Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDAA6B002C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:18:33 -0400 (EDT)
Date: Thu, 28 Apr 2011 18:18:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110428171826.GZ4658@suse.de>
References: <1303926637.2583.17.camel@mulgrave.site>
 <1303934716.2583.22.camel@mulgrave.site>
 <1303990590.2081.9.camel@lenovo>
 <20110428135228.GC1696@quack.suse.cz>
 <20110428140725.GX4658@suse.de>
 <1304000714.2598.0.camel@mulgrave.site>
 <20110428150827.GY4658@suse.de>
 <1304006499.2598.5.camel@mulgrave.site>
 <1304009438.2598.9.camel@mulgrave.site>
 <1304009778.2598.10.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1304009778.2598.10.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, Apr 28, 2011 at 11:56:17AM -0500, James Bottomley wrote:
> On Thu, 2011-04-28 at 11:50 -0500, James Bottomley wrote:
> > This is the output of perf record -g -a -f sleep 5
> > 
> > (hopefully the list won't choke)
> 
> Um, this one actually shows kswapd
> 
> James
> 
> ---
> 
> # Events: 6K cycles
> #
> # Overhead      Command        Shared Object                                   Symbol
> # ........  ...........  ...................  .......................................
> #
>     20.41%      kswapd0  [kernel.kallsyms]    [k] shrink_slab
>                 |
>                 --- shrink_slab
>                    |          
>                    |--99.91%-- kswapd
>                    |          kthread
>                    |          kernel_thread_helper
>                     --0.09%-- [...]
> 

Ok. I can't see how the patch "mm: vmscan: reclaim order-0 and use
compaction instead of lumpy reclaim" is related unless we are seeing
two problems that happen to manifest in a similar manner.

However, there were a number of changes made to dcache in particular
for 2.6.38. Specifically thinks like dentry_kill use trylock and is
happy to loop around if it fails to acquire anything. See things like
this for example;

static void try_prune_one_dentry(struct dentry *dentry)
        __releases(dentry->d_lock)
{
        struct dentry *parent;

        parent = dentry_kill(dentry, 0);
        /*
         * If dentry_kill returns NULL, we have nothing more to do.
         * if it returns the same dentry, trylocks failed. In either
         * case, just loop again.


If this in combination with many inodes being locked for whatever
reason (writeback locking them maybe?) is causing the shrinker to
return after zero progress, it could in turn cause kswapd to enter
into a loop for longish periods of time in shrink_slab here;

                while (total_scan >= SHRINK_BATCH) {
                        long this_scan = SHRINK_BATCH;
                        int shrink_ret;
                        int nr_before;

                        nr_before = (*shrinker->shrink)(shrinker, 0, gfp_mask);
                        shrink_ret = (*shrinker->shrink)(shrinker, this_scan,
                                                                gfp_mask);
                        if (shrink_ret == -1)
                                break;
                        if (shrink_ret < nr_before)
                                ret += nr_before - shrink_ret;
                        count_vm_events(SLABS_SCANNED, this_scan);
                        total_scan -= this_scan;

                        cond_resched();
                }

That would explain this trace.

>      9.98%      kswapd0  [kernel.kallsyms]    [k] shrink_zone
>                 |
>                 --- shrink_zone
>                    |          
>                    |--99.46%-- kswapd
>                    |          kthread
>                    |          kernel_thread_helper
>                    |          
>                     --0.54%-- kthread
>                               kernel_thread_helper
> 
>      7.70%      kswapd0  [kernel.kallsyms]    [k] kswapd
>                 |
>                 --- kswapd
>                     kthread
>                     kernel_thread_helper
> 
>      5.40%      kswapd0  [kernel.kallsyms]    [k] zone_watermark_ok_safe
>                 |
>                 --- zone_watermark_ok_safe
>                    |          
>                    |--72.66%-- kswapd
>                    |          kthread
>                    |          kernel_thread_helper
>                    |          
>                    |--20.88%-- sleeping_prematurely.part.12
>                    |          kswapd
>                    |          kthread
>                    |          kernel_thread_helper
>                    |          
>                     --6.46%-- kthread
>                               kernel_thread_helper
> 

We are also spending an astonishing amount of time in
sleeping_prematurely leading me to believe we are failing to balance the
zones and are continually under the min watermark for one of the zones.
We are never going to sleep because of this check;

                if (total_scanned && (priority < DEF_PRIORITY - 2)) {
                        if (has_under_min_watermark_zone)
                                count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
                        else
                                congestion_wait(BLK_RW_ASYNC, HZ/10);
                }

However, I think this is a secondary effect to the failure of shrinkers
to do their work. If slabs were being shrunk, one would expect us to
be getting over the min watermark.

>      4.25%      kswapd0  [kernel.kallsyms]    [k] do_raw_spin_lock
>                 |
>                 --- do_raw_spin_lock
>                    |          
>                    |--77.49%-- _raw_spin_lock
>                    |          |          
>                    |          |--51.85%-- mb_cache_shrink_fn
>                    |          |          shrink_slab
>                    |          |          kswapd
>                    |          |          kthread
>                    |          |          kernel_thread_helper
>                    |          |          
>                    |           --48.15%-- mem_cgroup_soft_limit_reclaim
>                    |                     kswapd
>                    |                     kthread
>                    |                     kernel_thread_helper
>                    |          

Way hey, cgroups are also in the mix. How jolly.

Is systemd a common element of the machines hitting this bug by any
chance?

The remaining traces seem to be follow-on damage related to the three
issues of "shrinkers are bust in some manner" causing "we are not
getting over the min watermark" and as a side-show "we are spending lots
of time doing something unspecified but unhelpful in cgroups".

> <SNIP>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
