Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB99F6B0007
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 20:03:55 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id i203-v6so258216ywg.7
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 17:03:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p70-v6sor752082yba.79.2018.06.26.17.03.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Jun 2018 17:03:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1530017430-5394-1-git-send-email-crecklin@redhat.com>
References: <1530017430-5394-1-git-send-email-crecklin@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 26 Jun 2018 17:03:52 -0700
Message-ID: <CAGXu5j+ELUHuyjkUU358DkQieKhxQ5Z6h5HM7qYE_AQvVr4R3g@mail.gmail.com>
Subject: Re: [v2 PATCH] add param that allows bootline control of hardened usercopy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris von Recklinghausen <crecklin@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, Paolo Abeni <pabeni@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

nit: I would expect the version to trail "PATCH" in the subject, like:
[PATCH v2]

On Tue, Jun 26, 2018 at 5:50 AM, Chris von Recklinghausen
<crecklin@redhat.com> wrote:
> Enabling HARDENED_USER_COPY causes measurable regressions in the
> networking performances, up to 8% under UDP flood.

Please include the details on the benchmark (from the email in the
thread), include the backtrace to help other people that might
discover the same issues. (Also, the name is "HARDENED_USERCOPY".)

> A generic distro may want to enable HARDENED_USER_COPY in their default
> kernel config, but at the same time, such distro may want to be able to
> avoid the performance penalties in with the default configuration and
> disable the stricter check on a per-boot basis.
>
> This change adds a boot parameter that to conditionally disable
> HARDENED_USERCOPY at boot time.
>
> v1->v2:
>         remove CONFIG_HUC_DEFAULT_OFF
>         default is now enabled, boot param disables
>         move check to __check_object_size so as to not break optimization of
>                 __builtin_constant_p()
>         include linux/atomic.h before linux/jump_label.h
>
> Signed-off-by: Chris von Recklinghausen <crecklin@redhat.com>
> ---
>  .../admin-guide/kernel-parameters.rst         |  1 +
>  .../admin-guide/kernel-parameters.txt         |  3 +++
>  include/linux/thread_info.h                   |  5 ++++
>  mm/usercopy.c                                 | 27 +++++++++++++++++++
>  4 files changed, 36 insertions(+)
>
> diff --git a/Documentation/admin-guide/kernel-parameters.rst b/Documentation/admin-guide/kernel-parameters.rst
> index b8d0bc07ed0a..87a1200a1db6 100644
> --- a/Documentation/admin-guide/kernel-parameters.rst
> +++ b/Documentation/admin-guide/kernel-parameters.rst
> @@ -100,6 +100,7 @@ parameter is applicable::
>         FB      The frame buffer device is enabled.
>         FTRACE  Function tracing enabled.
>         GCOV    GCOV profiling is enabled.
> +       HUC     Hardened usercopy is enabled

