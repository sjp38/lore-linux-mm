Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id BE8176B0027
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 11:15:41 -0400 (EDT)
Date: Wed, 3 Apr 2013 16:15:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130403151535.GA4908@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130402151436.GC31577@thunk.org>
 <20130403101925.GA7341@suse.de>
 <20130403120529.GA7741@thunk.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
In-Reply-To: <20130403120529.GA7741@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Wed, Apr 03, 2013 at 08:05:30AM -0400, Theodore Ts'o wrote:
> On Wed, Apr 03, 2013 at 11:19:25AM +0100, Mel Gorman wrote:
> > 
> > I'm running with -rc5 now. I have not noticed much interactivity problems
> > as such but the stall detection script reported that mutt stalled for
> > 20 seconds opening an inbox and imapd blocked for 59 seconds doing path
> > lookups, imaps blocked again for 12 seconds doing an atime update, an RSS
> > reader blocked for 3.5 seconds writing a file. etc.
> 
> If imaps blocked for 12 seconds during an atime update, combined with
> everything else, at a guess it got caught by something holding up a
> journal commit. 

It's a possibility.

I apologise but I forgot that mail is stored on a crypted partition on
this machine. It's formatted ext4 but dmcrypt could be making this problem
worse if it's stalling ext4 waiting to encrypt/decrypt data due to either
a scheduler or workqueue change.

> Could you try enabling the jbd2_run_stats tracepoint
> and grabbing the trace log?  This will give you statistics on how long
> (in milliseconds) each of the various phases of a jbd2 commit is
> taking, i.e.:
> 
>     jbd2/sdb1-8-327   [002] .... 39681.874661: jbd2_run_stats: dev 8,17 tid 7163786 wait 0 request_delay 0 running 3530 locked 0 flushing 0 logging 0 handle_count 75 blocks 8 blocks_logged 9
>      jbd2/sdb1-8-327   [003] .... 39682.514153: jbd2_run_stats: dev 8,17 tid 7163787 wait 0 request_delay 0 running 640 locked 0 flushing 0 logging 0 handle_count 39 blocks 12 blocks_logged 13
>      jbd2/sdb1-8-327   [000] .... 39687.665609: jbd2_run_stats: dev 8,17 tid 7163788 wait 0 request_delay 0 running 5150 locked 0 flushing 0 logging 0 handle_count 60 blocks 13 blocks_logged 14
>      jbd2/sdb1-8-327   [000] .... 39693.200453: jbd2_run_stats: dev 8,17 tid 7163789 wait 0 request_delay 0 running 4840 locked 0 flushing 0 logging 0 handle_count 53 blocks 10 blocks_logged 11
>      jbd2/sdb1-8-327   [001] .... 39695.061657: jbd2_run_stats: dev 8,17 tid 7163790 wait 0 request_delay 0 running 1860 locked 0 flushing 0 logging 0 handle_count 124 blocks 19 blocks_logged 20
> 

Attached as well as the dstate summary that was recorded at the same
time. It's not quite as compelling but I'll keep the monitor running and
see if something falls out. I didn't find anything useful in the existing
mmtests tests that could be used to bisect this but not many of them are
focused on IO.

> In the above sample each journal commit is running for no more than 5
> seconds or so (since that's the default jbd2 commit timeout; if a
> transaction is running for less than 5 seconds, then either we ran out
> of room in the journal, and the blocks_logged number will be high, or
> a commit was forced by something such as an fsync call).  
> 

I didn't see anything majorly compelling in the jbd tracepoints but I'm
not 100% sure I'm looking for the right thing either. I also recorded
/proc/latency_stat and there were some bad sync latencies from the file
as you can see here

3 4481 1586 jbd2_log_wait_commit ext4_sync_file vfs_fsync sys_msync system_call_fastpath
3 11325 4373 sleep_on_page wait_on_page_bit kretprobe_trampoline filemap_write_and_wait_range ext4_sync_file vfs_fsync sys_msync system_call_fastpath
85 1130707 14904 jbd2_journal_stop jbd2_journal_force_commit ext4_force_commit ext4_sync_file do_fsync sys_fsync system_call_fastpath
1 2161073 2161073 start_this_handle jbd2__journal_start.part.8 jbd2__journal_start __ext4_journal_start_sb ext4_da_writepages do_writepages __filemap_fdatawrite_range filemap_write_and_wait_range ext4_sync_file do_fsync sys_fsync system_call_fastpath
118 7798435 596184 jbd2_log_wait_commit jbd2_journal_stop jbd2_journal_force_commit ext4_force_commit ext4_sync_file do_fsync sys_fsync system_call_fastpath
599 15496449 3405822 sleep_on_page wait_on_page_bit kretprobe_trampoline filemap_write_and_wait_range ext4_sync_file do_fsync sys_fsync system_call_fastpath
405 28572881 2619592 jbd2_log_wait_commit ext4_sync_file do_fsync sys_fsync system_call_fastpath


