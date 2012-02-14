Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D731E6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 08:29:53 -0500 (EST)
Date: Tue, 14 Feb 2012 14:29:50 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120214132950.GE1934@quack.suse.cz>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <4F36816A.6030609@redhat.com>
 <20120212031029.GA17435@localhost>
 <20120213154313.GD6478@quack.suse.cz>
 <20120214100348.GA7000@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120214100348.GA7000@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Tue 14-02-12 18:03:48, Wu Fengguang wrote:
> On Mon, Feb 13, 2012 at 04:43:13PM +0100, Jan Kara wrote:
> > On Sun 12-02-12 11:10:29, Wu Fengguang wrote:
> 
> > > 4) test case
> > > 
> > > Run 2 dd tasks in a 100MB memcg (a very handy test case from Greg Thelen):
> > > 
> > > 	mkdir /cgroup/x
> > > 	echo 100M > /cgroup/x/memory.limit_in_bytes
> > > 	echo $$ > /cgroup/x/tasks
> > > 
> > > 	for i in `seq 2`
> > > 	do
> > > 		dd if=/dev/zero of=/fs/f$i bs=1k count=1M &
> > > 	done
> > > 
> > > Before patch, the dd tasks are quickly OOM killed.
> > > After patch, they run well with reasonably good performance and overheads:
> > > 
> > > 1073741824 bytes (1.1 GB) copied, 22.2196 s, 48.3 MB/s
> > > 1073741824 bytes (1.1 GB) copied, 22.4675 s, 47.8 MB/s
> >   I wonder what happens if you run:
> >        mkdir /cgroup/x
> >        echo 100M > /cgroup/x/memory.limit_in_bytes
> >        echo $$ > /cgroup/x/tasks
> > 
> >        for (( i = 0; i < 2; i++ )); do
> >          mkdir /fs/d$i
> >          for (( j = 0; j < 5000; j++ )); do 
> >            dd if=/dev/zero of=/fs/d$i/f$j bs=1k count=50
> >          done &
> >        done
> 
> That's a very good case, thanks!
>  
> >   Because for small files the writearound logic won't help much...
> 
> Right, it also means the native background work cannot be more I/O
> efficient than the pageout works, except for the overheads of more
> work items..
  Yes, that's true.

> >   Also the number of work items queued might become interesting.
> 
> It turns out that the 1024 mempool reservations are not exhausted at
> all (the below patch as a trace_printk on alloc failure and it didn't
> trigger at all).
> 
> Here is the representative iostat lines on XFS (full "iostat -kx 1 20" log attached):
> 
> avg-cpu:  %user   %nice %system %iowait  %steal   %idle                                                                     
>            0.80    0.00    6.03    0.03    0.00   93.14                                                                     
>                                                                                                                             
> Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util                   
> sda               0.00   205.00    0.00  163.00     0.00 16900.00   207.36     4.09   21.63   1.88  30.70                   
> 
> The attached dirtied/written progress graph looks interesting.
> Although the iostat disk utilization is low, the "dirtied" progress
> line is pretty straight and there is no single congestion_wait event
> in the trace log. Which makes me wonder if there are some unknown
> blocking issues in the way.
  Interesting. I'd also expect we should block in reclaim path. How fast
can dd threads progress when there is no cgroup involved?
 
> > Another common case to test - run 'slapadd' command in each cgroup to
> > create big LDAP database. That does pretty much random IO on a big mmaped
> > DB file.
> 
> I've not used this. Will it need some configuration and data feed?
> fio looks more handy to me for emulating mmap random IO.
  Yes, fio can generate random mmap IO. It's just that this is a real life
workload. So it is not completely random, it happens on several files and
is also interleaved with other memory allocations from DB. I can send you
the config files and data feed if you are interested.

