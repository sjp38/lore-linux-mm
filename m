Received: by an-out-0708.google.com with SMTP id d17so686108and.105
        for <linux-mm@kvack.org>; Mon, 12 May 2008 15:55:34 -0700 (PDT)
Message-ID: <8347f3fb0805121555k266fab9fvf9d006ab2a89dd7a@mail.gmail.com>
Date: Mon, 12 May 2008 18:55:34 -0400
From: "Randy Johnson" <theraptor2005@gmail.com>
Subject: 2.6.25.1: Kernel BUG at mm/rmap.c:669, General Protection Faults, and generic hard locks
In-Reply-To: <8347f3fb0805111721m57ba99e4l21df02d38ca3f41f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <8347f3fb0805111721m57ba99e4l21df02d38ca3f41f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sent this to linux-kernel, then realized I probably should have sent
this here as well...

Hi,

Recently moved from 2.6.22 up to 2.6.25.1 to solve some AHCI issues.
Following this update, Matlab has caused numerous hard lockups. I've
gotten lucky twice and been able to remote in and get the logs, which
follow below. System is an AM2 with 6G ram installed, but booted with
mem=3200M to circumvent some IOMMU issues. It is possible to
eventually replicate the issue, but not with a specific sequence of
activities that I've found. General activity from Matlab when it
occurs is heavy disk IO (reading, no writting), and large memory
consumption. Latest version of memtest86+ was run overnight and shows
no issues.

Any thoughts?

-Randy Johnson


log #1

Eeek! page_mapcount(page) went negative! (-1946157056)
 page pfn = 53ec8
 page->flags = 50080000000068
 page->count = 1
 page->mapping = ffff8100b4c8f769
 vma->vm_ops = 0x0
------------[ cut here ]------------
kernel BUG at mm/rmap.c:669!
invalid opcode: 0000 [1] SMP
CPU 1
Modules linked in: af_packet aic7xxx fan button thermal processor unix
Pid: 6378, comm: MATLAB Not tainted 2.6.25.1 #1
RIP: 0010:[<ffffffff8027733e>]  [<ffffffff8027733e>]
page_remove_rmap+0x12e/0x140
RSP: 0018:ffff8100b4c99d98  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffe2000125bbc0 RCX: 0000000000000001
RDX: 000000000000baba RSI: 0000000000000000 RDI: ffffffff8078fe74
RBP: ffff8100b4c911e8 R08: 000000000000787d R09: 00000000ffffffff
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000001d37000
R13: 0000000001e00000 R14: 0000000002515000 R15: 000000000007b000
FS:  00007f28829196d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000024f3000 CR3: 00000000b51e3000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process MATLAB (pid: 6378, threadinfo ffff8100b4c98000, task ffff8100b5df7080)
Stack:  0000000001c00000 ffff8100bc1109b8 ffffe2000125bbc0 ffffffff8026eede
 ffffe20001d7bae8 0000000000000000 ffff8100b4c99eb0 0000000002515000
 00000000015b3000 ffff8100b4c911e8 ffff8100b4c99eb8 0000000000000000
Call Trace:
 [<ffffffff8026eede>] ? unmap_vmas+0x50e/0x7f0
 [<ffffffff802731fa>] ? unmap_region+0xca/0x160
 [<ffffffff80274123>] ? do_munmap+0x223/0x2d0
 [<ffffffff80584f12>] ? __down_write_nested+0x12/0xb0
 [<ffffffff80275211>] ? sys_brk+0x131/0x140
 [<ffffffff8020b2eb>] ? system_call_after_swapgs+0x7b/0x80


Code: 10 e8 87 0f fe ff 48 8b 85 90 00 00 00 48 85 c0 74 19 48 8b 40
20 48 85 c0 74 10 48 8b 70 58 48 c7 c7 00 5a 64 80 e8 62 0f fe ff <0f>
0b eb fe 48 8b 53 10 e9 65 ff ff ff 66 66 90 66 90 48 83 ec
RIP  [<ffffffff8027733e>] page_remove_rmap+0x12e/0x140
 RSP <ffff8100b4c99d98>
---[ end trace 02af0d83a95ffec2 ]---


And log #2

general protection fault: 0000 [1] SMP
CPU 1
Modules linked in: af_packet aic7xxx fan button thermal processor unix
Pid: 6232, comm: MATLAB Not tainted 2.6.25.1 #1
RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
get_page_from_freelist+0x303/0x670
RSP: 0000:ffff8100b2421d78  EFLAGS: 00010002
RAX: ffff8100bf64bb10 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 000000000000001d
RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
R10: 000000000000175b R11: 0000000000000001 R12: ffffe200029538b0
R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
FS:  00007f07b68656d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f0758765000 CR3: 00000000b3053000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process MATLAB (pid: 6232, threadinfo ffff8100b2420000, task ffff8100b18d2040)
Stack:  0000000100001000 0000000000000001 0000000000000002 ffff8100000104b0
 0000004400000000 ffff8100000104a8 001280d200000000 ffff8100000104b0
 0000000100000000 0000000000000000 0000000000000000 00000002ffffffff
