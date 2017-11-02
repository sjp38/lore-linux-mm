Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E27296B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 03:10:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t188so4440107pfd.20
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:10:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e4si2896227pfg.198.2017.11.02.00.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 00:10:30 -0700 (PDT)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4BCEC2192C
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:10:30 +0000 (UTC)
Received: by mail-io0-f175.google.com with SMTP id 101so11665178ioj.3
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:10:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711012316130.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
 <alpine.DEB.2.20.1711012225400.1942@nanos> <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
 <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com> <alpine.DEB.2.20.1711012316130.1942@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 2 Nov 2017 00:10:09 -0700
Message-ID: <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 1, 2017 at 3:20 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Wed, 1 Nov 2017, Linus Torvalds wrote:
>> On Wed, Nov 1, 2017 at 2:52 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>> > On 11/01/2017 02:28 PM, Thomas Gleixner wrote:
>> >> On Wed, 1 Nov 2017, Andy Lutomirski wrote:
>> >>> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.
>> >>
>> >> Groan, forgot about that abomination, but still there is no point in having
>> >> it marked PAGE_USER in the init_mm at all, kaiser or not.
>> >
>> > So shouldn't this patch effectively make the vsyscall page unusable?
>> > Any idea why that didn't show up in any of the x86 selftests?
>>
>> I actually think there may be two issues here:
>>
>>  - vsyscall isn't even used much - if any - any more
>
> Only legacy user space uses it.
>
>>  - the vsyscall emulation works fine without _PAGE_USER, since the
>> whole point is that we take a fault on it and then emulate.
>>
>> We do expose the vsyscall page read-only to user space in the
>> emulation case, but I'm not convinced that's even required.
>
> I don't see a reason why it needs to be mapped at all for emulation.

At least a couple years ago, the maintainers of some userspace tracing
tools complained very loudly at the early versions of the patches.
There are programs like pin (semi-open-source IIRC) that parse
instructions, make an instrumented copy, and run it.  This means that
the vsyscall page needs to contain text that is semantically
equivalent to what calling it actually does.

So yes, read access needs to work.  I should add a selftest for this.

This is needed in emulation mode as well as native mode, so removing
native mode is totally orthogonal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
