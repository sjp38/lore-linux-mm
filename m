Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB2D26B04CB
	for <linux-mm@kvack.org>; Sat, 19 Aug 2017 23:17:48 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m133so193124448pga.2
        for <linux-mm@kvack.org>; Sat, 19 Aug 2017 20:17:48 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id f184si5643574pfg.308.2017.08.19.20.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Aug 2017 20:17:47 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t83so3768457pfj.3
        for <linux-mm@kvack.org>; Sat, 19 Aug 2017 20:17:47 -0700 (PDT)
Date: Sun, 20 Aug 2017 11:18:05 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 09/14] lockdep: Apply crossrelease to completions
Message-ID: <20170820031805.GF11771@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
 <CAK8P3a3ABsxTaS7ZdcWNbTx7j5wFRc0h=ZVWAC_h-E+XbFv+8Q@mail.gmail.com>
 <20170818234348.GE11771@tardis>
 <CAK8P3a2+OdPX-uvRjhycX1NYNC_cBPv_bxJHcoh1ue2y7UX+Tg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="47eKBCiAZYFK5l32"
Content-Disposition: inline
In-Reply-To: <CAK8P3a2+OdPX-uvRjhycX1NYNC_cBPv_bxJHcoh1ue2y7UX+Tg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Byungchul Park <byungchul.park@lge.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Michel Lespinasse <walken@google.com>, kirill@shutemov.name, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com


--47eKBCiAZYFK5l32
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 19, 2017 at 02:51:17PM +0200, Arnd Bergmann wrote:
[...]
> > Those two "rep movsq"s are very suspicious, because
> > COMPLETION_INITIALIZER_ONSTACK() should initialize the data in-place,
> > rather than move it to some temporary variable and copy it back.
>=20
> Right. I've seen this behavior before when using c99 compound
> literals, but I was surprised to see it here.
>=20
> I also submitted a patch for the one driver that turned up a new
> warning because of this behavior:
>=20
> https://www.spinics.net/lists/raid/msg58766.html
>=20

This solution also came up into my mind but then I found there are
several callsites of COMPLETION_INITIALIZER_ONSTACK(), so I then tried
to find a way to fix the macro itself. But your patch looks good to me
;-)

> In case of the mmc driver, the behavior was as expected, it was
> just a little too large and I sent the obvious workaround for it
>=20
> https://patchwork.kernel.org/patch/9902063/
>=20

Yep.

> > I tried to reduce the size of completion struct, and the "rep movsq" did
> > go away, however it seemed the compiler still allocated the memory for
> > the temporary variables on the stack, because whenever I
> > increased/decreased  the size of completion, the stack size of
> > write_journal() got increased/decreased *7* times, but there are only
> > 3 journal_completion structures in write_journal(). So the *4* callsites
> > of COMPLETION_INITIALIZER_ONSTACK() looked very suspicous.
> >
> > So I come up with the following patch, trying to teach the compiler not
> > to do the unnecessary allocation, could you give it a try?
> >
> > Besides, I could also observe the stack size reduction of
> > write_journal() even for !LOCKDEP kernel.
>=20
> Ok.
>=20
> > -------------------
> > Reported-by: Arnd Bergmann <arnd@arndb.de>
> > Signed-off-by: Boqun Feng <boqun.feng@gmail.com>
> > ---
> >  include/linux/completion.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/include/linux/completion.h b/include/linux/completion.h
> > index 791f053f28b7..cae5400022a3 100644
> > --- a/include/linux/completion.h
> > +++ b/include/linux/completion.h
> > @@ -74,7 +74,7 @@ static inline void complete_release_commit(struct com=
pletion *x) {}
> >  #endif
> >
> >  #define COMPLETION_INITIALIZER_ONSTACK(work) \
> > -       ({ init_completion(&work); work; })
> > +       (*({ init_completion(&work); &work; }))
> >
> >  /**
> >   * DECLARE_COMPLETION - declare and initialize a completion structure
>=20
> Nice hack. Any idea why that's different to the compiler?
>=20

So *I think* the block {init_completion(&work); &work;} now will return
a pointer rather than a whole structure, and a pointer could fit in a
register, so the compiler won't bother to allocate the memory for it.

> I've applied that one to my test tree now, and reverted my own patch,
> will let you know if anything else shows up. I think we probably want

Thanks ;-)

> to merge both patches to mainline.
>=20

Agreed! Unless we want to remove COMPLETION_INITIALIZER_ONSTACK() for
some reason, then my patch is not needed.

Regards,
Boqun

>       Arnd

--47eKBCiAZYFK5l32
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmY/2kACgkQSXnow7UH
+rhSUgf/TjxrI9kEOqElAeveIo4EYNpCLGQ1x0M0iJ3/mBKjCjLzK/kxEVbU7CdY
1WO3S9bLpMyegOUruEKFC9i1zODsmrDiEoJ+ZrhQeRi70Hkc8m7tEtOs11GykUdC
vQBhypRm4NxeBAv0GAXFjk5FkcZhYyayJV0pAwo1Lp3y0ON3Jt6FzR5yrBJrcqC5
UM1wTav7DK5KK7kksuiHErAvFyetSFXGWjj0uUAZh9RUiyxxFFb6Rdd9s0UHTdo8
okfUuyQZUpZkT+lJEzdJf40XHemo+/BBtQJSRpqIkdNWXBtKFEV0GiccjBdOV6Wm
3/JEPyH2a6hIX4NB8SQ4PL3T9r1wFg==
=dVlC
-----END PGP SIGNATURE-----

--47eKBCiAZYFK5l32--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
