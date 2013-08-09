Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id EA98C6B0071
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 05:27:17 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 19/20] mm, hugetlb: retry if failed to allocate and there is concurrent user
Date: Fri,  9 Aug 2013 18:26:37 +0900
Message-Id: <1376040398-11212-20-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If parallel fault occur, we can fail to allocate a hugepage,
because many threads dequeue a hugepage to handle a fault of same address.
This makes reserved pool shortage just for a little while and this cause
faulting thread who can get hugepages to get a SIGBUS signal.

To solve this problem, we already have a nice solution, that is,
a hugetlb_instantiation_mutex. This blocks other threads to dive into
a fault handler. This solve the problem clearly, but it introduce
performance degradation, because it serialize all fault handling.

Now, I try to remove a hugetlb_instantiation_mutex to get rid of
performance degradation. For achieving it, at first, we should ensure that
no one get a SIGBUS if there are enough hugepages.

For this purpose, if we fail to allocate a new hugepage when there is
concurrent user, we return just 0, instead of VM_FAULT_SIGBUS. With this,
these threads defer to get a SIGBUS signal until there is no
concurrent user, and so, we can ensure that no one get a SIGBUS if there
are enough hugepages.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index e29e28f..981c539 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -242,6 +242,7 @@ struct hstate {
 	int next_nid_to_free;
 	unsigned int order;
 	unsigned long mask;
+	unsigned long nr_dequeue_users;
 	unsigned long max_huge_pages;
 	unsigned long nr_huge_pages;
 	unsigned long free_huge_pages;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8743e5c..0501fe5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -561,6 +561,7 @@ retry_cpuset:
 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
 			if (page) {
+				h->nr_dequeue_users++;
 				if (!use_reserve)
 					break;
 
@@ -577,6 +578,16 @@ retry_cpuset:
 	return page;
 }
 
+static void commit_dequeued_huge_page(struct hstate *h, bool do_dequeue)
+{
+	if (!do_dequeue)
+		return;
+
+	spin_lock(&hugetlb_lock);
+	h->nr_dequeue_users--;
+	spin_unlock(&hugetlb_lock);
+}
+
 static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
@@ -1110,7 +1121,9 @@ static void vma_commit_reservation(struct hstate *h,
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
-				    unsigned long addr, int use_reserve)
+				    unsigned long addr, int use_reserve,
+				    unsigned long *nr_dequeue_users,
+				    bool *do_dequeue)
 {
 	struct hugepage_subpool *spool = subpool_vma(vma);
 	struct hstate *h = hstate_vma(vma);
@@ -1138,8 +1151,11 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		return ERR_PTR(-ENOSPC);
 	}
 	spin_lock(&hugetlb_lock);
+	*do_dequeue = true;
 	page = dequeue_huge_page_vma(h, vma, addr, use_reserve);
 	if (!page) {
+		*nr_dequeue_users = h->nr_dequeue_users;
+		*do_dequeue = false;
 		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
 		if (!page) {
@@ -1894,6 +1910,7 @@ void __init hugetlb_add_hstate(unsigned order)
 	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
 	h->nr_huge_pages = 0;
 	h->free_huge_pages = 0;
+	h->nr_dequeue_users = 0;
 	for (i = 0; i < MAX_NUMNODES; ++i)
 		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
 	INIT_LIST_HEAD(&h->hugepage_activelist);
@@ -2500,6 +2517,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	int outside_reserve = 0;
 	long chg;
 	bool use_reserve = false;
+	unsigned long nr_dequeue_users = 0;
+	bool do_dequeue = false;
 	int ret = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -2551,11 +2570,17 @@ retry_avoidcopy:
 		use_reserve = !chg;
 	}
 
-	new_page = alloc_huge_page(vma, address, use_reserve);
+	new_page = alloc_huge_page(vma, address, use_reserve,
+						&nr_dequeue_users, &do_dequeue);
 
 	if (IS_ERR(new_page)) {
 		page_cache_release(old_page);
 
+		if (nr_dequeue_users) {
+			ret = 0;
+			goto out_lock;
+		}
+
 		/*
 		 * If a process owning a MAP_PRIVATE mapping fails to COW,
 		 * it is due to references held by a child and an insufficient
@@ -2580,6 +2605,9 @@ retry_avoidcopy:
 			WARN_ON_ONCE(1);
 		}
 
+		if (use_reserve)
+			WARN_ON_ONCE(1);
+
 		ret = VM_FAULT_SIGBUS;
 		goto out_lock;
 	}
@@ -2614,6 +2642,7 @@ retry_avoidcopy:
 	page_cache_release(new_page);
 out_old_page:
 	page_cache_release(old_page);
+	commit_dequeued_huge_page(h, do_dequeue);
 out_lock:
 	/* Caller expects lock to be held */
 	spin_lock(&mm->page_table_lock);
@@ -2666,6 +2695,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_t new_pte;
 	long chg;
 	bool use_reserve;
+	unsigned long nr_dequeue_users = 0;
+	bool do_dequeue = false;
 
 	/*
 	 * Currently, we are forced to kill the process in the event the
@@ -2699,9 +2730,17 @@ retry:
 		}
 		use_reserve = !chg;
 
-		page = alloc_huge_page(vma, address, use_reserve);
+		page = alloc_huge_page(vma, address, use_reserve,
+					&nr_dequeue_users, &do_dequeue);
 		if (IS_ERR(page)) {
-			ret = VM_FAULT_SIGBUS;
+			if (nr_dequeue_users)
+				ret = 0;
+			else {
+				if (use_reserve)
+					WARN_ON_ONCE(1);
+
+				ret = VM_FAULT_SIGBUS;
+			}
 			goto out;
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
@@ -2714,22 +2753,24 @@ retry:
 			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
 			if (err) {
 				put_page(page);
+				commit_dequeued_huge_page(h, do_dequeue);
 				if (err == -EEXIST)
 					goto retry;
 				goto out;
 			}
 			ClearPagePrivate(page);
+			commit_dequeued_huge_page(h, do_dequeue);
 
 			spin_lock(&inode->i_lock);
 			inode->i_blocks += blocks_per_huge_page(h);
 			spin_unlock(&inode->i_lock);
 		} else {
 			lock_page(page);
+			anon_rmap = 1;
 			if (unlikely(anon_vma_prepare(vma))) {
 				ret = VM_FAULT_OOM;
 				goto backout_unlocked;
 			}
-			anon_rmap = 1;
 		}
 	} else {
 		/*
@@ -2783,6 +2824,8 @@ retry:
 	spin_unlock(&mm->page_table_lock);
 	unlock_page(page);
 out:
+	if (anon_rmap)
+		commit_dequeued_huge_page(h, do_dequeue);
 	return ret;
 
 backout:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
