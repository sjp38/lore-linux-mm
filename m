Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 475FA828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 18:56:18 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id e65so89470466pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:56:18 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id y11si5086103pas.239.2016.01.13.15.56.17
        for <linux-mm@kvack.org>;
        Wed, 13 Jan 2016 15:56:17 -0800 (PST)
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
References: <cover.1452294700.git.luto@kernel.org>
 <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
 <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
 <CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com>
 <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com>
 <CALCETrVT7ePZPAySF45hhnhZ5cBKH0EvDGmxftHvUmZw2YxZjQ@mail.gmail.com>
 <5696E129.9000804@linux.intel.com>
 <CALCETrVTO9NoxW-6zEAhHCa2ttQTKA0B+_0OCY-Qe10SwuTFag@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5696E420.9040704@linux.intel.com>
Date: Wed, 13 Jan 2016 15:56:16 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrVTO9NoxW-6zEAhHCa2ttQTKA0B+_0OCY-Qe10SwuTFag@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>

On 01/13/2016 03:51 PM, Andy Lutomirski wrote:
> On Wed, Jan 13, 2016 at 3:43 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>> On 01/13/2016 03:35 PM, Andy Lutomirski wrote:
>>> Can anyone here ask a hardware or microcode person what's going on
>>> with CR3 writes possibly being faster than INVPCID?  Is there some
>>> trick to it?
>>
>> I just went and measured it myself this morning.  "INVPCID Type 3" (all
>> contexts no global) on a Skylake system was 15% slower than a CR3 write.
>>
>> Is that in the same ballpark from what you've observed?
> 
> It's similar, except that I was comparing "INVPCID Type 1" (single
> context no globals) to a CR3 write.

Ahh, because you're using PCID...  That one I saw as being ~1.85x the
number of cycles that a CR3 write was.

> Type 2, at least, is dramatically faster than the pair of CR4 writes
> it replaces.

Yeah, I saw the same thing.  Type 2 was ~2.4x faster than the CR4 writes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
