Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB6736B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 10:31:22 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 76so139550308itj.0
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 07:31:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l192sor591275ioe.6.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Mar 2017 07:31:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170320011408.GA28871@WeideMacBook-Pro.local>
References: <20170317175034.4701-1-thgarnie@google.com> <20170319160333.GA1187@WeideMBP.lan>
 <CAJcbSZE5Kq4ew3hHSSpMkReNf54EVpetA0hU09YYtkE2j=8m9w@mail.gmail.com> <20170320011408.GA28871@WeideMacBook-Pro.local>
From: Thomas Garnier <thgarnie@google.com>
Date: Mon, 20 Mar 2017 07:31:17 -0700
Message-ID: <CAJcbSZFE9kgF81eHsbpQ_8Wsw-X=w93X=P8SHFqsaznEuF+XTQ@mail.gmail.com>
Subject: Re: [PATCH tip] x86/mm: Correct fixmap header usage on adaptable MODULES_END
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sun, Mar 19, 2017 at 6:14 PM, Wei Yang <richard.weiyang@gmail.com> wrote:
> On Sun, Mar 19, 2017 at 09:25:00AM -0700, Thomas Garnier wrote:
>>On Sun, Mar 19, 2017 at 9:03 AM, Wei Yang <richard.weiyang@gmail.com> wrote:
>>> On Fri, Mar 17, 2017 at 10:50:34AM -0700, Thomas Garnier wrote:
>>>>This patch remove fixmap header usage on non-x86 code that was
>>>>introduced by the adaptable MODULE_END change.
>>>
>>> Hi, Thomas
>>>
>>> In this patch, it looks you are trying to do two things for my understanding:
>>> 1. To include <asm/fixmap.h> in asm/pagetable_64.h and remove the include in
>>> some of the x86 files
>>> 2. Remove <asm/fixmap.h> in mm/vmalloc.c
>>>
>>> I think your change log covers the second task in the patch, but not not talk
>>> about the first task you did in the patch. If you could mention it in commit
>>> log, it would be good for maintain.
>>
>>I agree, I am not the best at writing commits (by far). What's the
>>best way for me to correct that? (the bot seem to have taken it).
>>
>
> Simply mention it in your commit log is enough to me.
>

I meant, do I send another patch or reply on in this thread and bot
will pick it up?

>>>
>>> BTW, I have little knowledge about MODULE_END. By searching the code
>>> MODULE_END is not used in arch/x86. If you would like to mention the commit
>>> which introduce the problem, it would be more helpful to review the code.
>>
>>It is used in many places in arch/x86, kasan, head64, fault etc..:
>>http://lxr.free-electrons.com/ident?i=MODULES_END
>>
>
> Oh, thanks :-)
>
>>>
>>>>
>>>>Signed-off-by: Thomas Garnier <thgarnie@google.com>
>>>>---
>>>>Based on tip:x86/mm
>>>>---
>>>> arch/x86/include/asm/pgtable_64.h | 1 +
>>>> arch/x86/kernel/module.c          | 1 -
>>>> arch/x86/mm/dump_pagetables.c     | 1 -
>>>> arch/x86/mm/kasan_init_64.c       | 1 -
>>>> mm/vmalloc.c                      | 4 ----
>>>> 5 files changed, 1 insertion(+), 7 deletions(-)
>>>>
>>>>diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
>>>>index 73c7ccc38912..67608d4abc2c 100644
>>>>--- a/arch/x86/include/asm/pgtable_64.h
>>>>+++ b/arch/x86/include/asm/pgtable_64.h
>>>>@@ -13,6 +13,7 @@
>>>> #include <asm/processor.h>
>>>> #include <linux/bitops.h>
>>>> #include <linux/threads.h>
>>>>+#include <asm/fixmap.h>
>>>>
>>>
>>> Hmm... I see in both pgtable_32.h and pgtable_64.h will include <asm/fixmap.h>
>>> after this change. And pgtable_32.h and pgtable_64.h will be included only in
>>> pgtable.h. So is it possible to include <asm/fixmap.h> in pgtable.h for once
>>> instead of include it in both files? Any concerns you would have?
>>
>>I am not sure I understood. Only 64-bit need this header to correctly
>>get MODULES_END, that's why I added it to pgtable_64.h only. I tried
>>to add it lower before and ran into multiple header errors.
>>
>
> When you look in to pgtable_64.h, you would see it includes <asm/fixmap.h>
> too. Hmm... If only 64-bit need this header, would it be possible to remote it
> from pgtable_32.h?
>

I see that you mean, I can test to see if putting fixmap in pgtable.h
will be enough.

>
>>>
>>>> extern pud_t level3_kernel_pgt[512];
>>>> extern pud_t level3_ident_pgt[512];
>>>>diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
>>>>index fad61caac75e..477ae806c2fa 100644
>>>>--- a/arch/x86/kernel/module.c
>>>>+++ b/arch/x86/kernel/module.c
>>>>@@ -35,7 +35,6 @@
>>>> #include <asm/page.h>
>>>> #include <asm/pgtable.h>
>>>> #include <asm/setup.h>
>>>>-#include <asm/fixmap.h>
>>>>
>>>> #if 0
>>>> #define DEBUGP(fmt, ...)                              \
>>>>diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
>>>>index 75efeecc85eb..58b5bee7ea27 100644
>>>>--- a/arch/x86/mm/dump_pagetables.c
>>>>+++ b/arch/x86/mm/dump_pagetables.c
>>>>@@ -20,7 +20,6 @@
>>>>
>>>> #include <asm/kasan.h>
>>>> #include <asm/pgtable.h>
>>>>-#include <asm/fixmap.h>
>>>>
>>>> /*
>>>>  * The dumper groups pagetable entries of the same type into one, and for
>>>>diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
>>>>index 1bde19ef86bd..8d63d7a104c3 100644
>>>>--- a/arch/x86/mm/kasan_init_64.c
>>>>+++ b/arch/x86/mm/kasan_init_64.c
>>>>@@ -9,7 +9,6 @@
>>>>
>>>> #include <asm/tlbflush.h>
>>>> #include <asm/sections.h>
>>>>-#include <asm/fixmap.h>
>>>>
>>>> extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>>>> extern struct range pfn_mapped[E820_X_MAX];
>>>>diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>>>index b7d2a23349f4..0dd80222b20b 100644
>>>>--- a/mm/vmalloc.c
>>>>+++ b/mm/vmalloc.c
>>>>@@ -36,10 +36,6 @@
>>>> #include <asm/tlbflush.h>
>>>> #include <asm/shmparam.h>
>>>>
>>>>-#ifdef CONFIG_X86
>>>>-# include <asm/fixmap.h>
>>>>-#endif
>>>>-
>>>> #include "internal.h"
>>>>
>>>> struct vfree_deferred {
>>>>--
>>>>2.12.0.367.g23dc2f6d3c-goog
>>>
>>> --
>>> Wei Yang
>>> Help you, Help me
>>
>>
>>
>>--
>>Thomas
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
