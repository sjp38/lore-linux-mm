Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id BCA7A6B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 10:50:09 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so1003610lag.14
        for <linux-mm@kvack.org>; Sat, 20 Oct 2012 07:50:07 -0700 (PDT)
Date: Sat, 20 Oct 2012 20:49:58 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121020204958.4bc8e293@sacrilege>
In-Reply-To: <CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/eS_.8PEyJyRd2zX1TbgKDk5"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org

--Sig_/eS_.8PEyJyRd2zX1TbgKDk5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 20 Oct 2012 08:42:33 -0400
Paul Moore <paul@paul-moore.com> wrote:

> Thanks for the problem report.  I'm not going to be in a position to start
> looking into this until late Sunday, but hopefully it will be a quick fix.
>=20
> Two quick questions (my apologies, I'm not able to dig through your logs
> right now): do you see this leak on kernels < 3.5.0, and are you using any
> labeled IPsec connections?
>=20

As I understand, labelled connections are only used in SELinux
and SMACK LSM, which are not enabled (in Kconfig, i.e. not built) in any
of the kernels I use.

The only LSM I have enabled (and actually use on 2/4 of these machines)
is AppArmor, and though I think it doesn't attach any labels to network
connections yet (there's a "Wishlist" bug at
https://bugs.launchpad.net/ubuntu/+source/apparmor/+bug/796588, but I
can't seem to find an existing implementation).

I believe it has started with 3.5.0, according to all available logs I
have. I'm afraid laziness and other tasks have prevented me from
looking into and reporting the issue back then, but memory graph trends
start at the exact time of reboot into 3.5.0 kernels, and before that,
there're no such trends for slab memory usage.

I've been able to ignore and work around the problem for months now, so
I don't think there's any rush at all ;)

But that said, currently I've started git bisect process between v3.5
and v3.4 tags, so hopefully I'll get good-enough results of it before
you'll get to it (probably in a few hours to a few days).

Also, I've found that switching to "slab" allocator from "slub" doesn't
help the problem at all, so I guess something doesn't get freed in the
code indeed, though I hasn't been able to find anything relevant in the
logs for the sources where secpath_put and secpath_dup are used, and
decided to try bisect.


--=20
Mike Kazantsev // fraggod.net

--Sig_/eS_.8PEyJyRd2zX1TbgKDk5
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCCuhkACgkQASbOZpzyXnHUJQCg6MAW5gCL0Ewhk0bc1/nOKhMr
PQYAn0JnR6ta8Ku7OncjUS9lE4l1QR2q
=5wtI
-----END PGP SIGNATURE-----

--Sig_/eS_.8PEyJyRd2zX1TbgKDk5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
