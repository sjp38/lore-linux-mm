From: Ruthiano Simioni Munaretti <ruthiano@exatas.unisinos.br>
Subject: Non-Contiguous Memory Allocation Tests
Date: Tue, 9 Dec 2003 11:11:21 -0200
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_5nc1/OEDkzTNzgc"
Message-Id: <200312091111.21349.ruthiano@exatas.unisinos.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_5nc1/OEDkzTNzgc
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I and a colleague were making tests in Non-Contiguous Memory Allocator. We 
implemented VGNCA, a non-contiguous memory allocator improvement.

In the current non-contiguous memory allocator, each physical page is 
allocated by time, through alloc_page() function call. However, each one of 
this calls has an associated overhead with enable/disable interrupts.

In VGNCA, the main idea is enable/disable interrupts only one time, reducing 
this overhead. Also, VGNCA allocation/deallocation functions are a little 
more simple, because elimination of unnecessary test conditions in size 
allocation.

Our patch is intended to be a test to check if this could bring enough 
benefits to deserve a more careful implementation. We also included some code 
to benchmark allocations and deallocations, using the RDTSC instruction.

We are sending:
- Patch against 2.6.0-test11 with these modifications.
- Graphics with performance tests:
--- small-allocations.eps/small-frees.eps --> 1-128 kB
--- large-allocations.eps/large-frees.eps --> 1-64 MB

LMB, Ruthiano.

--Boundary-00=_5nc1/OEDkzTNzgc
Content-Type: text/x-diff;
  charset="us-ascii";
  name="vgnca-test11.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="vgnca-test11.patch"

diff -Naur a/arch/i386/mm/pageattr.c b/arch/i386/mm/pageattr.c
--- a/arch/i386/mm/pageattr.c	2003-11-26 18:43:41.000000000 -0200
+++ b/arch/i386/mm/pageattr.c	2003-12-04 17:00:25.000000000 -0200
@@ -175,6 +175,23 @@
 	return err;
 }
 
+int vgnca_change_page_attr(struct page *page, int numpages, pgprot_t prot)
+{
+	int err = 0; 
+	int i; 
+
+	/* (VGNCA) spin_lock_irqsave(&cpa_lock, flags); */
+   spin_lock(&cpa_lock);
+	for (i = 0; i < numpages; i++, page++) { 
+		err = __change_page_attr(page, prot);
+		if (err) 
+			break; 
+	} 	
+	/* (VGNCA) spin_unlock_irqrestore(&cpa_lock, flags); */
+   spin_unlock(&cpa_lock);
+	return err;
+}
+
 void global_flush_tlb(void)
 { 
 	LIST_HEAD(l);
@@ -208,6 +225,20 @@
 	 */
 	__flush_tlb_all();
 }
+
+void vgnca_kernel_map_pages(struct page *page, int numpages, int enable)
+{
+	if (PageHighMem(page))
+		return;
+	/* the return value is ignored - the calls cannot fail,
+	 * large pages are disabled at boot time.
+	 */
+	vgnca_change_page_attr(page, numpages, enable ? PAGE_KERNEL : __pgprot(0));
+	/* we should perform an IPI and flush all tlbs,
+	 * but that can deadlock->flush only current cpu.
+	 */
+	__flush_tlb_all();
+}
 EXPORT_SYMBOL(kernel_map_pages);
 #endif
 
diff -Naur a/fs/proc/proc_misc.c b/fs/proc/proc_misc.c
--- a/fs/proc/proc_misc.c	2003-11-26 18:43:07.000000000 -0200
+++ b/fs/proc/proc_misc.c	2003-12-04 17:04:22.000000000 -0200
@@ -237,6 +237,161 @@
 #undef K
 }
 
+
+/*************************
+   VGNCA: benchmark vmalloc
+ *************************/
+
+/* thanks to rnsanchez & felipewd */
+#define rdtsc(ticks) \
+    __asm__ volatile (".byte 0x0f, 0x31" : "=A" (ticks));
+
+
+#define VMALLOC_THEN_VFREE(AMOUNT_IN_BYTES)                                 \
+{                                                                           \
+   poff += sprintf(page+poff, "%d", (AMOUNT_IN_BYTES));                     \
+   rdtsc(ticks_before);                                                     \
+   mem = vmalloc((AMOUNT_IN_BYTES));                                        \
+   rdtsc(ticks_after);                                                      \
+   poff += sprintf(page+poff, "\t%lld", ticks_after - ticks_before);        \
+                                                                            \
+   if (!mem)                                                                \
+      poff += sprintf(page+poff, "\tallocation failed!\n");                 \
+   else                                                                     \
+   {                                                                        \
+      rdtsc(ticks_before);                                                  \
+      vfree(mem);                                                           \
+      rdtsc(ticks_after);                                                   \
+      poff += sprintf(page+poff, "\t%lld\n", ticks_after - ticks_before);   \
+   }                                                                        \
+}
+
+
+
+static int bm_vmalloc_read_proc_1(char *page, char **start, off_t off,
+                                  int count, int *eof, void *data)
+{
+	uint64_t ticks_before, ticks_after;
+        void* mem;
+        off_t poff = off;
+        int i;
+
+        if ((mem = vmalloc(1024)))
+           vfree (mem);
+
+        for (i = 1; i <= 32; ++i)
+           VMALLOC_THEN_VFREE(1024*i);
+
+        poff += sprintf(page+poff, "\n");
+
+        return proc_calc_metrics(page, start, off, count, eof, poff - off);
+}
+
+static int bm_vmalloc_read_proc_2(char *page, char **start, off_t off,
+                                  int count, int *eof, void *data)
+{
+	uint64_t ticks_before, ticks_after;
+        void* mem;
+        off_t poff = off;
+        int i;
+
+        if ((mem = vmalloc(1024)))
+           vfree (mem);
+
+        for (i = 33; i <= 64; ++i)
+           VMALLOC_THEN_VFREE(1024*i);
+
+        poff += sprintf(page+poff, "\n");
+
+        return proc_calc_metrics(page, start, off, count, eof, poff - off);
+}
+
+static int bm_vmalloc_read_proc_3(char *page, char **start, off_t off,
+                                  int count, int *eof, void *data)
+{
+	uint64_t ticks_before, ticks_after;
+        void* mem;
+        off_t poff = off;
+        int i;
+
+        if ((mem = vmalloc(1024)))
+           vfree (mem);
+
+        for (i = 65; i <= 96; ++i)
+           VMALLOC_THEN_VFREE(1024*i);
+
+        poff += sprintf(page+poff, "\n");
+
+        return proc_calc_metrics(page, start, off, count, eof, poff - off);
+}
+
+static int bm_vmalloc_read_proc_4(char *page, char **start, off_t off,
+                                  int count, int *eof, void *data)
+{
+	uint64_t ticks_before, ticks_after;
+        void* mem;
+        off_t poff = off;
+        int i = 0;
+
+        if ((mem = vmalloc(1024)))
+           vfree (mem);
+
+        for (i = 97; i <= 128; ++i)
+           VMALLOC_THEN_VFREE(1024*i);
+
+        poff += sprintf(page+poff, "\n");
+
+        return proc_calc_metrics(page, start, off, count, eof, poff - off);
+}
+
+static int bm_vmalloc_read_proc_m1(char *page, char **start, off_t off,
+                                   int count, int *eof, void *data)
+{
+	uint64_t ticks_before, ticks_after;
+        void* mem;
+        off_t poff = off;
+        int i = 0;
+
+        if ((mem = vmalloc(1024)))
+           vfree (mem);
+
+        for (i = 1; i <= 32; ++i)
+           VMALLOC_THEN_VFREE(1024*1024*i);
+
+        poff += sprintf(page+poff, "\n");
+
+        return proc_calc_metrics(page, start, off, count, eof, poff - off);
+}
+
+static int bm_vmalloc_read_proc_m2(char *page, char **start, off_t off,
+                                   int count, int *eof, void *data)
+{
+	uint64_t ticks_before, ticks_after;
+        void* mem;
+        off_t poff = off;
+        int i = 0;
+
+        if ((mem = vmalloc(1024)))
+           vfree (mem);
+
+        for (i = 33; i <= 64; ++i)
+           VMALLOC_THEN_VFREE(1024*1024*i);
+
+        poff += sprintf(page+poff, "\n");
+
+        return proc_calc_metrics(page, start, off, count, eof, poff - off);
+}
+
+
+#undef rdtsc
+#undef VMALLOC_THEN_VFREE
+
+
+/*************************
+   VGNCA: end of benchmark vmalloc
+ *************************/
+
+
 extern struct seq_operations fragmentation_op;
 static int fragmentation_open(struct inode *inode, struct file *file)
 {
@@ -663,6 +818,13 @@
 #endif
 		{"locks",	locks_read_proc},
 		{"execdomains",	execdomains_read_proc},
+		/* VGNCA: benchmark 'vmalloc()' */
+		{"bm-vmalloc-1",  bm_vmalloc_read_proc_1},
+		{"bm-vmalloc-2",  bm_vmalloc_read_proc_2},
+		{"bm-vmalloc-3",  bm_vmalloc_read_proc_3},
+		{"bm-vmalloc-4",  bm_vmalloc_read_proc_4},
+		{"bm-vmalloc-m1",  bm_vmalloc_read_proc_m1},
+		{"bm-vmalloc-m2",  bm_vmalloc_read_proc_m2},
 		{NULL,}
 	};
 	for (p = simple_ones; p->name; p++)
diff -Naur a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h	2003-11-26 18:43:26.000000000 -0200
+++ b/include/linux/gfp.h	2003-12-04 17:12:25.000000000 -0200
@@ -64,6 +64,10 @@
  * optimized to &contig_page_data at compile-time.
  */
 extern struct page * FASTCALL(__alloc_pages(unsigned int, unsigned int, struct zonelist *));
