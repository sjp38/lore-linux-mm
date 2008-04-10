Message-Id: <20080410171102.194867000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:49 +1000
From: npiggin@suse.de
Subject: [patch 17/17] hugetlb: misc fixes
Content-Disposition: inline; filename=hugetlb-fixes.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

These are some various fixes I noticed while reviewing and testing the
hugetlbfs patchset. Nothing fundamental, but I feel it tidies things up
a bit. Where possible I will merge each of these changes into the
appropriate patch, or otherwise split them up.

- remove global_hstate, make the default hstate handling slightly more regular
- fix some hangs and bugs when multiple hugepage command line options are given
- have alloc_bm_huge_page fall back to other nodes rather than give up first
- santise the printk hugepage reporting
- remove one of the initcalls and instead just call it from the main initcall.
- make it slightly more robust at handling bad command line input (eg duplicate
  parameters).
- align hugepage mmaps in x86 code
- sysctl shouldn't always return -EINVAL if the > MAX_ORDER value is unchanged.
  This fix involved putting a max_huge_pages value in the hstate, as well as
  retaining the sysctl table. I think this makes most of the code look nicer
  though.
- I've only been testing on a limited system (1 1GB page available), but
  the tlp test Andi previously reported failing appears to work OK. Not sure
  if it is due to these changes because I only started testing while writing
  this patch.

Signed-off-by: Nick Piggin <npiggin@suse.de>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: pj@sgi.com
Cc: andi@firstfloor.org
Cc: kniht@linux.vnet.ibm.com

---
 arch/x86/mm/hugetlbpage.c |   15 ++--
 fs/hugetlbfs/inode.c      |    4 -
 include/linux/hugetlb.h   |    7 +-
 mm/hugetlb.c              |  145 ++++++++++++++++++++++++++++------------------
 4 files changed, 105 insertions(+), 66 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -28,12 +28,13 @@ unsigned long sysctl_overcommit_huge_pag
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
-static int max_hstate = 1;
+static int max_hstate = 0;
 
+static unsigned long default_hstate_resv = 0;
 struct hstate hstates[HUGE_MAX_HSTATE];
 
 /* for command line parsing */
-struct hstate *parsed_hstate __initdata = &global_hstate;
+struct hstate *parsed_hstate __initdata = NULL;
 
 #define for_each_hstate(h) \
 	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
