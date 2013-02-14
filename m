Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 679486B0002
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 16:24:02 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id un1so322623pbc.26
        for <linux-mm@kvack.org>; Thu, 14 Feb 2013 13:24:01 -0800 (PST)
Date: Thu, 14 Feb 2013 13:24:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: Limit pgd range freeing to mm->task_size
In-Reply-To: <20130213134756.b90f8e1b.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1302141227500.1911@eggly.anvils>
References: <1360755569-27282-1-git-send-email-catalin.marinas@arm.com> <20130213134756.b90f8e1b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Russell King <linux@arm.linux.org.uk>

On Wed, 13 Feb 2013, Andrew Morton wrote:
> On Wed, 13 Feb 2013 11:39:29 +0000
> Catalin Marinas <catalin.marinas@arm.com> wrote:
> 
> > ARM processors with LPAE enabled use 3 levels of page tables, with an
> > entry in the top level (pgd) covering 1GB of virtual space. Because of
> > the branch relocation limitations on ARM, the loadable modules are
> > mapped 16MB below PAGE_OFFSET, making the corresponding 1GB pgd shared
> > between kernel modules and user space.
> > 
> > Since free_pgtables() is called with ceiling == 0, free_pgd_range() (and
> > subsequently called functions) also frees the page table
> > shared between user space and kernel modules (which is normally handled
> > by the ARM-specific pgd_free() function).
> > 
> > This patch changes the ceiling argument to mm->task_size for the
> > free_pgtables() and free_pgd_range() function calls. We cannot use
> > TASK_SIZE since this macro may not be a run-time constant on 64-bit
> > systems supporting compat applications.
> 
> I'm trying to work out why we're using 0 in there at all, rather than
> ->task_size.  But that's lost in the mists of time.
> 
> As you've discovered, handling of task_size and TASK_SIZE is somewhat
> inconsistent across architectures and with compat tasks.  I guess we
> toss it in there and see if anything breaks...

... and an x86_64 kernel quickly shows,
with either 64-bit or 32-bit userspace, that exit_mmap() breaks at
WARN_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);

We couldn't think of using mm->task_size in 2.6.12 because it didn't
exist then; but although it sounds plausible, and on many architectures
(x86_32?) it should be fine, in general it's not quite the right thing
to use.  0 is an easy rounded-up-whatever-the-increment version of
TASK_SIZE (okay, it's missing an implicit 1 before all its 0s).

The ceiling passed to free_pgtables() says how far up it can go in
freeing pts and pmds and puds and pgds: when doing munmap(), you have
to be careful not to stray beyond the range you're freeing; when doing
exit_mmap(), you have to be careful to free all the areas you might
have had to avoid before.

mm->task_size does not necessarily fall on a nice boundary: use it
instead of 0 and exit_mmap() is liable to leave unfreed page tables
at several levels.

I'm sure that Catalin is right that he needs to adjust that ceiling arg
to free_pgtables() to cope with a level shared between user and kernel.

I met the same problem two years ago, when doing a patch (which worked
but went nowhere: x86 people kept on changing the early pagetable setup)
to make CONFIG_VMSPLIT_2G_OPT and 3G_OPT compatible with CONFIG_X86_PAE.
That shared a level beween user and kernel too: everything could be
handled down in the arch code, except this free_pgtables() ceiling arg.

(I did not make any change to the free_pgd_range() calls in fs/exec.c,
I'm not familiar with those at all: my patch appeared to work fine
without touching them, but now I wonder.)

Here's the mm/mmap.c part of my patch (but it now looks like the
default should go into include/asm-generic):

--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -38,6 +38,16 @@
 
 #include "internal.h"
 
+/*
+ * On almost all architectures and configurations, 0 can be used as the
+ * upper ceiling to free_pgtables(): on many architectures it has the same
+ * effect as using TASK_SIZE.  However, there is one configuration which
+ * must impose a more careful limit, to avoid freeing kernel pgtables.
+ */
+#ifndef USER_PGTABLES_CEILING
+#define USER_PGTABLES_CEILING	0UL
+#endif
+
 #ifndef arch_mmap_check
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
@@ -1888,8 +1898,8 @@ static void unmap_region(struct mm_struct *mm,
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
-				 next? next->vm_start: 0);
+	free_pgtables(tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
+				 next ? next->vm_start : USER_PGTABLES_CEILING);
 	tlb_finish_mmu(tlb, start, end);
 }
 
@@ -2221,7 +2231,7 @@ void exit_mmap(struct mm_struct *mm)
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 
-	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
+	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(tlb, 0, end);
 	arch_flush_exec_range(mm);
 

Then arch/x86/include/asm/pgtable-3level_types.h had to
#define USER_PGTABLES_CEILING PAGE_OFFSET
in the special configuration.

In other words: to be safe, I believe you have to keep using 0 for the
ceiling on all the architectures and configurations that you're not
adding special new code to handle the user/kernel shared pagetables.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
