Subject: Re: [PATCH 6/6] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HZ2kU-0005xx-00@dorka.pomaz.szeredi.hu>
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
	 <20070403144224.709586192@taijtu.programming.kicks-ass.net>
	 <E1HZ1so-0005q8-00@dorka.pomaz.szeredi.hu> <1175681794.6483.43.camel@twins>
	 <E1HZ2kU-0005xx-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 13:01:01 +0200
Message-Id: <1175684461.6483.64.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 12:29 +0200, Miklos Szeredi wrote:
> > > I'm worried about two things:
> > > 
> > > 1) If the per-bdi threshold becomes smaller than the granularity of
> > >    the per-bdi stat (due to the per-CPU counters), then things will
> > >    break.  Shouldn't there be some sanity checking for the calculated
> > >    threshold?
> > 
> > I'm not sure what you're referring to.
> > 
> > void get_writeout_scale(struct backing_dev_info *bdi, int *scale, int *div)
> > {
> >         int bits = vm_cycle_shift - 1;
> >         unsigned long total = __global_bdi_stat(BDI_WRITEOUT_TOTAL);
> >         unsigned long cycle = 1UL << bits;
> >         unsigned long mask = cycle - 1;
> > 
> >         if (bdi_cap_writeback_dirty(bdi)) {
> >                 bdi_writeout_norm(bdi);
> >                 *scale = __bdi_stat(bdi, BDI_WRITEOUT);
> >         } else
> >                 *scale = 0;
> > 
> >         *div = cycle + (total & mask);
> > }
> > 
> > where cycle ~ vm_total_pages
> > scale can be a tad off due to overstep here:
> > 
> > void __inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
> > {
> >         struct bdi_per_cpu_data *pcd = &bdi->pcd[smp_processor_id()];
> >         s8 *p = pcd->bdi_stat_diff + item;
> > 
> >         (*p)++;
> > 
> >         if (unlikely(*p > pcd->stat_threshold)) {
> >                 int overstep = pcd->stat_threshold / 2;
> > 
> >                 bdi_stat_add(*p + overstep, bdi, item);
> >                 *p = -overstep;
> >         }
> > }
> > 
> > so it could be that: scale / cycle > 1
> > by a very small amount; however:
> 
> No, I'm worried about the case when scale is too small.  If the
> per-bdi threshold becomes smaller than stat_threshold, then things
> won't work, because dirty+writeback will never go below the threshold,
> possibly resulting in the deadlock we are trying to avoid.

/me goes refresh the deadlock details..

A writes to B; A exceeds the dirty limit but writeout is blocked by B
because the dirty limit is exceeded, right?

This cannot happen when we decouple the BDI dirty thresholds, even when
a threshold is 0.

A write to B; A exceeds A's limit and writes to B, B has limit of 0, the
1 dirty page gets written out (we gain ratio) and life goes on.

Right?

> BTW, the second argument of get_dirty_limits() doesn't seem to get
> used by the caller, or does it?

Correct, there are currently no in-tree users left. However I do use it
in a debug patch that shows bdi_dirty of total_dirty. We could remove
it, I have no strong feelings on it, I thought it might still be useful
for reporting or something.

> > > 2) The loop is sleeping in congestion_wait(WRITE), which seems wrong.
> > >    It may well be possible that none of the queues are congested, so
> > >    it will sleep the full .1 second.  But by that time the queue may
> > >    have become idle and is just sitting there doing nothing.  Maybe
> > >    there should be a per-bdi waitq, that is woken up, when the per-bdi
> > >    stats are updated.
> > 
> > Good point, .1 seconds is a lot of time.
> > 
> > I'll cook up something like that if nobody beats me to it :-)
> 
> I realized, that it's maybe worth storing last the threshold in the
> bdi as well, so that balance_dirty_pages() doesn't get woken up too
> many times unnecessarilty.  But I don't know...

There is already a ratelimit somewhere, but I've heard it suggested to
remove that....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
