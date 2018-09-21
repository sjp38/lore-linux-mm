Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id A82928E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:05:08 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v8-v6so2853614ybl.5
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:05:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v128-v6sor965988ybe.202.2018.09.21.12.05.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 12:05:07 -0700 (PDT)
Received: from mail-yb1-f175.google.com (mail-yb1-f175.google.com. [209.85.219.175])
        by smtp.gmail.com with ESMTPSA id b6-v6sm461636ywe.71.2018.09.21.12.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 12:05:05 -0700 (PDT)
Received: by mail-yb1-f175.google.com with SMTP id w7-v6so5862777ybm.7
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:05:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1536874298-23492-3-git-send-email-rick.p.edgecombe@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com> <1536874298-23492-3-git-send-email-rick.p.edgecombe@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 21 Sep 2018 12:05:03 -0700
Message-ID: <CAGXu5jJ9nZYbVn5xdi7nsMJRD6ScLeWP2DWjrD8yEfwi-XXcRw@mail.gmail.com>
Subject: Re: [PATCH v6 2/4] x86/modules: Increase randomization for modules
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, Sep 13, 2018 at 2:31 PM, Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
> This changes the behavior of the KASLR logic for allocating memory for the text
> sections of loadable modules. It randomizes the location of each module text
> section with about 17 bits of entropy in typical use. This is enabled on X86_64
> only. For 32 bit, the behavior is unchanged.
>
> It refactors existing code around module randomization somewhat. There are now
> three different behaviors for x86 module_alloc depending on config.
> RANDOMIZE_BASE=n, and RANDOMIZE_BASE=y ARCH=x86_64, and RANDOMIZE_BASE=y
> ARCH=i386. The refactor of the existing code is to try to clearly show what
> those behaviors are without having three separate versions or threading the
> behaviors in a bunch of little spots. The reason it is not enabled on 32 bit
> yet is because the module space is much smaller and simulations haven't been
> run to see how it performs.
>
> The new algorithm breaks the module space in two, a random area and a backup
> area. It first tries to allocate at a number of randomly located starting pages
> inside the random section without purging any lazy free vmap areas and
> triggering the associated TLB flush. If this fails, it will try again a number
> of times allowing for purges if needed. It also saves any position that could
> have succeeded if it was allowed to purge, which doubles the chances of finding
> a spot that would fit. Finally if those both fail to find a position it will
> allocate in the backup area. The backup area base will be offset in the same
> way as the current algorithm does for the base area, 1024 possible locations.
>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>

I'm excited to get fine-grained module randomization. I think it's a
good first step to getting other fine-grained KASLR in other places.
Thanks for working on this!

