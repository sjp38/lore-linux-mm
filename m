Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB476B0268
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:12:21 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o74so11176438iod.15
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:12:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor1095784itf.1.2017.11.01.15.12.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 15:12:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
 <alpine.DEB.2.20.1711012225400.1942@nanos> <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Nov 2017 15:12:19 -0700
Message-ID: <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 1, 2017 at 2:52 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> On 11/01/2017 02:28 PM, Thomas Gleixner wrote:
>> On Wed, 1 Nov 2017, Andy Lutomirski wrote:
>>> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.
>>
>> Groan, forgot about that abomination, but still there is no point in having
>> it marked PAGE_USER in the init_mm at all, kaiser or not.
>
> So shouldn't this patch effectively make the vsyscall page unusable?
> Any idea why that didn't show up in any of the x86 selftests?

I actually think there may be two issues here:

 - vsyscall isn't even used much - if any - any more

 - the vsyscall emulation works fine without _PAGE_USER, since the
whole point is that we take a fault on it and then emulate.

We do expose the vsyscall page read-only to user space in the
emulation case, but I'm not convinced that's even required.

Nobody who configures KAISER enabled would possibly want to have the
actual native vsyscall page enabled. That would be an insane
combination.

So the only possibly difference would be a user mode program that
actually looks at the vsyscall page, which sounds unlikely to be an
issue.  It's legacy and not really used.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
