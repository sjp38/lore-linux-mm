Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C607B6B0338
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 11:23:17 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id a38so32654614ota.12
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:23:17 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u133si1724144oif.100.2017.06.23.08.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 08:23:17 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2F60722B6E
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 15:23:16 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id j53so38594640uaa.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:23:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cb8aad11-6e02-bc8e-8613-63f63a22bc77@oracle.com>
References: <cover.1498022414.git.luto@kernel.org> <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
 <cb8aad11-6e02-bc8e-8613-63f63a22bc77@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 23 Jun 2017 08:22:54 -0700
Message-ID: <CALCETrUbob1yucAgPA+tbmZ+DAXppFUxMKT=PCns0U+_QixRPw@mail.gmail.com>
Subject: Re: [PATCH v3 06/11] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>

On Fri, Jun 23, 2017 at 6:34 AM, Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
>> diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
>> index 1d7a7213a310..f5df56fb8b5c 100644
>> --- a/arch/x86/xen/mmu_pv.c
>> +++ b/arch/x86/xen/mmu_pv.c
>> @@ -1005,8 +1005,7 @@ static void xen_drop_mm_ref(struct mm_struct *mm)
>>         /* Get the "official" set of cpus referring to our pagetable. */
>>         if (!alloc_cpumask_var(&mask, GFP_ATOMIC)) {
>>                 for_each_online_cpu(cpu) {
>> -                       if (!cpumask_test_cpu(cpu, mm_cpumask(mm))
>> -                           && per_cpu(xen_current_cr3, cpu) !=
>> __pa(mm->pgd))
>> +                       if (per_cpu(xen_current_cr3, cpu) !=
>> __pa(mm->pgd))
>>                                 continue;
>>                         smp_call_function_single(cpu,
>> drop_mm_ref_this_cpu, mm, 1);
>>                 }
>>
>
>
> I wonder then whether
>         cpumask_copy(mask, mm_cpumask(mm));
> immediately below is needed.

Probably not.  I'll change it to cpumask_clear().  Then the two cases
in that function match better.

>
> -boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
