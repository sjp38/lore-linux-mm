Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C4F8F2806D7
	for <linux-mm@kvack.org>; Tue,  9 May 2017 09:03:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e131so86158046pfh.7
        for <linux-mm@kvack.org>; Tue, 09 May 2017 06:03:15 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id v77si8203522pfa.176.2017.05.09.06.03.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 06:03:14 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id CD5FF2034A
	for <linux-mm@kvack.org>; Tue,  9 May 2017 13:03:13 +0000 (UTC)
Received: from mail-ua0-f178.google.com (mail-ua0-f178.google.com [209.85.217.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 159AA202C8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 13:03:11 +0000 (UTC)
Received: by mail-ua0-f178.google.com with SMTP id e28so7653390uah.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 06:03:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d36207ef-a4b3-24ef-40e4-9e6a22b092cb@intel.com>
References: <cover.1494160201.git.luto@kernel.org> <983c5ee661d8fe8a70c596c4e77076d11ce3f80a.1494160201.git.luto@kernel.org>
 <d36207ef-a4b3-24ef-40e4-9e6a22b092cb@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 9 May 2017 06:02:49 -0700
Message-ID: <CALCETrXO2etzB55ZYk9xy4=8bWQC1+mv877tJHg-tOUpWGk6qw@mail.gmail.com>
Subject: Re: [RFC 03/10] x86/mm: Make the batched unmap TLB flush API more generic
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Sasha Levin <sasha.levin@oracle.com>

On Mon, May 8, 2017 at 8:34 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 05/07/2017 05:38 AM, Andy Lutomirski wrote:
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index f6838015810f..2e568c82f477 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -579,25 +579,12 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
>>  void try_to_unmap_flush(void)
>>  {
>>       struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
>> -     int cpu;
>>
>>       if (!tlb_ubc->flush_required)
>>               return;
>>
>> -     cpu = get_cpu();
>> -
>> -     if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask)) {
>> -             count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
>> -             local_flush_tlb();
>> -             trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>> -     }
>> -
>> -     if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids)
>> -             flush_tlb_others(&tlb_ubc->cpumask, NULL, 0, TLB_FLUSH_ALL);
>> -     cpumask_clear(&tlb_ubc->cpumask);
>>       tlb_ubc->flush_required = false;
>>       tlb_ubc->writable = false;
>> -     put_cpu();
>>  }
>>
>>  /* Flush iff there are potentially writable TLB entries that can race with IO */
>> @@ -613,7 +600,7 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
>>  {
>>       struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
>>
>> -     cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
>> +     arch_tlbbatch_add_mm(&tlb_ubc->arch, mm);
>>       tlb_ubc->flush_required = true;
>>
>>       /*
>
> Looking at this patch in isolation, how can this be safe?  It removes
> TLB flushes from the generic code.  Do other patches in the series fix
> this up?

Hmm?  Unless I totally screwed this up, this patch just moves the
flushes around -- it shouldn't remove any flushes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
