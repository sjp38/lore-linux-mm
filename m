Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 91A976B02A2
	for <linux-mm@kvack.org>; Mon, 10 May 2010 09:24:56 -0400 (EDT)
Date: Mon, 10 May 2010 14:24:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
	rmap_walk by guaranteeing rmap_walk finds PTEs created within the
	temporary stack
Message-ID: <20100510132431.GE26611@csn.ul.ie>
References: <1273188053-26029-3-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org> <20100507105712.18fc90c4.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org> <20100509192145.GI4859@csn.ul.ie> <alpine.LFD.2.00.1005091245000.3711@i5.linux-foundation.org> <20100510094050.8cb79143.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1005091827500.3711@i5.linux-foundation.org> <alpine.LFD.2.00.1005091831140.3711@i5.linux-foundation.org> <20100510104039.98332e67.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100510104039.98332e67.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 10, 2010 at 10:40:39AM +0900, KAMEZAWA Hiroyuki wrote:
> On Sun, 9 May 2010 18:32:32 -0700 (PDT)
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > 
> > 
> > On Sun, 9 May 2010, Linus Torvalds wrote:
> > > 
> > > So I never disliked that patch. I'm perfectly happy with a "don't migrate 
> > > these pages at all, because they are in a half-way state in the middle of 
> > > execve stack magic".
> > 
> > Btw, I also think that Mel's patch could be made a lot _less_ magic by 
> > just marking that initial stack vma with a VM_STACK_INCOMPLETE_SETUP bit, 
> > instead of doing that "maybe_stack" thing. We could easily make that 
> > initial vma setup very explicit indeed, and then just clear that bit when 
> > we've moved the stack to its final position.
> > 
> 
> Hmm. vm_flags is still 32bit..(I think it should be long long)
> 

This is why I didn't use a bit in vm_flags and I didn't want to increase
the size of any structure. I had thought of using a combination of flags
but thought people would prefer a test based on existing information such as
map_count. That said, I also made terrible choices for possible combination
of flags :)

> Using combination of existing flags...
> 
> #define VM_STACK_INCOMPLETE_SETUP (VM_RAND_READ | VM_SEC_READ)
> 
> Can be used instead of checking mapcount, I think.
> 

It can and this is a very good combination of flags to base the test on.
How does the following look?

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

This patch causes pages within the temporary stack during exec to be skipped
by migration. It does this by marking the VMA covering the temporary stack
with an otherwise impossible combination of VMA flags. These flags are
cleared when the temporary stack is moved to its final location.

[kamezawa.hiroyu@jp.fujitsu.com: Idea for identifying and skipping temporary stacks]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/exec.c          |    7 ++++++-
 include/linux/mm.h |    3 +++
 mm/rmap.c          |   30 +++++++++++++++++++++++++++++-
 3 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 725d7ef..13f8e7f 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -242,9 +242,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	 * use STACK_TOP because that can depend on attributes which aren't
 	 * configured yet.
 	 */
+	BUG_ON(VM_STACK_FLAGS & VM_STACK_INCOMPLETE_SETUP);
 	vma->vm_end = STACK_TOP_MAX;
 	vma->vm_start = vma->vm_end - PAGE_SIZE;
-	vma->vm_flags = VM_STACK_FLAGS;
+	vma->vm_flags = VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	err = insert_vm_struct(mm, vma);
@@ -616,6 +617,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	else if (executable_stack == EXSTACK_DISABLE_X)
 		vm_flags &= ~VM_EXEC;
 	vm_flags |= mm->def_flags;
+	vm_flags |= VM_STACK_INCOMPLETE_SETUP;
 
 	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
 			vm_flags);
@@ -630,6 +632,9 @@ int setup_arg_pages(struct linux_binprm *bprm,
 			goto out_unlock;
 	}
 
+	/* mprotect_fixup is overkill to remove the temporary stack flags */
+	vma->vm_flags &= ~VM_STACK_INCOMPLETE_SETUP;
+
 	stack_expand = 131072UL; /* randomly 32*4k (or 2*64k) pages */
 	stack_size = vma->vm_end - vma->vm_start;
 	/*
diff --git a/include/linux/mm.h b/include/linux/mm.h
index eb21256..925f5bc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -106,6 +106,9 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
+/* Bits set in the VMA until the stack is in its final location */
+#define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
+
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
 #endif
diff --git a/mm/rmap.c b/mm/rmap.c
index 85f203e..e96565f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1141,6 +1141,20 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	return ret;
 }
 
+static bool is_vma_temporary_stack(struct vm_area_struct *vma)
+{
+	int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);
+
+	if (!maybe_stack)
+		return false;
+
+	if ((vma->vm_flags & VM_STACK_INCOMPLETE_SETUP) ==
+						VM_STACK_INCOMPLETE_SETUP)
+		return true;
+
+	return false;
+}
+
 /**
  * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
  * rmap method
@@ -1169,7 +1183,21 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
