Received: from computer (dc-lata-1-95.dynamic-dialup.coretel.net [162.33.62.95])
	by boo-mda02.boo.net (8.9.3/8.9.3) with SMTP id UAA31114
	for <linux-mm@kvack.org>; Sun, 13 Jan 2002 20:40:00 -0500
Message-Id: <3.0.6.32.20020113204610.007c7a60@boo.net>
Date: Sun, 13 Jan 2002 20:46:10 -0500
From: Jason Papadopoulos <jasonp@boo.net>
Subject: [PATCH] page coloring for 2.4.17 kernel
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello. Please be patient with this, my first post to linux-mm.
The included patch modifies the free list in the 2.4.17 kernel
to support round-robin page coloring. It seems to work okay
on an Alpha and speeds up a lot of number-crunching code I
have lying around (lmbench reports some higher bandwidths too).
The patch is a port of the 2.2.20 version that I recently posted
to the linux kernelmailing list.

I'd be grateful if the folks on this list can try out other 
architectures and benchmarks. I've also been told that the code
which generates a random color needs to be more portable and cannot
rely on 64-bit data types. The coloring scheme is a little simplistic,
and it would be nice to use another scheme that is more efficient 
but involves more extensive changes to the kernel.

Thanks in advance for your help.
jasonp

PS: Note that three of the "diff" command lines below wrap around
    to the next line. Stupid Eudora...

-----------------------------------------------------------------
diff -ruN linux-2.4.17/drivers/char/Config.in linux-2.4.17a/drivers/char/Config.in
--- linux-2.4.17/drivers/char/Config.in	Mon Nov 12 12:34:16 2001
+++ linux-2.4.17a/drivers/char/Config.in	Sat Jan 12 09:35:03 2002
@@ -174,6 +174,8 @@
 fi
 endmenu
 
+tristate 'Page Coloring' CONFIG_PAGE_COLORING
+
 if [ "$CONFIG_ARCH_NETWINDER" = "y" ]; then
    tristate 'NetWinder thermometer support' CONFIG_DS1620
    tristate 'NetWinder Button' CONFIG_NWBUTTON
diff -ruN linux-2.4.17/drivers/char/Makefile linux-2.4.17a/drivers/char/Makefile
--- linux-2.4.17/drivers/char/Makefile	Sun Nov 11 13:09:32 2001
+++ linux-2.4.17a/drivers/char/Makefile	Sat Jan 12 09:42:23 2002
@@ -240,6 +240,11 @@
   obj-y += mwave/mwave.o
 endif
 
+ifeq ($(CONFIG_PAGE_COLORING),m)
+  CONFIG_PAGE_COLORING_MODULE=y
+  obj-m += page_color.o
+endif
+
 include $(TOPDIR)/Rules.make
 
 fastdep:
diff -ruN linux-2.4.17/drivers/char/page_color.c linux-2.4.17a/drivers/char/page_color.c
--- linux-2.4.17/drivers/char/page_color.c	Wed Dec 31 19:00:00 1969
+++ linux-2.4.17a/drivers/char/page_color.c	Sun Jan 13 17:47:44 2002
@@ -0,0 +1,167 @@
+/*
+ *	This module implements page coloring, a systematic way
+ * 	to get the most performance out of the expensive cache
+ *	memory your computer has. At present the code is *only*
+ *	to be built as a loadable kernel module.
+ *
+ *	After building the kernel and rebooting, load the module
+ *	and specify the cache size to use, like so:
+ *
+ *	insmod <path to page_color.o> cache_size=X
+ *
+ *	where X is the size of the largest cache your system has.
+ *	For machines with three cache levels (Alpha 21164, AMD K6-III)
+ *	this will be the size in bytes of the L3 cache, and for all
+ *	others it will be the size of the L2 cache. If your system
+ *	doesn't have at least L2 cache, fer cryin' out loud GET SOME!
+ *	When specifying the cache size you can use 'K' or 'M' to signify
+ *	kilobytes or megabytes, respectively. In any case, the cache
+ *	size *must* be a power of two.
+ * 
+ * 	insmod will create a module called 'page_color' which changes
+ *	the way Linux allocates pages from the free list. It is always
+ *	safe to start and stop the module while other processes are running.
+ *
+ *	If linux is configured for a /proc filesystem, the module will
+ *	also create /proc/page_color as a means of reporting statistics.
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <asm/page.h>
+#include <linux/mm.h>
+#include <linux/proc_fs.h>
+
+extern unsigned int page_miss_count;
+extern unsigned int page_hit_count;
+extern unsigned int page_colors;
+extern unsigned int page_alloc_count;
+extern struct list_head *page_color_table;
+
+void page_color_start(void);
+void page_color_stop(void);
+
+#if defined(__alpha__)
+#define CACHE_SIZE_GUESS (4*1024*1024)
+#elif defined(__i386__)
+#define CACHE_SIZE_GUESS (256*1024)
+#else
+#define CACHE_SIZE_GUESS (1*1024*1024)
+#endif 
+
+#ifdef CONFIG_PROC_FS
+
+int page_color_getinfo(char *buf, char **start, off_t fpos, int length)
+{
+	int i, j, k, count, num_colors;
+	struct list_head *queue, *curr;
+	char *p = buf;
+
+	p += sprintf(p, "colors: %d\n", page_colors);
+	p += sprintf(p, "hits: %d\n", page_hit_count);
+	p += sprintf(p, "misses: %d\n", page_miss_count);
+	p += sprintf(p, "pages allocated: %d\n", page_alloc_count);
+
+	queue = page_color_table;
+	for(i=0; i<MAX_NR_ZONES; i++) {
+		num_colors = page_colors;
+
+		for(j=0; j<MAX_ORDER; j++) {
+			for(k=0; k<num_colors; k++) {
+				count = 0;
+				if (!queue->next)
+					goto getinfo_done;
+
+				list_for_each(curr, queue) {
+					count++;
+				}
+				p += sprintf(p, "%d ", count);
+				queue++;
+			}
+	
+			p += sprintf(p, "\n");
+			if (num_colors > 1)
+				num_colors >>= 1;
+		}
+	}
+
+getinfo_done:
+        return p - buf;
+}
+
+#endif
+
+void cleanup_module(void)
+{
+	printk("page_color: terminating page coloring\n");
+
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("page_color", NULL);
+#endif
+
+	page_color_stop();
+	kfree(page_color_table);
+}
+
+static char *cache_size;
+MODULE_PARM(cache_size, "s");
+
+int init_module(void)
+{
+	unsigned int cache_size_int;
+	unsigned int alloc_size;
+
+	if (cache_size) {
+		cache_size_int = simple_strtoul(cache_size, 
+					(char **)NULL, 10);
+		if ( strchr(cache_size, 'M') || 
+		     strchr(cache_size, 'm') )
+			cache_size_int *= 1024*1024;
+
+		if ( strchr(cache_size, 'K') || 
+		     strchr(cache_size, 'k') )
+			cache_size_int *= 1024;
+	} 
+	else {
+		cache_size_int = CACHE_SIZE_GUESS;
+	}
+
+	if( (-cache_size_int & cache_size_int) != cache_size_int ) {
+		printk ("page_color: cache size is not a power of two\n");
+		return 1;
+	}
+
+	page_colors = cache_size_int / PAGE_SIZE;
+	page_hit_count = 0;
+	page_miss_count = 0;
+	page_alloc_count = 0;
+	alloc_size = MAX_NR_ZONES * sizeof(struct list_head) *
+				(2 * page_colors + MAX_ORDER);
+	page_color_table = (struct list_head *)kmalloc(alloc_size, GFP_KERNEL);
+	if (!page_color_table) {
+		printk("page_color: memory allocation failed\n");
+		return 1;
+	}
+	memset(page_color_table, 0, alloc_size);
+
+	page_color_start();
+
+#ifdef CONFIG_PROC_FS
+	create_proc_info_entry("page_color", 0, NULL, page_color_getinfo);
+#endif
+
+	printk("page_color: starting with %d colors\n", page_colors );
+	return 0;
+}
diff -ruN linux-2.4.17/include/linux/mmzone.h linux-2.4.17a/include/linux/mmzone.h
--- linux-2.4.17/include/linux/mmzone.h	Sat Jan 12 10:21:34 2002
+++ linux-2.4.17a/include/linux/mmzone.h	Sat Jan 12 23:34:28 2002
@@ -21,6 +21,12 @@
 typedef struct free_area_struct {
 	struct list_head	free_list;
 	unsigned long		*map;
+
+#ifdef CONFIG_PAGE_COLORING_MODULE
+	unsigned long		count;
+	struct list_head	*color_list;
+#endif
+
 } free_area_t;
 
 struct pglist_data;
diff -ruN linux-2.4.17/include/linux/sched.h linux-2.4.17a/include/linux/sched.h
--- linux-2.4.17/include/linux/sched.h	Sat Jan 12 10:21:34 2002
+++ linux-2.4.17a/include/linux/sched.h	Sat Jan 12 23:34:28 2002
@@ -410,6 +410,11 @@
 
 /* journalling filesystem info */
 	void *journal_info;