> If an atime update is getting blocked by 12 seconds, then it would be
> interesting to see if a journal commit is running for significantly
> longer than 5 seconds, or if one of the other commit phases is taking
> significant amounts of time.  (On the example above they are all
> taking no time, since I ran this on a relatively uncontended system;
> only a single git operation taking place.)
> 
> Something else that might be worth trying is grabbing a lock_stat
> report and see if something is sitting on an ext4 or jbd2 mutex for a
> long time.
> 

Ok, if nothing useful falls out in this session I'll enable lock
debugging. latency_stat on its own would not be enough to conclude that
a problem was related to lock contention.

> Finally, as I mentioned I tried some rather simplistic tests and I
> didn't notice any difference between a 3.2 kernel and a 3.8/3.9-rc5
> kernel.  Assuming you can get a version of systemtap that
> simultaneously works on 3.2 and 3.9-rc5 :-P, and chance you could do a
> quick experiment and see if you're seeing a difference on your setup?
> 

stap-fix.sh should be able to kick systemtap sufficiently hard for
either 3.2 or 3.9-rc5 to keep it working. I'll keep digging when I can.

-- 
Mel Gorman
SUSE Labs

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename="dstate-summary.txt"

Overall stalled time: 242940 ms

Time stalled in this event:    59077 ms
Event count:                       4
mutt                 sleep_on_buffer        1980 ms
latency-output       sleep_on_buffer       20272 ms
latency-output       sleep_on_buffer       19789 ms
tclsh                sleep_on_buffer       17036 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f3198>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f3209>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f57d1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119ac3e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b9b9>] update_time+0x79/0xc0
[<ffffffff8118ba98>] file_update_time+0x98/0x100
[<ffffffff81110ffc>] __generic_file_aio_write+0x17c/0x3b0
[<ffffffff811112aa>] generic_file_aio_write+0x7a/0xf0
[<ffffffff811ea853>] ext4_file_write+0x83/0xd0
[<ffffffff81172b23>] do_sync_write+0xa3/0xe0
[<ffffffff811731ae>] vfs_write+0xae/0x180
[<ffffffff8117361d>] sys_write+0x4d/0x90
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    50129 ms
Event count:                       1
offlineimap          sleep_on_buffer       50129 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3996>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9b45>] ext4_find_entry+0x325/0x4f0
[<ffffffff811f9d39>] ext4_lookup.part.31+0x29/0x140
[<ffffffff811f9e75>] ext4_lookup+0x25/0x30
[<ffffffff8117c828>] lookup_real+0x18/0x50
[<ffffffff8117cc63>] __lookup_hash+0x33/0x40
[<ffffffff81585a23>] lookup_slow+0x40/0xa4
[<ffffffff8117f1b2>] path_lookupat+0x222/0x780
[<ffffffff8117f73f>] filename_lookup+0x2f/0xc0
[<ffffffff81182274>] user_path_at_empty+0x54/0xa0
[<ffffffff811822cc>] user_path_at+0xc/0x10
[<ffffffff81177d39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177dc6>] vfs_stat+0x16/0x20
[<ffffffff81177ee5>] sys_newstat+0x15/0x30
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    29283 ms
Event count:                       5
latency-output       wait_on_page_bit       6482 ms
tclsh                wait_on_page_bit       7756 ms
mutt                 wait_on_page_bit       7702 ms
latency-output       wait_on_page_bit       6017 ms
latency-output       wait_on_page_bit       1326 ms
[<ffffffff8110f180>] wait_on_page_bit+0x70/0x80
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff8110f44a>] generic_perform_write+0xca/0x210
[<ffffffff8110f5e8>] generic_file_buffered_write+0x58/0x90
[<ffffffff81111036>] __generic_file_aio_write+0x1b6/0x3b0
[<ffffffff811112aa>] generic_file_aio_write+0x7a/0xf0
[<ffffffff811ea853>] ext4_file_write+0x83/0xd0
[<ffffffff81172b23>] do_sync_write+0xa3/0xe0
[<ffffffff811731ae>] vfs_write+0xae/0x180
[<ffffffff8117361d>] sys_write+0x4d/0x90
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    21871 ms
Event count:                       2
imapd                sleep_on_buffer       18495 ms
imapd                sleep_on_buffer        3376 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f3198>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f3209>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811f57d1>] ext4_dirty_inode+0x41/0x60
[<ffffffff8119ac3e>] __mark_inode_dirty+0x4e/0x2d0
[<ffffffff8118b9b9>] update_time+0x79/0xc0
[<ffffffff8118bc61>] touch_atime+0x161/0x170
[<ffffffff81110683>] do_generic_file_read.constprop.35+0x363/0x440
[<ffffffff811113f9>] generic_file_aio_read+0xd9/0x220
[<ffffffff81172c03>] do_sync_read+0xa3/0xe0
[<ffffffff8117332b>] vfs_read+0xab/0x170
[<ffffffff8117358d>] sys_read+0x4d/0x90
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:    20849 ms
Event count:                       1
awesome              sleep_on_buffer       20849 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f3198>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811fbd0f>] ext4_orphan_add+0x10f/0x1f0
[<ffffffff811f37b4>] ext4_setattr+0x3d4/0x640
[<ffffffff8118d362>] notify_change+0x1f2/0x3c0
[<ffffffff81171689>] do_truncate+0x59/0xa0
[<ffffffff8117d386>] handle_truncate+0x66/0xa0
[<ffffffff81181506>] do_last+0x626/0x820
[<ffffffff811817b3>] path_openat+0xb3/0x4a0
[<ffffffff8118230d>] do_filp_open+0x3d/0xa0
[<ffffffff811727f9>] do_sys_open+0xf9/0x1e0
[<ffffffff811728fc>] sys_open+0x1c/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     7872 ms
Event count:                       1
dconf-service        sleep_on_buffer        7872 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3996>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9b45>] ext4_find_entry+0x325/0x4f0
[<ffffffff811fbef5>] ext4_rename+0x105/0x980
[<ffffffff8117d6ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180326>] vfs_rename+0xb6/0x240
[<ffffffff81182e96>] sys_renameat+0x386/0x3d0
[<ffffffff81182ef6>] sys_rename+0x16/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     6265 ms
Event count:                       3
dconf-service        wait_on_page_bit       3486 ms
pool                 wait_on_page_bit       1059 ms
Cache I/O            wait_on_page_bit       1720 ms
[<ffffffff8110f180>] wait_on_page_bit+0x70/0x80
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff81110cf0>] filemap_write_and_wait_range+0x60/0x70
[<ffffffff811ea9fa>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1b88>] do_fsync+0x58/0x80
[<ffffffff811a1eeb>] sys_fsync+0xb/0x10
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     5349 ms
Event count:                       1
dconf-service        sleep_on_buffer        5349 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227c94>] ext4_mb_mark_diskspace_used+0x74/0x4d0
[<ffffffff812293af>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121fbb1>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811f0455>] ext4_map_blocks+0x2d5/0x470
[<ffffffff811f451a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f5020>] ext4_da_writepages+0x380/0x620
[<ffffffff8111aceb>] do_writepages+0x1b/0x30
[<ffffffff81110c89>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81110cda>] filemap_write_and_wait_range+0x4a/0x70
[<ffffffff811ea9fa>] ext4_sync_file+0x6a/0x2d0
[<ffffffff811a1b88>] do_fsync+0x58/0x80
[<ffffffff811a1eeb>] sys_fsync+0xb/0x10
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     5168 ms
Event count:                       2
evolution            wait_on_page_bit_killable   1177 ms
firefox              wait_on_page_bit_killable   3991 ms
[<ffffffff81111668>] wait_on_page_bit_killable+0x78/0x80
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff81111b18>] filemap_fault+0x3d8/0x410
[<ffffffff81135b2a>] __do_fault+0x6a/0x530
[<ffffffff8113964e>] handle_pte_fault+0xee/0x200
[<ffffffff8113a8c1>] handle_mm_fault+0x271/0x390
[<ffffffff81598e29>] __do_page_fault+0x169/0x520
[<ffffffff815991e9>] do_page_fault+0x9/0x10
[<ffffffff81595948>] page_fault+0x28/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     4929 ms
Event count:                       1
flush-253:0          sleep_on_buffer        4929 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227c94>] ext4_mb_mark_diskspace_used+0x74/0x4d0
[<ffffffff812293af>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121fbb1>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811f0455>] ext4_map_blocks+0x2d5/0x470
[<ffffffff811f451a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f5020>] ext4_da_writepages+0x380/0x620
[<ffffffff8111aceb>] do_writepages+0x1b/0x30
[<ffffffff81199ce0>] __writeback_single_inode+0x40/0x1b0
[<ffffffff8119c38a>] writeback_sb_inodes+0x19a/0x350
[<ffffffff8119c5d6>] __writeback_inodes_wb+0x96/0xc0
[<ffffffff8119c87b>] wb_writeback+0x27b/0x330
[<ffffffff8119e280>] wb_do_writeback+0x190/0x1d0
[<ffffffff8119e343>] bdi_writeback_thread+0x83/0x280
[<ffffffff8106901b>] kthread+0xbb/0xc0
[<ffffffff8159d57c>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     4840 ms
Event count:                       1
systemd-journal      sleep_on_buffer        4840 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff81227c94>] ext4_mb_mark_diskspace_used+0x74/0x4d0
[<ffffffff812293af>] ext4_mb_new_blocks+0x2af/0x490
[<ffffffff8121fbb1>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811f0455>] ext4_map_blocks+0x2d5/0x470
[<ffffffff8122045f>] ext4_fallocate+0x1cf/0x420
[<ffffffff81171be2>] do_fallocate+0x112/0x190
[<ffffffff81171cb2>] sys_fallocate+0x52/0x90
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     4739 ms
Event count:                       1
pool                 sleep_on_buffer        4739 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811f3198>] ext4_reserve_inode_write+0x78/0xa0
[<ffffffff811f3209>] ext4_mark_inode_dirty+0x49/0x220
[<ffffffff811fb47e>] ext4_link+0x10e/0x1b0
[<ffffffff81182033>] vfs_link+0x113/0x1c0
[<ffffffff81182aa4>] sys_linkat+0x174/0x1c0
[<ffffffff81182b09>] sys_link+0x19/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3358 ms
Event count:                       2
imapd                wait_on_page_bit       1726 ms
imapd                wait_on_page_bit       1632 ms
[<ffffffff8110f180>] wait_on_page_bit+0x70/0x80
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff8111d700>] truncate_inode_pages+0x10/0x20
[<ffffffff811f53cf>] ext4_evict_inode+0x10f/0x4d0
[<ffffffff8118beef>] evict+0xaf/0x1b0
[<ffffffff8118c771>] iput_final+0xd1/0x160
[<ffffffff8118c839>] iput+0x39/0x50
[<ffffffff81187418>] dentry_iput+0x98/0xe0
[<ffffffff81188cb8>] dput+0x128/0x230
[<ffffffff81182e4a>] sys_renameat+0x33a/0x3d0
[<ffffffff81182ef6>] sys_rename+0x16/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     3294 ms
Event count:                       1
imapd                sleep_on_buffer        3294 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3996>] __wait_on_buffer+0x26/0x30
[<ffffffff811f9b45>] ext4_find_entry+0x325/0x4f0
[<ffffffff811fca21>] ext4_unlink+0x41/0x350
[<ffffffff8117dcef>] vfs_unlink.part.31+0x7f/0xe0
[<ffffffff8117fbd7>] vfs_unlink+0x37/0x50
[<ffffffff8117fdff>] do_unlinkat+0x20f/0x260
[<ffffffff81182811>] sys_unlink+0x11/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2608 ms
Event count:                       1
pool                 sleep_on_buffer        2608 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff812298fa>] ext4_free_blocks+0x36a/0xbe0
[<ffffffff8121c3b6>] ext4_remove_blocks+0x256/0x2d0
[<ffffffff8121c635>] ext4_ext_rm_leaf+0x205/0x520
[<ffffffff8121e37c>] ext4_ext_remove_space+0x4dc/0x750
[<ffffffff8122024b>] ext4_ext_truncate+0x19b/0x1e0
[<ffffffff811efb25>] ext4_truncate.part.60+0xd5/0xf0
[<ffffffff811f0c24>] ext4_truncate+0x34/0x90
[<ffffffff811f356d>] ext4_setattr+0x18d/0x640
[<ffffffff8118d362>] notify_change+0x1f2/0x3c0
[<ffffffff81171689>] do_truncate+0x59/0xa0
[<ffffffff8117d386>] handle_truncate+0x66/0xa0
[<ffffffff81181506>] do_last+0x626/0x820
[<ffffffff811817b3>] path_openat+0xb3/0x4a0
[<ffffffff8118230d>] do_filp_open+0x3d/0xa0
[<ffffffff811727f9>] do_sys_open+0xf9/0x1e0
[<ffffffff811728fc>] sys_open+0x1c/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2546 ms
Event count:                       1
offlineimap          sleep_on_buffer        2546 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fa412>] ext4_dx_add_entry+0xc2/0x590
[<ffffffff811faf65>] ext4_add_entry+0x265/0x2d0
[<ffffffff811fc556>] ext4_rename+0x766/0x980
[<ffffffff8117d6ed>] vfs_rename_other+0xcd/0x120
[<ffffffff81180326>] vfs_rename+0xb6/0x240
[<ffffffff81182e96>] sys_renameat+0x386/0x3d0
[<ffffffff81182ef6>] sys_rename+0x16/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2199 ms
Event count:                       1
folder-markup.s      sleep_on_buffer        2199 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a39de>] __lock_buffer+0x2e/0x30
[<ffffffff8123a60f>] do_get_write_access+0x43f/0x4b0
[<ffffffff8123a7cb>] jbd2_journal_get_write_access+0x2b/0x50
[<ffffffff81220f79>] __ext4_journal_get_write_access+0x39/0x80
[<ffffffff811fa412>] ext4_dx_add_entry+0xc2/0x590
[<ffffffff811faf65>] ext4_add_entry+0x265/0x2d0
[<ffffffff811faff6>] ext4_add_nondir+0x26/0x80
[<ffffffff811fb2df>] ext4_create+0xff/0x190
[<ffffffff81180ca5>] vfs_create+0xb5/0x120
[<ffffffff81180e4e>] lookup_open+0x13e/0x1d0
[<ffffffff811811e7>] do_last+0x307/0x820
[<ffffffff811817b3>] path_openat+0xb3/0x4a0
[<ffffffff8118230d>] do_filp_open+0x3d/0xa0
[<ffffffff811727f9>] do_sys_open+0xf9/0x1e0
[<ffffffff811728fc>] sys_open+0x1c/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     2124 ms
Event count:                       2
evolution            sleep_on_buffer        1088 ms
imapd                sleep_on_buffer        1036 ms
[<ffffffff8110efb2>] __lock_page_killable+0x62/0x70
[<ffffffff811105a7>] do_generic_file_read.constprop.35+0x287/0x440
[<ffffffff811113f9>] generic_file_aio_read+0xd9/0x220
[<ffffffff81172c03>] do_sync_read+0xa3/0xe0
[<ffffffff8117332b>] vfs_read+0xab/0x170
[<ffffffff8117358d>] sys_read+0x4d/0x90
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1220 ms
Event count:                       1
jbd2/dm-0-8          sleep_on_buffer        1220 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3996>] __wait_on_buffer+0x26/0x30
[<ffffffff8123c6d1>] jbd2_journal_commit_transaction+0x1241/0x13c0
[<ffffffff81240d33>] kjournald2+0xb3/0x240
[<ffffffff8106901b>] kthread+0xbb/0xc0
[<ffffffff8159d57c>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1088 ms
Event count:                       1
firefox              sleep_on_buffer        1088 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3996>] __wait_on_buffer+0x26/0x30
[<ffffffff811ef5de>] __ext4_get_inode_loc+0x1be/0x3f0
[<ffffffff811f133e>] ext4_iget+0x7e/0x940
[<ffffffff811f9dd6>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9e75>] ext4_lookup+0x25/0x30
[<ffffffff8117c828>] lookup_real+0x18/0x50
[<ffffffff8117cc63>] __lookup_hash+0x33/0x40
[<ffffffff81585a23>] lookup_slow+0x40/0xa4
[<ffffffff8117f1b2>] path_lookupat+0x222/0x780
[<ffffffff8117f73f>] filename_lookup+0x2f/0xc0
[<ffffffff81182274>] user_path_at_empty+0x54/0xa0
[<ffffffff811822cc>] user_path_at+0xc/0x10
[<ffffffff81171d87>] sys_faccessat+0x97/0x220
[<ffffffff81171f23>] sys_access+0x13/0x20
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1076 ms
Event count:                       1
imapd                sleep_on_buffer        1076 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3996>] __wait_on_buffer+0x26/0x30
[<ffffffff811e7cc8>] ext4_wait_block_bitmap+0xb8/0xc0
[<ffffffff81224d6e>] ext4_mb_init_cache+0x1ce/0x730
[<ffffffff8122536e>] ext4_mb_init_group+0x9e/0x100
[<ffffffff812254d7>] ext4_mb_good_group+0x107/0x1a0
[<ffffffff81227973>] ext4_mb_regular_allocator+0x183/0x430
[<ffffffff812294f6>] ext4_mb_new_blocks+0x3f6/0x490
[<ffffffff8121fbb1>] ext4_ext_map_blocks+0x501/0xa00
[<ffffffff811f0455>] ext4_map_blocks+0x2d5/0x470
[<ffffffff811f451a>] mpage_da_map_and_submit+0xba/0x2f0
[<ffffffff811f5020>] ext4_da_writepages+0x380/0x620
[<ffffffff8111aceb>] do_writepages+0x1b/0x30
[<ffffffff81110c89>] __filemap_fdatawrite_range+0x49/0x50
[<ffffffff81111557>] filemap_flush+0x17/0x20
[<ffffffff811f0964>] ext4_alloc_da_blocks+0x44/0xa0
[<ffffffff811ea6b1>] ext4_release_file+0x61/0xd0
[<ffffffff811744a0>] __fput+0xb0/0x240
[<ffffffff81174639>] ____fput+0x9/0x10
[<ffffffff81065cf7>] task_work_run+0x97/0xd0
[<ffffffff81002cbc>] do_notify_resume+0x9c/0xb0
[<ffffffff8159d8ea>] int_signal+0x12/0x17
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1042 ms
Event count:                       1
offlineimap          wait_on_page_bit       1042 ms
[<ffffffff811eab95>] ext4_sync_file+0x205/0x2d0
[<ffffffff811a1b88>] do_fsync+0x58/0x80
[<ffffffff811a1eeb>] sys_fsync+0xb/0x10
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1011 ms
Event count:                       1
firefox              sleep_on_buffer        1011 ms
[<ffffffff81597b84>] kretprobe_trampoline+0x0/0x4c
[<ffffffff811a3996>] __wait_on_buffer+0x26/0x30
[<ffffffff811ef5de>] __ext4_get_inode_loc+0x1be/0x3f0
[<ffffffff811f133e>] ext4_iget+0x7e/0x940
[<ffffffff811f9dd6>] ext4_lookup.part.31+0xc6/0x140
[<ffffffff811f9e75>] ext4_lookup+0x25/0x30
[<ffffffff8117c828>] lookup_real+0x18/0x50
[<ffffffff8117cc63>] __lookup_hash+0x33/0x40
[<ffffffff81585a23>] lookup_slow+0x40/0xa4
[<ffffffff8117f1b2>] path_lookupat+0x222/0x780
[<ffffffff8117f73f>] filename_lookup+0x2f/0xc0
[<ffffffff81182274>] user_path_at_empty+0x54/0xa0
[<ffffffff811822cc>] user_path_at+0xc/0x10
[<ffffffff81177d39>] vfs_fstatat+0x49/0xa0
[<ffffffff81177dc6>] vfs_stat+0x16/0x20
[<ffffffff81177ee5>] sys_newstat+0x15/0x30
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:     1003 ms
Event count:                       1
folder-markup.s      sleep_on_buffer        1003 ms
[<ffffffff8117bb0e>] pipe_read+0x20e/0x340
[<ffffffff81172c03>] do_sync_read+0xa3/0xe0
[<ffffffff8117332b>] vfs_read+0xab/0x170
[<ffffffff8117358d>] sys_read+0x4d/0x90
[<ffffffff8159d62d>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

Time stalled in this event:        0 ms
Event count:                       1


--BOKacYhQ+x31HxR3
Content-Type: application/x-gzip
Content-Disposition: attachment; filename="ftrace-debug-stalls-monitor.gz"
Content-Transfer-Encoding: base64

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
8NDBXJdtMNH4/wEf97a0CRcCAA==

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