+
+
+/* VGNCA: this always allocate one page only, so the plural name is not good. */
+extern struct page * FASTCALL(__vgnca_alloc_pages(unsigned int, struct zonelist *));
 static inline struct page * alloc_pages_node(int nid, unsigned int gfp_mask, unsigned int order)
 {
 	if (unlikely(order >= MAX_ORDER))
@@ -87,13 +91,22 @@
 		__get_free_pages((gfp_mask) | GFP_DMA,(order))
 
 extern void FASTCALL(__free_pages(struct page *page, unsigned int order));
+extern void FASTCALL(__vgnca_free_pages(struct page *page /*, (VGNCA) unsigned int order*/));
 extern void FASTCALL(free_pages(unsigned long addr, unsigned int order));
 extern void FASTCALL(free_hot_page(struct page *page));
 extern void FASTCALL(free_cold_page(struct page *page));
 
 #define __free_page(page) __free_pages((page), 0)
+/* (VGNCA) no longer passing 'order' */
+#define __vgnca_free_page(page) __vgnca_free_pages((page))
 #define free_page(addr) free_pages((addr),0)
 
 void page_alloc_init(void);
 
+
+/* VGNCA: no longer pass the 'order' parameter (is always 0) */
+#define vgnca_alloc_page(gfp_mask) \
+	__vgnca_alloc_pages((gfp_mask), NODE_DATA(numa_node_id())->node_zonelists + ((gfp_mask) & GFP_ZONEMASK))
+
+
 #endif /* __LINUX_GFP_H */
diff -Naur a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h	2003-11-26 18:42:55.000000000 -0200
+++ b/include/linux/mm.h	2003-12-04 17:14:17.000000000 -0200
@@ -620,6 +620,11 @@
 kernel_map_pages(struct page *page, int numpages, int enable)
 {
 }
+
+static inline void
+vgnca_kernel_map_pages(struct page *page, int numpages, int enable)
+{
+}
 #endif
 
 #endif /* __KERNEL__ */
diff -Naur a/include/linux/vmalloc.h b/include/linux/vmalloc.h
--- a/include/linux/vmalloc.h	2003-11-26 18:45:53.000000000 -0200
+++ b/include/linux/vmalloc.h	2003-12-04 17:15:10.000000000 -0200
@@ -26,6 +26,7 @@
 extern void *vmalloc_32(unsigned long size);
 extern void *__vmalloc(unsigned long size, int gfp_mask, pgprot_t prot);
 extern void vfree(void *addr);
+extern void vgnca_vfree(void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
diff -Naur a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	2003-11-26 18:42:56.000000000 -0200
+++ b/mm/page_alloc.c	2003-12-04 17:23:42.000000000 -0200
@@ -209,6 +209,51 @@
 	list_add(&(base + page_idx)->list, &area->free_list);
 }
 
+
+static inline void __vgnca_free_pages_bulk (struct page *page, struct page *base,
+		struct zone *zone, struct free_area *area, unsigned long mask
+		/*, (VGNCA) unsigned int order*/)
+{
+	unsigned long page_idx, index;
+
+/* (VGNCA)
+	if (order)
+		destroy_compound_page(page, order);
+*/
+	page_idx = page - base;
+	if (page_idx & ~mask)
+		BUG();
+	index = page_idx >> (1 /* (VGNCA) + order*/);
+
+	zone->free_pages -= mask;
+	while (mask + (1 << (MAX_ORDER-1))) {
+		struct page *buddy1, *buddy2;
+
+		BUG_ON(area >= zone->free_area + MAX_ORDER);
+		if (!__test_and_change_bit(index, area->map))
+			/*
+			 * the buddy page is still allocated.
+			 */
+			break;
+		/*
+		 * Move the buddy up one level.
+		 * This code is taking advantage of the identity:
+		 * 	-mask = 1+~mask
+		 */
+		buddy1 = base + (page_idx ^ -mask);
+		buddy2 = base + page_idx;
+		BUG_ON(bad_range(zone, buddy1));
+		BUG_ON(bad_range(zone, buddy2));
+		list_del(&buddy1->list);
+		mask <<= 1;
+		area++;
+		index >>= 1;
+		page_idx &= mask;
+	}
+	list_add(&(base + page_idx)->list, &area->free_list);
+}
+
+
 static inline void free_pages_check(const char *function, struct page *page)
 {
 	if (	page_mapped(page) ||
@@ -264,6 +309,36 @@
 	return ret;
 }
 
+
+static int
+vgnca_free_pages_bulk(struct zone *zone, int count,
+                      struct list_head *list /* (VGNCA), unsigned int order */)
+{
+	unsigned long mask;
+	struct free_area *area;
+	struct page *base, *page = NULL;
+	int ret = 0;
+
+	mask = (~0UL) /* (VGNCA) << order*/;
+	base = zone->zone_mem_map;
+	area = zone->free_area /* (VGNCA) + order */;
+	/* (VGNCA) spin_lock_irqsave(&zone->lock, flags); */
+   spin_lock(&zone->lock);
+	zone->all_unreclaimable = 0;
+	zone->pages_scanned = 0;
+	while (!list_empty(list) && count--) {
+		page = list_entry(list->prev, struct page, list);
+		/* have to delete it as __free_pages_bulk list manipulates */
+		list_del(&page->list);
+		__vgnca_free_pages_bulk(page, base, zone, area, mask /* (VGNCA) , order */);
+		ret++;
+	}
+	/* (VGNCA) spin_unlock_irqrestore(&zone->lock, flags); */
+   spin_unlock(&zone->lock);
+	return ret;
+}
+
+
 void __free_pages_ok(struct page *page, unsigned int order)
 {
 	LIST_HEAD(list);
@@ -389,6 +464,29 @@
 	return allocated;
 }
 
+
+static int vgnca_rmqueue_bulk(struct zone *zone, /* (VGNCA) unsigned int order, */
+			unsigned long count, struct list_head *list)
+{
+	int i;
+	int allocated = 0;
+	struct page *page;
+	
+	/* (VGNCA) spin_lock_irqsave(&zone->lock, flags); */
+   spin_lock(&zone->lock);
+	for (i = 0; i < count; ++i) {
+		page = __rmqueue(zone, 0 /*(VGNCA) order*/);
+		if (page == NULL)
+			break;
+		allocated++;
+		list_add_tail(&page->list, list);
+	}
+	/* (VGNCA) spin_unlock_irqrestore(&zone->lock, flags); */
+   spin_unlock(&zone->lock);
+	return allocated;
+}
+
+
 #ifdef CONFIG_PM
 int is_head_of_free_region(struct page *page)
 {
@@ -461,10 +559,34 @@
 	put_cpu();
 }
 
+static void FASTCALL(vgnca_free_hot_cold_page(struct page *page, int cold));
+static void vgnca_free_hot_cold_page(struct page *page, int cold)
+{
+	struct zone *zone = page_zone(page);
+	struct per_cpu_pages *pcp;
+
+	vgnca_kernel_map_pages(page, 1, 0);
+	inc_page_state(pgfree);
+	free_pages_check(__FUNCTION__, page);
+	pcp = &zone->pageset[get_cpu()].pcp[cold];
+	/* (VGNCA) local_irq_save(flags); */
+	if (pcp->count >= pcp->high)
+		pcp->count -= vgnca_free_pages_bulk(zone, pcp->batch, &pcp->list/* (VGNCA), 0*/);
+	list_add(&page->list, &pcp->list);
+	pcp->count++;
+	/* (VGNCA) local_irq_restore(flags); */
+	put_cpu();
+}
+
 void free_hot_page(struct page *page)
 {
 	free_hot_cold_page(page, 0);
 }
+
+void vgnca_free_hot_page(struct page *page)
+{
+	vgnca_free_hot_cold_page(page, 0);
+}
 	
 void free_cold_page(struct page *page)
 {
@@ -515,6 +637,52 @@
 	return page;
 }
 
+
+/*  VGNCA:
+ *  - No longer pass 'order' as parameter.
+ */
+static struct page *vgnca_buffered_rmqueue(struct zone *zone, int cold)
+{
+	struct page *page = NULL;
+
+/*	(VGNCA) if (order == 0) { */
+		struct per_cpu_pages *pcp;
+
+		pcp = &zone->pageset[get_cpu()].pcp[cold];
+		/* (VGNCA) local_irq_save(flags); */
+		if (pcp->count <= pcp->low)
+			pcp->count += vgnca_rmqueue_bulk(zone, /* (VGNCA) 0, */
+						pcp->batch, &pcp->list);
+		if (pcp->count) {
+			page = list_entry(pcp->list.next, struct page, list);
+			list_del(&page->list);
+			pcp->count--;
+		}
+		/* (VGNCA) local_irq_restore(flags);*/
+		put_cpu();
+/*	(VGNCA) } */
+
+	if (page == NULL) {
+		/* (VGNCA) spin_lock_irqsave(&zone->lock, flags); */
+      spin_lock(&zone->lock);
+		page = __rmqueue(zone, 0 /* (VGNCA) order */);
+		/* (VGNCA) spin_unlock_irqrestore(&zone->lock, flags); */
+      spin_unlock(&zone->lock);
+/* (VGNCA)
+		if (order && page)
+			prep_compound_page(page, order);
+*/
+	}
+
+	if (page != NULL) {
+		BUG_ON(bad_range(zone, page));
+		mod_page_state(pgalloc, 1 /* (VGNCA) << order */);
+		prep_new_page(page, 0 /* (VGNCA) order */);
+	}
+	return page;
+}
+
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  *
@@ -679,7 +847,166 @@
 	return page;
 }
 
+/* VGNCA:
+ *  - Removed the 'order' parameter (is always 0)
+ */
+struct page *
+__vgnca_alloc_pages(unsigned int gfp_mask, struct zonelist *zonelist)
+{
+	const int wait = gfp_mask & __GFP_WAIT;
+	unsigned long min;
+	struct zone **zones, *classzone;
+	struct page *page;
+	struct reclaim_state reclaim_state;
+	struct task_struct *p = current;
+	int i;
+	int cold;
+
+	might_sleep_if(wait);
+
+	cold = 0;
+	if (gfp_mask & __GFP_COLD)
+		cold = 1;
+
+	zones = zonelist->zones;  /* the list of zones suitable for gfp_mask */
+	classzone = zones[0]; 
+	if (classzone == NULL)    /* no zones in the zonelist */
+		return NULL;
+
+	/* Go through the zonelist once, looking for a zone with enough free */
+	min = 1; /* VGNCA--used to be 'min = 1UL << order;' */
+	for (i = 0; zones[i] != NULL; i++) {
+		struct zone *z = zones[i];
+		unsigned long local_low;
+
+		/*
+		 * This is the fabled 'incremental min'. We let real-time tasks
+		 * dip their real-time paws a little deeper into reserves.
+		 */
+		local_low = z->pages_low;
+		if (rt_task(p))
+			local_low >>= 1;
+		min += local_low;
+
+		if (z->free_pages >= min ||
+				(!wait && z->free_pages >= z->pages_high)) {
+			page = vgnca_buffered_rmqueue(z, cold);
+			if (page)
+		       		goto got_pg;
+		}
+		min += z->pages_low * sysctl_lower_zone_protection;
+	}
+
+	/* we're somewhat low on memory, failed to find what we needed */
+	for (i = 0; zones[i] != NULL; i++)
+		wakeup_kswapd(zones[i]);
+
+	/* Go through the zonelist again, taking __GFP_HIGH into account */
+	min = 1; /* (VGNCA) min = 1UL << order; */
+	for (i = 0; zones[i] != NULL; i++) {
+		unsigned long local_min;
+		struct zone *z = zones[i];
+
+		local_min = z->pages_min;
+		if (gfp_mask & __GFP_HIGH)
+			local_min >>= 2;
+		if (rt_task(p))
+			local_min >>= 1;
+		min += local_min;
+		if (z->free_pages >= min ||
+				(!wait && z->free_pages >= z->pages_high)) {
+			page = vgnca_buffered_rmqueue(z, cold);
+			if (page)
+				goto got_pg;
+		}
+		min += local_min * sysctl_lower_zone_protection;
+	}
+
+	/* here we're in the low on memory slow path */
+
+rebalance:
+	if ((p->flags & (PF_MEMALLOC | PF_MEMDIE)) && !in_interrupt()) {
+		/* go through the zonelist yet again, ignoring mins */
+		for (i = 0; zones[i] != NULL; i++) {
+			struct zone *z = zones[i];
+
+			page = vgnca_buffered_rmqueue(z, cold);
+			if (page)
+				goto got_pg;
+		}
+		goto nopage;
+	}
+
+	/* Atomic allocations - we can't balance anything */
+	if (!wait)
+		goto nopage;
+
+	p->flags |= PF_MEMALLOC;
+	reclaim_state.reclaimed_slab = 0;
+	p->reclaim_state = &reclaim_state;
+
+	try_to_free_pages(classzone, gfp_mask, 0 /*order*/);
+
+	p->reclaim_state = NULL;
+	p->flags &= ~PF_MEMALLOC;
+
+	/* go through the zonelist yet one more time */
+	min = 1; /* (VGNCA) min = 1UL << order; */
+	for (i = 0; zones[i] != NULL; i++) {
+		struct zone *z = zones[i];
+
+		min += z->pages_min;
+		if (z->free_pages >= min ||
+				(!wait && z->free_pages >= z->pages_high)) {
+			page = vgnca_buffered_rmqueue(z, cold);
+			if (page)
+				goto got_pg;
+		}
+		min += z->pages_low * sysctl_lower_zone_protection;
+	}
+
+	/*
+	 * Don't let big-order allocations loop unless the caller explicitly
+	 * requests that.  Wait for some write requests to complete then retry.
+	 *
+	 * In this implementation, __GFP_REPEAT means __GFP_NOFAIL, but that
+	 * may not be true in other implementations.
+	 */
+
+/* (VGNCA) 'do_retry' will always be 1, because 'order <= 3' (actually,
+           'order == 0'). So, a lot of code can be removed from here.
+
+	do_retry = 0;
+	if (!(gfp_mask & __GFP_NORETRY)) {
+		if ((order <= 3) || (gfp_mask & __GFP_REPEAT))
+			do_retry = 1;
+		if (gfp_mask & __GFP_NOFAIL)
+			do_retry = 1;
+	}
+	if (do_retry) {
+		blk_congestion_wait(WRITE, HZ/50);
+		goto rebalance;
+	}
+*/
+/* (Added by VGNCA) */
+	blk_congestion_wait(WRITE, HZ/50);
+	goto rebalance;
+/* (End of VGNCA) */
+
+nopage:
+	if (!(gfp_mask & __GFP_NOWARN)) {
+		printk("%s: page allocation failure."
+			" order:%d, mode:0x%x\n",
+			p->comm, 0, gfp_mask);
+	}
+	return NULL;
+got_pg:
+	vgnca_kernel_map_pages(page, 1 << 0 /* (VGNCA) order*/, 1);
+	return page;
+}
 EXPORT_SYMBOL(__alloc_pages);
+EXPORT_SYMBOL(__vgnca_alloc_pages);
+
 
 /*
  * Common helper functions.
@@ -735,7 +1062,23 @@
 	}
 }
 
+
+/* (VGNCA) no longer taking an 'order' parameter */
+void __vgnca_free_pages(struct page *page)
+{
+	if (!PageReserved(page) && put_page_testzero(page)) {
+/* (VGNCA)
+		if (order == 0) */
+			vgnca_free_hot_page(page);
+/*	(VGNCA)
+	else
+			__free_pages_ok(page, 0);
+*/
+	}
+}
+
 EXPORT_SYMBOL(__free_pages);
+EXPORT_SYMBOL(__vgnca_free_pages);
 
 void free_pages(unsigned long addr, unsigned int order)
 {
diff -Naur a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c	2003-11-26 18:44:23.000000000 -0200
+++ b/mm/vmalloc.c	2003-12-04 17:37:25.000000000 -0200
@@ -20,6 +20,13 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
+#define CONFIG_USE_VGNCA
+
+#ifdef CONFIG_USE_VGNCA
+static int vgnca_alloc(struct vm_struct *area, int gfp_mask);
+static void vgnca_free(struct vm_struct *area);
+#endif
+
 
 rwlock_t vmlist_lock = RW_LOCK_UNLOCKED;
 struct vm_struct *vmlist;
@@ -309,6 +316,43 @@
 	return;
 }
 
+
+void __vgnca_vunmap(void *addr, int deallocate_pages)
+{
+	struct vm_struct *area;
+
+	if (!addr)
+		return;
+
+	if ((PAGE_SIZE-1) & (unsigned long)addr) {
+		printk(KERN_ERR "Trying to vfree() bad address (%p)\n", addr);
+		return;
+	}
+
+	area = remove_vm_area(addr);
+	if (unlikely(!area)) {
+		printk(KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
+				addr);
+		return;
+	}
+	
+	if (deallocate_pages) {
+		int i;
+
+		for (i = 0; i < area->nr_pages; i++) {
+			if (unlikely(!area->pages[i]))
+				BUG();
+			__vgnca_free_page(area->pages[i]);
+		}
+
+		kfree(area->pages);
+	}
+
+	kfree(area);
+	return;
+}
+
+
 /**
  *	vfree  -  release memory allocated by vmalloc()
  *
@@ -325,7 +369,13 @@
 	__vunmap(addr, 1);
 }
 
+void vgnca_vfree(void *addr)
+{
+	BUG_ON(in_interrupt());
+	__vgnca_vunmap(addr, 1);
+}
 EXPORT_SYMBOL(vfree);
+EXPORT_SYMBOL(vgnca_vfree);
 
 /**
  *	vunmap  -  release virtual mapping obtained by vmap()
@@ -392,7 +442,10 @@
 {
 	struct vm_struct *area;
 	struct page **pages;
-	unsigned int nr_pages, array_size, i;
+	unsigned int nr_pages, array_size;
+#ifndef CONFIG_USE_VGNCA
+   unsigned int i;
+#endif
 
 	size = PAGE_ALIGN(size);
 	if (!size || (size >> PAGE_SHIFT) > num_physpages)
@@ -414,6 +467,7 @@
 	}
 	memset(area->pages, 0, array_size);
 
+#ifndef CONFIG_USE_VGNCA
 	for (i = 0; i < area->nr_pages; i++) {
 		area->pages[i] = alloc_page(gfp_mask);
 		if (unlikely(!area->pages[i])) {
@@ -422,13 +476,20 @@
 			goto fail;
 		}
 	}
-	
+#else /* CONFIG_USE_VGNCA */
+   if (!vgnca_alloc(area, gfp_mask))
+      goto fail;
+#endif /* CONFIG_USE_VGNCA */
 	if (map_vm_area(area, prot, &pages))
 		goto fail;
 	return area->addr;
 
 fail:
+#ifndef CONFIG_USE_VGNCA
 	vfree(area->addr);
+#else /* CONFIG_USE_VGNCA */
+	vgnca_free(area);
+#endif /* CONFIG_USE_VGNCA */
 	return NULL;
 }
 