+
+#ifdef CONFIG_PAGE_COLORING_MODULE
+	unsigned int color_init;
+	unsigned int target_color;
+#endif
 };
 
 /*
diff -ruN linux-2.4.17/kernel/ksyms.c linux-2.4.17a/kernel/ksyms.c
--- linux-2.4.17/kernel/ksyms.c	Fri Dec 28 21:51:25 2001
+++ linux-2.4.17a/kernel/ksyms.c	Sun Jan 13 17:46:28 2002
@@ -559,3 +559,21 @@
 
 EXPORT_SYMBOL(tasklist_lock);
 EXPORT_SYMBOL(pidhash);
+
+#ifdef CONFIG_PAGE_COLORING_MODULE
+extern unsigned int page_miss_count;
+extern unsigned int page_hit_count;
+extern unsigned int page_alloc_count;
+extern unsigned int page_colors;
+extern struct list_head *page_color_table;
+void page_color_start(void);
+void page_color_stop(void);
+
+EXPORT_SYMBOL_NOVERS(page_miss_count);
+EXPORT_SYMBOL_NOVERS(page_hit_count);
+EXPORT_SYMBOL_NOVERS(page_alloc_count);
+EXPORT_SYMBOL_NOVERS(page_colors);
+EXPORT_SYMBOL_NOVERS(page_color_table);
+EXPORT_SYMBOL_NOVERS(page_color_start);
+EXPORT_SYMBOL_NOVERS(page_color_stop);
+#endif
diff -ruN linux-2.4.17/mm/page_alloc.c linux-2.4.17a/mm/page_alloc.c
--- linux-2.4.17/mm/page_alloc.c	Mon Nov 19 19:35:40 2001
+++ linux-2.4.17a/mm/page_alloc.c	Sun Jan 13 18:46:31 2002
@@ -56,6 +56,288 @@
  */
 #define BAD_RANGE(zone,x) (((zone) != (x)->zone) || (((x)-mem_map) < (zone)->zone_start_mapnr) || (((x)-mem_map) >= (zone)->zone_start_mapnr+(zone)->size))
 
