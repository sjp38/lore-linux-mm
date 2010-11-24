Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7D4546B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 03:46:57 -0500 (EST)
Date: Wed, 24 Nov 2010 00:46:52 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101124084652.GC25170@hostway.ca>
References: <20101115195246.GB17387@hostway.ca> <20101122154419.ee0e09d2.akpm@linux-foundation.org> <1290501331.2390.7023.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290501331.2390.7023.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 12:35:31AM -0800, Dave Hansen wrote:

> I wish.  :)  The best thing to do is to watch stuff like /proc/vmstat
> along with its friends like /proc/{buddy,meminfo,slabinfo}.  Could you
> post some samples of those with some indication of where the bad
> behavior was seen?
> 
> I've definitely seen swapping in the face of lots of free memory, but
> only in cases where I was being a bit unfair about the numbers of
> hugetlbfs pages I was trying to reserve.

So, Dave and I spent quite some time today figuring out was going on
here.  Once load picked up during the day, kswapd actually never slept
until late in the afternoon.  During the evening now, it's still waking
up in bursts, and still keeping way too much memory free:

	http://0x.ca/sim/ref/2.6.36/memory_tonight.png

	(NOTE: we did swapoff -a to keep /dev/sda from overloading)

We have a much better idea on what is happening here, but more questions.

This x86_64 box has 4 GB of RAM; zones are set up as follows:

[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000001 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00130000
...
[    0.000000] On node 0 totalpages: 1047279  
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved   
[    0.000000]   DMA zone: 3943 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 832392 pages, LIFO batch:31
[    0.000000]   Normal zone: 2688 pages used for memmap
[    0.000000]   Normal zone: 193920 pages, LIFO batch:31

So, "Normal" is relatively small, and DMA32 contains most of the RAM. 
Watermarks from /proc/zoneinfo are:

Node 0, zone      DMA
        min      7
        low      8
        high     10
        protection: (0, 3251, 4009, 4009)
Node 0, zone    DMA32
        min      1640
        low      2050
        high     2460
        protection: (0, 0, 757, 757)
Node 0, zone   Normal
        min      382
        low      477
        high     573
        protection: (0, 0, 0, 0)

This box has a couple bnx2 NICs, which do about 60 Mbps each.  Jumbo
frames were disabled for now (to try to stop big order allocations), but
this did not stop atomic allocations of order 3 coming in, as found with:

perf record --event kmem:mm_page_alloc --filter 'order>=3' -a --call-graph -c 1 -a sleep 10
perf report

__alloc_pages_nodemask
alloc_pages_current
new_slab
__slab_alloc
__kmalloc_node_track_caller
__alloc_skb
__netdev_alloc_skb
bnx2_poll_work 

>From my reading of this, it seems like __alloc_skb uses kmalloc(), and
kmalloc uses the kmalloc slab unless (unlikely(size > SLUB_MAX_SIZE)),
where SLUB_MAX_SIZE is 2 * PAGE_SIZE, in which case kmalloc_large is
called which allocates pages directly.  This means that reception of
jumbo frames probably actually results in (consistent) smaller order
allocations!  Anyway, these GFP_ATOMIC allocations don't seem to be
failing, BUT...

Right after kswapd goes to sleep, we're left with DMA32 with 421k or so
free pages, and Normal with 20k or so free pages (about 1.8 GB free).

Immediately, zone Normal starts being used until it reaches about 468
pages free in order 0, nothing else free.  kswapd is not woken here,
but allocations just start coming from zone DMA32 instead.  While this
happens, the occasional order=3 allocations coming in via the slab from
__alloc_skb seem to be picking away at the available order=3 chunks. 
/proc/buddyinfo shows that there are 10k or so when it starts, so this
succeeds easily.

After a minute or so, available order-3 start reaching a lower number,
like 20 or so.  order-4 then starts dropping as it is split into order-3,
until it reaches 20 or so as well.  Then, order-3 hits 0, and kswapd is
woken.  When this occurs, there are still a few order-5, order-6, etc.,
available.  I presume the GFP_ATOMIC allocation can still split buddies
here, still making order-3 available without sleeping, because there is
no allocation failure message that I can see.

Here is a "while true; do sleep 1; grep -v 'DMA ' /proc/buddyinfo; done"
("DMA" zone is totally untouched, always, so excluded; white space
crushed to avoid wrapping), while it happens:

Node 0, zone      DMA      2      1      1      2      1     1 1 0 1 1 3
Node 0, zone    DMA32  25770  29441  14512  10426   1901   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
...
Node 0, zone    DMA32  23343  29405   6062   6478   1901   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  23187  29358   6047   5960   1901   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  23000  29372   6047   5411   1901   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  22714  29391   6076   4225   1901   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  22354  29459   6059   3178   1901   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  22202  29388   6035   2395   1901   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  21971  29411   6036   1032   1901   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  21514  29388   6019    433   1796   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  21334  29387   6019    240   1464   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  21237  29421   6052    216   1336   123 4 0 0 0 0
Node 0, zone   Normal    455      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  20968  29378   6020    244    751   123 4 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  20741  29383   6022    134    272   123 4 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  20476  29370   6024    117     48   116 4 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  20343  29369   6020    110     23    10 2 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  21592  30477   4856     22     10     4 2 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  24388  33261   1985      6     10     4 2 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  25358  34080   1068      0      4     4 2 0 0 0 0
Node 0, zone   Normal    453      1      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  75985  68954   5345     87      1     4 2 0 0 0 0
Node 0, zone   Normal  18249      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81117  71630  19261    429      3     4 2 0 0 0 0
Node 0, zone   Normal  17908      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81226  71299  21038    569     19     4 2 0 0 0 0
Node 0, zone   Normal  18559      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81347  71278  21068    640     19     4 2 0 0 0 0
Node 0, zone   Normal  17928     21      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81370  71237  21241   1073     29     4 2 0 0 0 0
Node 0, zone   Normal  18187      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81401  71237  21314   1139     29     4 2 0 0 0 0
Node 0, zone   Normal  16978      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81410  71239  21314   1145     29     4 2 0 0 0 0
Node 0, zone   Normal  18156      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81419  71232  21317   1160     30     4 2 0 0 0 0
Node 0, zone   Normal  17536      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81347  71144  21443   1160     31     4 2 0 0 0 0
Node 0, zone   Normal  18483      7      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81300  71059  21556   1178     38     4 2 0 0 0 0
Node 0, zone   Normal  18528      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81315  71042  21577   1180     39     4 2 0 0 0 0
Node 0, zone   Normal  18431      2      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81301  71002  21702   1202     39     4 2 0 0 0 0
Node 0, zone   Normal  18487      5      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81301  70998  21702   1202     39     4 2 0 0 0 0
Node 0, zone   Normal  18311      0      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81296  71025  21711   1208     45     4 2 0 0 0 0
Node 0, zone   Normal  17092      5      0      0      0     0 0 0 0 0 0
Node 0, zone    DMA32  81299  71023  21716   1226     45     4 2 0 0 0 0
Node 0, zone   Normal  18225     12      0      0      0     0 0 0 0 0 0

Running a perf record on the kswapd wakeup right when it happens shows:
perf record --event vmscan:mm_vmscan_wakeup_kswapd -a --call-graph -c 1 -a sleep 10
perf trace
         swapper-0     [002] 1323136.979119: mm_vmscan_wakeup_kswapd: nid=0 zid=2 order=3
         swapper-0     [002] 1323136.979131: mm_vmscan_wakeup_kswapd: nid=0 zid=1 order=3
            lmtp-20593 [003] 1323136.984066: mm_vmscan_wakeup_kswapd: nid=0 zid=2 order=3
            lmtp-20593 [003] 1323136.984079: mm_vmscan_wakeup_kswapd: nid=0 zid=1 order=3
         swapper-0     [001] 1323136.985511: mm_vmscan_wakeup_kswapd: nid=0 zid=2 order=3
         swapper-0     [001] 1323136.985515: mm_vmscan_wakeup_kswapd: nid=0 zid=1 order=3
            lmtp-20593 [003] 1323136.985673: mm_vmscan_wakeup_kswapd: nid=0 zid=2 order=3
            lmtp-20593 [003] 1323136.985675: mm_vmscan_wakeup_kswapd: nid=0 zid=1 order=3

This causes kswapd to throw out a bunch of stuff from Normal and from
DMA32, to try to get zone_watermark_ok() to be happy for order=3. 
However, we have a heavy read load from all of the email stored on SSDs
on this box, and kswapd ends up fighting to try to keep reclaiming the
allocations (mostly order-0).  During the whole day, it never wins -- the
allocations are faster.  At night, it wins after a minute or two.  The
fighting is happening in all of the lines after it awakes above.

slabs_scanned, kswapd_steal, kswapd_inodesteal (slowly),
kswapd_skip_congestion_wait, and pageoutrun go up in vmstat while kswapd
is running.  With the box up for 15 days, you can see it struggling on
pgscan_kswapd_normal (from /proc/vmstat):

pgfree 3329793080
pgactivate 643476431
pgdeactivate 155182710
pgfault 2649106647
pgmajfault 58157157
pgrefill_dma 0
pgrefill_dma32 19688032
pgrefill_normal 7600864
pgrefill_movable 0
pgsteal_dma 0
pgsteal_dma32 465191578
pgsteal_normal 651178518
pgsteal_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 768300403
pgscan_kswapd_normal 34614572907
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 2853983
pgscan_direct_normal 885799
pgscan_direct_movable 0
pginodesteal 191895
pgrotated 27290463

So, here are my questions.

Why do we care about order > 0 watermarks at all in the Normal zone? 
Wouldn't it make a lot more sense to just make the DMA32 zone the only
one we care about for larger-order allocations?  Or is this required for
the hugepage stuff?

The fact that so much stuff is evicted just because order-3 hits 0 is
crazy, especially when larger order pages are still free.  It seems like
we're trying to keep large orders free here.  Why?  Maybe things would be
better if kswapd does not reclaim at all unless the requested order is
empty _and_ all orders above are empty.  This would require hugepage
users to use CONFIG_COMPACT, and have _compaction_ occur the way the
watermark checks work now, but people without CONFIG_HUGETLB_PAGE could
just actually use the memory.  Would this work?

There is logic at the end of balance_pgdat() to give up balancing order>0
and just try another loop with order = 0 if sc.nr_reclaimed is <
SWAP_CLUSTER_MAX.  However, when this order=0 pass returns, the caller of
balance_pgdat(), kswapd(), gets true from sleeping_prematurely() and just
calls right back to balance_pgdat() again.  I think this is why this
logic doesn't seem to work here.

Is my assumption about GFP_ATOMIC order=3 working even when order 3 is
empty, but order>3 is not?  Regardless, shouldn't kswapd be woken before
order 3 is 0 since it may have nothing above order 3 to split from, thus
actually causing an allocation failure?  Does something else do this?

Ok, that's enough for now.. :)

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
