Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDA16B0260
	for <linux-mm@kvack.org>; Sat,  7 Oct 2017 04:11:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s80so5624131lfg.0
        for <linux-mm@kvack.org>; Sat, 07 Oct 2017 01:11:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d128sor529440lfe.12.2017.10.07.01.11.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Oct 2017 01:11:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170904123039.GA5664@quack2.suse.cz>
References: <CABXGCsOL+_OgC0dpO1+Zeg=iu7ryZRZT4S7k-io8EGB0ZRgZGw@mail.gmail.com>
 <20170903074306.GA8351@infradead.org> <CABXGCsMmEvEh__R2L47jqVnxv9XDaT_KP67jzsUeDLhF2OuOyA@mail.gmail.com>
 <20170904123039.GA5664@quack2.suse.cz>
From: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Date: Sat, 7 Oct 2017 13:10:58 +0500
Message-ID: <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org

> Can you reproduce this? I've seen one occurence of this on our distro
> 4.4-based kernel but we were never able to reproduce and find the culprit.
> If you can reproduce, could you run with the attached debug patch to see
> whether the WARN_ON triggers? Because my suspicion is that there is some
> subtle race in page table teardown vs writeback vs page reclaim which can
> result in page being dirtied without filesystem being notified about it (I
> have seen very similar oops for ext4 as well which leads me to suspicion
> this is a generic issue). Thanks!

I trying reproduce issue with with your patch.
But seems now got another issue:

[ 1966.953781] INFO: task tracker-store:8578 blocked for more than 120 seconds.
[ 1966.953797]       Not tainted 4.13.4-301.fc27.x86_64+debug #1
[ 1966.953800] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 1966.953804] tracker-store   D12840  8578   1655 0x00000000
[ 1966.953811] Call Trace:
[ 1966.953823]  __schedule+0x2dc/0xbb0
[ 1966.953830]  ? wait_on_page_bit_common+0xfb/0x1a0
[ 1966.953838]  schedule+0x3d/0x90
[ 1966.953843]  io_schedule+0x16/0x40
[ 1966.953847]  wait_on_page_bit_common+0x10a/0x1a0
[ 1966.953857]  ? page_cache_tree_insert+0x170/0x170
[ 1966.953865]  __filemap_fdatawait_range+0x101/0x1a0
[ 1966.953883]  file_write_and_wait_range+0x63/0xc0
[ 1966.953928]  xfs_file_fsync+0x7c/0x2b0 [xfs]
[ 1966.953938]  vfs_fsync_range+0x4b/0xb0
[ 1966.953945]  do_fsync+0x3d/0x70
[ 1966.953950]  SyS_fsync+0x10/0x20
[ 1966.953954]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[ 1966.953957] RIP: 0033:0x7f9364393d5c
[ 1966.953959] RSP: 002b:00007ffe130b7d50 EFLAGS: 00000293 ORIG_RAX:
000000000000004a
[ 1966.953964] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f9364393d5c
[ 1966.953966] RDX: 0000000000000000 RSI: 00007ffe130b7d80 RDI: 000000000000000f
[ 1966.953968] RBP: 0000000000058a8e R08: 0000000000000000 R09: 000000000000002c
[ 1966.953970] R10: 0000000000058a8e R11: 0000000000000293 R12: 00007f9368ef57f0
[ 1966.953972] R13: 00005585d1ab47b0 R14: 00005585d19701d0 R15: 0000000000058a8e
[ 1966.954131]
               Showing all locks held in the system:
[ 1966.954141] 1 lock held by khungtaskd/65:
[ 1966.954147]  #0:  (tasklist_lock){.+.+..}, at: [<ffffffff9a114c6d>]
debug_show_all_locks+0x3d/0x1a0
[ 1966.954163] 3 locks held by kworker/u16:4/145:
[ 1966.954165]  #0:  ("writeback"){.+.+.+}, at: [<ffffffff9a0d2ac0>]
process_one_work+0x1d0/0x6a0
[ 1966.954176]  #1:  ((&(&wb->dwork)->work)){+.+.+.}, at:
[<ffffffff9a0d2ac0>] process_one_work+0x1d0/0x6a0
[ 1966.954187]  #2:  (&type->s_umount_key#63){++++.+}, at:
[<ffffffff9a2d3dbb>] trylock_super+0x1b/0x50
[ 1966.954289] 3 locks held by Cache2 I/O/2602:
[ 1966.954291]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2ccaef>]
do_sys_ftruncate.constprop.17+0xdf/0x110
[ 1966.954305]  #1:  (&inode->i_rwsem){++++++}, at:
[<ffffffff9a2cc795>] do_truncate+0x65/0xc0
[ 1966.954317]  #2:  (&(&ip->i_mmaplock)->mr_lock){+++++.}, at:
[<ffffffffc0a9aef9>] xfs_ilock+0x159/0x220 [xfs]
[ 1966.954501] 2 locks held by kworker/0:0/6788:
[ 1966.954503]  #0:  ("xfs-cil/%s"mp->m_fsname){++++..}, at:
[<ffffffff9a0d2ac0>] process_one_work+0x1d0/0x6a0
[ 1966.954513]  #1:  ((&cil->xc_push_work)){+.+...}, at:
[<ffffffff9a0d2ac0>] process_one_work+0x1d0/0x6a0
[ 1966.954530] 3 locks held by TaskSchedulerFo/8616:
[ 1966.954531]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2ccaef>]
do_sys_ftruncate.constprop.17+0xdf/0x110
[ 1966.954543]  #1:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffff9a2cc795>] do_truncate+0x65/0xc0
[ 1966.954556]  #2:  (&(&ip->i_mmaplock)->mr_lock){+++++.}, at:
[<ffffffffc0a9aef9>] xfs_ilock+0x159/0x220 [xfs]
[ 1966.954592] 3 locks held by TaskSchedulerFo/8686:
[ 1966.954594]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2fa7d4>]
mnt_want_write+0x24/0x50
[ 1966.954608]  #1:  (sb_internal#2){.+.+.+}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[ 1966.954646]  #2:  (&xfs_nondir_ilock_class){++++..}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[ 1966.954679] 5 locks held by TaskSchedulerFo/8687:
[ 1966.954681]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2ccaef>]
do_sys_ftruncate.constprop.17+0xdf/0x110
[ 1966.954693]  #1:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffff9a2cc795>] do_truncate+0x65/0xc0
[ 1966.954705]  #2:  (&(&ip->i_mmaplock)->mr_lock){+++++.}, at:
[<ffffffffc0a9aef9>] xfs_ilock+0x159/0x220 [xfs]
[ 1966.954740]  #3:  (sb_internal#2){.+.+.+}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[ 1966.954777]  #4:  (&xfs_nondir_ilock_class){++++..}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[ 1966.954811] 5 locks held by TaskSchedulerFo/8689:
[ 1966.954813]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2ccaef>]
do_sys_ftruncate.constprop.17+0xdf/0x110
[ 1966.954825]  #1:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffff9a2cc795>] do_truncate+0x65/0xc0
[ 1966.954837]  #2:  (&(&ip->i_mmaplock)->mr_lock){+++++.}, at:
[<ffffffffc0a9aef9>] xfs_ilock+0x159/0x220 [xfs]
[ 1966.954871]  #3:  (sb_internal#2){.+.+.+}, at: [<ffffffffc0aad7ac>]
xfs_trans_alloc+0xec/0x130 [xfs]
[ 1966.954906]  #4:  (&xfs_nondir_ilock_class){++++..}, at:
[<ffffffffc0a9af14>] xfs_ilock+0x174/0x220 [xfs]
[ 1966.954941] 3 locks held by TaskSchedulerFo/8690:
[ 1966.954943]  #0:  (sb_writers#17){.+.+.+}, at: [<ffffffff9a2ccaef>]
do_sys_ftruncate.constprop.17+0xdf/0x110
[ 1966.954955]  #1:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffff9a2cc795>] do_truncate+0x65/0xc0
[ 1966.954967]  #2:  (&(&ip->i_mmaplock)->mr_lock){+++++.}, at:
[<ffffffffc0a9aef9>] xfs_ilock+0x159/0x220 [xfs]
[ 1966.955001] 2 locks held by TaskSchedulerFo/9512:
[ 1966.955003]  #0:  (&f->f_pos_lock){+.+.+.}, at:
[<ffffffff9a2f71ac>] __fdget_pos+0x4c/0x60
[ 1966.955013]  #1:  (&sb->s_type->i_mutex_key#19){++++++}, at:
[<ffffffffc0a9af4c>] xfs_ilock+0x1ac/0x220 [xfs]
[ 1966.955048] 1 lock held by TaskSchedulerFo/9513:
[ 1966.955049]  #0:  (&xfs_nondir_ilock_class){++++..}, at:
[<ffffffffc0a9ae89>] xfs_ilock+0xe9/0x220 [xfs]

[ 1966.955214] =============================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
