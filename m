Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9E528038B
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 10:43:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r187so2205092pfr.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 07:43:14 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id l9si1163237pgs.254.2017.08.23.07.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 07:43:11 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id r62so229099pfj.4
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 07:43:11 -0700 (PDT)
Date: Wed, 23 Aug 2017 22:43:37 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 09/14] lockdep: Apply crossrelease to completions
Message-ID: <20170823144140.GK11771@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
 <CAK8P3a3ABsxTaS7ZdcWNbTx7j5wFRc0h=ZVWAC_h-E+XbFv+8Q@mail.gmail.com>
 <20170818234348.GE11771@tardis>
 <CAK8P3a2+OdPX-uvRjhycX1NYNC_cBPv_bxJHcoh1ue2y7UX+Tg@mail.gmail.com>
 <CAK8P3a3TfZ=_tm0CUC5aKtf5PDwscLYsAN9Tbs2v0iJN5Jz-Rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="oxV4ZoPwBLqAyY+a"
Content-Disposition: inline
In-Reply-To: <CAK8P3a3TfZ=_tm0CUC5aKtf5PDwscLYsAN9Tbs2v0iJN5Jz-Rw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michel Lespinasse <walken@google.com>, kirill@shutemov.name, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com


--oxV4ZoPwBLqAyY+a
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 19, 2017 at 03:34:01PM +0200, Arnd Bergmann wrote:
> On Sat, Aug 19, 2017 at 2:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>=20
> >> --- a/include/linux/completion.h
> >> +++ b/include/linux/completion.h
> >> @@ -74,7 +74,7 @@ static inline void complete_release_commit(struct co=
mpletion *x) {}
> >>  #endif
> >>
> >>  #define COMPLETION_INITIALIZER_ONSTACK(work) \
> >> -       ({ init_completion(&work); work; })
> >> +       (*({ init_completion(&work); &work; }))
> >>
> >>  /**
> >>   * DECLARE_COMPLETION - declare and initialize a completion structure
> >
> > Nice hack. Any idea why that's different to the compiler?
> >

So I find this link:

	https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html

it says:

"In G++, the result value of a statement expression undergoes array and
function pointer decay, and is returned by value to the enclosing
expression. "

I think this is why the temporary variable is constructed(or at least
allocated). Lemme put this in my commit log.

> > I've applied that one to my test tree now, and reverted my own patch,
> > will let you know if anything else shows up. I think we probably want
> > to merge both patches to mainline.
>=20
> There is apparently one user of COMPLETION_INITIALIZER_ONSTACK
> that causes a regression with the patch above:
>=20
> drivers/acpi/nfit/core.c: In function 'acpi_nfit_flush_probe':
> include/linux/completion.h:77:3: error: value computed is not used
> [-Werror=3Dunused-value]
>   (*({ init_completion(&work); &work; }))
>=20
> It would be trivial to convert to init_completion(), which seems to be
> what was intended there.
>=20

Thanks. Will send the conversion as a separate patch along with my
patch.

Regards,
Boqun

>         Arnd

--oxV4ZoPwBLqAyY+a
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmdlJQACgkQSXnow7UH
+rhoPwgAmloWiwRZC9y/pNE3ay7U2sD72j+EIrV0ksMlIBBZThT+FLO94T71M2qB
xFip80IMlC9LTd1nE3Df5kMimkqUHFKxd6Uoq99zJvAlGJQpS1A1BkjWQ6owDF2+
lqOM3R8hGAu/o5f9zkpqyn4tk0Mmqu2IS88UqRpK5ldKDA2DwquAwvuIMRdaVmVO
fuhYiLJ4VhQazW/MBDCkIsUmhWX/MY1C4utsqpQVIgTx7EPcSSdc814SdH2Gmps4
5ArqvMiiABlObLjAqJLtnDNsb497CLratEODHqofOFDAbsTtXVOwHT80dchla+OI
RSPprooAmg6CEn2d+B9sMm60eIO+oQ==
=j42v
-----END PGP SIGNATURE-----

--oxV4ZoPwBLqAyY+a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
