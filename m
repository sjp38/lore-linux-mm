Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 442D46B0314
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 17:24:08 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v74so5511875oie.10
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:24:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v187si14886414oie.325.2017.06.06.14.24.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 14:24:07 -0700 (PDT)
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com [209.85.213.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A1B3E23A0E
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 21:24:06 +0000 (UTC)
Received: by mail-vk0-f48.google.com with SMTP id p85so86568085vkd.3
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 14:24:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <C5EDE308-D2EA-490E-A76F-258E7B9A56E9@gmail.com>
References: <cover.1496701658.git.luto@kernel.org> <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
 <C5EDE308-D2EA-490E-A76F-258E7B9A56E9@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 6 Jun 2017 14:23:45 -0700
Message-ID: <CALCETrVrMtzYVUsLwjN6kuSXr-AF+_V-gYDs8J++zHa_9Bw0BQ@mail.gmail.com>
Subject: Re: [RFC 05/11] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Mon, Jun 5, 2017 at 6:39 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
>
>> On Jun 5, 2017, at 3:36 PM, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> x86's lazy TLB mode used to be fairly weak -- it would switch to
>> init_mm the first time it tried to flush a lazy TLB.  This meant an
>> unnecessary CR3 write and, if the flush was remote, an unnecessary
>> IPI.
>>
>> Rewrite it entirely.  When we enter lazy mode, we simply remove the
>> cpu from mm_cpumask.  This means that we need a way to figure out
>> whether we've missed a flush when we switch back out of lazy mode.
>> I use the tlb_gen machinery to track whether a context is up to
>> date.
>>
>
> [snip]
>
>> @@ -67,133 +67,118 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>> {
>>
>
> [snip]
>
>> +             /* Resume remote flushes and then read tlb_gen. */
>> +             cpumask_set_cpu(cpu, mm_cpumask(next));
>> +             next_tlb_gen = atomic64_read(&next->context.tlb_gen);
>
> It seems correct, but it got me somewhat confused at first.
>
> Perhaps it worth a comment that a memory barrier is not needed since
> cpumask_set_cpu() uses a locked-instruction. Otherwise, somebody may
> even copy-paste it to another architecture...

Agreed.  I'll do something here.

>
> Thanks,
> Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
