Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8686B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 21:18:08 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j124so36526575ith.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:18:08 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id w82si9687848itf.102.2016.07.27.18.18.06
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 18:18:07 -0700 (PDT)
Date: Thu, 28 Jul 2016 10:18:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: get_scan_count consider reclaimable lru pages
Message-ID: <20160728011847.GA6974@bbox>
References: <1469604588-6051-1-git-send-email-minchan@kernel.org>
 <1469604588-6051-2-git-send-email-minchan@kernel.org>
 <20160727142226.GA2693@suse.de>
MIME-Version: 1.0
In-Reply-To: <20160727142226.GA2693@suse.de>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 27, 2016 at 03:22:26PM +0100, Mel Gorman wrote:
> On Wed, Jul 27, 2016 at 04:29:48PM +0900, Minchan Kim wrote:
> > With node-lru, if there are enough reclaimable pages in highmem
> > but nothing in lowmem, VM try to shrink inactive list although
> > the requested zone is lowmem.
> >
> > The problem is that if the inactive list is full of highmem pages then a
> > direct reclaimer searching for a lowmem page waste CPU scanning uselessly.
> > It just burns out CPU.  Even, many direct reclaimers are stalled by
> > too_many_isolated if lots of parallel reclaimer are going on although
> > there are no reclaimable memory in inactive list.
> >
>
> The too_many_isolated point is interesting because the fact we
> congestion_wait in there is daft. Too many isolated LRU pages has nothing
> to do with congestion or dirty pages. More on that later

Agree.

>
> > To solve the issue, get_scan_count should consider zone-reclaimable lru
> > size in case of constrained-alloc rather than node-lru size so it should
> > not scan lru list if there is no reclaimable pages in lowmem area.
> >
> > Another optimization is to avoid too many stall in too_many_isolated loop
> > if there isn't any reclaimable page any more.
> >
>
> That should be split into a separate patch, particularly if
> too_many_isolated is altered to avoid congestion_wait.
>
> > This patch reduces hackbench elapsed time from 400sec to 50sec.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
>
> Incidentally, this does not apply to mmots (note mmots and not mmotm)
> due to other patches that have been picked up in the meantime. It needs
> to be rebased.

Will check it.

>
> I had trouble replicating your exact results. I do not know if this is
> because we used a different baseline (I had to revert patches and do
> some fixups to apply yours) or whether we have different versions of
> hackbench. The version I'm using uses 40 processes per group, how many
> does yours use?

My baseline was mmotm-2016-07-21-15-11 + "mm, vmscan: remove highmem_file_pages -fix"
The command I used is hackbench -l 1 -g 500 -P but the result is same
with the hackbench mmtest includes(hackbench 500 process 1).
Of course, default process is 40 per group so the command will create
task 2000 processes.
My i386 guest os has 8 processor and 2G memory and host 6 CPU with
3.2GHz.

