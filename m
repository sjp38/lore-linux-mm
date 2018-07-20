Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0892E6B0008
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 18:20:29 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f91-v6so6137515plb.10
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:20:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p19-v6sor869677pfo.123.2018.07.20.15.20.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 15:20:27 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 1/3] perf/core: Make sure the ring-buffer is mapped in all page-tables
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20180720213700.gh6d2qd2ck6nt4ax@suse.de>
Date: Fri, 20 Jul 2018 12:20:24 -1000
Content-Transfer-Encoding: quoted-printable
Message-Id: <D89602E9-E620-4AF0-822C-206D7F0BA071@amacapital.net>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org> <1532103744-31902-2-git-send-email-joro@8bytes.org> <CALCETrXJX8tPVgD=Ce41534uneAAobm-HyjeGwVYgJDJ_+-bDw@mail.gmail.com> <20180720174846.GF18541@8bytes.org> <CALCETrUj4cLpOKUbJUfLqKJFkjAgeraE=ORQ-e-bKU+AHda0=Q@mail.gmail.com> <20180720213700.gh6d2qd2ck6nt4ax@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>


> On Jul 20, 2018, at 11:37 AM, Joerg Roedel <jroedel@suse.de> wrote:
>=20
>> On Fri, Jul 20, 2018 at 12:32:10PM -0700, Andy Lutomirski wrote:
>> I'm just reading your changelog, and you said the PMDs are no longer
>> shared between the page tables.  So this presumably means that
>> vmalloc_fault() no longer actually works correctly on PTI systems.  I
>> didn't read the code to figure out *why* it doesn't work, but throwing
>> random vmalloc_sync_all() calls around is wrong.
>=20
> Hmm, so the whole point of vmalloc_fault() fault is to sync changes from
> swapper_pg_dir to process page-tables when the relevant parts of the
> kernel page-table are not shared, no?
>=20
> That is also the reason we don't see this on 64 bit, because there these
> parts *are* shared.
>=20
> So with that reasoning vmalloc_fault() works as designed, except that
> a warning is issued when it's happens in the NMI path. That warning comes
> from
>=20
>    ebc8827f75954 x86: Barf when vmalloc and kmemcheck faults happen in NMI=

>=20
> which went into 2.6.37 and was added because the NMI handler were not
> nesting-safe back then. Reason probably was that the handler on 64 bit
> has to use an IST stack and a nested NMI would overwrite the stack of
> the upper handler.  We don't have this problem on 32 bit as a nested NMI
> will not do another stack-switch there.
>=20

Thanks for digging!  The problem was presumably that vmalloc_fault() will IR=
ET and re-enable NMIs on the way out.  But we=E2=80=99ve supported page faul=
ts on user memory in NMI handlers on 32-bit and 64-bit for quite a while, an=
d it=E2=80=99s fine now.

I would remove the warning, re-test, and revert the other patch.

The one case we can=E2=80=99t handle in vmalloc_fault() is a fault on a stac=
k access. I don=E2=80=99t expect this to be a problem for PTI. It was a prob=
lem for CONFIG_VMAP_STACK, though.

> I am not sure about 64 bit, but there is a lot of assembly magic to make
> NMIs nesting-safe, so I guess the problem should be gone there too.
>=20
>=20
> Regards,
>=20
>    Joerg
