Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 7B8F16B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 05:13:59 -0500 (EST)
Date: Tue, 14 Feb 2012 18:03:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120214100348.GA7000@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <4F36816A.6030609@redhat.com>
 <20120212031029.GA17435@localhost>
 <20120213154313.GD6478@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Content-Disposition: inline
In-Reply-To: <20120213154313.GD6478@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 13, 2012 at 04:43:13PM +0100, Jan Kara wrote:
> On Sun 12-02-12 11:10:29, Wu Fengguang wrote:

> > 4) test case
> > 
> > Run 2 dd tasks in a 100MB memcg (a very handy test case from Greg Thelen):
> > 
> > 	mkdir /cgroup/x
> > 	echo 100M > /cgroup/x/memory.limit_in_bytes
> > 	echo $$ > /cgroup/x/tasks
> > 
> > 	for i in `seq 2`
> > 	do
> > 		dd if=/dev/zero of=/fs/f$i bs=1k count=1M &
> > 	done
> > 
> > Before patch, the dd tasks are quickly OOM killed.
> > After patch, they run well with reasonably good performance and overheads:
> > 
> > 1073741824 bytes (1.1 GB) copied, 22.2196 s, 48.3 MB/s
> > 1073741824 bytes (1.1 GB) copied, 22.4675 s, 47.8 MB/s
>   I wonder what happens if you run:
>        mkdir /cgroup/x
>        echo 100M > /cgroup/x/memory.limit_in_bytes
>        echo $$ > /cgroup/x/tasks
> 
>        for (( i = 0; i < 2; i++ )); do
>          mkdir /fs/d$i
>          for (( j = 0; j < 5000; j++ )); do 
>            dd if=/dev/zero of=/fs/d$i/f$j bs=1k count=50
>          done &
>        done

That's a very good case, thanks!
 
>   Because for small files the writearound logic won't help much...

Right, it also means the native background work cannot be more I/O
efficient than the pageout works, except for the overheads of more
work items..

>   Also the number of work items queued might become interesting.

It turns out that the 1024 mempool reservations are not exhausted at
all (the below patch as a trace_printk on alloc failure and it didn't
trigger at all).

Here is the representative iostat lines on XFS (full "iostat -kx 1 20" log attached):

avg-cpu:  %user   %nice %system %iowait  %steal   %idle                                                                     
           0.80    0.00    6.03    0.03    0.00   93.14                                                                     
                                                                                                                            
Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util                   
sda               0.00   205.00    0.00  163.00     0.00 16900.00   207.36     4.09   21.63   1.88  30.70                   

The attached dirtied/written progress graph looks interesting.
Although the iostat disk utilization is low, the "dirtied" progress
line is pretty straight and there is no single congestion_wait event
in the trace log. Which makes me wonder if there are some unknown
blocking issues in the way.

> Another common case to test - run 'slapadd' command in each cgroup to
> create big LDAP database. That does pretty much random IO on a big mmaped
> DB file.

I've not used this. Will it need some configuration and data feed?
fio looks more handy to me for emulating mmap random IO.

