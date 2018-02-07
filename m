Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0DA6B02CA
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 01:54:31 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w19so2720581pgv.4
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 22:54:31 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id x16si542077pgc.817.2018.02.06.22.54.27
        for <linux-mm@kvack.org>;
        Tue, 06 Feb 2018 22:54:28 -0800 (PST)
Date: Wed, 7 Feb 2018 17:55:20 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
Message-ID: <20180207065520.66f6gocvxlnxmkyv@destitution>
References: <1517337604.9211.13.camel@gmail.com>
 <20180131022209.lmhespbauhqtqrxg@destitution>
 <1517888875.7303.3.camel@gmail.com>
 <20180206060840.kj2u6jjmkuk3vie6@destitution>
 <CABXGCsOgcYyj8Xukn7Pi_M2qz2aJ1MJZTaxaSgYno7f_BtZH6w@mail.gmail.com>
 <1517974845.4352.8.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1517974845.4352.8.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail <mikhail.v.gavrilov@gmail.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Feb 07, 2018 at 08:40:45AM +0500, mikhail wrote:
> On Tue, 2018-02-06 at 12:12 +0500, Mikhail Gavrilov wrote:
> > On 6 February 2018 at 11:08, Dave Chinner <david@fromorbit.com> wrote:
> Yet another hung:
> Trace report: https://dumps.sy24.ru/1/trace_report.txt.bz2 (9.4 MB)
> dmesg:
> [  369.374381] INFO: task TaskSchedulerFo:5624 blocked for more than 120 seconds.
> [  369.374391]       Not tainted 4.15.0-rc4-amd-vega+ #9
> [  369.374393] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  369.374395] TaskSchedulerFo D11688  5624   3825 0x00000000
> [  369.374400] Call Trace:
> [  369.374407]  __schedule+0x2dc/0xba0
> [  369.374410]  ? __lock_acquire+0x2d4/0x1350
> [  369.374415]  ? __down+0x84/0x110
> [  369.374417]  schedule+0x33/0x90
> [  369.374419]  schedule_timeout+0x25a/0x5b0
> [  369.374423]  ? mark_held_locks+0x5f/0x90
> [  369.374425]  ? _raw_spin_unlock_irq+0x2c/0x40
> [  369.374426]  ? __down+0x84/0x110
> [  369.374429]  ? trace_hardirqs_on_caller+0xf4/0x190
> [  369.374431]  ? __down+0x84/0x110
> [  369.374433]  __down+0xac/0x110
> [  369.374466]  ? _xfs_buf_find+0x263/0xac0 [xfs]
> [  369.374470]  down+0x41/0x50
> [  369.374472]  ? down+0x41/0x50
> [  369.374490]  xfs_buf_lock+0x4e/0x270 [xfs]
> [  369.374507]  _xfs_buf_find+0x263/0xac0 [xfs]
> [  369.374528]  xfs_buf_get_map+0x29/0x490 [xfs]
> [  369.374545]  xfs_buf_read_map+0x2b/0x300 [xfs]
> [  369.374567]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  369.374585]  xfs_read_agi+0xaa/0x200 [xfs]
> [  369.374605]  xfs_iunlink+0x4d/0x150 [xfs]
> [  369.374609]  ? current_time+0x32/0x70
> [  369.374629]  xfs_droplink+0x54/0x60 [xfs]
> [  369.374654]  xfs_rename+0xb15/0xd10 [xfs]
> [  369.374680]  xfs_vn_rename+0xd3/0x140 [xfs]
> [  369.374687]  vfs_rename+0x476/0x960
> [  369.374695]  SyS_rename+0x33f/0x390
> [  369.374704]  entry_SYSCALL_64_fastpath+0x1f/0x96

Again, this is waiting on a lock....

