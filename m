Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4735C6B0003
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 19:04:09 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s22so4676240pfh.21
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 16:04:09 -0800 (PST)
Received: from mail.ewheeler.net (mx.ewheeler.net. [66.155.3.69])
        by mx.google.com with ESMTP id w23si6409194pgc.569.2018.01.28.16.04.06
        for <linux-mm@kvack.org>;
        Sun, 28 Jan 2018 16:04:07 -0800 (PST)
Date: Mon, 29 Jan 2018 00:04:02 +0000 (UTC)
From: Eric Wheeler <linux-mm@lists.ewheeler.net>
Subject: Re: Possible deadlock in v4.14.15 contention on shrinker_rwsem in
 shrink_slab()
In-Reply-To: <4e9300f9-14c4-84a9-2258-b7e52bb6f753@I-love.SAKURA.ne.jp>
Message-ID: <alpine.LRH.2.11.1801272305200.20457@mail.ewheeler.net>
References: <alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net> <20180125083516.GA22396@dhcp22.suse.cz> <alpine.LRH.2.11.1801261846520.7450@mail.ewheeler.net> <4e9300f9-14c4-84a9-2258-b7e52bb6f753@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Tejun Heo <tj@kernel.org>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>

On Sat, 27 Jan 2018, Tetsuo Handa wrote:
> On 2018/01/27 4:32, Eric Wheeler wrote:
> > On Thu, 25 Jan 2018, Michal Hocko wrote:
> > 
> >> [CC Kirill, Minchan]
> >> On Wed 24-01-18 23:57:42, Eric Wheeler wrote:
> >>> Hello all,
> >>>
> >>> We are getting processes stuck with /proc/pid/stack listing the following:
> >>>
> >>> [<ffffffffac0cd0d2>] io_schedule+0x12/0x40
> >>> [<ffffffffac1b4695>] __lock_page+0x105/0x150
> >>> [<ffffffffac1b4dc1>] pagecache_get_page+0x161/0x210
> >>> [<ffffffffac1d4ab4>] shmem_unused_huge_shrink+0x334/0x3f0
> >>> [<ffffffffac251546>] super_cache_scan+0x176/0x180
> >>> [<ffffffffac1cb6c5>] shrink_slab+0x275/0x460
> >>> [<ffffffffac1d0b8e>] shrink_node+0x10e/0x320
> >>> [<ffffffffac1d0f3d>] node_reclaim+0x19d/0x250
> >>> [<ffffffffac1be0aa>] get_page_from_freelist+0x16a/0xac0
> >>> [<ffffffffac1bed87>] __alloc_pages_nodemask+0x107/0x290
> >>> [<ffffffffac06dbc3>] pte_alloc_one+0x13/0x40
> >>> [<ffffffffac1ef329>] __pte_alloc+0x19/0x100
> >>> [<ffffffffac1f17b8>] alloc_set_pte+0x468/0x4c0
> >>> [<ffffffffac1f184a>] finish_fault+0x3a/0x70
> >>> [<ffffffffac1f369a>] __handle_mm_fault+0x94a/0x1190
> >>> [<ffffffffac1f3fa4>] handle_mm_fault+0xc4/0x1d0
> >>> [<ffffffffac0682a3>] __do_page_fault+0x253/0x4d0
> >>> [<ffffffffac068553>] do_page_fault+0x33/0x120
> >>> [<ffffffffac8019dc>] page_fault+0x4c/0x60
> >>>
> >>>
> >>> For some reason io_schedule is not coming back,
> >>
> >> Is this a permanent state or does the holder eventually releases the
> >> lock? It smells like somebody hasn't unlocked the shmem page. Tracking
> >> those is a major PITA... :/
> > 
> > Perpetual. It's been locked for a couple days now on two different 
> > servers, both running the same 4.14.15 build.
> > 
> >> Do you remember the last good kernel?
> > 
> > We were stable on 4.1.y for a long time. The only reason we are updating 
> > is because of the Spectre/Meltdown issues.
> > 
> > I can probably test with 4.9 and let you know if we have the same problem. 

