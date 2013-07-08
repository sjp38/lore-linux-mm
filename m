Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id D0E0D6B0033
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 08:53:55 -0400 (EDT)
Date: Mon, 8 Jul 2013 14:53:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130708125352.GC20149@dhcp22.suse.cz>
References: <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="3uo+9/B/ebqu+fSQ"
Content-Disposition: inline
In-Reply-To: <20130704163643.GF7833@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--3uo+9/B/ebqu+fSQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu 04-07-13 18:36:43, Michal Hocko wrote:
> On Wed 03-07-13 21:24:03, Dave Chinner wrote:
> > On Tue, Jul 02, 2013 at 02:44:27PM +0200, Michal Hocko wrote:
> > > On Tue 02-07-13 22:19:47, Dave Chinner wrote:
> > > [...]
> > > > Ok, so it's been leaked from a dispose list somehow. Thanks for the
> > > > info, Michal, it's time to go look at the code....
> > > 
> > > OK, just in case we will need it, I am keeping the machine in this state
> > > for now. So we still can play with crash and check all the juicy
> > > internals.
> > 
> > My current suspect is the LRU_RETRY code. I don't think what it is
> > doing is at all valid - list_for_each_safe() is not safe if you drop
> > the lock that protects the list. i.e. there is nothing that protects
> > the stored next pointer from being removed from the list by someone
> > else. Hence what I think is occurring is this:
> > 
> > 
> > thread 1			thread 2
> > lock(lru)
> > list_for_each_safe(lru)		lock(lru)
> >   isolate			......
> >     lock(i_lock)
> >     has buffers
> >       __iget
> >       unlock(i_lock)
> >       unlock(lru)
> >       .....			(gets lru lock)
> >       				list_for_each_safe(lru)
> > 				  walks all the inodes
> > 				  finds inode being isolated by other thread
> > 				  isolate
> > 				    i_count > 0
> > 				      list_del_init(i_lru)
> > 				      return LRU_REMOVED;
> > 				   moves to next inode, inode that
> > 				   other thread has stored as next
> > 				   isolate
> > 				     i_state |= I_FREEING
> > 				     list_move(dispose_list)
> > 				     return LRU_REMOVED
> > 				 ....
> > 				 unlock(lru)
> >       lock(lru)
> >       return LRU_RETRY;
> >   if (!first_pass)
> >     ....
> >   --nr_to_scan
> >   (loop again using next, which has already been removed from the
> >   LRU by the other thread!)
> >   isolate
> >     lock(i_lock)
> >     if (i_state & ~I_REFERENCED)
> >       list_del_init(i_lru)	<<<<< inode is on dispose list!
> > 				<<<<< inode is now isolated, with I_FREEING set
> >       return LRU_REMOVED;
> > 
> > That fits the corpse left on your machine, Michal. One thread has
> > moved the inode to a dispose list, the other thread thinks it is
> > still on the LRU and should be removed, and removes it.
> > 
> > This also explains the lru item count going negative - the same item
> > is being removed from the lru twice. So it seems like all the
> > problems you've been seeing are caused by this one problem....
> > 
> > Patch below that should fix this.
> 
> Good news! The test was running since morning and it didn't hang nor
> crashed. So this really looks like the right fix. It will run also
> during weekend to be 100% sure. But I guess it is safe to say

Hmm, it seems I was too optimistic or we have yet another issue here (I
guess the later is more probable).

The weekend testing got stuck as well. 

