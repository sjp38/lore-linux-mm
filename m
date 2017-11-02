Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 874C36B025F
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:33:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g10so2843494wrg.6
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 04:33:42 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d12si2559983wrg.307.2017.11.02.04.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 04:33:41 -0700 (PDT)
Date: Thu, 2 Nov 2017 12:33:37 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm
 page tables
In-Reply-To: <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1711021226020.2090@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com> <alpine.DEB.2.20.1711012225400.1942@nanos>
 <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com> <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com> <alpine.DEB.2.20.1711012316130.1942@nanos> <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, 2 Nov 2017, Andy Lutomirski wrote:
> On Wed, Nov 1, 2017 at 3:20 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Wed, 1 Nov 2017, Linus Torvalds wrote:
> >> On Wed, Nov 1, 2017 at 2:52 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> >> > On 11/01/2017 02:28 PM, Thomas Gleixner wrote:
> >> >> On Wed, 1 Nov 2017, Andy Lutomirski wrote:
> >> >>> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.
> >> >>
> >> >> Groan, forgot about that abomination, but still there is no point in having
> >> >> it marked PAGE_USER in the init_mm at all, kaiser or not.
> >> >
> >> > So shouldn't this patch effectively make the vsyscall page unusable?
> >> > Any idea why that didn't show up in any of the x86 selftests?
> >>
> >> I actually think there may be two issues here:
> >>
> >>  - vsyscall isn't even used much - if any - any more
> >
> > Only legacy user space uses it.
> >
> >>  - the vsyscall emulation works fine without _PAGE_USER, since the
> >> whole point is that we take a fault on it and then emulate.
> >>
> >> We do expose the vsyscall page read-only to user space in the
> >> emulation case, but I'm not convinced that's even required.
> >
> > I don't see a reason why it needs to be mapped at all for emulation.
> 
> At least a couple years ago, the maintainers of some userspace tracing
> tools complained very loudly at the early versions of the patches.
> There are programs like pin (semi-open-source IIRC) that parse
> instructions, make an instrumented copy, and run it.  This means that
> the vsyscall page needs to contain text that is semantically
> equivalent to what calling it actually does.
> 
> So yes, read access needs to work.  I should add a selftest for this.
> 
> This is needed in emulation mode as well as native mode, so removing
> native mode is totally orthogonal.

Fair enough. I enabled function tracing with emulate_vsyscall as the filter
on a couple of machines and so far I have no hit at all. Though I found a
VM with a real old user space (~2005) and that actually used it.

So for the problem at hand, I'd suggest we disable the vsyscall stuff if
CONFIG_KAISER=y and be done with it.

Thanks,

	tglx





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
