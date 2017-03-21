Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0ED56B0351
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:00:47 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id k6so15502173itb.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 09:00:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v82sor256052iod.126.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Mar 2017 09:00:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170321015254.GA12487@WeideMacBook-Pro.local>
References: <20170320194024.60749-1-thgarnie@google.com> <20170321015254.GA12487@WeideMacBook-Pro.local>
From: Thomas Garnier <thgarnie@google.com>
Date: Tue, 21 Mar 2017 09:00:43 -0700
Message-ID: <CAJcbSZHST2+DgX-Ye2HRrVWq1+RpgzkSS5WQNikH307+D4FChA@mail.gmail.com>
Subject: Re: [PATCH tip v2] x86/mm: Correct fixmap header usage on adaptable MODULES_END
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@suse.de>, Hugh Dickins <hughd@google.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Mon, Mar 20, 2017 at 6:52 PM, Wei Yang <richard.weiyang@gmail.com> wrote:
> On Mon, Mar 20, 2017 at 12:40:24PM -0700, Thomas Garnier wrote:
>>This patch removes fixmap headers on non-x86 code introduced by the
>>adaptable MODULE_END change. It is also removed in the 32-bit pgtable
>>header. Instead, it is added  by default in the pgtable generic header
>>for both architectures.
>>
>>Signed-off-by: Thomas Garnier <thgarnie@google.com>
>>---
>> arch/x86/include/asm/pgtable.h    | 1 +
>> arch/x86/include/asm/pgtable_32.h | 1 -
>> arch/x86/kernel/module.c          | 1 -
>> arch/x86/mm/dump_pagetables.c     | 1 -
>> arch/x86/mm/kasan_init_64.c       | 1 -
>> mm/vmalloc.c                      | 4 ----
>> 6 files changed, 1 insertion(+), 8 deletions(-)
>>
>>diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
>>index 6f6f351e0a81..78d1fc32e947 100644
>>--- a/arch/x86/include/asm/pgtable.h
>>+++ b/arch/x86/include/asm/pgtable.h
>>@@ -598,6 +598,7 @@ pte_t *populate_extra_pte(unsigned long vaddr);
>> #include <linux/mm_types.h>
>> #include <linux/mmdebug.h>
>> #include <linux/log2.h>
>>+#include <asm/fixmap.h>
>>
>> static inline int pte_none(pte_t pte)
>> {
>>diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgtable_32.h
>>index fbc73360aea0..bfab55675c16 100644
>>--- a/arch/x86/include/asm/pgtable_32.h
>>+++ b/arch/x86/include/asm/pgtable_32.h
>>@@ -14,7 +14,6 @@
>>  */
>> #ifndef __ASSEMBLY__
>> #include <asm/processor.h>
>>-#include <asm/fixmap.h>
>> #include <linux/threads.h>
>> #include <asm/paravirt.h>
>>
>
> Yep, I thinks the above two is what I mean.
>
>>diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
>>index fad61caac75e..477ae806c2fa 100644
>>--- a/arch/x86/kernel/module.c
>>+++ b/arch/x86/kernel/module.c
>>@@ -35,7 +35,6 @@
>> #include <asm/page.h>
>> #include <asm/pgtable.h>
>> #include <asm/setup.h>
>>-#include <asm/fixmap.h>
>>
>
> Hmm... your code is already merged in upstream?

It was merged on tip x86, it was my point before (as Ingo says after too).

>
> When I look into current Torvalds tree, it looks not include the <asm/fixmap.h>
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kernel/module.c
>
> Which tree your change is based on? Do I miss something?

tip mm x86, before the first patch.

>
>> #if 0
>> #define DEBUGP(fmt, ...)                              \
>>diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
>>index 75efeecc85eb..58b5bee7ea27 100644
>>--- a/arch/x86/mm/dump_pagetables.c
>>+++ b/arch/x86/mm/dump_pagetables.c
>>@@ -20,7 +20,6 @@
>>
>> #include <asm/kasan.h>
>> #include <asm/pgtable.h>
>>-#include <asm/fixmap.h>
>>
>
> The same as this one.
>
>> /*
>>  * The dumper groups pagetable entries of the same type into one, and for
>>diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>>index 1bde19ef86bd..8d63d7a104c3 100644
>>--- a/arch/x86/mm/kasan_init_64.c
>>+++ b/arch/x86/mm/kasan_init_64.c
>>@@ -9,7 +9,6 @@
>>
>> #include <asm/tlbflush.h>
>> #include <asm/sections.h>
>>-#include <asm/fixmap.h>
>>
>> extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>> extern struct range pfn_mapped[E820_X_MAX];
>>diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>index b7d2a23349f4..0dd80222b20b 100644
>>--- a/mm/vmalloc.c
>>+++ b/mm/vmalloc.c
>>@@ -36,10 +36,6 @@
>> #include <asm/tlbflush.h>
>> #include <asm/shmparam.h>
>>
>>-#ifdef CONFIG_X86
>>-# include <asm/fixmap.h>
>>-#endif
>>-
>> #include "internal.h"
>>
>> struct vfree_deferred {
>>--
>>2.12.0.367.g23dc2f6d3c-goog
>
>
> At last, you have tested both on x86-32 and x86-64 platform?

I did, I know have a collected set of configs for both 32-bit and
64-bit and a script merging each config and building. It should reduce
the risk of exotic configurations not working.

>
> --
> Wei Yang
> Help you, Help me



-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
