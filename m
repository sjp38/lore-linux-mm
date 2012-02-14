Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 05B826B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 07:53:52 -0500 (EST)
Received: by vcbf13 with SMTP id f13so4350377vcb.14
        for <linux-mm@kvack.org>; Tue, 14 Feb 2012 04:53:51 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 14 Feb 2012 20:53:51 +0800
Message-ID: <CAJd=RBATj97k5UESDFx82bzt0K4OquhBoDkfjPBPacdmdfJE8g@mail.gmail.com>
Subject: [PATCH] mm: hugetlb: defer freeing pages when gathering surplus pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>

When gathering surplus pages, the number of needed pages is recomputed after
reacquiring hugetlb lock to catch changes in resv_huge_pages and
free_huge_pages. Plus it is recomputed with the number of newly allocated
pages involved.

Thus freeing pages could be deferred a bit to see if the final page request is
satisfied, though pages could be allocated less than needed.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Tue Feb 14 20:10:46 2012
+++ b/mm/hugetlb.c	Tue Feb 14 20:19:42 2012
@@ -852,6 +852,7 @@ static int gather_surplus_pages(struct h
 	struct page *page, *tmp;
 	int ret, i;
 	int needed, allocated;
+	bool alloc_ok = true;

 	needed = (h->resv_huge_pages + delta) - h->free_huge_pages;
 	if (needed <= 0) {
@@ -867,17 +868,13 @@ retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
-		if (!page)
-			/*
-			 * We were not able to allocate enough pages to
-			 * satisfy the entire reservation so we free what
-			 * we've allocated so far.
-			 */
-			goto free;
-
+		if (!page) {
+			alloc_ok = false;
+			break;
+		}
 		list_add(&page->lru, &surplus_list);
 	}
-	allocated += needed;
+	allocated += i;

 	/*
 	 * After retaking hugetlb_lock, we need to recalculate 'needed'
@@ -886,9 +883,16 @@ retry:
 	spin_lock(&hugetlb_lock);
 	needed = (h->resv_huge_pages + delta) -
 			(h->free_huge_pages + allocated);
-	if (needed > 0)
-		goto retry;
-
+	if (needed > 0) {
+		if (alloc_ok)
+			goto retry;
+		/*
+		 * We were not able to allocate enough pages to
+		 * satisfy the entire reservation so we free what
+		 * we've allocated so far.
+		 */
+		goto free;
+	}
 	/*
 	 * The surplus_list now contains _at_least_ the number of extra pages
 	 * needed to accommodate the reservation.  Add the appropriate number
@@ -914,10 +918,10 @@ retry:
 		VM_BUG_ON(page_count(page));
 		enqueue_huge_page(h, page);
 	}
+free:
 	spin_unlock(&hugetlb_lock);

 	/* Free unnecessary surplus pages to the buddy allocator */
-free:
 	if (!list_empty(&surplus_list)) {
 		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
 			list_del(&page->lru);
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
