Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E02666B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 10:43:16 -0500 (EST)
Date: Mon, 13 Feb 2012 16:43:13 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120213154313.GD6478@quack.suse.cz>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <4F36816A.6030609@redhat.com>
 <20120212031029.GA17435@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120212031029.GA17435@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Sun 12-02-12 11:10:29, Wu Fengguang wrote:
> On Sat, Feb 11, 2012 at 09:55:38AM -0500, Rik van Riel wrote:
> > On 02/11/2012 07:44 AM, Wu Fengguang wrote:
> > 
> > >Note that it's data for XFS. ext4 seems to have some problem with the
> > >workload: the majority pages are found to be writeback pages, and the
> > >flusher ends up blocking on the unconditional wait_on_page_writeback()
> > >in write_cache_pages_da() from time to time...
> 
> Sorry I overlooked the WB_SYNC_NONE test before the wait_on_page_writeback()
> call! And the issue can no longer be reproduce anyway. ext4 performs pretty
> good now, here is the result for one single memcg dd:
> 
>         dd if=/dev/zero of=/fs/f$i bs=4k count=1M
> 
>         4294967296 bytes (4.3 GB) copied, 44.5759 s, 96.4 MB/s
> 
> iostat -kx 3
> 
> avg-cpu:  %user   %nice %system %iowait  %steal   %idle
>            0.25    0.00   11.03   28.54    0.00   60.19
>            0.25    0.00   13.71   16.65    0.00   69.39
>            0.17    0.00    8.41   24.81    0.00   66.61
>            0.25    0.00   15.00   19.63    0.00   65.12
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
> sda               0.00    17.00    0.00  178.33     0.00 90694.67  1017.14   111.34  520.88   5.45  97.23
> sda               0.00     0.00    0.00  193.67     0.00 98816.00  1020.48    86.22  496.81   4.81  93.07
> sda               0.00     3.33    0.00  182.33     0.00 92345.33  1012.93   101.14  623.98   5.49 100.03
> sda               0.00     3.00    0.00  187.00     0.00 95586.67  1022.32    89.36  441.70   4.96  92.70
> 
> > >XXX: commit NFS unstable pages via write_inode()
> > >XXX: the added congestion_wait() may be undesirable in some situations
> > 
> > Even with these caveats, this seems to be the right way forward.
> 
> > Acked-by: Rik van Riel <riel@redhat.com>
> 
> Thank you!
>  
> Here is the updated patch.
> - ~10ms write around chunk size, adaptive to the bdi bandwith 
> - cleanup flush_inode_page()
> 
> Thanks,
> Fengguang
> ---
> Subject: writeback: introduce the pageout work
> Date: Thu Jul 29 14:41:19 CST 2010
> 
> This relays file pageout IOs to the flusher threads.
> 
> The ultimate target is to gracefully handle the LRU lists full of
> dirty/writeback pages.
> 
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
> A simple yet reliable scheme is employed to avoid OOM and keep scan rate
> in sync with the I/O rate:
> 
> 	if (PageReclaim(page))
> 		congestion_wait(HZ/10);
> 
> PG_reclaim plays the key role. When dirty pages are encountered, we
> queue I/O for it, set PG_reclaim and put it back to the LRU head.
> So if PG_reclaim pages are encountered again, it means the dirty page
> has not yet been cleaned by the flusher after a full zone scan. It
> indicates we are scanning more fast than I/O and shall take a snap.
> 
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
  I wonder what happens if you run:
       mkdir /cgroup/x
       echo 100M > /cgroup/x/memory.limit_in_bytes
       echo $$ > /cgroup/x/tasks

       for (( i = 0; i < 2; i++ )); do
         mkdir /fs/d$i
         for (( j = 0; j < 5000; j++ )); do 
           dd if=/dev/zero of=/fs/d$i/f$j bs=1k count=50
         done &
       done
  Because for small files the writearound logic won't help much... Also the
number of work items queued might become interesting.

Another common case to test - run 'slapadd' command in each cgroup to
create big LDAP database. That does pretty much random IO on a big mmaped
DB file.

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
  One technical note here: If the inode is deleted while it is queued, this
reference will keep it living until flusher thread gets to it. Then when
flusher thread puts its reference, the inode will get deleted in flusher
thread context. I don't see an immediate problem in that but it might be
surprising sometimes. Another problem I see is that if you try to
unmount the filesystem while the work item is queued, you'll get EBUSY for
no apparent reason (for userspace).

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
