Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E95C6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 16:55:06 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id l2so6232823ywc.21
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 13:55:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w25-v6sor2861021ybi.141.2018.03.02.13.55.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 13:55:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <85f426c1bbbff5b8a512c79c4a92055d1e7db1cd.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com> <85f426c1bbbff5b8a512c79c4a92055d1e7db1cd.1520017438.git.andreyknvl@google.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Fri, 2 Mar 2018 13:55:03 -0800
Message-ID: <CAFKCwrjk7V_43qDWWFSNRyUO5p=LeYVSwCjZwvz+em7u4xco8Q@mail.gmail.com>
Subject: Re: [RFC PATCH 05/14] khwasan: initialize shadow to 0xff
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

If this memset has noticeable performance/memory impact, we could
treat memory tags as bitwise negation of pointer tags, and then shadow
would be initialized to 0 instead of 0xff.

On Fri, Mar 2, 2018 at 11:44 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> A KHWASAN shadow memory cell contains a memory tag, that corresponds to
> the tag in the top byte of the pointer, that points to that memory. The
> native top byte value of kernel pointers is 0xff, so with KHWASAN we
> need to initialize shadow memory to 0xff. This commit does that.
> ---
>  arch/arm64/mm/kasan_init.c | 11 ++++++++++-
>  include/linux/kasan.h      |  8 ++++++++
>  mm/kasan/common.c          |  7 +++++++
>  3 files changed, 25 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index dabfc1ecda3d..d4bceba60010 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -90,6 +90,10 @@ static void __init kasan_pte_populate(pmd_t *pmdp, unsigned long addr,
>         do {
>                 phys_addr_t page_phys = early ? __pa_symbol(kasan_zero_page)
>                                               : kasan_alloc_zeroed_page(node);
> +#if KASAN_SHADOW_INIT != 0
> +               if (!early)
> +                       memset(__va(page_phys), KASAN_SHADOW_INIT, PAGE_SIZE);
> +#endif
>                 next = addr + PAGE_SIZE;
>                 set_pte(ptep, pfn_pte(__phys_to_pfn(page_phys), PAGE_KERNEL));
>         } while (ptep++, addr = next, addr != end && pte_none(READ_ONCE(*ptep)));
> @@ -139,6 +143,11 @@ asmlinkage void __init kasan_early_init(void)
>                 KASAN_SHADOW_END - (1UL << (64 - KASAN_SHADOW_SCALE_SHIFT)));
>         BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_START, PGDIR_SIZE));
>         BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
> +
> +#if KASAN_SHADOW_INIT != 0
> +       memset(kasan_zero_page, KASAN_SHADOW_INIT, PAGE_SIZE);
> +#endif
> +
>         kasan_pgd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, NUMA_NO_NODE,
>                            true);
>  }
> @@ -235,7 +244,7 @@ void __init kasan_init(void)
>                 set_pte(&kasan_zero_pte[i],
>                         pfn_pte(sym_to_pfn(kasan_zero_page), PAGE_KERNEL_RO));
>
> -       memset(kasan_zero_page, 0, PAGE_SIZE);
> +       memset(kasan_zero_page, KASAN_SHADOW_INIT, PAGE_SIZE);
>         cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
>
>         /* At this point kasan is fully initialized. Enable error messages */
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 3c45e273a936..c34f413b0eac 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -139,6 +139,8 @@ static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
>
>  #ifdef CONFIG_KASAN_CLASSIC
>
> +#define KASAN_SHADOW_INIT 0
> +
>  void kasan_cache_shrink(struct kmem_cache *cache);
>  void kasan_cache_shutdown(struct kmem_cache *cache);
>
> @@ -149,4 +151,10 @@ static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
>
>  #endif /* CONFIG_KASAN_CLASSIC */
>
> +#ifdef CONFIG_KASAN_TAGS
> +
> +#define KASAN_SHADOW_INIT 0xff
> +
> +#endif /* CONFIG_KASAN_TAGS */
> +
>  #endif /* LINUX_KASAN_H */
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 08f6c8cb9f84..f4ccb9425655 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -253,6 +253,9 @@ int kasan_module_alloc(void *addr, size_t size)
>                         __builtin_return_address(0));
>
>         if (ret) {
> +#if KASAN_SHADOW_INIT != 0
> +               __memset(ret, KASAN_SHADOW_INIT, shadow_size);
> +#endif
>                 find_vm_area(addr)->flags |= VM_KASAN;
>                 kmemleak_ignore(ret);
>                 return 0;
> @@ -297,6 +300,10 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
>                 if (!ret)
>                         return NOTIFY_BAD;
>
> +#if KASAN_SHADOW_INIT != 0
> +               __memset(ret, KASAN_SHADOW_INIT, shadow_end - shadow_start);
> +#endif
> +
>                 kmemleak_ignore(ret);
>                 return NOTIFY_OK;
>         }
> --
> 2.16.2.395.g2e18187dfd-goog
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