+
+#ifdef CONFIG_PAGE_COLORING_MODULE
+
+#ifdef CONFIG_DISCONTIGMEM
+#error "Page coloring implementation cannot handle NUMA architectures"
+#endif
+
+unsigned int page_coloring = 0;
+unsigned int page_miss_count;
+unsigned int page_hit_count;
+unsigned int page_alloc_count;
+unsigned int page_colors = 0;
+struct list_head *page_color_table;
+
+#define COLOR(x)  ((x) & cache_mask)
+
+void page_color_start(void)
+{
+	/* Empty the free list in each zone. For each
+	   queue in the free list, transfer the entries
+	   in the queue over to another set of queues
+	   (the destination queue is determined by the 
+	   color of each entry). */
+
+	int i, j, k;
+	unsigned int num_colors, cache_mask;
+	unsigned long index;
+	unsigned long flags[MAX_NR_ZONES];
+	struct list_head *color_list_start, *head, *curr;
+	free_area_t *area;
+	struct page *page;
+	zone_t *zone;
+	pg_data_t *pgdata;
+ 
+ 	cache_mask = page_colors - 1;
+	color_list_start = page_color_table;
+	pgdata = &contig_page_data;
+
+	/* Stop all allocation of free pages while the
+	   reshuffling is taking place */
+
+	for(i = 0; i < MAX_NR_ZONES; i++) {
+		zone = pgdata->node_zones + i;
+		if (zone->size)
+			spin_lock_irqsave(&zone->lock, flags[i]);
+	}
+
+	for(i = 0; i < MAX_NR_ZONES; i++) {
+		num_colors = page_colors;
+		zone = pgdata->node_zones + i;
+
+		if (!zone->size)
+			continue;
+
+		for(j = 0; j < MAX_ORDER; j++) {
+			area = zone->free_area + j;
+			area->count = 0;
+			area->color_list = color_list_start;
+			head = &area->free_list;
+			curr = memlist_next(head);
+
+			for(k = 0; k < num_colors; k++) 
+				memlist_init(color_list_start + k);
+
+			while(curr != head) {
+				page = memlist_entry(curr, struct page, list);
+				memlist_del(curr);
+				index = page - zone->zone_mem_map;
+				memlist_add_head(curr, area->color_list +
+							(COLOR(index) >> j));
+				area->count++;
+				curr = memlist_next(head);
+			}
+	
+			color_list_start += num_colors;
+			if (num_colors > 1)
+				num_colors >>= 1;
+		}
+	}
+
+	/* Allocation of free pages can continue */
+
+	page_coloring = 1;
+	for(i = 0; i < MAX_NR_ZONES; i++) {
+		zone = pgdata->node_zones + i;
+		if (zone->size)
+			spin_unlock_irqrestore(&zone->lock, flags[i]);
+	}
+}
+
+void page_color_stop(void)
+{
+	/* Reverse the operation of page_color_start(). */
+
+	int i, j, k;
+	unsigned int num_colors;
+	unsigned long flags[MAX_NR_ZONES];
+	struct list_head *head, *curr;
+	free_area_t *area;
+	zone_t *zone;
+	pg_data_t *pgdata;
+ 
+	pgdata = &contig_page_data;
+
+	for(i = 0; i < MAX_NR_ZONES; i++) {
+		zone = pgdata->node_zones + i;
+		if (zone->size)
+			spin_lock_irqsave(&zone->lock, flags[i]);
+	}
+
+	for(i = 0; i < MAX_NR_ZONES; i++) {
+		num_colors = page_colors;
+		zone = pgdata->node_zones + i;
+
+		if (!zone->size)
+			continue;
+
+		for(j = 0; j<MAX_ORDER; j++) {
+			area = zone->free_area + j;
+			area->count = 0;
+
+			for(k = 0; k < num_colors; k++) {
+				head = area->color_list + k;
+				curr = memlist_next(head);
+				while(curr != head) {
+					memlist_del(curr);
+					memlist_add_head(curr, 
+							&area->free_list);
+					curr = memlist_next(head);
+				}
+			}
+	
+			if (num_colors > 1)
+				num_colors >>= 1;
+		}
+	}
+
+	page_coloring = 0;
+	for(i = 0; i < MAX_NR_ZONES; i++) {
+		zone = pgdata->node_zones + i;
+		if (zone->size)
+			spin_unlock_irqrestore(&zone->lock, flags[i]);
+	}
+}
+
+unsigned int rand_carry = 0x01234567;
+unsigned int rand_seed = 0x89abcdef;
+
+#define MULT 2131995753
+
+static inline unsigned int get_rand(void) 
+{
+	/* A multiply-with-carry random number generator by 
+	   George Marsaglia. The period is about 1<<63, and
+	   each call to get_rand() returns 32 random bits */
+
+	unsigned long long prod;
+
+	prod = (unsigned long long)rand_seed * 
+	       (unsigned long long)MULT + 
+	       (unsigned long long)rand_carry;
+	rand_seed = (unsigned int)prod;
+	rand_carry = (unsigned int)(prod >> 32);
+
+	return rand_seed;
+}
+
+static struct page *alloc_pages_by_color(zone_t *zone, unsigned int order)
+{
+	unsigned int i;
+	unsigned int mask, color;
+	unsigned long page_idx;
+	free_area_t *area;
+	struct list_head *curr, *head;
+	struct page *page;
+ 	unsigned int cache_mask = page_colors - 1;
+
+	/* If this process hasn't asked for free pages
+	   before, assign it a random starting color. */
+
+	if (current->color_init != current->pid) {
+		current->color_init = current->pid;
+		current->target_color = COLOR(get_rand());
+	}
+
+	/* Round the target color to look for up to the
+	   next 1<<order boundary. */
+
+	mask = (1 << order) - 1;
+	color = current->target_color;
+	color = COLOR((color + mask) & ~mask);
+
+	/* Find out early if there are no free pages at all. */
+
+	for(i = order; i < MAX_ORDER; i++)
+		if (zone->free_area[i].count)
+			break;
+	
+	if (i == MAX_ORDER) 
+		return NULL;
+
+	/* The memory allocation is guaranteed to succeed
+	   (although we may not find the correct color) */
+
+	while(1) {
+		area = zone->free_area + order;
+		for(i = order; i < MAX_ORDER; i++) {
+			head = area->color_list + (color >> i);
+			curr = memlist_next(head);
+			if (curr != head)
+				goto alloc_page_done;
+			area++;
+		}
+
+		page_miss_count++;
+		color = COLOR(color + (1<<order));
+	} 
+
+alloc_page_done:
+	page = memlist_entry(curr, struct page, list);
+	if (BAD_RANGE(zone,page))
+		BUG();
+
+	memlist_del(curr);
+	page_idx = page - zone->zone_mem_map;
+	zone->free_pages -= 1 << order;
+	area->count--;
+
+	if (i < (MAX_ORDER - 1))
+		__change_bit(page_idx >> (1+i), area->map);
+
+	while (i > order) {
+
+		/* Return 1<<order contiguous pages out of 
+		   the 1<<i available now. Without page coloring
+		   it would suffice to keep chopping the number of
+		   pages in half and return the last 1<<order of
+		   them. Here, the bottom bits of the index to 
+		   return must match the target color. We have to 
+		   keep chopping 1<<i in half but we can
+		   only ignore the halves that don't match the 
+		   bit pattern of the target color. */
+
+		i--;
+		area--;
+		mask = 1 << i;
+		area->count++;
+		__change_bit(page_idx >> (1+i), area->map);
+		if (color & mask) {
+			if (BAD_RANGE(zone,page + mask))
+				BUG();
+
+			memlist_add_head(&page->list, area->color_list + 
+						(COLOR(page_idx) >> i));
+			page_idx += mask;
+			page += mask;
+		}
+		else {
+			memlist_add_head(&(page + mask)->list, 
+					area->color_list + 
+					(COLOR(page_idx + mask) >> i));
+		}
+	}
+
+	set_page_count(page, 1);
+
+	if (BAD_RANGE(zone,page))
+		BUG();
+	if (PageLRU(page))
+		BUG();
+	if (PageActive(page))
+		BUG();
+
+	current->target_color = COLOR(color + (1<<order));
+	page_hit_count++;
+	page_alloc_count += 1 << order;
+	return page;
+}
+
+#endif	/* CONFIG_PAGE_COLORING_MODULE */
+
+
 /*
  * Buddy system. Hairy. You really aren't expected to understand this
  *
@@ -125,12 +407,26 @@
 		if (BAD_RANGE(zone,buddy2))
 			BUG();
 
+#ifdef CONFIG_PAGE_COLORING_MODULE
+		area->count--;
+		order++;
+#endif
 		memlist_del(&buddy1->list);
 		mask <<= 1;
 		area++;
 		index >>= 1;
 		page_idx &= mask;
 	}
+
+#ifdef CONFIG_PAGE_COLORING_MODULE
+	if (page_coloring == 1) {
+		unsigned long cache_mask = page_colors - 1;
+		memlist_add_head(&(base + page_idx)->list, 
+				area->color_list + (COLOR(page_idx) >> order));
+		spin_unlock_irqrestore(&zone->lock, flags);
+		return;
+	}
+#endif
 	memlist_add_head(&(base + page_idx)->list, &area->free_list);
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -181,6 +477,15 @@
 	struct page *page;
 
 	spin_lock_irqsave(&zone->lock, flags);
+
+#ifdef CONFIG_PAGE_COLORING_MODULE
+	if (page_coloring == 1) {
+		page = alloc_pages_by_color(zone, order);
+		spin_unlock_irqrestore(&zone->lock, flags);
+		return page;
+	}
+#endif
+
 	do {
 		head = &area->free_list;
 		curr = memlist_next(head);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
