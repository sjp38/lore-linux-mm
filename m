Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40A9D6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 12:58:47 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id z8so34204176igl.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:58:47 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id ng9si16854713oeb.26.2016.04.15.09.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 09:58:46 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id w85so129978533oiw.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:58:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460729545-5666-1-git-send-email-dsafonov@virtuozzo.com>
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com> <1460729545-5666-1-git-send-email-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 15 Apr 2016 09:58:26 -0700
Message-ID: <CALCETrXQHuSKejXtsGnpm455Z39TVn6jsaUd_T_F=b3Rtmki5Q@mail.gmail.com>
Subject: Re: [PATCHv4 1/2] x86/vdso: add mremap hook to vm_special_mapping
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

On Fri, Apr 15, 2016 at 7:12 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Add possibility for userspace 32-bit applications to move
> vdso mapping. Previously, when userspace app called
> mremap for vdso, in return path it would land on previous
> address of vdso page, resulting in segmentation violation.
> Now it lands fine and returns to userspace with remapped vdso.
> This will also fix context.vdso pointer for 64-bit, which does not
> affect the user of vdso after mremap by now, but this may change.
>
> As suggested by Andy, return EINVAL for mremap that splits vdso image.
>
> Renamed and moved text_mapping structure declaration inside
> map_vdso, as it used only there and now it complement
> vvar_mapping variable.
>
> There is still problem for remapping vdso in glibc applications:
> linker relocates addresses for syscalls on vdso page, so
> you need to relink with the new addresses. Or the next syscall
> through glibc may fail:
>   Program received signal SIGSEGV, Segmentation fault.
>   #0  0xf7fd9b80 in __kernel_vsyscall ()
>   #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
> ---
> v4: drop __maybe_unused & use image from mm->context instead vdso_image_32
> v3: as Andy suggested, return EINVAL in case of splitting vdso blob on mremap;
>     used is_ia32_task instead of ifdefs
> v2: added __maybe_unused for pt_regs in vdso_mremap
>
>  arch/x86/entry/vdso/vma.c | 36 +++++++++++++++++++++++++++++++-----
>  include/linux/mm_types.h  |  3 +++
>  mm/mmap.c                 | 10 ++++++++++
>  3 files changed, 44 insertions(+), 5 deletions(-)
>
> diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
> index 10f704584922..d26517f3f88f 100644
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
> @@ -98,10 +99,29 @@ static int vdso_fault(const struct vm_special_mapping *sm,
>         return 0;
>  }
>
> -static const struct vm_special_mapping text_mapping = {
> -       .name = "[vdso]",
> -       .fault = vdso_fault,
> -};

Ah, this is what I missed last time.  Looks good.

> +static int vdso_mremap(const struct vm_special_mapping *sm,
> +                     struct vm_area_struct *new_vma)
> +{
> +       unsigned long new_size = new_vma->vm_end - new_vma->vm_start;
> +       const struct vdso_image *image = current->mm->context.vdso_image;
> +
> +       if (image->size != new_size)
> +               return -EINVAL;
> +
> +       if (is_ia32_task()) {
> +               struct pt_regs *regs = current_pt_regs();
> +               unsigned long vdso_land = image->sym_int80_landing_pad;
> +               unsigned long old_land_addr = vdso_land +
> +                       (unsigned long)current->mm->context.vdso;
> +
> +               /* Fixing userspace landing - look at do_fast_syscall_32 */
> +               if (regs->ip == old_land_addr)
> +                       regs->ip = new_vma->vm_start + vdso_land;
> +       }
> +       new_vma->vm_mm->context.vdso = (void __user *)new_vma->vm_start;

A couple minor things:

 - You're looking at both new_vma->vm_mm and current->mm.  Is there a
reason for that?  If they're different, I'd be quite surprised, but
maybe it would make sense to check.

 - On second thought, the is_ia32_task() check is a little weird given
that you're planning on making the vdso image type.  It might make
sense to change that to in_ia32_syscall() && image == &vdso_image_32.

Other than that, looks good to me.

You could add a really simple test case to selftests/x86:

mremap(the vdso, somewhere else);
asm volatile ("int $0x80" : : "a" (__NR_exit), "b" (0));

That'll segfault if this fails and it'll work and return 0 if it works.

FWIW, there's one respect in which this code could be problematic down
the road: if syscalls ever start needing the vvar page, then this gets
awkward because you can't remap both at once.  Also, this is
fundamentally racy if multiple threads try to use it (but there's
nothing whatsoever the kernel could do about that).  In general, once
the call to change and relocate the vdso gets written, CRIU should
probably prefer to use it over mremap.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
