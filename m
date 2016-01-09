Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBC9828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 21:20:25 -0500 (EST)
Received: by mail-io0-f180.google.com with SMTP id 77so272854286ioc.2
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 18:20:25 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id qg4si3365315igb.21.2016.01.08.18.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 18:20:25 -0800 (PST)
Received: by mail-ig0-x232.google.com with SMTP id t15so64001749igr.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 18:20:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com>
References: <cover.1452294700.git.luto@kernel.org>
	<a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
	<CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
	<CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com>
Date: Fri, 8 Jan 2016 18:20:24 -0800
Message-ID: <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com>
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Oleg Nesterov <oleg@redhat.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>

On Fri, Jan 8, 2016 at 4:18 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>
>>  - on pcid setups, wouldn't invpcid_flush_single_context() be better?
>
> I played with that and it was slower.  I don't pretend that makes any sense.

Ugh. I guess reading and writing cr3 has been optimized.

>> And yes, that means that we'd require X86_FEATURE_INVPCID in order to
>> use X86_FEATURE_PCID, but that seems fine.
>
> I have an SNB "Extreme" with PCID but not INVPCID, and there could be
> a whole generation of servers like that.  I think we should fully
> support them.

Can you check the timings? IOW, is it a win on SNB?

I think originally Intel only had two actual bits of process context
ID in the TLB, and it was meant to be used for virtualization or
something. Together with the hashing (to make it always appear as 12
bits to software - a nice idea but also means that the hardware ends
up invalidating more than software really expects), it may not work
all that well.

That _could_ explain why the original patch from intel didn't work.

> We might be able to get away with just disabling preemption instead of
> IRQs, at least if mm == active_mm.

I'm not convinced it is all that much faster. Of course, it's nicer on
non-preempt, but nobody seems to run things that way.

>> Or is there some reason you wanted the odd flags version? If so, that
>> should be documented.
>
> What do you mean "odd"?

It's odd because it makes no sense for non-pcid (christ, I wish Intel
had just called it "asid" instead, "pcid" always makes me react to
"pci"), and I think it would make more sense to pair up the pcid case
with the invpcid rather than have those preemption rules here.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
