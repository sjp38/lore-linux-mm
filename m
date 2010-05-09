Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB1D6B0200
	for <linux-mm@kvack.org>; Sun,  9 May 2010 15:24:04 -0400 (EDT)
Date: Sun, 9 May 2010 20:23:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100509192343.GJ4859@csn.ul.ie>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-2-git-send-email-mel@csn.ul.ie> <20100508153922.GS5941@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100508153922.GS5941@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, May 08, 2010 at 05:39:22PM +0200, Andrea Arcangeli wrote:
> On Fri, May 07, 2010 at 12:20:52AM +0100, Mel Gorman wrote:
> > @@ -1655,6 +1655,7 @@ int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
> >  {
> >  	struct stable_node *stable_node;
> >  	struct hlist_node *hlist;
> > +	struct anon_vma *nested_anon_vma = NULL;
> >  	struct rmap_item *rmap_item;
> >  	int ret = SWAP_AGAIN;
> >  	int search_new_forks = 0;
> > @@ -1671,9 +1672,16 @@ again:
> >  		struct anon_vma_chain *vmac;
> >  		struct vm_area_struct *vma;
> >  
> > -		spin_lock(&anon_vma->lock);
> > +		anon_vma = anon_vma_lock_root(anon_vma);
> > +		if (nested_anon_vma) {
> > +			spin_unlock(&nested_anon_vma->lock);
> > +			nested_anon_vma = NULL;
> > +		}
> >  		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
> >  			vma = vmac->vma;
> > +			nested_anon_vma = anon_vma_lock_nested(nested_anon_vma,
> > +						vma->anon_vma, anon_vma);
> > +
> >  			if (rmap_item->address < vma->vm_start ||
> >  			    rmap_item->address >= vma->vm_end)
> >  				continue;
> > @@ -1368,19 +1444,26 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
> >  	 * are holding mmap_sem. Users without mmap_sem are required to
> >  	 * take a reference count to prevent the anon_vma disappearing
> >  	 */
> > -	anon_vma = page_anon_vma(page);
> > +	anon_vma = page_anon_vma_lock_root(page);
> >  	if (!anon_vma)
> >  		return ret;
> > -	spin_lock(&anon_vma->lock);
> >  	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
> >  		struct vm_area_struct *vma = avc->vma;
> > -		unsigned long address = vma_address(page, vma);
> > -		if (address == -EFAULT)
> > -			continue;
> > -		ret = rmap_one(page, vma, address, arg);
> > +		unsigned long address;
> > +
> > +		nested_anon_vma = anon_vma_lock_nested(nested_anon_vma,
> > +						vma->anon_vma, anon_vma);
> > +		address = vma_address(page, vma);
> > +		if (address != -EFAULT)
> > +			ret = rmap_one(page, vma, address, arg);
> > +
> >  		if (ret != SWAP_AGAIN)
> >  			break;
> >  	}
> > +
> > +	if (nested_anon_vma)
> > +		spin_unlock(&nested_anon_vma->lock);
> > +
> >  	spin_unlock(&anon_vma->lock);
> >  	return ret;
> >  }
> 
> I already told Mel by PM. This degrades the new-anon_vma code to an
> even _slower_ mode than the old anon-vma code in 2.6.32 (the same in
> math complexity terms but slower in practice) for migrate. Furthermore
> page_referenced() may now return true even if there are young ptes
> that simply get lost in the rmap walk.
> 

Yes, it does degrade it for migration but I don't consider that to be
the critical path at the moment. If it's important that it's faster,
then the thing to do is to take the anon_vma reference counting stuff
from Peter's patches, remove the RCU locking and always lock the root.

> The new anon-vma code is mostly relevant for migrate and memory
> compaction and transparent hugepage support where it gets invoked even
> if there's plenty of free memory and no I/O load at all. So whatever
> you save during swap, you'll lose while transparent hugepage support
> allocate the pages. So the above fix renders the whole effort
> pointless as far as I'm concerned.
> 

But this patch can be incrementally progressed to remove RCU and always
lock the root, right?

> I think Rik's patch is the only sensible solution that won't
> invalidate the whole effort for transparent hugepage.
> 

But it slows the mmap/munmap/etc patch right? And I don't recall seeing
a way that the cost of it could be reduced.

