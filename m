Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA566B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 03:22:44 -0500 (EST)
Received: by lams18 with SMTP id s18so18666239lam.13
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 00:22:43 -0800 (PST)
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com. [209.85.215.49])
        by mx.google.com with ESMTPS id r3si10912114laj.150.2015.02.10.00.22.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 00:22:42 -0800 (PST)
Received: by labgm9 with SMTP id gm9so13914603lab.2
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 00:22:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150203231212.223123220@linuxfoundation.org>
References: <20150203231211.486950145@linuxfoundation.org>
	<20150203231212.223123220@linuxfoundation.org>
Date: Tue, 10 Feb 2015 12:22:41 +0400
Message-ID: <CALYGNiPVvgxMFyDTSFv4mUhkq-5Q+Gp2UEY5W9G0gEc8YajipQ@mail.gmail.com>
Subject: Re: [PATCH 3.18 04/57] vm: add VM_FAULT_SIGSEGV handling support
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stable <stable@vger.kernel.org>, Jan Engelhardt <jengelh@inai.de>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

I've found regression:

[  257.139907] ================================================
[  257.139909] [ BUG: lock held when returning to user space! ]
[  257.139912] 3.18.6-debug+ #161 Tainted: G     U
[  257.139914] ------------------------------------------------
[  257.139916] python/22843 is leaving the kernel with locks still held!
[  257.139918] 1 lock held by python/22843:
[  257.139920]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8104e4c2>]
__do_page_fault+0x162/0x570

upstream commit 7fb08eca45270d0ae86e1ad9d39c40b7a55d0190 must be backported too.