@@ -541,3 +602,54 @@
 	read_unlock(&vmlist_lock);
 	return buf - buf_start;
 }
+
+#ifdef CONFIG_USE_VGNCA
+
+/**
+ * VGNCA Alloc  -  allocate some virtually contiguous pages at once.
+ *
+ * @area:      the struct vm_area used in this allocation.
+ * @gfp_mask:  flags for the page level allocator (TODO: is this right?)
+ *
+ * Allocate pages (hopefully) more efficiently than calling alloc_page()
+ * for each page. @area->nr_pages must be set to the number of pages that
+ * should be allocated.
+ *
+ * In case of failure returns 1 and sets @area->nr_pages to the number of
+ * pages successfully allocated. In case of success returns 0.
+ */
+static int vgnca_alloc(struct vm_struct *area, int gfp_mask)
+{
+   unsigned int i;
+   unsigned long flags;
+
+   local_irq_save(flags);
+
+	for (i = 0; i < area->nr_pages; i++) {
+		area->pages[i] = vgnca_alloc_page(gfp_mask);
+		if (unlikely(!area->pages[i])) {
+			/* Successfully allocated i pages, free them in __vunmap() */
+			area->nr_pages = i;
+
+         local_irq_restore(flags);
+         return 0;
+		}
+	}
+   local_irq_restore(flags);
+
+   return 1;
+}
+
+
+/**
+ * VGNCA Free  -  frees memory allocated by very_good_non_contig_alloc
+ *
+ * @area:      the struct vm_area used in the allocation being freed.
+ *
+ */
+static void vgnca_free(struct vm_struct *area)
+{
+   vgnca_vfree(area->addr);
+}
+
+#endif /* CONFIG_USE_VGNCA */

--Boundary-00=_5nc1/OEDkzTNzgc
Content-Type: image/x-eps;
  name="large-frees.eps"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="large-frees.eps"

%!PS-Adobe-2.0 EPSF-2.0
%%Title: large-frees.eps
%%Creator: gnuplot 3.7 patchlevel 1
%%CreationDate: Thu Nov 27 16:39:18 2003
%%DocumentFonts: (atend)
%%BoundingBox: 50 50 410 302
%%Orientation: Portrait
%%EndComments
/gnudict 256 dict def
gnudict begin
/Color true def
/Solid false def
/gnulinewidth 5.000 def
/userlinewidth gnulinewidth def
/vshift -46 def
/dl {10 mul} def
/hpt_ 31.5 def
/vpt_ 31.5 def
/hpt hpt_ def
/vpt vpt_ def
/M {moveto} bind def
/L {lineto} bind def
/R {rmoveto} bind def
/V {rlineto} bind def
/vpt2 vpt 2 mul def
/hpt2 hpt 2 mul def
/Lshow { currentpoint stroke M
  0 vshift R show } def
/Rshow { currentpoint stroke M
  dup stringwidth pop neg vshift R show } def
/Cshow { currentpoint stroke M
  dup stringwidth pop -2 div vshift R show } def
/UP { dup vpt_ mul /vpt exch def hpt_ mul /hpt exch def
  /hpt2 hpt 2 mul def /vpt2 vpt 2 mul def } def
/DL { Color {setrgbcolor Solid {pop []} if 0 setdash }
 {pop pop pop Solid {pop []} if 0 setdash} ifelse } def
/BL { stroke userlinewidth 2 mul setlinewidth } def
/AL { stroke userlinewidth 2 div setlinewidth } def
/UL { dup gnulinewidth mul /userlinewidth exch def
      10 mul /udl exch def } def
/PL { stroke userlinewidth setlinewidth } def
/LTb { BL [] 0 0 0 DL } def
/LTa { AL [1 udl mul 2 udl mul] 0 setdash 0 0 0 setrgbcolor } def
/LT0 { PL [] 1 0 0 DL } def
/LT1 { PL [4 dl 2 dl] 0 1 0 DL } def
/LT2 { PL [2 dl 3 dl] 0 0 1 DL } def
/LT3 { PL [1 dl 1.5 dl] 1 0 1 DL } def
/LT4 { PL [5 dl 2 dl 1 dl 2 dl] 0 1 1 DL } def
/LT5 { PL [4 dl 3 dl 1 dl 3 dl] 1 1 0 DL } def
/LT6 { PL [2 dl 2 dl 2 dl 4 dl] 0 0 0 DL } def
/LT7 { PL [2 dl 2 dl 2 dl 2 dl 2 dl 4 dl] 1 0.3 0 DL } def
/LT8 { PL [2 dl 2 dl 2 dl 2 dl 2 dl 2 dl 2 dl 4 dl] 0.5 0.5 0.5 DL } def
/Pnt { stroke [] 0 setdash
   gsave 1 setlinecap M 0 0 V stroke grestore } def
/Dia { stroke [] 0 setdash 2 copy vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath stroke
  Pnt } def
/Pls { stroke [] 0 setdash vpt sub M 0 vpt2 V
  currentpoint stroke M
  hpt neg vpt neg R hpt2 0 V stroke
  } def
/Box { stroke [] 0 setdash 2 copy exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V closepath stroke
  Pnt } def
/Crs { stroke [] 0 setdash exch hpt sub exch vpt add M
  hpt2 vpt2 neg V currentpoint stroke M
  hpt2 neg 0 R hpt2 vpt2 V stroke } def
/TriU { stroke [] 0 setdash 2 copy vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath stroke
  Pnt  } def
/Star { 2 copy Pls Crs } def
/BoxF { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V  hpt2 0 V  0 vpt2 V
  hpt2 neg 0 V  closepath fill } def
/TriUF { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath fill } def
/TriD { stroke [] 0 setdash 2 copy vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath stroke
  Pnt  } def
/TriDF { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath fill} def
/DiaF { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath fill } def
/Pent { stroke [] 0 setdash 2 copy gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath stroke grestore Pnt } def
/PentF { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath fill grestore } def
/Circle { stroke [] 0 setdash 2 copy
  hpt 0 360 arc stroke Pnt } def
/CircleF { stroke [] 0 setdash hpt 0 360 arc fill } def
/C0 { BL [] 0 setdash 2 copy moveto vpt 90 450  arc } bind def
/C1 { BL [] 0 setdash 2 copy        moveto
       2 copy  vpt 0 90 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C2 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 90 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C3 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C4 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 180 270 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C5 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 90 arc
       2 copy moveto
       2 copy  vpt 180 270 arc closepath fill
               vpt 0 360 arc } bind def
/C6 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 90 270 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C7 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 0 270 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C8 { BL [] 0 setdash 2 copy moveto
      2 copy vpt 270 360 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C9 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 270 450 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C10 { BL [] 0 setdash 2 copy 2 copy moveto vpt 270 360 arc closepath fill
       2 copy moveto
       2 copy vpt 90 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C11 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 180 arc closepath fill
       2 copy moveto
       2 copy  vpt 270 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C12 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 180 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C13 { BL [] 0 setdash  2 copy moveto
       2 copy  vpt 0 90 arc closepath fill
       2 copy moveto
       2 copy  vpt 180 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C14 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 90 360 arc closepath fill
               vpt 0 360 arc } bind def
/C15 { BL [] 0 setdash 2 copy vpt 0 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/Rec   { newpath 4 2 roll moveto 1 index 0 rlineto 0 exch rlineto
       neg 0 rlineto closepath } bind def
/Square { dup Rec } bind def
/Bsquare { vpt sub exch vpt sub exch vpt2 Square } bind def
/S0 { BL [] 0 setdash 2 copy moveto 0 vpt rlineto BL Bsquare } bind def
/S1 { BL [] 0 setdash 2 copy vpt Square fill Bsquare } bind def
/S2 { BL [] 0 setdash 2 copy exch vpt sub exch vpt Square fill Bsquare } bind def
/S3 { BL [] 0 setdash 2 copy exch vpt sub exch vpt2 vpt Rec fill Bsquare } bind def
/S4 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt Square fill Bsquare } bind def
/S5 { BL [] 0 setdash 2 copy 2 copy vpt Square fill
       exch vpt sub exch vpt sub vpt Square fill Bsquare } bind def
/S6 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt vpt2 Rec fill Bsquare } bind def
/S7 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt vpt2 Rec fill
       2 copy vpt Square fill
       Bsquare } bind def
/S8 { BL [] 0 setdash 2 copy vpt sub vpt Square fill Bsquare } bind def
/S9 { BL [] 0 setdash 2 copy vpt sub vpt vpt2 Rec fill Bsquare } bind def
/S10 { BL [] 0 setdash 2 copy vpt sub vpt Square fill 2 copy exch vpt sub exch vpt Square fill
       Bsquare } bind def
/S11 { BL [] 0 setdash 2 copy vpt sub vpt Square fill 2 copy exch vpt sub exch vpt2 vpt Rec fill
       Bsquare } bind def
