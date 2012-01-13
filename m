Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id D46B86B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 02:17:49 -0500 (EST)
Date: Fri, 13 Jan 2012 10:17:52 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
Message-ID: <20120113071752.GA3802@mwanda>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com>
 <20120111141219.271d3a97.akpm@linux-foundation.org>
 <1326355594.1999.7.camel@lappy>
 <CAOJsxLEYY=ZO8QrxiWL6qAxPzsPpZj3RsF9cXY0Q2L44+sn7JQ@mail.gmail.com>
 <alpine.DEB.2.00.1201121309340.17287@chino.kir.corp.google.com>
 <20120112135803.1fb98fd6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/9DWx/yDrRhgMJTb"
Content-Disposition: inline
In-Reply-To: <20120112135803.1fb98fd6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Sasha Levin <levinsasha928@gmail.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tyler Hicks <tyhicks@canonical.com>, Dustin Kirkland <kirkland@canonical.com>, ecryptfs@vger.kernel.org


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 12, 2012 at 01:58:03PM -0800, Andrew Morton wrote:
> On Thu, 12 Jan 2012 13:19:54 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
>=20
> > On Thu, 12 Jan 2012, Pekka Enberg wrote:
> >=20
> > > I think you missed Andrew's point. We absolutely want to issue a
> > > kernel warning here because ecryptfs is misusing the memdup_user()
> > > API. We must not let userspace processes allocate large amounts of
> > > memory arbitrarily.
> > >=20
> >=20
> > I think it's good to fix ecryptfs like Tyler is doing and, at the same=
=20
> > time, ensure that the len passed to memdup_user() makes sense prior to=
=20
> > kmallocing memory with GFP_KERNEL.  Perhaps something like
> >=20
> > 	if (WARN_ON(len > PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> > 		return ERR_PTR(-ENOMEM);
> >=20
> > in which case __GFP_NOWARN is irrelevant.
>=20
> If someone is passing huge size_t's into kmalloc() and getting failures
> then that's probably a bug.

It's pretty common to pass high values to kmalloc().  We've added
a bunch of integer overflow checks recently where we do:

	if (n > ULONG_MAX / size)
		return -EINVAL;

The problem is that we didn't set a maximum bound before and we
can't know which maximum will break compatibility.

Probably we shouldn't do that, I guess.

regards,
dan carpenter


--/9DWx/yDrRhgMJTb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPD9qgAAoJEOnZkXI/YHqRu78QAIuERPPRIKr4MrMLicVuU2N/
J480cGu4SnV+KYbndJpJsIwsgyZQyA+Kzwdb9PWlE+/C2dFkUcDnv+kqBrrat7I3
AKPQ2fx+ThCELGvlF3OZv5iC69zotV+AqRLNiA5PX3tiUFdSz125CeUKPAQYyHxm
FtZ3spPLmvw50H0epcXtCCjumUT3CoE+ICkK6wlXSrivBvn7vxDsmyKHHrlJDYGD
yO/0JJuWKVo74ozElQR/tN9hN1Q5AuH5pQq10h4EkFjpa9ealyknPrUGAbI9DiFT
NHNduYhbcWeNmSh9HJxUOa5qEdqiy1Ajhp4PwdTgTL+2BgnL44AHWSHbinvczkFP
j0hS4Yoz5oRX0igVOmPljBcRJkFvuYrQwnucbTNwmWtH4m+Hk0fldIS2VxA8mG87
DdJ48WhEcdaogPc0KxXOYn/bH54tPwVkCamxI9Kd0TR8XBKWIwLIvvqAkXzDpGqd
oRHpKFblVsI1qQXK7is8K0bLyg+OWxrauXSJMiUj7vOHUD8Pqfhg42Pw7Uh0BRWo
Vt+01mHpOlnkbuXgD9JxCgZcvUU/BG8qOio8Vj4wZ/dRnQ4phd+veqP8CNmwPFDb
JY0ImhBF44xCx3gZAczCux3p4aza98gqwF9XAjMVSsWnHIYl0yo0VNg1aNdSWWa0
PtJPIOXUvZiD+zL9Z2R3
=+rJw
-----END PGP SIGNATURE-----

--/9DWx/yDrRhgMJTb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