@@ -550,58 +551,48 @@ struct huge_bm_page {
 static int __init alloc_bm_huge_page(struct hstate *h)
 {
 	struct huge_bm_page *m;
-	m = __alloc_bootmem_node_nopanic(NODE_DATA(h->hugetlb_next_nid),
+	int nr_nodes = nodes_weight(node_online_map);
+
+	while (nr_nodes) {
+		m = __alloc_bootmem_node_nopanic(NODE_DATA(h->hugetlb_next_nid),
 					huge_page_size(h), huge_page_size(h),
 					0);
-	if (!m)
-		return 0;
+		if (m)
+			goto found;
+		hstate_next_node(h);
+		nr_nodes--;
+	}
+	return 0;
+
+found:
 	BUG_ON((unsigned long)virt_to_phys(m) & (huge_page_size(h) - 1));
 	/* Put them into a private list first because mem_map is not up yet */
 	list_add(&m->list, &huge_boot_pages);
 	m->hstate = h;
-	hstate_next_node(h);
 	return 1;
 }
 
 /* Put bootmem huge pages into the standard lists after mem_map is up */
-static int __init huge_init_bm(void)
+static void gather_bootmem_prealloc(void)
 {
 	unsigned long pages = 0;
 	struct huge_bm_page *m;
 	struct hstate *h = NULL;
-	char buf[32];
 
 	list_for_each_entry (m, &huge_boot_pages, list) {
 		struct page *page = virt_to_page(m);
 		h = m->hstate;
 		__ClearPageReserved(page);
+		WARN_ON(page_count(page) != 1);
 		prep_compound_page(page, h->order);
 		huge_new_page(h, page);
 		pages++;
 	}
-
-	/*
-	 * This only prints for a single hstate. This works for x86-64,
-	 * but if you do multiple > MAX_ORDER hstates you'll need to fix it.
-	 */
-	if (pages > 0)
-		printk(KERN_INFO "HugeTLB pre-allocated %ld %s pages\n",
-				h->free_huge_pages,
-				memfmt(buf, huge_page_size(h)));
-	return 0;
 }
-__initcall(huge_init_bm);
 
-static int __init hugetlb_init_hstate(struct hstate *h)
+static void __init hugetlb_init_hstate(struct hstate *h)
 {
 	unsigned long i;
-	char buf[32];
-	unsigned long pages = 0;
-
-	if (h == &global_hstate && !h->order) {
-		h->order = HPAGE_SHIFT - PAGE_SHIFT;
-		h->mask = HPAGE_MASK;
-	}
 
 	/* Don't reinitialize lists if they have been already init'ed */
 	if (!h->hugepage_freelists[0].next) {
@@ -611,29 +602,57 @@ static int __init hugetlb_init_hstate(st
 		h->hugetlb_next_nid = first_node(node_online_map);
 	}
 
-	while (h->parsed_hugepages < max_huge_pages[h - hstates]) {
+	while (h->parsed_hugepages < h->max_huge_pages) {
 		if (h->order > MAX_ORDER) {
 			if (!alloc_bm_huge_page(h))
 				break;
 		} else if (!alloc_fresh_huge_page(h))
 			break;
 		h->parsed_hugepages++;
-		pages++;
 	}
-	max_huge_pages[h - hstates] = h->parsed_hugepages;
+	h->max_huge_pages = h->parsed_hugepages;
+}
 
-	if (pages > 0)
-		printk(KERN_INFO "HugeTLB pre-allocated %ld %s pages\n",
-			h->free_huge_pages,
-			memfmt(buf, huge_page_size(h)));
-	return 0;
+static void __init hugetlb_init_hstates(void)
+{
+	struct hstate *h;
+
+	for_each_hstate (h) {
+		/* oversize hugepages were init'ed in early boot */
+		if (h->order <= MAX_ORDER)
+			hugetlb_init_hstate(h);
+		max_huge_pages[h - hstates] = h->max_huge_pages;
+	}
+}
+
+static void __init report_hugepages(void)
+{
+	struct hstate *h;
+
+	for_each_hstate (h) {
+		char buf[32];
+		printk(KERN_INFO "HugeTLB registered size %s, pre-allocated %ld pages\n",
+				memfmt(buf, huge_page_size(h)),
+				h->free_huge_pages);
+	}
 }
 
 static int __init hugetlb_init(void)
 {
-	if (HPAGE_SHIFT == 0)
-		return 0;
-	return hugetlb_init_hstate(&global_hstate);
+	BUILD_BUG_ON(HPAGE_SHIFT == 0);
+
+	if (!size_to_hstate(HPAGE_SIZE)) {
+		huge_add_hstate(HUGETLB_PAGE_ORDER);
+		parsed_hstate->max_huge_pages = default_hstate_resv;
+	}
+
+	hugetlb_init_hstates();
+
+	gather_bootmem_prealloc();
+
+	report_hugepages();
+
+	return 0;
 }
 module_init(hugetlb_init);
 
@@ -641,9 +660,14 @@ module_init(hugetlb_init);
 void __init huge_add_hstate(unsigned order)
 {
 	struct hstate *h;
-	BUG_ON(size_to_hstate(PAGE_SIZE << order));
+
+	if (size_to_hstate(PAGE_SIZE << order)) {
+		printk("hugepagesz= specified twice, ignoring\n");
+		return;
+	}
+
 	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
-	BUG_ON(order <= HPAGE_SHIFT - PAGE_SHIFT);
+	BUG_ON(order < HPAGE_SHIFT - PAGE_SHIFT);
 	h = &hstates[max_hstate++];
 	h->order = order;
 	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
@@ -653,17 +677,22 @@ void __init huge_add_hstate(unsigned ord
 
 static int __init hugetlb_setup(char *s)
 {
-	unsigned long *mhp = &max_huge_pages[parsed_hstate - hstates];
+	unsigned long *mhp;
+
+	if (!max_hstate)
+		mhp = &default_hstate_resv;
+	else
+		mhp = &parsed_hstate->max_huge_pages;
+
 	if (sscanf(s, "%lu", mhp) <= 0)
 		*mhp = 0;
+
 	/*
 	 * Global state is always initialized later in hugetlb_init.
 	 * But we need to allocate > MAX_ORDER hstates here early to still
 	 * use the bootmem allocator.
-	 * If you add additional hstates <= MAX_ORDER you'll need
-	 * to fix that.
 	 */
-	if (parsed_hstate != &global_hstate)
+	if (max_hstate > 0 && parsed_hstate->order > MAX_ORDER)
 		hugetlb_init_hstate(parsed_hstate);
 	return 1;
 }
@@ -719,8 +748,9 @@ set_max_huge_pages(struct hstate *h, uns
 	*err = 0;
 
 	if (h->order > MAX_ORDER) {
-		*err = -EINVAL;
-		return max_huge_pages[h - hstates];
+		if (count != h->max_huge_pages)
+			*err = -EINVAL;
+		return h->max_huge_pages;
 	}
 
 	/*
@@ -795,19 +825,24 @@ int hugetlb_sysctl_handler(struct ctl_ta
 {
 	int err = 0;
 	struct hstate *h;
-	int i;
+
 	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 	if (err)
 		return err;
-	i = 0;
-	for_each_hstate (h) {
-		max_huge_pages[i] = set_max_huge_pages(h, max_huge_pages[i],
-							&err);
-		if (err)
-			return err;
-		i++;
+
+	if (write) {
+		for_each_hstate (h) {
+			int tmp;
+
+			h->max_huge_pages = set_max_huge_pages(h,
+					max_huge_pages[h - hstates], &tmp);
+			max_huge_pages[h - hstates] = h->max_huge_pages;
+			if (tmp && !err)
+				err = tmp;
+		}
 	}
-	return 0;
+
+	return err;
 }
 
 int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c
+++ linux-2.6/fs/hugetlbfs/inode.c
@@ -827,7 +827,7 @@ hugetlbfs_parse_options(char *options, s
 		struct hstate *h = pconfig->hstate;
 		if (setsize == SIZE_PERCENT) {
 			size <<= huge_page_shift(h);
-			size *= max_huge_pages[h - hstates];
+			size *= h->max_huge_pages;
 			do_div(size, 100);
 		}
 		pconfig->nr_blocks = (size >> huge_page_shift(h));
@@ -857,7 +857,7 @@ hugetlbfs_fill_super(struct super_block 
 	config.uid = current->fsuid;
 	config.gid = current->fsgid;
 	config.mode = 0755;
-	config.hstate = &global_hstate;
+	config.hstate = size_to_hstate(HPAGE_SIZE);
 	ret = hugetlbfs_parse_options(data, &config);
 	if (ret)
 		return ret;
Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h
+++ linux-2.6/include/linux/hugetlb.h
@@ -208,7 +208,10 @@ struct hstate {
 	int hugetlb_next_nid;
 	unsigned int order;
 	unsigned long mask;
-	unsigned long nr_huge_pages, free_huge_pages, resv_huge_pages;
+	unsigned long max_huge_pages;
+	unsigned long nr_huge_pages;
+	unsigned long free_huge_pages;
+	unsigned long resv_huge_pages;
 	unsigned long surplus_huge_pages;
 	unsigned long nr_overcommit_huge_pages;
 	struct list_head hugepage_freelists[MAX_NUMNODES];
@@ -227,8 +230,6 @@ struct hstate *size_to_hstate(unsigned l
 
 extern struct hstate hstates[HUGE_MAX_HSTATE];
 
-#define global_hstate (hstates[0])
-
 static inline struct hstate *hstate_inode(struct inode *i)
 {
 	struct hugetlbfs_sb_info *hsb;
Index: linux-2.6/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
+++ linux-2.6/arch/x86/mm/hugetlbpage.c
@@ -259,6 +259,7 @@ static unsigned long hugetlb_get_unmappe
 		unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
+	struct hstate *h = hstate_file(file);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long start_addr;
@@ -271,7 +272,7 @@ static unsigned long hugetlb_get_unmappe
 	}
 
 full_search:
-	addr = ALIGN(start_addr, HPAGE_SIZE);
+	addr = ALIGN(start_addr, huge_page_size(h));
 
 	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
@@ -293,7 +294,7 @@ full_search:
 		}
 		if (addr + mm->cached_hole_size < vma->vm_start)
 		        mm->cached_hole_size = vma->vm_start - addr;
-		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
+		addr = ALIGN(vma->vm_end, huge_page_size(h));
 	}
 }
 
@@ -301,6 +302,7 @@ static unsigned long hugetlb_get_unmappe
 		unsigned long addr0, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
 {
+	struct hstate *h = hstate_file(file);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev_vma;
 	unsigned long base = mm->mmap_base, addr = addr0;
@@ -321,7 +323,7 @@ try_again:
 		goto fail;
 
 	/* either no address requested or cant fit in requested address hole */
-	addr = (mm->free_area_cache - len) & HPAGE_MASK;
+	addr = (mm->free_area_cache - len) & huge_page_mask(h);
 	do {
 		/*
 		 * Lookup failure means no vma is above this address,
@@ -352,7 +354,7 @@ try_again:
 		        largest_hole = vma->vm_start - addr;
 
 		/* try just below the current vma->vm_start */
-		addr = (vma->vm_start - len) & HPAGE_MASK;
+		addr = (vma->vm_start - len) & huge_page_mask(h);
 	} while (len <= vma->vm_start);
 
 fail:
@@ -390,10 +392,11 @@ unsigned long
 hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags)
 {
+	struct hstate *h = hstate_file(file);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 
-	if (len & ~HPAGE_MASK)
+	if (len & ~huge_page_mask(h))
 		return -EINVAL;
 	if (len > TASK_SIZE)
 		return -ENOMEM;
@@ -405,7 +408,7 @@ hugetlb_get_unmapped_area(struct file *f
 	}
 
 	if (addr) {
-		addr = ALIGN(addr, HPAGE_SIZE);
+		addr = ALIGN(addr, huge_page_size(h));
 		vma = find_vma(mm, addr);
 		if (TASK_SIZE - len >= addr &&
 		    (!vma || addr + len <= vma->vm_start))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
