Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD17828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 18:36:06 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id py5so101341661obc.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:36:06 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id r5si4135541obf.99.2016.01.13.15.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 15:36:06 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id is5so69047860obc.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:36:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com>
References: <cover.1452294700.git.luto@kernel.org> <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
 <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
 <CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com> <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 13 Jan 2016 15:35:46 -0800
Message-ID: <CALCETrVT7ePZPAySF45hhnhZ5cBKH0EvDGmxftHvUmZw2YxZjQ@mail.gmail.com>
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>

On Fri, Jan 8, 2016 at 6:20 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Jan 8, 2016 at 4:18 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>
>>>  - on pcid setups, wouldn't invpcid_flush_single_context() be better?
>>
>> I played with that and it was slower.  I don't pretend that makes any sense.
>
> Ugh. I guess reading and writing cr3 has been optimized.
>
>>> And yes, that means that we'd require X86_FEATURE_INVPCID in order to
>>> use X86_FEATURE_PCID, but that seems fine.
>>
>> I have an SNB "Extreme" with PCID but not INVPCID, and there could be
>> a whole generation of servers like that.  I think we should fully
>> support them.
>
> Can you check the timings? IOW, is it a win on SNB?

~80ns gain on SNB.  It's actually quite impressive on SNB: it knocks
the penalty for mm switches down to 20ns or so, which I find to be
fairly amazing.  (This is at 3.8GHz or thereabouts.)

>
> I think originally Intel only had two actual bits of process context
> ID in the TLB, and it was meant to be used for virtualization or
> something. Together with the hashing (to make it always appear as 12
> bits to software - a nice idea but also means that the hardware ends
> up invalidating more than software really expects), it may not work
> all that well.
>
> That _could_ explain why the original patch from intel didn't work.
>
>> We might be able to get away with just disabling preemption instead of
>> IRQs, at least if mm == active_mm.
>
> I'm not convinced it is all that much faster. Of course, it's nicer on
> non-preempt, but nobody seems to run things that way.

My current testing version has three different code paths now.  If
INVPCID and PCID are both available, then it uses INVPCID.  If PCID is
available but INVPCID is not, it does raw_local_irqsave.  If PCID is
not available, it just does the CR3 read/write.

Yeah, it's ugly, and it's a big blob of code to do something trivial,
but it seems to work and it should be the right thing to do in most
cases.

Can anyone here ask a hardware or microcode person what's going on
with CR3 writes possibly being faster than INVPCID?  Is there some
trick to it?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