/S12 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill Bsquare } bind def
/S13 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill
       2 copy vpt Square fill Bsquare } bind def
/S14 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill
       2 copy exch vpt sub exch vpt Square fill Bsquare } bind def
/S15 { BL [] 0 setdash 2 copy Bsquare fill Bsquare } bind def
/D0 { gsave translate 45 rotate 0 0 S0 stroke grestore } bind def
/D1 { gsave translate 45 rotate 0 0 S1 stroke grestore } bind def
/D2 { gsave translate 45 rotate 0 0 S2 stroke grestore } bind def
/D3 { gsave translate 45 rotate 0 0 S3 stroke grestore } bind def
/D4 { gsave translate 45 rotate 0 0 S4 stroke grestore } bind def
/D5 { gsave translate 45 rotate 0 0 S5 stroke grestore } bind def
/D6 { gsave translate 45 rotate 0 0 S6 stroke grestore } bind def
/D7 { gsave translate 45 rotate 0 0 S7 stroke grestore } bind def
/D8 { gsave translate 45 rotate 0 0 S8 stroke grestore } bind def
/D9 { gsave translate 45 rotate 0 0 S9 stroke grestore } bind def
/D10 { gsave translate 45 rotate 0 0 S10 stroke grestore } bind def
/D11 { gsave translate 45 rotate 0 0 S11 stroke grestore } bind def
/D12 { gsave translate 45 rotate 0 0 S12 stroke grestore } bind def
/D13 { gsave translate 45 rotate 0 0 S13 stroke grestore } bind def
/D14 { gsave translate 45 rotate 0 0 S14 stroke grestore } bind def
/D15 { gsave translate 45 rotate 0 0 S15 stroke grestore } bind def
/DiaE { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath stroke } def
/BoxE { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V closepath stroke } def
/TriUE { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath stroke } def
/TriDE { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath stroke } def
/PentE { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath stroke grestore } def
/CircE { stroke [] 0 setdash 
  hpt 0 360 arc stroke } def
/Opaque { gsave closepath 1 setgray fill grestore 0 setgray closepath } def
/DiaW { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V Opaque stroke } def
/BoxW { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V Opaque stroke } def
/TriUW { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V Opaque stroke } def
/TriDW { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V Opaque stroke } def
/PentW { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  Opaque stroke grestore } def
/CircW { stroke [] 0 setdash 
  hpt 0 360 arc Opaque stroke } def
/BoxFill { gsave Rec 1 setgray fill grestore } def
end
%%EndProlog
gnudict begin
gsave
50 50 translate
0.050 0.050 scale
0 setgray
newpath
(Helvetica) findfont 140 scalefont setfont
1.000 UL
LTb
1.000 UL
LTa
658 280 M
6304 0 V
1.000 UL
LTb
658 280 M
63 0 V
6241 0 R
-63 0 V
574 280 M
(0) Rshow
1.000 UL
LTa
658 936 M
6304 0 V
1.000 UL
LTb
658 936 M
63 0 V
6241 0 R
-63 0 V
574 936 M
(1e+06) Rshow
1.000 UL
LTa
658 1592 M
6304 0 V
1.000 UL
LTb
658 1592 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(2e+06) Rshow
1.000 UL
LTa
658 2248 M
6304 0 V
1.000 UL
LTb
658 2248 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(3e+06) Rshow
1.000 UL
LTa
658 2904 M
6304 0 V
1.000 UL
LTb
658 2904 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(4e+06) Rshow
1.000 UL
LTa
658 3560 M
6304 0 V
1.000 UL
LTb
658 3560 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(5e+06) Rshow
1.000 UL
LTa
658 4216 M
6304 0 V
1.000 UL
LTb
658 4216 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(6e+06) Rshow
1.000 UL
LTa
658 4872 M
6304 0 V
1.000 UL
LTb
658 4872 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(7e+06) Rshow
1.000 UL
LTa
658 280 M
0 4592 V
1.000 UL
LTb
658 280 M
0 63 V
0 4529 R
0 -63 V
658 140 M
(0) Cshow
1.000 UL
LTa
1559 280 M
0 4592 V
1.000 UL
LTb
1559 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(1e+07) Cshow
1.000 UL
LTa
2459 280 M
0 4592 V
1.000 UL
LTb
2459 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(2e+07) Cshow
1.000 UL
LTa
3360 280 M
0 4592 V
1.000 UL
LTb
3360 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(3e+07) Cshow
1.000 UL
LTa
4260 280 M
0 4592 V
1.000 UL
LTb
4260 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(4e+07) Cshow
1.000 UL
LTa
5161 280 M
0 4592 V
1.000 UL
LTb
5161 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(5e+07) Cshow
1.000 UL
LTa
6061 280 M
0 4249 V
0 280 R
0 63 V
1.000 UL
LTb
6061 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(6e+07) Cshow
1.000 UL
LTa
6962 280 M
0 4592 V
1.000 UL
LTb
6962 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(7e+07) Cshow
1.000 UL
LTb
658 280 M
6304 0 V
0 4592 V
-6304 0 V
658 280 L
1.000 UP
1.000 UL
LT0
6311 4739 M
(Normal) Rshow
752 325 Pls
847 373 Pls
5757 3588 Pls
2830 1478 Pls
6135 3900 Pls
6513 4223 Pls
3585 1904 Pls
2452 1267 Pls
5096 3047 Pls
3963 2201 Pls
4341 2469 Pls
1413 684 Pls
4719 2749 Pls
1791 896 Pls
1036 475 Pls
2169 1109 Pls
2358 1214 Pls
5474 3356 Pls
2547 1319 Pls
5852 3664 Pls
2924 1531 Pls
6229 3979 Pls
3302 1744 Pls
6607 4306 Pls
3680 1957 Pls
4058 2267 Pls
1130 527 Pls
4435 2537 Pls
1508 737 Pls
4813 2825 Pls
1886 950 Pls
3397 1796 Pls
5191 3124 Pls
2263 1161 Pls
5568 3433 Pls
2641 1372 Pls
5946 3743 Pls
3019 1584 Pls
6324 4061 Pls
6702 4386 Pls
3774 2079 Pls
4152 2333 Pls
4530 2604 Pls
1602 790 Pls
4907 2897 Pls
1980 1003 Pls
1225 579 Pls
5285 3199 Pls
5663 3511 Pls
2735 1425 Pls
6041 3821 Pls
3113 1637 Pls
6418 4141 Pls
3491 1850 Pls
2074 1056 Pls
3869 2138 Pls
941 424 Pls
4246 2402 Pls
1319 631 Pls
4624 2677 Pls
1697 843 Pls
5002 2971 Pls
3208 1691 Pls
5380 3278 Pls
6594 4739 Pls
1.000 UP
1.000 UL
LT1
6311 4599 M
(VGNCA) Rshow
752 324 Crs
847 372 Crs
5757 3606 Crs
2830 1476 Crs
6135 3927 Crs
6513 4253 Crs
3585 1925 Crs
2452 1264 Crs
5096 3051 Crs
3963 2188 Crs
4341 2463 Crs
1413 681 Crs
4719 2752 Crs
1791 893 Crs
1036 473 Crs
2169 1106 Crs
2358 1211 Crs
5474 3367 Crs
2547 1317 Crs
5852 3686 Crs
2924 1530 Crs
6229 4008 Crs
3302 1744 Crs
6607 4335 Crs
3680 1985 Crs
4058 2258 Crs
1130 525 Crs
4435 2534 Crs
1508 734 Crs
4813 2824 Crs
1886 946 Crs
3397 1804 Crs
5191 3128 Crs
2263 1158 Crs
5568 3448 Crs
2641 1371 Crs
5946 3766 Crs
3019 1583 Crs
6324 4091 Crs
6702 4416 Crs
3774 2067 Crs
4152 2322 Crs
4530 2606 Crs
1602 787 Crs
4907 2898 Crs
1980 1000 Crs
1225 577 Crs
5285 3206 Crs
5663 3526 Crs
2735 1423 Crs
6041 3846 Crs
3113 1637 Crs
6418 4172 Crs
3491 1864 Crs
2074 1053 Crs
3869 2124 Crs
941 422 Crs
4246 2392 Crs
1319 629 Crs
4624 2681 Crs
1697 840 Crs
5002 2973 Crs
3208 1690 Crs
5380 3286 Crs
6594 4599 Crs
stroke
grestore
end
showpage
%%Trailer
%%DocumentFonts: Helvetica

--Boundary-00=_5nc1/OEDkzTNzgc
Content-Type: image/x-eps;
  name="large-allocations.eps"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="large-allocations.eps"

%!PS-Adobe-2.0 EPSF-2.0
%%Title: large-allocations.eps
%%Creator: gnuplot 3.7 patchlevel 1
%%CreationDate: Thu Nov 27 16:39:18 2003
%%DocumentFonts: (atend)
%%BoundingBox: 50 50 410 302
%%Orientation: Portrait
%%EndComments
/gnudict 256 dict def
gnudict begin
/Color true def
/Solid false def
/gnulinewidth 5.000 def
/userlinewidth gnulinewidth def
/vshift -46 def
/dl {10 mul} def
/hpt_ 31.5 def
/vpt_ 31.5 def
/hpt hpt_ def
/vpt vpt_ def
/M {moveto} bind def
/L {lineto} bind def
/R {rmoveto} bind def
/V {rlineto} bind def
/vpt2 vpt 2 mul def
/hpt2 hpt 2 mul def
/Lshow { currentpoint stroke M
  0 vshift R show } def
/Rshow { currentpoint stroke M
  dup stringwidth pop neg vshift R show } def
/Cshow { currentpoint stroke M
  dup stringwidth pop -2 div vshift R show } def
/UP { dup vpt_ mul /vpt exch def hpt_ mul /hpt exch def
  /hpt2 hpt 2 mul def /vpt2 vpt 2 mul def } def
/DL { Color {setrgbcolor Solid {pop []} if 0 setdash }
 {pop pop pop Solid {pop []} if 0 setdash} ifelse } def
/BL { stroke userlinewidth 2 mul setlinewidth } def
/AL { stroke userlinewidth 2 div setlinewidth } def
/UL { dup gnulinewidth mul /userlinewidth exch def
      10 mul /udl exch def } def
/PL { stroke userlinewidth setlinewidth } def
/LTb { BL [] 0 0 0 DL } def
/LTa { AL [1 udl mul 2 udl mul] 0 setdash 0 0 0 setrgbcolor } def
/LT0 { PL [] 1 0 0 DL } def
/LT1 { PL [4 dl 2 dl] 0 1 0 DL } def
/LT2 { PL [2 dl 3 dl] 0 0 1 DL } def
/LT3 { PL [1 dl 1.5 dl] 1 0 1 DL } def
/LT4 { PL [5 dl 2 dl 1 dl 2 dl] 0 1 1 DL } def
/LT5 { PL [4 dl 3 dl 1 dl 3 dl] 1 1 0 DL } def
/LT6 { PL [2 dl 2 dl 2 dl 4 dl] 0 0 0 DL } def
/LT7 { PL [2 dl 2 dl 2 dl 2 dl 2 dl 4 dl] 1 0.3 0 DL } def
/LT8 { PL [2 dl 2 dl 2 dl 2 dl 2 dl 2 dl 2 dl 4 dl] 0.5 0.5 0.5 DL } def
/Pnt { stroke [] 0 setdash
   gsave 1 setlinecap M 0 0 V stroke grestore } def
/Dia { stroke [] 0 setdash 2 copy vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath stroke
  Pnt } def
/Pls { stroke [] 0 setdash vpt sub M 0 vpt2 V
  currentpoint stroke M
  hpt neg vpt neg R hpt2 0 V stroke
  } def
/Box { stroke [] 0 setdash 2 copy exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V closepath stroke
  Pnt } def
/Crs { stroke [] 0 setdash exch hpt sub exch vpt add M
  hpt2 vpt2 neg V currentpoint stroke M
  hpt2 neg 0 R hpt2 vpt2 V stroke } def
/TriU { stroke [] 0 setdash 2 copy vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath stroke
  Pnt  } def
/Star { 2 copy Pls Crs } def
/BoxF { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V  hpt2 0 V  0 vpt2 V
  hpt2 neg 0 V  closepath fill } def
/TriUF { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath fill } def
/TriD { stroke [] 0 setdash 2 copy vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath stroke
  Pnt  } def
/TriDF { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath fill} def
/DiaF { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath fill } def
/Pent { stroke [] 0 setdash 2 copy gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath stroke grestore Pnt } def
/PentF { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath fill grestore } def
/Circle { stroke [] 0 setdash 2 copy
  hpt 0 360 arc stroke Pnt } def
