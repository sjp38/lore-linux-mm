Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9EBE06B4C04
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 03:36:42 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so11757092pgr.15
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 00:36:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h192sor8335663pgc.77.2018.11.28.00.36.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 00:36:40 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC PATCH] mm: update highest_memmap_pfn based on exact pfn
Date: Wed, 28 Nov 2018 16:36:34 +0800
Message-Id: <20181128083634.18515-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, akpm@linux-foundation.org, pasha.tatashin@oracle.com, mgorman@suse.de
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

When DEFERRED_STRUCT_PAGE_INIT is set, page struct will not be
initialized all at boot up. Some of them is postponed to defer stage.
While the global variable highest_memmap_pfn is still set to the highest
pfn at boot up, even some of them are not initialized.

This patch adjust this behavior by update highest_memmap_pfn with the
exact pfn during each iteration. Since each node has a defer thread,
introduce a spin lock to protect it.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/internal.h   | 8 ++++++++
 mm/memory.c     | 1 +
 mm/nommu.c      | 1 +
 mm/page_alloc.c | 9 ++++++---
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 6a57811ae47d..f9e19c7d9b0a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -79,6 +79,14 @@ static inline void set_page_refcounted(struct page *page)
 }
 
 extern unsigned long highest_memmap_pfn;
+extern spinlock_t highest_memmap_pfn_lock;
+static inline void update_highest_memmap_pfn(unsigned long end_pfn)
+{
+	spin_lock(&highest_memmap_pfn_lock);
+	if (highest_memmap_pfn < end_pfn - 1)
+		highest_memmap_pfn = end_pfn - 1;
+	spin_unlock(&highest_memmap_pfn_lock);
+}
 
 /*
  * Maximum number of reclaim retries without progress before the OOM
diff --git a/mm/memory.c b/mm/memory.c
index 4ad2d293ddc2..0cf9b88b51b7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -127,6 +127,7 @@ unsigned long zero_pfn __read_mostly;
 EXPORT_SYMBOL(zero_pfn);
 
 unsigned long highest_memmap_pfn __read_mostly;
+DEFINE_SPINLOCK(highest_memmap_pfn_lock);
 
 /*
  * CONFIG_MMU architectures set up ZERO_PAGE in their paging_init()
diff --git a/mm/nommu.c b/mm/nommu.c
index 749276beb109..610dc6e17ce5 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -48,6 +48,7 @@ struct page *mem_map;
 unsigned long max_mapnr;
 EXPORT_SYMBOL(max_mapnr);
 unsigned long highest_memmap_pfn;
+static DEFINE_SPINLOCK(highest_memmap_pfn_lock);
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
 int heap_stack_gap = 0;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ccc86df24f28..33bb339aaef8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1216,6 +1216,7 @@ static void __meminit init_reserved_page(unsigned long pfn)
 			break;
 	}
 	__init_single_page(pfn_to_page(pfn), pfn, zid, nid);
+	update_highest_memmap_pfn(pfn);
 }
 #else
 static inline void init_reserved_page(unsigned long pfn)
@@ -1540,6 +1541,7 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 		__init_single_page(page, pfn, zid, nid);
 		nr_pages++;
 	}
+	update_highest_memmap_pfn(pfn);
 	return (nr_pages);
 }
 
@@ -5491,9 +5493,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	unsigned long pfn, end_pfn = start_pfn + size;
 	struct page *page;
 
-	if (highest_memmap_pfn < end_pfn - 1)
-		highest_memmap_pfn = end_pfn - 1;
-
 #ifdef CONFIG_ZONE_DEVICE
 	/*
 	 * Honor reservation requested by the driver for this ZONE_DEVICE
@@ -5550,6 +5549,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			cond_resched();
 		}
 	}
+
+	update_highest_memmap_pfn(pfn);
 }
 
 #ifdef CONFIG_ZONE_DEVICE
@@ -5622,6 +5623,8 @@ void __ref memmap_init_zone_device(struct zone *zone,
 		}
 	}
 
+	update_highest_memmap_pfn(pfn);
+
 	pr_info("%s initialised, %lu pages in %ums\n", dev_name(pgmap->dev),
 		size, jiffies_to_msecs(jiffies - start));
 }
-- 
2.15.1
