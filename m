Date: Tue, 22 May 2007 23:38:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070523061702.GA9449@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705222332530.16738@schroedinger.engr.sgi.com>
References: <20070523030637.GC9255@wotan.suse.de>
 <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com>
 <20070523045938.GA29045@wotan.suse.de> <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com>
 <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007, Nick Piggin wrote:

> OK, so with a 64-bit UP ppc kernel, compiled for size, and without full
> size data structures, booting with mem=16M init=/bin/bash.

Hmmm.. Cannot do much on such a system. Try a 32 bit instead?
 
> After booting and mounting /proc, SLOB has 1140K free, SLUB has 748K
> free.

The following patch may help a little bit but not much. Hmmm... In order 
to reduce the space further we would also have to shrink all caches when 
boot is  complete. Elimination of useless caches also would be good. 
Do you really want to go into this deeper?


---
 include/linux/slub_def.h |    2 ++
 mm/slub.c                |    4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

Index: slub/include/linux/slub_def.h
===================================================================
--- slub.orig/include/linux/slub_def.h	2007-05-22 22:46:06.000000000 -0700
+++ slub/include/linux/slub_def.h	2007-05-22 23:31:18.000000000 -0700
@@ -17,7 +17,9 @@ struct kmem_cache_node {
 	unsigned long nr_partial;
 	atomic_long_t nr_slabs;
 	struct list_head partial;
+#ifdef CONFIG_SLUB_DEBUG
 	struct list_head full;
+#endif
 };
 
 /*
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-22 22:46:06.000000000 -0700
+++ slub/mm/slub.c	2007-05-22 23:32:00.000000000 -0700
@@ -183,7 +183,7 @@ static inline void ClearSlabDebug(struct
  * Mininum number of partial slabs. These will be left on the partial
  * lists even if they are empty. kmem_cache_shrink may reclaim them.
  */
-#define MIN_PARTIAL 2
+#define MIN_PARTIAL 0
 
 /*
  * Maximum number of desirable partial slabs.
@@ -1792,7 +1792,9 @@ static void init_kmem_cache_node(struct 
 	atomic_long_set(&n->nr_slabs, 0);
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
+#ifdef CONFIG_SLUB_DEBUG
 	INIT_LIST_HEAD(&n->full);
+#endif
 }
 
 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