/CircleF { stroke [] 0 setdash hpt 0 360 arc fill } def
/C0 { BL [] 0 setdash 2 copy moveto vpt 90 450  arc } bind def
/C1 { BL [] 0 setdash 2 copy        moveto
       2 copy  vpt 0 90 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C2 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 90 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C3 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C4 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 180 270 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C5 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 90 arc
       2 copy moveto
       2 copy  vpt 180 270 arc closepath fill
               vpt 0 360 arc } bind def
/C6 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 90 270 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C7 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 0 270 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C8 { BL [] 0 setdash 2 copy moveto
      2 copy vpt 270 360 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C9 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 270 450 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C10 { BL [] 0 setdash 2 copy 2 copy moveto vpt 270 360 arc closepath fill
       2 copy moveto
       2 copy vpt 90 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C11 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 180 arc closepath fill
       2 copy moveto
       2 copy  vpt 270 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C12 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 180 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C13 { BL [] 0 setdash  2 copy moveto
       2 copy  vpt 0 90 arc closepath fill
       2 copy moveto
       2 copy  vpt 180 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C14 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 90 360 arc closepath fill
               vpt 0 360 arc } bind def
/C15 { BL [] 0 setdash 2 copy vpt 0 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/Rec   { newpath 4 2 roll moveto 1 index 0 rlineto 0 exch rlineto
       neg 0 rlineto closepath } bind def
/Square { dup Rec } bind def
/Bsquare { vpt sub exch vpt sub exch vpt2 Square } bind def
/S0 { BL [] 0 setdash 2 copy moveto 0 vpt rlineto BL Bsquare } bind def
/S1 { BL [] 0 setdash 2 copy vpt Square fill Bsquare } bind def
/S2 { BL [] 0 setdash 2 copy exch vpt sub exch vpt Square fill Bsquare } bind def
/S3 { BL [] 0 setdash 2 copy exch vpt sub exch vpt2 vpt Rec fill Bsquare } bind def
/S4 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt Square fill Bsquare } bind def
/S5 { BL [] 0 setdash 2 copy 2 copy vpt Square fill
       exch vpt sub exch vpt sub vpt Square fill Bsquare } bind def
/S6 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt vpt2 Rec fill Bsquare } bind def
/S7 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt vpt2 Rec fill
       2 copy vpt Square fill
       Bsquare } bind def
/S8 { BL [] 0 setdash 2 copy vpt sub vpt Square fill Bsquare } bind def
/S9 { BL [] 0 setdash 2 copy vpt sub vpt vpt2 Rec fill Bsquare } bind def
/S10 { BL [] 0 setdash 2 copy vpt sub vpt Square fill 2 copy exch vpt sub exch vpt Square fill
       Bsquare } bind def
/S11 { BL [] 0 setdash 2 copy vpt sub vpt Square fill 2 copy exch vpt sub exch vpt2 vpt Rec fill
       Bsquare } bind def
/S12 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill Bsquare } bind def
/S13 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill
       2 copy vpt Square fill Bsquare } bind def
/S14 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill
       2 copy exch vpt sub exch vpt Square fill Bsquare } bind def
/S15 { BL [] 0 setdash 2 copy Bsquare fill Bsquare } bind def
/D0 { gsave translate 45 rotate 0 0 S0 stroke grestore } bind def
/D1 { gsave translate 45 rotate 0 0 S1 stroke grestore } bind def
/D2 { gsave translate 45 rotate 0 0 S2 stroke grestore } bind def
/D3 { gsave translate 45 rotate 0 0 S3 stroke grestore } bind def
/D4 { gsave translate 45 rotate 0 0 S4 stroke grestore } bind def
/D5 { gsave translate 45 rotate 0 0 S5 stroke grestore } bind def
/D6 { gsave translate 45 rotate 0 0 S6 stroke grestore } bind def
/D7 { gsave translate 45 rotate 0 0 S7 stroke grestore } bind def
/D8 { gsave translate 45 rotate 0 0 S8 stroke grestore } bind def
/D9 { gsave translate 45 rotate 0 0 S9 stroke grestore } bind def
/D10 { gsave translate 45 rotate 0 0 S10 stroke grestore } bind def
/D11 { gsave translate 45 rotate 0 0 S11 stroke grestore } bind def
/D12 { gsave translate 45 rotate 0 0 S12 stroke grestore } bind def
/D13 { gsave translate 45 rotate 0 0 S13 stroke grestore } bind def
/D14 { gsave translate 45 rotate 0 0 S14 stroke grestore } bind def
/D15 { gsave translate 45 rotate 0 0 S15 stroke grestore } bind def
/DiaE { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath stroke } def
/BoxE { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V closepath stroke } def
/TriUE { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath stroke } def
/TriDE { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath stroke } def
/PentE { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath stroke grestore } def
/CircE { stroke [] 0 setdash 
  hpt 0 360 arc stroke } def
/Opaque { gsave closepath 1 setgray fill grestore 0 setgray closepath } def
/DiaW { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V Opaque stroke } def
/BoxW { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V Opaque stroke } def
/TriUW { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V Opaque stroke } def
/TriDW { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V Opaque stroke } def
/PentW { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  Opaque stroke grestore } def
/CircW { stroke [] 0 setdash 
  hpt 0 360 arc Opaque stroke } def
/BoxFill { gsave Rec 1 setgray fill grestore } def
end
%%EndProlog
gnudict begin
gsave
50 50 translate
0.050 0.050 scale
0 setgray
newpath
(Helvetica) findfont 140 scalefont setfont
1.000 UL
LTb
1.000 UL
LTa
658 280 M
6304 0 V
1.000 UL
LTb
658 280 M
63 0 V
6241 0 R
-63 0 V
574 280 M
(0) Rshow
1.000 UL
LTa
658 936 M
6304 0 V
1.000 UL
LTb
658 936 M
63 0 V
6241 0 R
-63 0 V
574 936 M
(1e+06) Rshow
1.000 UL
LTa
658 1592 M
6304 0 V
1.000 UL
LTb
658 1592 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(2e+06) Rshow
1.000 UL
LTa
658 2248 M
6304 0 V
1.000 UL
LTb
658 2248 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(3e+06) Rshow
1.000 UL
LTa
658 2904 M
6304 0 V
1.000 UL
LTb
658 2904 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(4e+06) Rshow
1.000 UL
LTa
658 3560 M
6304 0 V
1.000 UL
LTb
658 3560 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(5e+06) Rshow
1.000 UL
LTa
658 4216 M
6304 0 V
1.000 UL
LTb
658 4216 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(6e+06) Rshow
1.000 UL
LTa
658 4872 M
6304 0 V
1.000 UL
LTb
658 4872 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(7e+06) Rshow
1.000 UL
LTa
658 280 M
0 4592 V
1.000 UL
LTb
658 280 M
0 63 V
0 4529 R
0 -63 V
658 140 M
(0) Cshow
1.000 UL
LTa
1559 280 M
0 4592 V
1.000 UL
LTb
1559 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(1e+07) Cshow
1.000 UL
LTa
2459 280 M
0 4592 V
1.000 UL
LTb
2459 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(2e+07) Cshow
1.000 UL
LTa
3360 280 M
0 4592 V
1.000 UL
LTb
3360 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(3e+07) Cshow
1.000 UL
LTa
4260 280 M
0 4592 V
1.000 UL
LTb
4260 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(4e+07) Cshow
1.000 UL
LTa
5161 280 M
0 4592 V
1.000 UL
LTb
5161 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(5e+07) Cshow
1.000 UL
LTa
6061 280 M
0 4249 V
0 280 R
0 63 V
1.000 UL
LTb
6061 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(6e+07) Cshow
1.000 UL
LTa
6962 280 M
0 4592 V
1.000 UL
LTb
6962 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(7e+07) Cshow
1.000 UL
LTb
658 280 M
6304 0 V
0 4592 V
-6304 0 V
658 280 L
1.000 UP
1.000 UL
LT0
6311 4739 M
(Normal) Rshow
752 348 Pls
847 406 Pls
5757 3998 Pls
2830 1742 Pls
6135 4332 Pls
6513 4674 Pls
3585 2255 Pls
2452 1487 Pls
5096 3436 Pls
3963 2548 Pls
4341 2835 Pls
1413 784 Pls
4719 3129 Pls
1791 1039 Pls
1036 530 Pls
2169 1296 Pls
2358 1422 Pls
5474 3752 Pls
2547 1551 Pls
5852 4081 Pls
2924 1806 Pls
6229 4417 Pls
3302 2062 Pls
6607 4760 Pls
3680 2318 Pls
4058 2619 Pls
1130 596 Pls
4435 2907 Pls
1508 851 Pls
4813 3204 Pls
1886 1104 Pls
3397 2126 Pls
5191 3515 Pls
2263 1364 Pls
5568 3835 Pls
2641 1614 Pls
5946 4164 Pls
3019 1870 Pls
6324 4501 Pls
6702 4846 Pls
3774 2671 Pls
4152 2692 Pls
4530 2979 Pls
1602 912 Pls
4907 3281 Pls
1980 1167 Pls
1225 656 Pls
5285 3594 Pls
5663 3915 Pls
2735 1678 Pls
6041 4248 Pls
3113 1934 Pls
6418 4589 Pls
3491 2190 Pls
2074 1231 Pls
3869 2481 Pls
941 468 Pls
4246 2763 Pls
1319 720 Pls
4624 3053 Pls
1697 976 Pls
5002 3359 Pls
3208 1998 Pls
5380 3673 Pls
6594 4739 Pls
1.000 UP
1.000 UL
LT1
6311 4599 M
(VGNCA) Rshow
752 337 Crs
847 383 Crs
5757 3381 Crs
2830 1479 Crs
6135 3677 Crs
6513 3978 Crs
3585 1908 Crs
2452 1269 Crs
5096 2897 Crs
3963 2139 Crs
4341 2383 Crs
1413 693 Crs
4719 2639 Crs
1791 902 Crs
1036 484 Crs
2169 1111 Crs
2358 1217 Crs
5474 3169 Crs
2547 1322 Crs
5852 3455 Crs
2924 1532 Crs
6229 3750 Crs
3302 1742 Crs
6607 4054 Crs
3680 1963 Crs
4058 2199 Crs
1130 539 Crs
4435 2447 Crs
1508 748 Crs
4813 2702 Crs
1886 954 Crs
3397 1798 Crs
5191 2964 Crs
2263 1170 Crs
5568 3240 Crs
2641 1374 Crs
5946 3528 Crs
3019 1584 Crs
6324 3828 Crs
6702 4132 Crs
3774 2304 Crs
4152 2259 Crs
4530 2511 Crs
1602 797 Crs
4907 2767 Crs
1980 1006 Crs
1225 589 Crs
5285 3031 Crs
5663 3311 Crs
2735 1426 Crs
6041 3603 Crs
3113 1637 Crs
6418 3901 Crs
3491 1853 Crs
2074 1059 Crs
3869 2082 Crs
941 434 Crs
4246 2319 Crs
1319 641 Crs
4624 2574 Crs
1697 849 Crs
5002 2831 Crs
3208 1689 Crs
5380 3100 Crs
6594 4599 Crs
stroke
grestore
end
showpage
%%Trailer
%%DocumentFonts: Helvetica

--Boundary-00=_5nc1/OEDkzTNzgc
Content-Type: image/x-eps;
  name="small-allocations.eps"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="small-allocations.eps"

%!PS-Adobe-2.0 EPSF-2.0
%%Title: small-allocations.eps
%%Creator: gnuplot 3.7 patchlevel 1
%%CreationDate: Thu Nov 27 16:39:18 2003
%%DocumentFonts: (atend)
%%BoundingBox: 50 50 410 302
%%Orientation: Portrait
%%EndComments
/gnudict 256 dict def
gnudict begin
/Color true def
/Solid false def
/gnulinewidth 5.000 def
/userlinewidth gnulinewidth def
/vshift -46 def
/dl {10 mul} def
/hpt_ 31.5 def
/vpt_ 31.5 def
/hpt hpt_ def
/vpt vpt_ def
/M {moveto} bind def
/L {lineto} bind def
/R {rmoveto} bind def
/V {rlineto} bind def
/vpt2 vpt 2 mul def
/hpt2 hpt 2 mul def
/Lshow { currentpoint stroke M
  0 vshift R show } def
/Rshow { currentpoint stroke M
  dup stringwidth pop neg vshift R show } def