I just tried v4.9.78 and we still get the deadlock. I've backported your 
MemAlloc timing patch and yout timing is included in the output.  Both 
full sysrq traces (30 seconds apart) are available here and I made sure it 
includes both "Showing busy workqueues and worker pools" sections:

  https://www.linuxglobal.com/static/2018-01-27-hv1-deadlock-v4.9.78

# ps -eo pid,lstart,cmd,stat |grep D
  PID                  STARTED CMD                         STAT
16127 Sat Jan 27 05:24:29 2018 crm_node -N 2               D    << Both in D state
22444 Sat Jan 27 05:39:50 2018 rsync --server --sender -vl DNs  << Both in D state


"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
crm_node        D    0 16127  16126 0x00000080
MemAlloc: crm_node(16127) flags=0xc00900 switches=10 seq=441 gfp=0x24200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=209469 uninterruptible
ffff8cf6d750dd00 0000000000000000 ffff8cf74b9d5800 ffff8cf76fd19940
ffff8cf6c3d84200 ffffada2a17af6c8 ffffffff8e7178f5 0000000000000000
0000000000000000 0000000000000000 ffff8cf6c3d84200 7fffffffffffffff
Call Trace:
[<ffffffff8e7178f5>] ? __schedule+0x195/0x630
[<ffffffff8e718630>] ? bit_wait+0x50/0x50
[<ffffffff8e717dc6>] schedule+0x36/0x80
[<ffffffff8e71afa6>] schedule_timeout+0x1e6/0x320
[<ffffffff8e718630>] ? bit_wait+0x50/0x50
[<ffffffff8e7176f6>] io_schedule_timeout+0xa6/0x110
[<ffffffff8e71864b>] bit_wait_io+0x1b/0x60
[<ffffffff8e718286>] __wait_on_bit_lock+0x86/0xd0
[<ffffffff8e1acb22>] __lock_page+0x82/0xb0
[<ffffffff8e0e9e00>] ? autoremove_wake_function+0x40/0x40
[<ffffffff8e1ae63b>] pagecache_get_page+0x16b/0x230
[<ffffffff8e1ca3da>] shmem_unused_huge_shrink+0x28a/0x330
[<ffffffff8e1ca4a7>] shmem_unused_huge_scan+0x27/0x30
[<ffffffff8e23f941>] super_cache_scan+0x181/0x190
[<ffffffff8e1c1ab1>] shrink_slab+0x261/0x470
[<ffffffff8e1c6588>] shrink_node+0x108/0x310
[<ffffffff8e1c6927>] node_reclaim+0x197/0x210
[<ffffffff8e1b5dd8>] get_page_from_freelist+0x168/0x9f0
[<ffffffff8e1adc8e>] ? find_get_entry+0x1e/0x100
[<ffffffff8e1ca9c5>] ? shmem_getpage_gfp+0xf5/0xbb0
[<ffffffff8e1b77ae>] __alloc_pages_nodemask+0x10e/0x2d0
[<ffffffff8e207d08>] alloc_pages_current+0x88/0x120
[<ffffffff8e070287>] pte_alloc_one+0x17/0x40
[<ffffffff8e1e117e>] __pte_alloc+0x1e/0x100
[<ffffffff8e1e3622>] alloc_set_pte+0x4f2/0x560
[<ffffffff8e1e3770>] do_fault+0xe0/0x620
[<ffffffff8e1e5504>] handle_mm_fault+0x644/0xdd0
[<ffffffff8e06a96e>] __do_page_fault+0x25e/0x4f0
[<ffffffff8e06ac30>] do_page_fault+0x30/0x80
[<ffffffff8e003b55>] ? do_syscall_64+0x175/0x180
[<ffffffff8e71dae8>] page_fault+0x28/0x30

Pid 22444 didn't show up in the hung_task warning like crm_node did,
but its /proc/pid/stack looks like so:

~]# cat /proc/22444/stack
[<ffffffff8e1acb22>] __lock_page+0x82/0xb0
[<ffffffff8e1addd1>] find_lock_entry+0x61/0x80
[<ffffffff8e1ca9c5>] shmem_getpage_gfp+0xf5/0xbb0
[<ffffffff8e1cb9b9>] shmem_file_read_iter+0x159/0x310
[<ffffffff8e23b2ff>] __vfs_read+0xdf/0x130
[<ffffffff8e23ba2c>] vfs_read+0x8c/0x130
[<ffffffff8e23cf95>] SyS_read+0x55/0xc0
[<ffffffff8e003a47>] do_syscall_64+0x67/0x180
[<ffffffff8e71c530>] entry_SYSCALL64_slow_path+0x25/0x25
[<ffffffffffffffff>] 0xffffffffffffffff


==================== 4.14.15 ====================

On the other server running 4.14.15 the stacks look the same as you've 
seen before.  Both full sysrq traces (30 seconds apart) are available here 
and I made sure it includes both "Showing busy workqueues and worker 
pools" sections:

	https://www.linuxglobal.com/static/2018-01-28-hv2-deadlock-v4.14.15

~]# ps -eo pid,lstart,cmd,stat |grep D
  PID                  STARTED CMD                         STAT
27163 Sat Jan 27 05:15:48 2018 crm_node -N 2               D
 1125 Sat Jan 27 14:34:40 2018 /usr/sbin/libvirtd          D

I'm not sure if this is relevant, but the load average is wrong on the
4.14.15 machine:
  load average: 1308.46, 1246.69, 1078.29
There is no way those numbers are correct, top shows nothing spinning
and vmstat only shows 1-4 processes in a running or blocked state.

Here are the pid stacks in D states from ps above:

~]# cat /proc/27163/stack 
[<ffffffff900cd0d2>] io_schedule+0x12/0x40
[<ffffffff901b4735>] __lock_page+0x105/0x150
[<ffffffff901b4e61>] pagecache_get_page+0x161/0x210
[<ffffffff901d4c74>] shmem_unused_huge_shrink+0x334/0x3f0
[<ffffffff90251746>] super_cache_scan+0x176/0x180
[<ffffffff901cb885>] shrink_slab+0x275/0x460
[<ffffffff901d0d4e>] shrink_node+0x10e/0x320
[<ffffffff901d10fd>] node_reclaim+0x19d/0x250
[<ffffffff901be1ca>] get_page_from_freelist+0x16a/0xac0
[<ffffffff901bef81>] __alloc_pages_nodemask+0x111/0x2c0
[<ffffffff9006dbc3>] pte_alloc_one+0x13/0x40
[<ffffffff901ef4e9>] __pte_alloc+0x19/0x100
[<ffffffff901f1978>] alloc_set_pte+0x468/0x4c0
[<ffffffff901f1a0a>] finish_fault+0x3a/0x70
[<ffffffff901f385a>] __handle_mm_fault+0x94a/0x1190
[<ffffffff901f4192>] handle_mm_fault+0xf2/0x210
[<ffffffff900682a3>] __do_page_fault+0x253/0x4d0
[<ffffffff90068553>] do_page_fault+0x33/0x120
[<ffffffff908019dc>] page_fault+0x4c/0x60
[<ffffffffffffffff>] 0xffffffffffffffff


~]# cat /proc/1125/stack 
[<ffffffff907538d3>] call_rwsem_down_write_failed+0x13/0x20
[<ffffffff901cbb45>] register_shrinker+0x45/0xa0
[<ffffffff90251168>] sget_userns+0x468/0x4a0
[<ffffffff9025126a>] mount_nodev+0x2a/0xa0
[<ffffffff90251de4>] mount_fs+0x34/0x150
[<ffffffff902703f2>] vfs_kern_mount+0x62/0x120
[<ffffffff90272c0e>] do_mount+0x1ee/0xc50
[<ffffffff9027397e>] SyS_mount+0x7e/0xd0
[<ffffffff90003831>] do_syscall_64+0x61/0x1a0
[<ffffffff9080012c>] entry_SYSCALL64_slow_path+0x25/0x25
[<ffffffffffffffff>] 0xffffffffffffffff

