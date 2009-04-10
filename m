Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F37755F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 15:15:32 -0400 (EDT)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n3AJFfs4013486
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 20:15:42 +0100
Received: from wf-out-1314.google.com (wff28.prod.google.com [10.142.6.28])
	by zps75.corp.google.com with ESMTP id n3AJFLAd010941
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 12:15:40 -0700
Received: by wf-out-1314.google.com with SMTP id 28so1065817wff.17
        for <linux-mm@kvack.org>; Fri, 10 Apr 2009 12:15:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.0904100904250.4583@localhost.localdomain>
References: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com>
	 <20090409230205.310c68a7.akpm@linux-foundation.org>
	 <20090410073042.GB21149@localhost>
	 <alpine.LFD.2.00.0904100835150.4583@localhost.localdomain>
	 <alpine.LFD.2.00.0904100904250.4583@localhost.localdomain>
Date: Fri, 10 Apr 2009 12:15:39 -0700
Message-ID: <604427e00904101215j50288988mf694cfe70aa24e13@mail.gmail.com>
Subject: Re: [PATCH 2/2] Move FAULT_FLAG_xyz into handle_mm_fault() callers
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

2009/4/10 Linus Torvalds <torvalds@linux-foundation.org>:
>
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Fri, 10 Apr 2009 09:01:23 -0700
>
> This allows the callers to now pass down the full set of FAULT_FLAG_xyz
> flags to handle_mm_fault().  All callers have been (mechanically)
> converted to the new calling convention, there's almost certainly room
> for architectures to clean up their code and then add FAULT_FLAG_RETRY
> when that support is added.
>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>
> Again - untested. Not compiled. Might well rape your pets and just
> otherwise act badly. It's also a very mechanical conversion, ie I
> explicitly did
>
> -       fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, fsr & (1 << 11));
> +       fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, (fsr & (1 << 11)) ? FAULT_FLAG_WRITE : 0);
>
> rather than doing some cleanup while there.
>
> The point is, once we do this, now you really pass FAULT_FLAG_xyz
> everywhere, and now it's trivial to add FAULT_FLAG_RETRY without horribly
> ugly or hacky code.
>
> For example, before, I think Wu's code would have failed on ARM if
> FAULT_FLAG_RETRY just happened to be (1 << 11), because back when we
> passed in "zero or non-zero", ARM would literally pass in (1 << 11) or 0
> for "write_access".
>
> Now we explicitly pass in a nice FAULT_FLAG_WRITE or 0.
>
>  arch/alpha/mm/fault.c                   |    2 +-
>  arch/arm/mm/fault.c                     |    2 +-
>  arch/avr32/mm/fault.c                   |    2 +-
>  arch/cris/mm/fault.c                    |    2 +-
>  arch/frv/mm/fault.c                     |    2 +-
>  arch/ia64/mm/fault.c                    |    2 +-
>  arch/m32r/mm/fault.c                    |    2 +-
>  arch/m68k/mm/fault.c                    |    2 +-
>  arch/mips/mm/fault.c                    |    2 +-
>  arch/mn10300/mm/fault.c                 |    2 +-
>  arch/parisc/mm/fault.c                  |    2 +-
>  arch/powerpc/mm/fault.c                 |    2 +-
>  arch/powerpc/platforms/cell/spu_fault.c |    2 +-
>  arch/s390/lib/uaccess_pt.c              |    2 +-
>  arch/s390/mm/fault.c                    |    2 +-
>  arch/sh/mm/fault_32.c                   |    2 +-
>  arch/sh/mm/tlbflush_64.c                |    2 +-
>  arch/sparc/mm/fault_32.c                |    4 ++--
>  arch/sparc/mm/fault_64.c                |    2 +-
>  arch/um/kernel/trap.c                   |    2 +-
>  arch/x86/mm/fault.c                     |    2 +-
>  arch/xtensa/mm/fault.c                  |    2 +-
>  include/linux/mm.h                      |    4 ++--
>  mm/memory.c                             |    8 ++++----
>  24 files changed, 29 insertions(+), 29 deletions(-)
>
> diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
> index 4829f96..00a31de 100644
> --- a/arch/alpha/mm/fault.c
> +++ b/arch/alpha/mm/fault.c
> @@ -146,7 +146,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
>        /* If for any reason at all we couldn't handle the fault,
>           make sure we exit gracefully rather than endlessly redo
>           the fault.  */
> -       fault = handle_mm_fault(mm, vma, address, cause > 0);
> +       fault = handle_mm_fault(mm, vma, address, cause > 0 ? FAULT_FLAG_WRITE : 0);
>        up_read(&mm->mmap_sem);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
> diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
> index 0455557..6fdcbb7 100644
> --- a/arch/arm/mm/fault.c
> +++ b/arch/arm/mm/fault.c
> @@ -208,7 +208,7 @@ good_area:
>         * than endlessly redo the fault.
>         */
>  survive:
> -       fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, fsr & (1 << 11));
> +       fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, (fsr & (1 << 11)) ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
> index 62d4abb..b61d86d 100644
> --- a/arch/avr32/mm/fault.c
> +++ b/arch/avr32/mm/fault.c
> @@ -133,7 +133,7 @@ good_area:
>         * fault.
>         */
>  survive:
> -       fault = handle_mm_fault(mm, vma, address, writeaccess);
> +       fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
> index c4c76db..f925115 100644
> --- a/arch/cris/mm/fault.c
> +++ b/arch/cris/mm/fault.c
> @@ -163,7 +163,7 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
>         * the fault.
>         */
>
> -       fault = handle_mm_fault(mm, vma, address, writeaccess & 1);
> +       fault = handle_mm_fault(mm, vma, address, (writeaccess & 1) ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
> index 05093d4..30f5d10 100644
> --- a/arch/frv/mm/fault.c
> +++ b/arch/frv/mm/fault.c
> @@ -163,7 +163,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
>         * make sure we exit gracefully rather than endlessly redo
>         * the fault.
>         */
> -       fault = handle_mm_fault(mm, vma, ear0, write);
> +       fault = handle_mm_fault(mm, vma, ear0, write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
> index 23088be..19261a9 100644
> --- a/arch/ia64/mm/fault.c
> +++ b/arch/ia64/mm/fault.c
> @@ -154,7 +154,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
>         * sure we exit gracefully rather than endlessly redo the
>         * fault.
>         */
> -       fault = handle_mm_fault(mm, vma, address, (mask & VM_WRITE) != 0);
> +       fault = handle_mm_fault(mm, vma, address, (mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                /*
>                 * We ran out of memory, or some other thing happened
> diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
> index 4a71df4..7274b47 100644
> --- a/arch/m32r/mm/fault.c
> +++ b/arch/m32r/mm/fault.c
> @@ -196,7 +196,7 @@ survive:
>         */
>        addr = (address & PAGE_MASK);
>        set_thread_fault_code(error_code);
> -       fault = handle_mm_fault(mm, vma, addr, write);
> +       fault = handle_mm_fault(mm, vma, addr, write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
> index f493f03..d0e35cf 100644
> --- a/arch/m68k/mm/fault.c
> +++ b/arch/m68k/mm/fault.c
> @@ -155,7 +155,7 @@ good_area:
>         */
>
>  survive:
> -       fault = handle_mm_fault(mm, vma, address, write);
> +       fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
>  #ifdef DEBUG
>        printk("handle_mm_fault returns %d\n",fault);
>  #endif
> diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
> index 55767ad..6751ce9 100644
> --- a/arch/mips/mm/fault.c
> +++ b/arch/mips/mm/fault.c
> @@ -102,7 +102,7 @@ good_area:
>         * make sure we exit gracefully rather than endlessly redo
>         * the fault.
>         */
> -       fault = handle_mm_fault(mm, vma, address, write);
> +       fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
> index 33cf250..a62e1e1 100644
> --- a/arch/mn10300/mm/fault.c
> +++ b/arch/mn10300/mm/fault.c
> @@ -258,7 +258,7 @@ good_area:
>         * make sure we exit gracefully rather than endlessly redo
>         * the fault.
>         */
> -       fault = handle_mm_fault(mm, vma, address, write);
> +       fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
> index 92c7fa4..bfb6dd6 100644
> --- a/arch/parisc/mm/fault.c
> +++ b/arch/parisc/mm/fault.c
> @@ -202,7 +202,7 @@ good_area:
>         * fault.
>         */
>
> -       fault = handle_mm_fault(mm, vma, address, (acc_type & VM_WRITE) != 0);
> +       fault = handle_mm_fault(mm, vma, address, (acc_type & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                /*
>                 * We hit a shared mapping outside of the file, or some
> diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
> index 7699394..e2bf1ee 100644
> --- a/arch/powerpc/mm/fault.c
> +++ b/arch/powerpc/mm/fault.c
> @@ -299,7 +299,7 @@ good_area:
>         * the fault.
>         */
>  survive:
> -       ret = handle_mm_fault(mm, vma, address, is_write);
> +       ret = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(ret & VM_FAULT_ERROR)) {
>                if (ret & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/powerpc/platforms/cell/spu_fault.c b/arch/powerpc/platforms/cell/spu_fault.c
> index 95d8dad..d06ba87 100644
> --- a/arch/powerpc/platforms/cell/spu_fault.c
> +++ b/arch/powerpc/platforms/cell/spu_fault.c
> @@ -70,7 +70,7 @@ int spu_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
>        }
>
>        ret = 0;
> -       *flt = handle_mm_fault(mm, vma, ea, is_write);
> +       *flt = handle_mm_fault(mm, vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(*flt & VM_FAULT_ERROR)) {
>                if (*flt & VM_FAULT_OOM) {
>                        ret = -ENOMEM;
> diff --git a/arch/s390/lib/uaccess_pt.c b/arch/s390/lib/uaccess_pt.c
> index b0b84c3..cb5d59e 100644
> --- a/arch/s390/lib/uaccess_pt.c
> +++ b/arch/s390/lib/uaccess_pt.c
> @@ -66,7 +66,7 @@ static int __handle_fault(struct mm_struct *mm, unsigned long address,
>        }
>
>  survive:
> -       fault = handle_mm_fault(mm, vma, address, write_access);
> +       fault = handle_mm_fault(mm, vma, address, write_access ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
> index 833e836..31456fa 100644
> --- a/arch/s390/mm/fault.c
> +++ b/arch/s390/mm/fault.c
> @@ -351,7 +351,7 @@ good_area:
>         * make sure we exit gracefully rather than endlessly redo
>         * the fault.
>         */
> -       fault = handle_mm_fault(mm, vma, address, write);
> +       fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM) {
>                        up_read(&mm->mmap_sem);
> diff --git a/arch/sh/mm/fault_32.c b/arch/sh/mm/fault_32.c
> index 31a33eb..09ef52a 100644
> --- a/arch/sh/mm/fault_32.c
> +++ b/arch/sh/mm/fault_32.c
> @@ -133,7 +133,7 @@ good_area:
>         * the fault.
>         */
>  survive:
> -       fault = handle_mm_fault(mm, vma, address, writeaccess);
> +       fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/sh/mm/tlbflush_64.c b/arch/sh/mm/tlbflush_64.c
> index 7876997..fcbb6e1 100644
> --- a/arch/sh/mm/tlbflush_64.c
> +++ b/arch/sh/mm/tlbflush_64.c
> @@ -187,7 +187,7 @@ good_area:
>         * the fault.
>         */
>  survive:
> -       fault = handle_mm_fault(mm, vma, address, writeaccess);
> +       fault = handle_mm_fault(mm, vma, address, writeaccess ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
> index 12e447f..a5e30c6 100644
> --- a/arch/sparc/mm/fault_32.c
> +++ b/arch/sparc/mm/fault_32.c
> @@ -241,7 +241,7 @@ good_area:
>         * make sure we exit gracefully rather than endlessly redo
>         * the fault.
>         */
> -       fault = handle_mm_fault(mm, vma, address, write);
> +       fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> @@ -484,7 +484,7 @@ good_area:
>                if(!(vma->vm_flags & (VM_READ | VM_EXEC)))
>                        goto bad_area;
>        }
> -       switch (handle_mm_fault(mm, vma, address, write)) {
> +       switch (handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0)) {
>        case VM_FAULT_SIGBUS:
>        case VM_FAULT_OOM:
>                goto do_sigbus;
> diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
> index 4ab8993..e5620b2 100644
> --- a/arch/sparc/mm/fault_64.c
> +++ b/arch/sparc/mm/fault_64.c
> @@ -398,7 +398,7 @@ good_area:
>                        goto bad_area;
>        }
>
> -       fault = handle_mm_fault(mm, vma, address, (fault_code & FAULT_CODE_WRITE));
> +       fault = handle_mm_fault(mm, vma, address, (fault_code & FAULT_CODE_WRITE) ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
> index 7384d8a..637c650 100644
> --- a/arch/um/kernel/trap.c
> +++ b/arch/um/kernel/trap.c
> @@ -65,7 +65,7 @@ good_area:
>        do {
>                int fault;
>
> -               fault = handle_mm_fault(mm, vma, address, is_write);
> +               fault = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
>                if (unlikely(fault & VM_FAULT_ERROR)) {
>                        if (fault & VM_FAULT_OOM) {
>                                goto out_of_memory;
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index a03b727..65a07ba 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1130,7 +1130,7 @@ good_area:
>         * make sure we exit gracefully rather than endlessly redo
>         * the fault:
>         */
> -       fault = handle_mm_fault(mm, vma, address, write);
> +       fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
>
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                mm_fault_error(regs, error_code, address, fault);
> diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
> index bdd860d..bc07333 100644
> --- a/arch/xtensa/mm/fault.c
> +++ b/arch/xtensa/mm/fault.c
> @@ -106,7 +106,7 @@ good_area:
>         * the fault.
>         */
>  survive:
> -       fault = handle_mm_fault(mm, vma, address, is_write);
> +       fault = handle_mm_fault(mm, vma, address, is_write ? FAULT_FLAG_WRITE : 0);
>        if (unlikely(fault & VM_FAULT_ERROR)) {
>                if (fault & VM_FAULT_OOM)
>                        goto out_of_memory;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index bff1f0d..3f207d1 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -810,11 +810,11 @@ extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
>
>  #ifdef CONFIG_MMU
>  extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> -                       unsigned long address, int write_access);
> +                       unsigned long address, unsigned int flags);
>  #else
>  static inline int handle_mm_fault(struct mm_struct *mm,
>                        struct vm_area_struct *vma, unsigned long address,
> -                       int write_access)
> +                       unsigned int flags)
>  {
>        /* should never happen if there's no MMU */
>        BUG();
> diff --git a/mm/memory.c b/mm/memory.c
> index 9050bae..383dc0b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1310,8 +1310,9 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>                        cond_resched();
>                        while (!(page = follow_page(vma, start, foll_flags))) {
>                                int ret;
> -                               ret = handle_mm_fault(mm, vma, start,
> -                                               foll_flags & FOLL_WRITE);
> +
> +                               /* FOLL_WRITE matches FAULT_FLAG_WRITE! */
> +                               ret = handle_mm_fault(mm, vma, start, foll_flags & FOLL_WRITE);
>                                if (ret & VM_FAULT_ERROR) {
>                                        if (ret & VM_FAULT_OOM)
>                                                return i ? i : -ENOMEM;
> @@ -2864,13 +2865,12 @@ unlock:
>  * By the time we get here, we already hold the mm semaphore
>  */
>  int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> -               unsigned long address, int write_access)
> +               unsigned long address, unsigned int flags)
>  {
>        pgd_t *pgd;
>        pud_t *pud;
>        pmd_t *pmd;
>        pte_t *pte;
> -       unsigned int flags = write_access ? FAULT_FLAG_WRITE : 0;
>
>        __set_current_state(TASK_RUNNING);
>
> --
> 1.6.2.2.471.g6da14.dirty
>
>

How about something like this for x86? If it looks sane, i will apply
to other arches.

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 8bcb6f4..f3b6ee4 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -584,11 +584,12 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigne
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	unsigned long address;
-	int write, si_code;
+	int si_code;
 	int fault;
 #ifdef CONFIG_X86_64
 	unsigned long flags;
 #endif
+	unsigned int fault_flags |= FAULT_FLAG_RETRY;

 	/*
 	 * We can fault from pretty much anywhere, with unknown IRQ state.
@@ -722,14 +723,13 @@ again:
  */
 good_area:
 	si_code = SEGV_ACCERR;
-	write = 0;
 	switch (error_code & (PF_PROT|PF_WRITE)) {
 	default:	/* 3: write, present */
 		/* fall through */
 	case PF_WRITE:		/* write, not present */
 		if (!(vma->vm_flags & VM_WRITE))
 			goto bad_area;
-		write++;
+		fault_flags |= FAULT_FLAG_WRITE;
 		break;
 	case PF_PROT:		/* read, present */
 		goto bad_area;
@@ -746,7 +746,7 @@ survive:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, fault_flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
