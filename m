Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1096B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:14:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r28so9034122pgu.1
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 15:14:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a100-v6si140657pli.768.2018.01.30.15.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Jan 2018 15:14:22 -0800 (PST)
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] mm/swap_slots: use conditional compilation for swap_slots.c
Message-ID: <c2a47015-0b5a-d0d9-8bc7-9984c049df20@infradead.org>
Date: Tue, 30 Jan 2018 15:14:17 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

For mm/swap_slots.c, use the traditional Linux method of conditional
compilation and linking instead of always compiling it by using
#ifdef CONFIG_SWAP and #endif for the entire source file (excluding
header files).

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/Makefile     |    4 ++--
 mm/swap_slots.c |    4 ----
 2 files changed, 2 insertions(+), 6 deletions(-)

Tim, is there some reason that this is done as it currently is?

--- lnx-415.orig/mm/Makefile
+++ lnx-415/mm/Makefile
@@ -37,7 +37,7 @@ obj-y			:= filemap.o mempool.o oom_kill.
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
-			   compaction.o vmacache.o swap_slots.o \
+			   compaction.o vmacache.o \
 			   interval_tree.o list_lru.o workingset.o \
 			   debug.o $(mmu-y)
 
@@ -55,7 +55,7 @@ ifdef CONFIG_MMU
 endif
 obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
 
-obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
+obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o swap_slots.o
 obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_ZSWAP)	+= zswap.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
--- lnx-415.orig/mm/swap_slots.c
+++ lnx-415/mm/swap_slots.c
@@ -34,8 +34,6 @@
 #include <linux/mutex.h>
 #include <linux/mm.h>
 
-#ifdef CONFIG_SWAP
-
 static DEFINE_PER_CPU(struct swap_slots_cache, swp_slots);
 static bool	swap_slot_cache_active;
 bool	swap_slot_cache_enabled;
@@ -356,5 +354,3 @@ repeat:
 
 	return entry;
 }
-
-#endif /* CONFIG_SWAP */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
