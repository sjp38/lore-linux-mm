Date: Fri, 11 Jun 1999 04:18:04 -0700
Message-Id: <199906111118.EAA00916@pizda.davem.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <199906101918.MAA09371@google.engr.sgi.com>
	(kanoj@google.engr.sgi.com)
Subject: Re: Experiment on usefuleness of cache coloring on ia32
References: <199906101918.MAA09371@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

   The kernel patch does a gross type of colored allocation by
   grabbing pages from the free list until it gets one of the right
   color - the intent is not to study the os overheads of doing
   colored allocations, rather the benefits a program might see from
   using pages allocated in such fashion.

I, some time ago, spent a day or two playing with a similar patch of
my own.  I enclose it below, it is a first stage effort in efficient
page coloring.  The next stage would make the COLOR_HASH lists true
chains, and not just a single entry hash.

However it is enough that you can play with the color stepping/init
heuristics to see what works better/worse with various tweaks.  Feel
free to play around with it and improve it.

Note: you'll need to make appropriate changes to asm-i386/cache.h

--- ./include/asm-sparc64/cache.h.~1~	Sun Jan  3 07:31:18 1999
+++ ./include/asm-sparc64/cache.h	Mon Feb  8 06:57:26 1999
@@ -9,4 +9,8 @@
 
 #define        L1_CACHE_ALIGN(x)       (((x)+(L1_CACHE_BYTES-1))&~(L1_CACHE_BYTES-1))
 
+/* L2 cache heuristics, only define if you want page coloring */
+#define        L2_CACHE_BYTES		64
+#define        L2_CACHE_SIZE		(512 * 1024)
+
 #endif
--- ./include/linux/mm.h.~1~	Sun Feb  7 06:54:14 1999
+++ ./include/linux/mm.h	Mon Feb  8 07:46:38 1999
@@ -262,6 +262,8 @@ extern inline unsigned long get_free_pag
 	return page;
 }
 
+extern unsigned long get_colored_page(int gfp_mask, int *colorp);
+
 extern int low_on_memory;
 
 /* memory.c & swap.c*/
