Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B9A046B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:29:16 -0400 (EDT)
Date: Fri, 12 Jun 2009 15:30:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Huge pages for device drivers
Message-ID: <20090612143005.GA4429@csn.ul.ie>
References: <202cde0e0906112141n634c1bd6n15ec1ac42faa36d3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0906112141n634c1bd6n15ec1ac42faa36d3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


On Fri, Jun 12, 2009 at 04:41:19PM +1200, Alexey Korolev wrote:
> Hi,
> 
> I'm investigating the possibility to involve huge pages mappings in
> order to increase data analysing performance in case of device
> drivers.
> The model we have is more or less common: We have driver which
> allocates memory and configures DMA. This memory is then shared to
> user mode applications to allow user-mode daemons to analyse and
> process the data.
> 

Ok. So the order is

1. driver alloc_pages()
2. driver DMA
3. userspace mmap
4. userspace fault

?

> In this case Huge TLB could be quite useful because DMA buffers are
> large ~64MB - 1024MB and desired performance of data analysing in user
> mode is huge ~10Gb/s.
> 
> If I properly understood the code the only available approach is :
> Allocate huge page memory in user mode application. Then supply it to
> driver. Then do magic to obtain physical address and try to configure
> DMAs. But this approach leads to big bunch of problems because: 1.
> Virtual address can be remapped to another physical address.

Yeah, fork() + COW could be a woeful kick in the pants if it happened at
the wrong time.

> 2. It is
> necessary to manage GFP flags manually (GFP_DMA32 must be set).
> 

Indeed.

> So the question I have:
> 1. Is it definitely the only way to provide huge page mappings in this
> case.  May be I miss something.

You didn't miss anything. There isn't currently a of providing such a page.

> 2. Is there any plans to provide interfaces for device drivers to map
> huge pages? What are possible issues to have it?
> 

There is no plan that I'm aware of but I'm happy to review any patches
you come up with :)

There is a subtle distinction depending on what you are really looking for.
If all you are interested in is large contiguous pages, then that is relatively
handy. I did a hatchet-job below to show how one could allocate pages from
hugepage pools that should not break reservations. It's not tested, it's just
to illustrate how something like this might be implemented because it's been
asked for a number of times. However, I doubt it's what driver people really
want, it's just what has been asked for on occasion :)

If you must get those mapped into userspace, then it would be tricky to get the
pages above mapped into userspace properly, particularly with respect to PTEs
and then making sure the fault occurs properly. I'd hate to be maintaining such
a driver. It could be worked around to some extent by doing something similar
to what happens for shmget() and shmat() and this would be relatively reusable.

1. Create a wrapper around hugetlb_file_setup() similar to what happens in
ipc/shm.c#newseg(). That would create a hugetlbfs file on an invisible mount
and reserve the hugepages you will need.

2. Create a function that is similar to a nopage fault handler that allocates
a hugepage within an offset in your hidden hugetlbfs file and inserts it
into the hugetlbfs pagecache giving you back the page frame for use with DMA.

3. Your mmap() implementation needs to create a VMA that is backed by this
hugetlbfs file so that minor faults will map the pages into userspace backed
by huge PTEs and reference counted properly.

Most of the code you need is already there, just not quite in the shape
you want it in. I have no plans to implement such a thing but I estimate it
wouldn't take someone who really cared more than a few days to implement it.

Anyway, here is the alloc_huge_page() prototype for what that's worth to
you

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0bbc15f..c3ce783 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -200,6 +200,9 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
+extern struct page *alloc_huge_page(gfp_t gfp_mask);
+extern void free_huge_page(struct page *page);
+
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
 
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 085c903..f5284f6 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -198,9 +198,11 @@ extern void mpol_rebind_task(struct task_struct *tsk,
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
 extern void mpol_fix_fork_child_flag(struct task_struct *p);
 
-extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
+extern struct zonelist *huge_zonelist_vma(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask);
+extern struct zonelist *huge_zonelist(gfp_t gfp_flags,
+				struct mempolicy **mpol, nodemask_t **nodemask);
 extern unsigned slab_node(struct mempolicy *policy);
 
 extern enum zone_type policy_zone;
@@ -319,7 +321,7 @@ static inline void mpol_fix_fork_child_flag(struct task_struct *p)
 {
 }
 
-static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
+static inline struct zonelist *huge_zonelist_vma(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask)
 {
@@ -328,6 +330,12 @@ static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 	return node_zonelist(0, gfp_flags);
 }
 
+static inline struct zonelist *huge_zonelist(gfp_t gfp_flags,
+				struct mempolicy **mpol, nodemask_t **nodemask)
+{
+	return huge_zonelist_vma(NULL, 0, gfp_flags, mpol, nodemask);
+}
+
 static inline int do_migrate_pages(struct mm_struct *mm,
 			const nodemask_t *from_nodes,
 			const nodemask_t *to_nodes, int flags)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e83ad2c..036845c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -473,6 +473,38 @@ static struct page *dequeue_huge_page(struct hstate *h)
 	return page;
 }
 