> [  369.374707] RIP: 0033:0x7f01cf705137
> [  369.374708] RSP: 002b:00007f01873e5608 EFLAGS: 00000202 ORIG_RAX: 0000000000000052
> [  369.374710] RAX: ffffffffffffffda RBX: 0000000000000119 RCX: 00007f01cf705137
> [  369.374711] RDX: 00007f01873e56dc RSI: 00003a5cd3540850 RDI: 00003a5cd7ea8000
> [  369.374713] RBP: 00007f01873e6340 R08: 0000000000000000 R09: 00007f01873e54e0
> [  369.374714] R10: 00007f01873e55f0 R11: 0000000000000202 R12: 00007f01873e6218
> [  369.374715] R13: 00007f01873e6358 R14: 0000000000000000 R15: 00003a5cd8416000
> [  369.374725] INFO: task disk_cache:0:3971 blocked for more than 120 seconds.
> [  369.374727]       Not tainted 4.15.0-rc4-amd-vega+ #9
> [  369.374729] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  369.374731] disk_cache:0    D12432  3971   3903 0x00000000
> [  369.374735] Call Trace:
> [  369.374738]  __schedule+0x2dc/0xba0
> [  369.374743]  ? wait_for_completion+0x10e/0x1a0
> [  369.374745]  schedule+0x33/0x90
> [  369.374747]  schedule_timeout+0x25a/0x5b0
> [  369.374751]  ? mark_held_locks+0x5f/0x90
> [  369.374753]  ? _raw_spin_unlock_irq+0x2c/0x40
> [  369.374755]  ? wait_for_completion+0x10e/0x1a0
> [  369.374757]  ? trace_hardirqs_on_caller+0xf4/0x190
> [  369.374760]  ? wait_for_completion+0x10e/0x1a0
> [  369.374762]  wait_for_completion+0x136/0x1a0
> [  369.374765]  ? wake_up_q+0x80/0x80
> [  369.374782]  ? _xfs_buf_read+0x23/0x30 [xfs]
> [  369.374798]  xfs_buf_submit_wait+0xb2/0x530 [xfs]
> [  369.374814]  _xfs_buf_read+0x23/0x30 [xfs]
> [  369.374828]  xfs_buf_read_map+0x14b/0x300 [xfs]
> [  369.374847]  ? xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  369.374867]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  369.374883]  xfs_da_read_buf+0xca/0x110 [xfs]
> [  369.374901]  xfs_dir3_data_read+0x23/0x60 [xfs]
> [  369.374916]  xfs_dir2_leaf_addname+0x335/0x8b0 [xfs]
> [  369.374936]  xfs_dir_createname+0x17e/0x1d0 [xfs]
> [  369.374956]  xfs_create+0x6ad/0x840 [xfs]
> [  369.374981]  xfs_generic_create+0x1fa/0x2d0 [xfs]
> [  369.375000]  xfs_vn_mknod+0x14/0x20 [xfs]
> [  369.375016]  xfs_vn_create+0x13/0x20 [xfs]

That is held by this process, one it is waiting for IO completion.

There's nothing in the traces relating to this IO, because the trace
only starts at 270s after boot, and this process has been waiting
since submitting it's IO at 250s after boot. The traces tell me that
IO is still running, but it only takes on IO to go missing for
everything to have problems.

> [  369.378073] =============================================
> 
> Again false positive?

The lockdep false positive in the previous trace has nothing to do
with the IO completion/hung task issue here.

> If it not fs problem why process blocked for such time?

Lots of reasons, but the typical reason for Io completion not
occurring is that broken hardware.

And it looks like there's another different trace appended, and this
one is quite instructive:

> [  237.360627]   task                        PC stack   pid father
> [  237.360882] tracker-store   D12296  2481   1846 0x00000000
> [  237.360894] Call Trace:
> [  237.360901]  __schedule+0x2dc/0xba0
> [  237.360905]  ? _raw_spin_unlock_irq+0x2c/0x40
> [  237.360913]  schedule+0x33/0x90
> [  237.360918]  io_schedule+0x16/0x40
> [  237.360923]  generic_file_read_iter+0x3b8/0xe10
> [  237.360937]  ? page_cache_tree_insert+0x140/0x140
> [  237.360985]  xfs_file_buffered_aio_read+0x6e/0x1a0 [xfs]
> [  237.361018]  xfs_file_read_iter+0x68/0xc0 [xfs]
> [  237.361023]  __vfs_read+0xf1/0x160
> [  237.361035]  vfs_read+0xa3/0x150
> [  237.361042]  SyS_pread64+0x98/0xc0
> [  237.361048]  entry_SYSCALL_64_fastpath+0x1f/0x96

There are multiple processes stuck waiting for data read IO
completion. 

> [  237.361546] TaskSchedulerFo D12184  4005   3825 0x00000000
> [  237.361554] Call Trace:
> [  237.361560]  __schedule+0x2dc/0xba0
> [  237.361566]  ? _raw_spin_unlock_irq+0x2c/0x40
> [  237.361572]  schedule+0x33/0x90
> [  237.361577]  io_schedule+0x16/0x40
> [  237.361581]  wait_on_page_bit+0xd7/0x170
> [  237.361588]  ? page_cache_tree_insert+0x140/0x140
> [  237.361596]  truncate_inode_pages_range+0x702/0x9d0
> [  237.361606]  ? generic_write_end+0x98/0x100
> [  237.361617]  ? sched_clock+0x9/0x10
> [  237.361623]  ? unmap_mapping_range+0x76/0x130
> [  237.361632]  ? up_write+0x1f/0x40
> [  237.361636]  ? unmap_mapping_range+0x76/0x130
> [  237.361643]  truncate_pagecache+0x48/0x70
> [  237.361648]  truncate_setsize+0x32/0x40
> [  237.361677]  xfs_setattr_size+0xe3/0x340 [xfs]

And there's a truncate blocked waiting for data IO completion.

