Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6A936B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:23:05 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id t7so6159650qkh.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:23:05 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id on9si8134955wjc.179.2016.08.12.11.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 11:23:04 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id q128so42199554wma.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:23:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470937490-7375-1-git-send-email-catalin.marinas@arm.com>
References: <1470937490-7375-1-git-send-email-catalin.marinas@arm.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 12 Aug 2016 11:23:03 -0700
Message-ID: <CAGXu5jJTuJ+k948BU4rDGF=tHv54TR0JQVTbcVvzp=NtfQrL9Q@mail.gmail.com>
Subject: Re: [PATCH] arm64: Introduce execute-only page access permissions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Will Deacon <will.deacon@arm.com>

On Thu, Aug 11, 2016 at 10:44 AM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> The ARMv8 architecture allows execute-only user permissions by clearing
> the PTE_UXN and PTE_USER bits. However, the kernel running on a CPU
> implementation without User Access Override (ARMv8.2 onwards) can still
> access such page, so execute-only page permission does not protect
> against read(2)/write(2) etc. accesses. Systems requiring such
> protection must enable features like SECCOMP.

So, UAO CPUs will bypass this protection in userspace if using
read/write on a memory-mapped file? I'm just trying to make sure I
understand the bypass scenario. And is this something that can be
fixed? If we add exec-only, I feel like it shouldn't have corner case
surprises. :)

-Kees