Call Trace:
 [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
 [<ffffffff80270ecc>] ? handle_mm_fault+0x2ec/0x7f0
 [<ffffffff80222cf8>] ? do_page_fault+0x458/0x890
 [<ffffffff80585879>] ? error_exit+0x0/0x51


Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
 RSP <ffff8100b2421d78>
---[ end trace 1ed0909ea0360736 ]---
general protection fault: 0000 [2] SMP
CPU 1
Modules linked in: af_packet aic7xxx fan button thermal processor unix
Pid: 4490, comm: metalog Tainted: G      D  2.6.25.1 #1
RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
get_page_from_freelist+0x303/0x670
RSP: 0018:ffff8100b1827a48  EFLAGS: 00010002
RAX: ffff8100bf64bb10 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 000000000000001d
RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
R10: 000000000000175b R11: 0000000000000001 R12: ffffe200029538b0
R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
FS:  00007f51e48696d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f0758765000 CR3: 00000000b18d6000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process metalog (pid: 4490, threadinfo ffff8100b1826000, task ffff8100bd1f8040)
Stack:  0000000000000000 0000000000000001 0000000000000002 ffff8100000104b0
 0000004400000000 ffff8100000104a8 001200d200000000 ffff8100000104b0
 0000000100000000 0000000000000000 0000000000000000 00000002ffffffff
Call Trace:
 [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
 [<ffffffff80248600>] ? autoremove_wake_function+0x0/0x30
 [<ffffffff8025f76b>] ? __grab_cache_page+0x5b/0x90
 [<ffffffff802e5a8d>] ? reiserfs_write_begin+0x6d/0x200
 [<ffffffff80260428>] ? generic_file_buffered_write+0x148/0x6c0
 [<ffffffff80297992>] ? __link_path_walk+0xcd2/0xe60
 [<ffffffff80260c2e>] ? __generic_file_aio_write_nolock+0x28e/0x440
 [<ffffffff80260e41>] ? generic_file_aio_write+0x61/0xd0
 [<ffffffff8028d259>] ? do_sync_write+0xd9/0x120
 [<ffffffff80290be7>] ? cp_new_stat+0xe7/0x100
 [<ffffffff80248600>] ? autoremove_wake_function+0x0/0x30
 [<ffffffff8028db18>] ? vfs_write+0xc8/0x170
 [<ffffffff8028e1f3>] ? sys_write+0x53/0x90
 [<ffffffff8020b2eb>] ? system_call_after_swapgs+0x7b/0x80


Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
 RSP <ffff8100b1827a48>
---[ end trace 1ed0909ea0360736 ]---
general protection fault: 0000 [3] SMP
CPU 1
Modules linked in: af_packet aic7xxx fan button thermal processor unix
Pid: 6317, comm: cron Tainted: G      D  2.6.25.1 #1
RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
get_page_from_freelist+0x303/0x670
RSP: 0000:ffff8100b7833d18  EFLAGS: 00010002
RAX: ffffe200026d5838 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 0000000000000027
RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000001764 R11: 0000000000000001 R12: ffffe200029538b0
R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
FS:  00007fde356796d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fde34bb5e50 CR3: 00000000bc9ef000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process cron (pid: 6317, threadinfo ffff8100b7832000, task ffff8100bd1f8040)
Stack:  0000000000000000 0000000000000001 0000000000000002 ffff8100000104b0
 00000044b7833d98 ffff8100000104a8 001200d200000000 ffff8100000104b0
 00000001b298d500 0000000000000000 0000000000000000 00000002ffffffff
Call Trace:
 [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
 [<ffffffff8026e28a>] ? do_wp_page+0x9a/0x570
 [<ffffffff802711ba>] ? handle_mm_fault+0x5da/0x7f0
 [<ffffffff80222cf8>] ? do_page_fault+0x458/0x890
 [<ffffffff803b2731>] ? __up_write+0x21/0x130
 [<ffffffff80585879>] ? error_exit+0x0/0x51


Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
 RSP <ffff8100b7833d18>
---[ end trace 1ed0909ea0360736 ]---
general protection fault: 0000 [4] SMP
CPU 1
Modules linked in: af_packet aic7xxx fan button thermal processor unix
Pid: 228, comm: pdflush Tainted: G      D  2.6.25.1 #1
RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
get_page_from_freelist+0x303/0x670
RSP: 0018:ffff8100be795b80  EFLAGS: 00010002
RAX: ffffe200026d5838 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 000000000000003d
RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000001762 R11: 0000000000000001 R12: ffffe200029538b0
R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
FS:  000000004019b940(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007f381c21c000 CR3: 00000000b3053000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process pdflush (pid: 228, threadinfo ffff8100be794000, task ffff8100bec57040)
Stack:  ffff810006413358 0000000000000001 0000000000000002 ffff81000000fa78
 00000044802b1a10 ffff81000000fa70 0012005000000000 ffff81000000fa78
 00000001be795c20 0000000000000000 0000000000000000 00000002ffffffff
Call Trace:
 [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
 [<ffffffff8025fb46>] ? find_or_create_page+0x46/0xb0
 [<ffffffff802b11b1>] ? __getblk+0xd1/0x230
 [<ffffffff802f9c3f>] ? do_journal_end+0x84f/0xe20
 [<ffffffff802fc241>] ? reiserfs_flush_old_commits+0x21/0xd0
 [<ffffffff80267550>] ? pdflush+0x0/0x200
 [<ffffffff802eb274>] ? reiserfs_sync_fs+0x64/0x80
 [<ffffffff8028f76f>] ? sync_supers+0x7f/0xc0
 [<ffffffff8026703d>] ? wb_kupdate+0x2d/0x120
 [<ffffffff80267550>] ? pdflush+0x0/0x200
 [<ffffffff80267550>] ? pdflush+0x0/0x200
 [<ffffffff8026767f>] ? pdflush+0x12f/0x200
 [<ffffffff80267010>] ? wb_kupdate+0x0/0x120
 [<ffffffff802481fb>] ? kthread+0x4b/0x80
 [<ffffffff8020c118>] ? child_rip+0xa/0x12
 [<ffffffff802481b0>] ? kthread+0x0/0x80
 [<ffffffff8020c10e>] ? child_rip+0x0/0x12


Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
 RSP <ffff8100be795b80>
---[ end trace 1ed0909ea0360736 ]---
------------[ cut here ]------------
WARNING: at kernel/exit.c:889 do_exit+0x6dc/0x770()
Modules linked in: af_packet aic7xxx fan button thermal processor unix
Pid: 228, comm: pdflush Tainted: G      D  2.6.25.1 #1

Call Trace:
 [<ffffffff80233ab4>] warn_on_slowpath+0x64/0x90
 [<ffffffff8022a1f0>] enqueue_task_fair+0x20/0x40
 [<ffffffff80228c13>] enqueue_task+0x13/0x30
 [<ffffffff80234afe>] printk+0x4e/0x60
 [<ffffffff80237afc>] do_exit+0x6dc/0x770
 [<ffffffff8022c203>] __wake_up+0x43/0x70
 [<ffffffff8020c597>] oops_end+0x87/0x90
 [<ffffffff80585879>] error_exit+0x0/0x51
 [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
 [<ffffffff80265c11>] __alloc_pages+0x61/0x3a0
 [<ffffffff8025fb46>] find_or_create_page+0x46/0xb0
 [<ffffffff802b11b1>] __getblk+0xd1/0x230
 [<ffffffff802f9c3f>] do_journal_end+0x84f/0xe20
 [<ffffffff802fc241>] reiserfs_flush_old_commits+0x21/0xd0
 [<ffffffff80267550>] pdflush+0x0/0x200
 [<ffffffff802eb274>] reiserfs_sync_fs+0x64/0x80
 [<ffffffff8028f76f>] sync_supers+0x7f/0xc0
 [<ffffffff8026703d>] wb_kupdate+0x2d/0x120
 [<ffffffff80267550>] pdflush+0x0/0x200
 [<ffffffff80267550>] pdflush+0x0/0x200
 [<ffffffff8026767f>] pdflush+0x12f/0x200
 [<ffffffff80267010>] wb_kupdate+0x0/0x120
 [<ffffffff802481fb>] kthread+0x4b/0x80
 [<ffffffff8020c118>] child_rip+0xa/0x12
 [<ffffffff802481b0>] kthread+0x0/0x80
 [<ffffffff8020c10e>] child_rip+0x0/0x12

---[ end trace 1ed0909ea0360736 ]---
general protection fault: 0000 [5] SMP
CPU 1
Modules linked in: af_packet aic7xxx fan button thermal processor unix
Pid: 4911, comm: dhcpcd Tainted: G      D  2.6.25.1 #1
RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
get_page_from_freelist+0x303/0x670
RSP: 0018:ffff8100b5917a48  EFLAGS: 00010002
RAX: ffffe200026d5838 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 0000000000000040
RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000001766 R11: 0000000000000001 R12: ffffe200029538b0
R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
FS:  00007f381c2086d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f381c21c000 CR3: 00000000b1882000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process dhcpcd (pid: 4911, threadinfo ffff8100b5916000, task ffff8100be0527e0)
Stack:  0000000000000000 0000000000000001 0000000000000002 ffff8100000104b0
 0000004400000001 ffff8100000104a8 001200d200000000 ffff8100000104b0
 0000000100000000 0000000000000000 0000000000000000 00000002ffffffff
Call Trace:
 [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
 [<ffffffff8025f76b>] ? __grab_cache_page+0x5b/0x90
 [<ffffffff802e5a8d>] ? reiserfs_write_begin+0x6d/0x200
 [<ffffffff80260428>] ? generic_file_buffered_write+0x148/0x6c0
 [<ffffffff80260c2e>] ? __generic_file_aio_write_nolock+0x28e/0x440
 [<ffffffff8027396d>] ? vma_adjust+0xbd/0x4e0
 [<ffffffff8026c611>] ? zone_statistics+0xb1/0xc0
 [<ffffffff80260e41>] ? generic_file_aio_write+0x61/0xd0
 [<ffffffff8028d259>] ? do_sync_write+0xd9/0x120
 [<ffffffff80248600>] ? autoremove_wake_function+0x0/0x30
 [<ffffffff80270f9d>] ? handle_mm_fault+0x3bd/0x7f0
 [<ffffffff8028db18>] ? vfs_write+0xc8/0x170
 [<ffffffff8028e1f3>] ? sys_write+0x53/0x90
 [<ffffffff8020b2eb>] ? system_call_after_swapgs+0x7b/0x80


Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
 RSP <ffff8100b5917a48>
---[ end trace 1ed0909ea0360736 ]---
general protection fault: 0000 [6] SMP
CPU 1
Modules linked in: af_packet aic7xxx fan button thermal processor unix
Pid: 6319, comm: bash Tainted: G      D  2.6.25.1 #1
RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
get_page_from_freelist+0x303/0x670
RSP: 0018:ffff8100b5917528  EFLAGS: 00010002
RAX: ffffe200026d5838 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 0000000000000030
RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
R10: 000000000000174f R11: 0000000000000001 R12: ffffe200029538b0
R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
FS:  00007fde356796d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007faa98b7dd8e CR3: 00000000b2d4f000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process bash (pid: 6319, threadinfo ffff8100b5916000, task ffff8100bd1f8040)
Stack:  000000000000a83a 0000000000000001 0000000000000002 ffff81000000fa78
 0000004400000001 ffff81000000fa70 0012005000000000 ffff81000000fa78
 0000000100000046 0000000000000000 0000000000000000 00000002ffffffff
Call Trace:
 [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
 [<ffffffff8025fb46>] ? find_or_create_page+0x46/0xb0
 [<ffffffff802b11b1>] ? __getblk+0xd1/0x230
 [<ffffffff802f344e>] ? search_by_key+0x8e/0xdc0
 [<ffffffff8022a187>] ? enqueue_entity+0x37/0x80
 [<ffffffff802e424c>] ? reiserfs_get_block+0xaec/0x1090
 [<ffffffff803b1dca>] ? radix_tree_delete+0x1ba/0x260
 [<ffffffff802f451a>] ? search_for_position_by_key+0x8a/0x320
 [<ffffffff802e1c97>] ? _get_block_create_0+0x87/0x570
 [<ffffffff802e4245>] ? reiserfs_get_block+0xae5/0x1090
 [<ffffffff8026c611>] ? zone_statistics+0xb1/0xc0
 [<ffffffff802a18c7>] ? ifind+0x67/0xc0
 [<ffffffff802b03a7>] ? alloc_buffer_head+0x57/0x60
 [<ffffffff802b0e17>] ? alloc_page_buffers+0x97/0x120
 [<ffffffff802b3c17>] ? block_read_full_page+0x1d7/0x2e0
 [<ffffffff802e3760>] ? reiserfs_get_block+0x0/0x1090
 [<ffffffff802e2320>] ? reiserfs_readpage+0x0/0x10
 [<ffffffff8025f6ba>] ? add_to_page_cache+0xba/0xd0
 [<ffffffff802e2320>] ? reiserfs_readpage+0x0/0x10
 [<ffffffff8025f9a6>] ? read_cache_page_async+0x96/0x150
 [<ffffffff80261656>] ? read_cache_page+0x6/0x50
 [<ffffffff80294dd5>] ? page_getlink+0x25/0x80
 [<ffffffff80294e4b>] ? page_follow_link_light+0x1b/0x30
 [<ffffffff802976e1>] ? __link_path_walk+0xa21/0xe60
 [<ffffffff8026c611>] ? zone_statistics+0xb1/0xc0
 [<ffffffff80297b7a>] ? path_walk+0x5a/0xc0
 [<ffffffff80297e03>] ? do_path_lookup+0x83/0x1c0
 [<ffffffff80298c5a>] ? __path_lookup_intent_open+0x6a/0xd0
 [<ffffffff80299035>] ? open_namei+0x85/0x6c0
 [<ffffffff8028b8bc>] ? do_filp_open+0x1c/0x50
 [<ffffffff8028b589>] ? get_unused_fd_flags+0x79/0x130
 [<ffffffff8028b94a>] ? do_sys_open+0x5a/0xf0
 [<ffffffff8020b2eb>] ? system_call_after_swapgs+0x7b/0x80


Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
 RSP <ffff8100b5917528>
---[ end trace 1ed0909ea0360736 ]---
  page pfn = 53ec8
  page->flags = 50080000000068
  page->count = 1
  page->mapping = ffff8100b4c8f769
  vma->vm_ops = 0x0
 ------------[ cut here ]------------
 kernel BUG at mm/rmap.c:669!
 invalid opcode: 0000 [1] SMP
 CPU 1
 Modules linked in: af_packet aic7xxx fan button thermal processor unix
 Pid: 6378, comm: MATLAB Not tainted 2.6.25.1 #1
 RIP: 0010:[<ffffffff8027733e>]  [<ffffffff8027733e>]
 page_remove_rmap+0x12e/0x140
 RSP: 0018:ffff8100b4c99d98  EFLAGS: 00010246
 RAX: 0000000000000000 RBX: ffffe2000125bbc0 RCX: 0000000000000001
 RDX: 000000000000baba RSI: 0000000000000000 RDI: ffffffff8078fe74
 RBP: ffff8100b4c911e8 R08: 000000000000787d R09: 00000000ffffffff
 R10: 0000000000000000 R11: 0000000000000000 R12: 0000000001d37000
 R13: 0000000001e00000 R14: 0000000002515000 R15: 000000000007b000
 FS:  00007f28829196d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 00000000024f3000 CR3: 00000000b51e3000 CR4: 00000000000006e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process MATLAB (pid: 6378, threadinfo ffff8100b4c98000, task ffff8100b5df7080)
 Stack:  0000000001c00000 ffff8100bc1109b8 ffffe2000125bbc0 ffffffff8026eede
  ffffe20001d7bae8 0000000000000000 ffff8100b4c99eb0 0000000002515000
  00000000015b3000 ffff8100b4c911e8 ffff8100b4c99eb8 0000000000000000
 Call Trace:
  [<ffffffff8026eede>] ? unmap_vmas+0x50e/0x7f0
  [<ffffffff802731fa>] ? unmap_region+0xca/0x160
  [<ffffffff80274123>] ? do_munmap+0x223/0x2d0
  [<ffffffff80584f12>] ? __down_write_nested+0x12/0xb0
  [<ffffffff80275211>] ? sys_brk+0x131/0x140
  [<ffffffff8020b2eb>] ? system_call_after_swapgs+0x7b/0x80


 Code: 10 e8 87 0f fe ff 48 8b 85 90 00 00 00 48 85 c0 74 19 48 8b 40
 20 48 85 c0 74 10 48 8b 70 58 48 c7 c7 00 5a 64 80 e8 62 0f fe ff <0f>
 0b eb fe 48 8b 53 10 e9 65 ff ff ff 66 66 90 66 90 48 83 ec
 RIP  [<ffffffff8027733e>] page_remove_rmap+0x12e/0x140
  RSP <ffff8100b4c99d98>
 ---[ end trace 02af0d83a95ffec2 ]---


 And log #2

 general protection fault: 0000 [1] SMP
 CPU 1
 Modules linked in: af_packet aic7xxx fan button thermal processor unix
 Pid: 6232, comm: MATLAB Not tainted 2.6.25.1 #1
 RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
 get_page_from_freelist+0x303/0x670
 RSP: 0000:ffff8100b2421d78  EFLAGS: 00010002
 RAX: ffff8100bf64bb10 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
 RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 000000000000001d
 RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
 R10: 000000000000175b R11: 0000000000000001 R12: ffffe200029538b0
 R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
 FS:  00007f07b68656d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 00007f0758765000 CR3: 00000000b3053000 CR4: 00000000000006e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process MATLAB (pid: 6232, threadinfo ffff8100b2420000, task ffff8100b18d2040)
 Stack:  0000000100001000 0000000000000001 0000000000000002 ffff8100000104b0
  0000004400000000 ffff8100000104a8 001280d200000000 ffff8100000104b0
  0000000100000000 0000000000000000 0000000000000000 00000002ffffffff
 Call Trace:
  [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
  [<ffffffff80270ecc>] ? handle_mm_fault+0x2ec/0x7f0
  [<ffffffff80222cf8>] ? do_page_fault+0x458/0x890
  [<ffffffff80585879>] ? error_exit+0x0/0x51


 Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
 48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
 89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
 RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
  RSP <ffff8100b2421d78>
 ---[ end trace 1ed0909ea0360736 ]---
 general protection fault: 0000 [2] SMP
 CPU 1
 Modules linked in: af_packet aic7xxx fan button thermal processor unix
 Pid: 4490, comm: metalog Tainted: G      D  2.6.25.1 #1
 RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
 get_page_from_freelist+0x303/0x670
 RSP: 0018:ffff8100b1827a48  EFLAGS: 00010002
 RAX: ffff8100bf64bb10 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
 RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 000000000000001d
 RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
 R10: 000000000000175b R11: 0000000000000001 R12: ffffe200029538b0
 R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
 FS:  00007f51e48696d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: 00007f0758765000 CR3: 00000000b18d6000 CR4: 00000000000006e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process metalog (pid: 4490, threadinfo ffff8100b1826000, task ffff8100bd1f8040)
 Stack:  0000000000000000 0000000000000001 0000000000000002 ffff8100000104b0
  0000004400000000 ffff8100000104a8 001200d200000000 ffff8100000104b0
  0000000100000000 0000000000000000 0000000000000000 00000002ffffffff
 Call Trace:
  [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
  [<ffffffff80248600>] ? autoremove_wake_function+0x0/0x30
  [<ffffffff8025f76b>] ? __grab_cache_page+0x5b/0x90
  [<ffffffff802e5a8d>] ? reiserfs_write_begin+0x6d/0x200
  [<ffffffff80260428>] ? generic_file_buffered_write+0x148/0x6c0
  [<ffffffff80297992>] ? __link_path_walk+0xcd2/0xe60
  [<ffffffff80260c2e>] ? __generic_file_aio_write_nolock+0x28e/0x440
  [<ffffffff80260e41>] ? generic_file_aio_write+0x61/0xd0
  [<ffffffff8028d259>] ? do_sync_write+0xd9/0x120
  [<ffffffff80290be7>] ? cp_new_stat+0xe7/0x100
  [<ffffffff80248600>] ? autoremove_wake_function+0x0/0x30
  [<ffffffff8028db18>] ? vfs_write+0xc8/0x170
  [<ffffffff8028e1f3>] ? sys_write+0x53/0x90
  [<ffffffff8020b2eb>] ? system_call_after_swapgs+0x7b/0x80


 Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
 48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
 89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
 RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
  RSP <ffff8100b1827a48>
 ---[ end trace 1ed0909ea0360736 ]---
 general protection fault: 0000 [3] SMP
 CPU 1
 Modules linked in: af_packet aic7xxx fan button thermal processor unix
 Pid: 6317, comm: cron Tainted: G      D  2.6.25.1 #1
 RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
 get_page_from_freelist+0x303/0x670
 RSP: 0000:ffff8100b7833d18  EFLAGS: 00010002
 RAX: ffffe200026d5838 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
 RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 0000000000000027
 RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
 R10: 0000000000001764 R11: 0000000000000001 R12: ffffe200029538b0
 R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
 FS:  00007fde356796d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: 00007fde34bb5e50 CR3: 00000000bc9ef000 CR4: 00000000000006e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process cron (pid: 6317, threadinfo ffff8100b7832000, task ffff8100bd1f8040)
 Stack:  0000000000000000 0000000000000001 0000000000000002 ffff8100000104b0
  00000044b7833d98 ffff8100000104a8 001200d200000000 ffff8100000104b0
  00000001b298d500 0000000000000000 0000000000000000 00000002ffffffff
 Call Trace:
  [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
  [<ffffffff8026e28a>] ? do_wp_page+0x9a/0x570
  [<ffffffff802711ba>] ? handle_mm_fault+0x5da/0x7f0
  [<ffffffff80222cf8>] ? do_page_fault+0x458/0x890
  [<ffffffff803b2731>] ? __up_write+0x21/0x130
  [<ffffffff80585879>] ? error_exit+0x0/0x51


 Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
 48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
 89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
 RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
  RSP <ffff8100b7833d18>
 ---[ end trace 1ed0909ea0360736 ]---
 general protection fault: 0000 [4] SMP
 CPU 1
 Modules linked in: af_packet aic7xxx fan button thermal processor unix
 Pid: 228, comm: pdflush Tainted: G      D  2.6.25.1 #1
 RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
 get_page_from_freelist+0x303/0x670
 RSP: 0018:ffff8100be795b80  EFLAGS: 00010002
 RAX: ffffe200026d5838 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
 RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 000000000000003d
 RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
 R10: 0000000000001762 R11: 0000000000000001 R12: ffffe200029538b0
 R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
 FS:  000000004019b940(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
 CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
 CR2: 00007f381c21c000 CR3: 00000000b3053000 CR4: 00000000000006e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process pdflush (pid: 228, threadinfo ffff8100be794000, task ffff8100bec57040)
 Stack:  ffff810006413358 0000000000000001 0000000000000002 ffff81000000fa78
  00000044802b1a10 ffff81000000fa70 0012005000000000 ffff81000000fa78
  00000001be795c20 0000000000000000 0000000000000000 00000002ffffffff
 Call Trace:
  [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
  [<ffffffff8025fb46>] ? find_or_create_page+0x46/0xb0
  [<ffffffff802b11b1>] ? __getblk+0xd1/0x230
  [<ffffffff802f9c3f>] ? do_journal_end+0x84f/0xe20
  [<ffffffff802fc241>] ? reiserfs_flush_old_commits+0x21/0xd0
  [<ffffffff80267550>] ? pdflush+0x0/0x200
  [<ffffffff802eb274>] ? reiserfs_sync_fs+0x64/0x80
  [<ffffffff8028f76f>] ? sync_supers+0x7f/0xc0
  [<ffffffff8026703d>] ? wb_kupdate+0x2d/0x120
  [<ffffffff80267550>] ? pdflush+0x0/0x200
  [<ffffffff80267550>] ? pdflush+0x0/0x200
  [<ffffffff8026767f>] ? pdflush+0x12f/0x200
  [<ffffffff80267010>] ? wb_kupdate+0x0/0x120
  [<ffffffff802481fb>] ? kthread+0x4b/0x80
  [<ffffffff8020c118>] ? child_rip+0xa/0x12
  [<ffffffff802481b0>] ? kthread+0x0/0x80
  [<ffffffff8020c10e>] ? child_rip+0x0/0x12


 Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
 48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
 89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
 RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
  RSP <ffff8100be795b80>
 ---[ end trace 1ed0909ea0360736 ]---
 ------------[ cut here ]------------
 WARNING: at kernel/exit.c:889 do_exit+0x6dc/0x770()
 Modules linked in: af_packet aic7xxx fan button thermal processor unix
 Pid: 228, comm: pdflush Tainted: G      D  2.6.25.1 #1

 Call Trace:
  [<ffffffff80233ab4>] warn_on_slowpath+0x64/0x90
  [<ffffffff8022a1f0>] enqueue_task_fair+0x20/0x40
  [<ffffffff80228c13>] enqueue_task+0x13/0x30
  [<ffffffff80234afe>] printk+0x4e/0x60
  [<ffffffff80237afc>] do_exit+0x6dc/0x770
  [<ffffffff8022c203>] __wake_up+0x43/0x70
  [<ffffffff8020c597>] oops_end+0x87/0x90
  [<ffffffff80585879>] error_exit+0x0/0x51
  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
  [<ffffffff80265c11>] __alloc_pages+0x61/0x3a0
  [<ffffffff8025fb46>] find_or_create_page+0x46/0xb0
  [<ffffffff802b11b1>] __getblk+0xd1/0x230
  [<ffffffff802f9c3f>] do_journal_end+0x84f/0xe20
  [<ffffffff802fc241>] reiserfs_flush_old_commits+0x21/0xd0
  [<ffffffff80267550>] pdflush+0x0/0x200
  [<ffffffff802eb274>] reiserfs_sync_fs+0x64/0x80
  [<ffffffff8028f76f>] sync_supers+0x7f/0xc0
  [<ffffffff8026703d>] wb_kupdate+0x2d/0x120
  [<ffffffff80267550>] pdflush+0x0/0x200
  [<ffffffff80267550>] pdflush+0x0/0x200
  [<ffffffff8026767f>] pdflush+0x12f/0x200
  [<ffffffff80267010>] wb_kupdate+0x0/0x120
  [<ffffffff802481fb>] kthread+0x4b/0x80
  [<ffffffff8020c118>] child_rip+0xa/0x12
  [<ffffffff802481b0>] kthread+0x0/0x80
  [<ffffffff8020c10e>] child_rip+0x0/0x12

 ---[ end trace 1ed0909ea0360736 ]---
 general protection fault: 0000 [5] SMP
 CPU 1
 Modules linked in: af_packet aic7xxx fan button thermal processor unix
 Pid: 4911, comm: dhcpcd Tainted: G      D  2.6.25.1 #1
 RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
 get_page_from_freelist+0x303/0x670
 RSP: 0018:ffff8100b5917a48  EFLAGS: 00010002
 RAX: ffffe200026d5838 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
 RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 0000000000000040
 RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
 R10: 0000000000001766 R11: 0000000000000001 R12: ffffe200029538b0
 R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
 FS:  00007f381c2086d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: 00007f381c21c000 CR3: 00000000b1882000 CR4: 00000000000006e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process dhcpcd (pid: 4911, threadinfo ffff8100b5916000, task ffff8100be0527e0)
 Stack:  0000000000000000 0000000000000001 0000000000000002 ffff8100000104b0
  0000004400000001 ffff8100000104a8 001200d200000000 ffff8100000104b0
  0000000100000000 0000000000000000 0000000000000000 00000002ffffffff
 Call Trace:
  [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
  [<ffffffff8025f76b>] ? __grab_cache_page+0x5b/0x90
  [<ffffffff802e5a8d>] ? reiserfs_write_begin+0x6d/0x200
  [<ffffffff80260428>] ? generic_file_buffered_write+0x148/0x6c0
  [<ffffffff80260c2e>] ? __generic_file_aio_write_nolock+0x28e/0x440
  [<ffffffff8027396d>] ? vma_adjust+0xbd/0x4e0
  [<ffffffff8026c611>] ? zone_statistics+0xb1/0xc0
  [<ffffffff80260e41>] ? generic_file_aio_write+0x61/0xd0
  [<ffffffff8028d259>] ? do_sync_write+0xd9/0x120
  [<ffffffff80248600>] ? autoremove_wake_function+0x0/0x30
  [<ffffffff80270f9d>] ? handle_mm_fault+0x3bd/0x7f0
  [<ffffffff8028db18>] ? vfs_write+0xc8/0x170
  [<ffffffff8028e1f3>] ? sys_write+0x53/0x90
  [<ffffffff8020b2eb>] ? system_call_after_swapgs+0x7b/0x80


 Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
 48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
 89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
 RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
  RSP <ffff8100b5917a48>
 ---[ end trace 1ed0909ea0360736 ]---
 general protection fault: 0000 [6] SMP
 CPU 1
 Modules linked in: af_packet aic7xxx fan button thermal processor unix
 Pid: 6319, comm: bash Tainted: G      D  2.6.25.1 #1
 RIP: 0010:[<ffffffff802652e3>]  [<ffffffff802652e3>]
 get_page_from_freelist+0x303/0x670
 RSP: 0018:ffff8100b5917528  EFLAGS: 00010002
 RAX: ffffe200026d5838 RBX: ffff8100bf64bb10 RCX: ffffe200029538d8
 RDX: 7fffe200004bee10 RSI: 0000000000000000 RDI: 0000000000000030
 RBP: ffff8100bf64bb00 R08: 0000000000000000 R09: 0000000000000000
 R10: 000000000000174f R11: 0000000000000001 R12: ffffe200029538b0
 R13: 0000000000000202 R14: ffff81000000d580 R15: 0000000000000002
 FS:  00007fde356796d0(0000) GS:ffff8100bf672dc0(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: 00007faa98b7dd8e CR3: 00000000b2d4f000 CR4: 00000000000006e0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process bash (pid: 6319, threadinfo ffff8100b5916000, task ffff8100bd1f8040)
 Stack:  000000000000a83a 0000000000000001 0000000000000002 ffff81000000fa78
  0000004400000001 ffff81000000fa70 0012005000000000 ffff81000000fa78
  0000000100000046 0000000000000000 0000000000000000 00000002ffffffff
 Call Trace:
  [<ffffffff80265c11>] ? __alloc_pages+0x61/0x3a0
  [<ffffffff8025fb46>] ? find_or_create_page+0x46/0xb0
  [<ffffffff802b11b1>] ? __getblk+0xd1/0x230
  [<ffffffff802f344e>] ? search_by_key+0x8e/0xdc0
  [<ffffffff8022a187>] ? enqueue_entity+0x37/0x80
  [<ffffffff802e424c>] ? reiserfs_get_block+0xaec/0x1090
  [<ffffffff803b1dca>] ? radix_tree_delete+0x1ba/0x260
  [<ffffffff802f451a>] ? search_for_position_by_key+0x8a/0x320
  [<ffffffff802e1c97>] ? _get_block_create_0+0x87/0x570
  [<ffffffff802e4245>] ? reiserfs_get_block+0xae5/0x1090
  [<ffffffff8026c611>] ? zone_statistics+0xb1/0xc0
  [<ffffffff802a18c7>] ? ifind+0x67/0xc0
  [<ffffffff802b03a7>] ? alloc_buffer_head+0x57/0x60
  [<ffffffff802b0e17>] ? alloc_page_buffers+0x97/0x120
  [<ffffffff802b3c17>] ? block_read_full_page+0x1d7/0x2e0
  [<ffffffff802e3760>] ? reiserfs_get_block+0x0/0x1090
  [<ffffffff802e2320>] ? reiserfs_readpage+0x0/0x10
  [<ffffffff8025f6ba>] ? add_to_page_cache+0xba/0xd0
  [<ffffffff802e2320>] ? reiserfs_readpage+0x0/0x10
  [<ffffffff8025f9a6>] ? read_cache_page_async+0x96/0x150
  [<ffffffff80261656>] ? read_cache_page+0x6/0x50
  [<ffffffff80294dd5>] ? page_getlink+0x25/0x80
  [<ffffffff80294e4b>] ? page_follow_link_light+0x1b/0x30
  [<ffffffff802976e1>] ? __link_path_walk+0xa21/0xe60
  [<ffffffff8026c611>] ? zone_statistics+0xb1/0xc0
  [<ffffffff80297b7a>] ? path_walk+0x5a/0xc0
  [<ffffffff80297e03>] ? do_path_lookup+0x83/0x1c0
  [<ffffffff80298c5a>] ? __path_lookup_intent_open+0x6a/0xd0
  [<ffffffff80299035>] ? open_namei+0x85/0x6c0
  [<ffffffff8028b8bc>] ? do_filp_open+0x1c/0x50
  [<ffffffff8028b589>] ? get_unused_fd_flags+0x79/0x130
  [<ffffffff8028b94a>] ? do_sys_open+0x5a/0xf0
  [<ffffffff8020b2eb>] ? system_call_after_swapgs+0x7b/0x80


 Code: 63 55 08 44 8b 44 24 5c 31 f6 4c 89 f7 8b 5d 00 e8 83 e8 ff ff
 48 8b 4d 10 01 c3 89 5d 00 4c 8d 61 d8 49 8b 54 24 28 48 8b 41 08 <48>
 89 42 08 48 89 10 48 c7 41 08 00 02 20 00 49 c7 44 24 28 00
 RIP  [<ffffffff802652e3>] get_page_from_freelist+0x303/0x670
  RSP <ffff8100b5917528>
 ---[ end trace 1ed0909ea0360736 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
