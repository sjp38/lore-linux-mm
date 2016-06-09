Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 296E16B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 13:19:45 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h144so87831622ita.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 10:19:45 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id c81si3479784oib.69.2016.06.09.10.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 10:19:44 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id s139so74060365oie.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 10:19:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1464405413-7209-1-git-send-email-namit@vmware.com>
References: <1464405413-7209-1-git-send-email-namit@vmware.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 9 Jun 2016 10:19:24 -0700
Message-ID: <CALCETrUVmuXNpmFwe54iHjKsYmJEn4WSJ0RDO44V=mFMBwyuow@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Change barriers before TLB flushes to smp_mb__after_atomic
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jerome Marchand <jmarchan@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, May 27, 2016 at 8:16 PM, Nadav Amit <namit@vmware.com> wrote:
> When (current->active_mm != mm), flush_tlb_page() does not perform a
> memory barrier. In practice, this memory barrier is not needed since in
> the existing call-sites the PTE is modified using atomic-operations.
> This patch therefore modifies the existing smp_mb in flush_tlb_page to
> smp_mb__after_atomic and adds the missing one, while documenting the new
> assumption of flush_tlb_page.
>
> In addition smp_mb__after_atomic is also added to
> set_tlb_ubc_flush_pending, since it makes a similar implicit assumption
> and omits the memory barrier.
>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> ---
>  arch/x86/mm/tlb.c | 9 ++++++++-
>  mm/rmap.c         | 3 +++
>  2 files changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index fe9b9f7..2534333 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -242,6 +242,10 @@ out:
>         preempt_enable();
>  }
>
> +/*
> + * Calls to flush_tlb_page must be preceded by atomic PTE change or
> + * explicit memory-barrier.
> + */
>  void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
>  {
>         struct mm_struct *mm = vma->vm_mm;
> @@ -259,8 +263,11 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
>                         leave_mm(smp_processor_id());
>
>                         /* Synchronize with switch_mm. */
> -                       smp_mb();
> +                       smp_mb__after_atomic();
>                 }
> +       } else {
> +               /* Synchronize with switch_mm. */
> +               smp_mb__after_atomic();
>         }
>
>         if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 307b555..60ab0fe 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -613,6 +613,9 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
>  {
>         struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
>
> +       /* Synchronize with switch_mm. */
> +       smp_mb__after_atomic();
> +
>         cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
>         tlb_ubc->flush_required = true;
>
> --
> 2.7.4
>

This looks fine for x86, but I have no idea whether other
architectures are okay with it.  akpm?  mm folks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