/Cshow { currentpoint stroke M
  dup stringwidth pop -2 div vshift R show } def
/UP { dup vpt_ mul /vpt exch def hpt_ mul /hpt exch def
  /hpt2 hpt 2 mul def /vpt2 vpt 2 mul def } def
/DL { Color {setrgbcolor Solid {pop []} if 0 setdash }
 {pop pop pop Solid {pop []} if 0 setdash} ifelse } def
/BL { stroke userlinewidth 2 mul setlinewidth } def
/AL { stroke userlinewidth 2 div setlinewidth } def
/UL { dup gnulinewidth mul /userlinewidth exch def
      10 mul /udl exch def } def
/PL { stroke userlinewidth setlinewidth } def
/LTb { BL [] 0 0 0 DL } def
/LTa { AL [1 udl mul 2 udl mul] 0 setdash 0 0 0 setrgbcolor } def
/LT0 { PL [] 1 0 0 DL } def
/LT1 { PL [4 dl 2 dl] 0 1 0 DL } def
/LT2 { PL [2 dl 3 dl] 0 0 1 DL } def
/LT3 { PL [1 dl 1.5 dl] 1 0 1 DL } def
/LT4 { PL [5 dl 2 dl 1 dl 2 dl] 0 1 1 DL } def
/LT5 { PL [4 dl 3 dl 1 dl 3 dl] 1 1 0 DL } def
/LT6 { PL [2 dl 2 dl 2 dl 4 dl] 0 0 0 DL } def
/LT7 { PL [2 dl 2 dl 2 dl 2 dl 2 dl 4 dl] 1 0.3 0 DL } def
/LT8 { PL [2 dl 2 dl 2 dl 2 dl 2 dl 2 dl 2 dl 4 dl] 0.5 0.5 0.5 DL } def
/Pnt { stroke [] 0 setdash
   gsave 1 setlinecap M 0 0 V stroke grestore } def
/Dia { stroke [] 0 setdash 2 copy vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath stroke
  Pnt } def
/Pls { stroke [] 0 setdash vpt sub M 0 vpt2 V
  currentpoint stroke M
  hpt neg vpt neg R hpt2 0 V stroke
  } def
/Box { stroke [] 0 setdash 2 copy exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V closepath stroke
  Pnt } def
/Crs { stroke [] 0 setdash exch hpt sub exch vpt add M
  hpt2 vpt2 neg V currentpoint stroke M
  hpt2 neg 0 R hpt2 vpt2 V stroke } def
/TriU { stroke [] 0 setdash 2 copy vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath stroke
  Pnt  } def
/Star { 2 copy Pls Crs } def
/BoxF { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V  hpt2 0 V  0 vpt2 V
  hpt2 neg 0 V  closepath fill } def
/TriUF { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath fill } def
/TriD { stroke [] 0 setdash 2 copy vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath stroke
  Pnt  } def
/TriDF { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath fill} def
/DiaF { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath fill } def
/Pent { stroke [] 0 setdash 2 copy gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath stroke grestore Pnt } def
/PentF { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath fill grestore } def
/Circle { stroke [] 0 setdash 2 copy
  hpt 0 360 arc stroke Pnt } def
/CircleF { stroke [] 0 setdash hpt 0 360 arc fill } def
/C0 { BL [] 0 setdash 2 copy moveto vpt 90 450  arc } bind def
/C1 { BL [] 0 setdash 2 copy        moveto
       2 copy  vpt 0 90 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C2 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 90 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C3 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C4 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 180 270 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C5 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 90 arc
       2 copy moveto
       2 copy  vpt 180 270 arc closepath fill
               vpt 0 360 arc } bind def
/C6 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 90 270 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C7 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 0 270 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C8 { BL [] 0 setdash 2 copy moveto
      2 copy vpt 270 360 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C9 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 270 450 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C10 { BL [] 0 setdash 2 copy 2 copy moveto vpt 270 360 arc closepath fill
       2 copy moveto
       2 copy vpt 90 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C11 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 180 arc closepath fill
       2 copy moveto
       2 copy  vpt 270 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C12 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 180 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C13 { BL [] 0 setdash  2 copy moveto
       2 copy  vpt 0 90 arc closepath fill
       2 copy moveto
       2 copy  vpt 180 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C14 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 90 360 arc closepath fill
               vpt 0 360 arc } bind def
/C15 { BL [] 0 setdash 2 copy vpt 0 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/Rec   { newpath 4 2 roll moveto 1 index 0 rlineto 0 exch rlineto
       neg 0 rlineto closepath } bind def
/Square { dup Rec } bind def
/Bsquare { vpt sub exch vpt sub exch vpt2 Square } bind def
/S0 { BL [] 0 setdash 2 copy moveto 0 vpt rlineto BL Bsquare } bind def
/S1 { BL [] 0 setdash 2 copy vpt Square fill Bsquare } bind def
/S2 { BL [] 0 setdash 2 copy exch vpt sub exch vpt Square fill Bsquare } bind def
/S3 { BL [] 0 setdash 2 copy exch vpt sub exch vpt2 vpt Rec fill Bsquare } bind def
/S4 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt Square fill Bsquare } bind def
/S5 { BL [] 0 setdash 2 copy 2 copy vpt Square fill
       exch vpt sub exch vpt sub vpt Square fill Bsquare } bind def
/S6 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt vpt2 Rec fill Bsquare } bind def
/S7 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt vpt2 Rec fill
       2 copy vpt Square fill
       Bsquare } bind def
/S8 { BL [] 0 setdash 2 copy vpt sub vpt Square fill Bsquare } bind def
/S9 { BL [] 0 setdash 2 copy vpt sub vpt vpt2 Rec fill Bsquare } bind def
/S10 { BL [] 0 setdash 2 copy vpt sub vpt Square fill 2 copy exch vpt sub exch vpt Square fill
       Bsquare } bind def
/S11 { BL [] 0 setdash 2 copy vpt sub vpt Square fill 2 copy exch vpt sub exch vpt2 vpt Rec fill
       Bsquare } bind def
/S12 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill Bsquare } bind def
/S13 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill
       2 copy vpt Square fill Bsquare } bind def
/S14 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill
       2 copy exch vpt sub exch vpt Square fill Bsquare } bind def
/S15 { BL [] 0 setdash 2 copy Bsquare fill Bsquare } bind def
/D0 { gsave translate 45 rotate 0 0 S0 stroke grestore } bind def
/D1 { gsave translate 45 rotate 0 0 S1 stroke grestore } bind def
/D2 { gsave translate 45 rotate 0 0 S2 stroke grestore } bind def
/D3 { gsave translate 45 rotate 0 0 S3 stroke grestore } bind def
/D4 { gsave translate 45 rotate 0 0 S4 stroke grestore } bind def
/D5 { gsave translate 45 rotate 0 0 S5 stroke grestore } bind def
/D6 { gsave translate 45 rotate 0 0 S6 stroke grestore } bind def
/D7 { gsave translate 45 rotate 0 0 S7 stroke grestore } bind def
/D8 { gsave translate 45 rotate 0 0 S8 stroke grestore } bind def
/D9 { gsave translate 45 rotate 0 0 S9 stroke grestore } bind def
/D10 { gsave translate 45 rotate 0 0 S10 stroke grestore } bind def
/D11 { gsave translate 45 rotate 0 0 S11 stroke grestore } bind def
/D12 { gsave translate 45 rotate 0 0 S12 stroke grestore } bind def
/D13 { gsave translate 45 rotate 0 0 S13 stroke grestore } bind def
/D14 { gsave translate 45 rotate 0 0 S14 stroke grestore } bind def
/D15 { gsave translate 45 rotate 0 0 S15 stroke grestore } bind def
/DiaE { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath stroke } def
/BoxE { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V closepath stroke } def
/TriUE { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath stroke } def
/TriDE { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath stroke } def
/PentE { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath stroke grestore } def
/CircE { stroke [] 0 setdash 
  hpt 0 360 arc stroke } def
/Opaque { gsave closepath 1 setgray fill grestore 0 setgray closepath } def
/DiaW { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V Opaque stroke } def
/BoxW { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V Opaque stroke } def
/TriUW { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V Opaque stroke } def
/TriDW { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V Opaque stroke } def
/PentW { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  Opaque stroke grestore } def
/CircW { stroke [] 0 setdash 
  hpt 0 360 arc Opaque stroke } def
