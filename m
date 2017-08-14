Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79B786B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 03:05:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i192so121654870pgc.11
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:05:22 -0700 (PDT)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id o17si3702980pgj.623.2017.08.14.00.05.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 00:05:21 -0700 (PDT)
Received: by mail-pg0-x233.google.com with SMTP id v189so41448581pgd.2
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:05:21 -0700 (PDT)
Date: Mon, 14 Aug 2017 15:05:22 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170814070522.wwj4as2hk2o7avlu@tardis>
References: <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
 <20170810131737.skdyy4qcxlikbyeh@tardis>
 <20170811034328.GH20323@X58A-UD3R>
 <20170811080329.3ehu7pp7lcm62ji6@tardis>
 <20170811085201.GI20323@X58A-UD3R>
 <20170811094448.GJ20323@X58A-UD3R>
 <CANrsvRM4ijD0ym0HJySqjOfcCeUbGCc6bBppK43y5MqC5aB1gQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="f2pesoty2ewsepow"
Content-Disposition: inline
In-Reply-To: <CANrsvRM4ijD0ym0HJySqjOfcCeUbGCc6bBppK43y5MqC5aB1gQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <max.byungchul.park@gmail.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--f2pesoty2ewsepow
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 11, 2017 at 10:06:37PM +0900, Byungchul Park wrote:
> On Fri, Aug 11, 2017 at 6:44 PM, Byungchul Park <byungchul.park@lge.com> =
wrote:
> > On Fri, Aug 11, 2017 at 05:52:02PM +0900, Byungchul Park wrote:
> >> On Fri, Aug 11, 2017 at 04:03:29PM +0800, Boqun Feng wrote:
> >> > Thanks for taking a look at it ;-)
> >>
> >> I rather appriciate it.
> >>
> >> > > > @@ -5005,7 +5003,7 @@ static int commit_xhlock(struct cross_lock=
 *xlock, struct hist_lock *xhlock)
> >> > > >  static void commit_xhlocks(struct cross_lock *xlock)
> >> > > >  {
> >> > > >         unsigned int cur =3D current->xhlock_idx;
> >> > > > -       unsigned int prev_hist_id =3D xhlock(cur).hist_id;
> >> > > > +       unsigned int prev_hist_id =3D cur + 1;
> >> > >
> >> > > I should have named it another. Could you suggest a better one?
> >> > >
> >> >
> >> > I think "prev" is fine, because I thought the "previous" means the
> >> > xhlock item we visit _previously_.
> >> >
> >> > > >         unsigned int i;
> >> > > >
> >> > > >         if (!graph_lock())
> >> > > > @@ -5030,7 +5028,7 @@ static void commit_xhlocks(struct cross_lo=
ck *xlock)
> >> > > >                          * hist_id than the following one, which=
 is impossible
> >> > > >                          * otherwise.
> >> > >
> >> > > Or we need to modify the comment so that the word 'prev' does not =
make
> >> > > readers confused. It was my mistake.
> >> > >
> >> >
> >> > I think the comment needs some help, but before you do it, could you
> >> > have another look at what Peter proposed previously? Note you have a
> >> > same_context_xhlock() check in the commit_xhlocks(), so the your
> >> > previous overwrite case actually could be detected, I think.
> >>
> >> What is the previous overwrite case?
> >>
> >> ppppppppppwwwwwwwwwwwwiiiiiiiii
> >> iiiiiiiiiiiiiii................
> >>
> >> Do you mean this one? I missed the check of same_context_xhlock(). Yes,
> >> peterz's suggestion also seems to work.
> >>
> >> > However, one thing may not be detected is this case:
> >> >
> >> >             ppppppppppppppppppppppppppppppppppwwwwwwww
> >> > wrapped >   wwwwwww
> >>
> >> To be honest, I think your suggestion is more natual, with which this
> >> case would be also covered.
> >>
> >> >
> >> >     where p: process and w: worker.
> >> >
> >> > , because p and w are in the same task_irq_context(). I discussed th=
is
> >> > with Peter yesterday, and he has a good idea: unconditionally do a r=
eset
> >> > on the ring buffer whenever we do a crossrelease_hist_end(XHLOCK_PRO=
C).
> >
> > Ah, ok. You meant 'whenever _process_ context exit'.
> >
> > I need more time to be sure, but anyway for now it seems to work with
> > giving up some chances for remaining xhlocks.
> >
> > But, I am not sure if it's still true even in future and the code can be
> > maintained easily. I think your approach is natural and neat enough for
> > that purpose. What problem exists with yours?
>=20

My approach works but it has bigger memmory footprint than Peter's, so I
asked about whether you could consider Peter's approach.

> Let me list up the possible approaches:
>=20
> 0. Byungchul's approach

Your approach requires(additionally):

	MAX_XHLOCKS_NR * sizeof(unsigned int) // because of the hist_id field in h=
ist_lock
	+=20
	(XHLOCK_CXT_NR + 1) * sizeof(unsigned int) // because of fields in task_st=
ruct

bytes per task.

> 1. Boqun's approach

My approach requires(additionally):

	MAX_XHLOCKS_NR * sizeof(unsigned int) // because of the hist_id field in h=
ist_lock

bytes per task.

> 2. Peterz's approach

And Peter's approach requires(additionally):

	1 * sizeof(unsigned int)

bytes per task.

So basically we need some tradeoff between memory footprints and history
precision here.

> 3. Reset on process exit
>=20
> I like Boqun's approach most but, _whatever_. It's ok if it solves the pr=
oblem.
> The last one is not bad when it is used for syscall exit, but we have to =
give
> up valid dependencies unnecessarily in other cases. And I think Peterz's
> approach should be modified a bit to make it work neatly, like:
>=20
> crossrelease_hist_end(...)
> {
> ...
>        invalidate_xhlock(&xhlock(cur->xhlock_idx_max));
>=20
>        for (c =3D 0; c < XHLOCK_CXT_NR; c++)
>               if ((cur->xhlock_idx_max - cur->xhlock_idx_hist[c]) >=3D
> MAX_XHLOCKS_NR)
>                      invalidate_xhlock(&xhlock(cur->xhlock_idx_hist[c]));
> ...
> }
>=20

Haven't looked into this deeply, but my gut feeling is this is
unnecessary, will have a deep look.

Regards,
Boqun

> And then Peterz's approach can also work, I think.
>=20
> ---
> Thanks,
> Byungchul

--f2pesoty2ewsepow
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmRS68ACgkQSXnow7UH
+rhhvwgAhXZd9PeqnQ71g2WqItQGci9n+UmMw6CqvgtUQodPaUNM3GaUkUMRlMsh
Ve0Uyioiz33YSv8c/6ntDz8JsDqqaafW/qOrJYBVNfybhhYpaJ1dP/4FqOa0F7dK
OcGdkbLcUQSy/Ih2wfbWj2kXuRGTyx2ujH6lt4DFDAbMST1cS7qQdk+kh5SFb9OJ
Nq9yq3l4E60P8RhhfUgBlpESDr4AHN/KosCp2KFHNqCtFX2hPqlDcX/cHWuT0im/
5Y27uMkkUwLFSPKwRCoikqCeyd9eldMicpgbkhyod0netB5zQQrZeJjgpLWIH7gi
qUbz5afqyrElwX165viazs3H1IdwJQ==
=UFk9
-----END PGP SIGNATURE-----

--f2pesoty2ewsepow--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
