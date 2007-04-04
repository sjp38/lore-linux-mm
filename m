Subject: Re: [PATCH 6/6] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HZ1so-0005q8-00@dorka.pomaz.szeredi.hu>
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
	 <20070403144224.709586192@taijtu.programming.kicks-ass.net>
	 <E1HZ1so-0005q8-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 12:16:34 +0200
Message-Id: <1175681794.6483.43.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 11:34 +0200, Miklos Szeredi wrote:
> > Scale writeback cache per backing device, proportional to its writeout speed.
> > 
> > akpm sayeth:
> > > Which problem are we trying to solve here?  afaik our two uppermost
> > > problems are:
> > > 
> > > a) Heavy write to queue A causes light writer to queue B to blok for a long
> > > time in balance_dirty_pages().  Even if the devices have the same speed.  
> > 
> > This one; esp when not the same speed. The - my usb stick makes my
> > computer suck - problem. But even on similar speed, the separation of
> > device should avoid blocking dev B when dev A is being throttled.
> > 
> > The writeout speed is measure dynamically, so when it doesn't have
> > anything to write out for a while its writeback cache size goes to 0.
> > 
> > Conversely, when starting up it will in the beginning act almost
> > synchronous but will quickly build up a 'fair' share of the writeback
> > cache.
> 
> I'm worried about two things:
> 
> 1) If the per-bdi threshold becomes smaller than the granularity of
>    the per-bdi stat (due to the per-CPU counters), then things will
>    break.  Shouldn't there be some sanity checking for the calculated
>    threshold?

I'm not sure what you're referring to.

void get_writeout_scale(struct backing_dev_info *bdi, int *scale, int *div)
{
        int bits = vm_cycle_shift - 1;
        unsigned long total = __global_bdi_stat(BDI_WRITEOUT_TOTAL);
        unsigned long cycle = 1UL << bits;
        unsigned long mask = cycle - 1;

        if (bdi_cap_writeback_dirty(bdi)) {
                bdi_writeout_norm(bdi);
                *scale = __bdi_stat(bdi, BDI_WRITEOUT);
        } else
                *scale = 0;

        *div = cycle + (total & mask);
}

where cycle ~ vm_total_pages
scale can be a tad off due to overstep here:

void __inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
{
        struct bdi_per_cpu_data *pcd = &bdi->pcd[smp_processor_id()];
        s8 *p = pcd->bdi_stat_diff + item;

        (*p)++;

        if (unlikely(*p > pcd->stat_threshold)) {
                int overstep = pcd->stat_threshold / 2;

                bdi_stat_add(*p + overstep, bdi, item);
                *p = -overstep;
        }
}

so it could be that: scale / cycle > 1
by a very small amount; however:

if (bdi) {
        long long tmp = dirty;
        long reserve;
        int scale, div;

        get_writeout_scale(bdi, &scale, &div);

        tmp *= scale;
        do_div(tmp, div);

        reserve = dirty -
                (global_bdi_stat(BDI_DIRTY) +
                 global_bdi_stat(BDI_WRITEBACK) +
                 global_bdi_stat(BDI_UNSTABLE));

        if (reserve < 0)
                reserve = 0;

        reserve += bdi_stat(bdi, BDI_DIRTY) +
                bdi_stat(bdi, BDI_WRITEBACK) +
                bdi_stat(bdi, BDI_UNSTABLE);

        *pbdi_dirty = min((long)tmp, reserve);
}

here we clip to 'reserve' which is the total amount of dirty threshold
not dirty by others.

> 2) The loop is sleeping in congestion_wait(WRITE), which seems wrong.
>    It may well be possible that none of the queues are congested, so
>    it will sleep the full .1 second.  But by that time the queue may
>    have become idle and is just sitting there doing nothing.  Maybe
>    there should be a per-bdi waitq, that is woken up, when the per-bdi
>    stats are updated.

Good point, .1 seconds is a lot of time.

I'll cook up something like that if nobody beats me to it :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
