From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Deadlock at io_schedule? (Re: linux-next: Tree for November 3)
Date: Mon, 3 Nov 2008 16:33:01 +0300
Message-ID: <a4423d670811030533x62af4599mb0ecf33f91f070ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

Hi

2.6.28-rc3-next-20081103 on sparc64

SysRq : Emergency Sync
SysRq : Emergency Sync
SysRq : Emergency Sync
SysRq : Show Locks Held

Showing all locks held in the system:
1 lock held by pdflush/163:
 #0:  (&type->s_umount_key#13){----}, at: [<00000000004cf148>]
__sync_inodes+0x5c/0xd4
1 lock held by pdflush/164:
 #0:  (&type->s_umount_key#13){----}, at: [<00000000004cf148>]
__sync_inodes+0x5c/0xd4
1 lock held by metalog/1413:
 #0:  (&sb->s_type->i_mutex_key#3){--..}, at: [<0000000000488c88>]
generic_file_aio_write+0x44/0xc8
1 lock held by agetty/1630:
 #0:  (&tty->atomic_read_lock){--..}, at: [<00000000005ead9c>]
n_tty_read+0x20c/0x648
1 lock held by agetty/1632:
 #0:  (&tty->atomic_read_lock){--..}, at: [<00000000005ead9c>]
n_tty_read+0x20c/0x648
1 lock held by agetty/1634:
 #0:  (&tty->atomic_read_lock){--..}, at: [<00000000005ead9c>]
n_tty_read+0x20c/0x648
1 lock held by agetty/1636:
 #0:  (&tty->atomic_read_lock){--..}, at: [<00000000005ead9c>]
n_tty_read+0x20c/0x648
1 lock held by agetty/1638:
 #0:  (&tty->atomic_read_lock){--..}, at: [<00000000005ead9c>]
n_tty_read+0x20c/0x648
1 lock held by agetty/1640:
 #0:  (&tty->atomic_read_lock){--..}, at: [<00000000005ead9c>]
n_tty_read+0x20c/0x648
2 locks held by bash/1671:
 #0:  (sysrq_key_table_lock){....}, at: [<00000000005fc700>]
__handle_sysrq+0x14/0x164
 #1:  (tasklist_lock){..--}, at: [<0000000000471510>]
debug_show_all_locks+0x5c/0x1a8
1 lock held by bash/1676:
 #0:  (&tty->atomic_read_lock){--..}, at: [<00000000005ead9c>]
n_tty_read+0x20c/0x648
2 locks held by touch/1317:
 #0:  (&sb->s_type->i_mutex_key#3){--..}, at: [<00000000004d2170>]
utimes_common+0x164/0x194
 #1:  (jbd_handle){--..}, at: [<000000000053d788>] journal_start+0xe8/0x118
1 lock held by bash/1333:
 #0:  (&p->cred_exec_mutex){--..}, at: [<00000000004e61c0>]
compat_do_execve+0x38/0x194
1 lock held by init/1336:
 #0:  (&sb->s_type->i_mutex_key#3){--..}, at: [<0000000000488c88>]
generic_file_aio_write+0x44/0xc8

=============================================

SysRq : Show Blocked State
  task                        PC stack   pid father
pdflush       D 00000000004878c8     0   163      2
Call Trace:
 [00000000006d9f74] io_schedule+0x20/0x3c
 [00000000004878c8] sync_page+0x84/0x94
 [00000000006da2f8] __wait_on_bit+0x64/0xc0
 [0000000000487b20] wait_on_page_bit+0x8c/0x9c
 [00000000004880bc] wait_on_page_writeback_range+0x68/0x124
 [00000000004881a4] filemap_fdatawait+0x2c/0x40
 [000000000048844c] filemap_write_and_wait+0x38/0x50
 [00000000004d41fc] sync_blockdev+0x1c/0x30
 [00000000004cf168] __sync_inodes+0x7c/0xd4
 [00000000004cf1d8] sync_inodes+0x18/0x40
 [00000000004d1f88] do_sync+0x1c/0x7c
 [000000000048ff64] pdflush+0x110/0x1c0
 [00000000004655e4] kthread+0x48/0x7c
 [00000000004271a0] kernel_thread+0x3c/0x54
 [0000000000465450] kthreadd+0xe0/0x184
