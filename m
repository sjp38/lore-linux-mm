Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D51556B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 07:48:28 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id r97so4200243lfi.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 04:48:28 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id w10si166962lfd.404.2016.07.26.04.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 04:48:26 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id 33so247404lfw.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 04:48:26 -0700 (PDT)
Date: Tue, 26 Jul 2016 14:48:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: correctly handle errors during VMA merging
Message-ID: <20160726114823.GC7370@node.shutemov.name>
References: <1469514843-23778-1-git-send-email-vegard.nossum@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469514843-23778-1-git-send-email-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Leon Yu <chianglungyu@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>

On Tue, Jul 26, 2016 at 08:34:03AM +0200, Vegard Nossum wrote:
> Using trinity + fault injection I've been running into this bug a lot:
> 
>     ==================================================================
>     BUG: KASAN: out-of-bounds in mprotect_fixup+0x523/0x5a0 at addr ffff8800b9e7d740
>     Read of size 8 by task trinity-c3/6338
>     =============================================================================
>     BUG vm_area_struct (Not tainted): kasan: bad access detected
>     -----------------------------------------------------------------------------
> 
>     Disabling lock debugging due to kernel taint
>     INFO: Allocated in copy_process.part.42+0x3ae7/0x52d0 age=13 cpu=0 pid=23703
>             ___slab_alloc+0x480/0x4b0
>             __slab_alloc.isra.53+0x56/0x80
>             kmem_cache_alloc+0x22d/0x270
>             copy_process.part.42+0x3ae7/0x52d0
>             _do_fork+0x16d/0x8e0
>             SyS_clone+0x14/0x20
>             do_syscall_64+0x19c/0x410
>             return_from_SYSCALL_64+0x0/0x6a
>     INFO: Freed in vma_adjust+0xab7/0x1740 age=25 cpu=1 pid=6338
>             __slab_free+0x17a/0x250
>             kmem_cache_free+0x20f/0x220
>             remove_vma+0x12e/0x170
>             exit_mmap+0x265/0x3c0
>             mmput+0x77/0x170
>             do_exit+0x636/0x2b80
>             do_group_exit+0xe2/0x2d0
>             get_signal+0x4be/0x1000
>             do_signal+0x83/0x1f10
>             exit_to_usermode_loop+0xa2/0x120
>             syscall_return_slowpath+0x13f/0x170
>             ret_from_fork+0x2f/0x40
> 
>     CPU: 1 PID: 6338 Comm: trinity-c3 Tainted: G    B           4.7.0-rc7+ #45
>     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
>      ffffea0002e79f00 ffff88011887fc60 ffffffff81aa58b1 ffff88011a816400
>      ffff8800b9e7d740 ffff88011887fc90 ffffffff8142c54d ffff88011a816400
>      ffffea0002e79f00 ffff8800b9e7d740 0000000000000000 ffff88011887fcb8
>     Call Trace:
>      [<ffffffff81aa58b1>] dump_stack+0x65/0x84
>      [<ffffffff8142c54d>] print_trailer+0x10d/0x1a0
>      [<ffffffff8142fe5f>] object_err+0x2f/0x40
>      [<ffffffff81434ab1>] kasan_report_error+0x221/0x520
>      [<ffffffff81434eee>] __asan_report_load8_noabort+0x3e/0x40
>      [<ffffffff813e88f3>] mprotect_fixup+0x523/0x5a0
>      [<ffffffff813e8e34>] SyS_mprotect+0x4c4/0xa10
>      [<ffffffff8100534c>] do_syscall_64+0x19c/0x410
>      [<ffffffff83515d65>] entry_SYSCALL64_slow_path+0x25/0x25
> 
> followed shortly by assertion errors and/or other bugs due to memory
> corruption.
> 
> What's happening is that we're doing an mprotect() on a range that spans
> three existing adjacent mappings. The first two are merged fine, but if
> we merge the last one and anon_vma_clone() runs out of memory, we return
> an error and mprotect_fixup() tries to use the (now stale) pointer. It
> goes like this:
> 
>     SyS_mprotect()
>       - mprotect_fixup()
>          - vma_merge()
>             - vma_adjust()
>                // first merge
>                - kmem_cache_free(vma)
>                - goto again;
>                // second merge
>                - anon_vma_clone()
>                   - kmem_cache_alloc()
>                      - return NULL
>                   - kmem_cache_alloc()
>                      - return NULL
>                   - return -ENOMEM
>                - return -ENOMEM
>             - return NULL
>          - vma->vm_start // use-after-free
> 
> In other words, it is possible to run into a memory allocation error
> *after* part of the merging work has already been done. In this case,
> we probably shouldn't return an error back to userspace anyway (since
> it would not reflect the partial work that was done).
> 
> I *think* the solution might be to simply ignore the errors from
> vma_adjust() and carry on with distinct VMAs for adjacent regions that
> might otherwise have been represented with a single VMA.
> 
> I have a reproducer that runs into the bug within a few seconds when
> fault injection is enabled -- with the patch I no longer see any
> problems.
> 
> The patch and resulting code admittedly look odd and I'm *far* from
> an expert on mm internals, so feel free to propose counter-patches and
> I can give the reproducer a spin.

Could you give this a try (barely tested):

diff --git a/mm/mmap.c b/mm/mmap.c
index a384c10c7657..58c10191c3d6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -621,7 +621,6 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *next = vma->vm_next;
-	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
 	struct rb_root *root = NULL;
 	struct anon_vma *anon_vma = NULL;
@@ -632,16 +631,23 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL;
+		struct vm_area_struct *importer = NULL, *importer2 = NULL;
 
 		if (end >= next->vm_end) {
 			/*
 			 * vma expands, overlapping all the next, and
 			 * perhaps the one after too (mprotect case 6).
 			 */
-again:			remove_next = 1 + (end > next->vm_end);
+			remove_next = 1 + (end > next->vm_end);
 			end = next->vm_end;
 			exporter = next;
 			importer = vma;
+			if (remove_next == 2 &&
+					exporter && !exporter->anon_vma) {
+				exporter = next->vm_next;
+				importer2 = next;
+			}
+
 		} else if (end > next->vm_start) {
 			/*
 			 * vma expands, overlapping part of the next:
@@ -673,9 +679,19 @@ again:			remove_next = 1 + (end > next->vm_end);
 			error = anon_vma_clone(importer, exporter);
 			if (error)
 				return error;
+			if (importer2) {
+				importer2->anon_vma = exporter->anon_vma;
+				error = anon_vma_clone(importer2, exporter);
+				if (error) {
+					/* undo first anon_vma_clone() */
+					importer->anon_vma = NULL;
+					unlink_anon_vmas(importer);
+					return error;
+				}
+			}
 		}
 	}
-
+again:
 	vma_adjust_trans_huge(vma, start, end, adjust_next);
 
 	if (file) {
@@ -796,8 +812,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 		 * up the code too much to do both in one go.
 		 */
 		next = vma->vm_next;
-		if (remove_next == 2)
+		if (remove_next == 2) {
+			remove_next = 1;
+			end = next->vm_end;
 			goto again;
+		}
 		else if (next)
 			vma_gap_update(next);
 		else
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
