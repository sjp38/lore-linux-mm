Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C40D96B028A
	for <linux-mm@kvack.org>; Tue,  4 May 2010 10:33:47 -0400 (EDT)
Date: Tue, 4 May 2010 15:33:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
	and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100504143311.GI20979@csn.ul.ie>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie> <1272529930-29505-3-git-send-email-mel@csn.ul.ie> <20100429162120.GC22108@random.random> <20100504103213.GB20979@csn.ul.ie> <20100504125606.GK19891@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100504125606.GK19891@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 04, 2010 at 02:56:06PM +0200, Andrea Arcangeli wrote:
> On Tue, May 04, 2010 at 11:32:13AM +0100, Mel Gorman wrote:
> > Unfortunately, the same bug triggers after about 18 minutes. The objective of
> > your fix is very simple - have a VMA covering the new range so that rmap can
> > find it. However, no lock is held during move_page_tables() because of the
> > need to call the page allocator. Due to the lack of locking, is it possible
> > that something like the following is happening?
> > 
> > Exec Process				Migration Process
> > begin move_page_tables
> > 					begin rmap walk
> > 					take anon_vma locks
> > 					find new location of pte (do nothing)
> > copy migration pte to new location
> > #### Bad PTE now in place
> > 					find old location of pte
> > 					remove old migration pte
> > 					release anon_vma locks
> > remove temporary VMA
> > some time later, bug on migration pte
> > 
> > Even with the care taken, a migration PTE got copied and then left behind. What
> > I haven't confirmed at this point is if the ordering of the walk in "migration
> > process" is correct in the above scenario. The order is important for
> > the race as described to happen.
> 
> Ok so this seems the ordering dependency on the anon_vma list that
> strikes again, I didn't realize the ordering would matter here, but it
> does as shown above, great catch! The destination vma of the
> move_page_tables has to be at the tail of the anon_vma list like the
> child vma have to be at the end to avoid the equivalent race in
> fork. This has to be a requirement for mremap too. We just want to
> enforce the same invariants that mremap already enforces, to avoid
> adding new special cases to the VM.
> 

Agreed. To be honest, I found the problems ordering of the anon_vma a little
confusing but as long as it's consistent everywhere, it's manageable. If
this ever burns us in the future though, we might want DEBUG_VM option that
somehow verifies the ordering of the anon_vma list.

> == for new anon-vma code ==
> Subject: fix race between shift_arg_pages and rmap_walk
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> migrate.c requires rmap to be able to find all ptes mapping a page at
> all times, otherwise the migration entry can be instantiated, but it
> can't be removed if the second rmap_walk fails to find the page.
> 
> And split_huge_page() will have the same requirements as migrate.c
> already has.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

I'm currently testing this and have seen no problems after an hour which
is typically good. To be absolutly sure, it needs 24 hours but so far so
good. The changelog is a tad on the light side so maybe you'd like to take
this one instead and edit it to your liking?

==== CUT HERE ===

mm,migration: Fix race between shift_arg_pages and rmap_walk by guaranteeing rmap_walk finds PTEs created within the temporary stack

Page migration requires rmap to be able to find all migration ptes
created by migration. If the second rmap_walk clearing migration PTEs
misses an entry, it is left dangling causing a BUG_ON to trigger during
fault. For example;

