From: Andi Kleen <ak@suse.de>
Subject: ext3 fsync being starved for a long time by cp and cronjob
Date: Fri, 25 Aug 2006 13:53:51 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608251353.51748.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: axboe@suse.de, akpm@osdl.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

My vim is right now sitting for over a minute being stalled in a fsync
(it was several minutes overall):

vi            D ffff810077879d98     0 13905  13900                     (NOTLB)
 ffff810077879d98 ffffffff804d1c4e 000000000000008f ffff810009256240
 ffff81007be8e080 ffff810009256418 0000000000000001 0000000000000246
 0000000000000003 0000000000000000 000000008022284e ffff81007bd02024
Call Trace:
 [<ffffffff804d1c4e>] thread_return+0x0/0xd3
 [<ffffffff802db658>] log_wait_commit+0xa3/0xf5
 [<ffffffff8023b05c>] autoremove_wake_function+0x0/0x2e
 [<ffffffff802d4cee>] journal_stop+0x1d2/0x202
 [<ffffffff80284f13>] __writeback_single_inode+0x1ec/0x372
 [<ffffffff8023b05c>] autoremove_wake_function+0x0/0x2e
 [<ffffffff802850ba>] sync_inode+0x21/0x30
 [<ffffffff802c5bd9>] ext3_sync_file+0xb1/0xc4
 [<ffffffff8026763b>] do_fsync+0x4f/0x85
 [<ffffffff80267694>] __do_fsync+0x23/0x36
 [<ffffffff802094ee>] system_call+0x7e/0x83

Background load is a large cp from the same fs to a tmpfs and a cron job
doing random cron job stuff. All on a single sata disk with a 28G partition.

While I write this other windows keep stalling too, like my 
mailer and I have to wait to continue. I'm not sure it did fsync or not.

Kernel is 2.6.18rc3. Elevator is CFQ2.

Is such long starvation expected? Will ext4 fix that?

cp            D ffff81003f041bd8     0 13873  13872                     (NOTLB)
 ffff81003f041bd8 ffff81005d6937c0 0000000000002578 ffff8100186c89e0
 ffff81007be8e080 ffff8100186c8bb8 ffff8100551ff710 ffff81003f041cb8
 ffffffff802c6f2d 0000000000000000 0000000000000046 ffff81007b2f9968
Call Trace:
 [<ffffffff802c6f2d>] __ext3_get_inode_loc+0x156/0x317
 [<ffffffff802485a2>] sync_page+0x0/0x41
 [<ffffffff804d1d47>] io_schedule+0x26/0x32
 [<ffffffff80433dc1>] dm_unplug_all+0x0/0x28
 [<ffffffff802485de>] sync_page+0x3c/0x41
 [<ffffffff804d255a>] __wait_on_bit_lock+0x37/0x64
 [<ffffffff802486b2>] __lock_page+0x5e/0x64
 [<ffffffff8023b16c>] wake_bit_function+0x0/0x23
 [<ffffffff80249cff>] do_generic_mapping_read+0x1c6/0x3f4
 [<ffffffff80248b20>] file_read_actor+0x0/0xfe
 [<ffffffff8024a67d>] __generic_file_aio_read+0x14e/0x19b
 [<ffffffff8024a86b>] generic_file_aio_read+0x34/0x39
 [<ffffffff8026625a>] do_sync_read+0xc7/0x104
 [<ffffffff80272edf>] may_open+0x59/0x1bf
 [<ffffffff8023b05c>] autoremove_wake_function+0x0/0x2e
 [<ffffffff802664b2>] vfs_read+0xa8/0x14d
 [<ffffffff80266e78>] sys_read+0x45/0x6e
 [<ffffffff802094ee>] system_call+0x7e/0x83
kjournald     S ffff81007aa3be98     0  1369     11          7279   910 (L-TLB)
 ffff81007aa3be98 0000000000000fb4 0000000000000510 ffff81007b330ae0
 ffff81007be5b5e0 ffff81007b330cb8 0000000000000001 0000000000000246
 0000000000000003 ffff81007aa3be98 ffffffff8022284e 0000000000000000
Call Trace:
 [<ffffffff8022284e>] __wake_up+0x36/0x4d
 [<ffffffff802da225>] kjournald+0x192/0x213
 [<ffffffff8023b05c>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8023acfc>] keventd_create_kthread+0x0/0x5e
 [<ffffffff802da093>] kjournald+0x0/0x213
 [<ffffffff8023acfc>] keventd_create_kthread+0x0/0x5e
 [<ffffffff8023aef7>] kthread+0xcb/0xf5
 [<ffffffff8020a3d6>] child_rip+0x8/0x12
 [<ffffffff8023acfc>] keventd_create_kthread+0x0/0x5e
 [<ffffffff8023ae2c>] kthread+0x0/0xf5
 [<ffffffff8020a3ce>] child_rip+0x0/0x12

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