> > If you have any ideas on creating an easy way to reproduce the problem, 
> > then I can bisect---but bisecting one day at a time will take a long time, 
> > and could be prone to bugs which I would like to avoid on this production 
> > system.
> > 
> Thinking from SysRq-t output, I feel that some disk read is stuck.

Possibly.  I would not expect a hardware problem since we see this on two 
different systems with different kernel versions.

> Since rsyslogd failed to catch portion of SysRq-t output, I can't confirm
> whether register_shrinker() was in progress (nor all kernel worker threads
> were reported).

As linked above, I was able to get the full trace with netconsole.

> But what I was surprised is number of kernel worker threads.
> "grep ^kworker/ | sort" matched 314 threads and "grep ^kworker/0:"
> matched 244.

We have many DRBD volumes and LVM volumes, most of which are dm-thin, so 
that might be why. Also these servers have both scsi-mq and dm-mq enabled.

> ----------
> kworker/3:69    I    0 13343      2 0x80000080
> kworker/3:70    R  running task        0 13344      2 0x80000080
> kworker/4:0     I    0  7454      2 0x80000080
> kworker/4:0H    I    0    36      2 0x80000000
[snip]
> kworker/4:1H    I    0   456      2 0x80000000
> kworker/4:8     I    0 23606      2 0x80000080
> ----------
> 
> Although most of them were idle, and the system had enough free memory
> for creating workqueues, is there possibility that waiting for a work
> item to complete get stuck due to workqueue availability?
> ( Was there no "Showing busy workqueues and worker pools:" line?
> http://lkml.kernel.org/r/20170502041235.zqmywvj5tiiom3jk@merlins.org had it. )

The missing "Showing busy workqueues and worker pools:" line was a
capture problem on my end, this has been fixed in the new traces linked above.

> ----------
> kworker/0:262   I    0 31402      2 0x80000080
> Call Trace:
> ? __schedule+0x1dc/0x770
> ? cached_dev_write_complete+0x2c/0x60 [bcache]
> schedule+0x32/0x80
> worker_thread+0xc3/0x3e0
> kthread+0xfc/0x130
> ? rescuer_thread+0x380/0x380
> ? kthread_park+0x60/0x60
> ret_from_fork+0x35/0x40
> ----------
> 
> > ~]# cat /proc/meminfo 
> > MemTotal:       32912276 kB
> > MemFree:         8646212 kB
> > MemAvailable:   23506448 kB
> > Buffers:          230592 kB
> > Cached:         15443124 kB
> > SwapCached:         6112 kB
> > Active:         14235496 kB
> > Inactive:        7679336 kB
> > Active(anon):    3723980 kB
> > Inactive(anon):  2634188 kB
> > Active(file):   10511516 kB
> > Inactive(file):  5045148 kB
> > Unevictable:      233704 kB
> > Mlocked:          233704 kB
> > SwapTotal:       9873680 kB
> > SwapFree:        9090832 kB
> > Dirty:                40 kB
> > Writeback:             0 kB
> > AnonPages:       6435292 kB
> > Mapped:           162024 kB
> > Shmem:            105880 kB
> > Slab:             635280 kB
> > SReclaimable:     311468 kB
> > SUnreclaim:       323812 kB
> > KernelStack:       25296 kB
> > PageTables:        31376 kB
> > NFS_Unstable:          0 kB
> > Bounce:                0 kB
> > WritebackTmp:          0 kB
> > CommitLimit:    26329816 kB
> > Committed_AS:   16595004 kB
> > VmallocTotal:   34359738367 kB
> > VmallocUsed:           0 kB
> > VmallocChunk:          0 kB
> > HardwareCorrupted:     0 kB
> > AnonHugePages:   6090752 kB
> > ShmemHugePages:        0 kB
> > ShmemPmdMapped:        0 kB
> > CmaTotal:              0 kB
> > CmaFree:               0 kB
> > HugePages_Total:       0
> > HugePages_Free:        0
> > HugePages_Rsvd:        0
> > HugePages_Surp:        0
> > Hugepagesize:       2048 kB
> > DirectMap4k:     1012624 kB
> > DirectMap2M:    32514048 kB
> 
> One of workqueue threads was waiting at
> 
> ----------
> static void *new_read(struct dm_bufio_client *c, sector_t block,
> 		      enum new_flag nf, struct dm_buffer **bp)
> {
> 	int need_submit;
> 	struct dm_buffer *b;
> 
> 	LIST_HEAD(write_list);
> 
> 	dm_bufio_lock(c);
> 	b = __bufio_new(c, block, nf, &need_submit, &write_list);
> #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
> 	if (b && b->hold_count == 1)
> 		buffer_record_stack(b);
> #endif
> 	dm_bufio_unlock(c);
> 
> 	__flush_write_list(&write_list);
> 
> 	if (!b)
> 		return NULL;
> 
> 	if (need_submit)
> 		submit_io(b, READ, read_endio);
> 
> 	wait_on_bit_io(&b->state, B_READING, TASK_UNINTERRUPTIBLE); // <= here
> 
> 	if (b->read_error) {
> 		int error = blk_status_to_errno(b->read_error);
> 
> 		dm_bufio_release(b);
> 
> 		return ERR_PTR(error);
> 	}
> 
> 	*bp = b;
> 
> 	return b->data;
> }
> ----------
> 
> but what are possible reasons? Does this request depend on workqueue availability?

