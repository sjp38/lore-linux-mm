Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 776656B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:59:31 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v9so5792225oif.15
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 04:59:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y5sor1092676oia.36.2017.11.02.04.59.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 04:59:30 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <alpine.DEB.2.20.1711021226020.2090@nanos>
Date: Thu, 2 Nov 2017 12:59:22 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <A4F58550-CAA8-4AE2-8DE5-C6970CC47210@amacapital.net>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com> <alpine.DEB.2.20.1711012225400.1942@nanos> <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com> <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com> <alpine.DEB.2.20.1711012316130.1942@nanos> <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com> <alpine.DEB.2.20.1711021226020.2090@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>



> On Nov 2, 2017, at 12:33 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
>=20
>> On Thu, 2 Nov 2017, Andy Lutomirski wrote:
>>> On Wed, Nov 1, 2017 at 3:20 PM, Thomas Gleixner <tglx@linutronix.de> wro=
te:
>>>> On Wed, 1 Nov 2017, Linus Torvalds wrote:
>>>>> On Wed, Nov 1, 2017 at 2:52 PM, Dave Hansen <dave.hansen@linux.intel.c=
om> wrote:
>>>>>> On 11/01/2017 02:28 PM, Thomas Gleixner wrote:
>>>>>>> On Wed, 1 Nov 2017, Andy Lutomirski wrote:
>>>>>>> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.=

>>>>>>=20
>>>>>> Groan, forgot about that abomination, but still there is no point in h=
aving
>>>>>> it marked PAGE_USER in the init_mm at all, kaiser or not.
>>>>>=20
>>>>> So shouldn't this patch effectively make the vsyscall page unusable?
>>>>> Any idea why that didn't show up in any of the x86 selftests?
>>>>=20
>>>> I actually think there may be two issues here:
>>>>=20
>>>> - vsyscall isn't even used much - if any - any more
>>>=20
>>> Only legacy user space uses it.
>>>=20
>>>> - the vsyscall emulation works fine without _PAGE_USER, since the
>>>> whole point is that we take a fault on it and then emulate.
>>>>=20
>>>> We do expose the vsyscall page read-only to user space in the
>>>> emulation case, but I'm not convinced that's even required.
>>>=20
>>> I don't see a reason why it needs to be mapped at all for emulation.
>>=20
>> At least a couple years ago, the maintainers of some userspace tracing
>> tools complained very loudly at the early versions of the patches.
>> There are programs like pin (semi-open-source IIRC) that parse
>> instructions, make an instrumented copy, and run it.  This means that
>> the vsyscall page needs to contain text that is semantically
>> equivalent to what calling it actually does.
>>=20
>> So yes, read access needs to work.  I should add a selftest for this.
>>=20
>> This is needed in emulation mode as well as native mode, so removing
>> native mode is totally orthogonal.
>=20
> Fair enough. I enabled function tracing with emulate_vsyscall as the filte=
r
> on a couple of machines and so far I have no hit at all. Though I found a
> VM with a real old user space (~2005) and that actually used it.
>=20
> So for the problem at hand, I'd suggest we disable the vsyscall stuff if
> CONFIG_KAISER=3Dy and be done with it.

I think that time() on not-so-old glibc uses it.  Even more recent versions o=
f Go use it. :(

>=20
> Thanks,
>=20
>    tglx
>=20
>=20
>=20
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
