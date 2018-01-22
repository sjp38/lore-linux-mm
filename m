Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13D13800D8
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 21:28:09 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id h38so5663882wrh.11
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 18:28:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c2sor9256731edi.46.2018.01.21.18.28.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jan 2018 18:28:07 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CA+55aFz4cUhqhmWg-F8NXGjowVGXkMA126H-mQ4n1A0ywtQ_tg@mail.gmail.com>
Date: Sun, 21 Jan 2018 18:27:59 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <8B8147E4-0560-456D-BA23-F0037C80C945@gmail.com>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com>
 <886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
 <9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com>
 <CA+55aFz4cUhqhmWg-F8NXGjowVGXkMA126H-mQ4n1A0ywtQ_tg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, Jan 21, 2018 at 3:46 PM, Nadav Amit <nadav.amit@gmail.com> =
wrote:
>> I wanted to see whether segments protection can be a replacement for =
PTI
>> (yes, excluding SMEP emulation), or whether speculative execution =
=E2=80=9Cignores=E2=80=9D
>> limit checks, similarly to the way paging protection is skipped.
>>=20
>> It does seem that segmentation provides sufficient protection from =
Meltdown.
>> The =E2=80=9Creliability=E2=80=9D test of Gratz PoC fails if the =
segment limit is set to
>> prevent access to the kernel memory. [ It passes if the limit is not =
set,
>> even if the DS is reloaded. ] My test is enclosed below.
>=20
> Interesting. It might not be entirely reliable for all
> microarchitectures, though.
>=20
>> So my question: wouldn=E2=80=99t it be much more efficient to use =
segmentation
>> protection for x86-32, and allow users to choose whether they want =
SMEP-like
>> protection if needed (and then enable PTI)?
>=20
> That's what we did long long ago, with user space segments actually
> using the limit (in fact, if you go back far enough, the kernel even
> used the base).
>=20
> You'd have to make sure that the LDT loading etc do not allow CPL3
> segments with base+limit past TASK_SIZE, so that people can't generate
> their own.  And the TLS segments also need to be limited (and
> remember, the limit has to be TASK_SIZE-base, not just TASK_SIZE).
>=20
> And we should check with Intel that segment limit checking really is
> guaranteed to be done before any access.

Thanks. I=E2=80=99ll try to check with Intel liaison people of VMware =
(my employer),
yet any feedback will be appreciated.

> Too bad x86-64 got rid of the segments ;)

Actually, as I noted in a different thread, running 32-bit binaries on
x86_64 in legacy-mode, without PTI, performs considerably better than =
x86_64
binaries with PTI for workloads that are hit the most (e.g., Redis). By
dynamically removing the 64-bit user-CS from the GDT, this mode should =
be
safe, as long as CS load is not done speculatively.

Regards,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