> > +/*
> > + * schedule writeback on a range of inode pages.
> > + */
> > +static struct wb_writeback_work *
> > +bdi_flush_inode_range(struct backing_dev_info *bdi,
> > +		      struct inode *inode,
> > +		      pgoff_t offset,
> > +		      pgoff_t len,
> > +		      bool wait)
> > +{
> > +	struct wb_writeback_work *work;
> > +
> > +	if (!igrab(inode))
> > +		return ERR_PTR(-ENOENT);
>   One technical note here: If the inode is deleted while it is queued, this
> reference will keep it living until flusher thread gets to it. Then when
> flusher thread puts its reference, the inode will get deleted in flusher
> thread context. I don't see an immediate problem in that but it might be
> surprising sometimes. Another problem I see is that if you try to
> unmount the filesystem while the work item is queued, you'll get EBUSY for
> no apparent reason (for userspace).

Yeah, we need to make umount work.

And I find the pageout works seem to have some problems with ext4.
For example, this can be easily triggered with 10 dd tasks running
inside the 100MB limited memcg:

[18006.858109] INFO: task jbd2/sda1-8:51294 blocked for more than 120 seconds.
[18006.866425] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[18006.876096] jbd2/sda1-8     D 0000000000000000  5464 51294      2 0x00000000
[18006.884729]  ffff88040b097c70 0000000000000046 ffff880823032310 ffff88040b096000
[18006.894356]  00000000001d2f00 00000000001d2f00 ffff8808230322a0 00000000001d2f00
[18006.904000]  ffff88040b097fd8 00000000001d2f00 ffff88040b097fd8 00000000001d2f00
[18006.913652] Call Trace:
[18006.916901]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
[18006.924134]  [<ffffffff81232aab>] ? jbd2_journal_commit_transaction+0x1d0/0x1281
[18006.933324]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
[18006.939879]  [<ffffffff810b0ddd>] ? lock_release_holdtime+0xa3/0xac
[18006.947410]  [<ffffffff81232aab>] ? jbd2_journal_commit_transaction+0x1d0/0x1281
[18006.956607]  [<ffffffff81a57904>] schedule+0x5a/0x5c
[18006.962677]  [<ffffffff81232ab0>] jbd2_journal_commit_transaction+0x1d5/0x1281
[18006.971683]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
[18006.978933]  [<ffffffff810738ce>] ? try_to_del_timer_sync+0xba/0xc8
[18006.986452]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
[18006.992999]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
[18006.999542]  [<ffffffff810738ce>] ? try_to_del_timer_sync+0xba/0xc8
[18007.007062]  [<ffffffff81073a6f>] ? del_timer_sync+0xbb/0xce
[18007.013898]  [<ffffffff810739b4>] ? process_timeout+0x10/0x10
[18007.020835]  [<ffffffff81237bc1>] kjournald2+0xcf/0x242
[18007.027187]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
[18007.033733]  [<ffffffff81237af2>] ? commit_timeout+0x10/0x10
[18007.040574]  [<ffffffff81086384>] kthread+0x95/0x9d
[18007.046542]  [<ffffffff81a61134>] kernel_thread_helper+0x4/0x10
[18007.053675]  [<ffffffff81a591b4>] ? retint_restore_args+0x13/0x13
[18007.061003]  [<ffffffff810862ef>] ? __init_kthread_worker+0x5b/0x5b
[18007.068521]  [<ffffffff81a61130>] ? gs_change+0x13/0x13
[18007.074878] no locks held by jbd2/sda1-8/51294.

Sometimes I also catch dd/ext4lazyinit/flush all stalling in start_this_handle:

[17985.439567] dd              D 0000000000000007  3616 61440      1 0x00000004
[17985.448088]  ffff88080d71b9b8 0000000000000046 ffff88081ec80070 ffff88080d71a000
[17985.457545]  00000000001d2f00 00000000001d2f00 ffff88081ec80000 00000000001d2f00
[17985.467168]  ffff88080d71bfd8 00000000001d2f00 ffff88080d71bfd8 00000000001d2f00
[17985.476647] Call Trace:
[17985.479843]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
[17985.487025]  [<ffffffff81230b9d>] ? start_this_handle+0x357/0x4ed
[17985.494313]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
[17985.500815]  [<ffffffff810b0ddd>] ? lock_release_holdtime+0xa3/0xac
[17985.508287]  [<ffffffff81230b9d>] ? start_this_handle+0x357/0x4ed
[17985.515575]  [<ffffffff81a57904>] schedule+0x5a/0x5c
[17985.521588]  [<ffffffff81230c39>] start_this_handle+0x3f3/0x4ed
[17985.528669]  [<ffffffff81147820>] ? kmem_cache_free+0xfa/0x13a
[17985.545142]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
[17985.551650]  [<ffffffff81230f0e>] jbd2__journal_start+0xb0/0xf6
[17985.558732]  [<ffffffff811f7ad7>] ? ext4_dirty_inode+0x1d/0x4c
[17985.565716]  [<ffffffff81230f67>] jbd2_journal_start+0x13/0x15
[17985.572703]  [<ffffffff8120e3e9>] ext4_journal_start_sb+0x13f/0x157
[17985.580172]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
[17985.586680]  [<ffffffff811f7ad7>] ext4_dirty_inode+0x1d/0x4c
[17985.593472]  [<ffffffff81176827>] __mark_inode_dirty+0x2e/0x1cc
[17985.600552]  [<ffffffff81168e84>] file_update_time+0xe4/0x106
[17985.607441]  [<ffffffff811079f6>] __generic_file_aio_write+0x254/0x364
[17985.615202]  [<ffffffff81a565da>] ? mutex_lock_nested+0x2e4/0x2f3
[17985.622488]  [<ffffffff81107b50>] ? generic_file_aio_write+0x4a/0xc1
[17985.630057]  [<ffffffff81107b6c>] generic_file_aio_write+0x66/0xc1
[17985.637442]  [<ffffffff811ef72b>] ext4_file_write+0x1f9/0x251
[17985.644330]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
[17985.650835]  [<ffffffff8118809e>] ? fsnotify+0x222/0x27b
[17985.657238]  [<ffffffff81153612>] do_sync_write+0xce/0x10b
[17985.663844]  [<ffffffff8118809e>] ? fsnotify+0x222/0x27b
[17985.670243]  [<ffffffff81187ef8>] ? fsnotify+0x7c/0x27b
[17985.676561]  [<ffffffff81153dbe>] vfs_write+0xb8/0x157
[17985.682767]  [<ffffffff81154075>] sys_write+0x4d/0x77
[17985.688878]  [<ffffffff81a5fce9>] system_call_fastpath+0x16/0x1b

and jbd2 in

[17983.623657] jbd2/sda1-8     D 0000000000000000  5464 51294      2 0x00000000
[17983.632173]  ffff88040b097c70 0000000000000046 ffff880823032310 ffff88040b096000
[17983.641640]  00000000001d2f00 00000000001d2f00 ffff8808230322a0 00000000001d2f00
[17983.651119]  ffff88040b097fd8 00000000001d2f00 ffff88040b097fd8 00000000001d2f00
[17983.660603] Call Trace:
[17983.663808]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
[17983.670997]  [<ffffffff81232aab>] ? jbd2_journal_commit_transaction+0x1d0/0x1281
[17983.680124]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
[17983.686638]  [<ffffffff810b0ddd>] ? lock_release_holdtime+0xa3/0xac
[17983.694108]  [<ffffffff81232aab>] ? jbd2_journal_commit_transaction+0x1d0/0x1281
[17983.703243]  [<ffffffff81a57904>] schedule+0x5a/0x5c
[17983.709262]  [<ffffffff81232ab0>] jbd2_journal_commit_transaction+0x1d5/0x1281
[17983.718195]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
[17983.725392]  [<ffffffff810738ce>] ? try_to_del_timer_sync+0xba/0xc8
[17983.732867]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
[17983.739374]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
[17983.745864]  [<ffffffff810738ce>] ? try_to_del_timer_sync+0xba/0xc8
[17983.753343]  [<ffffffff81073a6f>] ? del_timer_sync+0xbb/0xce
[17983.760137]  [<ffffffff810739b4>] ? process_timeout+0x10/0x10
[17983.767041]  [<ffffffff81237bc1>] kjournald2+0xcf/0x242
[17983.773361]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
[17983.779863]  [<ffffffff81237af2>] ? commit_timeout+0x10/0x10
[17983.786665]  [<ffffffff81086384>] kthread+0x95/0x9d
[17983.792585]  [<ffffffff81a61134>] kernel_thread_helper+0x4/0x10
[17983.799670]  [<ffffffff81a591b4>] ? retint_restore_args+0x13/0x13
[17983.806948]  [<ffffffff810862ef>] ? __init_kthread_worker+0x5b/0x5b

Here is the updated patch used in the new tests. It moves
congestion_wait() out of the page lock and make flush_inode_page() no
longer wait for memory allocation (looks unnecessary).

Thanks,
Fengguang
---
Subject: writeback: introduce the pageout work
Date: Thu Jul 29 14:41:19 CST 2010

This relays file pageout IOs to the flusher threads.

The ultimate target is to gracefully handle the LRU lists full of
dirty/writeback pages.

1) I/O efficiency

