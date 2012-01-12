Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 806776B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 06:17:05 -0500 (EST)
Date: Thu, 12 Jan 2012 12:16:54 +0100
From: Tyler Hicks <tyhicks@canonical.com>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
Message-ID: <20120112111654.GA4717@boyd>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com>
 <20120111141219.271d3a97.akpm@linux-foundation.org>
 <1326355594.1999.7.camel@lappy>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
In-Reply-To: <1326355594.1999.7.camel@lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lizf@cn.fujitsu.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dustin Kirkland <kirkland@canonical.com>, ecryptfs@vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2012-01-12 10:06:34, Sasha Levin wrote:
> On Wed, 2012-01-11 at 14:12 -0800, Andrew Morton wrote:
> > There's nothing particularly special about memdup_user(): there are
> > many ways in which userspace can trigger GFP_KERNEL allocations.
> >=20
> > The problem here (one which your patch carefully covers up) is that
> > ecryptfs_miscdev_write() is passing an unchecked userspace-provided
> > `count' direct into kmalloc().  This is a bit problematic for other
> > reasons: it gives userspace a way to trigger heavy reclaim activity and
> > perhaps even to trigger the oom-killer.
> >=20
> > A better fix here would be to validate the incoming arg before using
> > it.  Preferably by running ecryptfs_parse_packet_length() before taking
> > a copy of the data.  That would require adding a small copy_from_user()
> > to peek at the message header.=20
>=20
> Let's split it to two parts: the specific ecryptfs issue I've given as
> an example here, and a general view about memdup_user().
>=20
> I fully agree that in the case of ecryptfs there's a missing validity
> check, and just calling memdup_user() with whatever the user has passed
> to it is wrong and dangerous. This should be fixed in the ecryptfs code
> and I'll send a patch to do that.

I just wrote up a patch for the eCryptfs portion. I'll send it out a
little later after I get a chance to test it.

Tyler

>=20
> The other part, is memdup_user() itself. Kernel warnings are usually
> reserved (AFAIK) to cases where it would be difficult to notify the user
> since it happens in a flow which the user isn't directly responsible
> for.
>=20
> memdup_user() is always located in path which the user has triggered,
> and is usually almost the first thing we try doing in response to the
> trigger. In those code flows it doesn't make sense to print a kernel
> warnings and taint the kernel, instead we can simply notify the user
> about that error and let him deal with it any way he wants.
>=20
> There are more reasons kalloc() can show warnings besides just trying to
> allocate too much, and theres no reason to dump kernel warnings when
> it's easier to notify the user.
>=20
> --=20
>=20
> Sasha.
>=20

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCgAGBQJPDsEmAAoJENaSAD2qAscKhLMP/jO4a+QYsOv/C/GB6W0mEEmY
tcZIBm04+a8MiEXo9FPaF5/3j3Kgh+vVaQhWol1I4xnUf4Oi7mJbli4yhP9VzCMO
DKDluE/nkTWWxSif/w1KBfH28WHS/otkobEi6JA5YDgXAQTj6jrtwrt/tBd+CxHk
u/O8LsspMdl8VHF+k7K6whPzkG57idDrb6754qw1Ne1906Wo6kyjpYJL65XSzrQF
9JUIkmGPbWLjV+q3NEDjbpATmYOshQcXmA9HUoQLbKibUyKmOEnyRfGnH8jTpMw2
37gwwC3l6N6mPmHL04Eij9W6HvrD15sikENtQnIBr4HGZf1HkjHZU+siepW0JsO2
SylWXfCPdRkx6oYKuqeoojHAi80bAZrHAQsV/MtnKcZuZQPqcZRdKzsj+dYu9JF5
+GbTZNFdccejw1GARuaH0RYTSxGmG7FQcTKUoNl0gRUHChjeLqwz5ImSGjne0By7
U+a/2G9pGSdaXT3gcYFHFfoV3hDGCeYLGI7SxpLYP3nMRI5NLDMaXEueAq0Y4VA4
xSmWliP2QG3X0xknE7w7YhFfrdmkig7/OQ/dP1lxPxv+9pohh0MUJu+bupCKAlvn
nYCZcE/9hK95cyCSOOrQTnLEGCBHOA6OjGMF54JshHcl63jO4fQzNRBT4WDFEPTd
gIQYq/eREOJ7z7NiouD/
=l6Vk
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
