Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DCE2B6B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 07:42:28 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so9842633pad.24
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 04:42:28 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id cv2si17326856pbc.135.2014.08.04.04.42.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 04:42:27 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so9428700pdj.8
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 04:42:27 -0700 (PDT)
Date: Mon, 4 Aug 2014 04:40:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: BUG in unmap_page_range
In-Reply-To: <53DD5F20.8010507@oracle.com>
Message-ID: <alpine.LSU.2.11.1408040418500.3406@eggly.anvils>
References: <53DD5F20.8010507@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Sat, 2 Aug 2014, Sasha Levin wrote:

> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel, I've stumbled on the following spew:
> 
> [ 2957.087977] BUG: unable to handle kernel paging request at ffffea0003480008
> [ 2957.088008] IP: unmap_page_range (mm/memory.c:1132 mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301)
> [ 2957.088024] PGD 7fffc6067 PUD 7fffc5067 PMD 0
> [ 2957.088041] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 2957.088087] Dumping ftrace buffer:
> [ 2957.088266]    (ftrace buffer empty)
> [ 2957.088279] Modules linked in:
> [ 2957.088293] CPU: 2 PID: 15417 Comm: trinity-c200 Not tainted 3.16.0-rc7-next-20140801-sasha-00047-gd6ce559 #990
> [ 2957.088301] task: ffff8807a8c50000 ti: ffff880739fb4000 task.ti: ffff880739fb4000
> [ 2957.088320] RIP: unmap_page_range (mm/memory.c:1132 mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1301)
> [ 2957.088328] RSP: 0018:ffff880739fb7c58  EFLAGS: 00010246
> [ 2957.088336] RAX: 0000000000000000 RBX: ffff880eb2bdbed8 RCX: dfff971b42800000
> [ 2957.088343] RDX: 1ffff100e73f6fc4 RSI: 00007f00e85db000 RDI: ffffea0003480008
> [ 2957.088350] RBP: ffff880739fb7d58 R08: 0000000000000001 R09: 0000000000b6e000
> [ 2957.088357] R10: 0000000000000000 R11: 0000000000000001 R12: ffffea0003480000
> [ 2957.088365] R13: 00000000d2000700 R14: 00007f00e85dc000 R15: 00007f00e85db000
> [ 2957.088374] FS:  00007f00e85d8700(0000) GS:ffff88177fa00000(0000) knlGS:0000000000000000
> [ 2957.088381] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 2957.088387] CR2: ffffea0003480008 CR3: 00000007a802a000 CR4: 00000000000006a0
> [ 2957.088406] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 2957.088413] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [ 2957.088416] Stack:
> [ 2957.088432]  ffff88171726d570 0000000000000010 0000000000000008 00000000d2000730
> [ 2957.088450]  0000000019d00250 00007f00e85dc000 ffff880f9d311900 ffff880739fb7e20
> [ 2957.088466]  ffff8807a8c507a0 ffff8807a8c50000 ffff8807a75fe000 ffff8807ceaa7a10
> [ 2957.088469] Call Trace:
> [ 2957.088490] unmap_single_vma (mm/memory.c:1348)
> [ 2957.088505] unmap_vmas (mm/memory.c:1375 (discriminator 3))
> [ 2957.088520] unmap_region (mm/mmap.c:2386 (discriminator 4))
> [ 2957.088542] ? vma_rb_erase (mm/mmap.c:454 include/linux/rbtree_augmented.h:219 include/linux/rbtree_augmented.h:227 mm/mmap.c:493)
> [ 2957.088559] ? vmacache_update (mm/vmacache.c:61)
> [ 2957.088572] do_munmap (mm/mmap.c:2581)
> [ 2957.088583] vm_munmap (mm/mmap.c:2596)
> [ 2957.088595] SyS_munmap (mm/mmap.c:2601)
> [ 2957.088616] tracesys (arch/x86/kernel/entry_64.S:541)
> [ 2957.088770] Code: ff ff e8 f9 5f 07 00 48 8b 45 90 80 48 18 01 4d 85 e4 0f 84 8b fe ff ff 45 84 ed 0f 85 fc 03 00 00 49 8d 7c 24 08 e8 b5 67 07 00 <41> f6 44 24 08 01 0f 84 29 02 00 00 83 6d c8 01 4c 89 e7 e8 bd
> All code
> ========
>    0:	ff                   	(bad)
>    1:	ff e8                	ljmpq  *<internal disassembler error>
>    3:	f9                   	stc
>    4:	5f                   	pop    %rdi
>    5:	07                   	(bad)
>    6:	00 48 8b             	add    %cl,-0x75(%rax)
>    9:	45 90                	rex.RB xchg %eax,%r8d
>    b:	80 48 18 01          	orb    $0x1,0x18(%rax)
>    f:	4d 85 e4             	test   %r12,%r12
>   12:	0f 84 8b fe ff ff    	je     0xfffffffffffffea3
>   18:	45 84 ed             	test   %r13b,%r13b
>   1b:	0f 85 fc 03 00 00    	jne    0x41d
>   21:	49 8d 7c 24 08       	lea    0x8(%r12),%rdi
>   26:	e8 b5 67 07 00       	callq  0x767e0
>   2b:*	41 f6 44 24 08 01    	testb  $0x1,0x8(%r12)		<-- trapping instruction
>   31:	0f 84 29 02 00 00    	je     0x260
>   37:	83 6d c8 01          	subl   $0x1,-0x38(%rbp)
>   3b:	4c 89 e7             	mov    %r12,%rdi
>   3e:	e8                   	.byte 0xe8
>   3f:	bd                   	.byte 0xbd

