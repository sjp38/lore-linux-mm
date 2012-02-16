Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 6CB496B0083
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 12:31:18 -0500 (EST)
Date: Thu, 16 Feb 2012 17:31:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120216173111.GA8555@suse.de>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <20120214101931.GB5938@suse.de>
 <20120214131812.GA17625@localhost>
 <20120214155124.GC5938@suse.de>
 <20120216095042.GC17597@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120216095042.GC17597@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Feb 16, 2012 at 05:50:42PM +0800, Wu Fengguang wrote:
> On Tue, Feb 14, 2012 at 03:51:24PM +0000, Mel Gorman wrote:
> > On Tue, Feb 14, 2012 at 09:18:12PM +0800, Wu Fengguang wrote:
> > > > For the OOM problem, a more reasonable stopgap might be to identify when
> > > > a process is scanning a memcg at high priority and encountered all
> > > > PageReclaim with no forward progress and to congestion_wait() if that
> > > > situation occurs. A preferable way would be to wait until the flusher
> > > > wakes up a waiter on PageReclaim pages to be written out because we want
> > > > to keep moving way from congestion_wait() if at all possible.
> > > 
> > > Good points! Below is the more serious page reclaim changes.
> > > 
> > > The dirty/writeback pages may often come close to each other in the
> > > LRU list, so the local test during a 32-page scan may still trigger
> > > reclaim waits unnecessarily.
> > 
> > Yes, this is particularly the case when writing back to USB. It is not
> > unusual that all dirty pages under writeback are backed by USB and at the
> > end of the LRU. Right now what happens is that reclaimers see higher CPU
> > usage as they scan over these pages uselessly. If the wrong choice is
> > made on how to throttle, we'll see yet more variants of the "system
> > responsiveness drops when writing to USB".
> 
> Yes, USB is an important case to support.  I'd imagine the heavy USB
> writes typically happen in desktops and run *outside* of any memcg.

I would expect it's common that USB writes are outside a memcg.

> So they'll typically take <= 20% memory in the zone. As long as we
> start the PG_reclaim throttling only when above the 20% dirty
> threshold (ie. on zone_dirty_ok()), the USB case should be safe.
> 

It's not just the USB writer, it's unrelated process that are allocating
memory at the same time the writing happens. What we want to avoid is a
situation where something like firefox or evolution or even gnome-terminal
is performing a small read and gets either

a) started for IO bandwidth and stalls (not the focus here obviously)
b) enter page reclaim, finds PG_reclaim pages from the USB write and stalls

It's (b) we need to watch out for. I accept that this patch is heading
in the right direction and that the tracepoint can be used to identify
processes get throttled unfairly. Before merging, it'd be nice to hear of
such a test and include details in the changelog similar to the test case
in https://bugzilla.kernel.org/show_bug.cgi?id=31142 (a bug that lasted a
*long* time as it turned out, fixes merged for 3.3 with sync-light migration).

> > > Some global information on the percent
> > > of dirty/writeback pages in the LRU list may help. Anyway the added
> > > tests should still be much better than no protection.
> > > 
> > 
> > You can tell how many dirty pages and writeback pages are in the zone
> > already.
> 
> Right. I changed the test to
> 
> +       if (nr_pgreclaim && nr_pgreclaim >= (nr_taken >> (DEF_PRIORITY-priority)) &&
> +           (!global_reclaim(sc) || !zone_dirty_ok(zone)))
> +               reclaim_wait(HZ/10);
> 
> And I'd prefer to use a higher threshold than the default 20% for the
> above zone_dirty_ok() test, so that when Johannes' zone dirty
> balancing does the job fine, PG_reclaim based page reclaim throttling
> won't happen at all.
> 

