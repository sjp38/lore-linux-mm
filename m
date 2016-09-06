Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C740A6B0038
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 21:22:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m139so68413405wma.0
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 18:22:20 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id v2si28195045wjh.115.2016.09.05.18.22.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Sep 2016 18:22:19 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id w12so6516612wmf.1
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 18:22:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <95a853538da28c64dfc877c60549ec79ed7a5d69.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org> <95a853538da28c64dfc877c60549ec79ed7a5d69.1452294700.git.luto@kernel.org>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Tue, 6 Sep 2016 09:22:18 +0800
Message-ID: <CANRm+CycVgg2XYC=j0FsfE1ZyutSWMEHwVPpLfbFmtuTpTg5Xg@mail.gmail.com>
Subject: Re: [RFC 05/13] x86/mm: Add barriers and document switch_mm-vs-flush synchronization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: the arch/x86 maintainers <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, stable@vger.kernel.org

Hi Andy,
2016-01-09 7:15 GMT+08:00 Andy Lutomirski <luto@kernel.org>:
> When switch_mm activates a new pgd, it also sets a bit that tells
> other CPUs that the pgd is in use so that tlb flush IPIs will be
> sent.  In order for that to work correctly, the bit needs to be
> visible prior to loading the pgd and therefore starting to fill the
> local TLB.
>
> Document all the barriers that make this work correctly and add a
> couple that were missing.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/mmu_context.h | 33 ++++++++++++++++++++++++++++++++-
>  arch/x86/mm/tlb.c                  | 29 ++++++++++++++++++++++++++---
>  2 files changed, 58 insertions(+), 4 deletions(-)
>
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
> index 379cd3658799..1edc9cd198b8 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -116,8 +116,34 @@ static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
>  #endif
>                 cpumask_set_cpu(cpu, mm_cpumask(next));
>
> -               /* Re-load page tables */
> +               /*
> +                * Re-load page tables.
> +                *
> +                * This logic has an ordering constraint:
> +                *
> +                *  CPU 0: Write to a PTE for 'next'
> +                *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
> +                *  CPU 1: set bit 1 in next's mm_cpumask
> +                *  CPU 1: load from the PTE that CPU 0 writes (implicit)
> +                *
> +                * We need to prevent an outcome in which CPU 1 observes
> +                * the new PTE value and CPU 0 observes bit 1 clear in
> +                * mm_cpumask.  (If that occurs, then the IPI will never
> +                * be sent, and CPU 0's TLB will contain a stale entry.)

I misunderstand this comments, CPU0 write to a PTE for 'next', and
CPU0 observes bit 1 clear in mm_cpumask, so CPU0 won't kick IPI to
CPU1, why CPU0's TLB will contain a stale entry instead of CPU1?

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
