Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9198B6B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 20:21:15 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so6821710pab.40
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 17:21:15 -0800 (PST)
Received: from ponies.io (ponies.io. [2600:3c01::f03c:91ff:fe6e:5e45])
        by mx.google.com with ESMTP id ez7si34970812pdb.228.2014.11.18.17.21.13
        for <linux-mm@kvack.org>;
        Tue, 18 Nov 2014 17:21:14 -0800 (PST)
Received: from cucumber.localdomain (203-206-0-73.dyn.iinet.net.au [203.206.0.73])
	by ponies.io (Postfix) with ESMTPSA id 5D72EA0B7
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 01:21:12 +0000 (UTC)
Date: Wed, 19 Nov 2014 12:21:10 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141119012110.GA2608@cucumber.iinet.net.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
In-Reply-To: <CABYiri-do2YdfBx=r+u1kwXkEwN4v+yeRSHB-ODXo4gMFgW-Fg.mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> Hello,
>=20
> I had found recently that the OSD daemons under certain conditions
> (moderate vm pressure, moderate I/O, slightly altered vm settings) can
> go into loop involving isolate_freepages and effectively hit Ceph
> cluster performance.

Hi! I'm the creator of the server fault issue you reference:

http://serverfault.com/questions/642883/cause-of-page-fragmentation-on-larg=
e-server-with-xfs-20-disks-and-ceph

I'd like to get to the bottom of this very much, I'm seeing a very similar
pattern on 3.10.0-123.9.3.el7.x86_64, if this is fixed in later versions
perhaps we could backport something.

Here is some perf output:

http://ponies.io/raw/compaction.png

Looks pretty similar. I also have hundreds of MB logs and traces should we =
need
some specific question answered.

I've managed to reproduce many failed compactions with this:

https://gist.github.com/christian-marie/cde7e80c5edb889da541

I took some compaction stress test code and bolted on a little loop to mmap=
 a
large sparse file and read every PAGE_SIZEth byte.

Run it once, compactions seem to do okay, run it again and they're really s=
low.
This seems to be because my little trick to fill up cache memory only seems=
 to
work exactly half the time. Note that transhuge pages are only used to
introduce fragmentation/pressure here, turning transparent huge pages off
doesn't seem to make the slightest difference to the spinning-in-reclaim is=
sue.

We are using Mellanox ipoib drivers which do not do scatter-gather, so I'm
currently working on adding support for that (the hardware supports it). Are
you also using ipoib or have something else doing high order allocations? I=
t's
a bit concerning for me if you don't as it would suggest that cutting down =
on
those allocations won't help.

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUa/CGAAoJEMHZnoZn5OSh0wcQAL5R2Ip711Bso9jf1bxVDTgx
PJMM+6OnwmUbNOmVC/p91V9ZipTNwrJzHC0gHgJzk8M7766R/N5212bC9iC5d5Ue
vTxE8Y7OKxFMr56A8vzt+8erKhCuGIP9edSPK9PCSHCcmzmyDIHqWIEpqbmodHLe
VwsuH0dWH31zrJmydah9+DVkC5SYLlQhKUyT0ynX7U4F1EmwHn+Aq29Kf2BOXsEU
32Ua2xsxDERVWlco+i2Md4W4n+rLTR7d99/HEzDb2B2oO3faEjhZgkd0CgtAO5Ik
+Jr3g74UltsTNS+J3C7uGPxu5p16XxFpoI+N/zUyk7wd7oUwwvtFYyPhQdVUuEHd
XjjRsS5mPmmc9QcsVMdaVrPlY5oZS+j+oferdzvX0kB2OqUB6C8JQ8rV1xzKJhAp
5XxcY5UAz3cV/2gTvX2hRnKE0J+UdyFbiBsMjfGbh+6DyS4c1j+LRmB7DtgW2tL2
L6eVX3gvQcNgwxyD90GNM/DWYxIfQTiFwcH1ObNsag1nrLE/rEPjMyTMVBHE+iMf
3+kHnqzpSyzTjHJpqJDMPP0nK3vd0SXZak2pxUm5VUk6AxFi2WP0s32NPC/z2q2j
+iLULXWeYKMd+G7aHBk7Zct/a/yJZCBAU8ucJ/Fas5TKfW2eVLD7iodFpf2G/HSq
ZI+4mi6fv6jHV2VMKQ4O
=jHrY
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
