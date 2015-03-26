Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3F86B006E
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 21:21:21 -0400 (EDT)
Received: by igcau2 with SMTP id au2so4879234igc.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:21:20 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id ww20si3702603icb.51.2015.03.25.18.21.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 18:21:20 -0700 (PDT)
Received: by iecvj10 with SMTP id vj10so36082257iec.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:21:20 -0700 (PDT)
Message-ID: <55135F06.4000906@gmail.com>
Date: Wed, 25 Mar 2015 21:21:10 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com> <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org> <550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <20150323051731.GA2616341@devbig257.prn2.facebook.com> <CADpJO7zk8J3q7Bw9NibV9CzLarO+YkfeshyFTTq=XeS5qziBiA@mail.gmail.com> <55117724.6030102@gmail.com> <20150326005009.GA7658@blaptop>
In-Reply-To: <20150326005009.GA7658@blaptop>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="gWdQ5wWODA4o1bSuSbrBd7JDhcQbGfSI0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Aliaksey Kandratsenka <alkondratenko@gmail.com>, Shaohua Li <shli@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gWdQ5wWODA4o1bSuSbrBd7JDhcQbGfSI0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

> I didn't follow this thread. However, as you mentioned MADV_FREE will
> make many page fault, I jump into here.
> One of the benefit with MADV_FREE in current implementation is to
> avoid page fault as well as no zeroing.
> Why did you see many page fault?

I think I just misunderstood why it was still so much slower than not
using purging at all.

>> I get ~20k requests/s with jemalloc on the ebizzy benchmark with this
>> dual core ivy bridge laptop. It jumps to ~60k requests/s with MADV_FRE=
E
>> IIRC, but disabling purging via MALLOC_CONF=3Dlg_dirty_mult:-1 leads t=
o
>> 3.5 *million* requests/s. It has a similar impact with TCMalloc.
>=20
> When I tested MADV_FREE with ebizzy, I saw similar result two or three
> times fater than MADV_DONTNEED. But It's no free cost. It incurs MADV_F=
REE
> cost itself*(ie, enumerating all of page table in the range and clear
> dirty bit and tlb flush). Of course, it has mmap_sem with read-side loc=
k.
> If you see great improve when you disable purging, I guess mainly it's
> caused by no lock of mmap_sem so some threads can allocate while other
> threads can do page fault. The reason I think so is I saw similar resul=
t
> when I implemented vrange syscall which hold mmap_sem read-side lock
> during very short time(ie, marking the volatile into vma, ie O(1) while=

> MADV_FREE holds a lock during enumerating all of pages in the range, ie=
 O(N))

It stops doing mmap after getting warmed up since it never unmaps so I
don't think mmap_sem is a contention issue. It could just be caused by
the cost of the system call itself and TLB flush. I found perf to be
fairly useless in identifying where the time was being spent.

It might be much more important to purge very large ranges in one go
with MADV_FREE. It's a different direction than the current compromises
forced by MADV_DONTNEED.


--gWdQ5wWODA4o1bSuSbrBd7JDhcQbGfSI0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVE18GAAoJEPnnEuWa9fIqC68QAJEVXESm4ZtUrtyXhW+NTxy/
L49+LLO03Eg6epvhCd85NJ60PJtUxDu6bLOnCctF8Jm/0xq0DN04GcNkKh/hMT4w
nzZDmD/fz6BgWCS29dCA07QBMs8VuuC6BiW3JakS5xuP9yt6lezFk1IEbByB01PR
jiGBjqM0S7dnJJDpeVvuha9kS7YBorWM6xc1iyo11pdK71GgCCEcqRXm+rggcuBx
2DGqQItYx4uO4LKysLIumMwJ/Gqwsg1GVuL3Ufg8chFBw7E8xPtGEA8c/wcQTbwG
0jzKCdz0OU2VTb31NIaJl9d4OQBbUjjStYCA1qktjobmaf6KYJ6dNEA1QevmVX7p
2wZ5duZNI9MZt9ZrDoLtAlxdzFFoweXsQIFMHXOzNXcTuPj3UQYK6M35AT1kppYA
RPdWl/OFYzcJiioJEs9wVteKYuOsVFxRtRDqUD9a9H3X6opJ7kQhQyuyw8/af7v/
uf9S6WlDXxZCqsefHCpbvjnExKBHL7NMh7PeQnduPIdsJyJXhzofu1HzxQCrhdmw
aJZL6jVXZIuIUEsdk3QixdSFNwtQ+TDeIBplZR5ep+S3UxOqR8vka8CiFmeKEonX
G5Bi0LQVBZ5BQaI722yOpywR/aXqmeZUbcULqi7HEr1i2ZNPWDjHk+dwuiBGQQbR
j6ySNFdhv2QS0C5sDME6
=7xwN
-----END PGP SIGNATURE-----

--gWdQ5wWODA4o1bSuSbrBd7JDhcQbGfSI0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