pdflush       D 00000000004878c8     0   164      2
Call Trace:
 [00000000006d9f74] io_schedule+0x20/0x3c
 [00000000004878c8] sync_page+0x84/0x94
 [00000000006da2f8] __wait_on_bit+0x64/0xc0
 [0000000000487b20] wait_on_page_bit+0x8c/0x9c
 [00000000004880bc] wait_on_page_writeback_range+0x68/0x124
 [00000000004881a4] filemap_fdatawait+0x2c/0x40
 [000000000048844c] filemap_write_and_wait+0x38/0x50
 [00000000004d41fc] sync_blockdev+0x1c/0x30
 [00000000004cf168] __sync_inodes+0x7c/0xd4
 [00000000004cf1d8] sync_inodes+0x18/0x40
 [00000000004d1f88] do_sync+0x1c/0x7c
 [000000000048ff64] pdflush+0x110/0x1c0
 [00000000004655e4] kthread+0x48/0x7c
 [00000000004271a0] kernel_thread+0x3c/0x54
 [0000000000465450] kthreadd+0xe0/0x184
kjournald     D 00000000005443d4     0   405      2
Call Trace:
 [000000000053f394] journal_commit_transaction+0x1c4/0x1648
 [00000000005443d4] kjournald+0x134/0x2fc
 [00000000004655e4] kthread+0x48/0x7c
 [00000000004271a0] kernel_thread+0x3c/0x54
 [0000000000465450] kthreadd+0xe0/0x184
metalog       D 000000000053d758     0  1413      1
Call Trace:
 [000000000053d4b0] start_this_handle+0x2b0/0x4a0
 [000000000053d758] journal_start+0xb8/0x118
 [00000000005117c0] ext3_journal_start_sb+0x54/0x64
 [000000000050b09c] ext3_dirty_inode+0x18/0xc8
 [00000000004cf318] __mark_inode_dirty+0x2c/0x180
 [00000000004c6674] file_update_time+0xe0/0x118
 [0000000000488b44] __generic_file_aio_write_nolock+0x26c/0x36c
 [0000000000488c9c] generic_file_aio_write+0x58/0xc8
 [0000000000505a30] ext3_file_write+0x28/0xd8
 [00000000004b2d88] do_sync_write+0x90/0xe0
 [00000000004b35e8] vfs_write+0x7c/0x118
 [00000000004b3a18] sys_write+0x38/0x68
 [0000000000406154] linux_sparc_syscall32+0x34/0x40
touch         D 00000000004d4400     0  1317      1
Call Trace:
 [00000000006d9f74] io_schedule+0x20/0x3c
 [00000000004d4400] sync_buffer+0x4c/0x5c
 [00000000006da1d8] __wait_on_bit_lock+0x64/0xa4
 [00000000006da280] out_of_line_wait_on_bit_lock+0x68/0x7c
 [00000000004d474c] __lock_buffer+0x34/0x44
 [000000000053cacc] do_get_write_access+0xd4/0x65c
 [000000000053d078] journal_get_write_access+0x24/0x40
 [0000000000516a08] __ext3_journal_get_write_access+0x14/0x50
 [0000000000507db4] ext3_reserve_inode_write+0x40/0x88
 [0000000000507e28] ext3_mark_inode_dirty+0x2c/0x5c
 [000000000050b12c] ext3_dirty_inode+0xa8/0xc8
 [00000000004cf318] __mark_inode_dirty+0x2c/0x180
 [00000000004c6b6c] inode_setattr+0x120/0x138
 [000000000050b034] ext3_setattr+0x174/0x1c4
 [00000000004c6d4c] notify_change+0x1c8/0x328
 [00000000004d217c] utimes_common+0x170/0x194
init          D 000000000053d758     0  1336      1
Call Trace:
 [000000000053d4b0] start_this_handle+0x2b0/0x4a0
 [000000000053d758] journal_start+0xb8/0x118
 [00000000005117c0] ext3_journal_start_sb+0x54/0x64
 [000000000050b09c] ext3_dirty_inode+0x18/0xc8
 [00000000004cf318] __mark_inode_dirty+0x2c/0x180
 [00000000004c6674] file_update_time+0xe0/0x118
 [0000000000488b44] __generic_file_aio_write_nolock+0x26c/0x36c
 [0000000000488c9c] generic_file_aio_write+0x58/0xc8
 [0000000000505a30] ext3_file_write+0x28/0xd8
 [00000000004b2d88] do_sync_write+0x90/0xe0
 [00000000004b35e8] vfs_write+0x7c/0x118
 [00000000004b3a18] sys_write+0x38/0x68
 [0000000000406154] linux_sparc_syscall32+0x34/0x40