We'd also need to watch that we do not get throttled on small zones
like ZONE_DMA (which shouldn't happen but still). To detect this if
it happens, please consider including node and zone information in the
writeback_reclaim_wait tracepoint. The memcg people might want to be
able to see the memcg which I guess could be available

node=[NID|memcg]
NID if zone >=0
memcg if zone == -1

Which is hacky but avoids creating two tracepoints.

> > > A global wait queue and reclaim_wait() is introduced. The waiters will
> > > be wakeup when pages are rotated by end_page_writeback() or lru drain.
> > > 
> > > I have to say its effectiveness depends on the filesystem... ext4
> > > and btrfs do fluent IO completions, so reclaim_wait() works pretty
> > > well:
> > >               dd-14560 [017] ....  1360.894605: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=10000
> > >               dd-14560 [017] ....  1360.904456: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=8000
> > >               dd-14560 [017] ....  1360.908293: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
> > >               dd-14560 [017] ....  1360.923960: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=15000
> > >               dd-14560 [017] ....  1360.927810: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
> > >               dd-14560 [017] ....  1360.931656: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
> > >               dd-14560 [017] ....  1360.943503: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=10000
> > >               dd-14560 [017] ....  1360.953289: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=7000
> > >               dd-14560 [017] ....  1360.957177: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
> > >               dd-14560 [017] ....  1360.972949: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=15000
> > > 
> > > However XFS does IO completions in very large batches (there may be
> > > only several big IO completions in one second). So reclaim_wait()
> > > mostly end up waiting to the full HZ/10 timeout:
> > > 
> > >               dd-4177  [008] ....   866.367661: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [010] ....   866.567583: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [012] ....   866.767458: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [013] ....   866.867419: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [008] ....   867.167266: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [010] ....   867.367168: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [012] ....   867.818950: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [013] ....   867.918905: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [013] ....   867.971657: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=52000
> > >               dd-4177  [013] ....   867.971812: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=0
> > >               dd-4177  [008] ....   868.355700: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > >               dd-4177  [010] ....   868.700515: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
> > > 
> > 
> > And where people will get hit by regressions in this area is writing to
> > vfat and in more rare cases ntfs on USB stick.
> 
> vfat IO completions seem to lie somewhere between ext4 and xfs:
> 
>            <...>-46385 [010] .... 143570.714470: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
>            <...>-46385 [008] .... 143570.752391: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=12000
>            <...>-46385 [008] .... 143570.937327: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=52000
>            <...>-46385 [010] .... 143571.160252: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
>            <...>-46385 [011] .... 143571.286197: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
>            <...>-46385 [008] .... 143571.329644: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=15000
>            <...>-46385 [008] .... 143571.475433: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=18000
>            <...>-46385 [008] .... 143571.653461: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=52000
>            <...>-46385 [008] .... 143571.839949: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=56000
>            <...>-46385 [010] .... 143572.060816: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
>            <...>-46385 [011] .... 143572.185754: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
>            <...>-46385 [008] .... 143572.212522: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=1000
>            <...>-46385 [008] .... 143572.217825: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=2000
>            <...>-46385 [008] .... 143572.312395: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=91000
>            <...>-46385 [008] .... 143572.315122: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=1000
>            <...>-46385 [009] .... 143572.433630: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
>            <...>-46385 [010] .... 143572.534569: writeback_reclaim_wait: usec_timeout=100000 usec_delayed=100000
>  

Ok. It's interesting to note that we are stalling a lot there - roughly
30ms every second. As long as it's the writer, that's fine. If it's
firefox, it will create bug reports :)

> > > <SNIP>
> > > @@ -813,6 +815,10 @@ static unsigned long shrink_page_list(st
> > >  
> > >  		if (PageWriteback(page)) {
> > >  			nr_writeback++;
> > > +			if (PageReclaim(page))
> > > +				nr_pgreclaim++;
> > > +			else
> > > +				SetPageReclaim(page);
> > >  			/*
> > 
> > This check is unexpected. We already SetPageReclaim when queuing pages for
> > IO from reclaim context and if dirty pages are encountered during the LRU
> > scan that cannot be queued for IO. How often is it that nr_pgreclaim !=
> > nr_writeback and by how much do they differ?
> 
> Quite often, I suspect. The pageout writeback works do 1-8MB write
> around which may start I/O a bit earlier than the covered pages are
> encountered by page reclaim. ext4 forces 128MB write chunk size, which
> further increases the opportunities.
> 

Ok, thanks for the clarification. Stick a wee comment on it please.

> > >  			 * Synchronous reclaim cannot queue pages for
> > >  			 * writeback due to the possibility of stack overflow
> > > @@ -874,12 +880,15 @@ static unsigned long shrink_page_list(st
> > >  			nr_dirty++;
> > >  
> > >  			/*
> > > -			 * Only kswapd can writeback filesystem pages to
> > > -			 * avoid risk of stack overflow but do not writeback
> > > -			 * unless under significant pressure.
> > > +			 * run into the visited page again: we are scanning
> > > +			 * faster than the flusher can writeout dirty pages
> > >  			 */
> > 
> > which in itself is not an abnormal condition. We get into this situation
> > when writing to USB. Dirty throttling stops too much memory getting dirtied
> > but that does not mean we should throttle instead of reclaiming clean pages.
> > 
> > That's why I worry that if this is aimed at fixing a memcg problem, it
> > will have the impact of making interactive performance on normal systems
> > worse.
> 
> You are right. This patch only addresses the pageout I/O efficiency
> and dirty throttling problems for a fully dirtied LRU. Next step, I'll
> think about the interactive performance problem for a less dirtied LRU.
> 

Ok, thanks.

> > <SNIP>
> >
> > If the intention is to avoid memcg going OOM prematurely, the
> > nr_pgreclaim value needs to be treated at a higher level that records
> > how many PageReclaim pages were encountered. If no progress was made
> > because all the pages were PageReclaim, then throttle and return 1 to
> > the page allocator where it will retry the allocation without going OOM
> > after some pages have been cleaned and reclaimed.
>  
> Agreed in general, but changed to this test for now, which is made a
> bit more global wise with the use of zone_dirty_ok().
> 

Ok, sure. We know what to look out for and where unrelated regressions
might get introduced.

> memcg is ignored due to no dirty accounting (Greg has the patch though).
> And even zone_dirty_ok() may be inaccurate for the global reclaim, if
> some memcgs are skipped by the global reclaim by the memcg soft limit.
> 
> But anyway, it's a handy hack for now. I'm looking into some more
> radical changes to put most dirty/writeback pages into a standalone
> LRU list (in addition to your LRU_IMMEDIATE, which I think is a good
> idea) for addressing the clustered way they tend to lie in the
> inactive LRU list.
> 
> +       if (nr_pgreclaim && nr_pgreclaim >= (nr_taken >> (DEF_PRIORITY-priority)) &&
> +           (!global_reclaim(sc) || !zone_dirty_ok(zone)))
> +               reclaim_wait(HZ/10);
> 

This should make it harder to get stalled. Your tracepoint should help
us catch if it happens unnecessarily.

> ---
> Subject: writeback: introduce the pageout work
> Date: Thu Jul 29 14:41:19 CST 2010
> 
> This relays file pageout IOs to the flusher threads.
> 
> The ultimate target is to gracefully handle the LRU lists full of
> dirty/writeback pages.
> 

It would be worth mentioning in the changelog that this is much more
important now that page reclaim generally does not writeout filesystem-backed
pages.

> 1) I/O efficiency
> 
> The flusher will piggy back the nearby ~10ms worth of dirty pages for I/O.
> 
> This takes advantage of the time/spacial locality in most workloads: the
> nearby pages of one file are typically populated into the LRU at the same
> time, hence will likely be close to each other in the LRU list. Writing
> them in one shot helps clean more pages effectively for page reclaim.
> 
> 2) OOM avoidance and scan rate control
> 
> Typically we do LRU scan w/o rate control and quickly get enough clean
> pages for the LRU lists not full of dirty pages.
> 
> Or we can still get a number of freshly cleaned pages (moved to LRU tail
> by end_page_writeback()) when the queued pageout I/O is completed within
> tens of milli-seconds.
> 
> However if the LRU list is small and full of dirty pages, it can be
> quickly fully scanned and go OOM before the flusher manages to clean
> enough pages.
> 