This differs in which functions got inlined (unmap_page_range showing up
in place of zap_pte_range), but this is the same "if (PageAnon(page))"
that Sasha reported in the "hang in shmem_fallocate" thread on June 26th.

I can see what it is now, and here is most of a patch (which I don't
expect to satisfy Trinity yet); at this point I think I had better
hand it over to Mel, to complete or to discard.

[INCOMPLETE PATCH] x86,mm: fix pte_special versus pte_numa

Sasha Levin has shown oopses on ffffea0003480048 and ffffea0003480008
at mm/memory.c:1132, running Trinity on different 3.16-rc-next kernels:
where zap_pte_range() checks page->mapping to see if PageAnon(page).

Those addresses fit struct pages for pfns d2001 and d2000, and in each
dump a register or a stack slot showed d2001730 or d2000730: pte flags
0x730 are PCD ACCESSED PROTNONE SPECIAL IOMAP; and Sasha's e820 map has
a hole between cfffffff and 100000000, which would need special access.

Commit c46a7c817e66 ("x86: define _PAGE_NUMA by reusing software bits on
the PMD and PTE levels") has broken vm_normal_page(): a PROTNONE SPECIAL
pte no longer passes the pte_special() test, so zap_pte_range() goes on
to try to access a non-existent struct page.

Fix this by refining pte_special() (SPECIAL with PRESENT or PROTNONE)
to complement pte_numa() (SPECIAL with neither PRESENT nor PROTNONE).

It's unclear why c46a7c817e66 added pte_numa() test to vm_normal_page(),
and moved its is_zero_pfn() test from slow to fast path: I suspect both
were papering over PROT_NONE issues seen with inadequate pte_special().
Revert vm_normal_page() to how it was before, relying on pte_special().

I find it confusing, that the only example of ARCH_USES_NUMA_PROT_NONE
no longer uses PROTNONE for NUMA, but SPECIAL instead: update the
asm-generic comment a little, but that config option remains unhelpful.

But more seriously, I think this patch is incomplete: aren't there
other places which need to be handling PROTNONE along with PRESENT?
For example, pte_mknuma() clears _PAGE_PRESENT and sets _PAGE_NUMA,
but on a PROT_NONE area, I think that will now make it pte_special()?
So it ought to clear _PAGE_PROTNONE too.  Or maybe we can never
pte_mknuma() on a PROT_NONE area - there would be no point?

Around here I began to wonder if it was just a mistake to have deserted
the PROTNONE for NUMA model: I know Linus had a strong reaction against
it, and I've never delved into its drawbacks myself; but bringing yet
another (SPECIAL) flag into the game is not an obvious improvement.
Should we just revert c46a7c817e66, or would that be a mistake?

Let me hand this over to Mel now...

Partially-Fixes: c46a7c817e66 ("x86: define _PAGE_NUMA by reusing software bits on the PMD and PTE levels")
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Not-yet-Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org [3.16]
---

 arch/x86/include/asm/pgtable.h |    9 +++++++--
 include/asm-generic/pgtable.h  |    6 +++---
 mm/memory.c                    |    7 +++----
 3 files changed, 13 insertions(+), 9 deletions(-)

--- v3.16/arch/x86/include/asm/pgtable.h	2014-08-03 15:25:02.000000000 -0700
+++ linux/arch/x86/include/asm/pgtable.h	2014-08-03 17:36:02.364552987 -0700
@@ -131,8 +131,13 @@ static inline int pte_exec(pte_t pte)
 
 static inline int pte_special(pte_t pte)
 {
-	return (pte_flags(pte) & (_PAGE_PRESENT|_PAGE_SPECIAL)) ==
-				 (_PAGE_PRESENT|_PAGE_SPECIAL);
+	/*
+	 * See CONFIG_NUMA_BALANCING CONFIG_ARCH_USES_NUMA_PROT_NONE pte_numa()
+	 * in include/asm-generic/pgtable.h: on x86 we have _PAGE_BIT_NUMA ==
+	 * _PAGE_BIT_GLOBAL+1 == __PAGE_BIT_SOFTW1 == _PAGE_BIT_SPECIAL.
+	 */
+	return (pte_flags(pte) & _PAGE_SPECIAL) &&
+		(pte_flags(pte) & (_PAGE_PRESENT|_PAGE_PROTNONE));
 }
 
 static inline unsigned long pte_pfn(pte_t pte)
--- v3.16/include/asm-generic/pgtable.h	2014-08-03 15:25:02.000000000 -0700
+++ linux/include/asm-generic/pgtable.h	2014-08-03 17:36:02.364552987 -0700
@@ -662,9 +662,9 @@ static inline int pmd_trans_unstable(pmd
 #ifdef CONFIG_NUMA_BALANCING
 #ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
 /*
- * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
- * same bit too). It's set only when _PAGE_PRESET is not set and it's
- * never set if _PAGE_PRESENT is set.
+ * _PAGE_NUMA works identically to _PAGE_PROTNONE.
+ * It is set only when neither _PAGE_PRESENT nor _PAGE_PROTNONE is set.
+ * This allows it to share a bit set only when present e.g. _PAGE_SPECIAL.
  *
  * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
  * fault triggers on those regions if pte/pmd_numa returns true
--- v3.16/mm/memory.c	2014-08-03 15:25:02.000000000 -0700
+++ linux/mm/memory.c	2014-08-03 17:36:02.368552987 -0700
@@ -751,7 +751,7 @@ struct page *vm_normal_page(struct vm_ar
 	unsigned long pfn = pte_pfn(pte);
 
 	if (HAVE_PTE_SPECIAL) {
-		if (likely(!pte_special(pte) || pte_numa(pte)))
+		if (likely(!pte_special(pte)))
 			goto check_pfn;
 		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
@@ -777,15 +777,14 @@ struct page *vm_normal_page(struct vm_ar
 		}
 	}
 
+	if (is_zero_pfn(pfn))
+		return NULL;
 check_pfn:
 	if (unlikely(pfn > highest_memmap_pfn)) {
 		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
 
-	if (is_zero_pfn(pfn))
-		return NULL;
-
 	/*
 	 * NOTE! We still have PageReserved() pages in the page tables.
 	 * eg. VDSO mappings can cause them to exist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
