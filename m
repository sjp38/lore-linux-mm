Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3A46B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 04:03:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r133so98676935pgr.6
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 01:03:52 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 3si1792596pfo.179.2017.08.17.01.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 01:03:51 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id y129so8643533pgy.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 01:03:51 -0700 (PDT)
Date: Thu, 17 Aug 2017 16:04:04 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170817080404.GC11771@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
 <20170817074811.csim2edowld4xvky@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="qtZFehHsKgwS5rPz"
Content-Disposition: inline
In-Reply-To: <20170817074811.csim2edowld4xvky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--qtZFehHsKgwS5rPz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 17, 2017 at 09:48:11AM +0200, Ingo Molnar wrote:
>=20
> * Boqun Feng <boqun.feng@gmail.com> wrote:
>=20
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
>=20
> Is there any progress with this bug? This false positive warning regressi=
on is=20
> blocking the locking tree.
>=20

I have been trying to reproduce the false positive on my machine, but
haven't succeeded. ;-( Have you tried this?

But I have been using this patch for a day and haven't shoot my foot
yet.

> BTW., I don't think the #ifdef is necessary: lockdep_init_map_crosslock s=
hould map=20
> to nothing when lockdep is disabled, right?

IIUC, lockdep_init_map_crosslock is only defined when
CONFIG_LOCKDEP_CROSSRELEASE=3Dy, moreover, completion::map, which used as
the parameter of lockdep_init_map_crosslock(), is only defined when
CONFIG_LOCKDEP_COMPLETE=3Dy. So the #ifdef is necessary, but maybe we can
clean this thing up in the future.

I will send a proper patch, so the thing could move forwards. Just a
minute ;-)

Regards,
Boqun

>=20
> Thanks,
>=20
> 	Ingo

--qtZFehHsKgwS5rPz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmVTfAACgkQSXnow7UH
+ri6eAf+JOu+fAhWne67inCvn0nK1nBw7zl5jHF/esSom/6F8oAO3CvaTW7+fgqe
4JA8NfSZPoxmwY6hUm4odIztCWL34VUZcqrVD0i+ry1TZywKBhbMMWIEzuVwGvIQ
w2KZbAloD88AzJ1JgKSPBEU6v6gN+jpMZFMAlvykU/x36V2vFFsPIORtBaH35rh4
kalt8VXxJV5KgyUoQSNCWnbyWc7/+OX1zlAzjNTiLT9r2LBHxCYjxza4xdvSClsF
D8PkWz8AOA7MAJXsjCDXsJAP1+Yr0ah/QhAVfvFKaP98yF3lJKr7BSDT7j3/conb
46gJq6QZ3ZVG5jJ27o9cCdwOl++Gbw==
=jXYI
-----END PGP SIGNATURE-----

--qtZFehHsKgwS5rPz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
