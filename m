Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC8E828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 16:02:08 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id q21so265407378iod.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 13:02:08 -0800 (PST)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id z6si2979505igl.20.2016.01.07.13.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 13:02:07 -0800 (PST)
Received: by mail-io0-x232.google.com with SMTP id q21so265406959iod.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 13:02:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160107000148.ED5D13DF@viggo.jf.intel.com>
References: <20160107000104.1A105322@viggo.jf.intel.com>
	<20160107000148.ED5D13DF@viggo.jf.intel.com>
Date: Thu, 7 Jan 2016 13:02:06 -0800
Message-ID: <CAGXu5jJx=EMnnGX4k8ZQSnsPV+4zQXGfC+3KF_qAWJVArt8M2Q@mail.gmail.com>
Subject: Re: [PATCH 31/31] x86, pkeys: execute-only support
From: Kees Cook <keescook@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On Wed, Jan 6, 2016 at 4:01 PM, Dave Hansen <dave@sr71.net> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> Protection keys provide new page-based protection in hardware.
> But, they have an interesting attribute: they only affect data
> accesses and never affect instruction fetches.  That means that
> if we set up some memory which is set as "access-disabled" via
> protection keys, we can still execute from it.
>
> This patch uses protection keys to set up mappings to do just that.
> If a user calls:
>
>         mmap(..., PROT_EXEC);
> or
>         mprotect(ptr, sz, PROT_EXEC);
>
> (note PROT_EXEC-only without PROT_READ/WRITE), the kernel will
> notice this, and set a special protection key on the memory.  It
> also sets the appropriate bits in the Protection Keys User Rights
> (PKRU) register so that the memory becomes unreadable and
> unwritable.
>
> I haven't found any userspace that does this today.  With this
> facility in place, we expect userspace to move to use it
> eventually.

And the magic benefit here is that linker/loaders can switch to just
PROT_EXEC without PROT_READ, and everything that doesn't support this
protection will silently include PROT_READ, so no runtime detection by
the loader is needed.

> The security provided by this approach is not comprehensive.  The

Perhaps specifically mention what it does provide, which would be
protection against leaking executable memory contents, as generally
done by attackers who are attempting to find ROP gadgets on the fly.

-Kees

