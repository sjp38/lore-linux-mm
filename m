Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D90616B02C3
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 23:09:52 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r74so19507179oie.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 20:09:52 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w20si239215oie.159.2017.06.22.20.09.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 20:09:52 -0700 (PDT)
Received: from mail-ua0-f174.google.com (mail-ua0-f174.google.com [209.85.217.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4D3E622B62
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:09:51 +0000 (UTC)
Received: by mail-ua0-f174.google.com with SMTP id g40so29670524uaa.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 20:09:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706222319330.2221@nanos>
References: <cover.1498022414.git.luto@kernel.org> <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
 <alpine.DEB.2.20.1706211159430.2328@nanos> <CALCETrUrwyMt+k4a-Tyh85Xiidr3zgEW7LKLnGDz90Z6jL9XtA@mail.gmail.com>
 <alpine.DEB.2.20.1706221037320.1885@nanos> <CALCETrVm9oQCpovr0aZcDXoG-8hOoYPMDyhYZJPSBNFGemXQNg@mail.gmail.com>
 <alpine.DEB.2.20.1706222319330.2221@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Jun 2017 20:09:29 -0700
Message-ID: <CALCETrU5VfJMOENEff8HCVn3mihtC_e3xN7wotSimnJujR5YeA@mail.gmail.com>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 2:22 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Thu, 22 Jun 2017, Andy Lutomirski wrote:
>> On Thu, Jun 22, 2017 at 5:21 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>> > Now one other optimization which should be trivial to add is to keep the 4
>> > asid context entries in cpu_tlbstate and cache the last asid in thread
>> > info. If that's still valid then use it otherwise unconditionally get a new
>> > one. That avoids the whole loop machinery and thread info is cache hot in
>> > the context switch anyway. Delta patch on top of your version below.
>>
>> I'm not sure I understand.  If an mm has ASID 0 on CPU 0 and ASID 1 on
>> CPU 1 and a thread in that mm bounces back and forth between those
>> CPUs, won't your patch cause it to flush every time?
>
> Yeah, I was too focussed on the non migratory case, where two tasks from
> different processes play rapid ping pong. That's what I was looking at for
> various reasons.
>
> There the cached asid really helps by avoiding the loop completely, but
> yes, the search needs to be done for the bouncing between CPUs case.
>
> So maybe a combo of those might be interesting.
>

I'm not too worried about optimizing away the loop.  It's a loop over
four or six things that are all in cachelines that we need anyway.  I
suspect that we'll never be able to see it in any microbenchmark, let
alone real application.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
