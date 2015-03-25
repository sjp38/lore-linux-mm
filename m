Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id EB6F26B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 16:49:57 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so112839796igb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:49:57 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com. [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id q1si12263718iga.42.2015.03.25.13.49.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 13:49:57 -0700 (PDT)
Received: by iecvj10 with SMTP id vj10so32095730iec.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:49:57 -0700 (PDT)
Message-ID: <55131F70.7020503@gmail.com>
Date: Wed, 25 Mar 2015 16:49:52 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>	<550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com> <5512E0C0.6060406@suse.cz>
In-Reply-To: <5512E0C0.6060406@suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="AN3Fqv5MDNxSMdjq7DAHljhlVIXPfLCnV"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Aliaksey Kandratsenka <alkondratenko@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--AN3Fqv5MDNxSMdjq7DAHljhlVIXPfLCnV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 25/03/15 12:22 PM, Vlastimil Babka wrote:
>=20
> I'm not sure I get your description right. The problem I know about is
> where "purging" means madvise(MADV_DONTNEED) and khugepaged later
> collapses a new hugepage that will repopulate the purged parts,
> increasing the memory usage. One can limit this via
> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none . That
> setting doesn't affect the page fault THP allocations, which however
> happen only in newly accessed hugepage-sized areas and not partially
> purged ones, though.

Since jemalloc doesn't unmap memory but instead does recycling itself in
userspace, it ends up with large spans of free virtual memory and gets
*lots* of huge pages from the page fault heuristic. It keeps track of
active vs. dirty (not purged) vs. clean (purged / untouched) ranges
everywhere, and will purge dirty ranges as they build up.

The THP allocation on page faults mean it ends up with memory that's
supposed to be clean but is really not.

A worst case example with the (up until recently) default chunk size of
4M is allocating a bunch of 2.1M allocations. Chunks are naturally
aligned, so each one can be represented as 2 huge pages. It increases
memory usage by nearly *50%*. The allocator thinks the tail is clean
memory, but it's not. When the allocations are freed, it will purge the
2.1M at the head (once enough dirty memory builds up) but all of the
tail memory will be leaked until something else is allocated there and
then freed.

>> I think a THP implementation playing that played well with purging wou=
ld
>> need to drop the page fault heuristic and rely on a significantly bett=
er
>> khugepaged.
>=20
> See here http://lwn.net/Articles/636162/ (the "Compaction" part)
>=20
> The objection is that some short-lived workloads like gcc have to map
> hugepages immediately if they are to benefit from them. I still plan to=

> improve khugepaged and allow admins to say that they don't want THP pag=
e
> faults (and rely solely on khugepaged which has more information to
> judge additional memory usage), but I'm not sure if it would be an
> acceptable default behavior.
> One workaround in the current state for jemalloc and friends could be t=
o
> use madvise(MADV_NOHUGEPAGE) on hugepage-sized/aligned areas where it
> wants to purge parts of them via madvise(MADV_DONTNEED). It could mean
> overhead of another syscall and tracking of where this was applied and
> when it makes sense to undo this and allow THP to be collapsed again,
> though, and it would also split vma's.

Huge pages do significantly help performance though, and this would
pretty much mean no huge pages. The overhead of toggling it on and off
based on whether it's a < chunk size allocation or a >=3D chunk size one
is too high.

The page fault heuristic is just way too aggressive because there's no
indication of how much memory will be used. I don't think it makes sense
to do it without an explicit MADV_NOHUGEPAGE. Collapsing only dense
ranges doesn't have the same risk.

>> This would mean faulting in a span of memory would no longer
>> be faster. Having a flag to populate a range with madvise would help a=

>=20
> If it's a newly mapped memory, there's mmap(MAP_POPULATE). There is als=
o
> a madvise(MADV_WILLNEED), which sounds like what you want, but I don't
> know what the implementation does exactly - it was apparently added for=

> paging in ahead, and maybe it ignores unpopulated anonymous areas, but
> it would probably be well in spirit of the flag to make it prepopulate
> those.

It doesn't seem to do anything for anon mappings atm but I do see a
patch from 2008 for that. I guess it never landed.


--AN3Fqv5MDNxSMdjq7DAHljhlVIXPfLCnV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVEx9wAAoJEPnnEuWa9fIqw7kQAJPOyfLYeWlfMNDhF0zGfYUQ
cRYZbbjcJx3T8wdGAIqs+oVsFWOqzn9C3M93RuKrXOpkEV/hJtT5t0Xai/tfa5fX
6H/aNkSQqDKD4CsrPL3WE8PoZ95IsLFVv0pHpq5Dj6G1nNrCUJ9qMfs+1YHWcRUN
YGwHgnzyau/iNwfOE4kXOdhIeouI48j1WxbB1kaMtbHjnq+TEnpzZnU1o4frw6SD
Tcedr58AnZC+7vxFQOl+N9pMQqCKCxr/V7S6i7JcSVBIRa4PdrI/IAzR920ifujS
OSk2xFS/z0Xx1b2fCAvZtxB0FmLrCatjF0QThW8bVTj+ewVkNjB/TOFDtrAqe7BH
/zpTUim7kRuGabs8GjxkyW+e6JmURndEyR7th9bNtHXJPeR8IkdIda6vtRs09MAB
QWWOMPVUq25LLvNuKd8Jpgg2tc5Bvr46PmKHkuALpxzJfP36bBCgYmWl9VLJ4mfp
LxAsVbEM8eQ8NTanpd0vhG2QJ+GORtDhdhiYSNEgEqLemqOwlEzZEGYjRvEH5FuR
L+g/MJawoUglEDmdN0IsaUx2c746PYup1+x+3tvPqz3M9LTFsUzdCOfJk4eUqqtm
n7Dn3NbVecnFy1xiE7CqeL+wIfAxvvSOqR6Lpixt83I70z4jgYwU+1Z5atOOAyIF
3kbMdlUSNUzaGFh/AnUW
=uxm3
-----END PGP SIGNATURE-----

--AN3Fqv5MDNxSMdjq7DAHljhlVIXPfLCnV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