> > > +/*
> > > + * schedule writeback on a range of inode pages.
> > > + */
> > > +static struct wb_writeback_work *
> > > +bdi_flush_inode_range(struct backing_dev_info *bdi,
> > > +		      struct inode *inode,
> > > +		      pgoff_t offset,
> > > +		      pgoff_t len,
> > > +		      bool wait)
> > > +{
> > > +	struct wb_writeback_work *work;
> > > +
> > > +	if (!igrab(inode))
> > > +		return ERR_PTR(-ENOENT);
> >   One technical note here: If the inode is deleted while it is queued, this
> > reference will keep it living until flusher thread gets to it. Then when
> > flusher thread puts its reference, the inode will get deleted in flusher
> > thread context. I don't see an immediate problem in that but it might be
> > surprising sometimes. Another problem I see is that if you try to
> > unmount the filesystem while the work item is queued, you'll get EBUSY for
> > no apparent reason (for userspace).
> 
> Yeah, we need to make umount work.
  The positive thing is that if the inode is reaped while the work item is
queue, we know all that needed to be done is done. So we don't really need
to pin the inode.

> And I find the pageout works seem to have some problems with ext4.
> For example, this can be easily triggered with 10 dd tasks running
> inside the 100MB limited memcg:
  So journal thread is getting stuck while committing transaction. Most
likely waiting for some dd thread to stop a transaction so that commit can
proceed. The processes waiting in start_this_handle() are just secondary
effect resulting from the first problem. It might be interesting to get
stack traces of all bloked processes when the journal thread is stuck.


> [18006.858109] INFO: task jbd2/sda1-8:51294 blocked for more than 120 seconds.
> [18006.866425] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [18006.876096] jbd2/sda1-8     D 0000000000000000  5464 51294      2 0x00000000
> [18006.884729]  ffff88040b097c70 0000000000000046 ffff880823032310 ffff88040b096000
> [18006.894356]  00000000001d2f00 00000000001d2f00 ffff8808230322a0 00000000001d2f00
> [18006.904000]  ffff88040b097fd8 00000000001d2f00 ffff88040b097fd8 00000000001d2f00
> [18006.913652] Call Trace:
> [18006.916901]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
> [18006.924134]  [<ffffffff81232aab>] ? jbd2_journal_commit_transaction+0x1d0/0x1281
> [18006.933324]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
> [18006.939879]  [<ffffffff810b0ddd>] ? lock_release_holdtime+0xa3/0xac
> [18006.947410]  [<ffffffff81232aab>] ? jbd2_journal_commit_transaction+0x1d0/0x1281
> [18006.956607]  [<ffffffff81a57904>] schedule+0x5a/0x5c
> [18006.962677]  [<ffffffff81232ab0>] jbd2_journal_commit_transaction+0x1d5/0x1281
> [18006.971683]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
> [18006.978933]  [<ffffffff810738ce>] ? try_to_del_timer_sync+0xba/0xc8
> [18006.986452]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
> [18006.992999]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
> [18006.999542]  [<ffffffff810738ce>] ? try_to_del_timer_sync+0xba/0xc8
> [18007.007062]  [<ffffffff81073a6f>] ? del_timer_sync+0xbb/0xce
> [18007.013898]  [<ffffffff810739b4>] ? process_timeout+0x10/0x10
> [18007.020835]  [<ffffffff81237bc1>] kjournald2+0xcf/0x242
> [18007.027187]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
> [18007.033733]  [<ffffffff81237af2>] ? commit_timeout+0x10/0x10
> [18007.040574]  [<ffffffff81086384>] kthread+0x95/0x9d
> [18007.046542]  [<ffffffff81a61134>] kernel_thread_helper+0x4/0x10
> [18007.053675]  [<ffffffff81a591b4>] ? retint_restore_args+0x13/0x13
> [18007.061003]  [<ffffffff810862ef>] ? __init_kthread_worker+0x5b/0x5b
> [18007.068521]  [<ffffffff81a61130>] ? gs_change+0x13/0x13
> [18007.074878] no locks held by jbd2/sda1-8/51294.
> 
> Sometimes I also catch dd/ext4lazyinit/flush all stalling in start_this_handle:
> 
> [17985.439567] dd              D 0000000000000007  3616 61440      1 0x00000004
> [17985.448088]  ffff88080d71b9b8 0000000000000046 ffff88081ec80070 ffff88080d71a000
> [17985.457545]  00000000001d2f00 00000000001d2f00 ffff88081ec80000 00000000001d2f00
> [17985.467168]  ffff88080d71bfd8 00000000001d2f00 ffff88080d71bfd8 00000000001d2f00
> [17985.476647] Call Trace:
> [17985.479843]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
> [17985.487025]  [<ffffffff81230b9d>] ? start_this_handle+0x357/0x4ed
> [17985.494313]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
> [17985.500815]  [<ffffffff810b0ddd>] ? lock_release_holdtime+0xa3/0xac
> [17985.508287]  [<ffffffff81230b9d>] ? start_this_handle+0x357/0x4ed
> [17985.515575]  [<ffffffff81a57904>] schedule+0x5a/0x5c
> [17985.521588]  [<ffffffff81230c39>] start_this_handle+0x3f3/0x4ed
> [17985.528669]  [<ffffffff81147820>] ? kmem_cache_free+0xfa/0x13a
> [17985.545142]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
> [17985.551650]  [<ffffffff81230f0e>] jbd2__journal_start+0xb0/0xf6
> [17985.558732]  [<ffffffff811f7ad7>] ? ext4_dirty_inode+0x1d/0x4c
> [17985.565716]  [<ffffffff81230f67>] jbd2_journal_start+0x13/0x15
> [17985.572703]  [<ffffffff8120e3e9>] ext4_journal_start_sb+0x13f/0x157
> [17985.580172]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
> [17985.586680]  [<ffffffff811f7ad7>] ext4_dirty_inode+0x1d/0x4c
> [17985.593472]  [<ffffffff81176827>] __mark_inode_dirty+0x2e/0x1cc
> [17985.600552]  [<ffffffff81168e84>] file_update_time+0xe4/0x106
> [17985.607441]  [<ffffffff811079f6>] __generic_file_aio_write+0x254/0x364
> [17985.615202]  [<ffffffff81a565da>] ? mutex_lock_nested+0x2e4/0x2f3
> [17985.622488]  [<ffffffff81107b50>] ? generic_file_aio_write+0x4a/0xc1
> [17985.630057]  [<ffffffff81107b6c>] generic_file_aio_write+0x66/0xc1
> [17985.637442]  [<ffffffff811ef72b>] ext4_file_write+0x1f9/0x251
> [17985.644330]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
> [17985.650835]  [<ffffffff8118809e>] ? fsnotify+0x222/0x27b
> [17985.657238]  [<ffffffff81153612>] do_sync_write+0xce/0x10b
> [17985.663844]  [<ffffffff8118809e>] ? fsnotify+0x222/0x27b
> [17985.670243]  [<ffffffff81187ef8>] ? fsnotify+0x7c/0x27b
> [17985.676561]  [<ffffffff81153dbe>] vfs_write+0xb8/0x157
> [17985.682767]  [<ffffffff81154075>] sys_write+0x4d/0x77
> [17985.688878]  [<ffffffff81a5fce9>] system_call_fastpath+0x16/0x1b
> 
> and jbd2 in
> 
> [17983.623657] jbd2/sda1-8     D 0000000000000000  5464 51294      2 0x00000000
> [17983.632173]  ffff88040b097c70 0000000000000046 ffff880823032310 ffff88040b096000
> [17983.641640]  00000000001d2f00 00000000001d2f00 ffff8808230322a0 00000000001d2f00
> [17983.651119]  ffff88040b097fd8 00000000001d2f00 ffff88040b097fd8 00000000001d2f00
> [17983.660603] Call Trace:
> [17983.663808]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
> [17983.670997]  [<ffffffff81232aab>] ? jbd2_journal_commit_transaction+0x1d0/0x1281
> [17983.680124]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
> [17983.686638]  [<ffffffff810b0ddd>] ? lock_release_holdtime+0xa3/0xac
> [17983.694108]  [<ffffffff81232aab>] ? jbd2_journal_commit_transaction+0x1d0/0x1281
> [17983.703243]  [<ffffffff81a57904>] schedule+0x5a/0x5c
> [17983.709262]  [<ffffffff81232ab0>] jbd2_journal_commit_transaction+0x1d5/0x1281
> [17983.718195]  [<ffffffff8103d4af>] ? native_sched_clock+0x29/0x70
> [17983.725392]  [<ffffffff810738ce>] ? try_to_del_timer_sync+0xba/0xc8
> [17983.732867]  [<ffffffff8109660d>] ? local_clock+0x41/0x5a
> [17983.739374]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
> [17983.745864]  [<ffffffff810738ce>] ? try_to_del_timer_sync+0xba/0xc8
> [17983.753343]  [<ffffffff81073a6f>] ? del_timer_sync+0xbb/0xce
> [17983.760137]  [<ffffffff810739b4>] ? process_timeout+0x10/0x10
> [17983.767041]  [<ffffffff81237bc1>] kjournald2+0xcf/0x242
> [17983.773361]  [<ffffffff8108683a>] ? wake_up_bit+0x2a/0x2a
> [17983.779863]  [<ffffffff81237af2>] ? commit_timeout+0x10/0x10
> [17983.786665]  [<ffffffff81086384>] kthread+0x95/0x9d
> [17983.792585]  [<ffffffff81a61134>] kernel_thread_helper+0x4/0x10
> [17983.799670]  [<ffffffff81a591b4>] ? retint_restore_args+0x13/0x13
> [17983.806948]  [<ffffffff810862ef>] ? __init_kthread_worker+0x5b/0x5b
> 
> Here is the updated patch used in the new tests. It moves
> congestion_wait() out of the page lock and make flush_inode_page() no
> longer wait for memory allocation (looks unnecessary).

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