> ---
>  arch/x86/include/asm/pgtable_64_types.h |   7 ++
>  arch/x86/kernel/module.c                | 165 +++++++++++++++++++++++++++-----
>  2 files changed, 149 insertions(+), 23 deletions(-)
>
> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
> index 04edd2d..5e26369 100644
> --- a/arch/x86/include/asm/pgtable_64_types.h
> +++ b/arch/x86/include/asm/pgtable_64_types.h
> @@ -143,6 +143,13 @@ extern unsigned int ptrs_per_p4d;
>  #define MODULES_END            _AC(0xffffffffff000000, UL)
>  #define MODULES_LEN            (MODULES_END - MODULES_VADDR)
>
> +/*
> + * Dedicate the first part of the module space to a randomized area when KASLR
> + * is in use.  Leave the remaining part for a fallback if we are unable to
> + * allocate in the random area.
> + */
> +#define MODULES_RAND_LEN       PAGE_ALIGN((MODULES_LEN/3)*2)
> +
>  #define ESPFIX_PGD_ENTRY       _AC(-2, UL)
>  #define ESPFIX_BASE_ADDR       (ESPFIX_PGD_ENTRY << P4D_SHIFT)
>
> diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
> index f58336a..d50a0a0 100644
> --- a/arch/x86/kernel/module.c
> +++ b/arch/x86/kernel/module.c
> @@ -48,34 +48,151 @@ do {                                                       \
>  } while (0)
>  #endif
>
> -#ifdef CONFIG_RANDOMIZE_BASE
> +#if defined(CONFIG_X86_64) && defined(CONFIG_RANDOMIZE_BASE)
> +static inline unsigned long get_modules_rand_len(void)
> +{
> +       return MODULES_RAND_LEN;
> +}
> +#else
> +static inline unsigned long get_modules_rand_len(void)
> +{
> +       BUILD_BUG();
> +       return 0;
> +}
> +
> +inline bool kaslr_enabled(void);
> +#endif
> +
> +static inline int kaslr_randomize_each_module(void)
> +{
> +       return IS_ENABLED(CONFIG_RANDOMIZE_BASE)
> +               && IS_ENABLED(CONFIG_X86_64)
> +               && kaslr_enabled();
> +}
> +
> +static inline int kaslr_randomize_base(void)
> +{
> +       return IS_ENABLED(CONFIG_RANDOMIZE_BASE)
> +               && !IS_ENABLED(CONFIG_X86_64)
> +               && kaslr_enabled();
> +}
> +
>  static unsigned long module_load_offset;
> +static const unsigned long NR_NO_PURGE = 5000;
> +static const unsigned long NR_TRY_PURGE = 5000;
>
>  /* Mutex protects the module_load_offset. */
>  static DEFINE_MUTEX(module_kaslr_mutex);
>
>  static unsigned long int get_module_load_offset(void)
>  {
> -       if (kaslr_enabled()) {
> -               mutex_lock(&module_kaslr_mutex);
> -               /*
> -                * Calculate the module_load_offset the first time this
> -                * code is called. Once calculated it stays the same until
> -                * reboot.
> -                */
> -               if (module_load_offset == 0)
> -                       module_load_offset =
> -                               (get_random_int() % 1024 + 1) * PAGE_SIZE;
> -               mutex_unlock(&module_kaslr_mutex);
> -       }
> +       mutex_lock(&module_kaslr_mutex);
> +       /*
> +        * Calculate the module_load_offset the first time this
> +        * code is called. Once calculated it stays the same until
> +        * reboot.
> +        */
> +       if (module_load_offset == 0)
> +               module_load_offset = (get_random_int() % 1024 + 1) * PAGE_SIZE;
> +       mutex_unlock(&module_kaslr_mutex);
> +
>         return module_load_offset;
>  }
> -#else
> -static unsigned long int get_module_load_offset(void)
> +
> +static unsigned long get_module_vmalloc_start(void)
>  {
> -       return 0;
> +       if (kaslr_randomize_each_module())
> +               return MODULES_VADDR + get_modules_rand_len()
> +                                       + get_module_load_offset();
> +       else if (kaslr_randomize_base())
> +               return MODULES_VADDR + get_module_load_offset();
> +
> +       return MODULES_VADDR;
> +}

I would find this much more readable as:

static unsigned long get_module_vmalloc_start(void)
{
       unsigned long addr = MODULES_VADDR;

       if (kaslr_randomize_base())
              addr += get_module_load_offset();

       if (kaslr_randomize_each_module())
               addr += get_modules_rand_len();

       return addr;
}