> PKRU register which controls access permissions is a normal
> user register writable from unprivileged userspace.  An attacker
> who can execute the 'wrpkru' instruction can easily disable the
> protection provided by this feature.
>
> The protection key that is used for execute-only support is
> permanently dedicated at compile time.  This is fine for now
> because there is currently no API to set a protection key other
> than this one.
>
> Despite there being a constant PKRU value across the entire
> system, we do not set it unless this feature is in use in a
> process.  That is to preserve the PKRU XSAVE 'init state',
> which can lead to faster context switches.
>
> PKRU *is* a user register and the kernel is modifying it.  That
> means that code doing:
>
>         pkru = rdpkru()
>         pkru |= 0x100;
>         mmap(..., PROT_EXEC);
>         wrpkru(pkru);
>
> could lose the bits in PKRU that enforce execute-only
> permissions.  To avoid this, we suggest avoiding ever calling
> mmap() or mprotect() when the PKRU value is expected to be
> stable.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: LKML <linux-kernel@vger.kernel.org>
> Cc: x86@kernel.org
> Cc: torvalds@linux-foundation.org
> Cc: akpm@linux-foundation.org
> Cc: linux-mm@kvack.org
> Cc: keescook@google.com
> Cc: luto@amacapital.net
> ---
>
>  b/arch/x86/include/asm/pkeys.h |   25 ++++++++++
>  b/arch/x86/kernel/fpu/xstate.c |    2
>  b/arch/x86/mm/Makefile         |    2
>  b/arch/x86/mm/fault.c          |   13 +++++
>  b/arch/x86/mm/pkeys.c          |  101 +++++++++++++++++++++++++++++++++++++++++
>  b/include/linux/pkeys.h        |    3 +
>  b/mm/mmap.c                    |   10 +++-
>  b/mm/mprotect.c                |    8 +--
>  8 files changed, 157 insertions(+), 7 deletions(-)
>
> diff -puN arch/x86/include/asm/pkeys.h~pkeys-79-xonly arch/x86/include/asm/pkeys.h
> --- a/arch/x86/include/asm/pkeys.h~pkeys-79-xonly       2016-01-06 15:50:16.796660318 -0800
> +++ b/arch/x86/include/asm/pkeys.h      2016-01-06 15:50:16.809660904 -0800
> @@ -6,4 +6,29 @@
>  extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>                 unsigned long init_val);
>
> +/*
> + * Try to dedicate one of the protection keys to be used as an
> + * execute-only protection key.
> + */
> +#define PKEY_DEDICATED_EXECUTE_ONLY 15
> +extern int __execute_only_pkey(struct mm_struct *mm);
> +static inline int execute_only_pkey(struct mm_struct *mm)
> +{
> +       if (!boot_cpu_has(X86_FEATURE_OSPKE))
> +               return 0;
> +
> +       return __execute_only_pkey(mm);
> +}
> +
> +extern int __arch_override_mprotect_pkey(struct vm_area_struct *vma,
> +               int prot, int pkey);
> +static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
> +               int prot, int pkey)
> +{
> +       if (!boot_cpu_has(X86_FEATURE_OSPKE))
> +               return 0;
> +
> +       return __arch_override_mprotect_pkey(vma, prot, pkey);
> +}
> +
>  #endif /*_ASM_X86_PKEYS_H */
> diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-79-xonly arch/x86/kernel/fpu/xstate.c
> --- a/arch/x86/kernel/fpu/xstate.c~pkeys-79-xonly       2016-01-06 15:50:16.797660363 -0800
> +++ b/arch/x86/kernel/fpu/xstate.c      2016-01-06 15:50:16.809660904 -0800
> @@ -878,8 +878,6 @@ int arch_set_user_pkey_access(struct tas
>         int pkey_shift = (pkey * PKRU_BITS_PER_PKEY);
>         u32 new_pkru_bits = 0;
>
> -       if (!validate_pkey(pkey))
> -               return -EINVAL;
>         /*
>          * This check implies XSAVE support.  OSPKE only gets
>          * set if we enable XSAVE and we enable PKU in XCR0.
> diff -puN arch/x86/mm/fault.c~pkeys-79-xonly arch/x86/mm/fault.c
> --- a/arch/x86/mm/fault.c~pkeys-79-xonly        2016-01-06 15:50:16.799660453 -0800
> +++ b/arch/x86/mm/fault.c       2016-01-06 15:50:16.810660949 -0800
> @@ -14,6 +14,8 @@
>  #include <linux/prefetch.h>            /* prefetchw                    */
>  #include <linux/context_tracking.h>    /* exception_enter(), ...       */
>  #include <linux/uaccess.h>             /* faulthandler_disabled()      */
> +#include <linux/pkeys.h>               /* PKEY_*                       */
> +#include <uapi/asm-generic/mman-common.h>
>
>  #include <asm/cpufeature.h>            /* boot_cpu_has, ...            */
>  #include <asm/traps.h>                 /* dotraplinkage, ...           */
> @@ -23,6 +25,7 @@
>  #include <asm/vsyscall.h>              /* emulate_vsyscall             */
>  #include <asm/vm86.h>                  /* struct vm86                  */
>  #include <asm/mmu_context.h>           /* vma_pkey()                   */
> +#include <asm/fpu/internal.h>          /* fpregs_active()              */
>
>  #define CREATE_TRACE_POINTS
>  #include <asm/trace/exceptions.h>
> @@ -1108,6 +1111,16 @@ access_error(unsigned long error_code, s
>          */
>         if (error_code & PF_PK)
>                 return 1;
> +
> +       if (!(error_code & PF_INSTR)) {
> +               /*
> +                * Assume all accesses require either read or execute
> +                * permissions.  This is not an instruction access, so
> +                * it requires read permissions.
> +                */
> +               if (!(vma->vm_flags & VM_READ))
> +                       return 1;
> +       }
>         /*
>          * Make sure to check the VMA so that we do not perform
>          * faults just to hit a PF_PK as soon as we fill in a
> diff -puN arch/x86/mm/Makefile~pkeys-79-xonly arch/x86/mm/Makefile
> --- a/arch/x86/mm/Makefile~pkeys-79-xonly       2016-01-06 15:50:16.800660498 -0800
> +++ b/arch/x86/mm/Makefile      2016-01-06 15:50:16.810660949 -0800
> @@ -33,3 +33,5 @@ obj-$(CONFIG_ACPI_NUMA)               += srat.o
>  obj-$(CONFIG_NUMA_EMU)         += numa_emulation.o
>
>  obj-$(CONFIG_X86_INTEL_MPX)    += mpx.o
> +obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
> +
> diff -puN /dev/null arch/x86/mm/pkeys.c
> --- /dev/null   2015-12-10 15:28:13.322405854 -0800
> +++ b/arch/x86/mm/pkeys.c       2016-01-06 15:50:16.810660949 -0800
> @@ -0,0 +1,101 @@
> +/*
> + * Intel Memory Protection Keys management
> + * Copyright (c) 2015, Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + */
> +#include <linux/mm_types.h>             /* mm_struct, vma, etc...       */
> +#include <linux/pkeys.h>                /* PKEY_*                       */
> +#include <uapi/asm-generic/mman-common.h>
> +
> +#include <asm/cpufeature.h>             /* boot_cpu_has, ...            */
> +#include <asm/mmu_context.h>            /* vma_pkey()                   */
> +#include <asm/fpu/internal.h>           /* fpregs_active()              */
> +
> +int __execute_only_pkey(struct mm_struct *mm)
> +{
> +       int ret;
> +
> +       /*
> +        * We do not want to go through the relatively costly
> +        * dance to set PKRU if we do not need to.  Check it
> +        * first and assume that if the execute-only pkey is
> +        * write-disabled that we do not have to set it
> +        * ourselves.  We need preempt off so that nobody
> +        * can make fpregs inactive.
> +        */
> +       preempt_disable();
> +       if (fpregs_active() &&
> +           !__pkru_allows_read(read_pkru(), PKEY_DEDICATED_EXECUTE_ONLY)) {
> +               preempt_enable();
> +               return PKEY_DEDICATED_EXECUTE_ONLY;
> +       }
> +       preempt_enable();
> +       ret = arch_set_user_pkey_access(current, PKEY_DEDICATED_EXECUTE_ONLY,
> +                       PKEY_DISABLE_ACCESS);
> +       /*
> +        * If the PKRU-set operation failed somehow, just return
> +        * 0 and effectively disable execute-only support.
> +        */
> +       if (ret)
> +               return 0;
> +
> +       return PKEY_DEDICATED_EXECUTE_ONLY;
> +}
> +
> +static inline bool vma_is_pkey_exec_only(struct vm_area_struct *vma)
> +{
> +       /* Do this check first since the vm_flags should be hot */
> +       if ((vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC)) != VM_EXEC)
> +               return false;
> +       if (vma_pkey(vma) != PKEY_DEDICATED_EXECUTE_ONLY)
> +               return false;
> +
> +       return true;
> +}
> +
> +/*
> + * This is only called for *plain* mprotect calls.
> + */
> +int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot, int pkey)
> +{
> +       /*
> +        * Is this an mprotect_pkey() call?  If so, never
> +        * override the value that came from the user.
> +        */
> +       if (pkey != -1)
> +               return pkey;
> +       /*
> +        * Look for a protection-key-drive execute-only mapping
> +        * which is now being given permissions that are not
> +        * execute-only.  Move it back to the default pkey.
> +        */
> +       if (vma_is_pkey_exec_only(vma) &&
> +           (prot & (PROT_READ|PROT_WRITE))) {
> +               return 0;
> +       }
> +       /*
> +        * The mapping is execute-only.  Go try to get the
> +        * execute-only protection key.  If we fail to do that,
> +        * fall through as if we do not have execute-only
> +        * support.
> +        */
> +       if (prot == PROT_EXEC) {
> +               pkey = execute_only_pkey(vma->vm_mm);
> +               if (pkey > 0)
> +                       return pkey;
> +       }
> +       /*
> +        * This is a vanilla, non-pkey mprotect (or we failed to
> +        * setup execute-only), inherit the pkey from the VMA we
> +        * are working on.
> +        */
> +       return vma_pkey(vma);
> +}
> diff -puN include/linux/pkeys.h~pkeys-79-xonly include/linux/pkeys.h
> --- a/include/linux/pkeys.h~pkeys-79-xonly      2016-01-06 15:50:16.802660588 -0800
> +++ b/include/linux/pkeys.h     2016-01-06 15:50:16.810660949 -0800
> @@ -13,6 +13,9 @@
>  #include <asm/pkeys.h>
>  #else /* ! CONFIG_ARCH_HAS_PKEYS */
>  #define arch_max_pkey() (1)
> +#define execute_only_pkey(mm) (0)
> +#define arch_override_mprotect_pkey(vma, prot, pkey) (0)
> +#define PKEY_DEDICATED_EXECUTE_ONLY 0
>  #endif /* ! CONFIG_ARCH_HAS_PKEYS */
>
>  /*
> diff -puN mm/mmap.c~pkeys-79-xonly mm/mmap.c
> --- a/mm/mmap.c~pkeys-79-xonly  2016-01-06 15:50:16.804660678 -0800
> +++ b/mm/mmap.c 2016-01-06 15:50:16.812661039 -0800
> @@ -42,6 +42,7 @@
>  #include <linux/memory.h>
>  #include <linux/printk.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/pkeys.h>
>
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
> @@ -1266,6 +1267,7 @@ unsigned long do_mmap(struct file *file,
>                         unsigned long pgoff, unsigned long *populate)
>  {
>         struct mm_struct *mm = current->mm;
> +       int pkey = 0;
>
>         *populate = 0;
>
> @@ -1305,11 +1307,17 @@ unsigned long do_mmap(struct file *file,
>         if (offset_in_page(addr))
>                 return addr;
>
> +       if (prot == PROT_EXEC) {
> +               pkey = execute_only_pkey(mm);
> +               if (pkey < 0)
> +                       pkey = 0;
> +       }
> +
>         /* Do simple checking here so the lower-level routines won't have
>          * to. we assume access permissions have been handled by the open
>          * of the memory object, so we don't do any here.
>          */
> -       vm_flags |= calc_vm_prot_bits(prot, 0) | calc_vm_flag_bits(flags) |
> +       vm_flags |= calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
>                         mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
>
>         if (flags & MAP_LOCKED)
> diff -puN mm/mprotect.c~pkeys-79-xonly mm/mprotect.c
> --- a/mm/mprotect.c~pkeys-79-xonly      2016-01-06 15:50:16.805660723 -0800
> +++ b/mm/mprotect.c     2016-01-06 15:50:16.812661039 -0800
> @@ -24,6 +24,7 @@
>  #include <linux/migrate.h>
>  #include <linux/perf_event.h>
>  #include <linux/ksm.h>
> +#include <linux/pkeys.h>
>  #include <asm/uaccess.h>
>  #include <asm/pgtable.h>
>  #include <asm/cacheflush.h>
> @@ -347,7 +348,7 @@ fail:
>  SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
>                 unsigned long, prot)
>  {
> -       unsigned long vm_flags, nstart, end, tmp, reqprot;
> +       unsigned long nstart, end, tmp, reqprot;
>         struct vm_area_struct *vma, *prev;
>         int error = -EINVAL;
>         const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
> @@ -373,8 +374,6 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
>         if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
>                 prot |= PROT_EXEC;
>
> -       vm_flags = calc_vm_prot_bits(prot, 0);
> -
>         down_write(&current->mm->mmap_sem);
>
>         vma = find_vma(current->mm, start);
> @@ -404,10 +403,11 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
>
>         for (nstart = start ; ; ) {
>                 unsigned long newflags;
> +               int pkey = arch_override_mprotect_pkey(vma, prot, -1);
>
>                 /* Here we know that vma->vm_start <= nstart < vma->vm_end. */
>
> -               newflags = vm_flags;
> +               newflags = calc_vm_prot_bits(prot, pkey);
>                 newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
>
>                 /* newflags >> 4 shift VM_MAY% in place of VM_% */
> _



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