/BoxFill { gsave Rec 1 setgray fill grestore } def
end
%%EndProlog
gnudict begin
gsave
50 50 translate
0.050 0.050 scale
0 setgray
newpath
(Helvetica) findfont 140 scalefont setfont
1.000 UL
LTb
1.000 UL
LTa
658 280 M
6304 0 V
1.000 UL
LTb
658 280 M
63 0 V
6241 0 R
-63 0 V
574 280 M
(0) Rshow
1.000 UL
LTa
658 1045 M
6304 0 V
1.000 UL
LTb
658 1045 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(2000) Rshow
1.000 UL
LTa
658 1811 M
6304 0 V
1.000 UL
LTb
658 1811 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(4000) Rshow
1.000 UL
LTa
658 2576 M
6304 0 V
1.000 UL
LTb
658 2576 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(6000) Rshow
1.000 UL
LTa
658 3341 M
6304 0 V
1.000 UL
LTb
658 3341 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(8000) Rshow
1.000 UL
LTa
658 4107 M
6304 0 V
1.000 UL
LTb
658 4107 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(10000) Rshow
1.000 UL
LTa
658 4872 M
6304 0 V
1.000 UL
LTb
658 4872 M
63 0 V
6241 0 R
-63 0 V
-6325 0 R
(12000) Rshow
1.000 UL
LTa
658 280 M
0 4592 V
1.000 UL
LTb
658 280 M
0 63 V
0 4529 R
0 -63 V
658 140 M
(0) Cshow
1.000 UL
LTa
1559 280 M
0 4592 V
1.000 UL
LTb
1559 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(20000) Cshow
1.000 UL
LTa
2459 280 M
0 4592 V
1.000 UL
LTb
2459 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(40000) Cshow
1.000 UL
LTa
3360 280 M
0 4592 V
1.000 UL
LTb
3360 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(60000) Cshow
1.000 UL
LTa
4260 280 M
0 4592 V
1.000 UL
LTb
4260 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(80000) Cshow
1.000 UL
LTa
5161 280 M
0 4592 V
1.000 UL
LTb
5161 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(100000) Cshow
1.000 UL
LTa
6061 280 M
0 4249 V
0 280 R
0 63 V
1.000 UL
LTb
6061 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(120000) Cshow
1.000 UL
LTa
6962 280 M
0 4592 V
1.000 UL
LTb
6962 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(140000) Cshow
1.000 UL
LTb
658 280 M
6304 0 V
0 4592 V
-6304 0 V
658 280 L
1.000 UP
1.000 UL
LT0
6311 4739 M
(Normal) Rshow
704 599 Pls
750 578 Pls
796 572 Pls
5269 2926 Pls
2410 1396 Pls
1027 656 Pls
4024 2279 Pls
5638 3173 Pls
4393 2445 Pls
1534 920 Pls
6007 3415 Pls
3148 1804 Pls
4762 2616 Pls
1903 1098 Pls
6376 3793 Pls
3517 1977 Pls
5131 4648 Pls
2272 1280 Pls
3886 2108 Pls
3655 3435 Pls
5499 3264 Pls
2641 1477 Pls
4255 2250 Pls
1396 829 Pls
5868 3443 Pls
3010 1655 Pls
4623 2457 Pls
1765 1010 Pls
6237 3749 Pls
3378 1857 Pls
4992 2766 Pls
2133 1183 Pls
2456 1364 Pls
3747 2028 Pls
889 668 Pls
5361 2971 Pls
2226 1307 Pls
2502 1364 Pls
4116 2163 Pls
1257 848 Pls
5730 3315 Pls
2871 1568 Pls
4485 2366 Pls
1626 1066 Pls
6099 3595 Pls
3240 1774 Pls
4854 2618 Pls
1995 1327 Pls
6468 3804 Pls
3609 1948 Pls
5223 2912 Pls
2364 1464 Pls
1165 749 Pls
3978 2103 Pls
1119 749 Pls
5592 3144 Pls
2733 1656 Pls
4347 2249 Pls
1488 932 Pls
5961 3475 Pls
3102 1874 Pls
4716 2459 Pls
1857 1166 Pls
6329 3690 Pls
3471 2050 Pls
5084 2759 Pls
5407 3061 Pls
2318 1275 Pls
5453 2966 Pls
2595 1450 Pls
4208 2361 Pls
5822 3379 Pls
2963 1657 Pls
4577 2639 Pls
1719 1011 Pls
6191 3617 Pls
3332 1800 Pls
4946 2754 Pls
2087 1242 Pls
981 657 Pls
3701 2020 Pls
842 573 Pls
5315 3027 Pls
3840 2179 Pls
4070 2197 Pls
1211 744 Pls
5684 3337 Pls
2825 1537 Pls
4439 2398 Pls
1580 949 Pls
6053 3654 Pls
3194 1744 Pls
4808 2655 Pls
1949 1098 Pls
6422 3936 Pls
3563 1978 Pls
6560 3822 Pls
5177 2908 Pls
2779 1570 Pls
1073 756 Pls
5546 3208 Pls
2687 1448 Pls
4301 2314 Pls
1442 967 Pls
5914 3447 Pls
3056 1655 Pls
4670 2483 Pls
1811 1223 Pls
6283 3746 Pls
3425 1799 Pls
5038 2825 Pls
2180 1747 Pls
3932 2076 Pls
3793 1990 Pls
935 662 Pls
1350 829 Pls
2548 1580 Pls
4162 2195 Pls
1304 842 Pls
5776 3344 Pls
2917 1761 Pls
4531 2369 Pls
1672 1012 Pls
6145 3562 Pls
3286 1911 Pls
4900 2560 Pls
2041 1216 Pls
6514 3842 Pls
6594 4739 Pls
1.000 UP
1.000 UL
LT1
6311 4599 M
(VGNCA) Rshow
704 631 Crs
750 583 Crs
796 571 Crs
5269 2356 Crs
2410 1170 Crs
1027 660 Crs
4024 1875 Crs
5638 2589 Crs
4393 2020 Crs
1534 831 Crs
6007 2809 Crs
3148 1434 Crs
4762 2132 Crs
1903 968 Crs
6376 2966 Crs
3517 1562 Crs
5131 3804 Crs
2272 1115 Crs
3886 1766 Crs
3655 2900 Crs
5499 2639 Crs
2641 1235 Crs
4255 1836 Crs
1396 765 Crs
5868 2895 Crs
3010 1367 Crs
4623 1972 Crs
1765 937 Crs
6237 2981 Crs
3378 1498 Crs
4992 2259 Crs
2133 1064 Crs
2456 1171 Crs
3747 1680 Crs
889 677 Crs
5361 2422 Crs
2226 1136 Crs
2502 1198 Crs
4116 1829 Crs
1257 815 Crs
5730 2630 Crs
2871 1330 Crs
4485 1962 Crs
1626 916 Crs
6099 2855 Crs
3240 1433 Crs
4854 2116 Crs
1995 1136 Crs
6468 3065 Crs
3609 1591 Crs
5223 2317 Crs
2364 1321 Crs
1165 735 Crs
3978 1733 Crs
1119 703 Crs
5592 2560 Crs
2733 1425 Crs
4347 1866 Crs
1488 845 Crs
5961 2756 Crs
3102 1529 Crs
4716 2031 Crs
1857 1007 Crs
6329 3031 Crs
3471 1627 Crs
5084 2255 Crs
5407 2542 Crs
2318 1107 Crs
5453 2538 Crs
2595 1236 Crs
4208 1925 Crs
5822 2656 Crs
2963 1397 Crs
4577 2072 Crs
1719 933 Crs
6191 2881 Crs
3332 1499 Crs
4946 2244 Crs
2087 1065 Crs
981 633 Crs
3701 1672 Crs
842 570 Crs
5315 2524 Crs
3840 1809 Crs
4070 1801 Crs
1211 698 Crs
5684 2642 Crs
2825 1301 Crs
4439 1964 Crs
1580 832 Crs
6053 2900 Crs
3194 1434 Crs
4808 2181 Crs
1949 1000 Crs
6422 3129 Crs
3563 1562 Crs
6560 3188 Crs
5177 2372 Crs
2779 1302 Crs
1073 715 Crs
5546 2555 Crs
2687 1235 Crs
4301 1863 Crs
1442 881 Crs
5914 2814 Crs
3056 1365 Crs
4670 1971 Crs
1811 1079 Crs
6283 2968 Crs
3425 1497 Crs
5038 2225 Crs
2180 1603 Crs
3932 1733 Crs
3793 1666 Crs
935 639 Crs
1350 794 Crs
2548 1317 Crs
4162 1768 Crs
1304 782 Crs
5776 2661 Crs
2917 1485 Crs
4531 1994 Crs
1672 904 Crs
6145 2858 Crs
3286 1626 Crs
4900 2116 Crs
2041 1035 Crs
6514 3091 Crs
6594 4599 Crs
stroke
grestore
end
showpage
%%Trailer
%%DocumentFonts: Helvetica

--Boundary-00=_5nc1/OEDkzTNzgc
Content-Type: image/x-eps;
  name="small-frees.eps"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="small-frees.eps"

%!PS-Adobe-2.0 EPSF-2.0
%%Title: small-frees.eps
%%Creator: gnuplot 3.7 patchlevel 1
%%CreationDate: Thu Nov 27 16:39:18 2003
%%DocumentFonts: (atend)
%%BoundingBox: 50 50 410 302
%%Orientation: Portrait
%%EndComments
/gnudict 256 dict def
gnudict begin
/Color true def
/Solid false def
/gnulinewidth 5.000 def
/userlinewidth gnulinewidth def
/vshift -46 def
/dl {10 mul} def
/hpt_ 31.5 def
/vpt_ 31.5 def
/hpt hpt_ def
/vpt vpt_ def
/M {moveto} bind def
/L {lineto} bind def
/R {rmoveto} bind def
/V {rlineto} bind def
/vpt2 vpt 2 mul def
/hpt2 hpt 2 mul def
/Lshow { currentpoint stroke M
  0 vshift R show } def
/Rshow { currentpoint stroke M
  dup stringwidth pop neg vshift R show } def
/Cshow { currentpoint stroke M
  dup stringwidth pop -2 div vshift R show } def
/UP { dup vpt_ mul /vpt exch def hpt_ mul /hpt exch def
  /hpt2 hpt 2 mul def /vpt2 vpt 2 mul def } def
/DL { Color {setrgbcolor Solid {pop []} if 0 setdash }
 {pop pop pop Solid {pop []} if 0 setdash} ifelse } def
/BL { stroke userlinewidth 2 mul setlinewidth } def
/AL { stroke userlinewidth 2 div setlinewidth } def
/UL { dup gnulinewidth mul /userlinewidth exch def
      10 mul /udl exch def } def
/PL { stroke userlinewidth setlinewidth } def
/LTb { BL [] 0 0 0 DL } def
/LTa { AL [1 udl mul 2 udl mul] 0 setdash 0 0 0 setrgbcolor } def
/LT0 { PL [] 1 0 0 DL } def
/LT1 { PL [4 dl 2 dl] 0 1 0 DL } def
/LT2 { PL [2 dl 3 dl] 0 0 1 DL } def
/LT3 { PL [1 dl 1.5 dl] 1 0 1 DL } def
/LT4 { PL [5 dl 2 dl 1 dl 2 dl] 0 1 1 DL } def
/LT5 { PL [4 dl 3 dl 1 dl 3 dl] 1 1 0 DL } def
/LT6 { PL [2 dl 2 dl 2 dl 4 dl] 0 0 0 DL } def
/LT7 { PL [2 dl 2 dl 2 dl 2 dl 2 dl 4 dl] 1 0.3 0 DL } def
/LT8 { PL [2 dl 2 dl 2 dl 2 dl 2 dl 2 dl 2 dl 4 dl] 0.5 0.5 0.5 DL } def
/Pnt { stroke [] 0 setdash
   gsave 1 setlinecap M 0 0 V stroke grestore } def
/Dia { stroke [] 0 setdash 2 copy vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath stroke
  Pnt } def
/Pls { stroke [] 0 setdash vpt sub M 0 vpt2 V
  currentpoint stroke M
  hpt neg vpt neg R hpt2 0 V stroke
  } def
/Box { stroke [] 0 setdash 2 copy exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V closepath stroke
  Pnt } def
/Crs { stroke [] 0 setdash exch hpt sub exch vpt add M
  hpt2 vpt2 neg V currentpoint stroke M
  hpt2 neg 0 R hpt2 vpt2 V stroke } def
/TriU { stroke [] 0 setdash 2 copy vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath stroke
  Pnt  } def
/Star { 2 copy Pls Crs } def
/BoxF { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V  hpt2 0 V  0 vpt2 V
  hpt2 neg 0 V  closepath fill } def
/TriUF { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath fill } def
/TriD { stroke [] 0 setdash 2 copy vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath stroke
  Pnt  } def
/TriDF { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath fill} def
/DiaF { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath fill } def
/Pent { stroke [] 0 setdash 2 copy gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath stroke grestore Pnt } def
/PentF { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath fill grestore } def
/Circle { stroke [] 0 setdash 2 copy
  hpt 0 360 arc stroke Pnt } def
/CircleF { stroke [] 0 setdash hpt 0 360 arc fill } def
/C0 { BL [] 0 setdash 2 copy moveto vpt 90 450  arc } bind def
/C1 { BL [] 0 setdash 2 copy        moveto
       2 copy  vpt 0 90 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C2 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 90 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C3 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C4 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 180 270 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C5 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 90 arc
       2 copy moveto
       2 copy  vpt 180 270 arc closepath fill
               vpt 0 360 arc } bind def
/C6 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 90 270 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C7 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 0 270 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C8 { BL [] 0 setdash 2 copy moveto
      2 copy vpt 270 360 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C9 { BL [] 0 setdash 2 copy moveto
      2 copy  vpt 270 450 arc closepath fill
              vpt 0 360 arc closepath } bind def
/C10 { BL [] 0 setdash 2 copy 2 copy moveto vpt 270 360 arc closepath fill
       2 copy moveto
       2 copy vpt 90 180 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C11 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 0 180 arc closepath fill
       2 copy moveto
       2 copy  vpt 270 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C12 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 180 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C13 { BL [] 0 setdash  2 copy moveto
       2 copy  vpt 0 90 arc closepath fill
       2 copy moveto
       2 copy  vpt 180 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/C14 { BL [] 0 setdash 2 copy moveto
       2 copy  vpt 90 360 arc closepath fill
               vpt 0 360 arc } bind def
/C15 { BL [] 0 setdash 2 copy vpt 0 360 arc closepath fill
               vpt 0 360 arc closepath } bind def
/Rec   { newpath 4 2 roll moveto 1 index 0 rlineto 0 exch rlineto
       neg 0 rlineto closepath } bind def
/Square { dup Rec } bind def
/Bsquare { vpt sub exch vpt sub exch vpt2 Square } bind def
/S0 { BL [] 0 setdash 2 copy moveto 0 vpt rlineto BL Bsquare } bind def
/S1 { BL [] 0 setdash 2 copy vpt Square fill Bsquare } bind def
/S2 { BL [] 0 setdash 2 copy exch vpt sub exch vpt Square fill Bsquare } bind def
/S3 { BL [] 0 setdash 2 copy exch vpt sub exch vpt2 vpt Rec fill Bsquare } bind def
/S4 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt Square fill Bsquare } bind def
/S5 { BL [] 0 setdash 2 copy 2 copy vpt Square fill
       exch vpt sub exch vpt sub vpt Square fill Bsquare } bind def
/S6 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt vpt2 Rec fill Bsquare } bind def
/S7 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt vpt2 Rec fill
       2 copy vpt Square fill
       Bsquare } bind def
/S8 { BL [] 0 setdash 2 copy vpt sub vpt Square fill Bsquare } bind def
/S9 { BL [] 0 setdash 2 copy vpt sub vpt vpt2 Rec fill Bsquare } bind def
/S10 { BL [] 0 setdash 2 copy vpt sub vpt Square fill 2 copy exch vpt sub exch vpt Square fill
       Bsquare } bind def
/S11 { BL [] 0 setdash 2 copy vpt sub vpt Square fill 2 copy exch vpt sub exch vpt2 vpt Rec fill
       Bsquare } bind def
/S12 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill Bsquare } bind def
/S13 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill
       2 copy vpt Square fill Bsquare } bind def
/S14 { BL [] 0 setdash 2 copy exch vpt sub exch vpt sub vpt2 vpt Rec fill
       2 copy exch vpt sub exch vpt Square fill Bsquare } bind def
