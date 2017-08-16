Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBF0A6B0292
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 01:57:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d5so4504850pfg.3
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:57:50 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id m6si65975pli.389.2017.08.15.22.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 22:57:49 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t83so473867pfj.3
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:57:49 -0700 (PDT)
Date: Wed, 16 Aug 2017 13:58:08 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170816055808.GB11771@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
 <20170816050506.GR20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="St7VIuEGZ6dlpu13"
Content-Disposition: inline
In-Reply-To: <20170816050506.GR20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--St7VIuEGZ6dlpu13
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 16, 2017 at 02:05:06PM +0900, Byungchul Park wrote:
> On Wed, Aug 16, 2017 at 12:05:31PM +0800, Boqun Feng wrote:
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
> >=20
> > So those two barr->done could not be the same instance, IIUC. Therefore
> > the deadlock case is not possible.
> >=20
> > The problem here is all barr->done instances are initialized at
> > insert_wq_barrier() and they belongs to the same lock class, to fix
>=20
> I'm not sure this caused the lockdep warning but, if they belongs to the
> same class even though they couldn't be the same instance as you said, I
> also think that is another problem and should be fixed.
>=20

My point was more like this is a false positive case, which we should
avoid as hard as we can, because this very case doesn't look like a
deadlock to me.

Maybe the pattern above does exist in current kernel, but we need to
guide/adjust lockdep to find the real case showing it's happening.

Regards,
Boqun

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

--St7VIuEGZ6dlpu13
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmT3uwACgkQSXnow7UH
+rg3IQgAp1jqK6uxiWzBA5xAU7l3DOng5vAQo1ZRASZ39tKjrlYFDfT6K/PeEXgg
LRpulqdcOHfkGgd7F9NJoDpbnipkeM2f2Y5pzcgxfG3u+dK3Gk/lyTzUk7i7basL
+E8Jjhowz9GsSCcK+fu/Hnq75LrvGdg/pt2mbHXUWtC4k+7fsClQed6jx8I9sO7e
eBPVTC0WFoJ7XiV25QIjuZuAJR3LtOOUvgospffQXA/T6wjJVRobv4p7+FKnrm6+
lYYwH1CQfXGRc+NjeSslUINHhuIDF3ClXfBzX1ikLFEUnCA9vhmOKBI7QC0ciS05
CNyvqFroy2MSoYhCgQOozY9zbazbAA==
=SwwL
-----END PGP SIGNATURE-----

--St7VIuEGZ6dlpu13--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
