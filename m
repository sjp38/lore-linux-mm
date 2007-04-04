In-reply-to: <1175681794.6483.43.camel@twins> (message from Peter Zijlstra on
	Wed, 04 Apr 2007 12:16:34 +0200)
Subject: Re: [PATCH 6/6] mm: per device dirty threshold
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
	 <20070403144224.709586192@taijtu.programming.kicks-ass.net>
	 <E1HZ1so-0005q8-00@dorka.pomaz.szeredi.hu> <1175681794.6483.43.camel@twins>
Message-Id: <E1HZ2kU-0005xx-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 04 Apr 2007 12:29:54 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: miklos@szeredi.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

> > I'm worried about two things:
> > 
> > 1) If the per-bdi threshold becomes smaller than the granularity of
> >    the per-bdi stat (due to the per-CPU counters), then things will
> >    break.  Shouldn't there be some sanity checking for the calculated
> >    threshold?
> 
> I'm not sure what you're referring to.
> 
> void get_writeout_scale(struct backing_dev_info *bdi, int *scale, int *div)
> {
>         int bits = vm_cycle_shift - 1;
>         unsigned long total = __global_bdi_stat(BDI_WRITEOUT_TOTAL);
>         unsigned long cycle = 1UL << bits;
>         unsigned long mask = cycle - 1;
> 
>         if (bdi_cap_writeback_dirty(bdi)) {
>                 bdi_writeout_norm(bdi);
>                 *scale = __bdi_stat(bdi, BDI_WRITEOUT);
>         } else
>                 *scale = 0;
> 
>         *div = cycle + (total & mask);
> }
> 
> where cycle ~ vm_total_pages
> scale can be a tad off due to overstep here:
> 
> void __inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
> {
>         struct bdi_per_cpu_data *pcd = &bdi->pcd[smp_processor_id()];
>         s8 *p = pcd->bdi_stat_diff + item;
> 
>         (*p)++;
> 
>         if (unlikely(*p > pcd->stat_threshold)) {
>                 int overstep = pcd->stat_threshold / 2;
> 
>                 bdi_stat_add(*p + overstep, bdi, item);
>                 *p = -overstep;
>         }
> }
> 
> so it could be that: scale / cycle > 1
> by a very small amount; however:

No, I'm worried about the case when scale is too small.  If the
per-bdi threshold becomes smaller than stat_threshold, then things
won't work, because dirty+writeback will never go below the threshold,
possibly resulting in the deadlock we are trying to avoid.

BTW, the second argument of get_dirty_limits() doesn't seem to get
used by the caller, or does it?

> here we clip to 'reserve' which is the total amount of dirty threshold
> not dirty by others.
> 
> > 2) The loop is sleeping in congestion_wait(WRITE), which seems wrong.
> >    It may well be possible that none of the queues are congested, so
> >    it will sleep the full .1 second.  But by that time the queue may
> >    have become idle and is just sitting there doing nothing.  Maybe
> >    there should be a per-bdi waitq, that is woken up, when the per-bdi
> >    stats are updated.
> 
> Good point, .1 seconds is a lot of time.
> 
> I'll cook up something like that if nobody beats me to it :-)

I realized, that it's maybe worth storing last the threshold in the
bdi as well, so that balance_dirty_pages() doesn't get woken up too
many times unnecessarilty.  But I don't know...

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
