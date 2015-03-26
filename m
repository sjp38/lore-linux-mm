Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1986A6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 23:25:02 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so42089806ied.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:25:01 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id cu15si3899167icb.46.2015.03.25.20.25.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 20:25:01 -0700 (PDT)
Received: by igbqf9 with SMTP id qf9so43122504igb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:25:01 -0700 (PDT)
Message-ID: <55137C06.9020608@gmail.com>
Date: Wed, 25 Mar 2015 23:24:54 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com> <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org> <550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com> <5512E0C0.6060406@suse.cz> <55131F70.7020503@gmail.com> <alpine.DEB.2.10.1503251710400.31453@chino.kir.corp.google.com> <551351CA.3090803@gmail.com> <alpine.DEB.2.10.1503251914260.16714@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503251914260.16714@chino.kir.corp.google.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="oR20fIOVQhEga68KfGXn2R1PPE7wOXKqr"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aliaksey Kandratsenka <alkondratenko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--oR20fIOVQhEga68KfGXn2R1PPE7wOXKqr
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

It's all well and good to say that you shouldn't do that, but it's the
basis of the design in jemalloc and other zone-based arena allocators.

There's a chosen chunk size and chunks are naturally aligned. An
allocation is either a span of chunks (chunk-aligned) or has metadata
stored in the chunk header. This also means chunks can be assigned to
arenas for a high level of concurrency. Thread caching is then only
necessary for batching operations to amortize the cost of locking rather
than to reduce contention. Per-CPU arenas can be implemented quite well
by using sched_getcpu() to move threads around whenever it detects that
another thread allocated from the arena.

With >=3D 2M chunks, madvise purging works very well at the chunk level
but there's also fine-grained purging within chunks and it completely
breaks down from THP page faults.

The allocator packs memory towards low addresses (address-ordered
best-fit and first-fit can both be done in O(log n) time) so swings in
memory usage will tend to clear large spans of memory which will then
fault in huge pages no matter how it was mapped. Once MADV_FREE can be
used rather than MADV_DONTNEED, this would only happen after memory
pressure... but that's not very comforting.

I don't find it acceptable that programs can have huge (up to ~30% in
real programs) amounts of memory leaked over time due to THP page
faults. This is a very real problem impacting projects like Redis,
MariaDB and Firefox because they all use jemalloc.

https://shk.io/2015/03/22/transparent-huge-pages/
https://www.percona.com/blog/2014/07/23/why-tokudb-hates-transparent-huge=
pages/
http://dev.nuodb.com/techblog/linux-transparent-huge-pages-jemalloc-and-n=
uodb
https://bugzilla.mozilla.org/show_bug.cgi?id=3D770612

Bionic (Android's libc) switched over to jemalloc too.

The only reason you don't hear about this with glibc is because it
doesn't have aggressive, fine-grained purging and a low fragmentation
design in the first place.


--oR20fIOVQhEga68KfGXn2R1PPE7wOXKqr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVE3wGAAoJEPnnEuWa9fIqSV8P/29XSFavaqyeKaD+HjVzjgY4
WP97K4PpxvxcYQif3FNlpS4N8j7L4dutdJoyhkjkD6R+1TVulVibbwOvQ9QNxq7E
rJL+qIcC8Y01SQEaEFQzjgxugJjq+N4t7NL+etkytsLtirSN7cJkJ70CAM6baCq8
7zHziRo5ti3tUhw12PSJeQ4gTIG+RkZmvUaIwD7WdE1J2l5XCXAQIwor2OaCuAkk
DuRUH3JBN/DzAcIB6/xnm3AIsZZ1I0T/rcqYUF8WsP9aaYpH3F58Uk9GdZ5nFUer
x3tsWsjvuSySQsCR3oMFCVRGoY/dsk4fEmwH6AgxQRuT6mNCqwUiSLkw22xgOx0W
z/DTJXTyAV8SDAAYDHnUJvt/bcp/ES5ani15v+kjT0q64eT0B3CADeqXy/hih+Qg
gJ40c22lRUo/jFKN7hanmV5nMofc88qnKepUmRPGucSG/ALQ9go/NB7vpeVqowB0
J7fqMS1Ss7M1uDE/pbu3AikNN3Xh4wJaAVv2QJqDpM8QJg46OGdJKWsUAmLUvbrX
6k3EOhAav3GM1l3fCk6/dvZvyTbLpFBvW5Fs9WC2nnBvceiqE4Og+yFdJfJv4ZMg
VNgbYlll0QfM8Ht2N+KKJynxD/YRZDWxEAStXpAG5s7wjygS0NFJx/0FL2o+3zb7
pOEW5E7IIl9fBBUdtEFn
=AX0U
-----END PGP SIGNATURE-----

--oR20fIOVQhEga68KfGXn2R1PPE7wOXKqr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