The dmesg shows there were some hung tasks:
[275284.264312] start.sh (11025): dropped kernel caches: 3
[276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
[276962.652087] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[276962.652093] xfs-data/sda9   D ffff88001ffb9cc8     0   930      2 0x00000000
[276962.652102]  ffff88003794d198 0000000000000046 ffff8800325f4480 0000000000000000
[276962.652113]  ffff88003794c010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[276962.652121]  0000000000012dc0 ffff88003794dfd8 ffff88003794dfd8 0000000000012dc0
[276962.652128] Call Trace:
[276962.652151]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[276962.652160]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[276962.652171]  [<ffffffff815793a4>] schedule+0x24/0x70
[276962.652178]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[276962.652187]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[276962.652194]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[276962.652200]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[276962.652206]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[276962.652215]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[276962.652224]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[276962.652231]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[276962.652239]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[276962.652246]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[276962.652254]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[276962.652262]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[276962.652274]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[276962.652282]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[276962.652291]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[276962.652298]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[276962.652305]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[276962.652313]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[276962.652323]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[276962.652332]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[276962.652343]  [<ffffffff81151c72>] kmem_getpages+0x62/0x1d0
[276962.652351]  [<ffffffff81153869>] fallback_alloc+0x189/0x250
[276962.652359]  [<ffffffff8115360d>] ____cache_alloc_node+0x8d/0x160
[276962.652367]  [<ffffffff81153e51>] __kmalloc+0x281/0x290
[276962.652490]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[276962.652540]  [<ffffffffa02c6e97>] kmem_alloc+0x77/0xe0 [xfs]
[276962.652588]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[276962.652653]  [<ffffffffa030a334>] xfs_inode_item_format_extents+0x54/0x100 [xfs]
[276962.652714]  [<ffffffffa030a63a>] xfs_inode_item_format+0x25a/0x4f0 [xfs]
[276962.652774]  [<ffffffffa03081a0>] xlog_cil_prepare_log_vecs+0xa0/0x170 [xfs]
[276962.652834]  [<ffffffffa03082a8>] xfs_log_commit_cil+0x38/0x1c0 [xfs]
[276962.652894]  [<ffffffffa0303304>] xfs_trans_commit+0x74/0x260 [xfs]
[276962.652935]  [<ffffffffa02ac70b>] xfs_setfilesize+0x12b/0x130 [xfs]
[276962.652947]  [<ffffffff81076bd0>] ? __migrate_task+0x150/0x150
[276962.652988]  [<ffffffffa02ac985>] xfs_end_io+0x75/0xc0 [xfs]
[276962.652997]  [<ffffffff8105e934>] process_one_work+0x1b4/0x380
[276962.653004]  [<ffffffff8105f294>] rescuer_thread+0x234/0x320
[276962.653011]  [<ffffffff8105f060>] ? free_pwqs+0x30/0x30
[276962.653017]  [<ffffffff81066a86>] kthread+0xc6/0xd0
[276962.653025]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[276962.653034]  [<ffffffff8158303c>] ret_from_fork+0x7c/0xb0
[276962.653041]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70

$ dmesg | grep "blocked for more than"
[276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
[276962.653097] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
[276962.653940] INFO: task ld:14442 blocked for more than 480 seconds.
[276962.654297] INFO: task ld:14962 blocked for more than 480 seconds.
[277442.652123] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
[277442.653153] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
[277442.653997] INFO: task ld:14442 blocked for more than 480 seconds.
[277442.654353] INFO: task ld:14962 blocked for more than 480 seconds.
[277922.652069] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
[277922.653089] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.

All of them are sitting in io_schedule triggered from the memcg soft
reclaim waiting for a wake up (full dmesg is attached). I guess this has
nothing to do with the slab shrinkers directly. It is probably priority 0
reclaim which is done in the soft reclaim path.

$ uptime
 13:32pm  up 4 days  2:54,  2 users,  load average: 25.00, 24.97, 24.66

so the current timestamp should be 352854 which means that all of them
happened quite some time ago and the system obviously resurrected from
this state.

What is more important, though, is that we still have the following
tasks stuck in D state for hours:
14442 [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[<ffffffff81114e43>] shrink_page_list+0x503/0x790
[<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[<ffffffff81116418>] shrink_zones+0x108/0x220
[<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[<ffffffff8113fe93>] read_swap_cache_async+0x113/0x160
[<ffffffff8113ffe1>] swapin_readahead+0x101/0x190
[<ffffffff8112e93f>] do_swap_page+0xef/0x5e0
[<ffffffff8112f94d>] handle_pte_fault+0x1bd/0x240
[<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[<ffffffff8157b348>] page_fault+0x28/0x30
[<ffffffffffffffff>] 0xffffffffffffffff
14962 [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[<ffffffff81114e43>] shrink_page_list+0x503/0x790
[<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[<ffffffff81116418>] shrink_zones+0x108/0x220
[<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[<ffffffff81129ebb>] do_anonymous_page+0x16b/0x350
[<ffffffff8112f9c5>] handle_pte_fault+0x235/0x240
[<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[<ffffffff8157b348>] page_fault+0x28/0x30
[<ffffffffffffffff>] 0xffffffffffffffff
20757 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
[<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
[<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
[<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
[<ffffffffa02c62d0>] xfs_free_eofblocks+0x180/0x250 [xfs]
[<ffffffffa02c68e6>] xfs_release+0x106/0x1d0 [xfs]
[<ffffffffa02b3b20>] xfs_file_release+0x10/0x20 [xfs]
[<ffffffff8116c86d>] __fput+0xbd/0x240
[<ffffffff8116ca49>] ____fput+0x9/0x10
[<ffffffff81063221>] task_work_run+0xb1/0xe0
[<ffffffff810029e0>] do_notify_resume+0x90/0x1d0
[<ffffffff815833a2>] int_signal+0x12/0x17
[<ffffffffffffffff>] 0xffffffffffffffff
20758 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
[<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
[<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
[<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
[<ffffffffa02c5999>] xfs_create+0x1a9/0x5c0 [xfs]
[<ffffffffa02bccca>] xfs_vn_mknod+0x8a/0x1a0 [xfs]
[<ffffffffa02bce0e>] xfs_vn_create+0xe/0x10 [xfs]
[<ffffffff811763dd>] vfs_create+0xad/0xd0
[<ffffffff81177e68>] lookup_open+0x1b8/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
20761 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
[<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
[<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
[<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
[<ffffffffa02c5999>] xfs_create+0x1a9/0x5c0 [xfs]
[<ffffffffa02bccca>] xfs_vn_mknod+0x8a/0x1a0 [xfs]
[<ffffffffa02bce0e>] xfs_vn_create+0xe/0x10 [xfs]
[<ffffffff811763dd>] vfs_create+0xad/0xd0
[<ffffffff81177e68>] lookup_open+0x1b8/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

Hohmm, now that I am looking at pids of the stuck processes, two of them
14442 and 14962 are mentioned in the soft lockup warnings. It is really
weird that the lockups have stopped quite some time ago (~20h ago).

I am keeping the system in this state in case you want to examine
details via crash again.

Let me know whether you need any further details.

Thanks!
-- 
Michal Hocko
SUSE Labs

--3uo+9/B/ebqu+fSQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="demon.dmesg"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.9.0mmotmfix+ (mhocko@noe) (gcc version 4.3.4 [gcc-4_3-branch revision 152973] (SUSE Linux) ) #1493 SMP Thu Jul 4 10:20:10 CEST 2013
[    0.000000] Command line: root=/dev/sda2 console=tty0 console=ttyS1,115200 nomodeset resume=/dev/sda1 splash=silent crashkernel= showopts vga=6 mem=1G
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009d7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009d800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000d2000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007ff1ffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007ff20000-0x000000007ff23fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007ff24000-0x000000007ff7ffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007ff80000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fff80000-0x00000000ffffffff] reserved
[    0.000000] e820: remove [mem 0x40000000-0xfffffffffffffffe] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] e820: user-defined physical RAM map:
[    0.000000] user: [mem 0x0000000000000000-0x000000000009d7ff] usable
[    0.000000] user: [mem 0x000000000009d800-0x000000000009ffff] reserved
[    0.000000] user: [mem 0x00000000000d2000-0x00000000000fffff] reserved
[    0.000000] user: [mem 0x0000000000100000-0x000000003fffffff] usable
[    0.000000] user: [mem 0x000000007ff20000-0x000000007ff23fff] ACPI data
[    0.000000] user: [mem 0x000000007ff24000-0x000000007ff7ffff] ACPI NVS
[    0.000000] user: [mem 0x000000007ff80000-0x000000007fffffff] reserved
[    0.000000] user: [mem 0x00000000fec00000-0x00000000fec0ffff] reserved
[    0.000000] user: [mem 0x00000000fff80000-0x00000000ffffffff] reserved
[    0.000000] SMBIOS 2.34 present.
[    0.000000] DMI: AMD A8440/WARTHOG, BIOS PW2A00-5 09/23/2005
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x40000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-protect
[    0.000000]   D4000-E3FFF uncachable
[    0.000000]   E4000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask FF80000000 write-back
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] found SMP MP-table at [mem 0x000f7850-0x000f785f] mapped at [ffff8800000f7850]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000096000] 96000 size 28672
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01d27000, 0x01d27fff] PGTABLE
[    0.000000] BRK [0x01d28000, 0x01d28fff] PGTABLE
[    0.000000] BRK [0x01d29000, 0x01d29fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x3fe00000-0x3fffffff]
[    0.000000]  [mem 0x3fe00000-0x3fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x3c000000-0x3fdfffff]
[    0.000000]  [mem 0x3c000000-0x3fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x3bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3bffffff] page 2M
[    0.000000] RAMDISK: [mem 0x36cbe000-0x37feffff]
[    0.000000] crashkernel: memory value expected
[    0.000000] ACPI: RSDP 00000000000f7820 00024 (v02 PTLTD )
[    0.000000] ACPI: XSDT 000000007ff2026c 00064 (v01 PTLTD  ? XSDT   06040000  LTP 00000000)
[    0.000000] ACPI: FACP 000000007ff202d0 00074 (v01 AMD    HAMMER   06040000 PTEC 000F4240)
[    0.000000] ACPI: DSDT 000000007ff20344 03107 (v01 AMD-K8  AMDACPI 06040000 MSFT 0100000E)
[    0.000000] ACPI: FACS 000000007ff24fc0 00040
[    0.000000] ACPI: SSDT 000000007ff2344b 007C4 (v01 PTLTD  POWERNOW 06040000  LTP 00000001)
[    0.000000] ACPI: SRAT 000000007ff23c0f 00178 (v01 AMD    HAMMER   06040000 AMD  00000001)
[    0.000000] ACPI: SSDT 000000007ff23d87 000E7 (v01 AMD-K8 AMD-ACPI 06040000  AMD 00000001)
[    0.000000] ACPI: HPET 000000007ff23e6e 00038 (v01 AMD    HAMMER   06040000 PTEC 00000000)
[    0.000000] ACPI: SPCR 000000007ff23ea6 00050 (v01 PTLTD  $UCRTBL$ 06040000 PTL  00000001)
[    0.000000] ACPI: APIC 000000007ff23ef6 000E2 (v01 PTLTD  ? APIC   06040000  LTP 00000000)
[    0.000000] ACPI: BOOT 000000007ff23fd8 00028 (v01 PTLTD  $SBFTBL$ 06040000  LTP 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x02 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x03 -> Node 1
[    0.000000] SRAT: PXM 2 -> APIC 0x04 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 0x05 -> Node 2
[    0.000000] SRAT: PXM 3 -> APIC 0x06 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 0x07 -> Node 3
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00100000-0x1fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x20000000-0x3fffffff]
[    0.000000] SRAT: Node 2 PXM 2 [mem 0x40000000-0x5fffffff]
[    0.000000] SRAT: Node 3 PXM 3 [mem 0x60000000-0x7fffffff]
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x1fffffff] -> [mem 0x00000000-0x1fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffffff]
[    0.000000]   NODE_DATA [mem 0x1ffec000-0x1fffffff]
[    0.000000] Initmem setup node 1 [mem 0x20000000-0x3fffffff]
[    0.000000]   NODE_DATA [mem 0x3ffec000-0x3fffffff]
[    0.000000] [ffffea0000700000-ffffea00007fffff] potential offnode page_structs
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001f600000-ffff88001fdfffff] on node 0
[    0.000000]  [ffffea0000800000-ffffea0000dfffff] PMD -> [ffff88003ee00000-ffff88003f3fffff] on node 1
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009cfff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffffff]
[    0.000000]   node   1: [mem 0x20000000-0x3fffffff]
[    0.000000] On node 0 totalpages: 130972
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 22 pages reserved
[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1736 pages used for memmap
[    0.000000]   DMA32 zone: 126976 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 131072
[    0.000000]   DMA32 zone: 1792 pages used for memmap
[    0.000000]   DMA32 zone: 131072 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xc008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x09] address[0xe8000000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 9, version 17, address 0xe8000000, GSI 24-27
[    0.000000] ACPI: IOAPIC (id[0x0a] address[0xe8001000] gsi_base[28])
[    0.000000] IOAPIC[2]: apic_id 10, version 17, address 0xe8001000, GSI 28-31
[    0.000000] ACPI: IOAPIC (id[0x0b] address[0xf8000000] gsi_base[32])
[    0.000000] IOAPIC[3]: apic_id 11, version 17, address 0xf8000000, GSI 32-35
[    0.000000] ACPI: IOAPIC (id[0x0c] address[0xf8001000] gsi_base[36])
[    0.000000] IOAPIC[4]: apic_id 12, version 17, address 0xf8001000, GSI 36-39
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x102282a0 base: 0xfed00000
[    0.000000] smpboot: Allowing 8 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 56
[    0.000000] PM: Registered nosave memory: 000000000009d000 - 000000000009e000
[    0.000000] PM: Registered nosave memory: 000000000009e000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000d2000
[    0.000000] PM: Registered nosave memory: 00000000000d2000 - 0000000000100000
[    0.000000] e820: [mem 0x80000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:8 nr_node_ids:4
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88001f000000 s80512 r8192 d21888 u1048576
[    0.000000] pcpu-alloc: s80512 r8192 d21888 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 [0] 4 5 [0] 6 7 [1] 2 3 
[    0.000000] Built 2 zonelists in Node order, mobility grouping on.  Total pages: 258438
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: root=/dev/sda2 console=tty0 console=ttyS1,115200 nomodeset resume=/dev/sda1 splash=silent crashkernel= showopts vga=6 mem=1G
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Node 0: aperture @ c1f6000000 size 32 MB
[    0.000000] Aperture beyond 4GB. Ignoring.
[    0.000000] Memory: 999232K/1048176K available (5659K kernel code, 671K rwdata, 2516K rodata, 1268K init, 1252K bss, 48944K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=8.
[    0.000000] NR_IRQS:33024 nr_irqs:1016 16
[    0.000000] Console: colour VGA+ 80x60
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS1] enabled
[    0.000000] allocated 4194304 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] Enabling automatic NUMA balancing. Configure with numa_balancing= or sysctl
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2389.785 MHz processor
[    0.000000] tsc: Marking TSC unstable due to TSCs unsynchronized
[    0.020000] Calibrating delay loop (skipped), value calculated using timer frequency.. 4779.57 BogoMIPS (lpj=9559140)
[    0.024003] pid_max: default: 32768 minimum: 301
[    0.028077] Security Framework initialized
[    0.032033] AppArmor: AppArmor initialized
[    0.036092] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.040687] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.044375] Mount-cache hash table entries: 256
[    0.048308] Initializing cgroup subsys cpuacct
[    0.052005] Initializing cgroup subsys memory
[    0.056045] Initializing cgroup subsys devices
[    0.060005] Initializing cgroup subsys freezer
[    0.064004] Initializing cgroup subsys net_cls
[    0.068003] Initializing cgroup subsys blkio
[    0.072003] Initializing cgroup subsys perf_event
[    0.076048] tseg: 007ff80000
[    0.076052] CPU: Physical Processor ID: 0
[    0.080003] CPU: Processor Core ID: 0
[    0.084003] mce: CPU supports 5 MCE banks
[    0.088009] LVT offset 0 assigned for vector 0xf9
[    0.092011] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.092011] Last level dTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.092011] tlb_flushall_shift: 4
[    0.096105] Freeing SMP alternatives memory: 24K (ffffffff81be6000 - ffffffff81bec000)
[    0.100827] ACPI: Core revision 20130117
[    0.109569] ACPI: All ACPI Tables successfully acquired
[    0.113296] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
[    0.157906] smpboot: CPU0: AMD Engineering Sample (fam: 0f, model: 41, stepping: 01)
[    0.172000] Performance Events: AMD PMU driver.
[    0.172003] ... version:                0
[    0.176001] ... bit width:              48
[    0.180001] ... generic registers:      4
[    0.184001] ... value mask:             0000ffffffffffff
[    0.188001] ... max period:             00007fffffffffff
[    0.192000] ... fixed-purpose events:   0
[    0.196001] ... event mask:             000000000000000f
[    0.200717] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.208105] smpboot: Booting Node   0, Processors  #1 OK
[    0.305027] smpboot: Booting Node   1, Processors  #2 #3 OK
[    0.488903] smpboot: Booting Node   0, Processors  #4 #5 #6 #7 OK
[    0.852083] Brought up 8 CPUs
[    0.855288] smpboot: Total of 8 processors activated (38238.06 BogoMIPS)
[    0.860420] devtmpfs: initialized
[    0.868206] PM: Registering ACPI NVS region [mem 0x7ff24000-0x7ff7ffff] (376832 bytes)
[    0.872179] RTC time:  8:38:18, date: 07/04/13
[    0.876103] NET: Registered protocol family 16
[    0.880206] node 0 link 1: io port [0, 2fff]
[    0.880209] node 1 link 1: io port [3000, 3fff]
[    0.880212] TOM: 0000000080000000 aka 2048M
[    0.884003] node 0 link 1: mmio [e8000000, e80fffff]
[    0.884006] node 1 link 1: mmio [f8000000, f84fffff]
[    0.884008] node 0 link 1: mmio [e8200000, e85fffff]
[    0.884012] bus: [bus 00-09] on node 0 link 1
[    0.884014] bus: 00 [io  0x0000-0x2fff]
[    0.884016] bus: 00 [io  0x4000-0xffff]
[    0.884017] bus: 00 [mem 0x80000000-0xe81fffff]
[    0.884019] bus: 00 [mem 0xe8200000-0xf7ffffff]
[    0.884021] bus: 00 [mem 0xf8500000-0xfcffffffff]
[    0.884022] bus: [bus 0a-ff] on node 1 link 1
[    0.884024] bus: 0a [io  0x3000-0x3fff]
[    0.884025] bus: 0a [mem 0xf8000000-0xf84fffff]
[    0.884056] ACPI: bus type PCI registered
[    0.888073] PCI: Using configuration type 1 for base access
[    0.893297] bio: create slab <bio-0> at 0
[    0.896088] ACPI: Added _OSI(Module Device)
[    0.900002] ACPI: Added _OSI(Processor Device)
[    0.904001] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.908001] ACPI: Added _OSI(Processor Aggregator Device)
[    0.912463] ACPI: EC: Look up EC in DSDT
[    0.919157] ACPI: Interpreter enabled
[    0.920013] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130117/hwxface-568)
[    0.932002] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20130117/hwxface-568)
[    0.942418] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S4_] (20130117/hwxface-568)
[    0.952005] ACPI: (supports S0 S1 S5)
[    0.956002] ACPI: Using IOAPIC for interrupt routing
[    0.960184] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.975743] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-09])
[    0.983122] acpi PNP0A03:00: host bridge window [io  0x03b0-0x03df] (ignored)
[    0.983125] acpi PNP0A03:00: host bridge window [io  0x0d00-0x2fff] (ignored)
[    0.983128] acpi PNP0A03:00: host bridge window [mem 0xfed00000-0xfed0ffff] (ignored)
[    0.983130] acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.983133] acpi PNP0A03:00: host bridge window [mem 0xfec00000-0xfec0ffff] (ignored)
[    0.983135] acpi PNP0A03:00: host bridge window [mem 0xf0000000-0xf7ffffff] (ignored)
[    0.983138] acpi PNP0A03:00: host bridge window [mem 0xe8000000-0xe85fffff] (ignored)
[    0.983140] acpi PNP0A03:00: host bridge window [mem 0x000c0000-0x000cafff] (ignored)
[    0.983142] acpi PNP0A03:00: host bridge window [mem 0x000d8000-0x000dbfff] (ignored)
[    0.983145] acpi PNP0A03:00: host bridge window [io  0x0000-0x03af] (ignored)
[    0.983147] acpi PNP0A03:00: host bridge window [io  0x03e0-0x0cf7] (ignored)
[    0.983150] PCI: root bus 00: hardware-probed resources
[    0.983157] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.984039] PCI host bridge to bus 0000:00
[    0.988003] pci_bus 0000:00: root bus resource [bus 00-09]
[    0.992003] pci_bus 0000:00: root bus resource [io  0x0000-0x2fff]
[    0.996002] pci_bus 0000:00: root bus resource [io  0x4000-0xffff]
[    1.000002] pci_bus 0000:00: root bus resource [mem 0x80000000-0xe81fffff]
[    1.004002] pci_bus 0000:00: root bus resource [mem 0xe8200000-0xf7ffffff]
[    1.008002] pci_bus 0000:00: root bus resource [mem 0xf8500000-0xfcffffffff]
[    1.012022] pci 0000:00:06.0: [1022:7460] type 01 class 0x060400
[    1.012130] pci 0000:00:06.0: System wakeup disabled by ACPI
[    1.016049] pci 0000:00:07.0: [1022:7468] type 00 class 0x060100
[    1.016157] pci 0000:00:07.1: [1022:7469] type 00 class 0x01018a
[    1.016188] pci 0000:00:07.1: reg 20: [io  0x1020-0x102f]
[    1.016266] pci 0000:00:07.2: [1022:746a] type 00 class 0x0c0500
[    1.016280] pci 0000:00:07.2: reg 10: [io  0x1000-0x101f]
[    1.016409] pci 0000:00:07.3: [1022:746b] type 00 class 0x068000
[    1.016536] pci 0000:00:0a.0: [1022:7450] type 01 class 0x060400
[    1.016601] pci 0000:00:0a.0: System wakeup disabled by ACPI
[    1.020042] pci 0000:00:0a.1: [1022:7451] type 00 class 0x080010
[    1.020051] pci 0000:00:0a.1: reg 10: [mem 0xe8000000-0xe8000fff 64bit]
[    1.020136] pci 0000:00:0b.0: [1022:7450] type 01 class 0x060400
[    1.020200] pci 0000:00:0b.0: System wakeup disabled by ACPI
[    1.024038] pci 0000:00:0b.1: [1022:7451] type 00 class 0x080010
[    1.024047] pci 0000:00:0b.1: reg 10: [mem 0xe8001000-0xe8001fff 64bit]
[    1.024144] pci 0000:00:18.0: [1022:1100] type 00 class 0x060000
[    1.024214] pci 0000:00:18.1: [1022:1101] type 00 class 0x060000
[    1.024279] pci 0000:00:18.2: [1022:1102] type 00 class 0x060000
[    1.024345] pci 0000:00:18.3: [1022:1103] type 00 class 0x060000
[    1.024420] pci 0000:00:19.0: [1022:1100] type 00 class 0x060000
[    1.024479] pci 0000:00:19.1: [1022:1101] type 00 class 0x060000
[    1.024546] pci 0000:00:19.2: [1022:1102] type 00 class 0x060000
[    1.024611] pci 0000:00:19.3: [1022:1103] type 00 class 0x060000
[    1.024683] pci 0000:00:1a.0: [1022:1100] type 00 class 0x060000
[    1.024757] pci 0000:00:1a.1: [1022:1101] type 00 class 0x060000
[    1.024824] pci 0000:00:1a.2: [1022:1102] type 00 class 0x060000
[    1.024890] pci 0000:00:1a.3: [1022:1103] type 00 class 0x060000
[    1.024963] pci 0000:00:1b.0: [1022:1100] type 00 class 0x060000
[    1.025041] pci 0000:00:1b.1: [1022:1101] type 00 class 0x060000
[    1.025108] pci 0000:00:1b.2: [1022:1102] type 00 class 0x060000
[    1.025177] pci 0000:00:1b.3: [1022:1103] type 00 class 0x060000
[    1.025307] pci 0000:01:00.0: [1022:7464] type 00 class 0x0c0310
[    1.025322] pci 0000:01:00.0: reg 10: [mem 0xe8110000-0xe8110fff]
[    1.025395] pci 0000:01:00.0: System wakeup disabled by ACPI
[    1.028050] pci 0000:01:00.1: [1022:7464] type 00 class 0x0c0310
[    1.028064] pci 0000:01:00.1: reg 10: [mem 0xe8111000-0xe8111fff]
[    1.028140] pci 0000:01:00.1: System wakeup disabled by ACPI
[    1.032062] pci 0000:01:05.0: [1095:3512] type 00 class 0x018000
[    1.032080] pci 0000:01:05.0: reg 10: [io  0x2420-0x2427]
[    1.032090] pci 0000:01:05.0: reg 14: [io  0x2414-0x2417]
[    1.032101] pci 0000:01:05.0: reg 18: [io  0x2418-0x241f]
[    1.036010] pci 0000:01:05.0: reg 1c: [io  0x2410-0x2413]
[    1.036020] pci 0000:01:05.0: reg 20: [io  0x2400-0x240f]
[    1.036031] pci 0000:01:05.0: reg 24: [mem 0xe8112000-0xe81121ff]
[    1.036042] pci 0000:01:05.0: reg 30: [mem 0x00000000-0x0007ffff pref]
[    1.036071] pci 0000:01:05.0: supports D1 D2
[    1.036126] pci 0000:01:06.0: [1002:5159] type 00 class 0x030000
[    1.036144] pci 0000:01:06.0: reg 10: [mem 0xf0000000-0xf7ffffff pref]
[    1.036155] pci 0000:01:06.0: reg 14: [io  0x2000-0x20ff]
[    1.036165] pci 0000:01:06.0: reg 18: [mem 0xe8100000-0xe810ffff]
[    1.036201] pci 0000:01:06.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    1.036231] pci 0000:01:06.0: supports D1 D2
[    1.036310] pci 0000:00:06.0: PCI bridge to [bus 01]
[    1.040005] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    1.040009] pci 0000:00:06.0:   bridge window [mem 0xe8100000-0xe81fffff]
[    1.040013] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf7ffffff pref]
[    1.040063] pci 0000:02:01.0: [14e4:1645] type 00 class 0x020000
[    1.040074] pci 0000:02:01.0: reg 10: [mem 0xe8200000-0xe820ffff 64bit]
[    1.040117] pci 0000:02:01.0: PME# supported from D3hot D3cold
[    1.040190] pci 0000:00:0a.0: PCI bridge to [bus 02]
[    1.044005] pci 0000:00:0a.0:   bridge window [mem 0xe8200000-0xe82fffff]
[    1.044047] pci 0000:03:02.0: [14e4:1648] type 00 class 0x020000
[    1.044060] pci 0000:03:02.0: reg 10: [mem 0xe8310000-0xe831ffff 64bit]
[    1.044069] pci 0000:03:02.0: reg 18: [mem 0xe8300000-0xe830ffff 64bit]
[    1.044109] pci 0000:03:02.0: PME# supported from D3hot D3cold
[    1.044162] pci 0000:03:02.1: [14e4:1648] type 00 class 0x020000
[    1.044175] pci 0000:03:02.1: reg 10: [mem 0xe8330000-0xe833ffff 64bit]
[    1.044184] pci 0000:03:02.1: reg 18: [mem 0xe8320000-0xe832ffff 64bit]
[    1.044224] pci 0000:03:02.1: PME# supported from D3hot D3cold
[    1.044288] pci 0000:00:0b.0: PCI bridge to [bus 03]
[    1.048005] pci 0000:00:0b.0:   bridge window [mem 0xe8300000-0xe83fffff]
[    1.048020] acpi PNP0A03:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    1.052002] acpi PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    1.056269] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 5 10 *11)
[    1.064174] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 5 *10 11)
[    1.070061] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 *5 10 11)
[    1.077462] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 5 10 *11)
[    1.086416] ACPI: PCI Root Bridge [PCI1] (domain 0000 [bus 0a-ff])
[    1.092211] acpi PNP0A03:01: host bridge window [mem 0xf8000000-0xf84fffff] (ignored)
[    1.092214] acpi PNP0A03:01: host bridge window [io  0x3000-0x3fff] (ignored)
[    1.092217] PCI: root bus 0a: hardware-probed resources
[    1.092220] acpi PNP0A03:01: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    1.096039] PCI host bridge to bus 0000:0a
[    1.100002] pci_bus 0000:0a: root bus resource [bus 0a-ff]
[    1.104002] pci_bus 0000:0a: root bus resource [io  0x3000-0x3fff]
[    1.108002] pci_bus 0000:0a: root bus resource [mem 0xf8000000-0xf84fffff]
[    1.112014] pci 0000:0a:01.0: [1022:7450] type 01 class 0x060400
[    1.112074] pci 0000:0a:01.0: System wakeup disabled by ACPI
[    1.116053] pci 0000:0a:01.1: [1022:7451] type 00 class 0x080010
[    1.116063] pci 0000:0a:01.1: reg 10: [mem 0xf8000000-0xf8000fff 64bit]
[    1.116135] pci 0000:0a:02.0: [1022:7450] type 01 class 0x060400
[    1.116186] pci 0000:0a:02.0: System wakeup disabled by ACPI
[    1.120039] pci 0000:0a:02.1: [1022:7451] type 00 class 0x080010
[    1.120049] pci 0000:0a:02.1: reg 10: [mem 0xf8001000-0xf8001fff 64bit]
[    1.120168] pci 0000:0b:01.0: [8086:107c] type 00 class 0x020000
[    1.120180] pci 0000:0b:01.0: reg 10: [mem 0xf8120000-0xf813ffff]
[    1.120187] pci 0000:0b:01.0: reg 14: [mem 0xf8100000-0xf811ffff]
[    1.120193] pci 0000:0b:01.0: reg 18: [io  0x3000-0x303f]
[    1.120212] pci 0000:0b:01.0: reg 30: [mem 0x00000000-0x0001ffff pref]
[    1.120234] pci 0000:0b:01.0: PME# supported from D0 D3hot D3cold
[    1.120295] pci 0000:0a:01.0: PCI bridge to [bus 0b-0f]
[    1.124005] pci 0000:0a:01.0:   bridge window [io  0x3000-0x3fff]
[    1.124008] pci 0000:0a:01.0:   bridge window [mem 0xf8100000-0xf81fffff]
[    1.124053] pci 0000:10:02.0: [14e4:1648] type 00 class 0x020000
[    1.124066] pci 0000:10:02.0: reg 10: [mem 0xf8210000-0xf821ffff 64bit]
[    1.124075] pci 0000:10:02.0: reg 18: [mem 0xf8200000-0xf820ffff 64bit]
[    1.124118] pci 0000:10:02.0: PME# supported from D3hot D3cold
[    1.124175] pci 0000:10:02.1: [14e4:1648] type 00 class 0x020000
[    1.124188] pci 0000:10:02.1: reg 10: [mem 0xf8230000-0xf823ffff 64bit]
[    1.124198] pci 0000:10:02.1: reg 18: [mem 0xf8220000-0xf822ffff 64bit]
[    1.124241] pci 0000:10:02.1: PME# supported from D3hot D3cold
[    1.124307] pci 0000:0a:02.0: PCI bridge to [bus 10-14]
[    1.128005] pci 0000:0a:02.0:   bridge window [mem 0xf8200000-0xf82fffff]
[    1.128016] acpi PNP0A03:01: ACPI _OSC support notification failed, disabling PCIe ASPM
[    1.132002] acpi PNP0A03:01: Unable to request _OSC control (_OSC support mask: 0x08)
[    1.136084] acpi root: \_SB_.PCI0 notify handler is installed
[    1.136102] acpi root: \_SB_.PCI1 notify handler is installed
[    1.136106] Found 2 acpi root devices
[    1.136203] vgaarb: device added: PCI:0000:01:06.0,decodes=io+mem,owns=io+mem,locks=none
[    1.140003] vgaarb: loaded
[    1.144001] vgaarb: bridge control possible 0000:01:06.0
[    1.148216] SCSI subsystem initialized
[    1.152003] ACPI: bus type ATA registered
[    1.156025] libata version 3.00 loaded.
[    1.156116] PCI: Using ACPI for IRQ routing
[    1.160003] PCI: pci_cache_line_size set to 64 bytes
[    1.160076] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
[    1.160215] NetLabel: Initializing
[    1.164002] NetLabel:  domain hash size = 128
[    1.168001] NetLabel:  protocols = UNLABELED CIPSOv4
[    1.172017] NetLabel:  unlabeled traffic allowed by default
[    1.176037] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    1.180008] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 19
[    1.185413] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    1.192023] Switching to clocksource hpet
[    1.200278] AppArmor: AppArmor Filesystem Enabled
[    1.205370] pnp: PnP ACPI init
[    1.208719] ACPI: bus type PNP registered
[    1.213356] pnp 00:00: [dma 4]
[    1.213415] pnp 00:00: Plug and Play ACPI device, IDs PNP0200 (active)
[    1.213487] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.213524] pnp 00:02: Plug and Play ACPI device, IDs PNP0800 (active)
[    1.213571] pnp 00:03: Plug and Play ACPI device, IDs PNP0c04 (active)
[    1.213769] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    1.219983] system 00:04: [io  0x1100-0x117f] has been reserved
[    1.226192] system 00:04: [io  0x1180-0x11ff] has been reserved
[    1.232403] system 00:04: [io  0x0b78-0x0b7b] has been reserved
[    1.238618] system 00:04: [io  0x0190-0x0193] has been reserved
[    1.244830] system 00:04: [io  0xde00-0xdef7] has been reserved
[    1.251046] system 00:04: [io  0x0ca2-0x0ca3] has been reserved
[    1.257258] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.257344] pnp 00:05: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.258174] system 00:06: [mem 0x000e0000-0x000fffff] could not be reserved
[    1.265444] system 00:06: [mem 0x000c0000-0x000cafff] could not be reserved
[    1.272710] system 00:06: [mem 0xfec00000-0xfec00fff] could not be reserved
[    1.279974] system 00:06: [mem 0xffc00000-0xfff7ffff] has been reserved
[    1.286891] system 00:06: [mem 0xfee00000-0xfee00fff] has been reserved
[    1.293806] system 00:06: [mem 0xfff80000-0xffffffff] has been reserved
[    1.300721] system 00:06: [mem 0xfe000000-0xfe000fff] has been reserved
[    1.307636] system 00:06: [mem 0xfe001000-0xfe001fff] has been reserved
[    1.314553] system 00:06: [mem 0xfe002000-0xfe003fff] has been reserved
[    1.321465] system 00:06: [mem 0xfe004000-0xfe004fff] has been reserved
[    1.328380] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.328428] pnp 00:07: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.328911] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.329374] pnp 00:09: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.329592] pnp 00:0a: Plug and Play ACPI device, IDs PNP0700 (disabled)
[    1.329733] pnp 00:0b: Plug and Play ACPI device, IDs PNP0501 (disabled)
[    1.329849] pnp 00:0c: Plug and Play ACPI device, IDs PNP0700 (disabled)
[    1.329916] pnp: PnP ACPI: found 13 devices
[    1.334373] ACPI: bus type PNP unregistered
[    1.347541] pci 0000:01:05.0: BAR 6: assigned [mem 0xe8180000-0xe81fffff pref]
[    1.355239] pci 0000:01:06.0: BAR 6: assigned [mem 0xe8120000-0xe813ffff pref]
[    1.362920] pci 0000:00:06.0: PCI bridge to [bus 01]
[    1.368169] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    1.374567] pci 0000:00:06.0:   bridge window [mem 0xe8100000-0xe81fffff]
[    1.381659] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf7ffffff pref]
[    1.389344] pci 0000:00:0a.0: PCI bridge to [bus 02]
[    1.394590] pci 0000:00:0a.0:   bridge window [mem 0xe8200000-0xe82fffff]
[    1.401686] pci 0000:00:0b.0: PCI bridge to [bus 03]
[    1.406940] pci 0000:00:0b.0:   bridge window [mem 0xe8300000-0xe83fffff]
[    1.414042] pci 0000:0a:01.0: BAR 15: assigned [mem 0xf8300000-0xf83fffff pref]
[    1.421818] pci 0000:0b:01.0: BAR 6: assigned [mem 0xf8300000-0xf831ffff pref]
[    1.429501] pci 0000:0a:01.0: PCI bridge to [bus 0b-0f]
[    1.435016] pci 0000:0a:01.0:   bridge window [io  0x3000-0x3fff]
[    1.441404] pci 0000:0a:01.0:   bridge window [mem 0xf8100000-0xf81fffff]
[    1.448492] pci 0000:0a:01.0:   bridge window [mem 0xf8300000-0xf83fffff pref]
[    1.456177] pci 0000:0a:02.0: PCI bridge to [bus 10-14]
[    1.461687] pci 0000:0a:02.0:   bridge window [mem 0xf8200000-0xf82fffff]
[    1.468806] pci_bus 0000:00: resource 4 [io  0x0000-0x2fff]
[    1.468809] pci_bus 0000:00: resource 5 [io  0x4000-0xffff]
[    1.468811] pci_bus 0000:00: resource 6 [mem 0x80000000-0xe81fffff]
[    1.468814] pci_bus 0000:00: resource 7 [mem 0xe8200000-0xf7ffffff]
[    1.468816] pci_bus 0000:00: resource 8 [mem 0xf8500000-0xfcffffffff]
[    1.468819] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
[    1.468822] pci_bus 0000:01: resource 1 [mem 0xe8100000-0xe81fffff]
[    1.468824] pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff pref]
[    1.468827] pci_bus 0000:02: resource 1 [mem 0xe8200000-0xe82fffff]
[    1.468830] pci_bus 0000:03: resource 1 [mem 0xe8300000-0xe83fffff]
[    1.468833] pci_bus 0000:0a: resource 4 [io  0x3000-0x3fff]
[    1.468836] pci_bus 0000:0a: resource 5 [mem 0xf8000000-0xf84fffff]
[    1.468839] pci_bus 0000:0b: resource 0 [io  0x3000-0x3fff]
[    1.468841] pci_bus 0000:0b: resource 1 [mem 0xf8100000-0xf81fffff]
[    1.468843] pci_bus 0000:0b: resource 2 [mem 0xf8300000-0xf83fffff pref]
[    1.468847] pci_bus 0000:10: resource 1 [mem 0xf8200000-0xf82fffff]
[    1.469098] NET: Registered protocol family 2
[    1.474226] TCP established hash table entries: 8192 (order: 5, 131072 bytes)
[    1.481786] TCP bind hash table entries: 8192 (order: 5, 131072 bytes)
[    1.488714] TCP: Hash tables configured (established 8192 bind 8192)
[    1.501205] TCP: reno registered
[    1.504707] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    1.510940] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    1.517818] NET: Registered protocol family 1
[    1.522486] pci 0000:00:07.3: boot interrupts on device [1022:746b] already disabled
[    1.530705] pci 0000:00:0a.0: MSI quirk detected; subordinate MSI disabled
[    1.537886] pci 0000:00:0a.0: AMD8131 rev 12 detected; disabling PCI-X MMRBC
[    1.545244] pci 0000:00:0b.0: MSI quirk detected; subordinate MSI disabled
[    1.552422] pci 0000:00:0b.0: AMD8131 rev 12 detected; disabling PCI-X MMRBC
[    2.104095] pci 0000:01:06.0: Boot video device
[    2.104109] pci 0000:0a:01.0: MSI quirk detected; subordinate MSI disabled
[    2.111287] pci 0000:0a:01.0: AMD8131 rev 12 detected; disabling PCI-X MMRBC
[    2.118640] pci 0000:0a:02.0: MSI quirk detected; subordinate MSI disabled
[    2.125816] pci 0000:0a:02.0: AMD8131 rev 12 detected; disabling PCI-X MMRBC
[    2.133179] PCI: CLS 64 bytes, default 64
[    2.133295] Unpacking initramfs...
[    2.586419] Freeing initrd memory: 19656K (ffff880036cbe000 - ffff880037ff0000)
[    2.595778] Simple Boot Flag at 0x39 set to 0x1
[    2.601497] Scanning for low memory corruption every 60 seconds
[    2.608067] audit: initializing netlink socket (disabled)
[    2.613755] type=2000 audit(1372927099.612:1): initialized
[    2.644783] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    2.652373] VFS: Disk quotas dquot_6.5.2
[    2.656612] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    2.664024] msgmni has been set to 1990
[    2.668593] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    2.676506] io scheduler noop registered
[    2.680696] io scheduler deadline registered
[    2.685299] io scheduler cfq registered (default)
[    2.690638] ioapic: probe of 0000:00:0a.1 failed with error -22
[    2.696870] ioapic: probe of 0000:00:0b.1 failed with error -22
[    2.703112] ioapic: probe of 0000:0a:01.1 failed with error -22
[    2.709339] ioapic: probe of 0000:0a:02.1 failed with error -22
[    2.715710] GHES: HEST is not enabled!
[    2.719800] Serial: 8250/16550 driver, 32 ports, IRQ sharing disabled
[    2.746996] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.773340] 00:09: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    2.779280] serial 00:0b: [io  0x03e8-0x03ef]
[    2.779404] serial 00:0b: [io  0x02e8-0x02ef]
[    2.779503] serial 00:0b: unable to assign resources
[    2.784738] serial: probe of 00:0b failed with error -16
[    2.792489] Non-volatile memory driver v1.3
[    2.796936] Linux agpgart interface v0.103
[    2.801533] libphy: Fixed MDIO Bus: probed
[    2.805946] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    2.817055] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.822296] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.827797] mousedev: PS/2 mouse device common for all mice
[    2.833825] rtc_cmos 00:01: RTC can wake from S4
[    2.838908] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    2.845346] rtc_cmos 00:01: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    2.853468] cpuidle: using governor ladder
[    2.857825] cpuidle: using governor menu
[    2.862011] ledtrig-cpu: registered to indicate activity on CPUs
[    2.868296] EFI Variables Facility v0.08 2004-May-17
[    2.873545] hidraw: raw HID events driver (C) Jiri Kosina
[    2.879387] TCP: cubic registered
[    2.883152] NET: Registered protocol family 10
[    2.888169] Key type dns_resolver registered
[    2.893306] PM: Checking hibernation image partition /dev/sda1
[    2.906270] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    3.163543] PM: Hibernation image not present or could not be loaded.
[    3.163562] registered taskstats version 1
[    3.168579]   Magic number: 5:732:623
[    3.174791] Freeing unused kernel memory: 1268K (ffffffff81aa9000 - ffffffff81be6000)
[    3.183115] Write protecting the kernel read-only data: 10240k
[    3.191096] Freeing unused kernel memory: 476K (ffff880001589000 - ffff880001600000)
[    3.204841] Freeing unused kernel memory: 1580K (ffff880001875000 - ffff880001a00000)
[    3.282824] pata_amd 0000:00:07.1: version 0.4.1
[    3.283218] scsi0 : pata_amd
[    3.286618] scsi1 : pata_amd
[    3.289810] ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0x1020 irq 14
[    3.297063] ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x1028 irq 15
[    3.313835] sata_sil 0000:01:05.0: version 2.4
[    3.314338] scsi2 : sata_sil
[    3.317630] scsi3 : sata_sil
[    3.320801] ata3: SATA max UDMA/100 mmio m512@0xe8112000 tf 0xe8112080 irq 16
[    3.328228] ata4: SATA max UDMA/100 mmio m512@0xe8112000 tf 0xe81120c0 irq 16
[    3.355901] hp_sw: device handler registered
[    3.369879] rdac: device handler registered
[    3.383238] emc: device handler registered
[    3.392495] udev: starting version 147
[    3.424913] ACPI: bus type USB registered
[    3.429359] usbcore: registered new interface driver usbfs
[    3.435206] usbcore: registered new interface driver hub
[    3.440978] usbcore: registered new device driver usb
[    3.453177] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    3.464950] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    3.468822] ata1.00: ATAPI: DV-28E-N, 1.6A, max UDMA/33
[    3.477402] ohci_hcd 0000:01:00.0: OHCI Host Controller
[    3.482957] ohci_hcd 0000:01:00.0: new USB bus registered, assigned bus number 1
[    3.484381] ata1.00: configured for UDMA/33
[    3.489297] scsi 0:0:0:0: CD-ROM            TEAC     DV-28E-N         1.6A PQ: 0 ANSI: 5
[    3.489621] ata2: port disabled--ignoring
[    3.503986] ohci_hcd 0000:01:00.0: irq 19, io mem 0xe8110000
[    3.566061] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
[    3.573139] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.580814] usb usb1: Product: OHCI Host Controller
[    3.585954] usb usb1: Manufacturer: Linux 3.9.0mmotmfix+ ohci_hcd
[    3.592330] usb usb1: SerialNumber: 0000:01:00.0
[    3.597369] hub 1-0:1.0: USB hub found
[    3.601384] hub 1-0:1.0: 3 ports detected
[    3.605897] ohci_hcd 0000:01:00.1: OHCI Host Controller
[    3.611396] ohci_hcd 0000:01:00.1: new USB bus registered, assigned bus number 2
[    3.619249] ohci_hcd 0000:01:00.1: irq 19, io mem 0xe8111000
[    3.682036] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    3.689109] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.696771] usb usb2: Product: OHCI Host Controller
[    3.701911] usb usb2: Manufacturer: Linux 3.9.0mmotmfix+ ohci_hcd
[    3.708279] usb usb2: SerialNumber: 0000:01:00.1
[    3.713280] hub 2-0:1.0: USB hub found
[    3.717298] hub 2-0:1.0: 3 ports detected
[    4.096036] usb 2-2: new full-speed USB device number 2 using ohci_hcd
[    4.307966] usb 2-2: New USB device found, idVendor=04b4, idProduct=6560
[    4.314963] usb 2-2: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    4.323999] hub 2-2:1.0: USB hub found
[    4.329956] hub 2-2:1.0: 4 ports detected
[    4.384061] ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 310)
[    4.396478] ata3.00: ATA-7: Maxtor 6Y120M0, YAR51EW0, max UDMA/133
[    4.402937] ata3.00: 234375000 sectors, multi 0: LBA 
[    4.424464] ata3.00: configured for UDMA/100
[    4.429326] scsi 2:0:0:0: Direct-Access     ATA      Maxtor 6Y120M0   YAR5 PQ: 0 ANSI: 5
[    4.438188] sd 2:0:0:0: [sda] 234375000 512-byte logical blocks: (120 GB/111 GiB)
[    4.446318] sd 2:0:0:0: [sda] Write Protect is off
[    4.451428] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    4.451492] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    4.524038] usb 2-3: new full-speed USB device number 3 using ohci_hcd
[    4.540827]  sda: sda1 sda2 sda4 < sda5 sda6 sda7 sda8 sda9 >
[    4.547749] sd 2:0:0:0: [sda] Attached SCSI disk
[    4.731896] usb 2-3: New USB device found, idVendor=04b4, idProduct=6560
[    4.744323] usb 2-3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    4.753928] hub 2-3:1.0: USB hub found
[    4.759883] hub 2-3:1.0: 4 ports detected
[    4.772074] ata4: SATA link down (SStatus 0 SControl 310)
[    6.003082] EXT4-fs (sda2): mounting ext3 file system using the ext4 subsystem
[    6.025866] EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: acl,user_xattr
[    6.159096] EXT4-fs (sda2): re-mounted. Opts: acl,user_xattr
[    8.080592] udev: starting version 147
[    8.265123] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input1
[    8.274118] ACPI: Power Button [PWRB]
[    8.278259] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    8.286200] ACPI: Power Button [PWRF]
[    8.616482] input: PC Speaker as /devices/platform/pcspkr/input/input3
[    8.671970] sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
[    8.678451] cdrom: Uniform CD-ROM driver Revision: 3.20
[    8.684196] sr 0:0:0:0: Attached scsi CD-ROM sr0
[    8.740111] microcode: AMD CPU family 0xf not supported
[    8.746473] microcode: AMD CPU family 0xf not supported
[    8.757933] microcode: AMD CPU family 0xf not supported
[    8.764894] microcode: AMD CPU family 0xf not supported
[    8.771615] microcode: AMD CPU family 0xf not supported
[    8.778899] microcode: AMD CPU family 0xf not supported
[    8.785345] microcode: AMD CPU family 0xf not supported
[    8.791100] sr 0:0:0:0: Attached scsi generic sg0 type 5
[    8.796804] sd 2:0:0:0: Attached scsi generic sg1 type 0
[    8.803229] microcode: AMD CPU family 0xf not supported
[    8.975186] MCE: In-kernel MCE decoding enabled.
[    9.117064] k8temp 0000:00:18.3: Temperature readouts might be wrong - check erratum #141
[    9.125970] k8temp 0000:00:19.3: Temperature readouts might be wrong - check erratum #141
[    9.134931] k8temp 0000:00:1a.3: Temperature readouts might be wrong - check erratum #141
[    9.143797] k8temp 0000:00:1b.3: Temperature readouts might be wrong - check erratum #141
[    9.250753] pci 0000:00:07.3: AMD GPIO region 0xc0b0 already in use!
[    9.327627] AMD768 RNG detected
[    9.734197] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    9.740557] EDAC MC: Ver: 3.0.0
[    9.988372] AMD64 EDAC driver v3.4.0
[    9.992281] EDAC amd64: DRAM ECC disabled.
[    9.996793] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[    9.996793]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[    9.996793]  (Note that use of the override may cause unknown side effects.)
[   10.022838] EDAC amd64: DRAM ECC disabled.
[   10.027301] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.027301]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.027301]  (Note that use of the override may cause unknown side effects.)
[   10.053552] EDAC amd64: DRAM ECC disabled.
[   10.057976] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.057976]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.057976]  (Note that use of the override may cause unknown side effects.)
[   10.084231] EDAC amd64: DRAM ECC disabled.
[   10.088647] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.088647]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.088647]  (Note that use of the override may cause unknown side effects.)
[   10.115314] shpchp 0000:00:0a.0: HPC vendor_id 1022 device_id 7450 ss_vid 0 ss_did 0
[   10.123619] shpchp 0000:00:0a.0: Cannot reserve MMIO region
[   10.129877] shpchp 0000:00:0b.0: HPC vendor_id 1022 device_id 7450 ss_vid 0 ss_did 0
[   10.138158] shpchp 0000:00:0b.0: Cannot reserve MMIO region
[   10.144129] shpchp 0000:0a:01.0: HPC vendor_id 1022 device_id 7450 ss_vid 0 ss_did 0
[   10.152522] shpchp 0000:0a:01.0: Cannot reserve MMIO region
[   10.159498] shpchp 0000:0a:02.0: HPC vendor_id 1022 device_id 7450 ss_vid 0 ss_did 0
[   10.167858] shpchp 0000:0a:02.0: Cannot reserve MMIO region
[   10.173766] AMD64 EDAC driver v3.4.0
[   10.173850] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   10.187096] EDAC amd64: DRAM ECC disabled.
[   10.191592] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.191592]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.191592]  (Note that use of the override may cause unknown side effects.)
[   10.218418] EDAC amd64: DRAM ECC disabled.
[   10.222891] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.222891]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.222891]  (Note that use of the override may cause unknown side effects.)
[   10.248729] EDAC amd64: DRAM ECC disabled.
[   10.253142] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.253142]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.253142]  (Note that use of the override may cause unknown side effects.)
[   10.278923] EDAC amd64: DRAM ECC disabled.
[   10.283447] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.283447]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.283447]  (Note that use of the override may cause unknown side effects.)
[   10.313313] AMD64 EDAC driver v3.4.0
[   10.317345] EDAC amd64: DRAM ECC disabled.
[   10.322145] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.322145]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.322145]  (Note that use of the override may cause unknown side effects.)
[   10.348285] EDAC amd64: DRAM ECC disabled.
[   10.352720] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.352720]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.352720]  (Note that use of the override may cause unknown side effects.)
[   10.379749] EDAC amd64: DRAM ECC disabled.
[   10.384220] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.384220]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.384220]  (Note that use of the override may cause unknown side effects.)
[   10.410363] EDAC amd64: DRAM ECC disabled.
[   10.414771] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.414771]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.414771]  (Note that use of the override may cause unknown side effects.)
[   10.445089] AMD64 EDAC driver v3.4.0
[   10.449040] EDAC amd64: DRAM ECC disabled.
[   10.453410] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.453410]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.453410]  (Note that use of the override may cause unknown side effects.)
[   10.484632] EDAC amd64: DRAM ECC disabled.
[   10.489036] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.489036]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.489036]  (Note that use of the override may cause unknown side effects.)
[   10.514589] EDAC amd64: DRAM ECC disabled.
[   10.518963] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.518963]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.518963]  (Note that use of the override may cause unknown side effects.)
[   10.544495] EDAC amd64: DRAM ECC disabled.
[   10.548858] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   10.548858]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   10.548858]  (Note that use of the override may cause unknown side effects.)
[   10.786265] pps_core: LinuxPPS API ver. 1 registered
[   10.791541] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[   10.891380] kvm: Nested Virtualization enabled
[   10.973977] PTP clock support registered
[   11.153593] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   11.161004] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   11.167467] powernow-k8: fid 0x10 (2400 MHz), vid 0x8
[   11.173090] powernow-k8: fid 0xe (2200 MHz), vid 0xa
[   11.178409] powernow-k8: fid 0xc (2000 MHz), vid 0xc
[   11.184261] powernow-k8: fid 0xa (1800 MHz), vid 0xe
[   11.189561] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
[   11.194993] powernow-k8: fid 0x10 (2400 MHz), vid 0x8
[   11.200311] powernow-k8: fid 0xe (2200 MHz), vid 0xa
[   11.205714] powernow-k8: fid 0xc (2000 MHz), vid 0xc
[   11.211250] powernow-k8: fid 0xa (1800 MHz), vid 0xe
[   11.216669] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
[   11.222074] powernow-k8: fid 0x10 (2400 MHz), vid 0x8
[   11.227584] powernow-k8: fid 0xe (2200 MHz), vid 0xa
[   11.232862] powernow-k8: fid 0xc (2000 MHz), vid 0xc
[   11.238097] powernow-k8: fid 0xa (1800 MHz), vid 0xe
[   11.243462] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
[   11.248922] powernow-k8: fid 0x10 (2400 MHz), vid 0x8
[   11.254305] powernow-k8: fid 0xe (2200 MHz), vid 0xa
[   11.259545] powernow-k8: fid 0xc (2000 MHz), vid 0xc
[   11.264785] powernow-k8: fid 0xa (1800 MHz), vid 0xe
[   11.270232] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
[   11.276179] tg3.c:v3.130 (February 14, 2013)
[   11.276800] powernow-k8: Found 2 AMD Engineering Sample (8 cpu cores) (version 2.20.00)
[   11.614401] e1000 0000:0b:01.0 eth0: (PCI:66MHz:32-bit) 00:1b:21:22:77:2e
[   11.621891] e1000 0000:0b:01.0 eth0: Intel(R) PRO/1000 Network Connection
[   12.472105] floppy0: no floppy controllers found
[   12.784966] tg3 0000:02:01.0 eth1: Tigon3 [partno(3C996B-T) rev 0105] (PCIX:133MHz:64-bit) MAC address 00:04:76:f1:0a:21
[   12.796372] tg3 0000:02:01.0 eth1: attached PHY is 5701 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   12.806600] tg3 0000:02:01.0 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[0]
[   12.814913] tg3 0000:02:01.0 eth1: dma_rwctrl[76db000f] dma_mask[64-bit]
[   12.861418] tg3 0000:03:02.0 eth2: Tigon3 [partno(BCM95704A6) rev 2003] (PCIX:100MHz:64-bit) MAC address 00:00:1a:19:c8:e2
[   12.872987] tg3 0000:03:02.0 eth2: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   12.883224] tg3 0000:03:02.0 eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[   12.891531] tg3 0000:03:02.0 eth2: dma_rwctrl[769f4000] dma_mask[64-bit]
[   12.933638] tg3 0000:03:02.1 eth3: Tigon3 [partno(BCM95704A6) rev 2003] (PCIX:100MHz:64-bit) MAC address 00:00:1a:19:c8:e1
[   12.945161] tg3 0000:03:02.1 eth3: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   12.955369] tg3 0000:03:02.1 eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[   12.963641] tg3 0000:03:02.1 eth3: dma_rwctrl[769f4000] dma_mask[64-bit]
[   13.009478] tg3 0000:10:02.0 eth4: Tigon3 [partno(BCM95704A6) rev 2003] (PCIX:100MHz:64-bit) MAC address 00:00:1a:19:c9:5e
[   13.021158] tg3 0000:10:02.0 eth4: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   13.031488] tg3 0000:10:02.0 eth4: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[   13.039862] tg3 0000:10:02.0 eth4: dma_rwctrl[769f4000] dma_mask[64-bit]
[   13.078155] tg3 0000:10:02.1 eth5: Tigon3 [partno(BCM95704A6) rev 2003] (PCIX:100MHz:64-bit) MAC address 00:00:1a:19:c9:5d
[   13.089837] tg3 0000:10:02.1 eth5: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   13.100163] tg3 0000:10:02.1 eth5: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[   13.108524] tg3 0000:10:02.1 eth5: dma_rwctrl[769f4000] dma_mask[64-bit]
[   15.504143] floppy0: no floppy controllers found
[   15.628978] Adding 2104476k swap on /dev/sda1.  Priority:-1 extents:1 across:2104476k 
[   16.025597] device-mapper: uevent: version 1.0.3
[   16.030896] device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) initialised: dm-devel@redhat.com
[   16.579014] loop: module loaded
[   17.475596] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no debug enabled
[   17.524049] XFS (sda9): Mounting Filesystem
[   17.950029] XFS (sda9): Starting recovery (logdev: internal)
[   18.777643] XFS (sda9): Ending recovery (logdev: internal)
[   21.090510] fuse init (API version 7.21)
[   31.600331] Bridge firewalling registered
[   31.878857] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[   31.882123] device eth1 entered promiscuous mode
[   31.892116] IPv6: ADDRCONF(NETDEV_UP): br0: link is not ready
[   34.786553] tg3 0000:02:01.0 eth1: Link is up at 1000 Mbps, full duplex
[   34.786578] tg3 0000:02:01.0 eth1: Flow control is on for TX and on for RX
[   34.786612] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   34.786719] br0: port 1(eth1) entered forwarding state
[   34.786733] br0: port 1(eth1) entered forwarding state
[   34.786893] IPv6: ADDRCONF(NETDEV_CHANGE): br0: link becomes ready
[   35.470290] NET: Registered protocol family 17
[   39.831645] RPC: Registered named UNIX socket transport module.
[   39.831659] RPC: Registered udp transport module.
[   39.831663] RPC: Registered tcp transport module.
[   39.831667] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   40.113821] FS-Cache: Loaded
[   40.466530] FS-Cache: Netfs 'nfs' registered for caching
[   42.180953] BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
[ 1744.821043] start.sh (5028): dropped kernel caches: 3
[ 2761.426095] run_test.sh (5050): dropped kernel caches: 3
[ 2815.442225] run_test.sh (5049): dropped kernel caches: 3
[ 2827.697507] start.sh (10101): dropped kernel caches: 3
[ 3907.055403] run_test.sh (10130): dropped kernel caches: 3
[ 3956.153741] run_test.sh (10131): dropped kernel caches: 3
[ 3967.873725] start.sh (16910): dropped kernel caches: 3
[ 5039.249150] run_test.sh (16940): dropped kernel caches: 3
[ 5047.985116] run_test.sh (16939): dropped kernel caches: 3
[ 5060.180075] start.sh (23048): dropped kernel caches: 3
[ 5879.242283] run_test.sh (23084): dropped kernel caches: 3
[ 5893.533277] run_test.sh (23083): dropped kernel caches: 3
[ 5905.577640] start.sh (26140): dropped kernel caches: 3
[ 6738.882048] run_test.sh (26169): dropped kernel caches: 3
[ 6746.648133] run_test.sh (26170): dropped kernel caches: 3
[ 6758.694415] start.sh (29415): dropped kernel caches: 3
[ 7592.056829] run_test.sh (29445): dropped kernel caches: 3
[ 7596.312199] run_test.sh (29444): dropped kernel caches: 3
[10565.621240] start.sh (892): dropped kernel caches: 3
[11535.852096] run_test.sh (922): dropped kernel caches: 3
[11635.432116] run_test.sh (923): dropped kernel caches: 3
[11647.652973] start.sh (7480): dropped kernel caches: 3
[12775.453315] run_test.sh (7510): dropped kernel caches: 3
[12792.798731] run_test.sh (7509): dropped kernel caches: 3
[12804.433827] start.sh (14720): dropped kernel caches: 3
[14032.290678] run_test.sh (14749): dropped kernel caches: 3
[14046.744583] run_test.sh (14750): dropped kernel caches: 3
[14059.287745] start.sh (22284): dropped kernel caches: 3
[14924.853945] run_test.sh (22314): dropped kernel caches: 3
[14924.863861] run_test.sh (22315): dropped kernel caches: 3
[14937.861865] start.sh (25954): dropped kernel caches: 3
[15840.230633] run_test.sh (25983): dropped kernel caches: 3
[15840.460598] run_test.sh (25984): dropped kernel caches: 3
[15858.177817] start.sh (30093): dropped kernel caches: 3
[16747.692711] run_test.sh (30128): dropped kernel caches: 3
[16754.236454] run_test.sh (30127): dropped kernel caches: 3
[16770.122066] start.sh (1675): dropped kernel caches: 3
[17894.897622] run_test.sh (1706): dropped kernel caches: 3
[17894.897647] run_test.sh (1705): dropped kernel caches: 3
[17906.602681] start.sh (9219): dropped kernel caches: 3
[19084.427238] run_test.sh (9248): dropped kernel caches: 3
[19124.504121] run_test.sh (9249): dropped kernel caches: 3
[19136.789567] start.sh (16993): dropped kernel caches: 3
[20533.841509] run_test.sh (17022): dropped kernel caches: 3
[20535.927383] run_test.sh (17023): dropped kernel caches: 3
[20547.333776] start.sh (26237): dropped kernel caches: 3
[21445.407932] run_test.sh (26267): dropped kernel caches: 3
[21446.166815] run_test.sh (26266): dropped kernel caches: 3
[21460.166389] start.sh (29985): dropped kernel caches: 3
[22354.279533] run_test.sh (30019): dropped kernel caches: 3
[22373.535224] run_test.sh (30020): dropped kernel caches: 3
[22385.815465] start.sh (2087): dropped kernel caches: 3
[23274.653688] run_test.sh (2117): dropped kernel caches: 3
[23274.653875] run_test.sh (2116): dropped kernel caches: 3
[28589.697722] start.sh (7752): dropped kernel caches: 3
[29943.626223] run_test.sh (7782): dropped kernel caches: 3
[29943.626671] run_test.sh (7781): dropped kernel caches: 3
[29955.454547] start.sh (16325): dropped kernel caches: 3
[31265.365454] run_test.sh (16355): dropped kernel caches: 3
[31265.365463] run_test.sh (16354): dropped kernel caches: 3
[31277.561806] start.sh (25020): dropped kernel caches: 3
[32649.463007] run_test.sh (25049): dropped kernel caches: 3
[32649.570650] run_test.sh (25050): dropped kernel caches: 3
[32664.115880] start.sh (1337): dropped kernel caches: 3
[33573.064679] run_test.sh (1367): dropped kernel caches: 3
[33582.338140] run_test.sh (1366): dropped kernel caches: 3
[33594.407287] start.sh (5825): dropped kernel caches: 3
[34509.102642] run_test.sh (5855): dropped kernel caches: 3
[34512.976769] run_test.sh (5854): dropped kernel caches: 3
[34525.637816] start.sh (10095): dropped kernel caches: 3
[35444.125032] run_test.sh (10125): dropped kernel caches: 3
[35444.128213] run_test.sh (10124): dropped kernel caches: 3
[35457.174141] start.sh (14289): dropped kernel caches: 3
[36808.158933] run_test.sh (14318): dropped kernel caches: 3
[36814.771629] run_test.sh (14319): dropped kernel caches: 3
[36826.320502] start.sh (23034): dropped kernel caches: 3
[38073.080136] run_test.sh (23063): dropped kernel caches: 3
[38073.080508] run_test.sh (23064): dropped kernel caches: 3
[38085.603173] start.sh (30987): dropped kernel caches: 3
[39340.373073] run_test.sh (31016): dropped kernel caches: 3
[39353.343312] run_test.sh (31017): dropped kernel caches: 3
[39364.929959] start.sh (6661): dropped kernel caches: 3
[40294.733773] run_test.sh (6691): dropped kernel caches: 3
[40296.604862] run_test.sh (6690): dropped kernel caches: 3
[40313.502875] start.sh (11182): dropped kernel caches: 3
[41265.676979] run_test.sh (11246): dropped kernel caches: 3
[41268.397822] run_test.sh (11245): dropped kernel caches: 3
[41281.146383] start.sh (15894): dropped kernel caches: 3
[42223.970711] run_test.sh (15923): dropped kernel caches: 3
[42223.986587] run_test.sh (15924): dropped kernel caches: 3
[42238.893545] start.sh (20564): dropped kernel caches: 3
[43402.502593] run_test.sh (20599): dropped kernel caches: 3
[43465.036660] run_test.sh (20598): dropped kernel caches: 3
[43476.757334] start.sh (28664): dropped kernel caches: 3
[44659.289429] run_test.sh (28694): dropped kernel caches: 3
[44678.487227] run_test.sh (28693): dropped kernel caches: 3
[44690.117820] start.sh (3628): dropped kernel caches: 3
[45971.497973] run_test.sh (3658): dropped kernel caches: 3
[46020.648218] run_test.sh (3657): dropped kernel caches: 3
[46032.489890] start.sh (12690): dropped kernel caches: 3
[46985.533535] run_test.sh (12720): dropped kernel caches: 3
[47001.385550] run_test.sh (12719): dropped kernel caches: 3
[47013.737901] start.sh (17395): dropped kernel caches: 3
[47957.262113] run_test.sh (17425): dropped kernel caches: 3
[47967.082602] run_test.sh (17424): dropped kernel caches: 3
[47979.111750] start.sh (22338): dropped kernel caches: 3
[48919.894257] run_test.sh (22367): dropped kernel caches: 3
[48919.894406] run_test.sh (22368): dropped kernel caches: 3
[48933.510810] start.sh (26651): dropped kernel caches: 3
[50266.136567] run_test.sh (26685): dropped kernel caches: 3
[50266.686401] run_test.sh (26686): dropped kernel caches: 3
[50281.446526] start.sh (2550): dropped kernel caches: 3
[51458.600907] run_test.sh (2580): dropped kernel caches: 3
[51488.945917] run_test.sh (2579): dropped kernel caches: 3
[51501.285970] start.sh (10585): dropped kernel caches: 3
[52717.389512] run_test.sh (10615): dropped kernel caches: 3
[52717.389522] run_test.sh (10614): dropped kernel caches: 3
[52730.047259] start.sh (18394): dropped kernel caches: 3
[53697.549879] run_test.sh (18424): dropped kernel caches: 3
[53697.567112] run_test.sh (18423): dropped kernel caches: 3
[53710.745912] start.sh (23106): dropped kernel caches: 3
[54682.000865] run_test.sh (23136): dropped kernel caches: 3
[54684.388645] run_test.sh (23135): dropped kernel caches: 3
[54696.694078] start.sh (27741): dropped kernel caches: 3
[55661.856076] run_test.sh (27771): dropped kernel caches: 3
[55674.920601] run_test.sh (27770): dropped kernel caches: 3
[55686.918067] start.sh (402): dropped kernel caches: 3
[57030.289106] run_test.sh (436): dropped kernel caches: 3
[57030.289202] run_test.sh (435): dropped kernel caches: 3
[57042.850406] start.sh (8795): dropped kernel caches: 3
[58289.940429] run_test.sh (8824): dropped kernel caches: 3
[58330.103350] run_test.sh (8825): dropped kernel caches: 3
[58342.308607] start.sh (16749): dropped kernel caches: 3
[59695.307881] run_test.sh (16778): dropped kernel caches: 3
[59695.450356] run_test.sh (16779): dropped kernel caches: 3
[59713.229607] start.sh (25292): dropped kernel caches: 3
[60665.211476] run_test.sh (25327): dropped kernel caches: 3
[60666.583904] run_test.sh (25326): dropped kernel caches: 3
[60683.161750] start.sh (30161): dropped kernel caches: 3
[61635.593315] run_test.sh (30195): dropped kernel caches: 3
[61639.910218] run_test.sh (30196): dropped kernel caches: 3
[61651.952558] start.sh (2606): dropped kernel caches: 3
[62630.181166] run_test.sh (2636): dropped kernel caches: 3
[62630.186838] run_test.sh (2635): dropped kernel caches: 3
[62644.173829] start.sh (7579): dropped kernel caches: 3
[63759.514246] run_test.sh (7609): dropped kernel caches: 3
[63780.868559] run_test.sh (7608): dropped kernel caches: 3
[63792.709932] start.sh (14494): dropped kernel caches: 3
[65149.818288] run_test.sh (14523): dropped kernel caches: 3
[65170.376485] run_test.sh (14524): dropped kernel caches: 3
[65182.770316] start.sh (24222): dropped kernel caches: 3
[66365.268227] run_test.sh (24256): dropped kernel caches: 3
[66392.007148] run_test.sh (24257): dropped kernel caches: 3
[66403.581820] start.sh (32183): dropped kernel caches: 3
[67355.957132] run_test.sh (32212): dropped kernel caches: 3
[67387.285364] run_test.sh (32213): dropped kernel caches: 3
[67400.041783] start.sh (5060): dropped kernel caches: 3
[68385.268815] run_test.sh (5089): dropped kernel caches: 3
[68385.449552] run_test.sh (5090): dropped kernel caches: 3
[68403.825809] start.sh (10202): dropped kernel caches: 3
[69356.260863] run_test.sh (10232): dropped kernel caches: 3
[69365.901222] run_test.sh (10231): dropped kernel caches: 3
[69378.034387] start.sh (14956): dropped kernel caches: 3
[70681.887344] run_test.sh (14986): dropped kernel caches: 3
[70734.920930] run_test.sh (14985): dropped kernel caches: 3
[70746.509502] start.sh (23993): dropped kernel caches: 3
[71939.631650] run_test.sh (24022): dropped kernel caches: 3
[72002.682784] run_test.sh (24023): dropped kernel caches: 3
[72014.718971] start.sh (32650): dropped kernel caches: 3
[73379.104611] run_test.sh (32679): dropped kernel caches: 3
[73379.777906] run_test.sh (32680): dropped kernel caches: 3
[73397.158099] start.sh (9753): dropped kernel caches: 3
[74378.872925] run_test.sh (9783): dropped kernel caches: 3
[74378.888685] run_test.sh (9782): dropped kernel caches: 3
[74393.138682] start.sh (14887): dropped kernel caches: 3
[75390.465421] run_test.sh (14921): dropped kernel caches: 3
[75390.472266] run_test.sh (14922): dropped kernel caches: 3
[75404.086033] start.sh (20107): dropped kernel caches: 3
[76409.632730] run_test.sh (20137): dropped kernel caches: 3
[76410.027730] run_test.sh (20136): dropped kernel caches: 3
[76424.077077] start.sh (25462): dropped kernel caches: 3
[77778.073863] run_test.sh (25492): dropped kernel caches: 3
[77781.630992] run_test.sh (25491): dropped kernel caches: 3
[77793.525953] start.sh (2071): dropped kernel caches: 3
[79109.632686] run_test.sh (2105): dropped kernel caches: 3
[79156.403172] run_test.sh (2106): dropped kernel caches: 3
[79168.195480] start.sh (10781): dropped kernel caches: 3
[80555.216266] run_test.sh (10810): dropped kernel caches: 3
[80555.216541] run_test.sh (10811): dropped kernel caches: 3
[80568.791191] start.sh (20040): dropped kernel caches: 3
[81558.422310] run_test.sh (20069): dropped kernel caches: 3
[81568.137960] run_test.sh (20070): dropped kernel caches: 3
[81580.637740] start.sh (25082): dropped kernel caches: 3
[82563.714165] run_test.sh (25117): dropped kernel caches: 3
[82564.414280] run_test.sh (25116): dropped kernel caches: 3
[82580.153975] start.sh (30147): dropped kernel caches: 3
[83565.827166] run_test.sh (30176): dropped kernel caches: 3
[83582.775235] run_test.sh (30177): dropped kernel caches: 3
[83596.750385] start.sh (3002): dropped kernel caches: 3
[84966.234539] run_test.sh (3041): dropped kernel caches: 3
[84966.234792] run_test.sh (3042): dropped kernel caches: 3
[84979.254451] start.sh (12258): dropped kernel caches: 3
[86424.033433] run_test.sh (12291): dropped kernel caches: 3
[86429.195606] run_test.sh (12292): dropped kernel caches: 3
[86440.671409] start.sh (21697): dropped kernel caches: 3
[87846.400516] run_test.sh (21727): dropped kernel caches: 3
[87903.868562] run_test.sh (21726): dropped kernel caches: 3
[87916.938118] start.sh (31473): dropped kernel caches: 3
[88920.952708] run_test.sh (31503): dropped kernel caches: 3
[88921.745459] run_test.sh (31502): dropped kernel caches: 3
[88935.505904] start.sh (4276): dropped kernel caches: 3
[89939.634755] run_test.sh (4309): dropped kernel caches: 3
[89939.634886] run_test.sh (4308): dropped kernel caches: 3
[89953.051421] start.sh (9642): dropped kernel caches: 3
[90972.976581] run_test.sh (9671): dropped kernel caches: 3
[90973.138177] run_test.sh (9672): dropped kernel caches: 3
[90992.453926] start.sh (15058): dropped kernel caches: 3
[92220.744922] run_test.sh (15088): dropped kernel caches: 3
[92227.401253] run_test.sh (15087): dropped kernel caches: 3
[92238.906095] start.sh (23923): dropped kernel caches: 3
[93436.878982] run_test.sh (23952): dropped kernel caches: 3
[93455.773468] run_test.sh (23953): dropped kernel caches: 3
[93468.289552] start.sh (32591): dropped kernel caches: 3
[94812.277729] run_test.sh (32620): dropped kernel caches: 3
[94823.830996] run_test.sh (32621): dropped kernel caches: 3
[94835.586039] start.sh (9245): dropped kernel caches: 3
[95841.684896] run_test.sh (9275): dropped kernel caches: 3
[95841.697956] run_test.sh (9274): dropped kernel caches: 3
[95854.658020] start.sh (14607): dropped kernel caches: 3
[96884.989131] run_test.sh (14636): dropped kernel caches: 3
[96884.989249] run_test.sh (14637): dropped kernel caches: 3
[96898.614283] start.sh (20102): dropped kernel caches: 3
[97920.642782] run_test.sh (20135): dropped kernel caches: 3
[97920.643088] run_test.sh (20134): dropped kernel caches: 3
[97934.839274] start.sh (25761): dropped kernel caches: 3
[99257.761692] run_test.sh (25790): dropped kernel caches: 3
[99341.646979] run_test.sh (25791): dropped kernel caches: 3
[99354.002311] start.sh (3268): dropped kernel caches: 3
[100800.590464] run_test.sh (3298): dropped kernel caches: 3
[100800.873909] run_test.sh (3297): dropped kernel caches: 3
[100820.903315] start.sh (12687): dropped kernel caches: 3
[102205.184912] run_test.sh (12727): dropped kernel caches: 3
[102213.310524] run_test.sh (12726): dropped kernel caches: 3
[102224.948238] start.sh (22198): dropped kernel caches: 3
[103249.654482] run_test.sh (22228): dropped kernel caches: 3
[103249.672540] run_test.sh (22227): dropped kernel caches: 3
[103262.487332] start.sh (27747): dropped kernel caches: 3
[104286.708245] run_test.sh (27776): dropped kernel caches: 3
[104286.708307] run_test.sh (27777): dropped kernel caches: 3
[104299.478042] start.sh (849): dropped kernel caches: 3
[105300.465397] run_test.sh (880): dropped kernel caches: 3
[105307.881530] run_test.sh (879): dropped kernel caches: 3
[105320.893760] start.sh (6267): dropped kernel caches: 3
[106651.940189] run_test.sh (6297): dropped kernel caches: 3
[106674.060861] run_test.sh (6296): dropped kernel caches: 3
[106688.786047] start.sh (15595): dropped kernel caches: 3
[108036.349474] run_test.sh (15625): dropped kernel caches: 3
[108117.864152] run_test.sh (15624): dropped kernel caches: 3
[108131.829728] start.sh (25463): dropped kernel caches: 3
[109585.152233] run_test.sh (25503): dropped kernel caches: 3
[109598.776067] run_test.sh (25502): dropped kernel caches: 3
[109610.261869] start.sh (2766): dropped kernel caches: 3
[110642.403124] run_test.sh (2796): dropped kernel caches: 3
[110649.498781] run_test.sh (2795): dropped kernel caches: 3
[110662.320608] start.sh (8360): dropped kernel caches: 3
[111702.106452] run_test.sh (8390): dropped kernel caches: 3
[111702.192227] run_test.sh (8389): dropped kernel caches: 3
[111719.157879] start.sh (13986): dropped kernel caches: 3
[112764.389077] run_test.sh (14015): dropped kernel caches: 3
[112764.730378] run_test.sh (14016): dropped kernel caches: 3
[112779.893688] start.sh (19616): dropped kernel caches: 3
[114144.975103] run_test.sh (19645): dropped kernel caches: 3
[114208.904219] run_test.sh (19646): dropped kernel caches: 3
[114221.134272] start.sh (29135): dropped kernel caches: 3
[115522.888860] run_test.sh (29165): dropped kernel caches: 3
[115522.889182] run_test.sh (29164): dropped kernel caches: 3
[115535.469772] start.sh (5272): dropped kernel caches: 3
[116822.380839] run_test.sh (5301): dropped kernel caches: 3
[116883.288144] run_test.sh (5302): dropped kernel caches: 3
[116895.871163] start.sh (13956): dropped kernel caches: 3
[117946.155106] run_test.sh (13986): dropped kernel caches: 3
[117960.796663] run_test.sh (13985): dropped kernel caches: 3
[117973.528215] start.sh (19632): dropped kernel caches: 3
[118989.330575] run_test.sh (19662): dropped kernel caches: 3
[118989.330839] run_test.sh (19661): dropped kernel caches: 3
[119002.770050] start.sh (25092): dropped kernel caches: 3
[120044.424328] run_test.sh (25122): dropped kernel caches: 3
[120045.213212] run_test.sh (25121): dropped kernel caches: 3
[120061.281159] start.sh (30921): dropped kernel caches: 3
[121565.202359] run_test.sh (30955): dropped kernel caches: 3
[121565.202507] run_test.sh (30956): dropped kernel caches: 3
[121577.663775] start.sh (8412): dropped kernel caches: 3
[122876.733337] run_test.sh (8441): dropped kernel caches: 3
[122889.161106] run_test.sh (8442): dropped kernel caches: 3
[122900.689041] start.sh (17195): dropped kernel caches: 3
[124423.465559] run_test.sh (17225): dropped kernel caches: 3
[124480.440672] run_test.sh (17224): dropped kernel caches: 3
[124493.461916] start.sh (28030): dropped kernel caches: 3
[125547.514213] run_test.sh (28065): dropped kernel caches: 3
[125547.722929] run_test.sh (28066): dropped kernel caches: 3
[125563.026019] start.sh (1412): dropped kernel caches: 3
[126630.041789] run_test.sh (1445): dropped kernel caches: 3
[126636.521199] run_test.sh (1444): dropped kernel caches: 3
[126649.266920] start.sh (7393): dropped kernel caches: 3
[127694.137507] run_test.sh (7422): dropped kernel caches: 3
[127694.137704] run_test.sh (7423): dropped kernel caches: 3
[127707.635121] start.sh (13355): dropped kernel caches: 3
[129001.089755] run_test.sh (13385): dropped kernel caches: 3
[129001.089946] run_test.sh (13384): dropped kernel caches: 3
[129013.676130] start.sh (22051): dropped kernel caches: 3
[130228.789373] run_test.sh (22081): dropped kernel caches: 3
[130315.903241] run_test.sh (22080): dropped kernel caches: 3
[130329.262009] start.sh (31277): dropped kernel caches: 3
[131785.156957] run_test.sh (31309): dropped kernel caches: 3
[131791.517881] run_test.sh (31310): dropped kernel caches: 3
[131803.630543] start.sh (8602): dropped kernel caches: 3
[132861.095665] run_test.sh (8632): dropped kernel caches: 3
[132861.095696] run_test.sh (8633): dropped kernel caches: 3
[132875.046985] start.sh (14506): dropped kernel caches: 3
[133940.080474] run_test.sh (14544): dropped kernel caches: 3
[133946.758541] run_test.sh (14543): dropped kernel caches: 3
[133959.733934] start.sh (20452): dropped kernel caches: 3
[135006.128904] run_test.sh (20481): dropped kernel caches: 3
[135006.154381] run_test.sh (20482): dropped kernel caches: 3
[135019.806170] start.sh (25992): dropped kernel caches: 3
[136404.069737] run_test.sh (26022): dropped kernel caches: 3
[136404.127463] run_test.sh (26021): dropped kernel caches: 3
[136420.553914] start.sh (3545): dropped kernel caches: 3
[137819.411895] run_test.sh (3575): dropped kernel caches: 3
[137823.013642] run_test.sh (3576): dropped kernel caches: 3
[137834.622029] start.sh (12876): dropped kernel caches: 3
[139292.147243] run_test.sh (12906): dropped kernel caches: 3
[139299.244901] run_test.sh (12905): dropped kernel caches: 3
[139311.541696] start.sh (23172): dropped kernel caches: 3
[140369.747771] run_test.sh (23203): dropped kernel caches: 3
[140369.748406] run_test.sh (23202): dropped kernel caches: 3
[140383.814673] start.sh (29161): dropped kernel caches: 3
[141451.945337] run_test.sh (29194): dropped kernel caches: 3
[141451.964385] run_test.sh (29193): dropped kernel caches: 3
[141464.681989] start.sh (2512): dropped kernel caches: 3
[142517.753399] run_test.sh (2542): dropped kernel caches: 3
[142519.382818] run_test.sh (2541): dropped kernel caches: 3
[142534.505885] start.sh (8659): dropped kernel caches: 3
[143889.296684] run_test.sh (8688): dropped kernel caches: 3
[143889.296741] run_test.sh (8689): dropped kernel caches: 3
[143901.904368] start.sh (18253): dropped kernel caches: 3
[145183.246550] run_test.sh (18287): dropped kernel caches: 3
[145183.246932] run_test.sh (18288): dropped kernel caches: 3
[145195.974580] start.sh (27352): dropped kernel caches: 3
[146658.565594] run_test.sh (27382): dropped kernel caches: 3
[146664.735406] run_test.sh (27381): dropped kernel caches: 3
[146678.045933] start.sh (4388): dropped kernel caches: 3
[147743.213760] run_test.sh (4426): dropped kernel caches: 3
[147743.227593] run_test.sh (4425): dropped kernel caches: 3
[147756.538377] start.sh (10237): dropped kernel caches: 3
[148835.364323] run_test.sh (10267): dropped kernel caches: 3
[148837.659236] run_test.sh (10266): dropped kernel caches: 3
[148858.133782] start.sh (16252): dropped kernel caches: 3
[149928.023317] run_test.sh (16287): dropped kernel caches: 3
[149930.358878] run_test.sh (16286): dropped kernel caches: 3
[149943.008830] start.sh (22282): dropped kernel caches: 3
[151471.561331] run_test.sh (22312): dropped kernel caches: 3
[151471.643920] run_test.sh (22311): dropped kernel caches: 3
[151491.006545] start.sh (372): dropped kernel caches: 3
[152811.219260] run_test.sh (406): dropped kernel caches: 3
[152811.227265] run_test.sh (407): dropped kernel caches: 3
[152824.816551] start.sh (10008): dropped kernel caches: 3
[154301.049094] run_test.sh (10037): dropped kernel caches: 3
[154301.535590] run_test.sh (10038): dropped kernel caches: 3
[154319.890097] start.sh (20266): dropped kernel caches: 3
[155401.818996] run_test.sh (20295): dropped kernel caches: 3
[155402.438812] run_test.sh (20296): dropped kernel caches: 3
[155421.398647] start.sh (26345): dropped kernel caches: 3
[156500.280551] run_test.sh (26374): dropped kernel caches: 3
[156507.028557] run_test.sh (26375): dropped kernel caches: 3
[156520.029019] start.sh (32431): dropped kernel caches: 3
[157609.836544] run_test.sh (32460): dropped kernel caches: 3
[157609.849909] run_test.sh (32461): dropped kernel caches: 3
[157623.797973] start.sh (6344): dropped kernel caches: 3
[159151.679187] run_test.sh (6373): dropped kernel caches: 3
[159209.562026] run_test.sh (6374): dropped kernel caches: 3
[159222.006083] start.sh (17820): dropped kernel caches: 3
[160582.073370] run_test.sh (17850): dropped kernel caches: 3
[160582.073448] run_test.sh (17849): dropped kernel caches: 3
[160594.698186] start.sh (27320): dropped kernel caches: 3
[162034.753532] run_test.sh (27350): dropped kernel caches: 3
[162041.271336] run_test.sh (27349): dropped kernel caches: 3
[162065.798111] start.sh (5216): dropped kernel caches: 3
[163159.491982] run_test.sh (5305): dropped kernel caches: 3
[163159.495754] run_test.sh (5306): dropped kernel caches: 3
[163172.770335] start.sh (11503): dropped kernel caches: 3
[164268.096965] run_test.sh (11533): dropped kernel caches: 3
[164278.643693] run_test.sh (11532): dropped kernel caches: 3
[164290.702093] start.sh (17917): dropped kernel caches: 3
[165373.085997] run_test.sh (17946): dropped kernel caches: 3
[165384.758431] run_test.sh (17947): dropped kernel caches: 3
[165398.374547] start.sh (24339): dropped kernel caches: 3
[166717.126060] run_test.sh (24368): dropped kernel caches: 3
[166784.371602] run_test.sh (24369): dropped kernel caches: 3
[166795.877796] start.sh (1645): dropped kernel caches: 3
[168311.722962] run_test.sh (1675): dropped kernel caches: 3
[168312.908954] run_test.sh (1674): dropped kernel caches: 3
[168332.314260] start.sh (13211): dropped kernel caches: 3
[169771.584652] run_test.sh (13245): dropped kernel caches: 3
[169771.584759] run_test.sh (13246): dropped kernel caches: 3
[169783.363557] start.sh (23578): dropped kernel caches: 3
[170870.300593] run_test.sh (23607): dropped kernel caches: 3
[170870.300839] run_test.sh (23608): dropped kernel caches: 3
[170884.258899] start.sh (30027): dropped kernel caches: 3
[171969.357413] run_test.sh (30065): dropped kernel caches: 3
[171969.371433] run_test.sh (30064): dropped kernel caches: 3
[171983.145997] start.sh (3824): dropped kernel caches: 3
[173066.896915] run_test.sh (3859): dropped kernel caches: 3
[173068.083913] run_test.sh (3858): dropped kernel caches: 3
[173084.710129] start.sh (9802): dropped kernel caches: 3
[174324.480275] run_test.sh (9841): dropped kernel caches: 3
[174435.277627] run_test.sh (9842): dropped kernel caches: 3
[174446.794291] start.sh (19474): dropped kernel caches: 3
[175869.392133] run_test.sh (19504): dropped kernel caches: 3
[175876.995183] run_test.sh (19503): dropped kernel caches: 3
[175889.560951] start.sh (29286): dropped kernel caches: 3
[177279.766754] run_test.sh (29320): dropped kernel caches: 3
[177293.432145] run_test.sh (29321): dropped kernel caches: 3
[177305.129115] start.sh (6220): dropped kernel caches: 3
[178382.080107] run_test.sh (6250): dropped kernel caches: 3
[178382.080285] run_test.sh (6249): dropped kernel caches: 3
[178395.565726] start.sh (12432): dropped kernel caches: 3
[179467.702291] run_test.sh (12462): dropped kernel caches: 3
[179468.909214] run_test.sh (12461): dropped kernel caches: 3
[179484.661615] start.sh (18502): dropped kernel caches: 3
[180595.731792] run_test.sh (18532): dropped kernel caches: 3
[180595.934993] run_test.sh (18531): dropped kernel caches: 3
[180613.262251] start.sh (25054): dropped kernel caches: 3
[182105.688428] run_test.sh (25088): dropped kernel caches: 3
[182134.805903] run_test.sh (25089): dropped kernel caches: 3
[182146.957388] start.sh (3753): dropped kernel caches: 3
[183517.651687] run_test.sh (3783): dropped kernel caches: 3
[183545.067241] run_test.sh (3782): dropped kernel caches: 3
[183558.328217] start.sh (13002): dropped kernel caches: 3
[184958.215274] run_test.sh (13037): dropped kernel caches: 3
[184968.609816] run_test.sh (13036): dropped kernel caches: 3
[184980.150352] start.sh (22733): dropped kernel caches: 3
[186065.714637] run_test.sh (22763): dropped kernel caches: 3
[186068.485658] run_test.sh (22762): dropped kernel caches: 3
[186082.457916] start.sh (28935): dropped kernel caches: 3
[187170.773576] run_test.sh (28975): dropped kernel caches: 3
[187171.436786] run_test.sh (28974): dropped kernel caches: 3
[187202.673902] start.sh (3113): dropped kernel caches: 3
[188304.198465] run_test.sh (3203): dropped kernel caches: 3
[188312.058524] run_test.sh (3202): dropped kernel caches: 3
[188324.133926] start.sh (9533): dropped kernel caches: 3
[189763.583430] run_test.sh (9563): dropped kernel caches: 3
[189768.906587] run_test.sh (9562): dropped kernel caches: 3
[189781.253989] start.sh (19706): dropped kernel caches: 3
[191162.628121] run_test.sh (19735): dropped kernel caches: 3
[191162.628301] run_test.sh (19736): dropped kernel caches: 3
[191176.474495] start.sh (29442): dropped kernel caches: 3
[192556.737512] run_test.sh (29472): dropped kernel caches: 3
[192559.520206] run_test.sh (29471): dropped kernel caches: 3
[192571.061558] start.sh (6107): dropped kernel caches: 3
[193675.217583] run_test.sh (6136): dropped kernel caches: 3
[193690.495735] run_test.sh (6137): dropped kernel caches: 3
[193702.838359] start.sh (12608): dropped kernel caches: 3
[194803.194251] run_test.sh (12637): dropped kernel caches: 3
[194803.205600] run_test.sh (12638): dropped kernel caches: 3
[194820.824479] start.sh (19018): dropped kernel caches: 3
[195923.875339] run_test.sh (19081): dropped kernel caches: 3
[195952.685307] run_test.sh (19080): dropped kernel caches: 3
[195965.913832] start.sh (25744): dropped kernel caches: 3
[197477.550590] run_test.sh (25773): dropped kernel caches: 3
[197477.768983] run_test.sh (25774): dropped kernel caches: 3
[197493.299276] start.sh (3760): dropped kernel caches: 3
[198936.217406] run_test.sh (3790): dropped kernel caches: 3
[198936.550862] run_test.sh (3789): dropped kernel caches: 3
[198954.864119] start.sh (13706): dropped kernel caches: 3
[200304.967112] run_test.sh (13736): dropped kernel caches: 3
[200304.967496] run_test.sh (13735): dropped kernel caches: 3
[200317.638592] start.sh (23035): dropped kernel caches: 3
[201426.923186] run_test.sh (23064): dropped kernel caches: 3
[201426.923698] run_test.sh (23065): dropped kernel caches: 3
[201439.602959] start.sh (29369): dropped kernel caches: 3
[202530.940910] run_test.sh (29399): dropped kernel caches: 3
[202531.351003] run_test.sh (29398): dropped kernel caches: 3
[202550.002082] start.sh (3264): dropped kernel caches: 3
[203660.439532] run_test.sh (3293): dropped kernel caches: 3
[203666.064045] run_test.sh (3294): dropped kernel caches: 3
[203679.341950] start.sh (9845): dropped kernel caches: 3
[205184.543569] run_test.sh (9875): dropped kernel caches: 3
[205277.438836] run_test.sh (9874): dropped kernel caches: 3
[205289.830546] start.sh (20809): dropped kernel caches: 3
[206719.577558] run_test.sh (20839): dropped kernel caches: 3
[206744.642844] run_test.sh (20838): dropped kernel caches: 3
[206757.299024] start.sh (30314): dropped kernel caches: 3
[208297.096209] run_test.sh (30343): dropped kernel caches: 3
[208299.575322] run_test.sh (30344): dropped kernel caches: 3
[208311.126118] start.sh (8322): dropped kernel caches: 3
[209422.813839] run_test.sh (8353): dropped kernel caches: 3
[209443.508452] run_test.sh (8354): dropped kernel caches: 3
[209457.076874] start.sh (14851): dropped kernel caches: 3
[210560.765080] run_test.sh (14885): dropped kernel caches: 3
[210560.946551] run_test.sh (14886): dropped kernel caches: 3
[210576.722171] start.sh (21064): dropped kernel caches: 3
[211689.652766] run_test.sh (21094): dropped kernel caches: 3
[211689.667325] run_test.sh (21093): dropped kernel caches: 3
[211702.934086] start.sh (27684): dropped kernel caches: 3
[213108.814387] run_test.sh (27714): dropped kernel caches: 3
[213109.635312] run_test.sh (27713): dropped kernel caches: 3
[213126.213782] start.sh (4844): dropped kernel caches: 3
[214513.680138] run_test.sh (4873): dropped kernel caches: 3
[214513.680201] run_test.sh (4874): dropped kernel caches: 3
[214526.190295] start.sh (14183): dropped kernel caches: 3
[215971.588432] run_test.sh (14212): dropped kernel caches: 3
[216005.115422] run_test.sh (14213): dropped kernel caches: 3
[216016.789865] start.sh (23558): dropped kernel caches: 3
[217105.145613] run_test.sh (23588): dropped kernel caches: 3
[217105.159443] run_test.sh (23587): dropped kernel caches: 3
[217118.434129] start.sh (29991): dropped kernel caches: 3
[218228.614090] run_test.sh (30020): dropped kernel caches: 3
[218228.631890] run_test.sh (30021): dropped kernel caches: 3
[218243.466150] start.sh (3980): dropped kernel caches: 3
[219331.968867] run_test.sh (4017): dropped kernel caches: 3
[219332.675081] run_test.sh (4018): dropped kernel caches: 3
[219348.351003] start.sh (10129): dropped kernel caches: 3
[220826.781998] run_test.sh (10159): dropped kernel caches: 3
[220826.782311] run_test.sh (10158): dropped kernel caches: 3
[220841.958917] start.sh (20019): dropped kernel caches: 3
[222382.486135] run_test.sh (20054): dropped kernel caches: 3
[222382.487411] run_test.sh (20053): dropped kernel caches: 3
[222395.566373] start.sh (30180): dropped kernel caches: 3
[223969.653319] run_test.sh (30210): dropped kernel caches: 3
[223998.520858] run_test.sh (30209): dropped kernel caches: 3
[224010.694063] start.sh (8366): dropped kernel caches: 3
[225111.083938] run_test.sh (8395): dropped kernel caches: 3
[225111.466991] run_test.sh (8396): dropped kernel caches: 3
[225127.138328] start.sh (14620): dropped kernel caches: 3
[226216.387030] run_test.sh (14649): dropped kernel caches: 3
[226227.741583] run_test.sh (14650): dropped kernel caches: 3
[226240.849875] start.sh (20738): dropped kernel caches: 3
[227351.819002] run_test.sh (20773): dropped kernel caches: 3
[227357.710951] run_test.sh (20772): dropped kernel caches: 3
[227371.514322] start.sh (27122): dropped kernel caches: 3
[228814.560279] run_test.sh (27151): dropped kernel caches: 3
[228874.621905] run_test.sh (27152): dropped kernel caches: 3
[228886.290780] start.sh (5754): dropped kernel caches: 3
[230284.994380] run_test.sh (5784): dropped kernel caches: 3
[230291.105378] run_test.sh (5785): dropped kernel caches: 3
[230302.722154] start.sh (15515): dropped kernel caches: 3
[231810.256545] run_test.sh (15545): dropped kernel caches: 3
[231832.737197] run_test.sh (15544): dropped kernel caches: 3
[231845.491296] start.sh (26282): dropped kernel caches: 3
[232949.986945] run_test.sh (26312): dropped kernel caches: 3
[232962.779760] run_test.sh (26311): dropped kernel caches: 3
[232975.125893] start.sh (32640): dropped kernel caches: 3
[234074.797561] run_test.sh (32670): dropped kernel caches: 3
[234075.472818] run_test.sh (32669): dropped kernel caches: 3
[234093.797875] start.sh (6395): dropped kernel caches: 3
[235200.826055] run_test.sh (6424): dropped kernel caches: 3
[235225.908461] run_test.sh (6425): dropped kernel caches: 3
[235242.949491] start.sh (13359): dropped kernel caches: 3
[236553.475567] run_test.sh (13394): dropped kernel caches: 3
[236600.924426] run_test.sh (13393): dropped kernel caches: 3
[236613.848650] start.sh (22897): dropped kernel caches: 3
[238058.072469] run_test.sh (22926): dropped kernel caches: 3
[238058.072572] run_test.sh (22927): dropped kernel caches: 3
[238072.898059] start.sh (629): dropped kernel caches: 3
[239482.334602] run_test.sh (670): dropped kernel caches: 3
[239517.814631] run_test.sh (671): dropped kernel caches: 3
[239529.820377] start.sh (11122): dropped kernel caches: 3
[240619.448652] run_test.sh (11151): dropped kernel caches: 3
[240626.388972] run_test.sh (11152): dropped kernel caches: 3
[240638.490066] start.sh (17398): dropped kernel caches: 3
[241744.113210] run_test.sh (17428): dropped kernel caches: 3
[241745.946315] run_test.sh (17427): dropped kernel caches: 3
[241762.550488] start.sh (23541): dropped kernel caches: 3
[242867.331518] run_test.sh (23570): dropped kernel caches: 3
[242867.345164] run_test.sh (23571): dropped kernel caches: 3
[242880.422146] start.sh (29831): dropped kernel caches: 3
[244318.457350] run_test.sh (29860): dropped kernel caches: 3
[244334.586792] run_test.sh (29861): dropped kernel caches: 3
[244346.021987] start.sh (8058): dropped kernel caches: 3
[245765.195062] run_test.sh (8087): dropped kernel caches: 3
[245767.559568] run_test.sh (8088): dropped kernel caches: 3
[245779.085812] start.sh (18140): dropped kernel caches: 3
[247144.679530] run_test.sh (18169): dropped kernel caches: 3
[247144.681493] run_test.sh (18170): dropped kernel caches: 3
[247157.993918] start.sh (27842): dropped kernel caches: 3
[248269.880170] run_test.sh (27876): dropped kernel caches: 3
[248270.047754] run_test.sh (27877): dropped kernel caches: 3
[248287.954475] start.sh (2056): dropped kernel caches: 3
[249392.367317] run_test.sh (2096): dropped kernel caches: 3
[249392.380440] run_test.sh (2095): dropped kernel caches: 3
[249404.972298] start.sh (8198): dropped kernel caches: 3
[250510.147648] run_test.sh (8228): dropped kernel caches: 3
[250524.049700] run_test.sh (8227): dropped kernel caches: 3
[250536.954453] start.sh (14904): dropped kernel caches: 3
[251993.289791] run_test.sh (14934): dropped kernel caches: 3
[251995.378541] run_test.sh (14933): dropped kernel caches: 3
[252011.633802] start.sh (24041): dropped kernel caches: 3
[253443.586414] run_test.sh (24070): dropped kernel caches: 3
[253525.928282] run_test.sh (24071): dropped kernel caches: 3
[253537.505873] start.sh (2631): dropped kernel caches: 3
[254882.490253] run_test.sh (2660): dropped kernel caches: 3
[254889.394961] run_test.sh (2661): dropped kernel caches: 3
[254900.785796] start.sh (12097): dropped kernel caches: 3
[256011.232547] run_test.sh (12126): dropped kernel caches: 3
[256039.701405] run_test.sh (12127): dropped kernel caches: 3
[256052.738082] start.sh (18914): dropped kernel caches: 3
[257140.270096] run_test.sh (18949): dropped kernel caches: 3
[257144.858550] run_test.sh (18948): dropped kernel caches: 3
[257175.726057] start.sh (24950): dropped kernel caches: 3
[258275.388393] run_test.sh (25059): dropped kernel caches: 3
[258275.557538] run_test.sh (25060): dropped kernel caches: 3
[258294.913890] start.sh (31043): dropped kernel caches: 3
[259786.493527] run_test.sh (31072): dropped kernel caches: 3
[259786.556141] run_test.sh (31073): dropped kernel caches: 3
[259803.877504] start.sh (9352): dropped kernel caches: 3
[261271.912278] run_test.sh (9381): dropped kernel caches: 3
[261271.912725] run_test.sh (9382): dropped kernel caches: 3
[261283.591394] start.sh (19449): dropped kernel caches: 3
[262725.014498] run_test.sh (19479): dropped kernel caches: 3
[262744.240772] run_test.sh (19478): dropped kernel caches: 3
[262757.197783] start.sh (29952): dropped kernel caches: 3
[263845.539051] run_test.sh (29981): dropped kernel caches: 3
[263854.812560] run_test.sh (29982): dropped kernel caches: 3
[263870.064340] start.sh (3916): dropped kernel caches: 3
[264983.735942] run_test.sh (3955): dropped kernel caches: 3
[264983.754280] run_test.sh (3956): dropped kernel caches: 3
[264997.446066] start.sh (10314): dropped kernel caches: 3
[266128.030868] run_test.sh (10344): dropped kernel caches: 3
[266128.030984] run_test.sh (10343): dropped kernel caches: 3
[266141.654460] start.sh (16946): dropped kernel caches: 3
[267525.910608] run_test.sh (16976): dropped kernel caches: 3
[267525.910661] run_test.sh (16975): dropped kernel caches: 3
[267537.620508] start.sh (26478): dropped kernel caches: 3
[268993.626239] run_test.sh (26507): dropped kernel caches: 3
[269009.600827] run_test.sh (26508): dropped kernel caches: 3
[269022.765919] start.sh (4954): dropped kernel caches: 3
[270475.554209] run_test.sh (4987): dropped kernel caches: 3
[270513.043821] run_test.sh (4988): dropped kernel caches: 3
[270524.838034] start.sh (15535): dropped kernel caches: 3
[271628.804566] run_test.sh (15565): dropped kernel caches: 3
[271633.287991] run_test.sh (15564): dropped kernel caches: 3
[271645.430994] start.sh (21766): dropped kernel caches: 3
[272730.714709] run_test.sh (21795): dropped kernel caches: 3
[272732.917732] run_test.sh (21796): dropped kernel caches: 3
[272748.511733] start.sh (27694): dropped kernel caches: 3
[273824.233368] run_test.sh (27724): dropped kernel caches: 3
[273829.293584] run_test.sh (27723): dropped kernel caches: 3
[273840.965968] start.sh (784): dropped kernel caches: 3
[275257.555658] run_test.sh (813): dropped kernel caches: 3
[275272.602783] run_test.sh (814): dropped kernel caches: 3
[275284.264312] start.sh (11025): dropped kernel caches: 3
[276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
[276962.652087] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[276962.652093] xfs-data/sda9   D ffff88001ffb9cc8     0   930      2 0x00000000
[276962.652102]  ffff88003794d198 0000000000000046 ffff8800325f4480 0000000000000000
[276962.652113]  ffff88003794c010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[276962.652121]  0000000000012dc0 ffff88003794dfd8 ffff88003794dfd8 0000000000012dc0
[276962.652128] Call Trace:
[276962.652151]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[276962.652160]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[276962.652171]  [<ffffffff815793a4>] schedule+0x24/0x70
[276962.652178]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[276962.652187]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[276962.652194]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[276962.652200]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[276962.652206]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[276962.652215]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[276962.652224]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[276962.652231]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[276962.652239]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[276962.652246]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[276962.652254]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[276962.652262]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[276962.652274]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[276962.652282]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[276962.652291]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[276962.652298]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[276962.652305]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[276962.652313]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[276962.652323]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[276962.652332]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[276962.652343]  [<ffffffff81151c72>] kmem_getpages+0x62/0x1d0
[276962.652351]  [<ffffffff81153869>] fallback_alloc+0x189/0x250
[276962.652359]  [<ffffffff8115360d>] ____cache_alloc_node+0x8d/0x160
[276962.652367]  [<ffffffff81153e51>] __kmalloc+0x281/0x290
[276962.652490]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[276962.652540]  [<ffffffffa02c6e97>] kmem_alloc+0x77/0xe0 [xfs]
[276962.652588]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[276962.652653]  [<ffffffffa030a334>] xfs_inode_item_format_extents+0x54/0x100 [xfs]
[276962.652714]  [<ffffffffa030a63a>] xfs_inode_item_format+0x25a/0x4f0 [xfs]
[276962.652774]  [<ffffffffa03081a0>] xlog_cil_prepare_log_vecs+0xa0/0x170 [xfs]
[276962.652834]  [<ffffffffa03082a8>] xfs_log_commit_cil+0x38/0x1c0 [xfs]
[276962.652894]  [<ffffffffa0303304>] xfs_trans_commit+0x74/0x260 [xfs]
[276962.652935]  [<ffffffffa02ac70b>] xfs_setfilesize+0x12b/0x130 [xfs]
[276962.652947]  [<ffffffff81076bd0>] ? __migrate_task+0x150/0x150
[276962.652988]  [<ffffffffa02ac985>] xfs_end_io+0x75/0xc0 [xfs]
[276962.652997]  [<ffffffff8105e934>] process_one_work+0x1b4/0x380
[276962.653004]  [<ffffffff8105f294>] rescuer_thread+0x234/0x320
[276962.653011]  [<ffffffff8105f060>] ? free_pwqs+0x30/0x30
[276962.653017]  [<ffffffff81066a86>] kthread+0xc6/0xd0
[276962.653025]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[276962.653034]  [<ffffffff8158303c>] ret_from_fork+0x7c/0xb0
[276962.653041]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[276962.653097] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
[276962.653100] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[276962.653104] kworker/2:2     D ffff88001ffc6448     0 17823      2 0x00000000
[276962.653111]  ffff88000b6251a8 0000000000000046 ffff8800325f4480 0000000000000000
[276962.653119]  ffff88000b624010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[276962.653126]  0000000000012dc0 ffff88000b625fd8 ffff88000b625fd8 0000000000012dc0
[276962.653134] Call Trace:
[276962.653143]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[276962.653151]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[276962.653159]  [<ffffffff815793a4>] schedule+0x24/0x70
[276962.653165]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[276962.653171]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[276962.653178]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[276962.653184]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[276962.653190]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[276962.653197]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[276962.653204]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[276962.653211]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[276962.653219]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[276962.653226]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[276962.653234]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[276962.653242]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[276962.653251]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[276962.653259]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[276962.653268]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[276962.653275]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[276962.653282]  [<ffffffff815793a4>] ? schedule+0x24/0x70
[276962.653289]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[276962.653295]  [<ffffffff815793a4>] ? schedule+0x24/0x70
[276962.653303]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[276962.653312]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[276962.653320]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[276962.653329]  [<ffffffff81151c72>] kmem_getpages+0x62/0x1d0
[276962.653337]  [<ffffffff81153869>] fallback_alloc+0x189/0x250
[276962.653345]  [<ffffffff8115360d>] ____cache_alloc_node+0x8d/0x160
[276962.653353]  [<ffffffff81153e51>] __kmalloc+0x281/0x290
[276962.653402]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[276962.653450]  [<ffffffffa02c6e97>] kmem_alloc+0x77/0xe0 [xfs]
[276962.653498]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[276962.653559]  [<ffffffffa030a334>] xfs_inode_item_format_extents+0x54/0x100 [xfs]
[276962.653619]  [<ffffffffa030a63a>] xfs_inode_item_format+0x25a/0x4f0 [xfs]
[276962.653679]  [<ffffffffa03081a0>] xlog_cil_prepare_log_vecs+0xa0/0x170 [xfs]
[276962.653739]  [<ffffffffa03082a8>] xfs_log_commit_cil+0x38/0x1c0 [xfs]
[276962.653798]  [<ffffffffa0303304>] xfs_trans_commit+0x74/0x260 [xfs]
[276962.653839]  [<ffffffffa02ac70b>] xfs_setfilesize+0x12b/0x130 [xfs]
[276962.653880]  [<ffffffffa02ac985>] xfs_end_io+0x75/0xc0 [xfs]
[276962.653888]  [<ffffffff8105e934>] process_one_work+0x1b4/0x380
[276962.653896]  [<ffffffff81061be2>] worker_thread+0x132/0x400
[276962.653904]  [<ffffffff81061ab0>] ? manage_workers+0xf0/0xf0
[276962.653910]  [<ffffffff81066a86>] kthread+0xc6/0xd0
[276962.653917]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[276962.653924]  [<ffffffff8158303c>] ret_from_fork+0x7c/0xb0
[276962.653931]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[276962.653940] INFO: task ld:14442 blocked for more than 480 seconds.
[276962.653943] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[276962.653947] ld              D ffff88001ffca3a8     0 14442  14432 0x00000000
[276962.653953]  ffff88000b66f238 0000000000000082 ffff8800325f4480 0000000000000000
[276962.653961]  ffff88000b66e010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[276962.653968]  0000000000012dc0 ffff88000b66ffd8 ffff88000b66ffd8 0000000000012dc0
[276962.653975] Call Trace:
[276962.653984]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[276962.653992]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[276962.653999]  [<ffffffff815793a4>] schedule+0x24/0x70
[276962.654006]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[276962.654012]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[276962.654019]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[276962.654025]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[276962.654031]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[276962.654038]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[276962.654045]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[276962.654052]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[276962.654060]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[276962.654067]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[276962.654074]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[276962.654083]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[276962.654092]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[276962.654100]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[276962.654109]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[276962.654116]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[276962.654123]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[276962.654131]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[276962.654140]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[276962.654148]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[276962.654157]  [<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[276962.654168]  [<ffffffff8113fe93>] read_swap_cache_async+0x113/0x160
[276962.654176]  [<ffffffff8113ffe1>] swapin_readahead+0x101/0x190
[276962.654187]  [<ffffffff8112e93f>] do_swap_page+0xef/0x5e0
[276962.654230]  [<ffffffffa02b378b>] ? xfs_rw_iunlock+0x1b/0x40 [xfs]
[276962.654239]  [<ffffffff8112f94d>] handle_pte_fault+0x1bd/0x240
[276962.654247]  [<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[276962.654257]  [<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[276962.654267]  [<ffffffff8116a8a8>] ? fsnotify_access+0x68/0x80
[276962.654274]  [<ffffffff8116b0b8>] ? vfs_read+0xd8/0x130
[276962.654283]  [<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[276962.654290]  [<ffffffff8157b348>] page_fault+0x28/0x30
[276962.654297] INFO: task ld:14962 blocked for more than 480 seconds.
[276962.654300] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[276962.654303] ld              D ffff88001ffc7a08     0 14962  14961 0x00000000
[276962.654309]  ffff880008bb9388 0000000000000086 ffff88001c157800 ffff8800325f4480
[276962.654317]  ffff880008bb8010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[276962.654323]  0000000000012dc0 ffff880008bb9fd8 ffff880008bb9fd8 0000000000012dc0
[276962.654331] Call Trace:
[276962.654340]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[276962.654348]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[276962.654355]  [<ffffffff815793a4>] schedule+0x24/0x70
[276962.654361]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[276962.654368]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[276962.654374]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[276962.654380]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[276962.654387]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[276962.654393]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[276962.654401]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[276962.654409]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[276962.654417]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[276962.654425]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[276962.654433]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[276962.654442]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[276962.654450]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[276962.654459]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[276962.654466]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[276962.654476]  [<ffffffff81009510>] ? native_sched_clock+0x20/0xa0
[276962.654483]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[276962.654491]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[276962.654499]  [<ffffffff811054ca>] ? zone_watermark_ok+0x1a/0x20
[276962.654507]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[276962.654516]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[276962.654524]  [<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[276962.654533]  [<ffffffff81129ebb>] do_anonymous_page+0x16b/0x350
[276962.654541]  [<ffffffff8112f9c5>] handle_pte_fault+0x235/0x240
[276962.654549]  [<ffffffff8115e78d>] ? do_huge_pmd_anonymous_page+0xad/0x2e0
[276962.654557]  [<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[276962.654565]  [<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[276962.654574]  [<ffffffff8111e9c9>] ? vm_mmap_pgoff+0xa9/0xd0
[276962.654581]  [<ffffffff811327a6>] ? remove_vma+0x56/0x60
[276962.654589]  [<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[276962.654596]  [<ffffffff8157b348>] page_fault+0x28/0x30
[277442.652123] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
[277442.652135] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[277442.652141] xfs-data/sda9   D ffff88001ffb9cc8     0   930      2 0x00000000
[277442.652151]  ffff88003794d198 0000000000000046 ffff8800325f4480 0000000000000000
[277442.652162]  ffff88003794c010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[277442.652170]  0000000000012dc0 ffff88003794dfd8 ffff88003794dfd8 0000000000012dc0
[277442.652177] Call Trace:
[277442.652201]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[277442.652210]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[277442.652221]  [<ffffffff815793a4>] schedule+0x24/0x70
[277442.652228]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[277442.652237]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[277442.652244]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[277442.652250]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[277442.652256]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[277442.652265]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[277442.652274]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[277442.652281]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[277442.652289]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[277442.652296]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[277442.652305]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[277442.652313]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[277442.652324]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[277442.652333]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[277442.652341]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[277442.652349]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[277442.652356]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[277442.652363]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[277442.652374]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[277442.652382]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[277442.652394]  [<ffffffff81151c72>] kmem_getpages+0x62/0x1d0
[277442.652402]  [<ffffffff81153869>] fallback_alloc+0x189/0x250
[277442.652410]  [<ffffffff8115360d>] ____cache_alloc_node+0x8d/0x160
[277442.652418]  [<ffffffff81153e51>] __kmalloc+0x281/0x290
[277442.652543]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[277442.652593]  [<ffffffffa02c6e97>] kmem_alloc+0x77/0xe0 [xfs]
[277442.652641]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[277442.652706]  [<ffffffffa030a334>] xfs_inode_item_format_extents+0x54/0x100 [xfs]
[277442.652767]  [<ffffffffa030a63a>] xfs_inode_item_format+0x25a/0x4f0 [xfs]
[277442.652827]  [<ffffffffa03081a0>] xlog_cil_prepare_log_vecs+0xa0/0x170 [xfs]
[277442.652887]  [<ffffffffa03082a8>] xfs_log_commit_cil+0x38/0x1c0 [xfs]
[277442.652947]  [<ffffffffa0303304>] xfs_trans_commit+0x74/0x260 [xfs]
[277442.652988]  [<ffffffffa02ac70b>] xfs_setfilesize+0x12b/0x130 [xfs]
[277442.653000]  [<ffffffff81076bd0>] ? __migrate_task+0x150/0x150
[277442.653041]  [<ffffffffa02ac985>] xfs_end_io+0x75/0xc0 [xfs]
[277442.653050]  [<ffffffff8105e934>] process_one_work+0x1b4/0x380
[277442.653058]  [<ffffffff8105f294>] rescuer_thread+0x234/0x320
[277442.653065]  [<ffffffff8105f060>] ? free_pwqs+0x30/0x30
[277442.653071]  [<ffffffff81066a86>] kthread+0xc6/0xd0
[277442.653079]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[277442.653088]  [<ffffffff8158303c>] ret_from_fork+0x7c/0xb0
[277442.653095]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[277442.653153] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
[277442.653157] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[277442.653160] kworker/2:2     D ffff88001ffc6448     0 17823      2 0x00000000
[277442.653167]  ffff88000b6251a8 0000000000000046 ffff8800325f4480 0000000000000000
[277442.653175]  ffff88000b624010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[277442.653182]  0000000000012dc0 ffff88000b625fd8 ffff88000b625fd8 0000000000012dc0
[277442.653190] Call Trace:
[277442.653199]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[277442.653207]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[277442.653215]  [<ffffffff815793a4>] schedule+0x24/0x70
[277442.653222]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[277442.653228]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[277442.653234]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[277442.653241]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[277442.653247]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[277442.653254]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[277442.653261]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[277442.653268]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[277442.653276]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[277442.653283]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[277442.653291]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[277442.653299]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[277442.653308]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[277442.653316]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[277442.653325]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[277442.653332]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[277442.653339]  [<ffffffff815793a4>] ? schedule+0x24/0x70
[277442.653346]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[277442.653353]  [<ffffffff815793a4>] ? schedule+0x24/0x70
[277442.653360]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[277442.653369]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[277442.653378]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[277442.653386]  [<ffffffff81151c72>] kmem_getpages+0x62/0x1d0
[277442.653394]  [<ffffffff81153869>] fallback_alloc+0x189/0x250
[277442.653403]  [<ffffffff8115360d>] ____cache_alloc_node+0x8d/0x160
[277442.653411]  [<ffffffff81153e51>] __kmalloc+0x281/0x290
[277442.653459]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[277442.653507]  [<ffffffffa02c6e97>] kmem_alloc+0x77/0xe0 [xfs]
[277442.653555]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[277442.653616]  [<ffffffffa030a334>] xfs_inode_item_format_extents+0x54/0x100 [xfs]
[277442.653676]  [<ffffffffa030a63a>] xfs_inode_item_format+0x25a/0x4f0 [xfs]
[277442.653736]  [<ffffffffa03081a0>] xlog_cil_prepare_log_vecs+0xa0/0x170 [xfs]
[277442.653796]  [<ffffffffa03082a8>] xfs_log_commit_cil+0x38/0x1c0 [xfs]
[277442.653855]  [<ffffffffa0303304>] xfs_trans_commit+0x74/0x260 [xfs]
[277442.653896]  [<ffffffffa02ac70b>] xfs_setfilesize+0x12b/0x130 [xfs]
[277442.653937]  [<ffffffffa02ac985>] xfs_end_io+0x75/0xc0 [xfs]
[277442.653945]  [<ffffffff8105e934>] process_one_work+0x1b4/0x380
[277442.653953]  [<ffffffff81061be2>] worker_thread+0x132/0x400
[277442.653961]  [<ffffffff81061ab0>] ? manage_workers+0xf0/0xf0
[277442.653967]  [<ffffffff81066a86>] kthread+0xc6/0xd0
[277442.653974]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[277442.653981]  [<ffffffff8158303c>] ret_from_fork+0x7c/0xb0
[277442.653988]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[277442.653997] INFO: task ld:14442 blocked for more than 480 seconds.
[277442.654000] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[277442.654003] ld              D ffff88001ffca3a8     0 14442  14432 0x00000000
[277442.654009]  ffff88000b66f238 0000000000000082 ffff8800325f4480 0000000000000000
[277442.654017]  ffff88000b66e010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[277442.654024]  0000000000012dc0 ffff88000b66ffd8 ffff88000b66ffd8 0000000000012dc0
[277442.654031] Call Trace:
[277442.654041]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[277442.654048]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[277442.654056]  [<ffffffff815793a4>] schedule+0x24/0x70
[277442.654062]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[277442.654069]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[277442.654075]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[277442.654081]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[277442.654088]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[277442.654094]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[277442.654101]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[277442.654108]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[277442.654116]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[277442.654123]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[277442.654131]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[277442.654139]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[277442.654148]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[277442.654156]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[277442.654165]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[277442.654172]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[277442.654180]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[277442.654187]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[277442.654196]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[277442.654205]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[277442.654214]  [<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[277442.654224]  [<ffffffff8113fe93>] read_swap_cache_async+0x113/0x160
[277442.654232]  [<ffffffff8113ffe1>] swapin_readahead+0x101/0x190
[277442.654243]  [<ffffffff8112e93f>] do_swap_page+0xef/0x5e0
[277442.654287]  [<ffffffffa02b378b>] ? xfs_rw_iunlock+0x1b/0x40 [xfs]
[277442.654295]  [<ffffffff8112f94d>] handle_pte_fault+0x1bd/0x240
[277442.654303]  [<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[277442.654313]  [<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[277442.654323]  [<ffffffff8116a8a8>] ? fsnotify_access+0x68/0x80
[277442.654330]  [<ffffffff8116b0b8>] ? vfs_read+0xd8/0x130
[277442.654338]  [<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[277442.654346]  [<ffffffff8157b348>] page_fault+0x28/0x30
[277442.654353] INFO: task ld:14962 blocked for more than 480 seconds.
[277442.654356] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[277442.654359] ld              D ffff88001ffc7a08     0 14962  14961 0x00000000
[277442.654365]  ffff880008bb9388 0000000000000086 ffff88001c157800 ffff8800325f4480
[277442.654373]  ffff880008bb8010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[277442.654379]  0000000000012dc0 ffff880008bb9fd8 ffff880008bb9fd8 0000000000012dc0
[277442.654387] Call Trace:
[277442.654396]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[277442.654404]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[277442.654411]  [<ffffffff815793a4>] schedule+0x24/0x70
[277442.654418]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[277442.654424]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[277442.654430]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[277442.654437]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[277442.654443]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[277442.654450]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[277442.654457]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[277442.654465]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[277442.654473]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[277442.654481]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[277442.654489]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[277442.654498]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[277442.654506]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[277442.654515]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[277442.654522]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[277442.654532]  [<ffffffff81009510>] ? native_sched_clock+0x20/0xa0
[277442.654539]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[277442.654546]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[277442.654555]  [<ffffffff811054ca>] ? zone_watermark_ok+0x1a/0x20
[277442.654563]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[277442.654572]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[277442.654580]  [<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[277442.654589]  [<ffffffff81129ebb>] do_anonymous_page+0x16b/0x350
[277442.654597]  [<ffffffff8112f9c5>] handle_pte_fault+0x235/0x240
[277442.654605]  [<ffffffff8115e78d>] ? do_huge_pmd_anonymous_page+0xad/0x2e0
[277442.654613]  [<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[277442.654621]  [<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[277442.654631]  [<ffffffff8111e9c9>] ? vm_mmap_pgoff+0xa9/0xd0
[277442.654637]  [<ffffffff811327a6>] ? remove_vma+0x56/0x60
[277442.654645]  [<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[277442.654652]  [<ffffffff8157b348>] page_fault+0x28/0x30
[277922.652069] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
[277922.652081] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[277922.652087] xfs-data/sda9   D ffff88001ffb9cc8     0   930      2 0x00000000
[277922.652097]  ffff88003794d198 0000000000000046 ffff8800325f4480 0000000000000000
[277922.652107]  ffff88003794c010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[277922.652115]  0000000000012dc0 ffff88003794dfd8 ffff88003794dfd8 0000000000012dc0
[277922.652122] Call Trace:
[277922.652145]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[277922.652154]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[277922.652165]  [<ffffffff815793a4>] schedule+0x24/0x70
[277922.652172]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[277922.652180]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[277922.652188]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[277922.652194]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[277922.652200]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[277922.652209]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[277922.652218]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[277922.652225]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[277922.652233]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[277922.652240]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[277922.652248]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[277922.652257]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[277922.652268]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[277922.652276]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[277922.652285]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[277922.652292]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[277922.652300]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[277922.652307]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[277922.652317]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[277922.652326]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[277922.652337]  [<ffffffff81151c72>] kmem_getpages+0x62/0x1d0
[277922.652345]  [<ffffffff81153869>] fallback_alloc+0x189/0x250
[277922.652354]  [<ffffffff8115360d>] ____cache_alloc_node+0x8d/0x160
[277922.652361]  [<ffffffff81153e51>] __kmalloc+0x281/0x290
[277922.652482]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[277922.652532]  [<ffffffffa02c6e97>] kmem_alloc+0x77/0xe0 [xfs]
[277922.652580]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[277922.652645]  [<ffffffffa030a334>] xfs_inode_item_format_extents+0x54/0x100 [xfs]
[277922.652706]  [<ffffffffa030a63a>] xfs_inode_item_format+0x25a/0x4f0 [xfs]
[277922.652766]  [<ffffffffa03081a0>] xlog_cil_prepare_log_vecs+0xa0/0x170 [xfs]
[277922.652826]  [<ffffffffa03082a8>] xfs_log_commit_cil+0x38/0x1c0 [xfs]
[277922.652885]  [<ffffffffa0303304>] xfs_trans_commit+0x74/0x260 [xfs]
[277922.652927]  [<ffffffffa02ac70b>] xfs_setfilesize+0x12b/0x130 [xfs]
[277922.652938]  [<ffffffff81076bd0>] ? __migrate_task+0x150/0x150
[277922.652979]  [<ffffffffa02ac985>] xfs_end_io+0x75/0xc0 [xfs]
[277922.652989]  [<ffffffff8105e934>] process_one_work+0x1b4/0x380
[277922.652996]  [<ffffffff8105f294>] rescuer_thread+0x234/0x320
[277922.653003]  [<ffffffff8105f060>] ? free_pwqs+0x30/0x30
[277922.653010]  [<ffffffff81066a86>] kthread+0xc6/0xd0
[277922.653017]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[277922.653027]  [<ffffffff8158303c>] ret_from_fork+0x7c/0xb0
[277922.653033]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[277922.653089] INFO: task kworker/2:2:17823 blocked for more than 480 seconds.
[277922.653092] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[277922.653096] kworker/2:2     D ffff88001ffc6448     0 17823      2 0x00000000
[277922.653102]  ffff88000b6251a8 0000000000000046 ffff8800325f4480 0000000000000000
[277922.653111]  ffff88000b624010 0000000000012dc0 0000000000012dc0 0000000000012dc0
[277922.653118]  0000000000012dc0 ffff88000b625fd8 ffff88000b625fd8 0000000000012dc0
[277922.653125] Call Trace:
[277922.653135]  [<ffffffff812a2c22>] ? __blk_run_queue+0x32/0x40
[277922.653142]  [<ffffffff812a31f8>] ? queue_unplugged+0x78/0xb0
[277922.653150]  [<ffffffff815793a4>] schedule+0x24/0x70
[277922.653156]  [<ffffffff8157948c>] io_schedule+0x9c/0xf0
[277922.653163]  [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[277922.653169]  [<ffffffff815778ca>] __wait_on_bit+0x5a/0x90
[277922.653175]  [<ffffffff811011a0>] ? __lock_page+0x70/0x70
[277922.653181]  [<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[277922.653188]  [<ffffffff81067190>] ? autoremove_wake_function+0x40/0x40
[277922.653195]  [<ffffffff81112ee1>] ? page_evictable+0x11/0x50
[277922.653202]  [<ffffffff81114e43>] shrink_page_list+0x503/0x790
[277922.653210]  [<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[277922.653217]  [<ffffffff81115d5f>] ? shrink_active_list+0x29f/0x340
[277922.653225]  [<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[277922.653233]  [<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[277922.653242]  [<ffffffff81160c28>] ? mem_cgroup_reclaimable+0x108/0x150
[277922.653250]  [<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[277922.653258]  [<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[277922.653266]  [<ffffffff81116418>] shrink_zones+0x108/0x220
[277922.653272]  [<ffffffff815793a4>] ? schedule+0x24/0x70
[277922.653280]  [<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[277922.653286]  [<ffffffff815793a4>] ? schedule+0x24/0x70
[277922.653293]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[277922.653302]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[277922.653311]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[277922.653320]  [<ffffffff81151c72>] kmem_getpages+0x62/0x1d0
[277922.653328]  [<ffffffff81153869>] fallback_alloc+0x189/0x250
[277922.653336]  [<ffffffff8115360d>] ____cache_alloc_node+0x8d/0x160
[277922.653344]  [<ffffffff81153e51>] __kmalloc+0x281/0x290
[277922.653392]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[277922.653441]  [<ffffffffa02c6e97>] kmem_alloc+0x77/0xe0 [xfs]
[277922.653489]  [<ffffffffa02c6e97>] ? kmem_alloc+0x77/0xe0 [xfs]
[277922.653549]  [<ffffffffa030a334>] xfs_inode_item_format_extents+0x54/0x100 [xfs]
[277922.653610]  [<ffffffffa030a63a>] xfs_inode_item_format+0x25a/0x4f0 [xfs]
[277922.653669]  [<ffffffffa03081a0>] xlog_cil_prepare_log_vecs+0xa0/0x170 [xfs]
[277922.653729]  [<ffffffffa03082a8>] xfs_log_commit_cil+0x38/0x1c0 [xfs]
[277922.653788]  [<ffffffffa0303304>] xfs_trans_commit+0x74/0x260 [xfs]
[277922.653829]  [<ffffffffa02ac70b>] xfs_setfilesize+0x12b/0x130 [xfs]
[277922.653870]  [<ffffffffa02ac985>] xfs_end_io+0x75/0xc0 [xfs]
[277922.653878]  [<ffffffff8105e934>] process_one_work+0x1b4/0x380
[277922.653886]  [<ffffffff81061be2>] worker_thread+0x132/0x400
[277922.653894]  [<ffffffff81061ab0>] ? manage_workers+0xf0/0xf0
[277922.653900]  [<ffffffff81066a86>] kthread+0xc6/0xd0
[277922.653907]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70
[277922.653914]  [<ffffffff8158303c>] ret_from_fork+0x7c/0xb0
[277922.653921]  [<ffffffff810669c0>] ? kthread_freezable_should_stop+0x70/0x70

--3uo+9/B/ebqu+fSQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
