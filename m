Date: Fri, 5 Oct 2007 10:20:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove throttle_vm_writeout()
Message-Id: <20071005102005.134f07fa.akpm@linux-foundation.org>
In-Reply-To: <391587432.00784@ustc.edu.cn>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	<1191501626.22357.14.camel@twins>
	<E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu>
	<1191504186.22357.20.camel@twins>
	<E1IdR58-0002Fq-00@dorka.pomaz.szeredi.hu>
	<1191516427.5574.7.camel@lappy>
	<20071004104650.d158121f.akpm@linux-foundation.org>
	<391587432.00784@ustc.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: a.p.zijlstra@chello.nl, miklos@szeredi.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Oct 2007 20:30:28 +0800
Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:

> > commit c4e2d7ddde9693a4c05da7afd485db02c27a7a09
> > Author: akpm <akpm>
> > Date:   Sun Dec 22 01:07:33 2002 +0000
> > 
> >     [PATCH] Give kswapd writeback higher priority than pdflush
> >     
> >     The `low latency page reclaim' design works by preventing page
> >     allocators from blocking on request queues (and by preventing them from
> >     blocking against writeback of individual pages, but that is immaterial
> >     here).
> >     
> >     This has a problem under some situations.  pdflush (or a write(2)
> >     caller) could be saturating the queue with highmem pages.  This
> >     prevents anyone from writing back ZONE_NORMAL pages.  We end up doing
> >     enormous amounts of scenning.
> 
> Sorry, I cannot not understand it. We now have balanced aging between
> zones. So the page allocations are expected to distribute proportionally
> between ZONE_HIGHMEM and ZONE_NORMAL?

Sure, but we don't have one disk queue per disk per zone!  The queue is
shared by all the zones.  So if writeback from one zone has filled the
queue up, the kernel can't write back data from another zone.

(Well, it can, by blocking in get_request_wait(), but that causes long and
uncontrollable latencies).

> >     A test case is to mmap(MAP_SHARED) almost all of a 4G machine's memory,
> >     then kill the mmapping applications.  The machine instantly goes from
> >     0% of memory dirty to 95% or more.  pdflush kicks in and starts writing
> >     the least-recently-dirtied pages, which are all highmem.  The queue is
> >     congested so nobody will write back ZONE_NORMAL pages.  kswapd chews
> >     50% of the CPU scanning past dirty ZONE_NORMAL pages and page reclaim
> >     efficiency (pages_reclaimed/pages_scanned) falls to 2%.
> >     
> >     So this patch changes the policy for kswapd.  kswapd may use all of a
> >     request queue, and is prepared to block on request queues.
> >     
> >     What will now happen in the above scenario is:
> >     
> >     1: The page alloctor scans some pages, fails to reclaim enough
> >        memory and takes a nap in blk_congetion_wait().
> >     
> >     2: kswapd() will scan the ZONE_NORMAL LRU and will start writing
> >        back pages.  (These pages will be rotated to the tail of the
> >        inactive list at IO-completion interrupt time).
> >     
> >        This writeback will saturate the queue with ZONE_NORMAL pages.
> >        Conveniently, pdflush will avoid the congested queues.  So we end up
> >        writing the correct pages.
> >     
> >     In this test, kswapd CPU utilisation falls from 50% to 2%, page reclaim
> >     efficiency rises from 2% to 40% and things are generally a lot happier.
> 
> We may see the same problem and improvement in the absent of 'all
> writeback goes to one zone' assumption.
> 
> The problem could be:
> - dirty_thresh is exceeded, so balance_dirty_pages() starts syncing
>   data and quickly _congests_ the queue;

Or someone ran fsync(), or pdflush is writing back data because it exceeded
dirty_writeback_centisecs, etc.

> - dirty pages are slowly but continuously turned into clean pages by
>   balance_dirty_pages(), but they still stay in the same place in LRU;
> - the zones are mostly dirty/writeback pages, kswapd has a hard time
>   finding the randomly distributed clean pages;
> - kswapd cannot do the writeout because the queue is congested!
> 
> The improvement could be:
> - kswapd is now explicitly preferred to do the writeout;
> - the pages written by kswapd will be rotated and easy for kswapd to reclaim;
> - it becomes possible for kswapd to wait for the congested queue,
>   instead of doing the vmscan like mad.

Yeah.  In 2.4 and early 2.5, page-reclaim (both direct reclaim and kswapd,
iirc) would throttle by waiting on writeout of a particular page.  This was
a poor design, because writeback against a *particular* page can take
anywhere from one millisecond to thirty seconds to complete, depending upon
where the disk head is and all that stuff.

The critical change I made was to switch the throttling algorithm from
"wait for one page to get written" to "wait for _any_ page to get written".
 Becaue reclaim really doesn't care _which_ page got written: we want to
wake up and start scanning again when _any_ page got written.

That's what congestion_wait() does.

It is pretty crude.  It could be that writeback completed against pages which
aren't in the correct zone, or it could be that some other task went and
allocated the just-cleaned pages before this task can get running and
reclaim them, or it could be that the just-written-back pages weren't
reclaimable after all, etc.

It would take a mind-boggling amount of logic and locking to make all this
100% accurate and the need has never been demonstrated.  So page reclaim
presently should be viewed as a polling algorithm, where the rate of
polling is paced by the rate at which the IO system can retire writes.

> The congestion wait looks like a pretty natural way to throttle the kswapd.
> Instead of doing the vmscan at 1000MB/s and actually freeing pages at
> 60MB/s(about the write throughput), kswapd will be relaxed to do vmscan at
> maybe 150MB/s.

Something like that.

The critical numbers to watch are /proc/vmstat's *scan* and *steal*.  Look:

akpm:/usr/src/25> uptime
 10:08:14 up 10 days, 16:46, 15 users,  load average: 0.02, 0.05, 0.04
akpm:/usr/src/25> grep steal /proc/vmstat
pgsteal_dma 0
pgsteal_dma32 0
pgsteal_normal 0
pgsteal_high 0
pginodesteal 0
kswapd_steal 1218698
kswapd_inodesteal 266847
akpm:/usr/src/25> grep scan /proc/vmstat      
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 1246816
pgscan_kswapd_normal 0
pgscan_kswapd_high 0
pgscan_direct_dma 0
pgscan_direct_dma32 448
pgscan_direct_normal 0
pgscan_direct_high 0
slabs_scanned 2881664

Ignore kswapd_inodesteal and slabs_scanned.  We see that this machine has
scanned 1246816+448 pages and has reclaimed (stolen) 1218698 pages.  That's
a reclaim success rate of 97.7%, which is pretty damn good - this machine
is just a lightly-loaded 3GB desktop.

When testing reclaim, it is critical that this ratio be monitored (vmmon.c
from ext3-tools is a vmstat-like interface to /proc/vmstat).  If the
reclaim efficiency falls below, umm, 25% then things are getting into some
trouble.

Actually, 25% is still pretty good.  We scan 4 pages for each reclaimed
page, but the amount of wall time which that takes is vastly less than the
time to write one page, bearing in mind that these things tend to be seeky
as hell.  But still, keeping an eye on the reclaim efficiency is just your
basic starting point for working on page reclaim.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
