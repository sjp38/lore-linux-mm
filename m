Subject: mm: soft lockup in 2.6.23-6636. caused by drop_caches ?
From: richard kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain
Date: Tue, 23 Oct 2007 14:55:28 +0100
Message-Id: <1193147728.3044.18.camel@castor.rsk.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on git v2.6.23-6636-g557ebb7 I'm getting a soft lockup when running a
simple disk write test case on AMD64X2, sata hd &  ext3.

the test does this
sync
echo 3 > /proc/sys/vm/drop_caches
for (( i=0; $i < $count; i=$i+1 )) ; do
dd if=large_file of=copy_file_$i bs=4k &
done

It never recovers once the lockup occurs and this message repeats on the
console :- 
BUG: soft lockup - CPU#0 stuck for 11s! [kjournald:456]
CPU 0:
Pid: 456, comm: kjournald Not tainted 2.6.23 #1
RIP: 0010:[<ffffffff812442df>]  [<ffffffff812442df>] _spin_lock+0x5/0xf
RSP: 0018:ffff8100096e3db8  EFLAGS: 00000286
RAX: 0000000000000000 RBX: 0000000000000004 RCX: 0000000000000015
RDX: 0000000000200000 RSI: 0000000000000004 RDI: ffffffff81378f80
RBP: ffff8100096e3da0 R08: 0000000000000021 R09: 0000000000000000
R10: ffffe2000142b7c0 R11: 00000000fffffffa R12: ffff8100096e3d90
R13: ffffffff812430b2 R14: ffff810006402bd0 R15: ffff81007fba7000
FS:  00002b3cf6460090(0000) GS:ffffffff813aa000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00002afa6e20b000 CR3: 000000000d6ba000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff810495cf>] wake_bit_function+0x0/0x23
 [<ffffffff810abdd4>] __mark_inode_dirty+0xe0/0x168
 [<ffffffff810afb43>] __set_page_dirty+0x112/0x11e
 [<ffffffff88021238>] :jbd:__journal_unfile_buffer+0x9/0x13
 [<ffffffff88023583>] :jbd:journal_commit_transaction+0xb3d/0xd1a
 [<ffffffff8103f385>] lock_timer_base+0x26/0x4b
 [<ffffffff88025f56>] :jbd:kjournald+0xc3/0x1e6
 [<ffffffff810495a1>] autoremove_wake_function+0x0/0x2e
 [<ffffffff88025e93>] :jbd:kjournald+0x0/0x1e6
 [<ffffffff8104946e>] kthread+0x47/0x75
 [<ffffffff8100cca8>] child_rip+0xa/0x12
 [<ffffffff81049427>] kthread+0x0/0x75
 [<ffffffff8100cc9e>] child_rip+0x0/0x12

BUG: soft lockup - CPU#1 stuck for 11s! [bash:3428]
CPU 1:
Pid: 3428, comm: bash Not tainted 2.6.23 #1
RIP: 0010:[<ffffffff812442e1>]  [<ffffffff812442e1>] _spin_lock+0x7/0xf
RSP: 0018:ffff810009163d80  EFLAGS: 00000286
RAX: 0000000000208029 RBX: ffff81004a895b40 RCX: 0000000000000001
RDX: ffff81004a895b40 RSI: ffffe20000a844b0 RDI: ffff8100095bb954
RBP: 0000000000000000 R08: 0000000000001000 R09: 0000000000000002
R10: ffff810009459230 R11: ffffffff88035a41 R12: ffffffff810700f4
R13: 0000000000000246 R14: ffff81000000d780 R15: ffffe20001bd6d90
FS:  00002b58a941ef40(0000) GS:ffff810006801700(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000362b8676e0 CR3: 000000000eddf000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff880228c9>] :jbd:journal_try_to_free_buffers+0x7e/0x124
 [<ffffffff81070b24>] __invalidate_mapping_pages+0x81/0x103
 [<ffffffff810ac53b>] drop_pagecache+0x74/0xe6
 [<ffffffff810ac5c7>] drop_caches_sysctl_handler+0x1a/0x2f
 [<ffffffff810cf5b7>] proc_sys_write+0x7c/0xa4
 [<ffffffff810912b9>] vfs_write+0xc6/0x16f
 [<ffffffff81091874>] sys_write+0x45/0x6e
 [<ffffffff8100c00c>] tracesys+0xdc/0xe1

Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
