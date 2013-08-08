Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 4854C6B0032
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 05:21:13 -0400 (EDT)
Date: Thu, 8 Aug 2013 10:21:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130808092107.GZ2296@suse.de>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <20130807145828.GQ2296@suse.de>
 <20130807153743.GH715@cmpxchg.org>
 <20130808041623.GL1845@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130808041623.GL1845@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 08, 2013 at 12:16:23AM -0400, Johannes Weiner wrote:
> On Wed, Aug 07, 2013 at 11:37:43AM -0400, Johannes Weiner wrote:
> > On Wed, Aug 07, 2013 at 03:58:28PM +0100, Mel Gorman wrote:
> > > On Fri, Aug 02, 2013 at 11:37:26AM -0400, Johannes Weiner wrote:
> > > > @@ -352,6 +352,7 @@ struct zone {
> > > >  	 * free areas of different sizes
> > > >  	 */
> > > >  	spinlock_t		lock;
> > > > +	int			alloc_batch;
> > > >  	int                     all_unreclaimable; /* All pages pinned */
> > > >  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> > > >  	/* Set to true when the PG_migrate_skip bits should be cleared */
> > > 
> > > This adds a dirty cache line that is updated on every allocation even if
> > > it's from the per-cpu allocator. I am concerned that this will introduce
> > > noticable overhead in the allocator paths on large machines running
> > > allocator intensive workloads.
> > > 
> > > Would it be possible to move it into the per-cpu pageset? I understand
> > > that hte round-robin nature will then depend on what CPU is running and
> > > the performance characterisics will be different. There might even be an
> > > adverse workload that uses all the batches from all available CPUs until
> > > it is essentially the same problem but that would be a very worst case.
> > > I would hope that in general it would work without adding a big source of
> > > dirty cache line bouncing in the middle of the allocator.
> > 
> > Rik made the same suggestion.  The per-cpu error is one thing, the
> > problem is if the allocating task and kswapd run on the same CPU and
> > bypass the round-robin allocator completely, at which point we are
> > back to square one.  We'd have to reduce the per-cpu lists from a pool
> > to strict batching of frees and allocs without reuse in between.  That
> > might be doable, I'll give this another look.
> 
> I found a way.  It's still in the fast path, but I'm using vmstat
> percpu counters and can stick the update inside the same irq-safe
> section that does the other statistic updates.
> 

Ok, there will be some drift as those counters are only updated
periodically or if they overflow. Offhand I think your worst case is
being off by (nr_cpu_in_node * 127 - default_batch) but I doubt it'll be
noticable.

> On a two socket system with a small Normal zone, the results are as
> follows (unfair: mmotm without the fairness allocator, fairpcp: the
> fair allocator + the vmstat optimization):
> 
> ---
> 
> pft
>                              mmotm                 mmotm
>                             unfair               fairpcp
> User       1       0.0258 (  0.00%)       0.0254 (  1.40%)
> User       2       0.0264 (  0.00%)       0.0263 (  0.21%)
> User       3       0.0271 (  0.00%)       0.0277 ( -2.36%)
> User       4       0.0287 (  0.00%)       0.0280 (  2.33%)
> System     1       0.4904 (  0.00%)       0.4919 ( -0.29%)
> System     2       0.6141 (  0.00%)       0.6183 ( -0.68%)
> System     3       0.7346 (  0.00%)       0.7349 ( -0.04%)
> System     4       0.8700 (  0.00%)       0.8704 ( -0.05%)
> Elapsed    1       0.5164 (  0.00%)       0.5182 ( -0.35%)
> Elapsed    2       0.3213 (  0.00%)       0.3235 ( -0.67%)
> Elapsed    3       0.2800 (  0.00%)       0.2800 (  0.00%)
> Elapsed    4       0.2304 (  0.00%)       0.2303 (  0.01%)
> Faults/cpu 1  392724.3239 (  0.00%)  391558.5131 ( -0.30%)
> Faults/cpu 2  319357.5074 (  0.00%)  317577.8745 ( -0.56%)
> Faults/cpu 3  265703.1420 (  0.00%)  265668.3579 ( -0.01%)
> Faults/cpu 4  225516.0058 (  0.00%)  225474.1508 ( -0.02%)
> Faults/sec 1  392051.3043 (  0.00%)  390880.8201 ( -0.30%)
> Faults/sec 2  635360.7045 (  0.00%)  631819.1117 ( -0.56%)
> Faults/sec 3  725535.2889 (  0.00%)  725525.1280 ( -0.00%)
> Faults/sec 4  883307.5047 (  0.00%)  884026.1721 (  0.08%)
> 
> The overhead appears to be negligible, if not noise.
> 

Certainly small enough to not care considering what you're balancing
it against. Mind you, I do note that 4 clients is almost certainly not
enought to load a 2-socket machine. As the test is not memory intensive I
suspect that this test ran entirely within a single socket that would have
avoided the worst costs of dirty cache line bouncing anyway. As the number
of clients grow I predict that the results will become more variable as
it'll depend on scheduling.

>                mmotm       mmotm
>               unfair     fairpcp
> User           39.90       39.70
> System       1070.93     1069.50
> Elapsed       557.47      556.86
> 

And there is nothing suspicious in the system CPU time.

> <SNIP
>
> parallelio
>                                               mmotm                       mmotm
>                                              unfair                     fairpcp
> Ops memcachetest-0M              28012.00 (  0.00%)          27887.00 ( -0.45%)
> Ops memcachetest-1877M           22366.00 (  0.00%)          27878.00 ( 24.64%)
> Ops memcachetest-6257M           17770.00 (  0.00%)          27610.00 ( 55.37%)
> Ops memcachetest-10638M          17695.00 (  0.00%)          27350.00 ( 54.56%)
> Ops io-duration-0M                   0.00 (  0.00%)              0.00 (  0.00%)
> Ops io-duration-1877M               42.00 (  0.00%)             18.00 ( 57.14%)
> Ops io-duration-6257M               97.00 (  0.00%)             57.00 ( 41.24%)
> Ops io-duration-10638M             172.00 (  0.00%)            122.00 ( 29.07%)
> Ops swaptotal-0M                     0.00 (  0.00%)              0.00 (  0.00%)
> Ops swaptotal-1877M              93603.00 (  0.00%)              0.00 (  0.00%)
> Ops swaptotal-6257M             113986.00 (  0.00%)              0.00 (  0.00%)
> Ops swaptotal-10638M            178887.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-0M                        0.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-1877M                 20710.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-6257M                 18803.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-10638M                18755.00 (  0.00%)              0.00 (  0.00%)
> Ops minorfaults-0M              866454.00 (  0.00%)         844880.00 (  2.49%)
> Ops minorfaults-1877M           957107.00 (  0.00%)         845839.00 ( 11.63%)
> Ops minorfaults-6257M           971144.00 (  0.00%)         844778.00 ( 13.01%)
> Ops minorfaults-10638M         1066811.00 (  0.00%)         843628.00 ( 20.92%)
> Ops majorfaults-0M                  17.00 (  0.00%)              0.00 (  0.00%)
> Ops majorfaults-1877M             7636.00 (  0.00%)             37.00 ( 99.52%)
> Ops majorfaults-6257M             6487.00 (  0.00%)             37.00 ( 99.43%)
> Ops majorfaults-10638M            7337.00 (  0.00%)             37.00 ( 99.50%)
> 
> Mmtests reporting seems to have a bug calculating the percentage when
> the numbers drop to 0, see swap activity.  Those should all be 100%.
> 

Yep. I added a note to the TODO list which is now going sideways on the
sheet. Really need to knock a few items off it.

Still, they key takeaway is that it's no longer swapping and with swapins
in particular that is a big deal. I think it's interesting to note that
major faults are also very different, higher than what can be accounted
for by just the swapping. I wonder if the shared libraries and executable
binaries also getting thrown out and paged back in.

>                mmotm       mmotm
>               unfair     fairpcp
> User          592.67      695.15
> System       3130.44     3628.81
> Elapsed      7209.01     7206.46
> 

I'm not concerned about the high user time here because it's due to not
swapping (I guess). The higher system CPU is interesting and while I expect
it's just because the process is busy I must find the time to see *where*
that time is spent for this workload some day.

>                                  mmotm       mmotm
>                                 unfair     fairpcp
> Page Ins                       1401120       42656
> Page Outs                    163980516   153864256
> Swap Ins                        316033           0
> Swap Outs                      2528278           0
> Alloc DMA                            0           0
> Alloc DMA32                   59139091    51707843
> Alloc Normal                  10013244    16310697
> Alloc Movable                        0           0
> Direct pages scanned            210080      235649
> Kswapd pages scanned          61960450    50130023
> Kswapd pages reclaimed        34998767    35769908
> Direct pages reclaimed          179655      173478
> Kswapd efficiency                  56%         71%
> Kswapd velocity               8594.863    6956.262
> Direct efficiency                  85%         73%
> Direct velocity                 29.141      32.700
> Percentage direct scans             0%          0%
> Page writes by reclaim         3523501           1
> Page writes file                995223           1
> Page writes anon               2528278           0
> Page reclaim immediate            2195        9188
> Page rescued immediate               0           0
> Slabs scanned                     2048        1536
> Direct inode steals                  0           0
> Kswapd inode steals                  0           0
> Kswapd skipped wait                  0           0
> THP fault alloc                      3           3
> THP collapse alloc                4958        3026
> THP splits                          28          27
> THP fault fallback                   0           0
> THP collapse fail                    7          72
> Compaction stalls                   65          32
> Compaction success                  57          14
> Compaction failures                  8          18
> Page migrate success             39460        9899
> Page migrate failure                 0           0
> Compaction pages isolated        87140       22017
> Compaction migrate scanned       53494       12526
> Compaction free scanned         913691      396861
> Compaction cost                     42          10
> NUMA PTE updates                     0           0
> NUMA hint faults                     0           0
> NUMA hint local faults               0           0
> NUMA pages migrated                  0           0
> AutoNUMA cost                        0           0
> 

btw, mmtests has another bug and that "Page Ins" and "Page Outs" figures
are completely bogus. They are replaced with simply Major and Minor
faults in my current git tree. Otherwise, note the decrease in kswapd
velocity. That's nice but nowhere near as nice as the elimination of page
writes from reclaim context!

> ---
> 
> Patch on top of mmotm:
> 
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: page_alloc: use vmstats for fair zone allocation batching
> 
> Avoid dirtying the same cache line with every single page allocation
> by making the fair per-zone allocation batch a vmstat item, which will
> turn it into batched percpu counters on SMP.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

With this patch on top;

Acked-by: Mel Gorman <mgorman@suse.de>

Thanks very much Johannes, this is a great result. One note below

> @@ -2418,8 +2417,10 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 */
>  		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
>  			continue;
> -		zone->alloc_batch = high_wmark_pages(zone) -
> -			low_wmark_pages(zone);
> +		mod_zone_page_state(zone, NR_ALLOC_BATCH,
> +				    high_wmark_pages(zone) -
> +				    low_wmark_pages(zone) -
> +				    zone_page_state(zone, NR_ALLOC_BATCH));
>  	}
>  }
>  

Because of drift this is not exactly equivalent. The batch value will not
be reinitialised but instead adjusted by the delta but it's close enough
to not matter. Due to the size of the delta it will always spill over and
update the global counter so while the decrements from the alloc fast
paths are light, the reset is not. I see no way around this but if there
is still some noticable overhead then I bet this is where it is. It's
still a *LOT* better than what was there before and I think the cost is
justified this time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
