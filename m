Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 617876B000A
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 09:33:03 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id r188-v6so2712892itb.9
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 06:33:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q6si19290540itj.38.2018.11.02.06.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 06:33:01 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/3] mm: Use line-buffered printk() for show_free_areas().
Date: Fri,  2 Nov 2018 22:31:56 +0900
Message-Id: <1541165517-3557-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

syzbot is sometimes getting mixed output like below due to concurrent
printk(). Mitigate such output by using line-buffered printk() API.

  Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB 
  syz-executor0: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|__GFP_COMP), nodemask=(null)
  (U) 
  syz-executor0 cpuset=
  2*64kB 
  syz0
  (U) 
   mems_allowed=0
  1*128kB 
  CPU: 0 PID: 7592 Comm: syz-executor0 Not tainted 4.19.0-rc6+ #118
  (U) 
  Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
  1*256kB (U) 
  Call Trace:
  0*512kB 
   <IRQ>
  1*1024kB 
   __dump_stack lib/dump_stack.c:77 [inline]
   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
  (U) 
  1*2048kB 
   warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
  (M) 

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_alloc.c | 32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5..4411d5a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4694,10 +4694,10 @@ unsigned long nr_free_pagecache_pages(void)
 	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
 }
 
-static inline void show_node(struct zone *zone)
+static inline void show_node(struct zone *zone, struct printk_buffer *buf)
 {
 	if (IS_ENABLED(CONFIG_NUMA))
-		printk("Node %d ", zone_to_nid(zone));
+		printk_buffered(buf, "Node %d ", zone_to_nid(zone));
 }
 
 long si_mem_available(void)
@@ -4814,7 +4814,7 @@ static bool show_mem_node_skip(unsigned int flags, int nid, nodemask_t *nodemask
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
-static void show_migration_types(unsigned char type)
+static void show_migration_types(unsigned char type, struct printk_buffer *buf)
 {
 	static const char types[MIGRATE_TYPES] = {
 		[MIGRATE_UNMOVABLE]	= 'U',
@@ -4838,7 +4838,7 @@ static void show_migration_types(unsigned char type)
 	}
 
 	*p = '\0';
-	printk(KERN_CONT "(%s) ", tmp);
+	printk_buffered(buf, "(%s) ", tmp);
 }
 
 /*
@@ -4852,6 +4852,7 @@ static void show_migration_types(unsigned char type)
  */
 void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 {
+	struct printk_buffer *buf = get_printk_buffer();
 	unsigned long free_pcp = 0;
 	int cpu;
 	struct zone *zone;
@@ -4950,8 +4951,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		for_each_online_cpu(cpu)
 			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
 
-		show_node(zone);
-		printk(KERN_CONT
+		show_node(zone, buf);
+		printk_buffered(buf,
 			"%s"
 			" free:%lukB"
 			" min:%lukB"
@@ -4993,10 +4994,10 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(free_pcp),
 			K(this_cpu_read(zone->pageset->pcp.count)),
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
-		printk("lowmem_reserve[]:");
+		printk_buffered(buf, "lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
-			printk(KERN_CONT " %ld", zone->lowmem_reserve[i]);
-		printk(KERN_CONT "\n");
+			printk_buffered(buf, " %ld", zone->lowmem_reserve[i]);
+		printk_buffered(buf, "\n");
 	}
 
 	for_each_populated_zone(zone) {
@@ -5006,8 +5007,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 		if (show_mem_node_skip(filter, zone_to_nid(zone), nodemask))
 			continue;
-		show_node(zone);
-		printk(KERN_CONT "%s: ", zone->name);
+		show_node(zone, buf);
+		printk_buffered(buf, "%s: ", zone->name);
 
 		spin_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
@@ -5025,12 +5026,12 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
-			printk(KERN_CONT "%lu*%lukB ",
-			       nr[order], K(1UL) << order);
+			printk_buffered(buf, "%lu*%lukB ",
+					nr[order], K(1UL) << order);
 			if (nr[order])
-				show_migration_types(types[order]);
+				show_migration_types(types[order], buf);
 		}
-		printk(KERN_CONT "= %lukB\n", K(total));
+		printk_buffered(buf, "= %lukB\n", K(total));
 	}
 
 	hugetlb_show_meminfo();
@@ -5038,6 +5039,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 	printk("%ld total pagecache pages\n", global_node_page_state(NR_FILE_PAGES));
 
 	show_swap_cache_info();
+	put_printk_buffer(buf);
 }
 
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
-- 
1.8.3.1
