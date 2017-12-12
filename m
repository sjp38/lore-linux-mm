Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 342636B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:22:53 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 200so16209868pge.12
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:22:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u7sor1713899plr.123.2017.12.12.10.22.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 10:22:52 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [patch 11/16] x86/ldt: Force access bit for CS/SS
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CALCETrVmFSVqDGrH1K+Qv=svPTP3E6maVb5T2feyDNRkKfDVKA@mail.gmail.com>
Date: Tue, 12 Dec 2017 10:22:48 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <C3141266-5522-4B5E-A0CE-65523F598F6D@amacapital.net>
References: <20171212173221.496222173@linutronix.de> <20171212173334.176469949@linutronix.de> <CALCETrX+d+5COyWX1gDxi3gX93zFuq79UE+fhs27+ySq85j3+Q@mail.gmail.com> <20171212180918.lc5fdk5jyzwmrcxq@hirez.programming.kicks-ass.net> <CALCETrVmFSVqDGrH1K+Qv=svPTP3E6maVb5T2feyDNRkKfDVKA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> On Dec 12, 2017, at 10:10 AM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
>> On Tue, Dec 12, 2017 at 10:09 AM, Peter Zijlstra <peterz@infradead.org> w=
rote:
>>> On Tue, Dec 12, 2017 at 10:03:02AM -0800, Andy Lutomirski wrote:
>>> On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wr=
ote:
>>=20
>>>> @@ -171,6 +172,9 @@ static void exit_to_usermode_loop(struct
>>>>                /* Disable IRQs and retry */
>>>>                local_irq_disable();
>>>>=20
>>>> +               if (cached_flags & _TIF_LDT)
>>>> +                       ldt_exit_user(regs);
>>>=20
>>> Nope.  To the extent that this code actually does anything (which it
>>> shouldn't since you already forced the access bit),
>>=20
>> Without this; even with the access bit set; IRET will go wobbly and
>> we'll #GP on the user-space side. Try it ;-)
>=20
> Maybe later.
>=20
> But that means that we need Intel and AMD to confirm WTF is going on
> before this blows up even with LAR on some other CPU.
>=20
>>=20
>>> it's racy against
>>> flush_ldt() from another thread, and that race will be exploitable for
>>> privilege escalation.  It needs to be outside the loopy part.
>>=20
>> The flush_ldt (__ldt_install after these patches) would re-set the TIF
>> flag. But sure, we can move this outside the loop I suppose.

Also, why is LAR deferred to user exit?  And I thought that LAR didn't set t=
he accessed bit.

If I had to guess, I'd guess that LAR is actually generating a read fault an=
d forcing the pagetables to get populated.  If so, then it means the VMA cod=
e isn't quite right, or you're susceptible to failures under memory pressure=
.

Now maybe LAR will repopulate the PTE every time if you were to never clear i=
t, but ick.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
