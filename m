From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906120102.SAA64168@google.engr.sgi.com>
Subject: Some issues + [PATCH] kanoj-mm8-2.2.9 Show statistics on alloc/free requests for each pagefree list
Date: Fri, 11 Jun 1999 18:02:18 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Attached is a patch to mm/page_alloc.c that will report the cumulative
number of alloc and free requests for pages of each size via the
MagicSysRq 'm' command. To turn on the display, you need to add a

#define FREELIST_STAT

to mm/page_alloc.c before the #ifdef FREELIST_STAT line.

On my HP-Kayak 2p ia32 system, the relevant output right after I get a 
login prompt is:

2*4kB (19651, 33223) 1*8kB (373, 299) 1*16kB (2, 0) 0*32kB (2, 0) 1*64kB (0, 0) 0*128kB (0, 0) 0*256kB (1, 0) 0*512kB (0, 0) 0*1024kB (0, 0) 26*2048kB (0, 0) = 53344kB)

And after running a 2.2.9 kernel compile:

183*4kB (510767, 515934) 19*8kB (2480, 2323) 10*16kB (2, 0) 3*32kB (2, 0) 0*64kB (0, 0) 0*128kB (0, 0) 2*256kB (1, 0) 2*512kB (0, 0) 0*1024kB (0, 0) 8*2048kB (0, 0) = 19060kB)

The first number in the bracketed pair is the number of alloc requests, the
second is the number of free requests. (Yes, don't ask me how the frees 
outnumber the allocs for 4K pages, probably some code is asking for bigger 
pages and freeing single pages).

Anyway, this raises some interesting questions about the buddy algorithm.
Is it really worth aggressively coalescing pages on each free? Wouldn't
it be better to lazily coalesce pages (maybe by a kernel thread), or even
on demand? By far, the most number of requests are coming for the 4K pages,
followed by 8K (task/stack pair). A kernel compile is no representative
app, but I would be surprised if there are too many apps/drivers which 
will force bigger page requests, once kernel initialization is complete.
Wouldn't it be better to optimize the more common case?

Not to mention that if we do not do aggressive coalescing, we could think
about maintaining pages freed by shrink_mmap in the SwapCache/filecache,
so that those pages could be reclaimed from the free list on re-reference.

Kanoj
kanoj@engr.sgi.com


--- mm/page_alloc.c	Fri May 14 14:33:29 1999
+++ mm/page_alloc.new	Fri Jun 11 17:24:14 1999
@@ -36,11 +36,32 @@
 #define NR_MEM_LISTS 10
 #endif
 
+#define FREELIST_STAT
+#ifdef FREELIST_STAT
+#define	alloc_stat_field	unsigned long alloc_stat;
+#define free_stat_field		unsigned long free_stat;
+#define init_stat(area)		(area)->alloc_stat = (area)->free_stat = 0
+#define alloc_stat_inc(area)	(area)->alloc_stat++
+#define free_stat_inc(area)	(area)->free_stat++
+#define alloc_stat_get(area)	(area)->alloc_stat
+#define free_stat_get(area)	(area)->free_stat
+#else
+#define	alloc_stat_field
+#define	free_stat_field
+#define	init_stat(area)
+#define alloc_stat_inc(area)
+#define free_stat_inc(area)
+#define alloc_stat_get(area)	(unsigned long)0
+#define free_stat_get(area)	(unsigned long)0
+#endif
+
 /* The start of this MUST match the start of "struct page" */
 struct free_area_struct {
 	struct page *next;
 	struct page *prev;
 	unsigned int * map;
+	alloc_stat_field
+	free_stat_field
 };
 
 #define memory_head(x) ((struct page *)(x))
@@ -51,6 +72,7 @@
 {
 	head->next = memory_head(head);
 	head->prev = memory_head(head);
+	init_stat(head);
 }
 
 static inline void add_mem_queue(struct free_area_struct * head, struct page * entry)
@@ -99,6 +121,8 @@
 
 	spin_lock_irqsave(&page_alloc_lock, flags);
 
+	free_stat_inc(free_area + order);
+
 #define list(x) (mem_map+(x))
 
 	map_nr &= mask;
@@ -236,6 +260,7 @@
 	}
 ok_to_allocate:
 	spin_lock_irqsave(&page_alloc_lock, flags);
+	alloc_stat_inc(free_area + order);
 	RMQUEUE(order, gfp_mask);
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
 
@@ -277,7 +302,7 @@
 			nr ++;
 		}
 		total += nr * ((PAGE_SIZE>>10) << order);
-		printk("%lu*%lukB ", nr, (unsigned long)((PAGE_SIZE>>10) << order));
+		printk("%lu*%lukB (%lu, %lu) ", nr, (unsigned long)((PAGE_SIZE>>10) << order), alloc_stat_get(free_area + order), free_stat_get(free_area + order));
 	}
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
 	printk("= %lukB)\n", total);
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
