From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: swap prefetch improvements
Date: Sat, 12 May 2007 15:15:59 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705121446.04191.kernel@kolivas.org> <20070511220314.f7af1d31.pj@sgi.com>
In-Reply-To: <20070511220314.f7af1d31.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705121516.00070.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, mingo@elte.hu, ck@vds.kolivas.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 12 May 2007 15:03, Paul Jackson wrote:
> > Swap prefetch is not cpuset aware so make the config option depend on
> > !CPUSETS.
>
> Ok.
>
> Could you explain what it means to say "swap prefetch is not cpuset aware",
> or could you give a rough idea of what it would take to make it cpuset
> aware?

Hmm I'm not really sure what it takes to make it cpuset aware; it was Nick 
that pointed out that it was not, so I'm not sure and still going off your 
original recommendation that there was no need to make it cpuset aware but at 
least honour node placement (see below).

> I wouldn't go so far as to say that no one would ever want to prefetch and
> use cpusets at the same time, but I will grant that it's not a sufficiently
> important need that it should block a useful prefetch implementation on
> non-cpuset systems.

Thank you for agreeing on me there :)

> One case that would be useful, however, is to handle prefetch in the case
> that cpusets are configured into ones kernel, but one is not making any
> real use of them ('number_of_cpusets' <= 1).  That will actually be the
> most common case for the major distribution(s) that enable cpusets by
> default in their builds, for most arch's including the arch's popular
> on desktops.
>
> So what would it take to allow CONFIG'ing both prefetch and cpusets on,
> but having prefetch dynamically adapt to the presence of active cpuset
> usage, perhaps by basically shutting down if it can't easily do any
> better?  I could certainly entertain requests to callout to some
> prefetch routine from the cpuset code, at the critical points that
> cpusets transitioned in or out of active use.

It would be absolutely trivial to add a check for 'number_of_cpusets' <= 1 in 
the prefetch_enabled() function. Would you like that?

> Semi-separate issue -- is it just cpusets that aren't prefetch friendly,
> or is it also mm/mempolicy (mbind, set_mempolicy) as well?
>
> For that matter, even if neither mm/mempolicy nor cpusets are used, on
> systems with multiple memory nodes (not all memory equally distant from
> all CPUs, aka NUMA), could prefetch cause some sort of shuffling of
> memory placement, which might harm the performance of an HPC (High
> Performance Computing) application with carefully tuned memory
> placement.  Granted, this -is- getting to be a corner case.  Most HPC
> apps running on NUMA hardware are making at least some use of
> mm/mempolicy or cpusets.

It is numa aware to some degree. It stores the node id and when it starts 
prefetching it only prefetches to nodes that are suitable for prefetching to 
(based on a number of arbitrary freeness arguments I invented). It uses the 
original node id it came from by allocating a page via:
	alloc_pages_node(node, GFP_HIGHUSER & ~__GFP_WAIT, 0);
where "node" is the original node the swapped page came from.

Thanks for comments.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
