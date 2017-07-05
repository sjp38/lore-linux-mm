Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4D716B03A6
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 12:05:02 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id n2so36625731oig.12
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 09:05:02 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c134si17022364oig.88.2017.07.05.09.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 09:05:01 -0700 (PDT)
Received: from mail-vk0-f53.google.com (mail-vk0-f53.google.com [209.85.213.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D40AD22BD4
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 16:05:00 +0000 (UTC)
Received: by mail-vk0-f53.google.com with SMTP id 191so127297497vko.2
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 09:05:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170705121807.GF4941@worktop>
References: <cover.1498751203.git.luto@kernel.org> <cf600d28712daa8e2222c08a10f6c914edab54f2.1498751203.git.luto@kernel.org>
 <20170705121807.GF4941@worktop>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 5 Jul 2017 09:04:39 -0700
Message-ID: <CALCETrWivSq=qSN6DMBLXVRCo-EBOx_xvnQYXHojYHuG7SaWnQ@mail.gmail.com>
Subject: Re: [PATCH v4 10/10] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Wed, Jul 5, 2017 at 5:18 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, Jun 29, 2017 at 08:53:22AM -0700, Andy Lutomirski wrote:
>> @@ -104,18 +140,20 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
>>
>>               /* Resume remote flushes and then read tlb_gen. */
>>               cpumask_set_cpu(cpu, mm_cpumask(next));
>
> Barriers should have a comment... what is being ordered here against
> what?

How's this comment?

        /*
         * Resume remote flushes and then read tlb_gen.  We need to do
         * it in this order: any inc_mm_tlb_gen() caller that writes a
         * larger tlb_gen than we read here must see our cpu set in
         * mm_cpumask() so that it will know to flush us.  The barrier
         * here synchronizes with inc_mm_tlb_gen().
         */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
