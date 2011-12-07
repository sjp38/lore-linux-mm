Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 39EA56B005D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 08:58:29 -0500 (EST)
Date: Wed, 7 Dec 2011 14:58:02 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/5] mm: exclude reserved pages from dirtyable memory
Message-ID: <20111207135802.GF12673@cmpxchg.org>
References: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
 <1322055258-3254-2-git-send-email-hannes@cmpxchg.org>
 <20111129162014.aa290174.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129162014.aa290174.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 29, 2011 at 04:20:14PM -0800, Andrew Morton wrote:
> On Wed, 23 Nov 2011 14:34:14 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > From: Johannes Weiner <jweiner@redhat.com>
> > 
> > The amount of dirtyable pages should not include the full number of
> > free pages: there is a number of reserved pages that the page
> > allocator and kswapd always try to keep free.
> > 
> > The closer (reclaimable pages - dirty pages) is to the number of
> > reserved pages, the more likely it becomes for reclaim to run into
> > dirty pages:
> > 
> >        +----------+ ---
> >        |   anon   |  |
> >        +----------+  |
> >        |          |  |
> >        |          |  -- dirty limit new    -- flusher new
> >        |   file   |  |                     |
> >        |          |  |                     |
> >        |          |  -- dirty limit old    -- flusher old
> >        |          |                        |
> >        +----------+                       --- reclaim
> >        | reserved |
> >        +----------+
> >        |  kernel  |
> >        +----------+
> > 
> > This patch introduces a per-zone dirty reserve that takes both the
> > lowmem reserve as well as the high watermark of the zone into account,
> > and a global sum of those per-zone values that is subtracted from the
> > global amount of dirtyable pages.  The lowmem reserve is unavailable
> > to page cache allocations and kswapd tries to keep the high watermark
> > free.  We don't want to end up in a situation where reclaim has to
> > clean pages in order to balance zones.
> > 
> > Not treating reserved pages as dirtyable on a global level is only a
> > conceptual fix.  In reality, dirty pages are not distributed equally
> > across zones and reclaim runs into dirty pages on a regular basis.
> > 
> > But it is important to get this right before tackling the problem on a
> > per-zone level, where the distance between reclaim and the dirty pages
> > is mostly much smaller in absolute numbers.
> > 
> > ...
> >
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -327,7 +327,8 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
> >  			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
> >  
> >  		x += zone_page_state(z, NR_FREE_PAGES) +
> > -		     zone_reclaimable_pages(z);
> > +		     zone_reclaimable_pages(z) -
> > +		     zone->dirty_balance_reserve;
> 
> Doesn't compile.  s/zone/z/.
> 
> Which makes me suspect it wasn't tested on a highmem box.  This is
> rather worrisome, as highmem machines tend to have acute and unique
> zone balancing issues.

You are right, so I ran fs_mark on an x86 machine with 8GB and a
32-bit kernel.

fs_mark  -S  0  -d  work-01  -d  work-02  -d  work-03  -d  work-04  -D  128  -N  128  -L  16  -n  512  -s  655360

This translates to 4 threads doing 16 iterations over a new set of 512
files each time, where each file is 640k in size, which adds up to 20G
of written data per run.  The results are gathered over 5 runs.  Data
are written to an ext4 on a standard consumer rotational disk.

The overall runtime for the loads were the same:

		seconds
		mean(stddev)
 vanilla:	242.061(0.953)
 patched:	242.726(1.714)

Allocation counts confirm that allocation placement does not change:

		pgalloc_dma		pgalloc_normal				pgalloc_high
		min|median|max	
 vanilla:	0.000|0.000|0.000	3733291.000|3742709.000|4034662.000	5189412.000|5202220.000|5208743.000
 patched:	0.000|0.000|0.000	3716148.000|3733269.000|4032205.000	5212301.000|5216834.000|5227756.000

Kswapd in both kernels did the same amount of work in each zone over
the course of the workload; direct reclaim was never invoked:

		pgscan_kswapd_dma	pgscan_kswapd_normal			pgscan_kswapd_high
		min|median|max
 vanilla:	0.000|0.000|0.000	109919.000|115773.000|117952.000	3235879.000|3246707.000|3255205.000
 patched:	0.000|0.000|0.000	104169.000|114845.000|117657.000	3241327.000|3246835.000|3257843.000

		pgsteal_dma		pgsteal_normal				pgsteal_high
		min|median|max
 vanilla:	0.000|0.000|0.000	109912.000|115766.000|117945.000	3235318.000|3246632.000|3255098.000
 patched:	0.000|0.000|0.000	104163.000|114839.000|117651.000	3240765.000|3246760.000|3257768.000

