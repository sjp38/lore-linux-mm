Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6AD16B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 17:18:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l1-v6so2257959edi.11
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 14:18:46 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id o34-v6si10041636edd.427.2018.07.24.14.18.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 14:18:45 -0700 (PDT)
Date: Tue, 24 Jul 2018 23:18:42 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Message-ID: <20180724211842.GB29308@amd>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <20180723140925.GA4285@amd>
 <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
 <20180723213830.GA4632@amd>
 <39A1C149-DA03-46D1-801F-0205DCD69A36@amacapital.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mxv5cy4qt+RJ9ypb"
Content-Disposition: inline
In-Reply-To: <39A1C149-DA03-46D1-801F-0205DCD69A36@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>


--mxv5cy4qt+RJ9ypb
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-07-23 14:50:50, Andy Lutomirski wrote:
>=20
>=20
> > On Jul 23, 2018, at 2:38 PM, Pavel Machek <pavel@ucw.cz> wrote:
> >=20
> >> On Mon 2018-07-23 12:00:08, Linus Torvalds wrote:
> >>> On Mon, Jul 23, 2018 at 7:09 AM Pavel Machek <pavel@ucw.cz> wrote:
> >>>=20
> >>> Meanwhile... it looks like gcc is not slowed down significantly, but
> >>> other stuff sees 30% .. 40% slowdowns... which is rather
> >>> significant.
> >>=20
> >> That is more or less expected.
> >>=20
> >> Gcc spends about 90+% of its time in user space, and the system calls
> >> it *does* do tend to be "real work" (open/read/etc). And modern gcc's
> >> no longer have the pipe between cpp and cc1, so they don't have that
> >> issue either (which would have sjhown the PTI slowdown a lot more)
> >>=20
> >> Some other loads will do a lot more time traversing the user/kernel
> >> boundary, and in 32-bit mode you won't be able to take advantage of
> >> the address space ID's, so you really get the full effect.
> >=20
> > Understood. Just -- bzip2 should include quite a lot of time in
> > userspace, too.=20
> >=20
> >>> Would it be possible to have per-process control of kpti? I have
> >>> some processes where trading of speed for security would make sense.
> >>=20
> >> That was pretty extensively discussed, and no sane model for it was
> >> ever agreed upon.  Some people wanted it per-thread, others per-mm,
> >> and it wasn't clear how to set it either and how it should inherit
> >> across fork/exec, and what the namespace rules etc should be.
> >>=20
> >> You absolutely need to inherit it (so that you can say "I trust this
> >> session" or whatever), but at the same time you *don't* want to
> >> inherit if you have a server you trust that then spawns user processes
> >> (think "I want systemd to not have the overhead, but the user
> >> processes it spawns obviously do need protection").
> >>=20
> >> It was just a morass. Nothing came out of it.  I guess people can
> >> discuss it again, but it's not simple.
> >=20
> > I agree it is not easy. OTOH -- 30% of user-visible performance is a
> > _lot_. That is worth spending man-years on...  Ok, problem is not as
> > severe on modern CPUs with address space ID's, but...
> >=20
> > What I want is "if A can ptrace B, and B has pti disabled, A can have
> > pti disabled as well". Now.. I see someone may want to have it
> > per-thread, because for stuff like javascript JIT, thread may have
> > rights to call ptrace, but is unable to call ptrace because JIT
> > removed that ability... hmm...
>=20
> No, you don=E2=80=99t want that. The problem is that Meltdown isn=E2=80=
=99t a problem that exists in isolation. It=E2=80=99s very plausible that J=
avaScript code could trigger a speculation attack that, with PTI off, could=
 read kernel memory.

Ok, you are right. It is more tricky then I thought.

Still, I probably don't need to run grep's and cat's with PTI
on. Chromium (etc) probably needs it. Python interpretter running my
own code probably does not.

Yes, my Thinkpad X60 is probably thermal-throttled. It is not really
new machine. I switched to T40p for now :-).

What is the "worst" case people are seeing?
time dd if=3D/dev/zero of=3D/dev/null bs=3D1 count=3D10000000
can reproduce 3x slowdown, but that's basically microbenchmark.

root-only per-process enable/disable of kpti should not be too hard to
do. Would there be interest in that?

Best regards,

								Pavel
--
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--mxv5cy4qt+RJ9ypb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltXl7IACgkQMOfwapXb+vKkRQCfTP3tSQsIpQiIYF3/7KW+67l/
PZYAnjaG42dv7CN8Jr3OMHjQVH73pfJ7
=1WCR
-----END PGP SIGNATURE-----

--mxv5cy4qt+RJ9ypb--
