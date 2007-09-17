Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8HGeBg2031240
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 12:40:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HGeBGJ522870
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 12:40:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HGeBkk001642
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 12:40:11 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/4] hugetlb: Try to grow hugetlb pool for MAP_SHARED mappings
Date: Mon, 17 Sep 2007 09:40:09 -0700
Message-Id: <20070917164009.32557.4348.stgit@kernel>
In-Reply-To: <20070917163935.32557.50840.stgit@kernel>
References: <20070917163935.32557.50840.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: libhugetlbfs-devel@lists.sourceforge.net, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

Shared mappings require special handling because the huge pages needed to
fully populate the VMA must be reserved at mmap time.  If not enough pages
are available when making the reservation, allocate all of the shortfall at
once from the buddy allocator and add the pages directly to the hugetlb
pool.  If they cannot be allocated, then fail the mapping.  The page
surplus is accounted for in the same way as for private mappings; faulted
surplus pages will be freed at unmap time.  Reserved, surplus pages that
have not been used must be freed separately when their reservation has been
released.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 mm/hugetlb.c |  161 ++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 138 insertions(+), 23 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 63abd31..1e78574 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -28,6 +28,7 @@ static struct list_head hugepage_freelists[MAX_NUMNODES];
 static unsigned int nr_huge_pages_node[MAX_NUMNODES];
 static unsigned int free_huge_pages_node[MAX_NUMNODES];
 static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+static unsigned long unused_surplus_pages;
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
@@ -85,6 +86,10 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 			list_del(&page->lru);
 			free_huge_pages--;
 			free_huge_pages_node[nid]--;
+			if (vma && vma->vm_flags & VM_MAYSHARE) {
+				resv_huge_pages--;
+				unused_surplus_pages--;
+			}
 			break;
 		}
 	}
@@ -174,15 +179,120 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
 	return page;
 }
 
