Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85CC36B0359
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:01:44 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y136so65930332iof.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 09:01:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 189sor232649iti.7.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Mar 2017 09:01:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170321071725.GA15782@gmail.com>
References: <20170320194024.60749-1-thgarnie@google.com> <20170321071725.GA15782@gmail.com>
From: Thomas Garnier <thgarnie@google.com>
Date: Tue, 21 Mar 2017 09:01:42 -0700
Message-ID: <CAJcbSZEgRZ+BVyWHmQ8mVxXmmBNYf7XRHTEByCEvO2TJ8THgpg@mail.gmail.com>
Subject: Re: [PATCH tip v2] x86/mm: Correct fixmap header usage on adaptable MODULES_END
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@suse.de>, Hugh Dickins <hughd@google.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Wei Yang <richard.weiyang@gmail.com>

On Tue, Mar 21, 2017 at 12:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Thomas Garnier <thgarnie@google.com> wrote:
>
>> This patch removes fixmap headers on non-x86 code introduced by the
>> adaptable MODULE_END change. It is also removed in the 32-bit pgtable
>> header. Instead, it is added  by default in the pgtable generic header
>> for both architectures.
>>
>> Signed-off-by: Thomas Garnier <thgarnie@google.com>
>> ---
>>  arch/x86/include/asm/pgtable.h    | 1 +
>>  arch/x86/include/asm/pgtable_32.h | 1 -
>>  arch/x86/kernel/module.c          | 1 -
>>  arch/x86/mm/dump_pagetables.c     | 1 -
>>  arch/x86/mm/kasan_init_64.c       | 1 -
>>  mm/vmalloc.c                      | 4 ----
>>  6 files changed, 1 insertion(+), 8 deletions(-)
>
> So I already have v1 and there's no explanation about the changes from v1 to v2.
>
> The interdiff between v1 and v2 is below, it only affects x86, presumably it's
> done to simplify the header usage slightly: instead of including fixmap.h in both
> pgtable_32/64.h it's only included in the common pgtable.h file.
>

Correct, simplify the header and explains better.

> That's a sensible cleanup of the original patch and I'd rather not rebase it (as
> tip:x86/mm has other changes as well), so could I've applied the delta cleanup on
> top of the existing changes, with its own changelog.

I understand. Thanks for merging a clean-up version of this patch.

>
> Thanks,
>
>         Ingo
>
> ============>
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 84f6ec4d47ec..9f6809545269 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -601,6 +601,7 @@ pte_t *populate_extra_pte(unsigned long vaddr);
>  #include <linux/mm_types.h>
>  #include <linux/mmdebug.h>
>  #include <linux/log2.h>
> +#include <asm/fixmap.h>
>
>  static inline int pte_none(pte_t pte)
>  {
> diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgtable_32.h
> index fbc73360aea0..bfab55675c16 100644
> --- a/arch/x86/include/asm/pgtable_32.h
> +++ b/arch/x86/include/asm/pgtable_32.h
> @@ -14,7 +14,6 @@
>   */
>  #ifndef __ASSEMBLY__
>  #include <asm/processor.h>
> -#include <asm/fixmap.h>
>  #include <linux/threads.h>
>  #include <asm/paravirt.h>
>
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> index 13709cf74ab6..1a4bc71534d4 100644
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -13,7 +13,6 @@
>  #include <asm/processor.h>
>  #include <linux/bitops.h>
>  #include <linux/threads.h>
> -#include <asm/fixmap.h>
>
>  extern pud_t level3_kernel_pgt[512];
>  extern pud_t level3_ident_pgt[512];
>



-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
