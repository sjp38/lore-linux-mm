Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C53516B0071
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 04:15:41 -0500 (EST)
Date: Wed, 1 Dec 2010 01:15:35 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Sudden and massive page cache eviction
Message-ID: <20101201091535.GD31793@hostway.ca>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com> <20101122161158.02699d10.akpm@linux-foundation.org> <1290501502.2390.7029.camel@nimitz> <AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com> <1290529171.2390.7994.camel@nimitz> <AANLkTikCn-YvORocXSJ1Z+ovYNMhKF7TaX=BHWKwrQup@mail.gmail.com> <AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com> <1290619929.10586.6.camel@nimitz> <AANLkTikT-svqverRLr7Mf6s-17VrOcP_BpyXFpDV=_7s@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikT-svqverRLr7Mf6s-17VrOcP_BpyXFpDV=_7s@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Peter Sch??ller <scode@spotify.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 25, 2010 at 04:33:01PM +0100, Peter Sch??ller wrote:

> > simple thing to do in any case. ??You can watch the entries in slabinfo
> > and see if any of the ones with sizes over 4096 bytes are getting used
> > often. ??You can also watch /proc/buddyinfo and see how often columns
> > other than the first couple are moving around.
> 
> I collected some information from
> /proc/{buddyinfo,meminfo,slabinfo,vmstat} and let it sit, polling
> approximately once per minute. I have some results correlated with
> another page eviction in graphs. The graph is here:
> 
>    http://files.spotify.com/memcut/memgraph-20101124.png
> 
> The last sudden eviction there occurred somewhere between 22:30 and
> 22:45. Some URL:s that can be compared for those periods:
> 
>    Before:
>    http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:39:30/vmstat
>    http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:39:30/buddyinfo
>    http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:39:30/meminfo
>    http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:39:30/slabinfo
> 
>    After:
>    http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:45:31/vmstat
>    http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:45:31/buddyinfo
>    http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:45:31/meminfo
>    http://files.spotify.com/memcut/memstat-20101124/2010-11-24T22:45:31/slabinfo

Disclaimer: I have no idea what I'm doing. :)

Your buddyinfo looks to be pretty low for order 3 and above, before and
after the sudden eviction, so my guess is that it's probably related to
the issues I'm seeing with fragmentation, but maybe not fighting between
zones, since you seem to have a larger Normal zone than DMA32.  (Not
sure, you didn't post /proc/zoneinfo).  Also, you seem to be on an
actual NUMA system, so other things are happening there, too.

If you have munin installed (it looks like you do), try enabling the
buddyinfo plugin available since munin 1.4.4.  It graphs the buddyinfo
data, so it could be lined up with the memory graphs (thanks Erik).

[snip]

> kmalloc increases:
> 
> -kmalloc-4096         301    328   4096    8    8 : tunables    0    0
>    0 : slabdata     41     41      0
> +kmalloc-4096         637    680   4096    8    8 : tunables    0    0
>    0 : slabdata     85     85      0
> -kmalloc-2048       18215  19696   2048   16    8 : tunables    0    0
>    0 : slabdata   1231   1231      0
> +kmalloc-2048       41908  51792   2048   16    8 : tunables    0    0
>    0 : slabdata   3237   3237      0
> -kmalloc-1024       85444  97280   1024   32    8 : tunables    0    0
>    0 : slabdata   3040   3040      0
> +kmalloc-1024      267031 327104   1024   32    8 : tunables    0    0
>    0 : slabdata  10222  10222      0

Note that all of the above are actually attempting order-3 allocations
first; see /sys/kernel/slab/kmalloc-1024/order, for instance.  The "8" is
means "8 pages per slab", which means order 3 is the attempted allocation
size.

I did the following on a system to test, but the free memory did not
actually improve.  It seems that even only order 1 allocations are enough
to reclaim too much order 0.  Even a "while true; sleep .01; done" caused
free memory to start increasing due to order 1 (task_struct allocation)
watermarks waking kswapd, while our other usual VM activity is happening.

#!/bin/bash

for i in /sys/kernel/slab/*/; do
        if [ `cat $i/object_size` -le 4096 ]; then
                echo 0 > $i/order
        else
                echo 1 > $i/order
        fi
done

But this is on another machine, without Mel's patch, and with 8 GB
memory, so a bigger Normal zone.

[snip]

> If my interpretation and understanding is correct, this indicates that
> for example, ~3000 to ~10000 3-order allocations resulting from 1 kb
> kmalloc():s. Meaning about 0.2 gig ( 7000*4*8*1024/1024/1024). Add the
> other ones and we get some more, but only a few hundred megs in total.
> 
> Going by the hypothesis that we are seeing the same thing as reported
> by Simon Kirby (I'll respond to that E-Mail separately), the total
> amount is (as far as I understand) not the important part, but the
> fact that we saw a non-trivial increase in 3-order allocations would
> perhaps be a consistent observation in that frequent 3-order
> allocations might be more likely to trigger the behavior Simon
> reports.

Try installing the "perf" tool.  It can be built from the kernel tree in
tools/perf, and then you usually can just copy the binary around.  You
can use it to trace the points which cause kswapd to wake up, which will
show which processes are doing it, the order, flags, etc.

Just before the eviction is about to happen (or whenever), try this:

perf record --event vmscan:mm_vmscan_wakeup_kswapd --filter 'order>=3' \
	--call-graph -a sleep 30

Then view the recorded events with "perf trace", which should spit out
something like this:

    lmtp-3531  [003] 432339.243851: mm_vmscan_wakeup_kswapd: nid=0 zid=2 order=3
    lmtp-3531  [003] 432339.243856: mm_vmscan_wakeup_kswapd: nid=0 zid=1 order=3

The process which woke kswapd may not be directly responsible for the
allocation as a network interrrupt or something could have happened on
top of it.  See "perf report", which is a bit dodgy at least for me, to
see the stack traces, which might make things clearer.  For example, my
traces show that even kswapd wakes kswapd sometimes, but it's because of
a trace like this:

    -      9.09%  kswapd0  [kernel.kallsyms]  [k] wakeup_kswapd
         wakeup_kswapd
         __alloc_pages_nodemask
         alloc_pages_current
         new_slab
         __slab_alloc
         __kmalloc_node_track_caller
         __alloc_skb
         __netdev_alloc_skb
         bnx2_poll_work
         bnx2_poll
         net_rx_action
         __do_softirq
         call_softirq
         do_softirq
         irq_exit
         do_IRQ
         ret_from_intr
         truncate_inode_pages
         proc_evict_inode
         evict
         iput
         dentry_iput
         d_kill
         __shrink_dcache_sb
         shrink_dcache_memory
         shrink_slab
         kswapd

Anyway, maybe you'll see some interesting traces.  If kswapd isn't waking
very often, you can also trace "kmem:mm_page_alloc" or similar (see "perf
list"), or try a smaller order or a longer sleep.

Cheers,

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
