Date: Tue, 31 Jul 2007 12:30:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070731013514.146ab1bb.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707311220200.6093@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
 <20070731015647.GC32468@localdomain> <Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
 <20070730192721.eb220a9d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
 <20070730214756.c4211678.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
 <20070730221736.ccf67c86.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com>
 <20070730225809.ed0a95ff.akpm@linux-foundation.org> <20070731082751.GB7316@localdomain>
 <20070731013514.146ab1bb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007, Andrew Morton wrote:

> On Tue, 31 Jul 2007 01:27:51 -0700 Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> 
> > >From what I can see with .21 and .22, going into reclaim is a problem rather
> > than reclaim efficiency itself. Sure, if unreclaimable pages are not on LRU
> > it would be good, but the main problem for my narrow eyes is going into
> > reclaim when there are no reclaimable pages, and the fact that benchmark
> > works as expected with the fixed arithmetic reinforces that impression.
> > 
> > What am I missing?
> 
> The fact that is there are "no reclaimable pages" then the all_unreclaimable
> logic should kick in and fix the problem.
> 
> Except zone_reclaim() fails to implement it.

It would be easy to implement. Just set a flag when we fail to reclaim. 
But this will result in the same deadbeat behavior like regular reclaim.

If the unmapped pages turn out to be unreclaimable then we essentially 
switch off zone reclaim and do small attempts at reclaim until we are 
successful. This may take a long time and we may be unsuccessful in 
detecting unmapped pages that become reclaimable.

Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2007-07-31 12:25:18.000000000 -0700
+++ linux-2.6/include/linux/mmzone.h	2007-07-31 12:25:41.000000000 -0700
@@ -234,6 +234,7 @@ struct zone {
 	unsigned long		nr_scan_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
+	int			unmapped_unreclaimable;	/* Unmapped pages are unreclaimable */
 
 	/* A count of how many reclaimers are scanning this zone */
 	atomic_t		reclaim_in_progress;
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-07-31 12:21:23.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-07-31 12:29:27.000000000 -0700
@@ -1759,7 +1759,10 @@ static int __zone_reclaim(struct zone *z
 			note_zone_scanning_priority(zone, priority);
 			nr_reclaimed += shrink_zone(priority, zone, &sc);
 			priority--;
-		} while (priority >= 0 && nr_reclaimed < nr_pages);
+		} while (priority >= 0 && nr_reclaimed < nr_pages &&
+			!zone->unmapped_unreclaimable);
+
+		zone->unmapped_reclaimable = nr_reclaimed > 0;
 	}
 
 	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
