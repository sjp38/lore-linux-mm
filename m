Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 68F606B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 02:29:07 -0400 (EDT)
Date: Fri, 1 May 2009 14:29:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch 20/22] vmscan: avoid multiplication overflow in
	shrink_zone()
Message-ID: <20090501062903.GA16746@localhost>
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org> <20090501012212.GA5848@localhost> <20090430194907.82b31565.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090430194907.82b31565.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 01, 2009 at 10:49:07AM +0800, Andrew Morton wrote:
> On Fri, 1 May 2009 09:22:12 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Fri, May 01, 2009 at 06:08:55AM +0800, Andrew Morton wrote:
> > > 
> > > Local variable `scan' can overflow on zones which are larger than
> > > 
> > > 	(2G * 4k) / 100 = 80GB.
> > > 
> > > Making it 64-bit on 64-bit will fix that up.
> > 
> > A side note about the "one HUGE scan inside shrink_zone":
> > 
> > Isn't this low level scan granularity way tooooo large?
> > 
> > It makes things a lot worse on memory pressure:
> > - the over reclaim, somehow workarounded by Rik's early bail out patch
> > - the throttle_vm_writeout()/congestion_wait() guards could work in a
> >   very sparse manner and hence is useless: imagine to stop and wait
> >   after shooting away every 1GB memory.
> > 
> > The long term fix could be to move the granularity control up to the
> > shrink_zones() level: there it can bail out early without hurting the
> > balanced zone aging.
> > 
> 
> I guess it could be bad in some circumstances.  Normally we'll bail out
> way early because (nr_reclaimed > swap_cluster_max) comes true.  If it
> _doesn't_ come true, we have little choice but to keep scanning.

Right. The main concern to the proposed granularity-control-lifting
could be the trickiness of scan code - the transition won't be easy. 
 
> The code is mystifying:
> 
> : 	for_each_evictable_lru(l) {
> : 		int file = is_file_lru(l);
> : 		unsigned long scan;
> : 
> : 		scan = zone_nr_pages(zone, sc, l);
> : 		if (priority) {
> : 			scan >>= priority;
> : 			scan = (scan * percent[file]) / 100;
> : 		}
> : 		if (scanning_global_lru(sc)) {
> : 			zone->lru[l].nr_scan += scan;
> 
> Here we increase zone->lru[l].nr_scan by (say) 1000000.
> 
> : 			nr[l] = zone->lru[l].nr_scan;
> 
> locally save away the number of pages to scan
> 
> : 			if (nr[l] >= swap_cluster_max)
> : 				zone->lru[l].nr_scan = 0;
> 
> err, wot?  This makes no sense at all afacit.
> 
> : 			else
> : 				nr[l] = 0;
> 
> ok, this is doing some batching I think.

Yes it's batching. So that smallish <32 scans can be delayed and batched.
I was lost too (twice! First time in 2006 and once more in 2009), so
we'd better add a simple comment to remind this fact 8-)

> : 		} else
> : 			nr[l] = scan;
> 
> so we didn't update the zone's nr_scan at all here.  But we display
> nr_scan in /proc/zoneinfo as "scanned".  So we're filing to inform
> userspace about scanning on this zone which is due to memcgroup
> constraints.  I think.

$ grep scanned /proc/zoneinfo
        scanned  0 (aa: 0 ia: 0 af: 0 if: 0)
        scanned  0 (aa: 0 ia: 0 af: 0 if: 0)
        scanned  0 (aa: 0 ia: 0 af: 0 if: 0)

They are all dynamic values. The first field shows pages scanned since
last reclaim - so a large value indicates we have trouble reclaiming
enough pages. The following 4 fields are the useless nr_scan[]s: they
never exceed SWAP_CLUSTER_MAX=32, and typically is 0 for large lists.

> : 	}
> : 
> : 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> : 					nr[LRU_INACTIVE_FILE]) {
> : 		for_each_evictable_lru(l) {
> : 			if (nr[l]) {
> : 				nr_to_scan = min(nr[l], swap_cluster_max);
> : 				nr[l] -= nr_to_scan;
> : 
> : 				nr_reclaimed += shrink_list(l, nr_to_scan,
> : 							    zone, sc, priority);
> : 			}
> : 		}
> : 		/*
> : 		 * On large memory systems, scan >> priority can become
> : 		 * really large. This is fine for the starting priority;
> : 		 * we want to put equal scanning pressure on each zone.
> : 		 * However, if the VM has a harder time of freeing pages,
> : 		 * with multiple processes reclaiming pages, the total
> : 		 * freeing target can get unreasonably large.
> : 		 */
> : 		if (nr_reclaimed > swap_cluster_max &&
> : 			priority < DEF_PRIORITY && !current_is_kswapd())
> : 			break;
> 
> here we bale out after scanning 32 pages, without updating ->nr_scan.

This is fine. Because (nr_reclaimed > swap_cluster_max) implies
(nr_scan = 0).  You know nr_scan is not regular accounting numbers ;-)

> : 	}
> 
> 
> What on earth does zone->lru[l].nr_scan mean after wending through all
> this stuff?
> 
> afacit this will muck up /proc/zoneinfo, but nothing else.

Exactly. nr_scan[] are not accounting numbers and means nothing to user.
They shall either be removed from /proc/zoneinfo, or be replaced with
meaningful _accumulated_ scan numbers.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
