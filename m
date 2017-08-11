Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D44166B02C3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 21:02:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d5so23725769pfg.3
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 18:02:50 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id b61si5253732plc.494.2017.08.10.18.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 18:02:49 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id j68so2073992pfc.2
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 18:02:49 -0700 (PDT)
Date: Fri, 11 Aug 2017 09:03:00 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170811010300.x2vo5yenxzvgujoq@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
 <20170811004021.GF20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="hwzhqrjmgyrvnnj7"
Content-Disposition: inline
In-Reply-To: <20170811004021.GF20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--hwzhqrjmgyrvnnj7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 11, 2017 at 09:40:21AM +0900, Byungchul Park wrote:
> On Thu, Aug 10, 2017 at 08:51:33PM +0800, Boqun Feng wrote:
> > > > >  void crossrelease_hist_end(enum context_t c)
> > > > >  {
> > > > > -	if (current->xhlocks)
> > > > > -		current->xhlock_idx =3D current->xhlock_idx_hist[c];
> > > > > +	struct task_struct *cur =3D current;
> > > > > +
> > > > > +	if (cur->xhlocks) {
> > > > > +		unsigned int idx =3D cur->xhlock_idx_hist[c];
> > > > > +		struct hist_lock *h =3D &xhlock(idx);
> > > > > +
> > > > > +		cur->xhlock_idx =3D idx;
> > > > > +
> > > > > +		/* Check if the ring was overwritten. */
> > > > > +		if (h->hist_id !=3D cur->hist_id_save[c])
> > > >=20
> > > > Could we use:
> > > >=20
> > > > 		if (h->hist_id !=3D idx)
> > >=20
> > > No, we cannot.
> > >=20
> >=20
> > Hey, I'm not buying it. task_struct::hist_id and task_struct::xhlock_idx
> > are increased at the same place(in add_xhlock()), right?
>=20
> Right.
>=20
> > And, yes, xhlock_idx will get decreased when we do ring-buffer
>=20
> This is why we should keep both of them.
>=20
> > unwinding, but that's OK, because we need to throw away those recently
> > added items.
> >=20
> > And xhlock_idx always points to the most recently added valid item,
>=20
> No, it's not true in case that the ring buffer was wrapped like:
>=20
>           ppppppppppppppppppppppppiiiiiiiiiiiiiiiiiiiiiiii
> wrapped > iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii................
>                                  ^
>                      xhlock_idx points here after unwinding,
>                      and it's not a valid one.
>=20
>           where p represents an acquisition in process context,
>           i represents an acquisition in irq context.
>=20

Yeah, but we can detect this with comparison between the
hist_lock::hist_id and the task_struct::xhlock_idx in
commit_xhlocks()(see my patch), no?

Regards,
Boqun

> > right?  Any other item's idx must "before()" the most recently added
> > one's, right? So ::xhlock_idx acts just like a timestamp, doesn't it?
>=20
> Both of two answers are _no_.
>=20
> > Maybe I'm missing something subtle, but could you show me an example,
> > that could end up being a problem if we use xhlock_idx as the hist_id?
>=20
> See the example above. We cannot detect whether it was wrapped or not usi=
ng
> xhlock_idx.
>=20
> >=20
> > > hist_id is a kind of timestamp and used to detect overwriting
> > > data into places of same indexes of the ring buffer. And idx is
> > > just an index. :) IOW, they mean different things.
> > >=20
> > > >=20
> > > > here, and
> > > >=20
> > > > > +			invalidate_xhlock(h);
> > > > > +	}
> > > > >  }
> > > > >
> > > > >  static int cross_lock(struct lockdep_map *lock)
> > > > > @@ -4826,6 +4851,7 @@ static inline int depend_after(struct held_=
lock
> > > > *hlock)
> > > > >   * Check if the xhlock is valid, which would be false if,
> > > > >   *
> > > > >   *    1. Has not used after initializaion yet.
> > > > > + *    2. Got invalidated.
> > > > >   *
> > > > >   * Remind hist_lock is implemented as a ring buffer.
> > > > >   */
> > > > > @@ -4857,6 +4883,7 @@ static void add_xhlock(struct held_lock *hl=
ock)
> > > > >
> > > > >  	/* Initialize hist_lock's members */
> > > > >  	xhlock->hlock =3D *hlock;
> > > > > +	xhlock->hist_id =3D current->hist_id++;
> >=20
> > Besides, is this code correct? Does this just make xhlock->hist_id
> > one-less-than the curr->hist_id, which cause the invalidation every time
> > you do ring buffer unwinding?
>=20
> Right. "save =3D hist_id++" should be "save =3D ++hist_id". Could you fix=
 it?
>=20
> Thank you,
> Byungchul
>=20

--hwzhqrjmgyrvnnj7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmNAkAACgkQSXnow7UH
+rimrgf+Ki+p2IfF83gxnYZwKKX8xUGeXOr+KR3mksRqTjbzqsr/o+GrVKSvJdF2
XsBJgzs6w7lBa9vTwsBH63vFtMc8mo3j2t4wNZRj9mn7MtAtqS2lf61yelMzO7Mc
tH+V2EUTHzdUqBILumzQ2qwJ31zTHsd8PXqFrwFk4TERCi+f9+WE8XY/It23tNmR
FGY0ybVUerKAa1t8iWeKGoMNUpE8/tyCV5rAKbHJtKXCt9YRi0uivZF7V4mdp8aY
MJ+wacA1ZwQt9311GaaZWyVFsSqBm2sDdLU3sMZtNOsq9+FmULjwvV2tm9rybDSh
7t942y/vTlcfBs14+wbShtQdOX7O0g==
=Gqrh
-----END PGP SIGNATURE-----

--hwzhqrjmgyrvnnj7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
