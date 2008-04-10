Date: Thu, 10 Apr 2008 11:28:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/18] SLUB: Slab defrag core
In-Reply-To: <Pine.LNX.4.64.0804081441350.31620@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0804101126280.12367@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230226.847485429@sgi.com>
 <20080407231129.3c044ba1.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com>
 <20080408141135.de5a6350.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081416060.31490@schroedinger.engr.sgi.com>
 <20080408142505.4bfc7a4d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081441350.31620@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Here is a patch that gets rid of the timer and instead works with the 
fuzzy notion of the "objects" freed returned from the shrinkers. We add 
those up per node or globally and if they are greater than 100 we call 
into defrag.

Do we need to have an additional knob to set the level at which defrag 
triggers from reclaim? I just used 100.


Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2008-04-10 11:06:52.000000000 -0700
+++ linux-2.6/include/linux/mmzone.h	2008-04-10 11:08:04.000000000 -0700
@@ -263,6 +263,7 @@
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
+	unsigned long		slab_objects_freed; /* Since last slab defrag */
 	unsigned long		flags;		   /* zone flags, see below */
 
 	/* Zone statistics */
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-04-10 11:06:52.000000000 -0700
+++ linux-2.6/include/linux/slub_def.h	2008-04-10 11:08:04.000000000 -0700
@@ -91,7 +91,6 @@
 	struct kmem_cache_order_objects min;
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
-	unsigned long next_defrag;
 	void (*ctor)(struct kmem_cache *, void *);
 	/*
 	 * Called with slab lock held and interrupts disabled.
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-04-10 11:06:52.000000000 -0700
+++ linux-2.6/mm/slub.c	2008-04-10 11:08:04.000000000 -0700
@@ -2985,9 +2985,6 @@
 
 	list_for_each_entry(s, &slab_caches, list) {
 
-		if (time_before(jiffies, s->next_defrag))
-			continue;
-
 		/*
 		 * Defragmentable caches come first. If the slab cache is not
 		 * defragmentable then we can stop traversing the list.
@@ -3004,11 +3001,6 @@
 		} else
 			reclaimed = __kmem_cache_shrink(s, node, MAX_PARTIAL);
 
-		if (reclaimed)
-			s->next_defrag = jiffies + HZ / 10;
-		else
-			s->next_defrag = jiffies + HZ;
-
 		slabs += reclaimed;
 	}
 	up_read(&slub_lock);
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2008-04-10 11:06:52.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2008-04-10 11:24:02.000000000 -0700
@@ -234,8 +234,34 @@
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
-	if (ret && (gfp_mask & __GFP_FS))
-		kmem_cache_defrag(zone ? zone_to_nid(zone) : -1);
+
+	/*
+	 * "ret" doesnt really contain the freed object count. The shrinkers
+	 * fake it. Gotta go with what we are getting though.
+	 *
+	 * Handling of the freed object counter is also racy. If we get the
+	 * wrong counts then we may unnecessarily do a defrag pass or defer
+	 * one. "ret" is already faked. So this is just increasing
+	 * the already existing fuzziness to get some notion as to when
+	 * to initiate slab defrag which will hopefully be okay.
+	 */
+	if (zone) {
+		/* balance_pgdat running on a zone so we only scan one node */
+		zone->slab_objects_freed += ret;
+		if (zone->slab_objects_freed > 100 && (gfp_mask & __GFP_FS)) {
+			zone->slab_objects_freed = 0;
+			kmem_cache_defrag(zone_to_nid(zone));
+		}
+	} else {
+		static unsigned long global_objects_freed = 0;
+
+		/* Direct (and thus global) reclaim. Scan all nodes */
+		global_objects_freed += ret;
+		if (global_objects_freed > 100 && (gfp_mask & __GFP_FS)) {
+			global_objects_freed = 0;
+			kmem_cache_defrag(-1);
+		}
+	}
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