It's worth pointing out here that generally this does not happen for global
reclaim which does dirty throttling but happens easily with memcg LRUs.

> A simple yet reliable scheme is employed to avoid OOM and keep scan rate
> in sync with the I/O rate:
> 
> 	if (PageReclaim(page))
> 		congestion_wait(HZ/10);
> 

This comment is stale now.

> PG_reclaim plays the key role. When dirty pages are encountered, we
> queue I/O for it,

This is misleading. The process that encounters the dirty page does
not queue the page for IO unless it is kswapd scanning at high priority
(currently anyway, you patch changes it). The process that finds the page
queues work for flusher threads that will queue the actual I/O for it at
some unknown time in the future.

> set PG_reclaim and put it back to the LRU head.
> So if PG_reclaim pages are encountered again, it means the dirty page
> has not yet been cleaned by the flusher after a full zone scan. It
> indicates we are scanning more fast than I/O and shall take a snap.
> 

This is also slightly misleading because the page can be encountered
after rescanning the inactive list, not necessarily a full zone scan but
it's a minor point.

> The runtime behavior on a fully dirtied small LRU list would be:
> It will start with a quick scan of the list, queuing all pages for I/O.
> Then the scan will be slowed down by the PG_reclaim pages *adaptively*
> to match the I/O bandwidth.
> 
> 3) writeback work coordinations
> 
> To avoid memory allocations at page reclaim, a mempool for struct
> wb_writeback_work is created.
> 
> wakeup_flusher_threads() is removed because it can easily delay the
> more oriented pageout works and even exhaust the mempool reservations.
> It's also found to not I/O efficient by frequently submitting writeback
> works with small ->nr_pages.
> 
> Background/periodic works will quit automatically, so as to clean the
> pages under reclaim ASAP. However for now the sync work can still block
> us for long time.
> 
> Jan Kara: limit the search scope. Note that the limited search and work
> pool is not a big problem: 1000 IOs under flight are typically more than
> enough to saturate the disk. And the overheads of searching in the work
> list didn't even show up in the perf report.
> 
> 4) test case
> 
> Run 2 dd tasks in a 100MB memcg (a very handy test case from Greg Thelen):
> 
> 	mkdir /cgroup/x
> 	echo 100M > /cgroup/x/memory.limit_in_bytes
> 	echo $$ > /cgroup/x/tasks
> 
> 	for i in `seq 2`
> 	do
> 		dd if=/dev/zero of=/fs/f$i bs=1k count=1M &
> 	done
> 
> Before patch, the dd tasks are quickly OOM killed.
> After patch, they run well with reasonably good performance and overheads:
> 
> 1073741824 bytes (1.1 GB) copied, 22.2196 s, 48.3 MB/s
> 1073741824 bytes (1.1 GB) copied, 22.4675 s, 47.8 MB/s
> 
> iostat -kx 1
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
> sda               0.00     0.00    0.00  178.00     0.00 89568.00  1006.38    74.35  417.71   4.80  85.40
> sda               0.00     2.00    0.00  191.00     0.00 94428.00   988.77    53.34  219.03   4.34  82.90
> sda               0.00    20.00    0.00  196.00     0.00 97712.00   997.06    71.11  337.45   4.77  93.50
> sda               0.00     5.00    0.00  175.00     0.00 84648.00   967.41    54.03  316.44   5.06  88.60
> sda               0.00     0.00    0.00  186.00     0.00 92432.00   993.89    56.22  267.54   5.38 100.00
> sda               0.00     1.00    0.00  183.00     0.00 90156.00   985.31    37.99  325.55   4.33  79.20
> sda               0.00     0.00    0.00  175.00     0.00 88692.00  1013.62    48.70  218.43   4.69  82.10
> sda               0.00     0.00    0.00  196.00     0.00 97528.00   995.18    43.38  236.87   5.10 100.00
> sda               0.00     0.00    0.00  179.00     0.00 88648.00   990.48    45.83  285.43   5.59 100.00
> sda               0.00     0.00    0.00  178.00     0.00 88500.00   994.38    28.28  158.89   4.99  88.80
> sda               0.00     0.00    0.00  194.00     0.00 95852.00   988.16    32.58  167.39   5.15 100.00
> sda               0.00     2.00    0.00  215.00     0.00 105996.00   986.01    41.72  201.43   4.65 100.00
> sda               0.00     4.00    0.00  173.00     0.00 84332.00   974.94    50.48  260.23   5.76  99.60
> sda               0.00     0.00    0.00  182.00     0.00 90312.00   992.44    36.83  212.07   5.49 100.00
> sda               0.00     8.00    0.00  195.00     0.00 95940.50   984.01    50.18  221.06   5.13 100.00
> sda               0.00     1.00    0.00  220.00     0.00 108852.00   989.56    40.99  202.68   4.55 100.00
> sda               0.00     2.00    0.00  161.00     0.00 80384.00   998.56    37.19  268.49   6.21 100.00
> sda               0.00     4.00    0.00  182.00     0.00 90830.00   998.13    50.58  239.77   5.49 100.00
> sda               0.00     0.00    0.00  197.00     0.00 94877.00   963.22    36.68  196.79   5.08 100.00
> 
> avg-cpu:  %user   %nice %system %iowait  %steal   %idle
>            0.25    0.00   15.08   33.92    0.00   50.75
>            0.25    0.00   14.54   35.09    0.00   50.13
>            0.50    0.00   13.57   32.41    0.00   53.52
>            0.50    0.00   11.28   36.84    0.00   51.38
>            0.50    0.00   15.75   32.00    0.00   51.75
>            0.50    0.00   10.50   34.00    0.00   55.00
>            0.50    0.00   17.63   27.46    0.00   54.41
>            0.50    0.00   15.08   30.90    0.00   53.52
>            0.50    0.00   11.28   32.83    0.00   55.39
>            0.75    0.00   16.79   26.82    0.00   55.64
>            0.50    0.00   16.08   29.15    0.00   54.27
>            0.50    0.00   13.50   30.50    0.00   55.50
>            0.50    0.00   14.32   35.18    0.00   50.00
>            0.50    0.00   12.06   33.92    0.00   53.52
>            0.50    0.00   17.29   30.58    0.00   51.63
>            0.50    0.00   15.08   29.65    0.00   54.77
>            0.50    0.00   12.53   29.32    0.00   57.64
>            0.50    0.00   15.29   31.83    0.00   52.38
> 
> The global dd numbers for comparison:
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
> sda               0.00     0.00    0.00  189.00     0.00 95752.00  1013.25   143.09  684.48   5.29 100.00
> sda               0.00     0.00    0.00  208.00     0.00 105480.00  1014.23   143.06  733.29   4.81 100.00
> sda               0.00     0.00    0.00  161.00     0.00 81924.00  1017.69   141.71  757.79   6.21 100.00
> sda               0.00     0.00    0.00  217.00     0.00 109580.00  1009.95   143.09  749.55   4.61 100.10
> sda               0.00     0.00    0.00  187.00     0.00 94728.00  1013.13   144.31  773.67   5.35 100.00
> sda               0.00     0.00    0.00  189.00     0.00 95752.00  1013.25   144.14  742.00   5.29 100.00
> sda               0.00     0.00    0.00  177.00     0.00 90032.00  1017.31   143.32  656.59   5.65 100.00
> sda               0.00     0.00    0.00  215.00     0.00 108640.00  1010.60   142.90  817.54   4.65 100.00
> sda               0.00     2.00    0.00  166.00     0.00 83858.00  1010.34   143.64  808.61   6.02 100.00
> sda               0.00     0.00    0.00  186.00     0.00 92813.00   997.99   141.18  736.95   5.38 100.00
> sda               0.00     0.00    0.00  206.00     0.00 104456.00  1014.14   146.27  729.33   4.85 100.00
> sda               0.00     0.00    0.00  213.00     0.00 107024.00  1004.92   143.25  705.70   4.69 100.00
> sda               0.00     0.00    0.00  188.00     0.00 95748.00  1018.60   141.82  764.78   5.32 100.00
> 
> avg-cpu:  %user   %nice %system %iowait  %steal   %idle
>            0.51    0.00   11.22   52.30    0.00   35.97
>            0.25    0.00   10.15   52.54    0.00   37.06
>            0.25    0.00    5.01   56.64    0.00   38.10
>            0.51    0.00   15.15   43.94    0.00   40.40
>            0.25    0.00   12.12   48.23    0.00   39.39
>            0.51    0.00   11.20   53.94    0.00   34.35
>            0.26    0.00    9.72   51.41    0.00   38.62
>            0.76    0.00    9.62   50.63    0.00   38.99
>            0.51    0.00   10.46   53.32    0.00   35.71
>            0.51    0.00    9.41   51.91    0.00   38.17
>            0.25    0.00   10.69   49.62    0.00   39.44
>            0.51    0.00   12.21   52.67    0.00   34.61
>            0.51    0.00   11.45   53.18    0.00   34.86
> 
> XXX: commit NFS unstable pages via write_inode()
> XXX: the added congestion_wait() may be undesirable in some situations
> 

