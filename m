Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 006916B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 14:06:33 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so152198272pdb.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 11:06:32 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id vr2si18893359pab.15.2015.05.11.11.06.31
        for <linux-mm@kvack.org>;
        Mon, 11 May 2015 11:06:32 -0700 (PDT)
Date: Mon, 11 May 2015 14:06:31 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH 0/3] Allow user to request memory to be locked on page
 fault
Message-ID: <20150511180631.GA1227@akamai.com>
References: <1431113626-19153-1-git-send-email-emunson@akamai.com>
 <20150508124203.6679b1d35ad9555425003929@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
Content-Disposition: inline
In-Reply-To: <20150508124203.6679b1d35ad9555425003929@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 08 May 2015, Andrew Morton wrote:

> On Fri,  8 May 2015 15:33:43 -0400 Eric B Munson <emunson@akamai.com> wro=
te:
>=20
> > mlock() allows a user to control page out of program memory, but this
> > comes at the cost of faulting in the entire mapping when it is
> > allocated.  For large mappings where the entire area is not necessary
> > this is not ideal.
> >=20
> > This series introduces new flags for mmap() and mlockall() that allow a
> > user to specify that the covered are should not be paged out, but only
> > after the memory has been used the first time.
>=20
> Please tell us much much more about the value of these changes: the use
> cases, the behavioural improvements and performance results which the
> patchset brings to those use cases, etc.
>=20

To illustrate the proposed use case I wrote a quick program that mmaps
a 5GB file which is filled with random data and accesses 150,000 pages
=66rom that mapping.  Setup and processing were timed separately to
illustrate the differences between the three tested approaches.  the
setup portion is simply the call to mmap, the processing is the
accessing of the various locations in  that mapping.  The following
values are in milliseconds and are the averages of 20 runs each with a
call to echo 3 > /proc/sys/vm/drop_caches between each run.

The first mapping was made with MAP_PRIVATE | MAP_LOCKED as a baseline:
Startup average:    9476.506
Processing average: 3.573

The second mapping was simply MAP_PRIVATE but each page was passed to
mlock() before being read:
Startup average:    0.051
Processing average: 721.859

The final mapping was MAP_PRIVATE | MAP_LOCKONFAULT:
Startup average:    0.084
Processing average: 42.125



--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVUO+mAAoJELbVsDOpoOa9NTQP/2wouTuGwUNtVMFtzfwXaw9K
VqgrTohALyWDKXY4YiEVXyru5Mi7BJvzwBzjXo2eNFNBHj5DwILwKk/9ONw1l7kC
KCAMPqxGumpbM0dYJwaDYmYCsSmfTuFfv4G/Y/p7q43+mtfr6fCKAu+iIKvZpjve
T374ZgnngXdn43b4lC7Abk4SakIEz7bj2gzX7B6WTRJ5/WZUDe/WkA4k+9bO58yQ
M2GKbVNdCbFS2yL8awktB+NCUw5wmUreswog6c9E1h7HHTI0u0TzXa3E+NYZ4DGu
rmsFzaojbtuNHvvuDIDLeBw1Dc6BlwdWTk+OgAUnseXrbTB+L7KKZS4on56W+zIi
AIDTZ1oEvYsUZg06tPmKhLAgLA+FvpcsNYYjRwGlHEwjcwLL2LjF1gAMGZk1n8UP
uTuhOR/Q0WtRRQks706KG47OkVs0glntwFRwpZ0/a5iACKMhQhIL6LJjDmR5jSFI
cA70pVY49xmBKQ/vY2gMrKwGuHA00kvLaVVwUqga9AUgD0zisklvSPfzs3ihxkLL
b61PtZJJ4rggU6HgH/aNVaKIsGiy8SnGZPgnkinlB0QQFrbrfmgk7/imIHT09pDQ
K0o/U3KOitLxnvS1mSk6l4rCxYQ5037KrlGU15pqp5WIOuAiad6dpoUN4iLN/nuk
RMNxTjQZKYW0XS2oLyRI
=2v7D
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
