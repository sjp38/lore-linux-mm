Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D46716B0272
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 09:01:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l4so10319761wre.10
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:01:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x128sor1967174wmg.61.2017.12.04.06.01.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 06:01:33 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 4/5] mm, hugetlb: get rid of surplus page accounting tricks
Date: Mon,  4 Dec 2017 15:01:16 +0100
Message-Id: <20171204140117.7191-5-mhocko@kernel.org>
In-Reply-To: <20171204140117.7191-1-mhocko@kernel.org>
References: <20171204140117.7191-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

alloc_surplus_huge_page increases the pool size and the number of
surplus pages opportunistically to prevent from races with the pool size
change. See d1c3fb1f8f29 ("hugetlb: introduce nr_overcommit_hugepages
sysctl") for more details.

The resulting code is unnecessarily hairy, cause code duplication and
doesn't allow to share the allocation paths. Moreover pool size changes
tend to be very seldom so optimizing for them is not really reasonable.
Simplify the code and allow to allocate a fresh surplus page as long as
we are under the overcommit limit and then recheck the condition after
the allocation and drop the new page if the situation has changed. This
should provide a reasonable guarantee that an abrupt allocation requests
will not go way off the limit.

If we consider races with the pool shrinking and enlarging then we
should be reasonably safe as well. In the first case we are off by one
in the worst case and the second case should work OK because the page is
not yet visible. We can waste CPU cycles for the allocation but that
should be acceptable for a relatively rare condition.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/hugetlb.c | 60 +++++++++++++++++++++---------------------------------------
 1 file changed, 21 insertions(+), 39 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a1b8b2888ec9..0c7dc269b6c0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1538,62 +1538,44 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 static struct page *__alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nmask)
 {
-	struct page *page;
-	unsigned int r_nid;
+	struct page *page = NULL;
 
 	if (hstate_is_gigantic(h))
 		return NULL;
 
-	/*
-	 * Assume we will successfully allocate the surplus page to
-	 * prevent racing processes from causing the surplus to exceed
-	 * overcommit
-	 *
-	 * This however introduces a different race, where a process B
-	 * tries to grow the static hugepage pool while alloc_pages() is
-	 * called by process A. B will only examine the per-node
-	 * counters in determining if surplus huge pages can be
-	 * converted to normal huge pages in adjust_pool_surplus(). A
-	 * won't be able to increment the per-node counter, until the
-	 * lock is dropped by B, but B doesn't drop hugetlb_lock until
-	 * no more huge pages can be converted from surplus to normal
-	 * state (and doesn't try to convert again). Thus, we have a
-	 * case where a surplus huge page exists, the pool is grown, and
-	 * the surplus huge page still exists after, even though it
-	 * should just have been converted to a normal huge page. This
-	 * does not leak memory, though, as the hugepage will be freed
-	 * once it is out of use. It also does not allow the counters to
-	 * go out of whack in adjust_pool_surplus() as we don't modify
-	 * the node values until we've gotten the hugepage and only the
-	 * per-node value is checked there.
-	 */
 	spin_lock(&hugetlb_lock);
-	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
-		spin_unlock(&hugetlb_lock);
-		return NULL;
-	} else {
-		h->nr_huge_pages++;
-		h->surplus_huge_pages++;
-	}
+	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages)
+		goto out_unlock;
 	spin_unlock(&hugetlb_lock);
 
 	page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask, nid, nmask);
+	if (!page)
+		goto out_unlock;
 
 	spin_lock(&hugetlb_lock);
-	if (page) {
+	/*
+	 * We could have raced with the pool size change.
+	 * Double check that and simply deallocate the new page
+	 * if we would end up overcommiting the surpluses. Abuse
+	 * temporary page to workaround the nasty free_huge_page
+	 * codeflow
+	 */
+	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
+		SetPageHugeTemporary(page);
+		put_page(page);
+		page = NULL;
+	} else {
+		h->surplus_huge_pages_node[page_to_nid(page)]++;
+		h->surplus_huge_pages++;
 		INIT_LIST_HEAD(&page->lru);
 		r_nid = page_to_nid(page);
 		set_compound_page_dtor(page, HUGETLB_PAGE_DTOR);
 		set_hugetlb_cgroup(page, NULL);
-		/*
-		 * We incremented the global counters already
-		 */
 		h->nr_huge_pages_node[r_nid]++;
 		h->surplus_huge_pages_node[r_nid]++;
-	} else {
-		h->nr_huge_pages--;
-		h->surplus_huge_pages--;
 	}
+
+out_unlock:
 	spin_unlock(&hugetlb_lock);
 
 	return page;
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