> +
> +static void *try_module_alloc(unsigned long addr, unsigned long size,
> +                                       int try_purge)
> +{
> +       const unsigned long vm_flags = 0;
> +
> +       return __vmalloc_node_try_addr(addr, size, GFP_KERNEL, PAGE_KERNEL_EXEC,
> +                                       vm_flags, NUMA_NO_NODE, try_purge,
> +                                       __builtin_return_address(0));
> +}
> +
> +/*
> + * Find a random address to try that won't obviously not fit. Random areas are
> + * allowed to overflow into the backup area
> + */
> +static unsigned long get_rand_module_addr(unsigned long size)
> +{
> +       unsigned long nr_max_pos = (MODULES_LEN - size) / MODULE_ALIGN + 1;
> +       unsigned long nr_rnd_pos = get_modules_rand_len() / MODULE_ALIGN;
> +       unsigned long nr_pos = min(nr_max_pos, nr_rnd_pos);
> +
> +       unsigned long module_position_nr = get_random_long() % nr_pos;
> +       unsigned long offset = module_position_nr * MODULE_ALIGN;
> +
> +       return MODULES_VADDR + offset;
> +}
> +
> +/*
> + * Try to allocate in the random area. First 5000 times without purging, then
> + * 5000 times with purging. If these fail, return NULL.
> + */
> +static void *try_module_randomize_each(unsigned long size)
> +{
> +       void *p = NULL;
> +       unsigned int i;
> +       unsigned long last_lazy_free_blocked = 0;
> +
> +       /* This will have a guard page */
> +       unsigned long va_size = PAGE_ALIGN(size) + PAGE_SIZE;
> +
> +       if (!kaslr_randomize_each_module())
> +               return NULL;
> +
> +       /* Make sure there is at least one address that might fit. */
> +       if (va_size < PAGE_ALIGN(size) || va_size > MODULES_LEN)
> +               return NULL;
> +
> +       /* Try to find a spot that doesn't need a lazy purge */
> +       for (i = 0; i < NR_NO_PURGE; i++) {
> +               unsigned long addr = get_rand_module_addr(va_size);
> +
> +               /* First try to avoid having to purge */
> +               p = try_module_alloc(addr, size, 0);
> +
> +               /*
> +                * Save the last value that was blocked by a
> +                * lazy purge area.
> +                */
> +               if (IS_ERR(p) && PTR_ERR(p) == -EUCLEAN)
> +                       last_lazy_free_blocked = addr;
> +               else if (!IS_ERR(p))
> +                       return p;
> +       }
> +
> +       /* Try the most recent spot that could be used after a lazy purge */
> +       if (last_lazy_free_blocked) {
> +               p = try_module_alloc(last_lazy_free_blocked, size, 1);
> +
> +               if (!IS_ERR(p))
> +                       return p;
> +       }
> +
> +       /* Look for more spots and allow lazy purges */
> +       for (i = 0; i < NR_TRY_PURGE; i++) {
> +               unsigned long addr = get_rand_module_addr(va_size);
> +
> +               /* Give up and allow for purges */
> +               p = try_module_alloc(addr, size, 1);
> +
> +               if (!IS_ERR(p))
> +                       return p;
> +       }
> +       return NULL;
>  }
> -#endif
>
>  void *module_alloc(unsigned long size)
>  {
> @@ -84,16 +201,18 @@ void *module_alloc(unsigned long size)
>         if (PAGE_ALIGN(size) > MODULES_LEN)
>                 return NULL;
>
> -       p = __vmalloc_node_range(size, MODULE_ALIGN,
> -                                   MODULES_VADDR + get_module_load_offset(),
> -                                   MODULES_END, GFP_KERNEL,
> -                                   PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
> -                                   __builtin_return_address(0));
> +       p = try_module_randomize_each(size);
> +
> +       if (!p)
> +               p = __vmalloc_node_range(size, MODULE_ALIGN,
> +                               get_module_vmalloc_start(), MODULES_END,
> +                               GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
> +                               NUMA_NO_NODE, __builtin_return_address(0));

Instead of having two open-coded __vmalloc_node_range() calls left in
this after the change, can this be done in terms of a call to
try_module_alloc() instead? I see they're slightly different, but it
might be nice for making the two paths share more code.

> +
>         if (p && (kasan_module_alloc(p, size) < 0)) {
>                 vfree(p);
>                 return NULL;
>         }
> -
>         return p;
>  }
>
> --
> 2.7.4
>

Looks promising!

-Kees

-- 
Kees Cook
Pixel Security
