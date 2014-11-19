Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 22EC06B0069
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 16:20:19 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so1052186pad.13
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 13:20:18 -0800 (PST)
Received: from ponies.io (mail.ponies.io. [173.255.217.209])
        by mx.google.com with ESMTP id bf9si440019pad.98.2014.11.19.13.20.16
        for <linux-mm@kvack.org>;
        Wed, 19 Nov 2014 13:20:17 -0800 (PST)
Received: from cucumber.localdomain (58-6-54-190.dyn.iinet.net.au [58.6.54.190])
	by ponies.io (Postfix) with ESMTPSA id 47D5B40001
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 21:20:16 +0000 (UTC)
Date: Thu, 20 Nov 2014 08:20:13 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141119212013.GA18318@cucumber.anchor.net.au>
References: <20141119012110.GA2608@cucumber.iinet.net.au>
 <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
In-Reply-To: <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 19, 2014 at 10:03:44PM +0400, Andrey Korolyov wrote:
> > We are using Mellanox ipoib drivers which do not do scatter-gather, so =
I'm
> > currently working on adding support for that (the hardware supports it)=
=2E Are
> > you also using ipoib or have something else doing high order allocation=
s? It's
> > a bit concerning for me if you don't as it would suggest that cutting d=
own on
> > those allocations won't help.
>=20
> So do I. On a test environment with regular tengig cards I was unable to
> reproduce the issue. Honestly, I thought that almost every contemporary
> driver for high-speed cards is working with scatter-gather, so I had not =
mlx
> in mind as a potential cause of this problem from very beginning.

Right, the drivers handle SG just fine, even in UD mode. It's just that as =
soon
as you go switch to CM they turn of hardware IP csums and SG support. The o=
nly
question I remain to answer before testing a patched driver is whether or n=
ot
the messages sent by Ceph are fragmented enough to save allocations. If not=
, we
could always patch Ceph as well but this is beginning to snowball.

Here is the untested WIP patch for SG support in ipoib CM mode, I'm current=
ly
talking to the original author of a larger patch to review and split that a=
nd
get them both upstream.:

https://gist.github.com/christian-marie/e8048b9c118bd3925957

> There are a couple of reports in ceph lists, complaining for OSD
> flapping/unresponsiveness without clear reason on certain (not always cle=
ar
> though) conditions which may have same root cause.

Possibly, though ipoib and Ceph seem to be a relatively rare combination.
Someone will likely find this thread if it is the same root cause.

> Wonder if numad-like mechanism will help there, but its usage is generall=
y an
> anti-performance pattern in my experience.

We've played with zone_reclaim_mode and numad to no avail. Only thing we ha=
ven't
tried is striping, which I don't want to do anyway.

If these large allocations are indeed a reasonable thing to ask of the
compaction/reclaim subsystem that seems like the best way forward. I have t=
wo
questions that follow from this conjecture:

Are compaction behaving badly or are we just asking for too many high order
allocations?

Is this fixed in a later kernel? I haven't tested yet.

--BOKacYhQ+x31HxR3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUbQmNAAoJEMHZnoZn5OShHawP/RC+Fc1mpAKdMeXDZe/H3/KN
kycw405SCxliKiyPIGsuUO5YLOBxBAQ3BNfywzCNKnVdxKx97UUO2ys3ySdrymof
Dt4E2LUw0aqFNrrbEcmFHH1i6Vmyqivomuk3rzDsOa5Km37WTemOfhJTQnwE4uzj
Zd2jE5Ib07F250EaFsbIC6Yw4Bk/xmuRiFGCZEXy26TaPuKwj4V0FdIfAcbsEvNS
XyJcQ0x5Tv0UQANS4tV02Tn1S1hoHLHcDBSzwQcPQ6Eo+5vQ2NRQInQnqiVHpShH
WfIhUaku6zoQ+3WcjtRmKYr2WojiJs4ZQfbOm+TEQfAXi88jjRwZbgljiBNYMcC8
nFt65DkLMlr1j1Y40tMTN7xFBrP3fjVSWc8xPlGhXEtRuA9QBjs9gd44zVGXNyts
KmtIgJG3xGIa7YOJnReh1wYd2VtH4DPU4ItsYa+IX2oABE+zbTukjYwVUn0xhMNs
tANSxTm2rLwnY/b0A8X+ga22FuDCuJErtKPsV9/SV1AMpSS3+67iWLJZvar3uQG0
RuhjtKNFvKmVaWzPhgMLmS4GZmY+nR3ubTIub/PmOWZsUIUN3/zCiTAi+ZlUfrzI
tcmKo3oLoSZLWACd84Hl5A0DZ2fk/HK9v2rSHwBZfZRKEJj61ZDxulK9SHh/YdP/
HdZfQcGBN062vHgLq6fJ
=Xu4D
-----END PGP SIGNATURE-----

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
