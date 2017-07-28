Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED2B2802FE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 22:06:09 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b184so15460382oih.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 19:06:09 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 81si6792881oie.274.2017.07.27.19.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 19:06:08 -0700 (PDT)
Received: from mail-ua0-f179.google.com (mail-ua0-f179.google.com [209.85.217.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D854B22CC1
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:06:07 +0000 (UTC)
Received: by mail-ua0-f179.google.com with SMTP id q25so135209078uah.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 19:06:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170727195357.GM277355@stormcage.americas.sgi.com>
References: <cover.1498022414.git.luto@kernel.org> <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
 <20170622145013.n3slk7ip6wpany5d@pd.tnic> <CALCETrUA-+9ORRXFrYdyEg5ZQOEbDFrwq4uuRWDb89V49QRBWw@mail.gmail.com>
 <20170727195357.GM277355@stormcage.americas.sgi.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 27 Jul 2017 19:05:46 -0700
Message-ID: <CALCETrW=_K7wmR+jv_e0RtYUUcm7yMEMf0Z_OrnXb8Mciu+wpw@mail.gmail.com>
Subject: Re: [PATCH v3 06/11] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Banman <abanman@hpe.com>
Cc: Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

> On Jul 27, 2017, at 3:53 PM, Andrew Banman <abanman@hpe.com> wrote:
>
>> On Thu, Jun 22, 2017 at 10:47:29AM -0700, Andy Lutomirski wrote:
>>> On Thu, Jun 22, 2017 at 7:50 AM, Borislav Petkov <bp@alien8.de> wrote:
>>>> On Tue, Jun 20, 2017 at 10:22:12PM -0700, Andy Lutomirski wrote:
>>>> Rewrite it entirely.  When we enter lazy mode, we simply remove the
>>>> cpu from mm_cpumask.  This means that we need a way to figure out
>>>
>>> s/cpu/CPU/
>>
>> Done.
>>
>>>
>>>> whether we've missed a flush when we switch back out of lazy mode.
>>>> I use the tlb_gen machinery to track whether a context is up to
>>>> date.
>>>>
>>>> Note to reviewers: this patch, my itself, looks a bit odd.  I'm
>>>> using an array of length 1 containing (ctx_id, tlb_gen) rather than
>>>> just storing tlb_gen, and making it at array isn't necessary yet.
>>>> I'm doing this because the next few patches add PCID support, and,
>>>> with PCID, we need ctx_id, and the array will end up with a length
>>>> greater than 1.  Making it an array now means that there will be
>>>> less churn and therefore less stress on your eyeballs.
>>>>
>>>> NB: This is dubious but, AFAICT, still correct on Xen and UV.
>>>> xen_exit_mmap() uses mm_cpumask() for nefarious purposes and this
>>>> patch changes the way that mm_cpumask() works.  This should be okay,
>>>> since Xen *also* iterates all online CPUs to find all the CPUs it
>>>> needs to twiddle.
>>>
>>> This whole text should be under the "---" line below if we don't want it
>>> in the commit message.
>>
>> I figured that some future reader of this patch might actually want to
>> see this text, though.
>>
>>>
>>>>
>>>> The UV tlbflush code is rather dated and should be changed.
>>
>> And I'd definitely like the UV maintainers to notice this part, now or
>> in the future :)  I don't want to personally touch the UV code with a
>> ten-foot pole, but it really should be updated by someone who has a
>> chance of getting it right and being able to test it.
>
> Noticed! We're aware of these changes and we're planning on updating this
> code in the future. Presently the BAU tlb shootdown feature is working well
> on our recent hardware.

:)

I would suggest reworking it to hook the SMP function call
infrastructure instead of the TLB shootdown code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
