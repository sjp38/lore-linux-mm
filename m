Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D13A6B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:45:44 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w12-v6so33924784oie.12
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:45:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3-v6sor9392734oia.123.2018.07.11.12.45.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 12:45:42 -0700 (PDT)
MIME-Version: 1.0
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-28-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-28-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Wed, 11 Jul 2018 12:45:16 -0700
Message-ID: <CAG48ez2cY1CPTTfDnV5yZyHVPXP787=fR1+G_D7tR5VYXdjFmQ@mail.gmail.com>
Subject: Re: [RFC PATCH v2 27/27] x86/cet: Add arch_prctl functions for CET
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> arch_prctl(ARCH_CET_STATUS, unsigned long *addr)
>     Return CET feature status.
>
>     The parameter 'addr' is a pointer to a user buffer.
>     On returning to the caller, the kernel fills the following
>     information:
>
>     *addr = SHSTK/IBT status
>     *(addr + 1) = SHSTK base address
>     *(addr + 2) = SHSTK size
>
> arch_prctl(ARCH_CET_DISABLE, unsigned long features)
>     Disable SHSTK and/or IBT specified in 'features'.  Return -EPERM
>     if CET is locked out.
>
> arch_prctl(ARCH_CET_LOCK)
>     Lock out CET feature.
>
> arch_prctl(ARCH_CET_ALLOC_SHSTK, unsigned long *addr)
>     Allocate a new SHSTK.
>
>     The parameter 'addr' is a pointer to a user buffer and indicates
>     the desired SHSTK size to allocate.  On returning to the caller
>     the buffer contains the address of the new SHSTK.
>
> arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
>     Allocate an IBT legacy code bitmap if the current task does not
>     have one.
>
>     The parameter 'addr' is a pointer to a user buffer.
>     On returning to the caller, the kernel fills the following
>     information:
>
>     *addr = IBT bitmap base address
>     *(addr + 1) = IBT bitmap size
>
> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
[...]
> diff --git a/arch/x86/kernel/cet_prctl.c b/arch/x86/kernel/cet_prctl.c
> new file mode 100644
> index 000000000000..86bb78ae656d
> --- /dev/null
> +++ b/arch/x86/kernel/cet_prctl.c
> @@ -0,0 +1,141 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +
> +#include <linux/errno.h>
> +#include <linux/uaccess.h>
> +#include <linux/prctl.h>
> +#include <linux/compat.h>
> +#include <asm/processor.h>
> +#include <asm/prctl.h>
> +#include <asm/elf.h>
> +#include <asm/elf_property.h>
> +#include <asm/cet.h>
> +
> +/* See Documentation/x86/intel_cet.txt. */
> +
> +static int handle_get_status(unsigned long arg2)
> +{
> +       unsigned int features = 0;
> +       unsigned long shstk_base, shstk_size;
> +
> +       if (current->thread.cet.shstk_enabled)
> +               features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
> +       if (current->thread.cet.ibt_enabled)
> +               features |= GNU_PROPERTY_X86_FEATURE_1_IBT;
> +
> +       shstk_base = current->thread.cet.shstk_base;
> +       shstk_size = current->thread.cet.shstk_size;
> +
> +       if (in_ia32_syscall()) {
> +               unsigned int buf[3];
> +
> +               buf[0] = features;
> +               buf[1] = (unsigned int)shstk_base;
> +               buf[2] = (unsigned int)shstk_size;
> +               return copy_to_user((unsigned int __user *)arg2, buf,
> +                                   sizeof(buf));
> +       } else {
> +               unsigned long buf[3];
> +
> +               buf[0] = (unsigned long)features;
> +               buf[1] = shstk_base;
> +               buf[2] = shstk_size;
> +               return copy_to_user((unsigned long __user *)arg2, buf,
> +                                   sizeof(buf));
> +       }

Other places in the kernel (e.g. the BPF subsystem) just
unconditionally use u64 instead of unsigned long to avoid having to
switch between different sizes. I wonder whether that would make sense
here?

> +}
> +
> +static int handle_alloc_shstk(unsigned long arg2)
> +{
> +       int err = 0;
> +       unsigned long shstk_size = 0;
> +
> +       if (in_ia32_syscall()) {
> +               unsigned int size;
> +
> +               err = get_user(size, (unsigned int __user *)arg2);
> +               if (!err)
> +                       shstk_size = size;
> +       } else {
> +               err = get_user(shstk_size, (unsigned long __user *)arg2);
> +       }

As above.

> +       if (err)
> +               return -EFAULT;
> +
> +       err = cet_alloc_shstk(&shstk_size);
> +       if (err)
> +               return -err;
> +
> +       if (in_ia32_syscall()) {
> +               if (put_user(shstk_size, (unsigned int __user *)arg2))
> +                       return -EFAULT;
> +       } else {
> +               if (put_user(shstk_size, (unsigned long __user *)arg2))
> +                       return -EFAULT;
> +       }
> +       return 0;
> +}
> +
> +static int handle_bitmap(unsigned long arg2)
> +{
> +       unsigned long addr, size;
> +
> +       if (current->thread.cet.ibt_enabled) {
> +               if (!current->thread.cet.ibt_bitmap_addr)
> +                       cet_setup_ibt_bitmap();
> +               addr = current->thread.cet.ibt_bitmap_addr;
> +               size = current->thread.cet.ibt_bitmap_size;
> +       } else {
> +               addr = 0;
> +               size = 0;
> +       }
> +
> +       if (in_compat_syscall()) {
> +               if (put_user(addr, (unsigned int __user *)arg2) ||
> +                   put_user(size, (unsigned int __user *)arg2 + 1))
> +                       return -EFAULT;
> +       } else {
> +               if (put_user(addr, (unsigned long __user *)arg2) ||
> +                   put_user(size, (unsigned long __user *)arg2 + 1))
> +               return -EFAULT;
> +       }
> +       return 0;
> +}
> +
> +int prctl_cet(int option, unsigned long arg2)
> +{
> +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK) &&
> +           !cpu_feature_enabled(X86_FEATURE_IBT))
> +               return -EINVAL;
> +
> +       switch (option) {
> +       case ARCH_CET_STATUS:
> +               return handle_get_status(arg2);
> +
> +       case ARCH_CET_DISABLE:
> +               if (current->thread.cet.locked)
> +                       return -EPERM;
> +               if (arg2 & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
> +                       cet_disable_free_shstk(current);
> +               if (arg2 & GNU_PROPERTY_X86_FEATURE_1_IBT)
> +                       cet_disable_ibt();
> +
> +               return 0;
> +
> +       case ARCH_CET_LOCK:
> +               current->thread.cet.locked = 1;
> +               return 0;
> +
> +       case ARCH_CET_ALLOC_SHSTK:
> +               return handle_alloc_shstk(arg2);
> +
> +       /*
> +        * Allocate legacy bitmap and return address & size to user.
> +        */
> +       case ARCH_CET_LEGACY_BITMAP:
> +               return handle_bitmap(arg2);
> +
> +       default:
> +               return -EINVAL;
> +       }
> +}
> diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
> index 42e08d3b573e..3d4934fdac7f 100644
> --- a/arch/x86/kernel/elf.c
> +++ b/arch/x86/kernel/elf.c
> @@ -8,7 +8,10 @@
>
>  #include <asm/cet.h>
>  #include <asm/elf_property.h>
> +#include <asm/prctl.h>
> +#include <asm/processor.h>
>  #include <uapi/linux/elf-em.h>
> +#include <uapi/linux/prctl.h>
>  #include <linux/binfmts.h>
>  #include <linux/elf.h>
>  #include <linux/slab.h>
> @@ -255,6 +258,7 @@ int arch_setup_features(void *ehdr_p, void *phdr_p,
>         current->thread.cet.ibt_enabled = 0;
>         current->thread.cet.ibt_bitmap_addr = 0;
>         current->thread.cet.ibt_bitmap_size = 0;
> +       current->thread.cet.locked = 0;
>         if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
>                 if (shstk) {
>                         err = cet_setup_shstk();
> diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
> index 43a57d284a22..259b92664981 100644
> --- a/arch/x86/kernel/process.c
> +++ b/arch/x86/kernel/process.c
> @@ -795,6 +795,12 @@ long do_arch_prctl_common(struct task_struct *task, int option,
>                 return get_cpuid_mode();
>         case ARCH_SET_CPUID:
>                 return set_cpuid_mode(task, cpuid_enabled);
> +       case ARCH_CET_STATUS:
> +       case ARCH_CET_DISABLE:
> +       case ARCH_CET_LOCK:
> +       case ARCH_CET_ALLOC_SHSTK:
> +       case ARCH_CET_LEGACY_BITMAP:
> +               return prctl_cet(option, cpuid_enabled);
>         }
>
>         return -EINVAL;
> --
> 2.17.1
>