>
> This patch changes the arm64 __P100 and __S100 protection_map[] macros
> to the new __PAGE_EXECONLY attributes. A side effect is that
> pte_user() no longer triggers for __PAGE_EXECONLY since PTE_USER isn't
> set. To work around this, the check is done on the PTE_NG bit via the
> pte_ng() macro. VM_READ is also checked now for page faults.
>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  arch/arm64/include/asm/pgtable-prot.h |  5 +++--
>  arch/arm64/include/asm/pgtable.h      | 10 +++++-----
>  arch/arm64/mm/fault.c                 |  5 ++---
>  mm/mmap.c                             |  5 +++++
>  4 files changed, 15 insertions(+), 10 deletions(-)
>
> diff --git a/arch/arm64/include/asm/pgtable-prot.h b/arch/arm64/include/asm/pgtable-prot.h
> index 39f5252673f7..2142c7726e76 100644
> --- a/arch/arm64/include/asm/pgtable-prot.h
> +++ b/arch/arm64/include/asm/pgtable-prot.h
> @@ -70,12 +70,13 @@
>  #define PAGE_COPY_EXEC         __pgprot(_PAGE_DEFAULT | PTE_USER | PTE_NG | PTE_PXN)
>  #define PAGE_READONLY          __pgprot(_PAGE_DEFAULT | PTE_USER | PTE_NG | PTE_PXN | PTE_UXN)
>  #define PAGE_READONLY_EXEC     __pgprot(_PAGE_DEFAULT | PTE_USER | PTE_NG | PTE_PXN)
> +#define PAGE_EXECONLY          __pgprot(_PAGE_DEFAULT | PTE_NG | PTE_PXN)
>
>  #define __P000  PAGE_NONE
>  #define __P001  PAGE_READONLY
>  #define __P010  PAGE_COPY
>  #define __P011  PAGE_COPY
> -#define __P100  PAGE_READONLY_EXEC
> +#define __P100  PAGE_EXECONLY
>  #define __P101  PAGE_READONLY_EXEC
>  #define __P110  PAGE_COPY_EXEC
>  #define __P111  PAGE_COPY_EXEC
> @@ -84,7 +85,7 @@
>  #define __S001  PAGE_READONLY
>  #define __S010  PAGE_SHARED
>  #define __S011  PAGE_SHARED
> -#define __S100  PAGE_READONLY_EXEC
> +#define __S100  PAGE_EXECONLY
>  #define __S101  PAGE_READONLY_EXEC
>  #define __S110  PAGE_SHARED_EXEC
>  #define __S111  PAGE_SHARED_EXEC
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index dbb1b7bf1b07..403a61cf4967 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -74,7 +74,7 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
>  #define pte_write(pte)         (!!(pte_val(pte) & PTE_WRITE))
>  #define pte_exec(pte)          (!(pte_val(pte) & PTE_UXN))
>  #define pte_cont(pte)          (!!(pte_val(pte) & PTE_CONT))
> -#define pte_user(pte)          (!!(pte_val(pte) & PTE_USER))
> +#define pte_ng(pte)            (!!(pte_val(pte) & PTE_NG))
>
>  #ifdef CONFIG_ARM64_HW_AFDBM
>  #define pte_hw_dirty(pte)      (pte_write(pte) && !(pte_val(pte) & PTE_RDONLY))
> @@ -85,8 +85,8 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
>  #define pte_dirty(pte)         (pte_sw_dirty(pte) || pte_hw_dirty(pte))
>
>  #define pte_valid(pte)         (!!(pte_val(pte) & PTE_VALID))
> -#define pte_valid_not_user(pte) \
> -       ((pte_val(pte) & (PTE_VALID | PTE_USER)) == PTE_VALID)
> +#define pte_valid_global(pte) \
> +       ((pte_val(pte) & (PTE_VALID | PTE_NG)) == PTE_VALID)
>  #define pte_valid_young(pte) \
>         ((pte_val(pte) & (PTE_VALID | PTE_AF)) == (PTE_VALID | PTE_AF))
>
> @@ -179,7 +179,7 @@ static inline void set_pte(pte_t *ptep, pte_t pte)
>          * Only if the new pte is valid and kernel, otherwise TLB maintenance
>          * or update_mmu_cache() have the necessary barriers.
>          */
> -       if (pte_valid_not_user(pte)) {
> +       if (pte_valid_global(pte)) {
>                 dsb(ishst);
>                 isb();
>         }
> @@ -213,7 +213,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
>                         pte_val(pte) &= ~PTE_RDONLY;
>                 else
>                         pte_val(pte) |= PTE_RDONLY;
> -               if (pte_user(pte) && pte_exec(pte) && !pte_special(pte))
> +               if (pte_ng(pte) && pte_exec(pte) && !pte_special(pte))
>                         __sync_icache_dcache(pte, addr);
>         }
>
> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
> index c8beaa0da7df..58f697fe18b6 100644
> --- a/arch/arm64/mm/fault.c
> +++ b/arch/arm64/mm/fault.c
> @@ -245,8 +245,7 @@ static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
>  good_area:
>         /*
>          * Check that the permissions on the VMA allow for the fault which
> -        * occurred. If we encountered a write or exec fault, we must have
> -        * appropriate permissions, otherwise we allow any permission.
> +        * occurred.
>          */
>         if (!(vma->vm_flags & vm_flags)) {
>                 fault = VM_FAULT_BADACCESS;
> @@ -281,7 +280,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>         struct task_struct *tsk;
>         struct mm_struct *mm;
>         int fault, sig, code;
> -       unsigned long vm_flags = VM_READ | VM_WRITE | VM_EXEC;
> +       unsigned long vm_flags = VM_READ | VM_WRITE;
>         unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
>
>         if (notify_page_fault(regs, esr))
> diff --git a/mm/mmap.c b/mm/mmap.c
> index ca9d91bca0d6..69cad562cd00 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -88,6 +88,11 @@ static void unmap_region(struct mm_struct *mm,
>   *             w: (no) no      w: (no) no      w: (copy) copy  w: (no) no
>   *             x: (no) no      x: (no) yes     x: (no) yes     x: (yes) yes
>   *
> + * On arm64, PROT_EXEC has the following behaviour for both MAP_SHARED and
> + * MAP_PRIVATE:
> + *                                                             r: (no) no
> + *                                                             w: (no) no
> + *                                                             x: (yes) yes
>   */
>  pgprot_t protection_map[16] = {
>         __P000, __P001, __P010, __P011, __P100, __P101, __P110, __P111,



-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
