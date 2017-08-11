Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A640D6B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 04:03:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i192so30400934pgc.11
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 01:03:20 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id b8si184711pfh.440.2017.08.11.01.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 01:03:19 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id j68so2882550pfc.2
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 01:03:19 -0700 (PDT)
Date: Fri, 11 Aug 2017 16:03:29 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170811080329.3ehu7pp7lcm62ji6@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
 <20170810131737.skdyy4qcxlikbyeh@tardis>
 <20170811034328.GH20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="53ffyjemh4ckify3"
Content-Disposition: inline
In-Reply-To: <20170811034328.GH20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--53ffyjemh4ckify3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 11, 2017 at 12:43:28PM +0900, Byungchul Park wrote:
> On Thu, Aug 10, 2017 at 09:17:37PM +0800, Boqun Feng wrote:
> > > > > > @@ -4826,6 +4851,7 @@ static inline int depend_after(struct hel=
d_lock
> > > > > *hlock)
> > > > > >   * Check if the xhlock is valid, which would be false if,
> > > > > >   *
> > > > > >   *    1. Has not used after initializaion yet.
> > > > > > + *    2. Got invalidated.
> > > > > >   *
> > > > > >   * Remind hist_lock is implemented as a ring buffer.
> > > > > >   */
> > > > > > @@ -4857,6 +4883,7 @@ static void add_xhlock(struct held_lock *=
hlock)
> > > > > >
> > > > > >  	/* Initialize hist_lock's members */
> > > > > >  	xhlock->hlock =3D *hlock;
> > > > > > +	xhlock->hist_id =3D current->hist_id++;
> > >=20
> > > Besides, is this code correct? Does this just make xhlock->hist_id
> > > one-less-than the curr->hist_id, which cause the invalidation every t=
ime
> > > you do ring buffer unwinding?
> > >=20
> > > Regards,
> > > Boqun
> > >=20
> >=20
> > So basically, I'm suggesting do this on top of your patch, there is also
> > a fix in commit_xhlocks(), which I think you should swap the parameters
> > in before(...), no matter using task_struct::hist_id or using
> > task_struct::xhlock_idx as the timestamp.
> >=20
> > Hope this could make my point more clear, and if I do miss something,
> > please point it out, thanks ;-)
>=20
> Sorry for mis-understanding. I like your patch. I think it works.
>=20

Thanks for taking a look at it ;-)

> Additionally.. See below..
>=20
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 074872f016f8..886ba79bfc38 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -854,9 +854,6 @@ struct task_struct {
> >  	unsigned int xhlock_idx;
> >  	/* For restoring at history boundaries */
> >  	unsigned int xhlock_idx_hist[XHLOCK_NR];
> > -	unsigned int hist_id;
> > -	/* For overwrite check at each context exit */
> > -	unsigned int hist_id_save[XHLOCK_NR];
> >  #endif
> > =20
> >  #ifdef CONFIG_UBSAN
> > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > index 699fbeab1920..04c6c8d68e18 100644
> > --- a/kernel/locking/lockdep.c
> > +++ b/kernel/locking/lockdep.c
> > @@ -4752,10 +4752,8 @@ void crossrelease_hist_start(enum xhlock_context=
_t c)
> >  {
> >  	struct task_struct *cur =3D current;
> > =20
> > -	if (cur->xhlocks) {
> > +	if (cur->xhlocks)
> >  		cur->xhlock_idx_hist[c] =3D cur->xhlock_idx;
> > -		cur->hist_id_save[c] =3D cur->hist_id;
> > -	}
> >  }
> > =20
> >  void crossrelease_hist_end(enum xhlock_context_t c)
> > @@ -4769,7 +4767,7 @@ void crossrelease_hist_end(enum xhlock_context_t =
c)
> >  		cur->xhlock_idx =3D idx;
> > =20
> >  		/* Check if the ring was overwritten. */
> > -		if (h->hist_id !=3D cur->hist_id_save[c])
> > +		if (h->hist_id !=3D idx)
> >  			invalidate_xhlock(h);
> >  	}
> >  }
> > @@ -4849,7 +4847,7 @@ static void add_xhlock(struct held_lock *hlock)
> > =20
> >  	/* Initialize hist_lock's members */
> >  	xhlock->hlock =3D *hlock;
> > -	xhlock->hist_id =3D current->hist_id++;
> > +	xhlock->hist_id =3D idx;
> > =20
> >  	xhlock->trace.nr_entries =3D 0;
> >  	xhlock->trace.max_entries =3D MAX_XHLOCK_TRACE_ENTRIES;
> > @@ -5005,7 +5003,7 @@ static int commit_xhlock(struct cross_lock *xlock=
, struct hist_lock *xhlock)
> >  static void commit_xhlocks(struct cross_lock *xlock)
> >  {
> >  	unsigned int cur =3D current->xhlock_idx;
> > -	unsigned int prev_hist_id =3D xhlock(cur).hist_id;
> > +	unsigned int prev_hist_id =3D cur + 1;
>=20
> I should have named it another. Could you suggest a better one?
>=20

I think "prev" is fine, because I thought the "previous" means the
xhlock item we visit _previously_.

> >  	unsigned int i;
> > =20
> >  	if (!graph_lock())
> > @@ -5030,7 +5028,7 @@ static void commit_xhlocks(struct cross_lock *xlo=
ck)
> >  			 * hist_id than the following one, which is impossible
> >  			 * otherwise.
>=20
> Or we need to modify the comment so that the word 'prev' does not make
> readers confused. It was my mistake.
>=20

I think the comment needs some help, but before you do it, could you
have another look at what Peter proposed previously? Note you have a
same_context_xhlock() check in the commit_xhlocks(), so the your
previous overwrite case actually could be detected, I think.

However, one thing may not be detected is this case:

		ppppppppppppppppppppppppppppppppppwwwwwwww
wrapped >	wwwwwww

	where p: process and w: worker.

, because p and w are in the same task_irq_context(). I discussed this
with Peter yesterday, and he has a good idea: unconditionally do a reset
on the ring buffer whenever we do a crossrelease_hist_end(XHLOCK_PROC).
Basically it means we empty the lock history whenever we finished a
worker function in a worker thread or we are about to return to
userspace after we finish the syscall. This could further save some
memory and so I think this may be better than my approach.

How does this sound to you?

Regards,
Boqun

> Thanks,
> Byungchul
>=20

--53ffyjemh4ckify3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmNZM0ACgkQSXnow7UH
+rjEMwf9HGZP8GOdd7bEURaNvj/0wTHduSA86LpdlgF87tlDVgb7ATJKI4RGhNaW
VUH1pf3UZKX2D0zIvZGSMUl4OeQ++HR+R2HPISc+3NFaHB+Gyxes/e2HbdLUnMZ+
3ZGahEQvJindzYBIg7Y3mWU5jZ+sPWrUopIpyscFpVYKcHVlNqCTmqZDpFOwunYT
CzMo4ZytgC6EXoDBtVl3HfmsV4iy/9FFX3p5HLC9+Zu4wolbp92/K8j+5RNw3rew
3w9Sd2gz7LLVR23PGgo5C/MvglntEjsqvqi2SY/eAKhRuVzXn9O8/U6Cv8c0JHwV
bwLNBqIiH/BwJDou6al3Xxhb1prQ0w==
=Wg2V
-----END PGP SIGNATURE-----

--53ffyjemh4ckify3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
