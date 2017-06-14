Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 033276B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:43:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l83so7437746oif.15
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:43:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 65si545661otr.207.2017.06.14.15.43.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 15:43:22 -0700 (PDT)
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com [209.85.213.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6948D239BE
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:43:21 +0000 (UTC)
Received: by mail-vk0-f48.google.com with SMTP id y70so8640629vky.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:43:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cc8596e6-8c6c-eb0c-4d59-ee3b97fe881f@intel.com>
References: <cover.1497415951.git.luto@kernel.org> <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
 <cc8596e6-8c6c-eb0c-4d59-ee3b97fe881f@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 14 Jun 2017 15:42:59 -0700
Message-ID: <CALCETrUi44LiuyizVh=bfntnvebiEVbvJz+7AwdyT647CJSZcg@mail.gmail.com>
Subject: Re: [PATCH v2 05/10] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Wed, Jun 14, 2017 at 3:33 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/13/2017 09:56 PM, Andy Lutomirski wrote:
>> -     if (cpumask_test_cpu(cpu, &batch->cpumask))
>> +     if (cpumask_test_cpu(cpu, &batch->cpumask)) {
>> +             local_irq_disable();
>>               flush_tlb_func_local(&info, TLB_LOCAL_SHOOTDOWN);
>> +             local_irq_enable();
>> +     }
>> +
>
> Could you talk a little about why this needs to be local_irq_disable()
> and not preempt_disable()?  Is it about the case where somebody is
> trying to call flush_tlb_func_*() from an interrupt handler?

It's to prevent flush_tlb_func_local() and flush_tlb_func_remote()
from being run concurrently, which would cause flush_tlb_func_common()
to be reentered.  Either we'd need to be very careful in
flush_tlb_func_common() to avoid races if this happened, or we could
just disable interrupts around flush_tlb_func_local().  The latter is
fast and easy.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