>
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index d572b78..87d186f 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -805,7 +805,8 @@ static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
> >  #endif
> >  }
> >  
> > -extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
> > +extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru,
> > + int classzone);
> >  
>
> Use reclaim_idx as it's sc->reclaim_idx that is passed in. Lets not
> reintroduce any confusion between classzone_idx and reclaim_idx.
>
> >  #ifdef CONFIG_HAVE_MEMORY_PRESENT
> >  void memory_present(int nid, unsigned long start, unsigned long end);
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index f8ded2b..f553fd8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -234,12 +234,33 @@ bool pgdat_reclaimable(struct pglist_data *pgdat)
> >   pgdat_reclaimable_pages(pgdat) * 6;
> >  }
> >  
> > -unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
> > +/*
> > + * Return size of lru list zones[0..classzone_idx] if memcg is disabled.
> > + */
> > +unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru,
> > + int classzone_idx)
> >  {
> > + struct pglist_data *pgdat;
> > + unsigned long nr_pages, nr_zone_pages;
> > + int zid;
> > + struct zone *zone;
> > +
> >   if (!mem_cgroup_disabled())
> >   return mem_cgroup_get_lru_size(lruvec, lru);
> >  
> > - return node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
> > + pgdat = lruvec_pgdat(lruvec);
> > + nr_pages = node_page_state(pgdat, NR_LRU_BASE + lru);
> > +
> > + for (zid = classzone_idx + 1; zid < MAX_NR_ZONES; zid++) {
> > + zone = &pgdat->node_zones[zid];
> > + if (!populated_zone(zone))
> > + continue;
> > +
> > + nr_zone_pages = zone_page_state(zone, NR_ZONE_LRU_BASE + lru);
> > + nr_pages -= min(nr_pages, nr_zone_pages);
> > + }
> > +
> > + return nr_pages;
> >  }
> >  
> >  /*
>
> Ok.
>
> > @@ -1481,13 +1502,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >   total_skipped += nr_skipped[zid];
> >   }
> >  
> > - /*
> > - * Account skipped pages as a partial scan as the pgdat may be
> > - * close to unreclaimable. If the LRU list is empty, account
> > - * skipped pages as a full scan.
> > - */
> > - scan += list_empty(src) ? total_skipped : total_skipped >> 2;
> > -
> >   list_splice(&pages_skipped, src);
> >   }
> >   *nr_scanned = scan;
>
> It's not clear why this is removed. Minimally, there is a race between
> when lruvec_lru_size is checked and when the pages are isolated that can
> empty the LRU lists in the meantime. Furthermore, if the lists are small
> then it still makes sense to account for skipped pages as partial scans
> to ensure OOM detection happens.

I will revmoe the part because it's not related to the problem I am
addressing.

>
> > @@ -1652,6 +1666,30 @@ static int current_may_throttle(void)
> >   bdi_write_congested(current->backing_dev_info);
> >  }
> >  
> > +static bool inactive_reclaimable_pages(struct lruvec *lruvec,
> > + struct scan_control *sc, enum lru_list lru)
> > +{
> > + int zid;
> > + struct zone *zone;
> > + int file = is_file_lru(lru);
> > + struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> > +
> > + if (!global_reclaim(sc))
> > + return true;
> > +
> >
>
> When you rebase, it should be clear that this check can disappear.

Sure..

>
> > + for (zid = sc->reclaim_idx; zid >= 0; zid--) {
> > + zone = &pgdat->node_zones[zid];
> > + if (!populated_zone(zone))
> > + continue;
> > +
> > + if (zone_page_state_snapshot(zone, NR_ZONE_LRU_BASE +
> > + LRU_FILE * file) >= SWAP_CLUSTER_MAX)
> > + return true;
> > + }
> > +
> > + return false;
> > +}
> > +
> >  /*
> >   * shrink_inactive_list() is a helper for shrink_node().  It returns the number
> >   * of reclaimed pages
> > @@ -1674,12 +1712,23 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >   struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> >   struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> >  
> > + /*
> > + * Although get_scan_count tell us it's worth to scan, there
> > + * would be no reclaimalble pages in the list if parallel
> > + * reclaimers already isolated them.
> > + */
> > + if (!inactive_reclaimable_pages(lruvec, sc, lru))
> > + return 0;
> > +
> >   while (unlikely(too_many_isolated(pgdat, file, sc))) {
> >   congestion_wait(BLK_RW_ASYNC, HZ/10);
> >  
> >   /* We are about to die and free our memory. Return now. */
> >   if (fatal_signal_pending(current))
> >   return SWAP_CLUSTER_MAX;
> > +
> > + if (!inactive_reclaimable_pages(lruvec, sc, lru))
> > + return 0;
> >   }
> >  
> >   lru_add_drain();
>
> I think it makes sense to fix this loop first before putting that check
> in. I'll post a candidate patch below that arguably should be merged
> before this one.

I don't care which patch should be first but don't mind if you want.

>
> The rest looked ok but I haven't tested it in depth. I'm gathering a
> baseline set of results based on mmots at the moment and so should be
> ready when/if v2 of this patch arrives.
>
> I'd also like you to consider the following for applying first.

Will revmoe your recent version.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
