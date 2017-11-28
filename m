Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADD476B025F
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 09:12:20 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id b189so474358wmd.5
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 06:12:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17sor9823487edf.7.2017.11.28.06.12.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 06:12:19 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit during migration
Date: Tue, 28 Nov 2017 15:12:11 +0100
Message-Id: <20171128141211.11117-3-mhocko@kernel.org>
In-Reply-To: <20171128141211.11117-1-mhocko@kernel.org>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

hugepage migration relies on __alloc_buddy_huge_page to get a new page.
This has 2 main disadvantages.
1) it doesn't allow to migrate any huge page if the pool is used
completely which is not an exceptional case as the pool is static and
unused memory is just wasted.
2) it leads to a weird semantic when migration between two numa nodes
might increase the pool size of the destination NUMA node while the page
is in use. The issue is caused by per NUMA node surplus pages tracking
(see free_huge_page).

Address both issues by changing the way how we allocate and account
pages allocated for migration. Those should temporal by definition.
So we mark them that way (we will abuse page flags in the 3rd page)
and update free_huge_page to free such pages to the page allocator.
Page migration path then just transfers the temporal status from the
new page to the old one which will be freed on the last reference.
The global surplus count will never change during this path but we still
have to be careful when freeing a page from a node with surplus pages
on the node.

Rename __alloc_buddy_huge_page to __alloc_surplus_huge_page to better
reflect its purpose. The new allocation routine for the migration path
is __alloc_migrate_huge_page.

The user visible effect of this patch is that migrated pages are really
temporal and they travel between NUMA nodes as per the migration
request:
Before migration
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:1
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0

After

/sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:0
/sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:1
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0

with the previous implementation, both nodes would have nr_hugepages:1
until the page is freed.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/hugetlb.h | 35 +++++++++++++++++++++++++++++
 mm/hugetlb.c            | 58 +++++++++++++++++++++++++++++++++++--------------
 mm/migrate.c            | 13 +++++++++++
 3 files changed, 90 insertions(+), 16 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6e3696c7b35a..1b6d7783c717 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -157,8 +157,43 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
 
 bool is_hugetlb_entry_migration(pte_t pte);
+
+/*
+ * Internal hugetlb specific page flag. Do not use outside of the hugetlb
+ * code
+ */
+static inline bool PageHugeTemporary(struct page *page)
+{
+	if (!PageHuge(page))
+		return false;
+
+	return page[2].flags == -1U;
+}
+
+static inline void SetPageHugeTemporary(struct page *page)
+{
+	page[2].flags = -1U;
+}
+
+static inline void ClearPageHugeTemporary(struct page *page)
+{
+	page[2].flags = 0;
+}
 #else /* !CONFIG_HUGETLB_PAGE */
 
+static inline bool PageHugeTemporary(struct page *page)
+{
+	return false;
+}
+
+static inline void SetPageHugeTemporary(struct page *page)
+{
+}
+
+static inline void ClearPageHugeTemporary(struct page *page)
+{
+}
+
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8189c92fac82..037bf0f89463 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1283,7 +1283,13 @@ void free_huge_page(struct page *page)
 	if (restore_reserve)
 		h->resv_huge_pages++;
 
-	if (h->surplus_huge_pages_node[nid]) {
+	if (PageHugeTemporary(page)) {
+		list_del(&page->lru);
+		ClearPageHugeTemporary(page);
+		update_and_free_page(h, page);
+		if (h->surplus_huge_pages_node[nid])
+			h->surplus_huge_pages_node[nid]--;
+	} else if (h->surplus_huge_pages_node[nid]) {
 		/* remove the page from active list */
 		list_del(&page->lru);
 		update_and_free_page(h, page);
@@ -1531,7 +1537,11 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 	return rc;
 }
 
-static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
+/*
+ * Allocates a fresh surplus page from the page allocator. Temporary
+ * requests (e.g. page migration) can pass enforce_overcommit == false
+ */
+static struct page *__alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nmask)
 {
 	struct page *page;
@@ -1595,6 +1605,28 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h, gfp_t gfp_mask,
 	return page;
 }
 