We are using dm-thin which uses dm-bufio.  The dm-thin pools are working
properly, so I don't think this is the problem---or at least if it is
the problem, it isn't affecting the thin pool.


--
Eric Wheeler


> 
> ----------
> kworker/0:32    R  running task        0 18541      2 0x80000080
> Call Trace:
> ? __schedule+0x1dc/0x770
> schedule+0x32/0x80
> worker_thread+0xc3/0x3e0
> kthread+0xfc/0x130
> ? rescuer_thread+0x380/0x380
> ? kthread_park+0x60/0x60
> ret_from_fork+0x35/0x40
> 
> kworker/3:70    R  running task        0 13344      2 0x80000080
> Workqueue: events_power_efficient fb_flashcursor
> Call Trace:
> ? fb_flashcursor+0x131/0x140
> ? bit_clear+0x110/0x110
> ? process_one_work+0x141/0x340
> ? worker_thread+0x47/0x3e0
> ? kthread+0xfc/0x130
> ? rescuer_thread+0x380/0x380
> ? kthread_park+0x60/0x60
> ? ret_from_fork+0x35/0x40
> 
> kworker/u16:1   D    0  9752      2 0x80000080
> Workqueue: dm-thin do_worker [dm_thin_pool]
> Call Trace:
> ? __schedule+0x1dc/0x770
> ? out_of_line_wait_on_atomic_t+0x110/0x110
> schedule+0x32/0x80
> io_schedule+0x12/0x40
> bit_wait_io+0xd/0x50
> __wait_on_bit+0x5a/0x90
> out_of_line_wait_on_bit+0x8e/0xb0
> ? bit_waitqueue+0x30/0x30
> new_read+0x9f/0x100 [dm_bufio]
> dm_bm_read_lock+0x21/0x70 [dm_persistent_data]
> ro_step+0x31/0x60 [dm_persistent_data]
> btree_lookup_raw.constprop.7+0x3a/0x100 [dm_persistent_data]
> dm_btree_lookup+0x71/0x100 [dm_persistent_data]
> __find_block+0x55/0xa0 [dm_thin_pool]
> dm_thin_find_block+0x48/0x70 [dm_thin_pool]
> process_cell+0x67/0x510 [dm_thin_pool]
> ? dm_bio_detain+0x4c/0x60 [dm_bio_prison]
> process_bio+0xaa/0xc0 [dm_thin_pool]
> do_worker+0x632/0x8b0 [dm_thin_pool]
> ? __switch_to+0xa8/0x480
> process_one_work+0x141/0x340
> worker_thread+0x47/0x3e0
> kthread+0xfc/0x130
> ? rescuer_thread+0x380/0x380
> ? kthread_park+0x60/0x60
> ? SyS_exit_group+0x10/0x10
> ret_from_fork+0x35/0x40
> ----------
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
