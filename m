Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21E2A6B02C3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 04:32:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r133so99826118pgr.6
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 01:32:55 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id e61si1982374plb.704.2017.08.17.01.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 01:32:54 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 83so8754809pgb.4
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 01:32:54 -0700 (PDT)
Date: Thu, 17 Aug 2017 16:33:13 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170817083313.GD11771@tardis>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
 <20170817074811.csim2edowld4xvky@gmail.com>
 <20170817080404.GC11771@tardis>
 <20170817081224.yp3qhqt6vijzvvpz@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="pQhZXvAqiZgbeUkD"
Content-Disposition: inline
In-Reply-To: <20170817081224.yp3qhqt6vijzvvpz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


--pQhZXvAqiZgbeUkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 17, 2017 at 10:12:24AM +0200, Ingo Molnar wrote:
>=20
> * Boqun Feng <boqun.feng@gmail.com> wrote:
>=20
> > > BTW., I don't think the #ifdef is necessary: lockdep_init_map_crosslo=
ck should map=20
> > > to nothing when lockdep is disabled, right?
> >=20
> > IIUC, lockdep_init_map_crosslock is only defined when
> > CONFIG_LOCKDEP_CROSSRELEASE=3Dy,
>=20
> Then lockdep_init_map_crosslock() should be defined in the !LOCKDEP case =
as well.
>=20
> > [...] moreover, completion::map, which used as
> > the parameter of lockdep_init_map_crosslock(), is only defined when
> > CONFIG_LOCKDEP_COMPLETE=3Dy.
>=20
> If the !LOCKDEP wrapper is a CPP macro then it can ignore that parameter =
just=20
> fine, and it won't be built.
>=20

Oops, I miss this part.. so I will cook a patch define
lockdep_init_map_crosslock() when !LOCKDEP and I think based on that,
there is no need to introducde INIT_WQ_BARRIER_ONSTACK(), we can simply:

	lockdep_init_map_crosslock(...);
	__init_completion();

in insert_wq_barrier(). Simpler.

Thanks for your suggestion.

Regards,
Boqun

> Thanks,
>=20
> 	Ingo

--pQhZXvAqiZgbeUkD
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEyBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmVVMYACgkQSXnow7UH
+rgMpgf3QTM3HajvNuJbPsO5zujqWFZq32u9uKHvTxLDZEZcE5EvCViNf+GYjms7
W0sEtupZ9FIM0AeGqBjyh85MH8XBq8txgo3yt5DjPn9NYgh5m99dQeDm1Jz2QIdy
h3UBtew7JsHW9qjQoP5WZ7FpPFY2ZLGhtqdx1pj0HoGbuUNZ4OUkgOl+ZtjTlkGh
A3xEIxf4jXuSmRYJwW91lcWozOSzEh67wtePyTgZGl9omtcYRe8vZbry3O8/AnWv
h53nZoWqhNjDpaYTTfauv0DkSyDU9zIQPr+Q2YBFdTqT7yQd8tBwKto7wRwoG1RN
PMQBvJ1SYFulgHKeNhUZIceZLFMr
=1XDT
-----END PGP SIGNATURE-----

--pQhZXvAqiZgbeUkD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