+static struct page *dequeue_huge_page_zonelist(struct hstate *h,
+				struct zonelist *zonelist,
+				nodemask_t *nodemask)
+{
+	int nid;
+	struct page *page = NULL;
+	struct zone *zone;
+	struct zoneref *z;
+
+	/* There is no reserve so ensure enough pages are in the pool */
+	if (h->free_huge_pages - h->resv_huge_pages == 0)
+		return NULL;
+
+	/* Walk the zonelist */
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+						MAX_NR_ZONES - 1, nodemask) {
+		nid = zone_to_nid(zone);
+		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask) &&
+		    !list_empty(&h->hugepage_freelists[nid])) {
+			page = list_entry(h->hugepage_freelists[nid].next,
+					  struct page, lru);
+			list_del(&page->lru);
+			h->free_huge_pages--;
+			h->free_huge_pages_node[nid]--;
+
+			break;
+		}
+	}
+
+	return page;
+}
+
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve)
@@ -481,7 +513,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	struct page *page = NULL;
 	struct mempolicy *mpol;
 	nodemask_t *nodemask;
-	struct zonelist *zonelist = huge_zonelist(vma, address,
+	struct zonelist *zonelist = huge_zonelist_vma(vma, address,
 					htlb_alloc_mask, &mpol, &nodemask);
 	struct zone *zone;
 	struct zoneref *z;
@@ -550,7 +582,7 @@ struct hstate *size_to_hstate(unsigned long size)
 	return NULL;
 }
 
-static void free_huge_page(struct page *page)
+static void __free_huge_page(struct page *page)
 {
 	/*
 	 * Can't pass hstate in here because it is called from the
@@ -578,6 +610,13 @@ static void free_huge_page(struct page *page)
 		hugetlb_put_quota(mapping, 1);
 }
 
+void free_huge_page(struct page *page)
+{
+	BUG_ON(page_count(page) != 1);
+	put_page_testzero(page);
+	__free_huge_page(page);
+}
+
 /*
  * Increment or decrement surplus_huge_pages.  Keep node-specific counters
  * balanced by operating on them in a round-robin fashion.
@@ -615,7 +654,7 @@ static int adjust_pool_surplus(struct hstate *h, int delta)
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 {
-	set_compound_page_dtor(page, free_huge_page);
+	set_compound_page_dtor(page, __free_huge_page);
 	spin_lock(&hugetlb_lock);
 	h->nr_huge_pages++;
 	h->nr_huge_pages_node[nid]++;
@@ -690,8 +729,7 @@ static int alloc_fresh_huge_page(struct hstate *h)
 	return ret;
 }
 
-static struct page *alloc_buddy_huge_page(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long address)
+static struct page *alloc_buddy_huge_page(struct hstate *h)
 {
 	struct page *page;
 	unsigned int nid;
@@ -750,7 +788,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h,
 		put_page_testzero(page);
 		VM_BUG_ON(page_count(page));
 		nid = page_to_nid(page);
-		set_compound_page_dtor(page, free_huge_page);
+		set_compound_page_dtor(page, __free_huge_page);
 		/*
 		 * We incremented the global counters already
 		 */
@@ -791,7 +829,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = alloc_buddy_huge_page(h, NULL, 0);
+		page = alloc_buddy_huge_page(h);
 		if (!page) {
 			/*
 			 * We were not able to allocate enough pages to
@@ -844,12 +882,12 @@ free:
 			list_del(&page->lru);
 			/*
 			 * The page has a reference count of zero already, so
-			 * call free_huge_page directly instead of using
+			 * call __free_huge_page directly instead of using
 			 * put_page.  This must be done with hugetlb_lock
-			 * unlocked which is safe because free_huge_page takes
+			 * unlocked which is safe because __free_huge_page takes
 			 * hugetlb_lock before deciding how to free the page.
 			 */
-			free_huge_page(page);
+			__free_huge_page(page);
 		}
 		spin_lock(&hugetlb_lock);
 	}
@@ -962,7 +1000,7 @@ static void vma_commit_reservation(struct hstate *h,
 	}
 }
 
