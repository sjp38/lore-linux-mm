Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 8642A6B0073
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:50:48 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2468561dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 00:50:47 -0700 (PDT)
Date: Fri, 8 Jun 2012 00:49:06 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
Message-ID: <20120608074906.GA27095@lizard>
References: <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
 <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
 <20120601122118.GA6128@lizard>
 <alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
 <4FCC7592.9030403@kernel.org>
 <20120604113811.GA4291@lizard>
 <4FCD14F1.1030105@gmail.com>
 <CAOJsxLHR4wSgT2hNfOB=X6ud0rXgYg+h7PTHzAZYCUdLs6Ktug@mail.gmail.com>
 <20120605083921.GA21745@lizard>
 <4FD014D7.6000605@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FD014D7.6000605@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Thu, Jun 07, 2012 at 11:41:27AM +0900, Minchan Kim wrote:
[...]
> How about this?

So, basically this is just another shrinker callback (well, it's
very close to), but only triggered after some magic index crosses
a threshold.

Some information beforehand: current ALMK is broken in the regard
that it does not do what it is supposed to do according to its
documentation. It uses shrinker notifiers (alike to your code), but
kernel calls shrinker when there is already pressure on the memory,
and ALMK's original idea was to start killing processes when there
is [yet] no pressure at all, so ALMK was supposed to act in advance,
e.g. "kill unneeded apps when there's say 64 MB free memory left,
irrespective of the current pressure". ALMK doesn't do this
currently, it only reacts to the shrinker.

So, the solution would be then two-fold:

1. Use your memory pressure notifications. They must be quite fast when
   we starting to feel the high pressure. (I see the you use
   zone_page_state() and friends, which is vm_stat, and it is updated
   very infrequently, but to get accurate notification we have to
   update it much more frequently, but this is very expensive. So
   KOSAKI and Christoph will complain. :-)
2. Plus use deferred timers to monitor /proc/vmstat, we don't have to
   be fast here. But I see Pekka and Leonid don't like it already,
   so we're stuck.

Thanks,

> It's totally pseudo code just I want to show my intention and even it's not a math.
> Totally we need more fine-grained some expression to standardize memory pressure.
> For it, we can use VM's several parameter, nr_scanned, nr_reclaimed, order, dirty page scanning ratio
> and so on. Also, we can aware of zone, node so we can pass lots of information to user space if they
> want it. For making lowmem notifier general, they are must, I think.
> We can have a plenty of tools for it.
> 
> And later as further step, we could replace it with memcg-aware after memcg reclaim work is
> totally unified with global page reclaim. Many memcg guys have tried it so I expect it works
> sooner or later but I'm not sure memcg really need it because memcg's goal is limit memory resource
> among several process groups. If some process feel bad about latency due to short of free memory
> and it's critical, I think it would be better to create new memcg group has tighter limit for
> latency and put the process into the group.
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eeb3bc9..eae3d2e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2323,6 +2323,32 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
>  }
>  
>  /*
> + * higher dirty pages, higher pressure
> + * higher nr_scanned, higher pressure
> + * higher nr_reclaimed, lower pressure
> + * higher unmapped pages, lower pressure
> + *
> + * index toward 0 implies memory pressure is heavy.
> + */
> +int lowmem_index(struct zone *zone, struct scan_control *sc)
> +{
> +       int pressure = (1000 * (sc->nr_scanned * (zone_page_state(zone, NR_FILE_DIRTY) 
> +                       * dirty_weight + 1) - sc->nr_reclaimed -
> +                       zone_unmapped_file_pages(zone))) /
> +                       zone_reclaimable_page(zone);
> +
> +       return 1000 - pressure;
> +}
> +
> +void lowmem_notifier(struct zone *zone, int index)
> +{
> +       if (lowmem_has_interested_zone(zone)) {
> +               if (index < sysctl_lowmem_threshold)
> +                       notify(numa_node_id(), zone, index);
> +       }
> +}
> +
> +/*
>   * For kswapd, balance_pgdat() will work across all this node's zones until
>   * they are all at high_wmark_pages(zone).
>   *
> @@ -2494,6 +2520,7 @@ loop_again:
>                                     !zone_watermark_ok_safe(zone, testorder,
>                                         high_wmark_pages(zone) + balance_gap,
>                                         end_zone, 0)) {
> +                               int index;
>                                 shrink_zone(zone, &sc);
>  
>                                 reclaim_state->reclaimed_slab = 0;
> @@ -2503,6 +2530,9 @@ loop_again:
>  
>                                 if (nr_slab == 0 && !zone_reclaimable(zone))
>                                         zone->all_unreclaimable = 1;
> +
> +                               index = lowmem_index(zone, &sc);
> +                               lowmem_notifier(zone, index);
> 
> > 
> 
> > p.s. http://git.infradead.org/users/cbou/ulmkd.git
> >      I haven't updated it for new vmevent changes, but still,
> >      its idea should be clear enough.
> > 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