The flusher will piggy back the nearby ~10ms worth of dirty pages for I/O.

This takes advantage of the time/spacial locality in most workloads: the
nearby pages of one file are typically populated into the LRU at the same
time, hence will likely be close to each other in the LRU list. Writing
them in one shot helps clean more pages effectively for page reclaim.

2) OOM avoidance and scan rate control

Typically we do LRU scan w/o rate control and quickly get enough clean
pages for the LRU lists not full of dirty pages.

Or we can still get a number of freshly cleaned pages (moved to LRU tail
by end_page_writeback()) when the queued pageout I/O is completed within
tens of milli-seconds.

However if the LRU list is small and full of dirty pages, it can be
quickly fully scanned and go OOM before the flusher manages to clean
enough pages.

A simple yet reliable scheme is employed to avoid OOM and keep scan rate
in sync with the I/O rate:

	if (PageReclaim(page))
		congestion_wait(HZ/10);

PG_reclaim plays the key role. When dirty pages are encountered, we
queue I/O for it, set PG_reclaim and put it back to the LRU head.
So if PG_reclaim pages are encountered again, it means the dirty page
has not yet been cleaned by the flusher after a full zone scan. It
indicates we are scanning more fast than I/O and shall take a snap.

The runtime behavior on a fully dirtied small LRU list would be:
It will start with a quick scan of the list, queuing all pages for I/O.
Then the scan will be slowed down by the PG_reclaim pages *adaptively*
to match the I/O bandwidth.

3) writeback work coordinations

To avoid memory allocations at page reclaim, a mempool for struct
wb_writeback_work is created.

wakeup_flusher_threads() is removed because it can easily delay the
more oriented pageout works and even exhaust the mempool reservations.
It's also found to not I/O efficient by frequently submitting writeback
works with small ->nr_pages.

Background/periodic works will quit automatically, so as to clean the
pages under reclaim ASAP. However for now the sync work can still block
us for long time.

Jan Kara: limit the search scope. Note that the limited search and work
pool is not a big problem: 1000 IOs under flight are typically more than
enough to saturate the disk. And the overheads of searching in the work
list didn't even show up in the perf report.

4) test case

Run 2 dd tasks in a 100MB memcg (a very handy test case from Greg Thelen):

	mkdir /cgroup/x
	echo 100M > /cgroup/x/memory.limit_in_bytes
	echo $$ > /cgroup/x/tasks

	for i in `seq 2`
	do
		dd if=/dev/zero of=/fs/f$i bs=1k count=1M &
	done

Before patch, the dd tasks are quickly OOM killed.
After patch, they run well with reasonably good performance and overheads:

1073741824 bytes (1.1 GB) copied, 22.2196 s, 48.3 MB/s
1073741824 bytes (1.1 GB) copied, 22.4675 s, 47.8 MB/s

iostat -kx 1

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00  178.00     0.00 89568.00  1006.38    74.35  417.71   4.80  85.40
sda               0.00     2.00    0.00  191.00     0.00 94428.00   988.77    53.34  219.03   4.34  82.90
sda               0.00    20.00    0.00  196.00     0.00 97712.00   997.06    71.11  337.45   4.77  93.50
sda               0.00     5.00    0.00  175.00     0.00 84648.00   967.41    54.03  316.44   5.06  88.60
sda               0.00     0.00    0.00  186.00     0.00 92432.00   993.89    56.22  267.54   5.38 100.00
sda               0.00     1.00    0.00  183.00     0.00 90156.00   985.31    37.99  325.55   4.33  79.20
sda               0.00     0.00    0.00  175.00     0.00 88692.00  1013.62    48.70  218.43   4.69  82.10
sda               0.00     0.00    0.00  196.00     0.00 97528.00   995.18    43.38  236.87   5.10 100.00
sda               0.00     0.00    0.00  179.00     0.00 88648.00   990.48    45.83  285.43   5.59 100.00
sda               0.00     0.00    0.00  178.00     0.00 88500.00   994.38    28.28  158.89   4.99  88.80
sda               0.00     0.00    0.00  194.00     0.00 95852.00   988.16    32.58  167.39   5.15 100.00
sda               0.00     2.00    0.00  215.00     0.00 105996.00   986.01    41.72  201.43   4.65 100.00
sda               0.00     4.00    0.00  173.00     0.00 84332.00   974.94    50.48  260.23   5.76  99.60
sda               0.00     0.00    0.00  182.00     0.00 90312.00   992.44    36.83  212.07   5.49 100.00
sda               0.00     8.00    0.00  195.00     0.00 95940.50   984.01    50.18  221.06   5.13 100.00
sda               0.00     1.00    0.00  220.00     0.00 108852.00   989.56    40.99  202.68   4.55 100.00
sda               0.00     2.00    0.00  161.00     0.00 80384.00   998.56    37.19  268.49   6.21 100.00
sda               0.00     4.00    0.00  182.00     0.00 90830.00   998.13    50.58  239.77   5.49 100.00
sda               0.00     0.00    0.00  197.00     0.00 94877.00   963.22    36.68  196.79   5.08 100.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.25    0.00   15.08   33.92    0.00   50.75
           0.25    0.00   14.54   35.09    0.00   50.13
           0.50    0.00   13.57   32.41    0.00   53.52
           0.50    0.00   11.28   36.84    0.00   51.38
           0.50    0.00   15.75   32.00    0.00   51.75
           0.50    0.00   10.50   34.00    0.00   55.00
           0.50    0.00   17.63   27.46    0.00   54.41
           0.50    0.00   15.08   30.90    0.00   53.52
           0.50    0.00   11.28   32.83    0.00   55.39
           0.75    0.00   16.79   26.82    0.00   55.64
           0.50    0.00   16.08   29.15    0.00   54.27
           0.50    0.00   13.50   30.50    0.00   55.50
           0.50    0.00   14.32   35.18    0.00   50.00
           0.50    0.00   12.06   33.92    0.00   53.52
           0.50    0.00   17.29   30.58    0.00   51.63
           0.50    0.00   15.08   29.65    0.00   54.77
           0.50    0.00   12.53   29.32    0.00   57.64
           0.50    0.00   15.29   31.83    0.00   52.38

