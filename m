Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F25B6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:48:45 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id q44so11416976otd.7
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:48:45 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u62si562129oib.351.2017.06.22.07.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 07:48:44 -0700 (PDT)
Received: from mail-ua0-f176.google.com (mail-ua0-f176.google.com [209.85.217.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7415422B4B
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 14:48:43 +0000 (UTC)
Received: by mail-ua0-f176.google.com with SMTP id j53so19890901uaa.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:48:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170622072449.4rc4bnvucn7usuak@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <91f24a6145b2077f992902891f8fa59abe5c8696.1498022414.git.luto@kernel.org>
 <20170621184424.eixb2jdyy66xq4hg@pd.tnic> <CALCETrWEGrVJj3Jcc3U38CYh01GKgGpLqW=eN_-7nMo4t=V5Mg@mail.gmail.com>
 <20170622072449.4rc4bnvucn7usuak@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Jun 2017 07:48:21 -0700
Message-ID: <CALCETrVdT449KiEJ7wo8g9B6NyTSQhuXpYL76b=ToJhKwKyVXg@mail.gmail.com>
Subject: Re: [PATCH v3 05/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 12:24 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Wed, Jun 21, 2017 at 07:46:05PM -0700, Andy Lutomirski wrote:
>> > I'm certainly still missing something here:
>> >
>> > We have f->new_tlb_gen and mm_tlb_gen to control the flushing, i.e., we
>> > do once
>> >
>> >         bump_mm_tlb_gen(mm);
>> >
>> > and once
>> >
>> >         info.new_tlb_gen = bump_mm_tlb_gen(mm);
>> >
>> > and in both cases, the bumping is done on mm->context.tlb_gen.
>> >
>> > So why isn't that enough to do the flushing and we have to consult
>> > info.new_tlb_gen too?
>>
>> The issue is a possible race.  Suppose we start at tlb_gen == 1 and
>> then two concurrent flushes happen.  The first flush is a full flush
>> and sets tlb_gen to 2.  The second is a partial flush and sets tlb_gen
>> to 3.  If the second flush gets propagated to a given CPU first and it
>
> Maybe I'm still missing something, which is likely...
>
> but if the second flush gets propagated to the CPU first, the CPU will
> have local tlb_gen 1 and thus enforce a full flush anyway because we
> will go 1 -> 3 on that particular CPU. Or?
>

Yes, exactly.  Which means I'm probably just misunderstanding your
original question.  Can you re-ask it?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
