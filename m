Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3666B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 08:06:52 -0400 (EDT)
Received: by wiga1 with SMTP id a1so67361865wig.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 05:06:51 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id s14si13031523wij.118.2015.07.13.05.06.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 05:06:50 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so59991135wic.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 05:06:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 13 Jul 2015 15:06:30 +0300
Message-ID: <CALq1K=J-VqnTmgNj-pbfq8Ps-mgU3=10i0WiS2S5V37og9bMcw@mail.gmail.com>
Subject: Re: [PATCH 2/5] x86, mpx: do not set ->vm_ops on mpx VMAs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

Hi Kirill,

On Mon, Jul 13, 2015 at 1:54 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> MPX setups private anonymous mapping, but uses vma->vm_ops too.
> This can confuse core VM, as it relies on vm->vm_ops to distinguish
> file VMAs from anonymous.
>
> As result we will get SIGBUS, because handle_pte_fault() thinks it's
> file VMA without vm_ops->fault and it doesn't know how to handle the
> situation properly.
>
> Let's fix that by not setting ->vm_ops.
>
> We don't really need ->vm_ops here: MPX VMA can be detected with VM_MPX
> flag. And vma_merge() will not merge MPX VMA with non-MPX VMA, because
> ->vm_flags won't match.
>
> The only thing left is name of VMA. I'm not sure if it's part of ABI, or
> we can just drop it. The patch keep it by providing arch_vma_name() on x86.
>
> Build tested only.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> ---
>  arch/x86/mm/mmap.c |  7 +++++++
>  arch/x86/mm/mpx.c  | 20 +-------------------
>  2 files changed, 8 insertions(+), 19 deletions(-)
>
> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> index 9d518d693b4b..844b06d67df4 100644
> --- a/arch/x86/mm/mmap.c
> +++ b/arch/x86/mm/mmap.c
> @@ -126,3 +126,10 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
>                 mm->get_unmapped_area = arch_get_unmapped_area_topdown;
>         }
>  }
> +
> +const char *arch_vma_name(struct vm_area_struct *vma)
> +{
> +       if (vma->vm_flags & VM_MPX)
> +               return "[mpx]";
> +       return NULL;
> +}

I sure that I'm missing something important. This function stores
"[mpx]" string on this function stack and returns the pointer to that
address. In current flow, this address is visible and accessible,
however in can be a different in general case.

> diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
> index c439ec478216..4d1c11c07fe1 100644
> --- a/arch/x86/mm/mpx.c
> +++ b/arch/x86/mm/mpx.c
> @@ -18,26 +18,9 @@
>  #include <asm/processor.h>
>  #include <asm/fpu-internal.h>
>
> -static const char *mpx_mapping_name(struct vm_area_struct *vma)
> -{
> -       return "[mpx]";
> -}
> -
> -static struct vm_operations_struct mpx_vma_ops = {
> -       .name = mpx_mapping_name,
> -};
> -
> -static int is_mpx_vma(struct vm_area_struct *vma)
> -{
> -       return (vma->vm_ops == &mpx_vma_ops);
> -}
> -
>  /*
>   * This is really a simplified "vm_mmap". it only handles MPX
>   * bounds tables (the bounds directory is user-allocated).
> - *
> - * Later on, we use the vma->vm_ops to uniquely identify these
> - * VMAs.
>   */
>  static unsigned long mpx_mmap(unsigned long len)
>  {
> @@ -83,7 +66,6 @@ static unsigned long mpx_mmap(unsigned long len)
>                 ret = -ENOMEM;
>                 goto out;
>         }
> -       vma->vm_ops = &mpx_vma_ops;
>
>         if (vm_flags & VM_LOCKED) {
>                 up_write(&mm->mmap_sem);
> @@ -661,7 +643,7 @@ static int zap_bt_entries(struct mm_struct *mm,
>                  * so stop immediately and return an error.  This
>                  * probably results in a SIGSEGV.
>                  */
> -               if (!is_mpx_vma(vma))
> +               if (!(vma->vm_flags & VM_MPX))
>                         return -EINVAL;
>
>                 len = min(vma->vm_end, end) - addr;
> --
> 2.1.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>




-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
