Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 932E46B0261
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:45:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f20so11464831ioj.2
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:45:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y19sor877628itb.11.2017.11.01.15.45.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 15:45:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711012316130.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
 <alpine.DEB.2.20.1711012225400.1942@nanos> <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
 <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com> <alpine.DEB.2.20.1711012316130.1942@nanos>
From: Kees Cook <keescook@google.com>
Date: Wed, 1 Nov 2017 15:45:48 -0700
Message-ID: <CAGXu5jLCkhhVmCbpxp4oWCgwCdkDQz2DsJnO=9EzfYZorNLMUQ@mail.gmail.com>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

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
>
>> Nobody who configures KAISER enabled would possibly want to have the
>> actual native vsyscall page enabled. That would be an insane
>> combination.
>>
>> So the only possibly difference would be a user mode program that
>> actually looks at the vsyscall page, which sounds unlikely to be an
>> issue.  It's legacy and not really used.
>
> Right, and we can either disable the NATIVE mode when KAISER is on or just
> rip the native mode out completely. Most distros have native mode disabled
> anyway, so you cannot even enable it on the kernel command line.
>
> I'm all for ripping it out or at least removing the config switch to enable
> native mode as a first step.

I would like to see NATIVE removed too.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