The global dd numbers for comparison:

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00  189.00     0.00 95752.00  1013.25   143.09  684.48   5.29 100.00
sda               0.00     0.00    0.00  208.00     0.00 105480.00  1014.23   143.06  733.29   4.81 100.00
sda               0.00     0.00    0.00  161.00     0.00 81924.00  1017.69   141.71  757.79   6.21 100.00
sda               0.00     0.00    0.00  217.00     0.00 109580.00  1009.95   143.09  749.55   4.61 100.10
sda               0.00     0.00    0.00  187.00     0.00 94728.00  1013.13   144.31  773.67   5.35 100.00
sda               0.00     0.00    0.00  189.00     0.00 95752.00  1013.25   144.14  742.00   5.29 100.00
sda               0.00     0.00    0.00  177.00     0.00 90032.00  1017.31   143.32  656.59   5.65 100.00
sda               0.00     0.00    0.00  215.00     0.00 108640.00  1010.60   142.90  817.54   4.65 100.00
sda               0.00     2.00    0.00  166.00     0.00 83858.00  1010.34   143.64  808.61   6.02 100.00
sda               0.00     0.00    0.00  186.00     0.00 92813.00   997.99   141.18  736.95   5.38 100.00
sda               0.00     0.00    0.00  206.00     0.00 104456.00  1014.14   146.27  729.33   4.85 100.00
sda               0.00     0.00    0.00  213.00     0.00 107024.00  1004.92   143.25  705.70   4.69 100.00
sda               0.00     0.00    0.00  188.00     0.00 95748.00  1018.60   141.82  764.78   5.32 100.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.51    0.00   11.22   52.30    0.00   35.97
           0.25    0.00   10.15   52.54    0.00   37.06
           0.25    0.00    5.01   56.64    0.00   38.10
           0.51    0.00   15.15   43.94    0.00   40.40
           0.25    0.00   12.12   48.23    0.00   39.39
           0.51    0.00   11.20   53.94    0.00   34.35
           0.26    0.00    9.72   51.41    0.00   38.62
           0.76    0.00    9.62   50.63    0.00   38.99
           0.51    0.00   10.46   53.32    0.00   35.71
           0.51    0.00    9.41   51.91    0.00   38.17
           0.25    0.00   10.69   49.62    0.00   39.44
           0.51    0.00   12.21   52.67    0.00   34.61
           0.51    0.00   11.45   53.18    0.00   34.86

XXX: commit NFS unstable pages via write_inode()
XXX: the added congestion_wait() may be undesirable in some situations

CC: Jan Kara <jack@suse.cz>
CC: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
CC: Greg Thelen <gthelen@google.com>
CC: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c                |  169 ++++++++++++++++++++++++++++-
 include/linux/writeback.h        |    4 
 include/trace/events/writeback.h |   12 +-
 mm/vmscan.c                      |   35 ++++--
 4 files changed, 202 insertions(+), 18 deletions(-)

- move congestion_wait() out of the page lock: it's blocking btrfs lock_delalloc_pages()