On Wed, Feb 4, 2015 at 2:13 AM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> 3.18-stable review patch.  If anyone has any objections, please let me know.
>
> ------------------
>
> From: Linus Torvalds <torvalds@linux-foundation.org>
>
> commit 33692f27597fcab536d7cbbcc8f52905133e4aa7 upstream.
>
> The core VM already knows about VM_FAULT_SIGBUS, but cannot return a
> "you should SIGSEGV" error, because the SIGSEGV case was generally
> handled by the caller - usually the architecture fault handler.
>
> That results in lots of duplication - all the architecture fault
> handlers end up doing very similar "look up vma, check permissions, do
> retries etc" - but it generally works.  However, there are cases where
> the VM actually wants to SIGSEGV, and applications _expect_ SIGSEGV.
>
> In particular, when accessing the stack guard page, libsigsegv expects a
> SIGSEGV.  And it usually got one, because the stack growth is handled by
> that duplicated architecture fault handler.
>
> However, when the generic VM layer started propagating the error return
> from the stack expansion in commit fee7e49d4514 ("mm: propagate error
> from stack expansion even for guard page"), that now exposed the
> existing VM_FAULT_SIGBUS result to user space.  And user space really
> expected SIGSEGV, not SIGBUS.
>
> To fix that case, we need to add a VM_FAULT_SIGSEGV, and teach all those
> duplicate architecture fault handlers about it.  They all already have
> the code to handle SIGSEGV, so it's about just tying that new return
> value to the existing code, but it's all a bit annoying.
>
> This is the mindless minimal patch to do this.  A more extensive patch
> would be to try to gather up the mostly shared fault handling logic into
> one generic helper routine, and long-term we really should do that
> cleanup.
>
> Just from this patch, you can generally see that most architectures just
> copied (directly or indirectly) the old x86 way of doing things, but in
> the meantime that original x86 model has been improved to hold the VM
> semaphore for shorter times etc and to handle VM_FAULT_RETRY and other
> "newer" things, so it would be a good idea to bring all those
> improvements to the generic case and teach other architectures about
> them too.
>
> Reported-and-tested-by: Takashi Iwai <tiwai@suse.de>
> Tested-by: Jan Engelhardt <jengelh@inai.de>
> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # "s390 still compiles and boots"
> Cc: linux-arch@vger.kernel.org
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>
> ---
>  arch/alpha/mm/fault.c                        |    2 ++
>  arch/arc/mm/fault.c                          |    2 ++
>  arch/avr32/mm/fault.c                        |    2 ++
>  arch/cris/mm/fault.c                         |    2 ++
>  arch/frv/mm/fault.c                          |    2 ++
>  arch/ia64/mm/fault.c                         |    2 ++
>  arch/m32r/mm/fault.c                         |    2 ++
>  arch/m68k/mm/fault.c                         |    2 ++
>  arch/metag/mm/fault.c                        |    2 ++
>  arch/microblaze/mm/fault.c                   |    2 ++
>  arch/mips/mm/fault.c                         |    2 ++
>  arch/mn10300/mm/fault.c                      |    2 ++
>  arch/openrisc/mm/fault.c                     |    2 ++
>  arch/parisc/mm/fault.c                       |    2 ++
>  arch/powerpc/mm/copro_fault.c                |    2 +-
>  arch/powerpc/mm/fault.c                      |    2 ++
>  arch/s390/mm/fault.c                         |    6 ++++++
>  arch/score/mm/fault.c                        |    2 ++
>  arch/sh/mm/fault.c                           |    2 ++
>  arch/sparc/mm/fault_32.c                     |    2 ++
>  arch/sparc/mm/fault_64.c                     |    2 ++
>  arch/tile/mm/fault.c                         |    2 ++
>  arch/um/kernel/trap.c                        |    2 ++
>  arch/x86/mm/fault.c                          |    2 ++
>  arch/xtensa/mm/fault.c                       |    2 ++
>  drivers/staging/lustre/lustre/llite/vvp_io.c |    2 +-
>  include/linux/mm.h                           |    6 ++++--
>  mm/gup.c                                     |    4 ++--
>  mm/ksm.c                                     |    2 +-
>  29 files changed, 61 insertions(+), 7 deletions(-)
>
> --- a/arch/alpha/mm/fault.c
> +++ b/arch/alpha/mm/fault.c
> @@ -156,6 +156,8 @@ retry:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/arc/mm/fault.c
> +++ b/arch/arc/mm/fault.c
> @@ -161,6 +161,8 @@ good_area:
>
>         if (fault & VM_FAULT_OOM)
>                 goto out_of_memory;
> +       else if (fault & VM_FAULT_SIGSEV)
> +               goto bad_area;
>         else if (fault & VM_FAULT_SIGBUS)
>                 goto do_sigbus;
>
> --- a/arch/avr32/mm/fault.c
> +++ b/arch/avr32/mm/fault.c
> @@ -142,6 +142,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/cris/mm/fault.c
> +++ b/arch/cris/mm/fault.c
> @@ -176,6 +176,8 @@ retry:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/frv/mm/fault.c
> +++ b/arch/frv/mm/fault.c
> @@ -168,6 +168,8 @@ asmlinkage void do_page_fault(int datamm
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/ia64/mm/fault.c
> +++ b/arch/ia64/mm/fault.c
> @@ -172,6 +172,8 @@ retry:
>                  */
>                 if (fault & VM_FAULT_OOM) {
>                         goto out_of_memory;
> +               } else if (fault & VM_FAULT_SIGSEGV) {
> +                       goto bad_area;
>                 } else if (fault & VM_FAULT_SIGBUS) {
>                         signal = SIGBUS;
>                         goto bad_area;
> --- a/arch/m32r/mm/fault.c
> +++ b/arch/m32r/mm/fault.c
> @@ -200,6 +200,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/m68k/mm/fault.c
> +++ b/arch/m68k/mm/fault.c
> @@ -145,6 +145,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto map_err;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto bus_err;
>                 BUG();
> --- a/arch/metag/mm/fault.c
> +++ b/arch/metag/mm/fault.c
> @@ -141,6 +141,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/microblaze/mm/fault.c
> +++ b/arch/microblaze/mm/fault.c
> @@ -224,6 +224,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/mips/mm/fault.c
> +++ b/arch/mips/mm/fault.c
> @@ -158,6 +158,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/mn10300/mm/fault.c
> +++ b/arch/mn10300/mm/fault.c
> @@ -262,6 +262,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/openrisc/mm/fault.c
> +++ b/arch/openrisc/mm/fault.c
> @@ -171,6 +171,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/parisc/mm/fault.c
> +++ b/arch/parisc/mm/fault.c
> @@ -256,6 +256,8 @@ good_area:
>                  */
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto bad_area;
>                 BUG();
> --- a/arch/powerpc/mm/copro_fault.c
> +++ b/arch/powerpc/mm/copro_fault.c
> @@ -76,7 +76,7 @@ int copro_handle_mm_fault(struct mm_stru
>                 if (*flt & VM_FAULT_OOM) {
>                         ret = -ENOMEM;
>                         goto out_unlock;
> -               } else if (*flt & VM_FAULT_SIGBUS) {
> +               } else if (*flt & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV)) {
>                         ret = -EFAULT;
>                         goto out_unlock;
>                 }
> --- a/arch/powerpc/mm/fault.c
> +++ b/arch/powerpc/mm/fault.c
> @@ -444,6 +444,8 @@ good_area:
>          */
>         fault = handle_mm_fault(mm, vma, address, flags);
>         if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
> +               if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 rc = mm_fault_error(regs, address, fault);
>                 if (rc >= MM_FAULT_RETURN)
>                         goto bail;
> --- a/arch/s390/mm/fault.c
> +++ b/arch/s390/mm/fault.c
> @@ -374,6 +374,12 @@ static noinline void do_fault_error(stru
>                                 do_no_context(regs);
>                         else
>                                 pagefault_out_of_memory();
> +               } else if (fault & VM_FAULT_SIGSEGV) {
> +                       /* Kernel mode? Handle exceptions or die */
> +                       if (!user_mode(regs))
> +                               do_no_context(regs);
> +                       else
> +                               do_sigsegv(regs, SEGV_MAPERR);
>                 } else if (fault & VM_FAULT_SIGBUS) {
>                         /* Kernel mode? Handle exceptions or die */
>                         if (!user_mode(regs))
> --- a/arch/score/mm/fault.c
> +++ b/arch/score/mm/fault.c
> @@ -114,6 +114,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/sh/mm/fault.c
> +++ b/arch/sh/mm/fault.c
> @@ -353,6 +353,8 @@ mm_fault_error(struct pt_regs *regs, uns
>         } else {
>                 if (fault & VM_FAULT_SIGBUS)
>                         do_sigbus(regs, error_code, address);
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       bad_area(regs, error_code, address);
>                 else
>                         BUG();
>         }
> --- a/arch/sparc/mm/fault_32.c
> +++ b/arch/sparc/mm/fault_32.c
> @@ -249,6 +249,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/sparc/mm/fault_64.c
> +++ b/arch/sparc/mm/fault_64.c
> @@ -446,6 +446,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/tile/mm/fault.c
> +++ b/arch/tile/mm/fault.c
> @@ -444,6 +444,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/arch/um/kernel/trap.c
> +++ b/arch/um/kernel/trap.c
> @@ -80,6 +80,8 @@ good_area:
>                 if (unlikely(fault & VM_FAULT_ERROR)) {
>                         if (fault & VM_FAULT_OOM) {
>                                 goto out_of_memory;
> +                       } else if (fault & VM_FAULT_SIGSEGV) {
> +                               goto out;
>                         } else if (fault & VM_FAULT_SIGBUS) {
>                                 err = -EACCES;
>                                 goto out;
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -905,6 +905,8 @@ mm_fault_error(struct pt_regs *regs, uns
>                 if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
>                              VM_FAULT_HWPOISON_LARGE))
>                         do_sigbus(regs, error_code, address, fault);
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       bad_area_nosemaphore(regs, error_code, address);
>                 else
>                         BUG();
>         }
> --- a/arch/xtensa/mm/fault.c
> +++ b/arch/xtensa/mm/fault.c
> @@ -117,6 +117,8 @@ good_area:
>         if (unlikely(fault & VM_FAULT_ERROR)) {
>                 if (fault & VM_FAULT_OOM)
>                         goto out_of_memory;
> +               else if (fault & VM_FAULT_SIGSEGV)
> +                       goto bad_area;
>                 else if (fault & VM_FAULT_SIGBUS)
>                         goto do_sigbus;
>                 BUG();
> --- a/drivers/staging/lustre/lustre/llite/vvp_io.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
> @@ -632,7 +632,7 @@ static int vvp_io_kernel_fault(struct vv
>                 return 0;
>         }
>
> -       if (cfio->fault.ft_flags & VM_FAULT_SIGBUS) {
> +       if (cfio->fault.ft_flags & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV)) {
>                 CDEBUG(D_PAGE, "got addr %p - SIGBUS\n", vmf->virtual_address);
>                 return -EFAULT;
>         }
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1054,6 +1054,7 @@ static inline int page_mapped(struct pag
>  #define VM_FAULT_WRITE 0x0008  /* Special case for get_user_pages */
>  #define VM_FAULT_HWPOISON 0x0010       /* Hit poisoned small page */
>  #define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
> +#define VM_FAULT_SIGSEGV 0x0040
>
>  #define VM_FAULT_NOPAGE        0x0100  /* ->fault installed the pte, not return page */
>  #define VM_FAULT_LOCKED        0x0200  /* ->fault locked the returned page */
> @@ -1062,8 +1063,9 @@ static inline int page_mapped(struct pag
>
>  #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
>
> -#define VM_FAULT_ERROR (VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON | \
> -                        VM_FAULT_FALLBACK | VM_FAULT_HWPOISON_LARGE)
> +#define VM_FAULT_ERROR (VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
> +                        VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
> +                        VM_FAULT_FALLBACK)
>
>  /* Encode hstate index for a hwpoisoned large page */
>  #define VM_FAULT_SET_HINDEX(x) ((x) << 12)
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -296,7 +296,7 @@ static int faultin_page(struct task_stru
>                         return -ENOMEM;
>                 if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
>                         return *flags & FOLL_HWPOISON ? -EHWPOISON : -EFAULT;
> -               if (ret & VM_FAULT_SIGBUS)
> +               if (ret & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV))
>                         return -EFAULT;
>                 BUG();
>         }
> @@ -571,7 +571,7 @@ int fixup_user_fault(struct task_struct
>                         return -ENOMEM;
>                 if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
>                         return -EHWPOISON;
> -               if (ret & VM_FAULT_SIGBUS)
> +               if (ret & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV))
>                         return -EFAULT;
>                 BUG();
>         }
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -376,7 +376,7 @@ static int break_ksm(struct vm_area_stru
>                 else
>                         ret = VM_FAULT_WRITE;
>                 put_page(page);
> -       } while (!(ret & (VM_FAULT_WRITE | VM_FAULT_SIGBUS | VM_FAULT_OOM)));
> +       } while (!(ret & (VM_FAULT_WRITE | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | VM_FAULT_OOM)));
>         /*
>          * We must loop because handle_mm_fault() may back out if there's
>          * any difficulty e.g. if pte accessed bit gets updated concurrently.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