> [  237.361842]  wait_for_completion+0x136/0x1a0
> [  237.361846]  ? wake_up_q+0x80/0x80
> [  237.361872]  ? _xfs_buf_read+0x23/0x30 [xfs]
> [  237.361898]  xfs_buf_submit_wait+0xb2/0x530 [xfs]
> [  237.361935]  _xfs_buf_read+0x23/0x30 [xfs]
> [  237.361958]  xfs_buf_read_map+0x14b/0x300 [xfs]
> [  237.361981]  ? xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  237.362003]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  237.362005]  ? rcu_read_lock_sched_held+0x79/0x80
> [  237.362027]  xfs_imap_to_bp+0x67/0xe0 [xfs]
> [  237.362056]  xfs_iread+0x86/0x220 [xfs]
> [  237.362090]  xfs_iget+0x4c5/0x1070 [xfs]
> [  237.362094]  ? kfree+0xfe/0x2e0
> [  237.362132]  xfs_lookup+0x149/0x1e0 [xfs]
> [  237.362164]  xfs_vn_lookup+0x70/0xb0 [xfs]
> [  237.362172]  lookup_slow+0x132/0x220
> [  237.362192]  walk_component+0x1bd/0x340
> [  237.362202]  path_lookupat+0x84/0x1f0
> [  237.362212]  filename_lookup+0xb6/0x190
> [  237.362226]  ? __check_object_size+0xaf/0x1b0
> [  237.362233]  ? strncpy_from_user+0x4d/0x170
> [  237.362242]  user_path_at_empty+0x36/0x40
> [  237.362245]  ? user_path_at_empty+0x36/0x40
> [  237.362250]  vfs_statx+0x76/0xe0

and there's a stat() call blocked waiting for inode cluster read IO
completion.

> [  237.362321] TaskSchedulerFo D11576  5625   3825 0x00000000
> [  237.362328] Call Trace:
> [  237.362334]  __schedule+0x2dc/0xba0
> [  237.362339]  ? _raw_spin_unlock_irq+0x2c/0x40
> [  237.362346]  schedule+0x33/0x90
> [  237.362350]  io_schedule+0x16/0x40
> [  237.362355]  wait_on_page_bit_common+0x10a/0x1a0
> [  237.362362]  ? page_cache_tree_insert+0x140/0x140
> [  237.362371]  __filemap_fdatawait_range+0xfd/0x190
> [  237.362389]  filemap_write_and_wait_range+0x4b/0x90
> [  237.362412]  xfs_setattr_size+0x10b/0x340 [xfs]
> [  237.362433]  ? setattr_prepare+0x69/0x190
> [  237.362464]  xfs_vn_setattr_size+0x57/0x150 [xfs]
> [  237.362493]  xfs_vn_setattr+0x87/0xb0 [xfs]
> [  237.362502]  notify_change+0x300/0x420
> [  237.362512]  do_truncate+0x73/0xc0

Truncate explicitly waiting for data writeback completion.

> [  237.362586] Call Trace:
> [  237.362593]  __schedule+0x2dc/0xba0
> [  237.362622]  ? _xfs_log_force_lsn+0x2d4/0x360 [xfs]
> [  237.362634]  schedule+0x33/0x90
> [  237.362664]  _xfs_log_force_lsn+0x2d9/0x360 [xfs]
> [  237.362671]  ? wake_up_q+0x80/0x80
> [  237.362705]  xfs_file_fsync+0x10f/0x2b0 [xfs]
> [  237.362718]  vfs_fsync_range+0x4e/0xb0
> [  237.362726]  do_fsync+0x3d/0x70

fsync() waiting on log write IO completion.

> [  237.362804]  schedule_timeout+0x25a/0x5b0
> [  237.362811]  ? mark_held_locks+0x5f/0x90
> [  237.362815]  ? _raw_spin_unlock_irq+0x2c/0x40
> [  237.362818]  ? wait_for_completion+0x10e/0x1a0
> [  237.362823]  ? trace_hardirqs_on_caller+0xf4/0x190
> [  237.362829]  ? wait_for_completion+0x10e/0x1a0
> [  237.362833]  wait_for_completion+0x136/0x1a0
> [  237.362838]  ? wake_up_q+0x80/0x80
> [  237.362868]  ? _xfs_buf_read+0x23/0x30 [xfs]
> [  237.362897]  xfs_buf_submit_wait+0xb2/0x530 [xfs]
> [  237.362926]  _xfs_buf_read+0x23/0x30 [xfs]
> [  237.362952]  xfs_buf_read_map+0x14b/0x300 [xfs]
> [  237.362981]  ? xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  237.363014]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> [  237.363019]  ? rcu_read_lock_sched_held+0x79/0x80
> [  237.363048]  xfs_imap_to_bp+0x67/0xe0 [xfs]
> [  237.363081]  xfs_iread+0x86/0x220 [xfs]
> [  237.363116]  xfs_iget+0x4c5/0x1070 [xfs]
> [  237.363121]  ? kfree+0xfe/0x2e0
> [  237.363162]  xfs_lookup+0x149/0x1e0 [xfs]
> [  237.363195]  xfs_vn_lookup+0x70/0xb0 [xfs]
> [  237.363204]  lookup_open+0x2dc/0x7c0

open() waiting on inode read IO completion.

.....

And there's a lot more threads all waiting on IO completion, both
data or metadata, so I'm not going to bother commenting further
because filesystems don't hang like this by themselves.

i.e. This has all the hallmarks of something below the filesystem
dropping IO completions, such as the hardware being broken. The
filesystem is just the messenger....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
