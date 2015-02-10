Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id D7F666B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 12:25:46 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id vb8so33204260obc.11
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 09:25:46 -0800 (PST)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id o185si7869468oif.15.2015.02.10.09.25.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 09:25:46 -0800 (PST)
Received: by mail-oi0-f45.google.com with SMTP id i138so11195130oig.4
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 09:25:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
Date: Tue, 10 Feb 2015 09:25:45 -0800
Message-ID: <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
Subject: Re: [PATCH] x86, kaslr: propagate base load address calculation
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Feb 10, 2015 at 5:17 AM, Jiri Kosina <jkosina@suse.cz> wrote:
> Commit e2b32e678 ("x86, kaslr: randomize module base load address") makes
> the base address for module to be unconditionally randomized in case when
> CONFIG_RANDOMIZE_BASE is defined and "nokaslr" option isn't present on the
> commandline.
>
> This is not consistent with how choose_kernel_location() decides whether
> it will randomize kernel load base.
>
> Namely, CONFIG_HIBERNATION disables kASLR (unless "kaslr" option is
> explicitly specified on kernel commandline), which makes the state space
> larger than what module loader is looking at. IOW CONFIG_HIBERNATION &&
> CONFIG_RANDOMIZE_BASE is a valid config option, kASLR wouldn't be applied
> by default in that case, but module loader is not aware of that.
>
> Instead of fixing the logic in module.c, this patch takes more generic
> aproach, and exposes __KERNEL_OFFSET macro, which calculates the real
> offset that has been established by choose_kernel_location() during boot.
> This can be used later by other kernel code as well (such as, but not
> limited to, live patching).
>
> OOPS offset dumper and module loader are converted to that they make use
> of this macro as well.
>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Ah, yes! This is a good clean up. Thanks! I do see, however, one
corner case remaining: kASLR randomized to 0 offset. This will force
module ASLR off, which I think is a mistake. Perhaps we need to export
the kaslr state as a separate item to be checked directly, instead of
using __KERNEL_OFFSET?

-Kees

> ---
>  arch/x86/include/asm/page_types.h |  4 ++++
>  arch/x86/kernel/module.c          | 10 +---------
>  arch/x86/kernel/setup.c           |  4 ++--
>  3 files changed, 7 insertions(+), 11 deletions(-)
>
> diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
> index f97fbe3..7f18eaf 100644
> --- a/arch/x86/include/asm/page_types.h
> +++ b/arch/x86/include/asm/page_types.h
> @@ -46,6 +46,10 @@
>
>  #ifndef __ASSEMBLY__
>
> +/* Return kASLR relocation offset */
> +extern char _text[];
> +#define __KERNEL_OFFSET ((unsigned long)&_text - __START_KERNEL)
> +
>  extern int devmem_is_allowed(unsigned long pagenr);
>
>  extern unsigned long max_low_pfn_mapped;
> diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
> index e69f988..d236bd2 100644
> --- a/arch/x86/kernel/module.c
> +++ b/arch/x86/kernel/module.c
> @@ -46,21 +46,13 @@ do {                                                        \
>
>  #ifdef CONFIG_RANDOMIZE_BASE
>  static unsigned long module_load_offset;
> -static int randomize_modules = 1;
>
>  /* Mutex protects the module_load_offset. */
>  static DEFINE_MUTEX(module_kaslr_mutex);
>
> -static int __init parse_nokaslr(char *p)
> -{
> -       randomize_modules = 0;
> -       return 0;
> -}
> -early_param("nokaslr", parse_nokaslr);
> -
>  static unsigned long int get_module_load_offset(void)
>  {
> -       if (randomize_modules) {
> +       if (__KERNEL_OFFSET) {
>                 mutex_lock(&module_kaslr_mutex);
>                 /*
>                  * Calculate the module_load_offset the first time this
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index c4648ada..08124a1 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -833,8 +833,8 @@ dump_kernel_offset(struct notifier_block *self, unsigned long v, void *p)
>  {
>         pr_emerg("Kernel Offset: 0x%lx from 0x%lx "
>                  "(relocation range: 0x%lx-0x%lx)\n",
> -                (unsigned long)&_text - __START_KERNEL, __START_KERNEL,
> -                __START_KERNEL_map, MODULES_VADDR-1);
> +                __KERNEL_OFFSET, __START_KERNEL, __START_KERNEL_map,
> +                MODULES_VADDR-1);
>
>         return 0;
>  }
>
> --
> Jiri Kosina
> SUSE Labs



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
