Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62C2C6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:51:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o82so5830639pfj.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:51:22 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 81si1515050pfs.644.2017.08.10.05.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 05:51:20 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id y192so550360pgd.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:51:20 -0700 (PDT)
Date: Thu, 10 Aug 2017 20:51:33 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170810125133.2poixhni4d5aqkpy@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="i7xzaj27tckrkcft"
Content-Disposition: inline
In-Reply-To: <016b01d311d1$d02acfa0$70806ee0$@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--i7xzaj27tckrkcft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 10, 2017 at 09:11:32PM +0900, Byungchul Park wrote:
> > -----Original Message-----
> > From: Boqun Feng [mailto:boqun.feng@gmail.com]
> > Sent: Thursday, August 10, 2017 8:59 PM
> > To: Byungchul Park
> > Cc: peterz@infradead.org; mingo@kernel.org; tglx@linutronix.de;
> > walken@google.com; kirill@shutemov.name; linux-kernel@vger.kernel.org;
> > linux-mm@kvack.org; akpm@linux-foundation.org; willy@infradead.org;
> > npiggin@gmail.com; kernel-team@lge.com
> > Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
> > buffer overwrite
> >=20
> > On Mon, Aug 07, 2017 at 04:12:53PM +0900, Byungchul Park wrote:
> > > The ring buffer can be overwritten by hardirq/softirq/work contexts.
> > > That cases must be considered on rollback or commit. For example,
> > >
> > >           |<------ hist_lock ring buffer size ----->|
> > >           ppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
> > > wrapped > iiiiiiiiiiiiiiiiiiiiiii....................
> > >
> > >           where 'p' represents an acquisition in process context,
> > >           'i' represents an acquisition in irq context.
> > >
> > > On irq exit, crossrelease tries to rollback idx to original position,
> > > but it should not because the entry already has been invalid by
> > > overwriting 'i'. Avoid rollback or commit for entries overwritten.
> > >
> > > Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> > > ---
> > >  include/linux/lockdep.h  | 20 +++++++++++++++++++
> > >  include/linux/sched.h    |  3 +++
> > >  kernel/locking/lockdep.c | 52
> > +++++++++++++++++++++++++++++++++++++++++++-----
> > >  3 files changed, 70 insertions(+), 5 deletions(-)
> > >
> > > diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
> > > index 0c8a1b8..48c244c 100644
> > > --- a/include/linux/lockdep.h
> > > +++ b/include/linux/lockdep.h
> > > @@ -284,6 +284,26 @@ struct held_lock {
> > >   */
> > >  struct hist_lock {
> > >  	/*
> > > +	 * Id for each entry in the ring buffer. This is used to
> > > +	 * decide whether the ring buffer was overwritten or not.
> > > +	 *
> > > +	 * For example,
> > > +	 *
> > > +	 *           |<----------- hist_lock ring buffer size ------->|
> > > +	 *           pppppppppppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiii
> > > +	 * wrapped > iiiiiiiiiiiiiiiiiiiiiiiiiii.......................
> > > +	 *
> > > +	 *           where 'p' represents an acquisition in process
> > > +	 *           context, 'i' represents an acquisition in irq
> > > +	 *           context.
> > > +	 *
> > > +	 * In this example, the ring buffer was overwritten by
> > > +	 * acquisitions in irq context, that should be detected on
> > > +	 * rollback or commit.
> > > +	 */
> > > +	unsigned int hist_id;
> > > +
> > > +	/*
> > >  	 * Seperate stack_trace data. This will be used at commit step.
> > >  	 */
> > >  	struct stack_trace	trace;
> > > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > > index 5becef5..373466b 100644
> > > --- a/include/linux/sched.h
> > > +++ b/include/linux/sched.h
> > > @@ -855,6 +855,9 @@ struct task_struct {
> > >  	unsigned int xhlock_idx;
> > >  	/* For restoring at history boundaries */
> > >  	unsigned int xhlock_idx_hist[CONTEXT_NR];
> > > +	unsigned int hist_id;
> > > +	/* For overwrite check at each context exit */
> > > +	unsigned int hist_id_save[CONTEXT_NR];
> > >  #endif
> > >
> > >  #ifdef CONFIG_UBSAN
> > > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > > index afd6e64..5168dac 100644
> > > --- a/kernel/locking/lockdep.c
> > > +++ b/kernel/locking/lockdep.c
> > > @@ -4742,6 +4742,17 @@ void lockdep_rcu_suspicious(const char *file,
> > const int line, const char *s)
> > >  static atomic_t cross_gen_id; /* Can be wrapped */
> > >
> > >  /*
> > > + * Make an entry of the ring buffer invalid.
> > > + */
> > > +static inline void invalidate_xhlock(struct hist_lock *xhlock)
> > > +{
> > > +	/*
> > > +	 * Normally, xhlock->hlock.instance must be !NULL.
> > > +	 */
> > > +	xhlock->hlock.instance =3D NULL;
> > > +}
> > > +
> > > +/*
> > >   * Lock history stacks; we have 3 nested lock history stacks:
> > >   *
> > >   *   Hard IRQ
> > > @@ -4773,14 +4784,28 @@ void lockdep_rcu_suspicious(const char *file,
> > const int line, const char *s)
> > >   */
> > >  void crossrelease_hist_start(enum context_t c)
> > >  {
> > > -	if (current->xhlocks)
> > > -		current->xhlock_idx_hist[c] =3D current->xhlock_idx;
> > > +	struct task_struct *cur =3D current;
> > > +
> > > +	if (cur->xhlocks) {
> > > +		cur->xhlock_idx_hist[c] =3D cur->xhlock_idx;
> > > +		cur->hist_id_save[c] =3D cur->hist_id;
> > > +	}
> > >  }
> > >
> > >  void crossrelease_hist_end(enum context_t c)
> > >  {
> > > -	if (current->xhlocks)
> > > -		current->xhlock_idx =3D current->xhlock_idx_hist[c];
> > > +	struct task_struct *cur =3D current;
> > > +
> > > +	if (cur->xhlocks) {
> > > +		unsigned int idx =3D cur->xhlock_idx_hist[c];
> > > +		struct hist_lock *h =3D &xhlock(idx);
> > > +
> > > +		cur->xhlock_idx =3D idx;
> > > +
> > > +		/* Check if the ring was overwritten. */
> > > +		if (h->hist_id !=3D cur->hist_id_save[c])
> >=20
> > Could we use:
> >=20
> > 		if (h->hist_id !=3D idx)
>=20
> No, we cannot.
>=20

Hey, I'm not buying it. task_struct::hist_id and task_struct::xhlock_idx
are increased at the same place(in add_xhlock()), right?

And, yes, xhlock_idx will get decreased when we do ring-buffer
unwinding, but that's OK, because we need to throw away those recently
added items.

And xhlock_idx always points to the most recently added valid item,
right?  Any other item's idx must "before()" the most recently added
one's, right? So ::xhlock_idx acts just like a timestamp, doesn't it?

Maybe I'm missing something subtle, but could you show me an example,
that could end up being a problem if we use xhlock_idx as the hist_id?

> hist_id is a kind of timestamp and used to detect overwriting
> data into places of same indexes of the ring buffer. And idx is
> just an index. :) IOW, they mean different things.
>=20
> >=20
> > here, and
> >=20
> > > +			invalidate_xhlock(h);
> > > +	}
> > >  }
> > >
> > >  static int cross_lock(struct lockdep_map *lock)
> > > @@ -4826,6 +4851,7 @@ static inline int depend_after(struct held_lock
> > *hlock)
> > >   * Check if the xhlock is valid, which would be false if,
> > >   *
> > >   *    1. Has not used after initializaion yet.
> > > + *    2. Got invalidated.
> > >   *
> > >   * Remind hist_lock is implemented as a ring buffer.
> > >   */
> > > @@ -4857,6 +4883,7 @@ static void add_xhlock(struct held_lock *hlock)
> > >
> > >  	/* Initialize hist_lock's members */
> > >  	xhlock->hlock =3D *hlock;
> > > +	xhlock->hist_id =3D current->hist_id++;

Besides, is this code correct? Does this just make xhlock->hist_id
one-less-than the curr->hist_id, which cause the invalidation every time
you do ring buffer unwinding?

Regards,
Boqun

> >=20
> > use:
> >=20
> > 	xhlock->hist_id =3D idx;
> >=20
> > and,
>=20
> Same.
>=20
> >=20
> >=20
> > >
> > >  	xhlock->trace.nr_entries =3D 0;
> > >  	xhlock->trace.max_entries =3D MAX_XHLOCK_TRACE_ENTRIES;
> > > @@ -4995,6 +5022,7 @@ static int commit_xhlock(struct cross_lock *xlo=
ck,
> > struct hist_lock *xhlock)
> > >  static void commit_xhlocks(struct cross_lock *xlock)
> > >  {
> > >  	unsigned int cur =3D current->xhlock_idx;
> > > +	unsigned int prev_hist_id =3D xhlock(cur).hist_id;
> >=20
> > use:
> > 	unsigned int prev_hist_id =3D cur;
> >=20
> > here.
>=20
> Same.
>=20
>=20

--i7xzaj27tckrkcft
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmMVtIACgkQSXnow7UH
+riGdwgApcsiZdqKu98PF9CY95arBR9U7rAe0qtx9PnXng2i2G77+aoMMEWVtCh1
pJVzvEgZtBbjOImUeF30d+H9Vy3DdkcR9GFmt2tLT7kszR2iE9Fakqk2hzR0eXHv
Z+kis+wckatN9sGFL1OsP3HAC7Mx1HTRHKnbG/cXPufrKToap9Sk6yOl9rZeSd69
GRkL2Nz1CruwDVRvmaMEUHTVEIhQGupd0BzEKJ8GFo3qTqyaoyvleo/83kNJGZNc
EHWHqYRJazpFjoICYA9g10itMqz4cY+7mSJBiPZpqX1/i9K4CPkik/S3H3vY4jBl
ffc9OcTp5OW70mLMMGWfYlKvXVqKew==
=IARR
-----END PGP SIGNATURE-----

--i7xzaj27tckrkcft--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