--- ./include/linux/fs.h.~1~	Sun Feb  7 06:54:12 1999
+++ ./include/linux/fs.h	Mon Feb  8 07:26:37 1999
@@ -339,6 +339,7 @@ struct inode {
 	struct list_head	i_dentry;
 
 	unsigned long		i_ino;
+	unsigned int		i_color;
 	unsigned int		i_count;
 	kdev_t			i_dev;
 	umode_t			i_mode;
--- ./include/linux/sched.h.~1~	Sun Feb  7 06:54:14 1999
+++ ./include/linux/sched.h	Mon Feb  8 07:46:34 1999
@@ -166,6 +166,7 @@ struct mm_struct {
 	pgd_t * pgd;
 	atomic_t count;
 	int map_count;				/* number of VMAs */
+	int color;
 	struct semaphore mmap_sem;
 	unsigned long context;
 	unsigned long start_code, end_code, start_data, end_data;
@@ -184,7 +185,7 @@ struct mm_struct {
 #define INIT_MM {					\
 		&init_mmap, NULL, NULL,			\
 		swapper_pg_dir, 			\
-		ATOMIC_INIT(1), 1,			\
+		ATOMIC_INIT(1), 1, 0,			\
 		MUTEX,					\
 		0,					\
 		0, 0, 0, 0,				\
--- ./kernel/ksyms.c.~1~	Thu Jan 21 03:48:22 1999
+++ ./kernel/ksyms.c	Mon Feb  8 06:55:18 1999
@@ -87,6 +87,7 @@ EXPORT_SYMBOL(exit_sighand);
 
 /* internal kernel memory management */
 EXPORT_SYMBOL(__get_free_pages);
+EXPORT_SYMBOL(get_colored_page);
 EXPORT_SYMBOL(free_pages);
 EXPORT_SYMBOL(__free_page);
 EXPORT_SYMBOL(kmem_find_general_cachep);
--- ./mm/filemap.c.~1~	Mon Jan 25 20:53:47 1999
+++ ./mm/filemap.c	Mon Feb  8 07:01:35 1999
@@ -253,7 +253,7 @@ static unsigned long try_to_read_ahead(s
 	offset &= PAGE_MASK;
 	switch (page_cache) {
 	case 0:
-		page_cache = __get_free_page(GFP_USER);
+		page_cache = get_colored_page(GFP_USER, &inode->i_color);
 		if (!page_cache)
 			break;
 	default:
@@ -675,7 +675,7 @@ no_cached_page:
 		 * page..
 		 */
 		if (!page_cache) {
-			page_cache = __get_free_page(GFP_USER);
+			page_cache = get_colored_page(GFP_USER, &inode->i_color);
 			/*
 			 * That could have slept, so go around to the
 			 * very beginning..
@@ -941,7 +941,7 @@ found_page:
 	 * extra page -- better to overlap the allocation with the I/O.
 	 */
 	if (no_share && !new_page) {
-		new_page = __get_free_page(GFP_USER);
+		new_page = get_colored_page(GFP_USER, &inode->i_color);
 		if (!new_page)
 			goto failure;
 	}
@@ -989,7 +989,7 @@ no_cached_page:
 		new_page = try_to_read_ahead(file, reada, new_page);
 
 	if (!new_page)
-		new_page = __get_free_page(GFP_USER);
+		new_page = get_colored_page(GFP_USER, &inode->i_color);
 	if (!new_page)
 		goto no_page;
 
@@ -1464,7 +1464,7 @@ generic_file_write(struct file *file, co
 		page = __find_page(inode, pgpos, *hash);
 		if (!page) {
 			if (!page_cache) {
-				page_cache = __get_free_page(GFP_USER);
+				page_cache = get_colored_page(GFP_USER, &inode->i_color);
 				if (page_cache)
 					continue;
 				status = -ENOMEM;
@@ -1535,7 +1535,7 @@ unsigned long get_cached_page(struct ino
 	if (!page) {
 		if (!new)
 			goto out;
-		page_cache = get_free_page(GFP_USER);
+		page_cache = get_colored_page(GFP_USER, &inode->i_color);
 		if (!page_cache)
 			goto out;
 		page = mem_map + MAP_NR(page_cache);
--- ./mm/page_alloc.c.~1~	Mon Jan 25 20:53:47 1999
+++ ./mm/page_alloc.c	Mon Feb  8 07:26:00 1999
@@ -36,6 +36,16 @@ int nr_free_pages = 0;
 #define NR_MEM_LISTS 6
 #endif
 
+#ifdef L2_CACHE_BYTES
+#define NUM_COLORS	(L2_CACHE_SIZE >> PAGE_SHIFT)
+struct page *color_hash[NUM_COLORS];
+#define UNCOLOR(x, num) \
+	if(color_hash[(num) & (NUM_COLORS - 1)] == (x)) \
+		color_hash[(num) & (NUM_COLORS - 1)] = NULL
+#else
+#define UNCOLOR(num)	do { } while (0)
+#endif
+
 /* The start of this MUST match the start of "struct page" */
 struct free_area_struct {
 	struct page *next;
@@ -93,6 +103,7 @@ spinlock_t page_alloc_lock = SPIN_LOCK_U
 static inline void free_pages_ok(unsigned long map_nr, unsigned long order)
 {
 	struct free_area_struct *area = free_area + order;
+	struct page *p;
 	unsigned long index = map_nr >> (1 + order);
 	unsigned long mask = (~0UL) << order;
 	unsigned long flags;
@@ -112,7 +123,12 @@ static inline void free_pages_ok(unsigne
 		index >>= 1;
 		map_nr &= mask;
 	}
-	add_mem_queue(area, list(map_nr));
+	p = list(map_nr);
+#ifdef L2_CACHE_BYTES
+	if(area == free_area)
+		color_hash[map_nr & (NUM_COLORS - 1)] = p;
+#endif
+	add_mem_queue(area, p);
 
 #undef list
 
@@ -164,6 +180,7 @@ do { struct free_area_struct * area = fr
 				unsigned long map_nr; \
 				(prev->next = ret->next)->prev = prev; \
 				map_nr = ret - mem_map; \
+				UNCOLOR(ret, map_nr); \
 				MARK_USED(map_nr, new_order, area); \
 				nr_free_pages -= 1 << order; \
 				EXPAND(ret, map_nr, order, new_order, area); \
@@ -253,6 +270,52 @@ nopage:
 	return 0;
 }
 
+unsigned long get_colored_page(int gfp_mask, int *colorp)
+{
+#ifndef L2_CACHE_BYTES
+	return __get_free_pages(gfp_mask, 0);
+#else
+	unsigned long flags;
+	struct page *p;
+	unsigned long map_nr;
+
+	/* This code is simplified by the fact that interrupts
+	 * and the try_to_free_pages paths do not call us.
+	 * So if we are low on memory, just punt to non-colored
+	 * allocation immediately because this is a heuristic.
+	 */
+	p = NULL;
+	map_nr = 0;
+	if (!low_on_memory &&
+	    nr_free_pages >= freepages.high) {
+		int color = ((*colorp)++ & (NUM_COLORS - 1));
+
+		spin_lock_irqsave(&page_alloc_lock, flags);
+		p = color_hash[color];
+		if(p != NULL) {
+			/* Zap from color hash and unlink the page. */
+			color_hash[color] = NULL;
+			(p->prev->next = p->next)->prev = p->prev;
+
+			/* Set index, and mark it used. */
+			map_nr = p - mem_map;
+			change_bit(map_nr >> 1, free_area->map);
+
+			/* One less free page. */
+			nr_free_pages--;
+
+			/* Set initial page count. */
+			atomic_set(&p->count, 1);
+		}
+		spin_unlock_irqrestore(&page_alloc_lock, flags);
+	}
+	if(p != NULL)
+		return ADDRESS(map_nr);
+
+	return __get_free_pages(gfp_mask, 0);
+#endif
+}
+
 /*
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
@@ -299,6 +362,11 @@ unsigned long __init free_area_init(unsi
 	mem_map_t * p;
 	unsigned long mask = PAGE_MASK;
 	unsigned long i;
+
+#ifdef L2_CACHE_BYTES
+	for(i = 0; i < NUM_COLORS; i++)
+		color_hash[i] = (struct page *) 0;
+#endif
 
 	/*
 	 * Select nr of pages we try to keep free for important stuff
--- ./mm/memory.c.~1~	Mon Jan 25 20:38:57 1999
+++ ./mm/memory.c	Mon Feb  8 06:59:45 1999
@@ -808,7 +808,7 @@ static int do_anonymous_page(struct task
 {
 	pte_t entry = pte_wrprotect(mk_pte(ZERO_PAGE, vma->vm_page_prot));
 	if (write_access) {
-		unsigned long page = __get_free_page(GFP_USER);
+		unsigned long page = get_colored_page(GFP_USER, &vma->vm_mm->color);
 		if (!page)
 			return 0;
 		clear_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
