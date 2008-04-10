Message-Id: <20080410171101.551336000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:43 +1000
From: npiggin@suse.de
Subject: [patch 11/17] hugetlbfs: support larger than MAX_ORDER
Content-Disposition: inline; filename=hugetlb-unlimited-order.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

This is needed on x86-64 to handle GB pages in hugetlbfs, because it is
not practical to enlarge MAX_ORDER to 1GB. 

Instead the 1GB pages are only allocated at boot using the bootmem
allocator using the hugepages=... option.

These 1G bootmem pages are never freed. In theory it would be possible
to implement that with some complications, but since it would be a one-way
street (> MAX_ORDER pages cannot be allocated later) I decided not to currently.

The > MAX_ORDER code is not ifdef'ed per architecture. It is not very big
and the ifdef uglyness seemed not be worth it.

Known problems: /proc/meminfo and "free" do not display the memory 
allocated for gb pages in "Total". This is a little confusing for the
user.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: pj@sgi.com
Cc: andi@firstfloor.org
Cc: kniht@linux.vnet.ibm.com

---
 mm/hugetlb.c |   64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 62 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/bootmem.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -158,7 +159,7 @@ static void free_huge_page(struct page *
 	INIT_LIST_HEAD(&page->lru);
 
 	spin_lock(&hugetlb_lock);
-	if (h->surplus_huge_pages_node[nid]) {
+	if (h->surplus_huge_pages_node[nid] && h->order <= MAX_ORDER) {
 		update_and_free_page(h, page);
 		h->surplus_huge_pages--;
 		h->surplus_huge_pages_node[nid]--;
@@ -220,6 +221,9 @@ static struct page *alloc_fresh_huge_pag
 {
 	struct page *page;
 
+	if (h->order > MAX_ORDER)
+		return NULL;
+
 	page = alloc_pages_node(nid,
 		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
 			huge_page_order(h));
@@ -276,6 +280,9 @@ static struct page *alloc_buddy_huge_pag
 	struct page *page;
 	unsigned int nid;
 
+	if (h->order > MAX_ORDER)
+		return NULL;
+
 	/*
 	 * Assume we will successfully allocate the surplus page to
 	 * prevent racing processes from causing the surplus to exceed
@@ -442,6 +449,10 @@ static void return_unused_surplus_pages(
 	/* Uncommit the reservation */
 	h->resv_huge_pages -= unused_resv_pages;
 
+	/* Cannot return gigantic pages currently */
+	if (h->order > MAX_ORDER)
+		return;
+
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
 
 	while (remaining_iterations-- && nr_pages) {
@@ -520,6 +531,44 @@ static struct page *alloc_huge_page(stru
 	return page;
 }
 
+static __initdata LIST_HEAD(huge_boot_pages);
+
+struct huge_bm_page {
+	struct list_head list;
+	struct hstate *hstate;
+};
+
+static int __init alloc_bm_huge_page(struct hstate *h)
+{
+	struct huge_bm_page *m;
+	m = __alloc_bootmem_node_nopanic(NODE_DATA(h->hugetlb_next_nid),
+					huge_page_size(h), huge_page_size(h),
+					0);
+	if (!m)
+		return 0;
+	BUG_ON((unsigned long)virt_to_phys(m) & (huge_page_size(h) - 1));
+	/* Put them into a private list first because mem_map is not up yet */
+	list_add(&m->list, &huge_boot_pages);
+	m->hstate = h;
+	hstate_next_node(h);
+	return 1;
+}
+
+/* Put bootmem huge pages into the standard lists after mem_map is up */
+static int __init huge_init_bm(void)
+{
+	struct huge_bm_page *m;
+	list_for_each_entry (m, &huge_boot_pages, list) {
+		struct page *page = virt_to_page(m);
+		struct hstate *h = m->hstate;
+		__ClearPageReserved(page);
+		prep_compound_page(page, h->order);
+		huge_new_page(h, page);
+	}
+	return 0;
+}
+__initcall(huge_init_bm);
+
 static int __init hugetlb_init_hstate(struct hstate *h)
 {
 	unsigned long i;
@@ -535,7 +584,10 @@ static int __init hugetlb_init_hstate(st
 	h->hugetlb_next_nid = first_node(node_online_map);
 
 	for (i = 0; i < max_huge_pages[h - hstates]; ++i) {
-		if (!alloc_fresh_huge_page(h))
+		if (h->order > MAX_ORDER) {
+			if (!alloc_bm_huge_page(h))
+				break;
+		} else if (!alloc_fresh_huge_page(h))
 			break;
 	}
 	max_huge_pages[h - hstates] = h->free_huge_pages = h->nr_huge_pages = i;
@@ -594,6 +646,9 @@ static void try_to_free_low(struct hstat
 {
 	int i;
 
+	if (h->order > MAX_ORDER)
+		return;
+
 	for (i = 0; i < MAX_NUMNODES; ++i) {
 		struct page *page, *next;
 		struct list_head *freel = &h->hugepage_freelists[i];
@@ -623,6 +678,11 @@ set_max_huge_pages(struct hstate *h, uns
 
 	*err = 0;
 
+	if (h->order > MAX_ORDER) {
+		*err = -EINVAL;
+		return max_huge_pages[h - hstates];
+	}
+
 	/*
 	 * Increase the pool size
 	 * First take pages out of surplus state.  Then make up the

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