--- linux.orig/mm/vmscan.c	2012-02-12 21:27:28.000000000 +0800
+++ linux/mm/vmscan.c	2012-02-13 12:14:20.000000000 +0800
@@ -767,7 +767,8 @@ static unsigned long shrink_page_list(st
 				      struct scan_control *sc,
 				      int priority,
 				      unsigned long *ret_nr_dirty,
-				      unsigned long *ret_nr_writeback)
+				      unsigned long *ret_nr_writeback,
+				      unsigned long *ret_nr_pgreclaim)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -776,6 +777,7 @@ static unsigned long shrink_page_list(st
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_pgreclaim = 0;
 
 	cond_resched();
 
@@ -813,6 +815,10 @@ static unsigned long shrink_page_list(st
 
 		if (PageWriteback(page)) {
 			nr_writeback++;
+			if (PageReclaim(page))
+				nr_pgreclaim++;
+			else
+				SetPageReclaim(page);
 			/*
 			 * Synchronous reclaim cannot queue pages for
 			 * writeback due to the possibility of stack overflow
@@ -874,12 +880,15 @@ static unsigned long shrink_page_list(st
 			nr_dirty++;
 
 			/*
-			 * Only kswapd can writeback filesystem pages to
-			 * avoid risk of stack overflow but do not writeback
-			 * unless under significant pressure.
+			 * run into the visited page again: we are scanning
+			 * faster than the flusher can writeout dirty pages
 			 */
-			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
+			if (page_is_file_cache(page) && PageReclaim(page)) {
+				nr_pgreclaim++;
+				goto keep_locked;
+			}
+			if (page_is_file_cache(page) && mapping &&
+			    flush_inode_page(mapping, page, false) >= 0) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -1028,6 +1037,7 @@ keep_lumpy:
 	count_vm_events(PGACTIVATE, pgactivate);
 	*ret_nr_dirty += nr_dirty;
 	*ret_nr_writeback += nr_writeback;
+	*ret_nr_pgreclaim += nr_pgreclaim;
 	return nr_reclaimed;
 }
 
@@ -1087,8 +1097,10 @@ int __isolate_lru_page(struct page *page
 	 */
 	if (mode & (ISOLATE_CLEAN|ISOLATE_ASYNC_MIGRATE)) {
 		/* All the caller can do on PageWriteback is block */
-		if (PageWriteback(page))
+		if (PageWriteback(page)) {
+			SetPageReclaim(page);
 			return ret;
+		}
 
 		if (PageDirty(page)) {
 			struct address_space *mapping;
@@ -1509,6 +1521,7 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_file;
 	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_pgreclaim = 0;
 	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
 	struct zone *zone = mz->zone;
 
@@ -1559,13 +1572,13 @@ shrink_inactive_list(unsigned long nr_to
 	spin_unlock_irq(&zone->lru_lock);
 
 	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
-						&nr_dirty, &nr_writeback);
+				&nr_dirty, &nr_writeback, &nr_pgreclaim);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
 		nr_reclaimed += shrink_page_list(&page_list, mz, sc,
-					priority, &nr_dirty, &nr_writeback);
+			priority, &nr_dirty, &nr_writeback, &nr_pgreclaim);
 	}
 
 	spin_lock_irq(&zone->lru_lock);
@@ -1608,6 +1621,8 @@ shrink_inactive_list(unsigned long nr_to
 	 */
 	if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+	if (nr_pgreclaim)
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
@@ -2382,8 +2397,6 @@ static unsigned long do_try_to_free_page
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
-						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
 
--- linux.orig/fs/fs-writeback.c	2012-02-12 21:27:28.000000000 +0800
+++ linux/fs/fs-writeback.c	2012-02-13 12:15:50.000000000 +0800
@@ -41,6 +41,8 @@ struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
 	unsigned long *older_than_this;
+	struct inode *inode;
+	pgoff_t offset;
 	enum writeback_sync_modes sync_mode;
 	unsigned int tagged_writepages:1;
 	unsigned int for_kupdate:1;
@@ -65,6 +67,27 @@ struct wb_writeback_work {
  */
 int nr_pdflush_threads;
 
+static mempool_t *wb_work_mempool;
+
+static void *wb_work_alloc(gfp_t gfp_mask, void *pool_data)
+{
+	/*
+	 * bdi_flush_inode_range() may be called on page reclaim
+	 */
+	if (current->flags & PF_MEMALLOC)
+		return NULL;
+
+	return kmalloc(sizeof(struct wb_writeback_work), gfp_mask);
+}
+
+static __init int wb_work_init(void)
+{
+	wb_work_mempool = mempool_create(1024,
+					 wb_work_alloc, mempool_kfree, NULL);
+	return wb_work_mempool ? 0 : -ENOMEM;
+}
+fs_initcall(wb_work_init);
+
 /**
  * writeback_in_progress - determine whether there is writeback in progress
  * @bdi: the device's backing_dev_info structure.
@@ -129,7 +152,7 @@ __bdi_start_writeback(struct backing_dev
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
-	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
 	if (!work) {
 		if (bdi->wb.task) {
 			trace_writeback_nowork(bdi);
@@ -138,6 +161,7 @@ __bdi_start_writeback(struct backing_dev
 		return;
 	}
 
+	memset(work, 0, sizeof(*work));
 	work->sync_mode	= WB_SYNC_NONE;
 	work->nr_pages	= nr_pages;
 	work->range_cyclic = range_cyclic;
@@ -186,6 +210,125 @@ void bdi_start_background_writeback(stru
 	spin_unlock_bh(&bdi->wb_lock);
 }
 
+static bool extend_writeback_range(struct wb_writeback_work *work,
+				   pgoff_t offset,
+				   unsigned long write_around_pages)
+{
+	pgoff_t end = work->offset + work->nr_pages;
+
+	if (offset >= work->offset && offset < end)
+		return true;
+
+	/*
+	 * for sequential workloads with good locality, include up to 8 times
+	 * more data in one chunk
+	 */
+	if (work->nr_pages >= 8 * write_around_pages)
+		return false;
+
+	/* the unsigned comparison helps eliminate one compare */
+	if (work->offset - offset < write_around_pages) {
+		work->nr_pages += write_around_pages;
+		work->offset -= write_around_pages;
+		return true;
+	}
+
+	if (offset - end < write_around_pages) {
+		work->nr_pages += write_around_pages;
+		return true;
+	}
+
+	return false;
+}
+
+/*
+ * schedule writeback on a range of inode pages.
+ */
+static struct wb_writeback_work *
+bdi_flush_inode_range(struct backing_dev_info *bdi,
+		      struct inode *inode,
+		      pgoff_t offset,
+		      pgoff_t len,
+		      bool wait)
+{
+	struct wb_writeback_work *work;
+
+	if (!igrab(inode))
+		return ERR_PTR(-ENOENT);
+
+	work = mempool_alloc(wb_work_mempool, wait ? GFP_NOIO : GFP_NOWAIT);
+	if (!work) {
+		trace_printk("wb_work_mempool alloc fail\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	memset(work, 0, sizeof(*work));
+	work->sync_mode		= WB_SYNC_NONE;
+	work->inode		= inode;
+	work->offset		= offset;
+	work->nr_pages		= len;
+	work->reason		= WB_REASON_PAGEOUT;
+
+	bdi_queue_work(bdi, work);
+
+	return work;
+}
+
+/*
+ * Called by page reclaim code to flush the dirty page ASAP. Do write-around to
+ * improve IO throughput. The nearby pages will have good chance to reside in
+ * the same LRU list that vmscan is working on, and even close to each other
+ * inside the LRU list in the common case of sequential read/write.
+ *
+ * ret > 0: success, found/reused a previous writeback work
+ * ret = 0: success, allocated/queued a new writeback work
+ * ret < 0: failed
+ */
+long flush_inode_page(struct address_space *mapping,
+		      struct page *page,
+		      bool wait)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct inode *inode = mapping->host;
+	struct wb_writeback_work *work;
+	unsigned long write_around_pages;
+	pgoff_t offset = page->index;
+	int i;
+	long ret = 0;
+
+	if (unlikely(!inode))
+		return -ENOENT;
+
+	/*
+	 * piggy back 8-15ms worth of data
+	 */
+	write_around_pages = bdi->avg_write_bandwidth + MIN_WRITEBACK_PAGES;
+	write_around_pages = rounddown_pow_of_two(write_around_pages) >> 6;
+
+	i = 1;
+	spin_lock_bh(&bdi->wb_lock);
+	list_for_each_entry_reverse(work, &bdi->work_list, list) {
+		if (work->inode != inode)
+			continue;
+		if (extend_writeback_range(work, offset, write_around_pages)) {
+			ret = i;
+			break;
+		}
+		if (i++ > 100)	/* limit search depth */
+			break;
+	}
+	spin_unlock_bh(&bdi->wb_lock);
+
+	if (!ret) {
+		offset = round_down(offset, write_around_pages);
+		work = bdi_flush_inode_range(bdi, inode,
+					     offset, write_around_pages, wait);
+		if (IS_ERR(work))
+			ret = PTR_ERR(work);
+	}
+	return ret;
+}
+
 /*
  * Remove the inode from the writeback list it is on.
  */
@@ -833,6 +976,23 @@ static unsigned long get_nr_dirty_pages(
 		get_nr_dirty_inodes();
 }
 
+static long wb_flush_inode(struct bdi_writeback *wb,
+			   struct wb_writeback_work *work)
+{
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = LONG_MAX,
+		.range_start = work->offset << PAGE_CACHE_SHIFT,
+		.range_end = (work->offset + work->nr_pages - 1)
+						<< PAGE_CACHE_SHIFT,
+	};
+
+	do_writepages(work->inode->i_mapping, &wbc);
+	iput(work->inode);
+
+	return LONG_MAX - wbc.nr_to_write;
+}
+
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
 	if (over_bground_thresh(wb->bdi)) {
@@ -905,7 +1065,10 @@ long wb_do_writeback(struct bdi_writebac
 
 		trace_writeback_exec(bdi, work);
 
-		wrote += wb_writeback(wb, work);
+		if (work->inode)
+			wrote += wb_flush_inode(wb, work);
+		else
+			wrote += wb_writeback(wb, work);
 
 		/*
 		 * Notify the caller of completion if this is a synchronous
@@ -914,7 +1077,7 @@ long wb_do_writeback(struct bdi_writebac
 		if (work->done)
 			complete(work->done);
 		else
-			kfree(work);
+			mempool_free(work, wb_work_mempool);
 	}
 
 	/*
--- linux.orig/include/trace/events/writeback.h	2012-02-12 21:27:33.000000000 +0800
+++ linux/include/trace/events/writeback.h	2012-02-12 21:27:34.000000000 +0800
@@ -23,7 +23,7 @@
 
 #define WB_WORK_REASON							\
 		{WB_REASON_BACKGROUND,		"background"},		\
-		{WB_REASON_TRY_TO_FREE_PAGES,	"try_to_free_pages"},	\
+		{WB_REASON_PAGEOUT,		"pageout"},		\
 		{WB_REASON_SYNC,		"sync"},		\
 		{WB_REASON_PERIODIC,		"periodic"},		\
 		{WB_REASON_LAPTOP_TIMER,	"laptop_timer"},	\
@@ -45,6 +45,8 @@ DECLARE_EVENT_CLASS(writeback_work_class
 		__field(int, range_cyclic)
 		__field(int, for_background)
 		__field(int, reason)
+		__field(unsigned long, ino)
+		__field(unsigned long, offset)
 	),
 	TP_fast_assign(
 		strncpy(__entry->name, dev_name(bdi->dev), 32);
@@ -55,9 +57,11 @@ DECLARE_EVENT_CLASS(writeback_work_class
 		__entry->range_cyclic = work->range_cyclic;
 		__entry->for_background	= work->for_background;
 		__entry->reason = work->reason;
+		__entry->ino = work->inode ? work->inode->i_ino : 0;
+		__entry->offset = work->offset;
 	),
 	TP_printk("bdi %s: sb_dev %d:%d nr_pages=%ld sync_mode=%d "
-		  "kupdate=%d range_cyclic=%d background=%d reason=%s",
+		  "kupdate=%d range_cyclic=%d background=%d reason=%s ino=%lu offset=%lu",
 		  __entry->name,
 		  MAJOR(__entry->sb_dev), MINOR(__entry->sb_dev),
 		  __entry->nr_pages,
@@ -65,7 +69,9 @@ DECLARE_EVENT_CLASS(writeback_work_class
 		  __entry->for_kupdate,
 		  __entry->range_cyclic,
 		  __entry->for_background,
-		  __print_symbolic(__entry->reason, WB_WORK_REASON)
+		  __print_symbolic(__entry->reason, WB_WORK_REASON),
+		  __entry->ino,
+		  __entry->offset
 	)
 );
 #define DEFINE_WRITEBACK_WORK_EVENT(name) \
--- linux.orig/include/linux/writeback.h	2012-02-12 21:27:28.000000000 +0800
+++ linux/include/linux/writeback.h	2012-02-12 21:27:34.000000000 +0800
@@ -40,7 +40,7 @@ enum writeback_sync_modes {
  */
 enum wb_reason {
 	WB_REASON_BACKGROUND,
-	WB_REASON_TRY_TO_FREE_PAGES,
+	WB_REASON_PAGEOUT,
 	WB_REASON_SYNC,
 	WB_REASON_PERIODIC,
 	WB_REASON_LAPTOP_TIMER,
@@ -94,6 +94,8 @@ long writeback_inodes_wb(struct bdi_writ
 				enum wb_reason reason);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
 void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
+long flush_inode_page(struct address_space *mapping, struct page *page,
+		      bool wait);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)

--AhhlLboLdkugWU4S
Content-Type: image/png
Content-Disposition: attachment; filename="global_dirtied_written.png"
Content-Transfer-Encoding: base64

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
4a8qXUdpgHXwxBNP3Hfffbq8d8eOHSNGjAicMHz48J07d8ZVH6xKx+T49e3bNzEx8bzzzrv1
1lvff//9uAuERcWUnLvvvnvy5MmbN29ua2tra2urqakpLi6+9957/aNcc1xFx+T4cc1xj3h+
Yfm9++67/m+47LiKjsnx47LjEuGT88ILL1x88cUdfxn+qtJ1lBsJIgv/d6murq5///4nT57U
5b1JSUknTpwInHPixInk5ORY6oVVmJkcn883YcKE11577fjx4wcPHvzzn/+clZW1fft2ibKh
nL7JaW9vv+mmmwIv++PHj++4j4hrjpOYmRwf1xxn0Tc8V1555fLlywNfefbZZzsuLFx2nMTM
5Pi47DhIPMk5ePDgkCFD/u///q/jlfBXla6jNMCRhf8n9NOf/nTu3Ll6vZffCk5iZnK6+t//
/d/rr78+/BxYk77JmTNnzsCBA1988UWv1+v1el988cWcnJxf/epX/lGuOU5iZnK64ppja/qG
Z+PGjX379l2+fHlra2tra+vSpUszMzNTUlL8o1x2nMTM5HTFZce+pJOzf//+MWPGvPTSS4Ev
0gDrL8w/oQMHDvTp0+fgwYN6vbdv37779+8PfGXfvn3nnntuLPXCKsxMTleff/75WWedFU2d
sBp9k3PBBRfU1NQEvlJTU5OTk+P/nmuOk5iZnK645tia7r+wXnnllXHjxp111lk9evS44oor
li1bxmXHkcxMTldcduxLLjlNTU0jRozo1P36Il1Vuo6yBzguTz755MSJE/v06aPXe4cOHfr2
228HvlJXV5eXlxdXlbAe3ZPTlY9nAziRRHI++eSTgoKCwFfy8/M/+eQT//dcc1xC9+R0xTXH
qeR+YY0dO/bll19ubW09evToG2+80bt3729961v+IS47LqF7crrisuNIoZLz6aef3nDDDY8/
/vh3v/vdTkPhrypdR2mA5Z08eXLBggVyO/tDvXf8+PGLFy8OfGXx4sUTJkyQrxLWY0Ryulq+
fPkVV1wh8UfAsuSSM2DAgO3btwe+sm3btv79+/u/55rjBkYkpyuuOY4Uzy+sQH/605+mT5/u
/57LjhsYkZyuuOw4T6jkfPbZZ4WFhb/61a+uvvrqru8Kf1XpOsot0JGF+rv017/+9dprr9X3
vZ9//nlOTs6cOXMOHTp06NChX/7ylxdeeGFra2usNcMKzEzO1VdfvWLFin379p06dWrfvn3z
5s3LzMysra2NtWZYgb7J+f3vfz9o0KB169YdPXr06NGjL7zwwgUXXPCHP/zBP8o1x0nMTA7X
HIfR/RfWxIkTt2/ffuLEid27d99xxx133nlnxxCXHScxMzlcdpwk1uRccsklzz77bKhPC39V
6TpKAxxS0P8tEThh9OjRa9eu1f29H3/88fe///1evXr16tXr+9//fn19vV4/EcyhJDkbN278
wQ9+cM455yQmJvbr12/q1Knvv/++jj8UTGBcchYtWpSfn9+9e/fu3bvn5+f/5S9/CXwv1xy7
U5IcrjnOYFx4li5dmpeXl5ycfNFFFz3xxBPt7e2B7+WyY3dKksNlxwGkkxP0jS0tLR0Twl9V
Oo1qoT4RAAAAAAAnYQ8wAAAAAMAVaIABAAAAAK5AAwwAAAAAcAUaYAAAAACAK9AAAwAAAABc
gQYYAAAAAOAKNMAAAAAAAFegAQYAAAAAuAINMAAAAADAFWiAAQAAAACuQAMMAAAAAHAFGmAA
AAAAgCvQAAMAAAAAXIEGGAAAAADgCjTAAAAAAABXoAEGAAAAALgCDTAAALakaZrRf8THH3+c
kpJSWloacWZpaWlKSkp9fb3RJQEAEA/N5/OprgEAAESgaZ1/ZXd9RXe33357bW1tbW1t9+7d
w888fvz4pZdeOnr06P/5n/8xtCQAAOJBAwwAgA2Y0O52sm/fvuzs7A0bNowZMyaa+a+88sr1
11+/d+/evn37Gl0bAAByuAUaAACr89/trH0p8EX/N1988cX06dP79OnTu3fv+++//9SpU62t
rdOmTevdu3d6evq999576tSpjk979dVXR40alZKScsEFFyxatCjUH7p06dIrrrgisPttaWm5
5557srOzk5KSevfufe21165du7Zj9Kqrrho1atSyZcv0/dkBANARDTAAAFbnX/v1fanrhLvv
vvu73/1uU1PTu+++u3379oqKirvuuuvaa6/dt2/fu++++8477/z3f/+3f+Zbb701adKkBx98
8MiRI88///yvf/3rF154Iegf+tJLL5WUlAS+8sMf/jA1NXXTpk3Hjx//+OOP77vvvt///veB
E26//fb169fr8zMDAGAAboEGAMAGwuwB1jStsrJy+vTp/te3bt06duzYJ554ouOVLVu2/PjH
P3733XeFEMXFxWPGjLnnnnv8Q9XV1b/97W9feumlrn/i+eef/8orrwwaNKjjleTk5M8//zwl
JSVUkR9++OF3v/vdxsbGuH5UAAAMQwMMAIANhG+ADxw4kJGR4X/9+PHjPXr06PRKenr68ePH
hRDnnnvu5s2bs7Oz/UNer/f8889vaWnp+icmJSV5vd7k5OSOV/Lz80ePHv2f//mf/fr1C1rk
iRMnUlNTT5w4Ee9PCwCAMbgFGgAA2+vodYUQ/hXaTq+0tbX5vz948OAFF1zQsZ04NTX1yJEj
Uf4py5cvb2pquvDCC3Nzc0tKSv72t7+dPn1avx8CAADD0QADAOAi6enphw4d8gUI1cSee+65
nW5mHjx48Nq1a48cObJ06dLvfOc7FRUVt99+e+CE+vr6c88918DqAQCIDw0wAAA2kJCQ0N7e
Hv/njBs3bvXq1dHMHD58+Ouvv9719e7du48YMeKOO+5Yv379ypUrA4dee+214cOHx18kAAAG
oQEGAMAGBg4cuG7duvhP7pg9e/ZDDz20bNkyr9fr9Xo3btx40003BZ153XXXVVVVBb4yZsyY
qqqqpqam9vZ2j8fz+OOPjxs3LnDCM888c91118VZIQAAxqEBBgDABn7961/fddddCQkJHY//
lTN06NC1a9c+/fTT5513XmZm5i9/+csZM2YEnTl58uTXX3/9zTff7Hjl0Ucffe655y655JLu
3btfeumlLS0tzz77bMfoa6+99s9//nPy5MnxlAcAgKE4BRoAAAR3++23b9++fevWrYFnQQfV
1tY2cuTISy+99KmnnjKlNAAAZNAAAwCA4D7++OPc3Nwf//jHCxYsCD/zzjvvfOqpp957772c
nBxzagMAQAINMAAAAADAFdgDDAAAAABwBRpgAAAAAIAr0AADAAAAAFyBBhgAAAAA4Ar/HxVR
GBKRoDt5AAAAAElFTkSuQmCC

--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=iostat

Linux 3.3.0-rc3-flush-page+ (snb) 	02/14/2012 	_x86_64_	(32 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.03    0.00    0.05    0.38    0.00   99.54

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.20    33.00    0.05    2.91     0.16  1025.66   694.73     1.50  508.37   6.10   1.80

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.90    0.00    5.72    0.00    0.00   93.38

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    1.00    0.00     8.00     0.00    16.00     0.00    1.00   1.00   0.10

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.90    0.00    5.82    0.00    0.00   93.28

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.90    0.00    5.81    0.00    0.00   93.29

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.83    0.00    5.84    0.00    0.00   93.33

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.83    0.00    5.94    0.00    0.00   93.23

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   370.00    0.00   71.00     0.00 12480.00   351.55    11.17   71.76   3.56  25.30

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.80    0.00    5.84    0.00    0.00   93.35

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00    65.00    0.00   51.00     0.00 13104.00   513.88     2.85  170.22   4.00  20.40

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.87    0.00    5.93    0.00    0.00   93.20

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   379.00    0.00  134.00     0.00 30004.00   447.82    15.43  116.99   4.11  55.10

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.90    0.00    5.91    0.00    0.00   93.19

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   133.00    0.00  114.00     0.00 12792.00   224.42     3.20   28.12   2.30  26.20

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.83    0.00    5.96    0.00    0.00   93.21

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   367.00    0.00  114.00     0.00 24960.00   437.89    12.55  110.12   4.35  49.60

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.80    0.00    6.03    0.03    0.00   93.14

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   205.00    0.00  163.00     0.00 16900.00   207.36     4.09   21.63   1.88  30.70

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.87    0.00    5.98    0.00    0.00   93.16

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   219.00    0.00  182.00     0.00 19292.00   212.00     4.42   21.41   1.97  35.80

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.93    0.00    5.87    0.00    0.00   93.20

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   201.00    0.00  135.00     0.00 21216.00   314.31     6.39   55.44   2.97  40.10

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.93    0.00    5.99    0.00    0.00   93.08

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   329.00    0.00  166.00     0.00 24336.00   293.20    10.42   58.39   3.19  53.00

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.80    0.00    5.96    0.00    0.00   93.24

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   258.00    0.00  181.00     0.00 16848.00   186.17     4.01   17.64   1.36  24.70

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.90    0.00    5.92    0.00    0.00   93.18

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   166.00    0.00   88.00     0.00 20488.00   465.64     6.09   86.72   4.68  41.20

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.86    0.00    6.05    0.00    0.00   93.08

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   566.00    0.00  194.00     0.00 34528.00   355.96    20.50   78.32   3.16  61.30

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.86    0.00    5.79    0.00    0.00   93.34

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00   12.00     0.00  5616.00   936.00     0.77  506.67   9.58  11.50

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.90    0.00    5.93    0.00    0.00   93.18

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   259.00    0.00  173.00     0.00 22464.00   259.70     4.79   27.67   2.09  36.10

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.74    0.00    6.16    0.00    0.00   93.10

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00   190.00    0.00  163.00     0.00 18304.00   224.59     3.67   22.50   1.78  29.00


--AhhlLboLdkugWU4S--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