I'd prefer the new HUC item here was just left off: it isn't a class
of parameters yet (it's a single item). See below.

>         HW      Appropriate hardware is enabled.
>         IA-64   IA-64 architecture is enabled.
>         IMA     Integrity measurement architecture is enabled.
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index efc7aa7a0670..d14be0038aed 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -816,6 +816,9 @@
>         disable=        [IPV6]
>                         See Documentation/networking/ipv6.txt.
>
> +       disable_hardened_usercopy [HUC]
> +                       Disable hardened usercopy checks
> +

Instead of "disable_hardened_usercopy" let's make this a parseable
item. I would model it after "rodata=" or other things like that.
Perhaps the following text:

        hardened_usercopy=
                        [KNL] Under CONFIG_HARDENED_USERCOPY, whether
                        hardening is enabled for this boot. Hardened
                        usercopy checking is used to protect the kernel
                        from reading or writing beyond known memory
                        allocation boundaries as a proactive defense
                        against bounds-checking flaws in the kernel's
                        copy_to_user()/copy_from_user() interface.
                on      Perform hardened usercopy checks (default).
                off     Disable hardened usercopy checks.


>         disable_radix   [PPC]
>                         Disable RADIX MMU mode on POWER9
>
> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
> index 8d8821b3689a..ab24fe2d3f87 100644
> --- a/include/linux/thread_info.h
> +++ b/include/linux/thread_info.h
> @@ -109,6 +109,11 @@ static inline int arch_within_stack_frames(const void * const stack,
>  #endif
>
>  #ifdef CONFIG_HARDENED_USERCOPY
> +#include <linux/atomic.h>
> +#include <linux/jump_label.h>
> +
> +DECLARE_STATIC_KEY_FALSE(bypass_usercopy_checks);
> +
>  extern void __check_object_size(const void *ptr, unsigned long n,
>                                         bool to_user);
>
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index e9e9325f7638..6a1265e1a54e 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -20,6 +20,8 @@
>  #include <linux/sched/task.h>
>  #include <linux/sched/task_stack.h>
>  #include <linux/thread_info.h>
> +#include <linux/atomic.h>
> +#include <linux/jump_label.h>
>  #include <asm/sections.h>
>
>  /*
> @@ -248,6 +250,9 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
>   */
>  void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>  {
> +       if (static_branch_likely(&bypass_usercopy_checks))
> +               return;

This should be unlikely (if CONFIG_HARDENED_USERCOPY is built, we want
the fast-path to avoid the jmp instruction).

> +
>         /* Skip all tests if size is zero. */
>         if (!n)
>                 return;
> @@ -279,3 +284,25 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>         check_kernel_text_object((const unsigned long)ptr, n, to_user);
>  }
>  EXPORT_SYMBOL(__check_object_size);
> +
> +DEFINE_STATIC_KEY_FALSE(bypass_usercopy_checks);

This needs to be __ro_after_init otherwise it remains a target for
attacks. Though it seems unlikely for it to be useful without the call
to static_branch_enable(), see my thoughts below on non-jump-label
architectures...

> +EXPORT_SYMBOL(bypass_usercopy_checks);
> +
> +static bool disable_huc_atboot = false;

Since this is static, you can just call it "disable_checks". The "huc"
is redundant since that's the subject of the .c file already, and
"atboot" will be obvious from the next suggestion: it is never used
outside of __init, so it can be marked __initdata.

> +
> +static int __init parse_disable_usercopy(char *str)
> +{
> +       disable_huc_atboot = true;
> +       return 1;
> +}
> +
> +static int __init set_disable_usercopy(void)
> +{
> +       if (disable_huc_atboot == true)
> +               static_branch_enable(&bypass_usercopy_checks);
> +       return 1;
> +}
> +
> +__setup("disable_hardened_usercopy", parse_disable_usercopy);
> +
> +late_initcall(set_disable_usercopy);
> --
> 2.17.0
>

One concern remains:

$ git grep HAVE_ARCH_JUMP_LABEL
...
arch/arm/Kconfig:       select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL &&
!CPU_ENDIAN_BE32 && MMU
arch/arm64/Kconfig:     select HAVE_ARCH_JUMP_LABEL
arch/mips/Kconfig:      select HAVE_ARCH_JUMP_LABEL
arch/powerpc/Kconfig:   select HAVE_ARCH_JUMP_LABEL
arch/s390/Kconfig:      select HAVE_ARCH_JUMP_LABEL
arch/sparc/Kconfig:     select HAVE_ARCH_JUMP_LABEL if SPARC64
arch/x86/Kconfig:       select HAVE_ARCH_JUMP_LABEL

This means for non-jump-label architectures (e.g. old arm, sparc32,
riscv) this leaves a branch test against a writable target in memory
(i.e. the fall-back implementation of static keys):

#define static_branch_likely(x)         likely(static_key_enabled(&(x)->key))
#define static_branch_unlikely(x)       unlikely(static_key_enabled(&(x)->key))

But the earlier __ro_after_init change should, I think, solve my main
concern there. These architectures, however, will still have a
memory-load-branch (though marked "unlikely"), but I think I can live
with that.

-Kees

-- 
Kees Cook
Pixel Security
