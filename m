Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A44056B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 18:59:15 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id jl1so169205312obb.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 15:59:15 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id r31si14959206otr.185.2016.04.14.15.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 15:59:14 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id s79so108446538oie.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 15:59:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460651571-10545-1-git-send-email-dsafonov@virtuozzo.com>
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com> <1460651571-10545-1-git-send-email-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 14 Apr 2016 15:58:55 -0700
Message-ID: <CALCETrUhDvdyJV53Am2sgefyMJmHs5u1voOM2N76Si7BTtJWaQ@mail.gmail.com>
Subject: Re: [PATCHv2] x86/vdso: add mremap hook to vm_special_mapping
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

On Thu, Apr 14, 2016 at 9:32 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Add possibility for userspace 32-bit applications to move
> vdso mapping. Previously, when userspace app called
> mremap for vdso, in return path it would land on previous
> address of vdso page, resulting in segmentation violation.
> Now it lands fine and returns to userspace with remapped vdso.
> This will also fix context.vdso pointer for 64-bit, which does not
> affect the user of vdso after mremap by now, but this may change.
>
> Renamed and moved text_mapping structure declaration inside
> map_vdso, as it used only there and now it complement
> vvar_mapping variable.
>
> There is still problem for remapping vdso in 32-bit glibc applications:
> linker relocates addresses for syscalls on vdso page, so
> you need to relink with the new addresses. Or the next syscall
> through glibc may fail:
>   Program received signal SIGSEGV, Segmentation fault.
>   #0  0xf7fd9b80 in __kernel_vsyscall ()
>   #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
> ---
> v2: added __maybe_unused for pt_regs in vdso_mremap
>
>  arch/x86/entry/vdso/vma.c | 33 ++++++++++++++++++++++++++++-----
>  include/linux/mm_types.h  |  3 +++
>  mm/mmap.c                 | 10 ++++++++++
>  3 files changed, 41 insertions(+), 5 deletions(-)
>
> diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
> index 10f704584922..7e261e2554c8 100644
> --- a/arch/x86/entry/vdso/vma.c
> +++ b/arch/x86/entry/vdso/vma.c
> @@ -12,6 +12,7 @@
>  #include <linux/random.h>
>  #include <linux/elf.h>
>  #include <linux/cpu.h>
> +#include <linux/ptrace.h>
>  #include <asm/pvclock.h>
>  #include <asm/vgtod.h>
>  #include <asm/proto.h>
> @@ -98,10 +99,26 @@ static int vdso_fault(const struct vm_special_mapping *sm,
>         return 0;
>  }
>
> -static const struct vm_special_mapping text_mapping = {
> -       .name = "[vdso]",
> -       .fault = vdso_fault,
> -};
> +static int vdso_mremap(const struct vm_special_mapping *sm,
> +                     struct vm_area_struct *new_vma)
> +{
> +       struct pt_regs __maybe_unused *regs = current_pt_regs();
> +
> +#if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
> +       /* Fixing userspace landing - look at do_fast_syscall_32 */
> +       if (regs->ip == (unsigned long)current->mm->context.vdso +
> +                       vdso_image_32.sym_int80_landing_pad
> +#ifdef CONFIG_IA32_EMULATION
> +               && current_thread_info()->status & TS_COMPAT
> +#endif

Instead of ifdef, use the (grossly misnamed) is_ia32_task() helper for
this, please.

> +          )
> +               regs->ip = new_vma->vm_start +
> +                       vdso_image_32.sym_int80_landing_pad;
> +#endif
> +       new_vma->vm_mm->context.vdso = (void __user *)new_vma->vm_start;

Can you arrange for the mremap call to fail if the old mapping gets
split?  This might be as simple as confirming that the new mapping's
length is what we expect it to be and, if it isn't, returning -EINVAL.

If anyone things that might break some existing application (which is
quite unlikely), then we could allow mremap to succeed but skip the
part where we change context.vdso and rip.

> +
> +       return 0;
> +}
>
>  static int vvar_fault(const struct vm_special_mapping *sm,
>                       struct vm_area_struct *vma, struct vm_fault *vmf)
> @@ -162,6 +179,12 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
>         struct vm_area_struct *vma;
>         unsigned long addr, text_start;
>         int ret = 0;
> +
> +       static const struct vm_special_mapping vdso_mapping = {
> +               .name = "[vdso]",
> +               .fault = vdso_fault,
> +               .mremap = vdso_mremap,
> +       };

Why did you add this instead of modifying text_mapping?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
