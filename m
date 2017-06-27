Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 409DB6B02FA
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 19:07:38 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id h64so28901522iod.9
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:07:38 -0700 (PDT)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id w71si3709355itc.8.2017.06.27.16.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 16:07:37 -0700 (PDT)
Received: by mail-io0-x229.google.com with SMTP id h64so26538841iod.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:07:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1497544976-7856-7-git-send-email-s.mesoraca16@gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com> <1497544976-7856-7-git-send-email-s.mesoraca16@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 27 Jun 2017 16:07:36 -0700
Message-ID: <CAGXu5jJ2DykaU6bbFGRcOaZK9nn5dFUYQ6UjXCq9Y97DwYpCyA@mail.gmail.com>
Subject: Re: [RFC v2 6/9] Creation of "pagefault_handler_x86" LSM hook
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-security-module <linux-security-module@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Jun 15, 2017 at 9:42 AM, Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
> Creation of a new hook to let LSM modules handle user-space pagefaults on
> x86.
> It can be used to avoid segfaulting the originating process.
> If it's the case it can modify process registers before returning.
> This is not a security feature by itself, it's a way to soften some
> unwanted side-effects of restrictive security features.
> In particular this is used by S.A.R.A. can be used to implement what
> PaX call "trampoline emulation" that, in practice, allow for some specific
> code sequences to be executed even if they are in non executable memory.
> This may look like a bad thing at first, but you have to consider
> that:
> - This allows for strict memory restrictions (e.g. W^X) to stay on even
>   when they should be turned off. And, even if this emulation
>   makes those features less effective, it's still better than having
>   them turned off completely.
> - The only code sequences emulated are trampolines used to make
>   function calls. In many cases, when you have the chance to
>   make arbitrary memory writes, you can already manipulate the
>   control flow of the program by overwriting function pointers or
>   return values. So, in many cases, the "trampoline emulation"
>   doesn't introduce new exploit vectors.
> - It's a feature that can be turned on only if needed, on a per
>   executable file basis.

Can this be made arch-agnostic? It seems a per-arch register-handling
routine would be needed, though. :(

-Kees

>
> Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
> ---
>  arch/x86/mm/fault.c       |  6 ++++++
>  include/linux/lsm_hooks.h |  9 +++++++++
>  include/linux/security.h  | 11 +++++++++++
>  security/security.c       | 11 +++++++++++
>  4 files changed, 37 insertions(+)
>
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 8ad91a0..b75b81a 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -15,6 +15,7 @@
>  #include <linux/prefetch.h>            /* prefetchw                    */
>  #include <linux/context_tracking.h>    /* exception_enter(), ...       */
>  #include <linux/uaccess.h>             /* faulthandler_disabled()      */
> +#include <linux/security.h>            /* security_pagefault_handler   */
>
>  #include <asm/cpufeature.h>            /* boot_cpu_has, ...            */
>  #include <asm/traps.h>                 /* dotraplinkage, ...           */
> @@ -1358,6 +1359,11 @@ static inline bool smap_violation(int error_code, struct pt_regs *regs)
>                         local_irq_enable();
>         }
>
> +       if (unlikely(security_pagefault_handler_x86(regs,
> +                                                   error_code,
> +                                                   address)))
> +               return;
> +
>         perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
>
>         if (error_code & PF_WRITE)
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index 33dab16..da487e5 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -488,6 +488,11 @@
>   *     @vmflags contains requested the vmflags.
>   *     Return 0 if the operation is allowed to continue otherwise return
>   *     the appropriate error code.
> + * @pagefault_handler_x86:
> + *     Handle pagefaults on x86.
> + *     @regs contains process' registers.
> + *     @error_code contains error code for the pagefault.
> + *     @address contains the address that caused the pagefault.
>   * @file_lock:
>   *     Check permission before performing file locking operations.
>   *     Note: this hook mediates both flock and fcntl style locks.
> @@ -1483,6 +1488,9 @@
>         int (*file_mprotect)(struct vm_area_struct *vma, unsigned long reqprot,
>                                 unsigned long prot);
>         int (*check_vmflags)(vm_flags_t vmflags);
> +       int (*pagefault_handler_x86)(struct pt_regs *regs,
> +                                    unsigned long error_code,
> +                                    unsigned long address);
>         int (*file_lock)(struct file *file, unsigned int cmd);
>         int (*file_fcntl)(struct file *file, unsigned int cmd,
>                                 unsigned long arg);
> @@ -1754,6 +1762,7 @@ struct security_hook_heads {
>         struct list_head mmap_file;
>         struct list_head file_mprotect;
>         struct list_head check_vmflags;
> +       struct list_head pagefault_handler_x86;
>         struct list_head file_lock;
>         struct list_head file_fcntl;
>         struct list_head file_set_fowner;
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 8701872..3b91999 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -301,6 +301,9 @@ int security_mmap_file(struct file *file, unsigned long prot,
>  int security_file_mprotect(struct vm_area_struct *vma, unsigned long reqprot,
>                            unsigned long prot);
>  int security_check_vmflags(vm_flags_t vmflags);
> +int __maybe_unused security_pagefault_handler_x86(struct pt_regs *regs,
> +                                                 unsigned long error_code,
> +                                                 unsigned long address);
>  int security_file_lock(struct file *file, unsigned int cmd);
>  int security_file_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
>  void security_file_set_fowner(struct file *file);
> @@ -829,6 +832,14 @@ static inline int security_check_vmflags(vm_flags_t vmflags)
>         return 0;
>  }
>
> +static inline int __maybe_unused security_pagefault_handler_x86(
> +                                               struct pt_regs *regs,
> +                                               unsigned long error_code,
> +                                               unsigned long address)
> +{
> +       return 0;
> +}
> +
>  static inline int security_file_lock(struct file *file, unsigned int cmd)
>  {
>         return 0;
> diff --git a/security/security.c b/security/security.c
> index 7e45846..f7df697 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -905,6 +905,17 @@ int security_check_vmflags(vm_flags_t vmflags)
>         return call_int_hook(check_vmflags, 0, vmflags);
>  }
>
> +int __maybe_unused security_pagefault_handler_x86(struct pt_regs *regs,
> +                                                 unsigned long error_code,
> +                                                 unsigned long address)
> +{
> +       return call_int_hook(pagefault_handler_x86,
> +                            0,
> +                            regs,
> +                            error_code,
> +                            address);
> +}
> +
>  int security_file_lock(struct file *file, unsigned int cmd)
>  {
>         return call_int_hook(file_lock, 0, file, cmd);
> --
> 1.9.1
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