> About how to adapt split_huge_page to the root anon_vma I didn't even
> think about it yet. All I can tell you right now is that
> wait_split_huge_page can be changed to wait on the pmd_trans_splitting
> (or alternatively the pmd_trans_huge bit) bit to go away in a
> cpu_relax() barrier() loop. But the page->mapping/anon_vma->lock is
> also used to serialize against parallel split_huge_page but I guess
> taking the root anon_vma lock in split_huge_page() should work
> fine.

I would expect so. It would be preferable from your perspective to
always take the root lock on all paths but without the reference
counting, it requires RCU in the main paths.

> Just I'm not going to do that except maybe in a for-mainline
> branch, but I'll keep master branch with the old-anon-vma 2.6.32 code
> and the anon_vma_branch with Rik's fix that allows to take advantage
> of the new anon-vma code (so it's not purely gratuitous complexity
> added for nothing) also in migrate.c from memory compaction (that runs
> 24/7 on all my systems and it's much more frequent than the swap rmap
> walks that in fact never ever happens here), and in the rmap walks in
> split_huge_page too (which are not so frequent especially after
> Johannes implemented native mprotect on hugepages but it's obviously
> still more frequent than swap).
> 
> I'm simply not going to support the degradation to the root anon_vma
> complexity in aa.git, except for strict merging requirements but I'll
> keep backing it out in aa.git or I'd rather stick to old-anon-vma
> code which at least is much simpler and saves memory too (as there are
> many fewer anon-vma and no avc, and less useless locks).
> 
> What I instead already mentioned once was to add a _shared_ lock so
> you share the spinlock across the whole forest but you keep walking
> the right page->anon_vma->same_anon_vma!

Is the root lock not such a lock as long as it was always used?

> The moment you walk the
> page->anon_vma->root_anon_vma->same_anon_vma you lost my support as it
> makes the whole effort pointless compared to 2.6.32 as far as 99% of my
> workloads are concerned.
> 

Can we agree on this patch even? Even on it's own, I cannot reproduce
the migration-related problems racing with exec with this applied. Yes,
is adds some magic to exec, but the cost of exec remains the same.

==== CUT HERE ====
mm,migration: Avoid race between shift_arg_pages() and rmap_walk() during migration by not migrating temporary stacks

Page migration requires rmap to be able to find all ptes mapping a page
at all times, otherwise the migration entry can be instantiated, but it
is possible to leave one behind if the second rmap_walk fails to find
the page.  If this page is later faulted, migration_entry_to_page() will
call BUG because the page is locked indicating the page was migrated by
the migration PTE not cleaned up. For example

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

There is a race between shift_arg_pages and migration that triggers this bug.
A temporary stack is setup during exec and later moved. If migration moves
a page in the temporary stack and the VMA is then removed before migration
completes, the migration PTE may not be found leading to a BUG when the
stack is faulted.

Ideally, shift_arg_pages must run atomically with respect of rmap_walk
by holding the anon_vma lock but this is problematic as pages must be
allocated for page tables which cannot happen with a spinlock held. Instead,
this patch skips processes in exec by making an assumption that a VMA with
stack-flags set and a map_count == 1 is in exec that hasn't finalised the
temporary stack yet so don't migrate the pages. Memory hot-remove will try
again, sys_move_pages() wouldn't be operating during exec() time and memory
compaction will just continue to another page without concern.

[kamezawa.hiroyu@jp.fujitsu.com: Idea for having migration skip temporary stacks]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/rmap.c |   30 +++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index f95b66d..3bb6c9e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1143,6 +1143,20 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	return ret;
 }
 
+static bool is_vma_temporary_stack(struct vm_area_struct *vma)
+{
+	int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);
+
+	if (!maybe_stack)
+		return false;
+
+	/* If only the stack is mapped, assume exec is in progress */
+	if (vma->vm_mm->map_count == 1)
+		return true;
+
+	return false;
+}
+
 /**
  * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
  * rmap method
@@ -1171,7 +1185,21 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
+		unsigned long address;
+
+		/*
+		 * During exec, a temporary VMA is setup and later moved.
+		 * The VMA is moved under the anon_vma lock but not the
+		 * page tables leading to a race where migration cannot
+		 * find the migration ptes. Rather than increasing the
+		 * locking requirements of exec(), migration skips
+		 * temporary VMAs until after exec() completes.
+		 */
+		if (PAGE_MIGRATION && (flags & TTU_MIGRATION) &&
+				is_vma_temporary_stack(vma))
+			continue;
+
+		address = vma_address(page, vma);
 		if (address == -EFAULT)
 			continue;
 		ret = try_to_unmap_one(page, vma, address, flags);
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