+/*
+ * Increase the hugetlb pool such that it can accomodate a reservation
+ * of size 'delta'.
+ */
+static int gather_surplus_pages(int delta)
+{
+	struct list_head surplus_list;
+	struct page *page, *tmp;
+	int ret, i;
+	int needed, allocated;
+
+	needed = (resv_huge_pages + delta) - free_huge_pages;
+	if (needed <= 0)
+		return 0;
+
+	allocated = 0;
+	INIT_LIST_HEAD(&surplus_list);
+
+	ret = -ENOMEM;
+retry:
+	spin_unlock(&hugetlb_lock);
+	for (i = 0; i < needed; i++) {
+		page = alloc_buddy_huge_page(NULL, 0);
+		if (!page) {
+			/*
+			 * We were not able to allocate enough pages to
+			 * satisfy the entire reservation so we free what
+			 * we've allocated so far.
+			 */
+			spin_lock(&hugetlb_lock);
+			needed = 0;
+			goto free;
+		}
+
+		list_add(&page->lru, &surplus_list);
+	}
+	allocated += needed;
+
+	/*
+	 * After retaking hugetlb_lock, we need to recalculate 'needed'
+	 * because either resv_huge_pages or free_huge_pages may have changed.
+	 */
+	spin_lock(&hugetlb_lock);
+	needed = (resv_huge_pages + delta) - (free_huge_pages + allocated);
+	if (needed > 0)
+		goto retry;
+
+	/*
+	 * The surplus_list now contains _at_least_ the number of extra pages
+	 * needed to accomodate the reservation.  Add the appropriate number
+	 * of pages to the hugetlb pool and free the extras back to the buddy
+	 * allocator.
+	 *
+	 * Those pages that get added to the pool may never be allocated and
+	 * subsequently freed so keep track of them in unused_surplus_pages
+	 * so they can be freed again when a reservation is released.
+	 */
+	needed += allocated;
+	unused_surplus_pages += needed;
+	ret = 0;
+free:
+	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
+		list_del(&page->lru);
+		if ((--needed) >= 0)
+			enqueue_huge_page(page);
+		else
+			update_and_free_page(page);
+	}
+
+	return ret;
+}
+
+/*
+ * When releasing a reservation, free all unused, surplus huge pages that are
+ * no longer reserved.
+ */
+void return_unused_surplus_pages(void)
+{
+	static int nid = -1;
+	int delta;
+	struct page *page;
+
+	delta = unused_surplus_pages - resv_huge_pages;
+
+	while (delta) {
+		nid = next_node(nid, node_online_map);
+		if (nid == MAX_NUMNODES)
+			nid = first_node(node_online_map);
+
+		if (!surplus_huge_pages_node[nid])
+			continue;
+
+		if (!list_empty(&hugepage_freelists[nid])) {
+			page = list_entry(hugepage_freelists[nid].next,
+					  struct page, lru);
+			list_del(&page->lru);
+			update_and_free_page(page);
+			free_huge_pages--;
+			free_huge_pages_node[nid]--;
+			surplus_huge_pages_node[nid]--;
+			unused_surplus_pages--;
+			delta--;
+		}
+	}
+}
+
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr)
 {
 	struct page *page = NULL;
+	int use_reserved_page = vma->vm_flags & VM_MAYSHARE;
 
 	spin_lock(&hugetlb_lock);
-	if (vma->vm_flags & VM_MAYSHARE)
-		resv_huge_pages--;
-	else if (free_huge_pages <= resv_huge_pages)
+	if (!use_reserved_page && (free_huge_pages <= resv_huge_pages))
 		goto fail;
 
 	page = dequeue_huge_page(vma, addr);
@@ -194,8 +304,6 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	return page;
 
 fail:
-	if (vma->vm_flags & VM_MAYSHARE)
-		resv_huge_pages++;
 	spin_unlock(&hugetlb_lock);
 
 	/*
@@ -203,7 +311,7 @@ fail:
 	 * may have failed due to an undersized hugetlb pool.  Try to grab a
 	 * surplus huge page from the buddy allocator.
 	 */
-	if (!(vma->vm_flags & VM_MAYSHARE))
+	if (!use_reserved_page)
 		page = alloc_buddy_huge_page(vma, addr);
 
 	return page;
@@ -876,21 +984,6 @@ static int hugetlb_acct_memory(long delta)
 	int ret = -ENOMEM;
 
 	spin_lock(&hugetlb_lock);
-	if ((delta + resv_huge_pages) <= free_huge_pages) {
-		resv_huge_pages += delta;
-		ret = 0;
-	}
-	spin_unlock(&hugetlb_lock);
-	return ret;
-}
-
-int hugetlb_reserve_pages(struct inode *inode, long from, long to)
-{
-	long ret, chg;
-
-	chg = region_chg(&inode->i_mapping->private_list, from, to);
-	if (chg < 0)
-		return chg;
 	/*
 	 * When cpuset is configured, it breaks the strict hugetlb page
 	 * reservation as the accounting is done on a global variable. Such
@@ -908,8 +1001,30 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to)
 	 * a best attempt and hopefully to minimize the impact of changing
 	 * semantics that cpuset has.
 	 */
-	if (chg > cpuset_mems_nr(free_huge_pages_node))
-		return -ENOMEM;
+	if (delta > 0) {
+		if (gather_surplus_pages(delta) < 0)
+			goto out;
+
+		if (delta > cpuset_mems_nr(free_huge_pages_node))
+			goto out;
+	}
+
+	ret = 0;
+	resv_huge_pages += delta;
+	if (delta <= 0)
+		return_unused_surplus_pages();
+out:
+	spin_unlock(&hugetlb_lock);
+	return ret;
+}
+
+int hugetlb_reserve_pages(struct inode *inode, long from, long to)
+{
+	long ret, chg;
+
+	chg = region_chg(&inode->i_mapping->private_list, from, to);
+	if (chg < 0)
+		return chg;
 
 	ret = hugetlb_acct_memory(chg);
 	if (ret < 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