-static struct page *alloc_huge_page(struct vm_area_struct *vma,
+static struct page *alloc_huge_page_fault(struct vm_area_struct *vma,
 				    unsigned long addr, int avoid_reserve)
 {
 	struct hstate *h = hstate_vma(vma);
@@ -990,7 +1028,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	spin_unlock(&hugetlb_lock);
 
 	if (!page) {
-		page = alloc_buddy_huge_page(h, vma, addr);
+		page = alloc_buddy_huge_page(h);
 		if (!page) {
 			hugetlb_put_quota(inode->i_mapping, chg);
 			return ERR_PTR(-VM_FAULT_OOM);
@@ -1005,6 +1043,40 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	return page;
 }
 
+/*
+ * alloc_huge_page - Allocate a single huge page for use with a driver
+ * gfp_mask - GFP mask to use if the buddy allocator is called
+ *
+ * alloc_huge_page() is intended for use by device drivers that want to
+ * back regions of memory with huge pages that will be later mapped to
+ * userspace. This is done outside of hugetlbfs and pages are allocated
+ * directly from the pool or from the buddy allocator. However, existing
+ * reservations are taken into account so use of this API will not
+ * destabilise hugetlbfs users
+ */
+struct page *alloc_huge_page(gfp_t gfp_mask)
+{
+	struct page *page;
+	struct mempolicy *mpol;
+	nodemask_t *nodemask;
+	struct hstate *h = &default_hstate;
+	struct zonelist *zonelist = huge_zonelist(gfp_mask, &mpol, &nodemask);
+
+	spin_lock(&hugetlb_lock);
+	page = dequeue_huge_page_zonelist(h, zonelist, nodemask);
+	spin_unlock(&hugetlb_lock);
+	if (!page) {
+		page = alloc_buddy_huge_page(h);
+		if (!page)
+			return NULL;
+	}
+
+	set_page_refcounted(page);
+	mpol_cond_put(mpol);
+	return page;
+}
+EXPORT_SYMBOL(alloc_huge_page);
+
 int __weak alloc_bootmem_huge_page(struct hstate *h)
 {
 	struct huge_bootmem_page *m;
@@ -1168,7 +1240,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
 	while (count > persistent_huge_pages(h)) {
 		/*
 		 * If this allocation races such that we no longer need the
-		 * page, free_huge_page will handle it by freeing the page
+		 * page, __free_huge_page will handle it by freeing the page
 		 * and reducing the surplus.
 		 */
 		spin_unlock(&hugetlb_lock);
@@ -1899,7 +1971,7 @@ retry_avoidcopy:
 		outside_reserve = 1;
 
 	page_cache_get(old_page);
-	new_page = alloc_huge_page(vma, address, outside_reserve);
+	new_page = alloc_huge_page_fault(vma, address, outside_reserve);
 
 	if (IS_ERR(new_page)) {
 		page_cache_release(old_page);
@@ -1992,7 +2064,7 @@ retry:
 		size = i_size_read(mapping->host) >> huge_page_shift(h);
 		if (idx >= size)
 			goto out;
-		page = alloc_huge_page(vma, address, 0);
+		page = alloc_huge_page_fault(vma, address, 0);
 		if (IS_ERR(page)) {
 			ret = -PTR_ERR(page);
 			goto out;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 3eb4a6f..d5c41fa 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1481,7 +1481,7 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
  * If the effective policy is 'BIND, returns a pointer to the mempolicy's
  * @nodemask for filtering the zonelist.
  */
-struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
+struct zonelist *huge_zonelist_vma(struct vm_area_struct *vma, unsigned long addr,
 				gfp_t gfp_flags, struct mempolicy **mpol,
 				nodemask_t **nodemask)
 {
@@ -1500,6 +1500,25 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 	}
 	return zl;
 }
+
+struct zonelist *huge_zonelist(gfp_t gfp_flags,
+			struct mempolicy **mpol, nodemask_t **nodemask)
+{
+	struct zonelist *zl;
+
+	*mpol = get_vma_policy(current, NULL, 0);
+	*nodemask = NULL;	/* assume !MPOL_BIND */
+
+	if (unlikely((*mpol)->mode == MPOL_INTERLEAVE)) {
+		zl = node_zonelist(interleave_nid(*mpol, vma, addr,
+				huge_page_shift(hstate_vma(vma))), gfp_flags);
+	} else {
+		zl = policy_zonelist(gfp_flags, *mpol);
+		if ((*mpol)->mode == MPOL_BIND)
+			*nodemask = &(*mpol)->v.nodes;
+	}
+	return zl;
+}
 #endif
 
 /* Allocate a page in interleaved policy.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
