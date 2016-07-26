Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 906486B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 02:34:13 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id f6so1206728ith.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:34:13 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n75si19975688itb.84.2016.07.25.23.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 23:34:12 -0700 (PDT)
From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] mm: correctly handle errors during VMA merging
Date: Tue, 26 Jul 2016 08:34:03 +0200
Message-Id: <1469514843-23778-1-git-send-email-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vegard Nossum <vegard.nossum@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Leon Yu <chianglungyu@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>

Using trinity + fault injection I've been running into this bug a lot:

    ==================================================================
    BUG: KASAN: out-of-bounds in mprotect_fixup+0x523/0x5a0 at addr ffff8800b9e7d740
    Read of size 8 by task trinity-c3/6338
    =============================================================================
    BUG vm_area_struct (Not tainted): kasan: bad access detected
    -----------------------------------------------------------------------------

    Disabling lock debugging due to kernel taint
    INFO: Allocated in copy_process.part.42+0x3ae7/0x52d0 age=13 cpu=0 pid=23703
            ___slab_alloc+0x480/0x4b0
            __slab_alloc.isra.53+0x56/0x80
            kmem_cache_alloc+0x22d/0x270
            copy_process.part.42+0x3ae7/0x52d0
            _do_fork+0x16d/0x8e0
            SyS_clone+0x14/0x20
            do_syscall_64+0x19c/0x410
            return_from_SYSCALL_64+0x0/0x6a
    INFO: Freed in vma_adjust+0xab7/0x1740 age=25 cpu=1 pid=6338
            __slab_free+0x17a/0x250
            kmem_cache_free+0x20f/0x220
            remove_vma+0x12e/0x170
            exit_mmap+0x265/0x3c0
            mmput+0x77/0x170
            do_exit+0x636/0x2b80
            do_group_exit+0xe2/0x2d0
            get_signal+0x4be/0x1000
            do_signal+0x83/0x1f10
            exit_to_usermode_loop+0xa2/0x120
            syscall_return_slowpath+0x13f/0x170
            ret_from_fork+0x2f/0x40

    CPU: 1 PID: 6338 Comm: trinity-c3 Tainted: G    B           4.7.0-rc7+ #45
    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
     ffffea0002e79f00 ffff88011887fc60 ffffffff81aa58b1 ffff88011a816400
     ffff8800b9e7d740 ffff88011887fc90 ffffffff8142c54d ffff88011a816400
     ffffea0002e79f00 ffff8800b9e7d740 0000000000000000 ffff88011887fcb8
    Call Trace:
     [<ffffffff81aa58b1>] dump_stack+0x65/0x84
     [<ffffffff8142c54d>] print_trailer+0x10d/0x1a0
     [<ffffffff8142fe5f>] object_err+0x2f/0x40
     [<ffffffff81434ab1>] kasan_report_error+0x221/0x520
     [<ffffffff81434eee>] __asan_report_load8_noabort+0x3e/0x40
     [<ffffffff813e88f3>] mprotect_fixup+0x523/0x5a0
     [<ffffffff813e8e34>] SyS_mprotect+0x4c4/0xa10
     [<ffffffff8100534c>] do_syscall_64+0x19c/0x410
     [<ffffffff83515d65>] entry_SYSCALL64_slow_path+0x25/0x25

followed shortly by assertion errors and/or other bugs due to memory
corruption.

What's happening is that we're doing an mprotect() on a range that spans
three existing adjacent mappings. The first two are merged fine, but if
we merge the last one and anon_vma_clone() runs out of memory, we return
an error and mprotect_fixup() tries to use the (now stale) pointer. It
goes like this:

    SyS_mprotect()
      - mprotect_fixup()
         - vma_merge()
            - vma_adjust()
               // first merge
               - kmem_cache_free(vma)
               - goto again;
               // second merge
               - anon_vma_clone()
                  - kmem_cache_alloc()
                     - return NULL
                  - kmem_cache_alloc()
                     - return NULL
                  - return -ENOMEM
               - return -ENOMEM
            - return NULL
         - vma->vm_start // use-after-free

In other words, it is possible to run into a memory allocation error
*after* part of the merging work has already been done. In this case,
we probably shouldn't return an error back to userspace anyway (since
it would not reflect the partial work that was done).

I *think* the solution might be to simply ignore the errors from
vma_adjust() and carry on with distinct VMAs for adjacent regions that
might otherwise have been represented with a single VMA.

I have a reproducer that runs into the bug within a few seconds when
fault injection is enabled -- with the patch I no longer see any
problems.

The patch and resulting code admittedly look odd and I'm *far* from
an expert on mm internals, so feel free to propose counter-patches and
I can give the reproducer a spin.

