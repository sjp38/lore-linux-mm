Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F63A6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 11:36:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l23so6382608pgc.10
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 08:36:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor913887pgf.291.2017.11.02.08.36.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 08:36:34 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: KAISER memory layout (Re: [PATCH 06/23] x86, kaiser: introduce user-mapped percpu areas)
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <alpine.DEB.2.20.1711021343380.2090@nanos>
Date: Thu, 2 Nov 2017 16:36:29 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <65E6D547-2871-4D93-9E10-24C31DB10269@amacapital.net>
References: <CALCETrXLJfmTg1MsQHKCL=WL-he_5wrOqeX2OatQCCqVE003VQ@mail.gmail.com> <alpine.DEB.2.20.1711021235290.2090@nanos> <89E52C9C-DBAB-4661-8172-0F6307857870@amacapital.net> <alpine.DEB.2.20.1711021343380.2090@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>



> On Nov 2, 2017, at 1:45 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
>=20
> On Thu, 2 Nov 2017, Andy Lutomirski wrote:
>>> On Nov 2, 2017, at 12:48 PM, Thomas Gleixner <tglx@linutronix.de> wrote:=

>>>=20
>>>> On Thu, 2 Nov 2017, Andy Lutomirski wrote:
>>>> I think we're far enough along here that it may be time to nail down
>>>> the memory layout for real.  I propose the following:
>>>>=20
>>>> The user tables will contain the following:
>>>>=20
>>>> - The GDT array.
>>>> - The IDT.
>>>> - The vsyscall page.  We can make this be _PAGE_USER.
>>>=20
>>> I rather remove it for the kaiser case.
>>>=20
>>>> - The TSS.
>>>> - The per-cpu entry stack.  Let's make it one page with guard pages
>>>> on either side.  This can replace rsp_scratch.
>>>> - cpu_current_top_of_stack.  This could be in the same page as the TSS.=

>>>> - The entry text.
>>>> - The percpu IST (aka "EXCEPTION") stacks.
>>>=20
>>> Do you really want to put the full exception stacks into that user mappi=
ng?
>>> I think we should not do that. There are two options:
>>>=20
>>> 1) Always use the per-cpu entry stack and switch to the proper IST after=

>>>    the CR3 fixup
>>=20
>> Can't -- it's microcode, not software, that does that switch.
>=20
> Well, yes. The micro code does the stack switch to ISTs but software tells=

> it to do so. We write the IDT IIRC.
>=20
>>> 2) Have separate per-cpu entry stacks for the ISTs and switch to the rea=
l
>>>    ones after the CR3 fixup.
>>=20
>> How is that simpler?
>=20
> Simpler is not the question. I want to avoid mapping the whole IST stacks.=

>=20

OK, let's see.  We can have the IDT be different in the user tables and the k=
ernel tables.  The user IDT could have IST-less entry stubs that do their ow=
n CR3 switch and then bounce to the IST stack.  I don't see why this wouldn'=
t work aside from requiring a substantially larger entry stack, but I'm also=
 not convinced it's worth the added complexity.  The NMI code would certainl=
y need some careful thought to convince ourselves that it would still be cor=
rect.  #DF would be, um, interesting because of the silly ESPFIX64 thing.

My inclination would be to deal with this later.  For the first upstream ver=
sion, we map the IST stacks.  Later on, we have a separate user IDT that doe=
s whatever it needs to do.

The argument to the contrary would be that Dave's CR3 code *and* my entry st=
ack crap gets simpler if all the CR3 switches happen in special stubs.

The argument against *that* is that this erase_kstack crap might also benefi=
t from the magic stack switch.  OTOH that's the *exit* stack, which is total=
ly independent.

FWIW, I want to get rid of the #DB and #BP stacks entirely, but that does no=
t deserve to block this series, I think.

> Thanks,
>=20
>    tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
