Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3A5B6B0314
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 17:34:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j65so1917264oib.1
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:34:29 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l43si14396104ota.279.2017.06.06.14.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 14:34:28 -0700 (PDT)
Received: from mail-vk0-f51.google.com (mail-vk0-f51.google.com [209.85.213.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0362523A0C
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 21:34:28 +0000 (UTC)
Received: by mail-vk0-f51.google.com with SMTP id 191so3373518vko.2
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:34:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1496776285.20270.64.camel@redhat.com>
References: <cover.1496701658.git.luto@kernel.org> <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
 <1496776285.20270.64.camel@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 6 Jun 2017 14:34:06 -0700
Message-ID: <CALCETrVX73+vHJMVYaddygEFj42oc3ShoUrXOm_s6CBwEP1peA@mail.gmail.com>
Subject: Re: [RFC 05/11] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, Jun 6, 2017 at 12:11 PM, Rik van Riel <riel@redhat.com> wrote:
> On Mon, 2017-06-05 at 15:36 -0700, Andy Lutomirski wrote:
>
>> +++ b/arch/x86/include/asm/mmu_context.h
>> @@ -122,8 +122,10 @@ static inline void switch_ldt(struct mm_struct
>> *prev, struct mm_struct *next)
>>
>>  static inline void enter_lazy_tlb(struct mm_struct *mm, struct
>> task_struct *tsk)
>>  {
>> -     if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
>> -             this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
>> +     int cpu = smp_processor_id();
>> +
>> +     if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
>> +             cpumask_clear_cpu(cpu, mm_cpumask(mm));
>>  }
>
> This is an atomic write to a shared cacheline,
> every time a CPU goes idle.
>
> I am not sure you really want to do this, since
> there are some workloads out there that have a
> crazy number of threads, which go idle hundreds,
> or even thousands of times a second, on dozens
> of CPUs at a time. *cough*Java*cough*

It seems to me that the set of workloads on which this patch will hurt
performance is rather limited.  We'd need an mm with a lot of threads,
probably spread among a lot of nodes, that is constantly going idle
and non-idle on multiple CPUs on the same node, where there's nothing
else happening on those CPUs.

If there's a low-priority background task on the relevant CPUs, then
existing kernels will act just like patched kernels: the same bit will
be written by the same atomic operation at the same times.

>
> Keeping track of the state in a CPU-local variable,
> written with a non-atomic write, would be much more
> CPU cache friendly here.

We could, but then handing remote flushes becomes more complicated.

My inclination would be to keep the patch as is and, if this is
actually a problem, think about solving it more generally.  The real
issue is that we need a way to reasonably efficiently find the set of
CPUs for which a given mm is currently loaded and non-lazy.  A simple
improvement would be to split up mm_cpumask so that we'd have one
cache line per node.  (And we'd presumably allow several mms to share
the same pile of memory.)  Or we could go all out and use percpu state
only and iterate over all online CPUs when flushing (ick!).  Or
something in between.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
