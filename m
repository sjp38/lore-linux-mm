Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 170A56B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:01:33 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so96130872pac.3
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 23:01:32 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id lb4si31367230pbc.153.2015.08.09.23.01.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Sun, 09 Aug 2015 23:01:32 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 10 Aug 2015 11:31:28 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 75F1E3940053
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 11:31:24 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7A61GAL32637026
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 11:31:16 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7A61DEa009214
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 11:31:14 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 2/7] mm: kasan: introduce generic kasan_populate_zero_shadow()
In-Reply-To: <1437756119-12817-3-git-send-email-a.ryabinin@samsung.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com> <1437756119-12817-3-git-send-email-a.ryabinin@samsung.com>
Date: Mon, 10 Aug 2015 11:31:12 +0530
Message-ID: <87mvxzptqv.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Andrey Ryabinin <a.ryabinin@samsung.com> writes:

> Introduce generic kasan_populate_zero_shadow(start, end).
> This function maps kasan_zero_page to the [start, end] addresses.
>
> In follow on patches it will be used for ARMv8 (and maybe other
> architectures) and will replace x86_64 specific populate_zero_shadow().
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

This assume that we can have shared pgtable_t in generic code ? Is that
true for generic code ? Even if it is we may want to allow some arch to
override this ? On ppc64, we store the hardware hash page table slot
number in pte_t, Hence we won't be able to share pgtable_t. 



> ---
>  arch/x86/mm/kasan_init_64.c |  14 ----
>  include/linux/kasan.h       |   8 +++
>  mm/kasan/Makefile           |   2 +-
>  mm/kasan/kasan_init.c       | 151 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 160 insertions(+), 15 deletions(-)
>  create mode 100644 mm/kasan/kasan_init.c
>
> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> index e1840f3..812086c 100644
> --- a/arch/x86/mm/kasan_init_64.c
> +++ b/arch/x86/mm/kasan_init_64.c
> @@ -12,20 +12,6 @@
>  extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>  extern struct range pfn_mapped[E820_X_MAX];
>  
> -static pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
> -static pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
> -static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> -
> -/*

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