This second XXX may also not be redundant.

> CC: Jan Kara <jack@suse.cz>
> CC: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> CC: Greg Thelen <gthelen@google.com>
> CC: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c                |  169 ++++++++++++++++++++++++++++-
>  include/linux/backing-dev.h      |    2 
>  include/linux/writeback.h        |    4 
>  include/trace/events/writeback.h |   19 ++-
>  mm/backing-dev.c                 |   35 ++++++
>  mm/swap.c                        |    1 
>  mm/vmscan.c                      |   32 +++--
>  7 files changed, 245 insertions(+), 17 deletions(-)
> 
> - move congestion_wait() out of the page lock: it's blocking btrfs lock_delalloc_pages()
> 
> --- linux.orig/include/linux/backing-dev.h	2012-02-14 20:11:21.000000000 +0800
> +++ linux/include/linux/backing-dev.h	2012-02-15 12:34:24.000000000 +0800
> @@ -304,6 +304,8 @@ void clear_bdi_congested(struct backing_
>  void set_bdi_congested(struct backing_dev_info *bdi, int sync);
>  long congestion_wait(int sync, long timeout);
>  long wait_iff_congested(struct zone *zone, int sync, long timeout);
> +long reclaim_wait(long timeout);
> +void reclaim_rotated(void);
>  
>  static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
>  {
> --- linux.orig/mm/backing-dev.c	2012-02-14 20:11:21.000000000 +0800
> +++ linux/mm/backing-dev.c	2012-02-15 12:34:19.000000000 +0800
> @@ -873,3 +873,38 @@ out:
>  	return ret;
>  }
>  EXPORT_SYMBOL(wait_iff_congested);
> +
> +static DECLARE_WAIT_QUEUE_HEAD(reclaim_wqh);
> +

Should this be declared on a per-NUMA node basis to avoid throttling on one
node being woken up by activity on an unrelated node?  reclaim_rorated()
is called from a context that has a page so looking up the waitqueue would
be easy. Grep for place that initialise kswapd_wait and the initialisation
code will be easier although watch that if a node is hot-removed that
the queue is woken.

> +/**
> + * reclaim_wait - wait for some pages being rotated to the LRU tail
> + * @timeout: timeout in jiffies
> + *
> + * Wait until @timeout, or when some (typically PG_reclaim under writeback)
> + * pages rotated to the LRU so that page reclaim can make progress.
> + */
> +long reclaim_wait(long timeout)
> +{
> +	long ret;
> +	unsigned long start = jiffies;
> +	DEFINE_WAIT(wait);
> +
> +	prepare_to_wait(&reclaim_wqh, &wait, TASK_KILLABLE);
> +	ret = io_schedule_timeout(timeout);
> +	finish_wait(&reclaim_wqh, &wait);
> +
> +	trace_writeback_reclaim_wait(jiffies_to_usecs(timeout),
> +				     jiffies_to_usecs(jiffies - start));
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(reclaim_wait);
> +

Why do we export this? Only vmscan.c is calling it and I'm scratching my
head trying to figure out why a kernel module would want to call it.

> +void reclaim_rotated()
> +{

style nit

void reclaim_rotated(void)

> +	wait_queue_head_t *wqh = &reclaim_wqh;
> +
> +	if (waitqueue_active(wqh))
> +		wake_up(wqh);
> +}
> +
> --- linux.orig/mm/swap.c	2012-02-14 20:11:21.000000000 +0800
> +++ linux/mm/swap.c	2012-02-15 12:27:35.000000000 +0800
> @@ -253,6 +253,7 @@ static void pagevec_move_tail(struct pag
>  
>  	pagevec_lru_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
>  	__count_vm_events(PGROTATED, pgmoved);
> +	reclaim_rotated();
>  }
>  
>  /*
> --- linux.orig/mm/vmscan.c	2012-02-14 20:11:21.000000000 +0800
> +++ linux/mm/vmscan.c	2012-02-16 17:23:17.000000000 +0800
> @@ -767,7 +767,8 @@ static unsigned long shrink_page_list(st
>  				      struct scan_control *sc,
>  				      int priority,
>  				      unsigned long *ret_nr_dirty,
> -				      unsigned long *ret_nr_writeback)
> +				      unsigned long *ret_nr_writeback,
> +				      unsigned long *ret_nr_pgreclaim)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> @@ -776,6 +777,7 @@ static unsigned long shrink_page_list(st
>  	unsigned long nr_congested = 0;
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_writeback = 0;
> +	unsigned long nr_pgreclaim = 0;
>  
>  	cond_resched();
>  
> @@ -813,6 +815,10 @@ static unsigned long shrink_page_list(st
>  
>  		if (PageWriteback(page)) {
>  			nr_writeback++;
> +			if (PageReclaim(page))
> +				nr_pgreclaim++;
> +			else
> +				SetPageReclaim(page);
>  			/*
>  			 * Synchronous reclaim cannot queue pages for
>  			 * writeback due to the possibility of stack overflow
> @@ -874,12 +880,15 @@ static unsigned long shrink_page_list(st
>  			nr_dirty++;
>  
>  			/*
> -			 * Only kswapd can writeback filesystem pages to
> -			 * avoid risk of stack overflow but do not writeback
> -			 * unless under significant pressure.
> +			 * run into the visited page again: we are scanning
> +			 * faster than the flusher can writeout dirty pages
>  			 */
> -			if (page_is_file_cache(page) &&
> -					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
> +			if (page_is_file_cache(page) && PageReclaim(page)) {
> +				nr_pgreclaim++;
> +				goto keep_locked;
> +			}

This change means that kswapd is no longer doing any writeback from page
reclaim. Was that intended because it's not discussed in the changelog. I
know writeback from kswapd is poor in terms of IO performance but it's a
last resort for freeing a page when reclaim is in trouble. If we are to
disable it and depend 100% on the flusher threads, it should be in its
own patch for bisection reasons if nothing else.

> +			if (page_is_file_cache(page) && mapping &&
> +			    flush_inode_page(mapping, page, false) >= 0) {
>  				/*
>  				 * Immediately reclaim when written back.
>  				 * Similar in principal to deactivate_page()
> @@ -1028,6 +1037,7 @@ keep_lumpy:
>  	count_vm_events(PGACTIVATE, pgactivate);
>  	*ret_nr_dirty += nr_dirty;
>  	*ret_nr_writeback += nr_writeback;
> +	*ret_nr_pgreclaim += nr_pgreclaim;
>  	return nr_reclaimed;
>  }
>  
> @@ -1509,6 +1519,7 @@ shrink_inactive_list(unsigned long nr_to
>  	unsigned long nr_file;
>  	unsigned long nr_dirty = 0;
>  	unsigned long nr_writeback = 0;
> +	unsigned long nr_pgreclaim = 0;
>  	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
>  	struct zone *zone = mz->zone;
>  
> @@ -1559,13 +1570,13 @@ shrink_inactive_list(unsigned long nr_to
>  	spin_unlock_irq(&zone->lru_lock);
>  
>  	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
> -						&nr_dirty, &nr_writeback);
> +				&nr_dirty, &nr_writeback, &nr_pgreclaim);
>  
>  	/* Check if we should syncronously wait for writeback */
>  	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
>  		set_reclaim_mode(priority, sc, true);
>  		nr_reclaimed += shrink_page_list(&page_list, mz, sc,
> -					priority, &nr_dirty, &nr_writeback);
> +			priority, &nr_dirty, &nr_writeback, &nr_pgreclaim);
>  	}
>  
>  	spin_lock_irq(&zone->lru_lock);
> @@ -1608,6 +1619,9 @@ shrink_inactive_list(unsigned long nr_to
>  	 */
>  	if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
>  		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +	if (nr_pgreclaim && nr_pgreclaim >= (nr_taken >> (DEF_PRIORITY-priority)) &&
> +	    (!global_reclaim(sc) || !zone_dirty_ok(zone)))
> +		reclaim_wait(HZ/10);
>  

I prefer this but it would be nice if there was a comment explaining it
or at least expand the comment explaining how nr_writeback can lead to
wait_iff_congested() being called.

>  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
>  		zone_idx(zone),
> @@ -2382,8 +2396,6 @@ static unsigned long do_try_to_free_page
>  		 */
>  		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
>  		if (total_scanned > writeback_threshold) {
> -			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
> -						WB_REASON_TRY_TO_FREE_PAGES);
>  			sc->may_writepage = 1;
>  		}
>  
> --- linux.orig/fs/fs-writeback.c	2012-02-14 20:11:21.000000000 +0800
> +++ linux/fs/fs-writeback.c	2012-02-15 12:27:35.000000000 +0800
> @@ -41,6 +41,8 @@ struct wb_writeback_work {
>  	long nr_pages;
>  	struct super_block *sb;
>  	unsigned long *older_than_this;
> +	struct inode *inode;
> +	pgoff_t offset;
>  	enum writeback_sync_modes sync_mode;
>  	unsigned int tagged_writepages:1;
>  	unsigned int for_kupdate:1;
> @@ -65,6 +67,27 @@ struct wb_writeback_work {
>   */
>  int nr_pdflush_threads;
>  
> +static mempool_t *wb_work_mempool;
> +
> +static void *wb_work_alloc(gfp_t gfp_mask, void *pool_data)
> +{
> +	/*
> +	 * bdi_flush_inode_range() may be called on page reclaim
> +	 */
> +	if (current->flags & PF_MEMALLOC)
> +		return NULL;
> +

This check is why I worry about kswapd being unable to write pages at
all. If the mempool is depleted for whatever reason, reclaim has no way
of telling the flushers what work is needed or waking them. Potentially,
we could be waiting a long time for pending flusher work to complete to
free up a slot.  I recognise it may not be bad in practice because the
pool is large and other work will be completing but it's why kswapd not
writing back pages should be in its own patch.

> +	return kmalloc(sizeof(struct wb_writeback_work), gfp_mask);
> +}
> +
> +static __init int wb_work_init(void)
> +{
> +	wb_work_mempool = mempool_create(1024,
> +					 wb_work_alloc, mempool_kfree, NULL);
> +	return wb_work_mempool ? 0 : -ENOMEM;
> +}
> +fs_initcall(wb_work_init);
> +
>  /**
>   * writeback_in_progress - determine whether there is writeback in progress
>   * @bdi: the device's backing_dev_info structure.
> @@ -129,7 +152,7 @@ __bdi_start_writeback(struct backing_dev
>  	 * This is WB_SYNC_NONE writeback, so if allocation fails just
>  	 * wakeup the thread for old dirty data writeback
>  	 */
> -	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> +	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
>  	if (!work) {
>  		if (bdi->wb.task) {
>  			trace_writeback_nowork(bdi);
> @@ -138,6 +161,7 @@ __bdi_start_writeback(struct backing_dev
>  		return;
>  	}
>  
> +	memset(work, 0, sizeof(*work));
>  	work->sync_mode	= WB_SYNC_NONE;
>  	work->nr_pages	= nr_pages;
>  	work->range_cyclic = range_cyclic;
> @@ -186,6 +210,125 @@ void bdi_start_background_writeback(stru
>  	spin_unlock_bh(&bdi->wb_lock);
>  }
>  
> +static bool extend_writeback_range(struct wb_writeback_work *work,
> +				   pgoff_t offset,
> +				   unsigned long write_around_pages)
> +{

comment on what this function is for and what the return values mean.

"returns true if the wb_writeback_work now encompasses the request"

or something

> +	pgoff_t end = work->offset + work->nr_pages;
> +
> +	if (offset >= work->offset && offset < end)
> +		return true;
> +

This does not ensure that the full span of
offset -> offset+write_around_pages is encompassed by work. All it
checks is that the start of the requested range is going to be handled.

I guess it's ok because the page reclaims cares about is covered and
avoids a situation where too much IO is being queued. It's unclear if
this is what you intended though because you check for too much IO being
queued in the next block.

> +	/*
> +	 * for sequential workloads with good locality, include up to 8 times
> +	 * more data in one chunk
> +	 */
> +	if (work->nr_pages >= 8 * write_around_pages)
> +		return false;
> +
> +	/* the unsigned comparison helps eliminate one compare */
> +	if (work->offset - offset < write_around_pages) {
> +		work->nr_pages += write_around_pages;
> +		work->offset -= write_around_pages;
> +		return true;
> +	}
> +
> +	if (offset - end < write_around_pages) {
> +		work->nr_pages += write_around_pages;
> +		return true;
> +	}
> +
> +	return false;
> +}
> +
> +/*
> + * schedule writeback on a range of inode pages.
> + */
> +static struct wb_writeback_work *
> +bdi_flush_inode_range(struct backing_dev_info *bdi,
> +		      struct inode *inode,
> +		      pgoff_t offset,
> +		      pgoff_t len,
> +		      bool wait)
> +{
> +	struct wb_writeback_work *work;
> +
> +	if (!igrab(inode))
> +		return ERR_PTR(-ENOENT);
> +

Explain why the igrab is necessary. I think it's because we are calling
this from page reclaim context and the only thing pinning the
address_space is the page lock . If I'm right, it should be made clear
in the comment for bdi_flush_inode_range that this should only be called
from page reclaim context. Maybe even VM_BUG_ON if
!(current->flags & PF_MEMALLOC)?

> +	work = mempool_alloc(wb_work_mempool, wait ? GFP_NOIO : GFP_NOWAIT);
> +	if (!work) {
> +		trace_printk("wb_work_mempool alloc fail\n");
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	memset(work, 0, sizeof(*work));
> +	work->sync_mode		= WB_SYNC_NONE;
> +	work->inode		= inode;
> +	work->offset		= offset;
> +	work->nr_pages		= len;
> +	work->reason		= WB_REASON_PAGEOUT;
> +
> +	bdi_queue_work(bdi, work);
> +
> +	return work;
> +}
> +
> +/*
> + * Called by page reclaim code to flush the dirty page ASAP. Do write-around to
> + * improve IO throughput. The nearby pages will have good chance to reside in
> + * the same LRU list that vmscan is working on, and even close to each other
> + * inside the LRU list in the common case of sequential read/write.
> + *
> + * ret > 0: success, found/reused a previous writeback work
> + * ret = 0: success, allocated/queued a new writeback work
> + * ret < 0: failed
> + */
> +long flush_inode_page(struct address_space *mapping,
> +		      struct page *page,
> +		      bool wait)
> +{
> +	struct backing_dev_info *bdi = mapping->backing_dev_info;
> +	struct inode *inode = mapping->host;
> +	struct wb_writeback_work *work;
> +	unsigned long write_around_pages;
> +	pgoff_t offset = page->index;
> +	int i;
> +	long ret = 0;
> +
> +	if (unlikely(!inode))
> +		return -ENOENT;
> +
> +	/*
> +	 * piggy back 8-15ms worth of data
> +	 */
> +	write_around_pages = bdi->avg_write_bandwidth + MIN_WRITEBACK_PAGES;
> +	write_around_pages = rounddown_pow_of_two(write_around_pages) >> 6;
> +
> +	i = 1;
> +	spin_lock_bh(&bdi->wb_lock);
> +	list_for_each_entry_reverse(work, &bdi->work_list, list) {
> +		if (work->inode != inode)
> +			continue;
> +		if (extend_writeback_range(work, offset, write_around_pages)) {
> +			ret = i;
> +			break;
> +		}
> +		if (i++ > 100)	/* limit search depth */
> +			break;

No harm to move Jan's comment on depth limit search to here adding why
100 is as good as number as any to use.

> +	}
> +	spin_unlock_bh(&bdi->wb_lock);
> +
> +	if (!ret) {
> +		offset = round_down(offset, write_around_pages);
> +		work = bdi_flush_inode_range(bdi, inode,
> +					     offset, write_around_pages, wait);
> +		if (IS_ERR(work))
> +			ret = PTR_ERR(work);
> +	}
> +	return ret;
> +}
> +
>  /*
>   * Remove the inode from the writeback list it is on.
>   */
> @@ -833,6 +976,23 @@ static unsigned long get_nr_dirty_pages(
>  		get_nr_dirty_inodes();
>  }
>  
> +static long wb_flush_inode(struct bdi_writeback *wb,
> +			   struct wb_writeback_work *work)
> +{
> +	struct writeback_control wbc = {
> +		.sync_mode = WB_SYNC_NONE,
> +		.nr_to_write = LONG_MAX,
> +		.range_start = work->offset << PAGE_CACHE_SHIFT,
> +		.range_end = (work->offset + work->nr_pages - 1)
> +						<< PAGE_CACHE_SHIFT,
> +	};
> +
> +	do_writepages(work->inode->i_mapping, &wbc);
> +	iput(work->inode);
> +
> +	return LONG_MAX - wbc.nr_to_write;
> +}
> +
>  static long wb_check_background_flush(struct bdi_writeback *wb)
>  {
>  	if (over_bground_thresh(wb->bdi)) {
> @@ -905,7 +1065,10 @@ long wb_do_writeback(struct bdi_writebac
>  
>  		trace_writeback_exec(bdi, work);
>  
> -		wrote += wb_writeback(wb, work);
> +		if (work->inode)
> +			wrote += wb_flush_inode(wb, work);
> +		else
> +			wrote += wb_writeback(wb, work);
>  
>  		/*
>  		 * Notify the caller of completion if this is a synchronous
> @@ -914,7 +1077,7 @@ long wb_do_writeback(struct bdi_writebac
>  		if (work->done)
>  			complete(work->done);
>  		else
> -			kfree(work);
> +			mempool_free(work, wb_work_mempool);
>  	}
>  
>  	/*
> --- linux.orig/include/trace/events/writeback.h	2012-02-14 20:11:22.000000000 +0800
> +++ linux/include/trace/events/writeback.h	2012-02-15 12:27:35.000000000 +0800
> @@ -23,7 +23,7 @@
>  
>  #define WB_WORK_REASON							\
>  		{WB_REASON_BACKGROUND,		"background"},		\
> -		{WB_REASON_TRY_TO_FREE_PAGES,	"try_to_free_pages"},	\
> +		{WB_REASON_PAGEOUT,		"pageout"},		\
>  		{WB_REASON_SYNC,		"sync"},		\
>  		{WB_REASON_PERIODIC,		"periodic"},		\
>  		{WB_REASON_LAPTOP_TIMER,	"laptop_timer"},	\
> @@ -45,6 +45,8 @@ DECLARE_EVENT_CLASS(writeback_work_class
>  		__field(int, range_cyclic)
>  		__field(int, for_background)
>  		__field(int, reason)
> +		__field(unsigned long, ino)
> +		__field(unsigned long, offset)
>  	),
>  	TP_fast_assign(
>  		strncpy(__entry->name, dev_name(bdi->dev), 32);
> @@ -55,9 +57,11 @@ DECLARE_EVENT_CLASS(writeback_work_class
>  		__entry->range_cyclic = work->range_cyclic;
>  		__entry->for_background	= work->for_background;
>  		__entry->reason = work->reason;
> +		__entry->ino = work->inode ? work->inode->i_ino : 0;
> +		__entry->offset = work->offset;
>  	),
>  	TP_printk("bdi %s: sb_dev %d:%d nr_pages=%ld sync_mode=%d "
> -		  "kupdate=%d range_cyclic=%d background=%d reason=%s",
> +		  "kupdate=%d range_cyclic=%d background=%d reason=%s ino=%lu offset=%lu",
>  		  __entry->name,
>  		  MAJOR(__entry->sb_dev), MINOR(__entry->sb_dev),
>  		  __entry->nr_pages,
> @@ -65,7 +69,9 @@ DECLARE_EVENT_CLASS(writeback_work_class
>  		  __entry->for_kupdate,
>  		  __entry->range_cyclic,
>  		  __entry->for_background,
> -		  __print_symbolic(__entry->reason, WB_WORK_REASON)
> +		  __print_symbolic(__entry->reason, WB_WORK_REASON),
> +		  __entry->ino,
> +		  __entry->offset
>  	)
>  );
>  #define DEFINE_WRITEBACK_WORK_EVENT(name) \
> @@ -437,6 +443,13 @@ DEFINE_EVENT(writeback_congest_waited_te
>  	TP_ARGS(usec_timeout, usec_delayed)
>  );
>  
> +DEFINE_EVENT(writeback_congest_waited_template, writeback_reclaim_wait,
> +
> +	TP_PROTO(unsigned int usec_timeout, unsigned int usec_delayed),
> +
> +	TP_ARGS(usec_timeout, usec_delayed)
> +);
> +
>  DECLARE_EVENT_CLASS(writeback_single_inode_template,
>  
>  	TP_PROTO(struct inode *inode,
> --- linux.orig/include/linux/writeback.h	2012-02-14 20:11:21.000000000 +0800
> +++ linux/include/linux/writeback.h	2012-02-15 12:27:35.000000000 +0800
> @@ -40,7 +40,7 @@ enum writeback_sync_modes {
>   */
>  enum wb_reason {
>  	WB_REASON_BACKGROUND,
> -	WB_REASON_TRY_TO_FREE_PAGES,
> +	WB_REASON_PAGEOUT,
>  	WB_REASON_SYNC,
>  	WB_REASON_PERIODIC,
>  	WB_REASON_LAPTOP_TIMER,
> @@ -94,6 +94,8 @@ long writeback_inodes_wb(struct bdi_writ
>  				enum wb_reason reason);
>  long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
>  void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
> +long flush_inode_page(struct address_space *mapping, struct page *page,
> +		      bool wait);
>  
>  /* writeback.h requires fs.h; it, too, is not included from here. */
>  static inline void wait_on_inode(struct inode *inode)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
