Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 24] OOM related fixes
Message-Id: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:48:47 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

This is a set of fixes done in the context of a quite evil workload reading
from nfs large files with big read buffers in parallel from many tasks at
the same time until the system goes oom. Mostly all of these fixes seems to be
required to fix the customer workload on top of an older sles kernel. The
forward port of the fixes has been already tested successfully on similar evil
workloads.

The oom deadlock detection triggers a couple of times against the PG_locked
deadlock:

Jun  8 13:51:19 kvm kernel: Killed process 3504 (recursive_readd)
Jun  8 13:51:19 kvm kernel: detected probable OOM deadlock, so killing another task
Jun  8 13:51:19 kvm kernel: Out of memory: kill process 3532 (recursive_readd)
score 1225 or a child

Example of stack trace of TIF_MEMDIE killed task (not literally verified that
this was the one with TIF_MEMDIE set but it's the same as before with the  
verified one):

recursive_rea D ffff810001056418     0  3548   3544 (NOTLB)
 ffff81000e57dba8 0000000000000082 ffff8100010af5e8 ffff8100148df730
 ffff81001ff3ea10 0000000000bd2e1b ffff8100148df908 0000000000000046
 ffff81001fd5f170 ffffffff8031c36d ffff81001fd5f170 ffff810001056418
Call Trace:
 [<ffffffff8031c36d>] __generic_unplug_device+0x13/0x24
 [<ffffffff80244163>] sync_page+0x0/0x40
 [<ffffffff804cdf5b>] io_schedule+0xf/0x17
 [<ffffffff8024419e>] sync_page+0x3b/0x40
 [<ffffffff804ce162>] __wait_on_bit_lock+0x36/0x65
 [<ffffffff80244150>] __lock_page+0x5e/0x64
 [<ffffffff802321f1>] wake_bit_function+0x0/0x23
 [<ffffffff802440c0>] find_get_page+0xe/0x40
 [<ffffffff80244a33>] do_generic_mapping_read+0x200/0x450
 [<ffffffff80243f26>] file_read_actor+0x0/0x11d
 [<ffffffff80247fd4>] get_page_from_freelist+0x2d3/0x36e
 [<ffffffff802464d0>] generic_file_aio_read+0x11d/0x159
 [<ffffffff80260bdc>] do_sync_read+0xc9/0x10c
 [<ffffffff80252adb>] vma_merge+0x10c/0x195
 [<ffffffff802321c3>] autoremove_wake_function+0x0/0x2e
 [<ffffffff80253a06>] do_mmap_pgoff+0x5e1/0x74c
 [<ffffffff8026134d>] vfs_read+0xaa/0x132
 [<ffffffff80261662>] sys_read+0x45/0x6e
 [<ffffffff8020991e>] system_call+0x7e/0x83

At the end I merged David Rientjes's patches to adapt cpuset oom killing to
the new changes and to further improve it.

There's one patch that is controversial (remove_nr_scan) and that can be
deferred, though I guess if it slowdown AIM we should fix it in some other way
not by leaving that patch out. I'll do some local testing with AIM soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
