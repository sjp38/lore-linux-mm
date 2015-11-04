Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id BE76D82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:06:30 -0500 (EST)
Received: by qgbb65 with SMTP id b65so52247911qgb.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:06:30 -0800 (PST)
Received: from mail-qg0-x241.google.com (mail-qg0-x241.google.com. [2607:f8b0:400d:c04::241])
        by mx.google.com with ESMTPS id d109si2275504qgf.27.2015.11.04.14.06.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:06:30 -0800 (PST)
Received: by qgen11 with SMTP id n11so6178669qge.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:06:30 -0800 (PST)
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
 <56399CA5.8090101@gmail.com>
 <CALCETrU5P-mmjf+8QuS3-pm__R02j2nnRc5B1gQkeC013XWNvA@mail.gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <563A813B.9080903@gmail.com>
Date: Wed, 4 Nov 2015 17:05:47 -0500
MIME-Version: 1.0
In-Reply-To: <CALCETrU5P-mmjf+8QuS3-pm__R02j2nnRc5B1gQkeC013XWNvA@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="2IVeWpq2IbSSTeFp3TFicxabJLij5cBB9"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, Shaohua Li <shli@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin wang <yalin.wang2010@gmail.com>, Mel Gorman <mgorman@suse.de>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2IVeWpq2IbSSTeFp3TFicxabJLij5cBB9
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> With enough pages at once, though, munmap would be fine, too.

That implies lots of page faults and zeroing though. The zeroing alone
is a major performance issue.

There are separate issues with munmap since it ends up resulting in a
lot more virtual memory fragmentation. It would help if the kernel used
first-best-fit for mmap instead of the current naive algorithm (bonus:
O(log n) worst-case, not O(n)). Since allocators like jemalloc and
PartitionAlloc want 2M aligned spans, mixing them with other allocators
can also accelerate the VM fragmentation caused by the dumb mmap
algorithm (i.e. they make a 2M aligned mapping, some other mmap user
does 4k, now there's a nearly 2M gap when the next 2M region is made and
the kernel keeps going rather than reusing it). Anyway, that's a totally
separate issue from this. Just felt like complaining :).

> Maybe what's really needed is a MADV_FREE variant that takes an iovec.
> On an all-cores multithreaded mm, the TLB shootdown broadcast takes
> thousands of cycles on each core more or less regardless of how much
> of the TLB gets zapped.

That would work very well. The allocator ends up having a sequence of
dirty spans that it needs to purge in one go. As long as purging is
fairly spread out, the cost of a single TLB shootdown isn't that bad. It
is extremely bad if it needs to do it over and over to purge a bunch of
ranges, which can happen if the memory has ended up being very, very
fragmentated despite the efforts to compact it (depends on what the
application ends up doing).


--2IVeWpq2IbSSTeFp3TFicxabJLij5cBB9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOoE7AAoJEPnnEuWa9fIqY8cP/i3Vush0x4uyrzNPqvIVcxOf
Z+RF1KG7P7XeVO2g3M+h8Mx1klWsgnKJHjOw9v7UU4LEn9kmioiTXs4KgjBebVap
RJhhBDqlqoIm83ktfRAN2/hL/gfW3IUBmWZUv64YR7JD9w3O4RcbEv85HcXplQlC
0/kb5PasDsuXu0lWmAhEQO1ebKssnX3OryUxO6MNKGPlL73kXd1K2WOu9b4xtlWp
3M0iWJ7An4ItkV1vFh94WB22Ix2uwhqnC+I4p1SbZiivhGDd8lHDP1CIW/mAbYpS
wIV0srQSYIwF66fnaExtRBdxVPzxyYsyMXf8TBO/XoPrm6Nh8Q5k438AbSsslzAb
6fqDoKVgz6ZEBsqJKSbrbGw6rSHtMLQLGTUDlBj5Z9jJU4IPNVf0Y1lyO8xNNN40
rJLBzcpCu0LiGzBJMIwUxSQb2Cze8QUmGd/+k17BbE26/9MjaZWrD4S7XANFbhL2
NYSBnemJsjFrz9waiI/pE4Q/qpramCDpdWwN7l3uO8auzVwn1NVmdo6pCLV5nSrZ
MaRYavbmf+fFZmZ0/ptqVQG7HAN0dyjHuLVtSjGerj/o2cQ6MB0ibabqOEs9FB54
7xL3i2JycJn5Pk9TsSZHh1fxI2QNM70ltADzH8fG/Qprne3dzU0TqBskXpmy0et+
vNEz9RtJG8JKLuHkv26d
=X3NF
-----END PGP SIGNATURE-----

--2IVeWpq2IbSSTeFp3TFicxabJLij5cBB9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
