Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E22876B000A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:50:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y16-v6so1077784pgv.23
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:50:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1-v6sor2371930pgo.316.2018.07.23.14.50.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 14:50:53 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20180723213830.GA4632@amd>
Date: Mon, 23 Jul 2018 14:50:50 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <39A1C149-DA03-46D1-801F-0205DCD69A36@amacapital.net>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org> <20180723140925.GA4285@amd> <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com> <20180723213830.GA4632@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?utf-8?Q?J=C3=BCrgen_Gro=C3=9F?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>



> On Jul 23, 2018, at 2:38 PM, Pavel Machek <pavel@ucw.cz> wrote:
>=20
>> On Mon 2018-07-23 12:00:08, Linus Torvalds wrote:
>>> On Mon, Jul 23, 2018 at 7:09 AM Pavel Machek <pavel@ucw.cz> wrote:
>>>=20
>>> Meanwhile... it looks like gcc is not slowed down significantly, but
>>> other stuff sees 30% .. 40% slowdowns... which is rather
>>> significant.
>>=20
>> That is more or less expected.
>>=20
>> Gcc spends about 90+% of its time in user space, and the system calls
>> it *does* do tend to be "real work" (open/read/etc). And modern gcc's
>> no longer have the pipe between cpp and cc1, so they don't have that
>> issue either (which would have sjhown the PTI slowdown a lot more)
>>=20
>> Some other loads will do a lot more time traversing the user/kernel
>> boundary, and in 32-bit mode you won't be able to take advantage of
>> the address space ID's, so you really get the full effect.
>=20
> Understood. Just -- bzip2 should include quite a lot of time in
> userspace, too.=20
>=20
>>> Would it be possible to have per-process control of kpti? I have
>>> some processes where trading of speed for security would make sense.
>>=20
>> That was pretty extensively discussed, and no sane model for it was
>> ever agreed upon.  Some people wanted it per-thread, others per-mm,
>> and it wasn't clear how to set it either and how it should inherit
>> across fork/exec, and what the namespace rules etc should be.
>>=20
>> You absolutely need to inherit it (so that you can say "I trust this
>> session" or whatever), but at the same time you *don't* want to
>> inherit if you have a server you trust that then spawns user processes
>> (think "I want systemd to not have the overhead, but the user
>> processes it spawns obviously do need protection").
>>=20
>> It was just a morass. Nothing came out of it.  I guess people can
>> discuss it again, but it's not simple.
>=20
> I agree it is not easy. OTOH -- 30% of user-visible performance is a
> _lot_. That is worth spending man-years on...  Ok, problem is not as
> severe on modern CPUs with address space ID's, but...
>=20
> What I want is "if A can ptrace B, and B has pti disabled, A can have
> pti disabled as well". Now.. I see someone may want to have it
> per-thread, because for stuff like javascript JIT, thread may have
> rights to call ptrace, but is unable to call ptrace because JIT
> removed that ability... hmm...

No, you don=E2=80=99t want that. The problem is that Meltdown isn=E2=80=99t a=
 problem that exists in isolation. It=E2=80=99s very plausible that JavaScri=
pt code could trigger a speculation attack that, with PTI off, could read ke=
rnel memory.