[  511.201534] kernel BUG at include/linux/swapops.h:105!
[  511.201534] invalid opcode: 0000 [#1] PREEMPT SMP
[  511.201534] last sysfs file: /sys/block/sde/size
[  511.201534] CPU 0
[  511.201534] Modules linked in: kvm_amd kvm dm_crypt loop i2c_piix4 serio_raw tpm_tis shpchp evdev tpm i2c_core pci_hotplug tpm_bios wmi processor button ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod raid10 raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid1 raid0 multipath linear md_mod sg sr_mod cdrom sd_mod ata_generic ahci libahci libata ide_pci_generic ehci_hcd ide_core r8169 mii ohci_hcd scsi_mod floppy thermal fan thermal_sys
[  511.888526]
[  511.888526] Pid: 20431, comm: date Not tainted 2.6.34-rc4-mm1-fix-swapops #6 GA-MA790GP-UD4H/GA-MA790GP-UD4H
[  511.888526] RIP: 0010:[<ffffffff811094ff>]  [<ffffffff811094ff>] migration_entry_wait+0xc1/0x129
[  512.173545] RSP: 0018:ffff880037b979d8  EFLAGS: 00010246
[  512.198503] RAX: ffffea0000000000 RBX: ffffea0001a2ba10 RCX: 0000000000029830
[  512.329617] RDX: 0000000001a2ba10 RSI: ffffffff818264b8 RDI: 000000000ef45c3e
[  512.380001] RBP: ffff880037b97a08 R08: ffff880078003f00 R09: ffff880037b979e8
[  512.380001] R10: ffffffff8114ddaa R11: 0000000000000246 R12: 0000000037304000
[  512.380001] R13: ffff88007a9ed5c8 R14: f800000000077a2e R15: 000000000ef45c3e
[  512.380001] FS:  00007f3d346866e0(0000) GS:ffff880002200000(0000) knlGS:0000000000000000
[  512.380001] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  512.380001] CR2: 00007fff6abec9c1 CR3: 0000000037a15000 CR4: 00000000000006f0
[  512.380001] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  513.004775] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  513.068415] Process date (pid: 20431, threadinfo ffff880037b96000, task ffff880078003f00)
[  513.068415] Stack:
[  513.068415]  ffff880037b97b98 ffff880037b97a18 ffff880037b97be8 0000000000000c00
[  513.228068] <0> ffff880037304f60 00007fff6abec9c1 ffff880037b97aa8 ffffffff810e951a
[  513.228068] <0> ffff880037b97a88 0000000000000246 0000000000000000 ffffffff8130c5c2
[  513.228068] Call Trace:
[  513.228068]  [<ffffffff810e951a>] handle_mm_fault+0x3f8/0x76a
[  513.228068]  [<ffffffff8130c5c2>] ? do_page_fault+0x26a/0x46e
[  513.228068]  [<ffffffff8130c7a2>] do_page_fault+0x44a/0x46e
[  513.720755]  [<ffffffff8130875d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  513.789278]  [<ffffffff8114ddaa>] ? load_elf_binary+0x14a1/0x192b
[  513.851506]  [<ffffffff813099b5>] page_fault+0x25/0x30
[  513.851506]  [<ffffffff8114ddaa>] ? load_elf_binary+0x14a1/0x192b
[  513.851506]  [<ffffffff811c1e27>] ? strnlen_user+0x3f/0x57
[  513.851506]  [<ffffffff8114de33>] load_elf_binary+0x152a/0x192b
[  513.851506]  [<ffffffff8111329b>] search_binary_handler+0x173/0x313
[  513.851506]  [<ffffffff8114c909>] ? load_elf_binary+0x0/0x192b
[  513.851506]  [<ffffffff81114896>] do_execve+0x219/0x30a
[  513.851506]  [<ffffffff8111887f>] ? getname+0x14d/0x1b3
[  513.851506]  [<ffffffff8100a5c6>] sys_execve+0x43/0x5e
[  514.483501]  [<ffffffff8100320a>] stub_execve+0x6a/0xc0
[  514.548357] Code: 74 05 83 f8 1f 75 68 48 b8 ff ff ff ff ff ff ff 07 48 21 c2 48 b8 00 00 00 00 00 ea ff ff 48 6b d2 38 48 8d 1c 02 f6 03 01 75 04 <0f> 0b eb fe 8b 4b 08 48 8d 73 08 85 c9 74 35 8d 41 01 89 4d e0
[  514.704292] RIP  [<ffffffff811094ff>] migration_entry_wait+0xc1/0x129
[  514.808221]  RSP <ffff880037b979d8>
[  514.906179] ---[ end trace 4f88495edc224d6b ]---

This particular BUG_ON is caused by a race between shift_arg_pages and
migration. During exec, a temporary stack is created and later moved to its
final location. If migration selects a page within the temporary stack,
the page tables and migration PTE can be copied to the new location
before rmap_walk is able to find the copy. This leaves a dangling
migration PTE behind that later triggers the bug.

This patch fixes the problem by using two VMAs - one which covers the temporary
stack and the other which covers the new location. This guarantees that rmap
can always find the migration PTE even if it is copied while rmap_walk is
taking place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
