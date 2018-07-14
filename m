Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7C16B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 10:36:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e19-v6so2912183pgv.11
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 07:36:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t63-v6sor3468281pfi.74.2018.07.14.07.36.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 07:36:51 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20180714080159.hqp36q7fxzb2ktlq@suse.de>
Date: Sat, 14 Jul 2018 07:36:47 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <75BDF04F-9585-438C-AE04-918FBE00A174@amacapital.net>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-11-git-send-email-joro@8bytes.org> <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com> <20180714052110.cobtew6rms23ih37@suse.de> <7AB4F269-E0E8-4290-A764-69D8605467E8@amacapital.net> <20180714080159.hqp36q7fxzb2ktlq@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>



> On Jul 14, 2018, at 1:01 AM, Joerg Roedel <jroedel@suse.de> wrote:
>=20
> On Fri, Jul 13, 2018 at 11:26:54PM -0700, Andy Lutomirski wrote:
>>> So based on that, I did the above because the entry-stack is a per-cpu
>>> data structure and I am not sure that we always return from the exceptio=
n
>>> on the same CPU where we got it. Therefore the path is called
>>> PARANOID_... :)
>>=20
>> But we should just be able to IRET and end up right back on the entry
>> stack where we were when we got interrupted.
>=20
> Yeah, but using another CPUs entry-stack is a bad idea, no? Especially
> since the owning CPU might have overwritten our content there already.
>=20
>> On x86_64, we *definitely* can=E2=80=99t schedule in NMI, MCE, or #DB bec=
ause
>> we=E2=80=99re on a percpu stack. Are you *sure* we need this patch?
>=20
> I am sure we need this patch, but not 100% sure that we really can
> change CPUs in this path. We are not only talking about NMI, #MC and
> #DB, but also about #GP and every other exception that can happen while
> writing segments registers or on iret. With this implementation we are
> on the safe side for this unlikely slow-path.

Oh, right, exceptions while writing segment regs. IRET is special, though.

But I=E2=80=99m still unconvinced. If any code executed with IRQs enabled on=
 the entry stack, then that code is terminally buggy. If you=E2=80=99re exec=
uting with IRQs off, you=E2=80=99re not going to get migrated.  64-bit kerne=
ls run on percpu stacks all the time, and it=E2=80=99s not a problem.

IRET errors are genuinely special and, if they=E2=80=99re causing a problem f=
or you, we should fix them the same way we deal with them on x86_64. M

>=20
> Regards,
>=20
>    Joerg
