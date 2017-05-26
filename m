Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA2376B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 22:02:03 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v80so257743792oie.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 19:02:03 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d84si13052770oib.189.2017.05.25.19.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 19:02:03 -0700 (PDT)
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com [209.85.213.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5135623A06
	for <linux-mm@kvack.org>; Fri, 26 May 2017 02:02:02 +0000 (UTC)
Received: by mail-vk0-f48.google.com with SMTP id x71so100387734vkd.0
        for <linux-mm@kvack.org>; Thu, 25 May 2017 19:02:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1495762747.29205.63.camel@redhat.com>
References: <cover.1495759610.git.luto@kernel.org> <61de238db6d9c9018db020c41047ce32dac64488.1495759610.git.luto@kernel.org>
 <1495762747.29205.63.camel@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 25 May 2017 19:01:40 -0700
Message-ID: <CALCETrVDpWL4kQbxNVWBX-OKuThoaYaqefbKY-dD0A2y4BgNfA@mail.gmail.com>
Subject: Re: [PATCH v3 2/8] x86/mm: Change the leave_mm() condition for local
 TLB flushes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, May 25, 2017 at 6:39 PM, Rik van Riel <riel@redhat.com> wrote:
> On Thu, 2017-05-25 at 17:47 -0700, Andy Lutomirski wrote:
>>
>> +++ b/arch/x86/mm/tlb.c
>> @@ -311,7 +311,7 @@ void flush_tlb_mm_range(struct mm_struct *mm,
>> unsigned long start,
>>               goto out;
>>       }
>>
>> -     if (!current->mm) {
>> +     if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
>>               leave_mm(smp_processor_id());
>
> Unless -mm changed leave_mm (I did not check), this
> is not quite correct yet.
>
> The reason is leave_mm (at least in the latest Linus
> tree) ignores the cpu argument for one of its checks.
>
> You should probably fix that in an earlier patch,
> assuming you haven't already done so in -mm.
>
> void leave_mm(int cpu)
> {
>         struct mm_struct *active_mm =
> this_cpu_read(cpu_tlbstate.active_mm);
>         if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
>                 BUG();
>         if (cpumask_test_cpu(cpu, mm_cpumask(active_mm))) {
>                 cpumask_clear_cpu(cpu, mm_cpumask(active_mm));
>                 load_cr3(swapper_pg_dir);

I agree it's odd, but what's the bug?  Both before and after, leave_mm
needed to be called with cpu == smp_processor_id(), and
smp_processor_id() warns if it's called in a preemptible context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