+static struct page *__alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
+		int nid, nodemask_t *nmask)
+{
+	struct page *page;
+
+	if (hstate_is_gigantic(h))
+		return NULL;
+
+	page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask, nid, nmask);
+	if (!page)
+		return NULL;
+
+	/*
+	 * We do not account these pages as surplus because they are only
+	 * temporary and will be released properly on the last reference
+	 */
+	prep_new_huge_page(h, page, page_to_nid(page));
+	SetPageHugeTemporary(page);
+
+	return page;
+}
+
 /*
  * Use the VMA's mpolicy to allocate a huge page from the buddy.
  */
@@ -1609,17 +1641,13 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
 	nodemask_t *nodemask;
 
 	nid = huge_node(vma, addr, gfp_mask, &mpol, &nodemask);
-	page = __alloc_buddy_huge_page(h, gfp_mask, nid, nodemask);
+	page = __alloc_surplus_huge_page(h, gfp_mask, nid, nodemask);
 	mpol_cond_put(mpol);
 
 	return page;
 }
 
-/*
- * This allocation function is useful in the context where vma is irrelevant.
- * E.g. soft-offlining uses this function because it only cares physical
- * address of error page.
- */
+/* page migration callback function */
 struct page *alloc_huge_page_node(struct hstate *h, int nid)
 {
 	gfp_t gfp_mask = htlb_alloc_mask(h);
@@ -1634,12 +1662,12 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 	spin_unlock(&hugetlb_lock);
 
 	if (!page)
-		page = __alloc_buddy_huge_page(h, gfp_mask, nid, NULL);
+		page = __alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
 
 	return page;
 }
 
-
+/* page migration callback function */
 struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 		nodemask_t *nmask)
 {
@@ -1657,9 +1685,7 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	/* No reservations, try to overcommit */
-
-	return __alloc_buddy_huge_page(h, gfp_mask, preferred_nid, nmask);
+	return __alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
 }
 
 /*
@@ -1687,7 +1713,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = __alloc_buddy_huge_page(h, htlb_alloc_mask(h),
+		page = __alloc_surplus_huge_page(h, htlb_alloc_mask(h),
 				NUMA_NO_NODE, NULL);
 		if (!page) {
 			alloc_ok = false;
@@ -2284,7 +2310,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * First take pages out of surplus state.  Then make up the
 	 * remaining difference by allocating fresh huge pages.
 	 *
-	 * We might race with __alloc_buddy_huge_page() here and be unable
+	 * We might race with __alloc_surplus_huge_page() here and be unable
 	 * to convert a surplus huge page to a normal huge page. That is
 	 * not critical, though, it just means the overall size of the
 	 * pool might be one hugepage larger than it needs to be, but
@@ -2330,7 +2356,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * By placing pages into the surplus state independent of the
 	 * overcommit value, we are allowing the surplus pool size to
 	 * exceed overcommit. There are few sane options here. Since
-	 * __alloc_buddy_huge_page() is checking the global counter,
+	 * __alloc_surplus_huge_page() is checking the global counter,
 	 * though, we'll note that we're not allowed to exceed surplus
 	 * and won't grow the pool anywhere else. Not until one of the
 	 * sysctls are changed, or the surplus pages go out of use.
diff --git a/mm/migrate.c b/mm/migrate.c
index 4d0be47a322a..b3345f8174a9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1326,6 +1326,19 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		hugetlb_cgroup_migrate(hpage, new_hpage);
 		put_new_page = NULL;
 		set_page_owner_migrate_reason(new_hpage, reason);
+
+		/*
+		 * transfer temporary state of the new huge page. This is
+		 * reverse to other transitions because the newpage is going to
+		 * be final while the old one will be freed so it takes over
+		 * the temporary status.
+		 * No need for any locking here because destructor cannot race
+		 * with us.
+		 */
+		if (PageHugeTemporary(new_hpage)) {
+			SetPageHugeTemporary(hpage);
+			ClearPageHugeTemporary(new_hpage);
+		}
 	}
 
 	unlock_page(hpage);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