and the distribution of scans over time was equivalent, with no new
hickups or scan spikes:

		pgscan_kswapd_dma/s	pgscan_kswapd_normal/s			pgscan_kswapd_high/s
		min|median|max
 vanilla:	0.000|0.000|0.000	0.000|144.000|2100.000			0.000|15582.500|44916.000
 patched:	0.000|0.000|0.000	0.000|152.000|2058.000			0.000|15361.000|44453.000

		pgsteal_dma/s		pgsteal_normal/s			pgsteal_high/s
		min|median|max
 vanilla:	0.000|0.000|0.000	0.000|144.000|2094.000			0.000|15582.500|44916.000
 patched:	0.000|0.000|0.000	0.000|152.000|2058.000			0.000|15361.000|44453.000


				fs_mark 1G

The same fs_mark load was run on the system limited to 1G memory
(booted with mem=1G), to have a highmem zone that is much smaller
compared to the rest of the system.

		seconds
		mean(stddev)
 vanilla:	238.428(3.810)	
 patched:	241.392(0.221)	

In this case, allocation placement did shift slightly towards lower
zones, to protect the tiny highmem zone from being unreclaimable due
to dirty pages:

		pgalloc_dma			pgalloc_normal				pgalloc_high
		min|median|max
 vanilla:	20658.000|21863.000|23231.000	4017580.000|4023331.000|4038774.000	1057246.000|1076280.000|1083824.000
 patched:	25403.000|27679.000|28556.000	4163538.000|4172116.000|4179151.000	 917054.000| 922206.000| 933609.000

However, while there were in total more allocations in the DMA and
Normal zone, the utilization peaks of the zones individually were
actually reduced due to smoother distribution:

		DMA min nr_free_pages		Normal min nr_free_pages		HighMem min nr_free_pages
 vanilla:	1244.000			14819.000				432.000
 patched:	1337.000			14850.000				439.000

Keep in mind that the lower zones are only used more often for
allocation because they are providing dirtyable memory in this
scenario, i.e. they have space to spare.

With increasing lowmem usage for stuff that is truly lowmem, like
dcache and page tables, the amount of memory we consider dirtyable
(free pages + file pages) shrinks, so when highmem is not allowed to
take anymore dirty pages, we will not thrash on the lower zones:
either they have space left or the dirtiers are already being
throttled in balance_dirty_pages().

Reclaim numbers suggests that kswapd can easily keep up with the the
allocation frequency increase in the Normal zone.  But for DMA, it
looks like the unpatched kernel flooded the zone with dirty pages
every once in a while, making it ineligible for allocations until
those pages were cleaned.  Through better distribution, the patch
improves reclaim efficiency (reclaimed/scanned) from 32% to 100% for
DMA:

		pgscan_kswapd_dma		pgscan_kswapd_normal			pgscan_kswapd_high
		min|median|max
 vanilla:	39734.000|41248.000|41965.000	3692050.000|3696209.000|3716653.000	970411.000|987483.000|991469.000
 patched:	21204.000|23901.000|25141.000	3874782.000|3879125.000|3888302.000	793141.000|795631.000|803482.000

		pgsteal_dma			pgsteal_normal				pgsteal_high
		min|median|max
 vanilla:	12932.000|14044.000|16957.000	3692025.000|3696183.000|3716626.000	966050.000|987386.000|991405.000
 patched:	21204.000|23901.000|25141.000	3874771.000|3879095.000|3888284.000	792079.000|795572.000|803370.000

And the increased reclaim efficiency in the DMA zone indeed correlates
with the reduced likelyhood of reclaim running into dirty pages:

	DMA						Normal				Highmem
	nr_vmscan_write	nr_vmscan_immediate_reclaim

vanilla:
	26.0	19614.0					0.0	0.0			1174.0	0.0
	0.0	21737.0					0.0	1.0			0.0	0.0
	0.0	22101.0					0.0	0.0			0.0	0.0
        0.0	21906.0					0.0	0.0			0.0	0.0
	0.0	21880.0					0.0	0.0			0.0	0.0

patched:
	0.0	0.0					0.0	1.0			502.0	0.0
	0.0	0.0					0.0	0.0			0.0	0.0
	0.0	0.0					0.0	0.0			0.0	0.0
	0.0	0.0					0.0	0.0			0.0	0.0
	0.0	0.0					0.0	1.0			0.0	0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
