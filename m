Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 857E96B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 01:40:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r29so4185951pfi.7
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:40:35 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id d6si43074pgt.177.2017.08.15.22.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 22:40:34 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id o86so1935771pfj.1
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:40:34 -0700 (PDT)
Date: Wed, 16 Aug 2017 13:40:51 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170816054051.GA11771@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
 <20170816043746.GQ20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Content-Disposition: inline
In-Reply-To: <20170816043746.GQ20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 16, 2017 at 01:37:46PM +0900, Byungchul Park wrote:
> On Wed, Aug 16, 2017 at 12:05:31PM +0800, Boqun Feng wrote:
> > On Wed, Aug 16, 2017 at 09:16:37AM +0900, Byungchul Park wrote:
> > > On Tue, Aug 15, 2017 at 10:20:20AM +0200, Ingo Molnar wrote:
> > > >=20
> > > > So with the latest fixes there's a new lockdep warning on one of my=
 testboxes:
> > > >=20
> > > > [   11.322487] EXT4-fs (sda2): mounted filesystem with ordered data=
 mode. Opts: (null)
> > > >=20
> > > > [   11.495661] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > [   11.502093] WARNING: possible circular locking dependency detect=
ed
> > > > [   11.508507] 4.13.0-rc5-00497-g73135c58-dirty #1 Not tainted
> > > > [   11.514313] ----------------------------------------------------=
--
> > > > [   11.520725] umount/533 is trying to acquire lock:
> > > > [   11.525657]  ((complete)&barr->done){+.+.}, at: [<ffffffff810fdb=
b3>] flush_work+0x213/0x2f0
> > > > [   11.534411]=20
> > > >                but task is already holding lock:
> > > > [   11.540661]  (lock#3){+.+.}, at: [<ffffffff8122678d>] lru_add_dr=
ain_all_cpuslocked+0x3d/0x190
> > > > [   11.549613]=20
> > > >                which lock already depends on the new lock.
> > > >=20
> > > > The full splat is below. The kernel config is nothing fancy - distr=
o derived,=20
> > > > pretty close to defconfig, with lockdep enabled.
> > >=20
> > > I see...
> > >=20
> > > Worker A : acquired of wfc.work -> wait for cpu_hotplug_lock to be re=
leased
> > > Task   B : acquired of cpu_hotplug_lock -> wait for lock#3 to be rele=
ased
> > > Task   C : acquired of lock#3 -> wait for completion of barr->done
> >=20
> > >From the stack trace below, this barr->done is for flush_work() in
> > lru_add_drain_all_cpuslocked(), i.e. for work "per_cpu(lru_add_drain_wo=
rk)"
> >=20
> > > Worker D : wait for wfc.work to be released -> will complete barr->do=
ne
> >=20
> > and this barr->done is for work "wfc.work".
>=20
> I think it can be the same instance. wait_for_completion() in flush_work()
> e.g. at task C in my example, waits for completion which we expect to be
> done by a worker e.g. worker D in my example.
>=20
> I think the problem is caused by a write-acquisition of wfc.work in
> process_one_work(). The acquisition of wfc.work should be reenterable,
> that is, read-acquisition, shouldn't it?
>=20

The only thing is that wfc.work is not a real and please see code in
flush_work(). And if a task C do a flush_work() for "wfc.work" with
lock#3 held, it needs to "acquire" wfc.work before it
wait_for_completion(), which is already a deadlock case:

	lock#3 -> wfc.work -> cpu_hotplug_lock -+
          ^                                     |
	  |                                     |
	  +-------------------------------------+

, without crossrelease enabled. So the task C didn't flush work wfc.work
in the previous case, which implies barr->done in Task C and Worker D
are not the same instance.

Make sense?

Regards,
Boqun

> I might be wrong... Please fix me if so.
>=20
> Thank you,
> Byungchul
>=20
> > So those two barr->done could not be the same instance, IIUC. Therefore
> > the deadlock case is not possible.
> >=20
> > The problem here is all barr->done instances are initialized at
> > insert_wq_barrier() and they belongs to the same lock class, to fix
> > this, we need to differ barr->done with different lock classes based on
> > the corresponding works.
> >=20
> > How about the this(only compilation test):
> >=20
> > ----------------->8
> > diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> > index e86733a8b344..d14067942088 100644
> > --- a/kernel/workqueue.c
> > +++ b/kernel/workqueue.c
> > @@ -2431,6 +2431,27 @@ struct wq_barrier {
> >  	struct task_struct	*task;	/* purely informational */
> >  };
> > =20
> > +#ifdef CONFIG_LOCKDEP_COMPLETE
> > +# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
> > +do {										\
> > +	INIT_WORK_ONSTACK(&(barr)->work, func);					\
> > +	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
> > +	lockdep_init_map_crosslock((struct lockdep_map *)&(barr)->done.map,	\
> > +				   "(complete)" #barr,				\
> > +				   (target)->lockdep_map.key, 1); 		\
> > +	__init_completion(&barr->done);						\
> > +	barr->task =3D current;							\
> > +} while (0)
> > +#else
> > +# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
> > +do {										\
> > +	INIT_WORK_ONSTACK(&(barr)->work, func);					\
> > +	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
> > +	init_completion(&barr->done);						\
> > +	barr->task =3D current;							\
> > +} while (0)
> > +#endif
> > +
> >  static void wq_barrier_func(struct work_struct *work)
> >  {
> >  	struct wq_barrier *barr =3D container_of(work, struct wq_barrier, wor=
k);
> > @@ -2474,10 +2495,7 @@ static void insert_wq_barrier(struct pool_workqu=
eue *pwq,
> >  	 * checks and call back into the fixup functions where we
> >  	 * might deadlock.
> >  	 */
> > -	INIT_WORK_ONSTACK(&barr->work, wq_barrier_func);
> > -	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&barr->work));
> > -	init_completion(&barr->done);
> > -	barr->task =3D current;
> > +	INIT_WQ_BARRIER_ONSTACK(barr, wq_barrier_func, target);
> > =20
> >  	/*
> >  	 * If @target is currently being executed, schedule the

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmT2t8ACgkQSXnow7UH
+rjj9wf+MlcXppLXXlgo2JaQ2om9HkTwqu2BE+0knw5ohoXfYC88vUgj7HXiAxb1
fIg035V3Io+5fsaengQNaEtRIZqt2opv/0yQ3uGm5XuvpqVfx/sX0gYJsqjh6OTd
qdiNEsDN22z5BIMrlzbGMfB3dxD2WZFUYEUJeVbgyOkbgduPIIvI+RQnb7f7b0KK
tFrXXzA2cwaFDtUT5Ze+vW+hMoF9jN2vLK23fvsW45qW/z7idoJCNJFDWjC4ZgqU
4vgps4I0DvJy/XpesRVOsFWLMv3vNTFvPY9YioOawRWTsnlODP8QsR88yMSBQ7hy
YWLq9R+wwc2X8z62RpfPSxm4tH8NeQ==
=+Bv2
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