There's also a question about what to do with __split_vma() and other
callers of vma_adjust(). This crash (without my patch) only appeared
once and it looks kinda related, but I haven't really looked into it
and could be something else entirely:

    ------------[ cut here ]------------
    kernel BUG at mm/mmap.c:591!
    invalid opcode: 0000 [#1] PREEMPT SMP KASAN
    CPU: 0 PID: 3354 Comm: trinity-c1 Not tainted 4.7.0-rc7+ #37
    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
    task: ffff8800b89a8dc0 ti: ffff8800b8b20000 task.ti: ffff8800b8b20000
    RIP: 0010:[<ffffffff8134860a>]  [<ffffffff8134860a>] vma_adjust+0xe9a/0x1390
    RSP: 0018:ffff8800b8b27c60  EFLAGS: 00010206
    RAX: 1ffff10017014364 RBX: ffff8800b89c1930 RCX: 1ffff10017174cc5
    RDX: dffffc0000000000 RSI: 00007f1774fe8000 RDI: ffff8800b80a1b28
    RBP: ffff8800b8b27d08 R08: ffff8800bad5b660 R09: ffff8801190eafa0
    R10: 00007f1775ff7000 R11: ffff8800b8ba65d0 R12: ffff8800b89c0f80
    R13: ffff8800b80a1b40 R14: ffff8800b80a1b20 R15: ffff8801190eafa0
    FS:  00007f1776bfa700(0000) GS:ffff88011ae00000(0000) knlGS:0000000000000000
    CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
    CR2: 000000000066a3ac CR3: 00000000b807f000 CR4: 00000000000006f0
    Stack:
     0000000000000286 00000000024000c0 00000000ffffffff ffff8800b89c0f90
     000fffffffffee02 ffff8800b89c0f88 ffff8800bad5b640 00007f1774df7000
     ffff8800bb840000 00000000000100c0 ffff8800b809d500 00007f1774fe8000
    Call Trace:
     [<ffffffff81348f04>] __split_vma.isra.34+0x404/0x730
     [<ffffffff8134bd8f>] split_vma+0x7f/0xc0
     [<ffffffff813542d8>] mprotect_fixup+0x3e8/0x5a0
     [<ffffffff81354827>] SyS_mprotect+0x397/0x790
     [<ffffffff81354490>] ? mprotect_fixup+0x5a0/0x5a0
     [<ffffffff81002d27>] ? syscall_trace_enter_phase2+0x227/0x3e0
     [<ffffffff81354490>] ? mprotect_fixup+0x5a0/0x5a0
     [<ffffffff8100334c>] do_syscall_64+0x19c/0x410
     [<ffffffff812c0e88>] ? context_tracking_enter+0x18/0x20
     [<ffffffff83296525>] entry_SYSCALL64_slow_path+0x25/0x25
    Code: 39 d0 48 0f 42 c2 49 8d 7d 18 48 89 fa 48 c1 ea 03 42 80 3c 32 00 0f 85 b8 01 00 00 49 39 45 18 0f 85 e9 fe ff ff e9 a6 fc ff ff <0f> 0b 48 8d 7b 08 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1
    RIP  [<ffffffff8134860a>] vma_adjust+0xe9a/0x1390
     RSP <ffff8800b8b27c60>
    ---[ end trace 49ee508a1e48b42d ]---

Reference: http://marc.info/?l=linux-mm&m=146935829205267&w=2
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Leon Yu <chianglungyu@gmail.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 mm/mmap.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index de2c176..aff328e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -937,7 +937,6 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
-	int err;
 
 	/*
 	 * We later require that vma->vm_flags == vm_flags,
@@ -974,13 +973,11 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 				is_mergeable_anon_vma(prev->anon_vma,
 						      next->anon_vma, NULL)) {
 							/* cases 1, 6 */
-			err = vma_adjust(prev, prev->vm_start,
+			vma_adjust(prev, prev->vm_start,
 				next->vm_end, prev->vm_pgoff, NULL);
 		} else					/* cases 2, 5, 7 */
-			err = vma_adjust(prev, prev->vm_start,
+			vma_adjust(prev, prev->vm_start,
 				end, prev->vm_pgoff, NULL);
-		if (err)
-			return NULL;
 		khugepaged_enter_vma_merge(prev, vm_flags);
 		return prev;
 	}
@@ -994,13 +991,11 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 					     anon_vma, file, pgoff+pglen,
 					     vm_userfaultfd_ctx)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
-			err = vma_adjust(prev, prev->vm_start,
+			vma_adjust(prev, prev->vm_start,
 				addr, prev->vm_pgoff, NULL);
 		else					/* cases 3, 8 */
-			err = vma_adjust(area, addr, next->vm_end,
+			vma_adjust(area, addr, next->vm_end,
 				next->vm_pgoff - pglen, NULL);
-		if (err)
-			return NULL;
 		khugepaged_enter_vma_merge(area, vm_flags);
 		return area;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