/S15 { BL [] 0 setdash 2 copy Bsquare fill Bsquare } bind def
/D0 { gsave translate 45 rotate 0 0 S0 stroke grestore } bind def
/D1 { gsave translate 45 rotate 0 0 S1 stroke grestore } bind def
/D2 { gsave translate 45 rotate 0 0 S2 stroke grestore } bind def
/D3 { gsave translate 45 rotate 0 0 S3 stroke grestore } bind def
/D4 { gsave translate 45 rotate 0 0 S4 stroke grestore } bind def
/D5 { gsave translate 45 rotate 0 0 S5 stroke grestore } bind def
/D6 { gsave translate 45 rotate 0 0 S6 stroke grestore } bind def
/D7 { gsave translate 45 rotate 0 0 S7 stroke grestore } bind def
/D8 { gsave translate 45 rotate 0 0 S8 stroke grestore } bind def
/D9 { gsave translate 45 rotate 0 0 S9 stroke grestore } bind def
/D10 { gsave translate 45 rotate 0 0 S10 stroke grestore } bind def
/D11 { gsave translate 45 rotate 0 0 S11 stroke grestore } bind def
/D12 { gsave translate 45 rotate 0 0 S12 stroke grestore } bind def
/D13 { gsave translate 45 rotate 0 0 S13 stroke grestore } bind def
/D14 { gsave translate 45 rotate 0 0 S14 stroke grestore } bind def
/D15 { gsave translate 45 rotate 0 0 S15 stroke grestore } bind def
/DiaE { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V closepath stroke } def
/BoxE { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V closepath stroke } def
/TriUE { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V closepath stroke } def
/TriDE { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V closepath stroke } def
/PentE { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  closepath stroke grestore } def
/CircE { stroke [] 0 setdash 
  hpt 0 360 arc stroke } def
/Opaque { gsave closepath 1 setgray fill grestore 0 setgray closepath } def
/DiaW { stroke [] 0 setdash vpt add M
  hpt neg vpt neg V hpt vpt neg V
  hpt vpt V hpt neg vpt V Opaque stroke } def
/BoxW { stroke [] 0 setdash exch hpt sub exch vpt add M
  0 vpt2 neg V hpt2 0 V 0 vpt2 V
  hpt2 neg 0 V Opaque stroke } def
/TriUW { stroke [] 0 setdash vpt 1.12 mul add M
  hpt neg vpt -1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt 1.62 mul V Opaque stroke } def
/TriDW { stroke [] 0 setdash vpt 1.12 mul sub M
  hpt neg vpt 1.62 mul V
  hpt 2 mul 0 V
  hpt neg vpt -1.62 mul V Opaque stroke } def
/PentW { stroke [] 0 setdash gsave
  translate 0 hpt M 4 {72 rotate 0 hpt L} repeat
  Opaque stroke grestore } def
/CircW { stroke [] 0 setdash 
  hpt 0 360 arc Opaque stroke } def
/BoxFill { gsave Rec 1 setgray fill grestore } def
end
%%EndProlog
gnudict begin
gsave
50 50 translate
0.050 0.050 scale
0 setgray
newpath
(Helvetica) findfont 140 scalefont setfont
1.000 UL
LTb
1.000 UL
LTa
574 280 M
6388 0 V
1.000 UL
LTb
574 280 M
63 0 V
6325 0 R
-63 0 V
490 280 M
(0) Rshow
1.000 UL
LTa
574 854 M
6388 0 V
1.000 UL
LTb
574 854 M
63 0 V
6325 0 R
-63 0 V
490 854 M
(1000) Rshow
1.000 UL
LTa
574 1428 M
6388 0 V
1.000 UL
LTb
574 1428 M
63 0 V
6325 0 R
-63 0 V
-6409 0 R
(2000) Rshow
1.000 UL
LTa
574 2002 M
6388 0 V
1.000 UL
LTb
574 2002 M
63 0 V
6325 0 R
-63 0 V
-6409 0 R
(3000) Rshow
1.000 UL
LTa
574 2576 M
6388 0 V
1.000 UL
LTb
574 2576 M
63 0 V
6325 0 R
-63 0 V
-6409 0 R
(4000) Rshow
1.000 UL
LTa
574 3150 M
6388 0 V
1.000 UL
LTb
574 3150 M
63 0 V
6325 0 R
-63 0 V
-6409 0 R
(5000) Rshow
1.000 UL
LTa
574 3724 M
6388 0 V
1.000 UL
LTb
574 3724 M
63 0 V
6325 0 R
-63 0 V
-6409 0 R
(6000) Rshow
1.000 UL
LTa
574 4298 M
6388 0 V
1.000 UL
LTb
574 4298 M
63 0 V
6325 0 R
-63 0 V
-6409 0 R
(7000) Rshow
1.000 UL
LTa
574 4872 M
6388 0 V
1.000 UL
LTb
574 4872 M
63 0 V
6325 0 R
-63 0 V
-6409 0 R
(8000) Rshow
1.000 UL
LTa
574 280 M
0 4592 V
1.000 UL
LTb
574 280 M
0 63 V
0 4529 R
0 -63 V
574 140 M
(0) Cshow
1.000 UL
LTa
1487 280 M
0 4592 V
1.000 UL
LTb
1487 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(20000) Cshow
1.000 UL
LTa
2399 280 M
0 4592 V
1.000 UL
LTb
2399 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(40000) Cshow
1.000 UL
LTa
3312 280 M
0 4592 V
1.000 UL
LTb
3312 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(60000) Cshow
1.000 UL
LTa
4224 280 M
0 4592 V
1.000 UL
LTb
4224 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(80000) Cshow
1.000 UL
LTa
5137 280 M
0 4592 V
1.000 UL
LTb
5137 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(100000) Cshow
1.000 UL
LTa
6049 280 M
0 4249 V
0 280 R
0 63 V
1.000 UL
LTb
6049 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(120000) Cshow
1.000 UL
LTa
6962 280 M
0 4592 V
1.000 UL
LTb
6962 280 M
0 63 V
0 4529 R
0 -63 V
0 -4669 R
(140000) Cshow
1.000 UL
LTb
574 280 M
6388 0 V
0 4592 V
-6388 0 V
574 280 L
1.000 UP
1.000 UL
LT0
6311 4739 M
(Normal) Rshow
621 849 Pls
667 837 Pls
714 881 Pls
5246 3082 Pls
2349 1627 Pls
948 903 Pls
3985 2375 Pls
5620 3495 Pls
4359 2584 Pls
1462 1154 Pls
5994 3806 Pls
3097 1970 Pls
4732 2857 Pls
1836 1409 Pls
6368 4121 Pls
3471 2164 Pls
5106 3311 Pls
2209 1511 Pls
3845 2289 Pls
3611 2297 Pls
5480 3460 Pls
2583 1707 Pls
4218 2503 Pls
1322 1070 Pls
5854 3764 Pls
2957 1829 Pls
4592 2616 Pls
1695 1244 Pls
6228 4181 Pls
3331 2125 Pls
4966 2991 Pls
2069 1458 Pls
2396 1578 Pls
3704 2219 Pls
808 921 Pls
5340 3235 Pls
2163 1521 Pls
2443 1624 Pls
4078 2325 Pls
1181 1129 Pls
5714 3752 Pls
2817 1745 Pls
4452 2491 Pls
1555 1323 Pls
6087 3987 Pls
3191 1955 Pls
4826 2776 Pls
1929 1410 Pls
6461 4320 Pls
3564 2077 Pls
5200 3316 Pls
2303 1583 Pls
1088 993 Pls
3938 2292 Pls
1041 1046 Pls
5573 3454 Pls
2677 1791 Pls
4312 2451 Pls
1415 1169 Pls
5947 3767 Pls
3050 1912 Pls
4686 2619 Pls
1789 1337 Pls
6321 4053 Pls
3424 2124 Pls
5059 2953 Pls
5387 3279 Pls
2256 1551 Pls
5433 3226 Pls
2536 1662 Pls
4172 2454 Pls
5807 3704 Pls
2910 1874 Pls
4546 2620 Pls
1649 1244 Pls
6181 3895 Pls
3284 1995 Pls
4919 3038 Pls
2022 1410 Pls
901 903 Pls
3658 2178 Pls
761 829 Pls
5293 3328 Pls
3798 2337 Pls
4032 2326 Pls
1135 986 Pls
5667 3660 Pls
2770 1745 Pls
4405 2492 Pls
1508 1154 Pls
6041 3951 Pls
3144 1912 Pls
4779 2782 Pls
1882 1369 Pls
6414 4223 Pls
3518 2124 Pls
6555 4240 Pls
5153 3112 Pls
2723 1834 Pls
995 1049 Pls
5527 3462 Pls
2630 1661 Pls
4265 2455 Pls
1368 1168 Pls
5900 3774 Pls
3004 1876 Pls
4639 2714 Pls
1742 1480 Pls
6274 4190 Pls
3377 2083 Pls
5013 2905 Pls
2116 1537 Pls
3891 2284 Pls
3751 2217 Pls
854 916 Pls
1275 1070 Pls
2490 1661 Pls
4125 2606 Pls
1228 1085 Pls
5760 3706 Pls
2863 1873 Pls
4499 2490 Pls
1602 1245 Pls
6134 3938 Pls
3237 2087 Pls
4873 2729 Pls
1976 1411 Pls
6508 4243 Pls
6594 4739 Pls
1.000 UP
1.000 UL
LT1
6311 4599 M
(VGNCA) Rshow
621 824 Crs
667 845 Crs
714 854 Crs
5246 3192 Crs
2349 1689 Crs
948 892 Crs
3985 2343 Crs
5620 3445 Crs
4359 2509 Crs
1462 1178 Crs
5994 3723 Crs
3097 1973 Crs
4732 2807 Crs
1836 1304 Crs
6368 4154 Crs
3471 2096 Crs
5106 3227 Crs
2209 1522 Crs
3845 2217 Crs
3611 2276 Crs
5480 3486 Crs
2583 1682 Crs
4218 2426 Crs
1322 1053 Crs
5854 3744 Crs
2957 1804 Crs
4592 2546 Crs
1695 1224 Crs
6228 4047 Crs
3331 1969 Crs
4966 2921 Crs
2069 1387 Crs
2396 1602 Crs
3704 2138 Crs
808 944 Crs
5340 3331 Crs
2163 1479 Crs
2443 1557 Crs
4078 2344 Crs
1181 1155 Crs
5714 3499 Crs
2817 1722 Crs
4452 2464 Crs
1555 1367 Crs
6087 3871 Crs
3191 1886 Crs
4826 2758 Crs
1929 1431 Crs
6461 4243 Crs
3564 2097 Crs
5200 3065 Crs
2303 1558 Crs
1088 1021 Crs
3938 2217 Crs
1041 1036 Crs
5573 3576 Crs
2677 1722 Crs
4312 2425 Crs
1415 1148 Crs
5947 3678 Crs
3050 1887 Crs
4686 2636 Crs
1789 1357 Crs
6321 4042 Crs
3424 2097 Crs
5059 2870 Crs
5387 3410 Crs
2256 1475 Crs
5433 3331 Crs
2536 1638 Crs
4172 2472 Crs
5807 3542 Crs
2910 1805 Crs
4546 2725 Crs
1649 1315 Crs
6181 3828 Crs
3284 1969 Crs
4919 3276 Crs
2022 1387 Crs
901 895 Crs
3658 2184 Crs
761 800 Crs
5293 3431 Crs
3798 2265 Crs
4032 2299 Crs
1135 1068 Crs
5667 3667 Crs
2770 1766 Crs
4405 2510 Crs
1508 1133 Crs
6041 3833 Crs
3144 1887 Crs
4779 2719 Crs
1882 1305 Crs
6414 4209 Crs
3518 2053 Crs
6555 4237 Crs
5153 3028 Crs
2723 1721 Crs
995 986 Crs
5527 3534 Crs
2630 1639 Crs
4265 2429 Crs
1368 1153 Crs
5900 3686 Crs
3004 1803 Crs
4639 2546 Crs
1742 1320 Crs
6274 3997 Crs
3377 2014 Crs
5013 2928 Crs
2116 1538 Crs
3891 2217 Crs
3751 2221 Crs
854 912 Crs
1275 1046 Crs
2490 1683 Crs
4125 2299 Crs
1228 1068 Crs
5760 3593 Crs
2863 1805 Crs
4499 2509 Crs
1602 1280 Crs
6134 3872 Crs
3237 1972 Crs
4873 2710 Crs
1976 1434 Crs
6508 4200 Crs
6594 4599 Crs
stroke
grestore
end
showpage
%%Trailer
%%DocumentFonts: Helvetica

--Boundary-00=_5nc1/OEDkzTNzgc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
