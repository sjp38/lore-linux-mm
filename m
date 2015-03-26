Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC0B6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:24:48 -0400 (EDT)
Received: by igcau2 with SMTP id au2so4283543igc.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:24:48 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id j3si3613943igx.23.2015.03.25.17.24.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 17:24:48 -0700 (PDT)
Received: by igcxg11 with SMTP id xg11so40833046igc.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 17:24:47 -0700 (PDT)
Message-ID: <551351CA.3090803@gmail.com>
Date: Wed, 25 Mar 2015 20:24:42 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com> <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org> <550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com> <5512E0C0.6060406@suse.cz> <55131F70.7020503@gmail.com> <alpine.DEB.2.10.1503251710400.31453@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503251710400.31453@chino.kir.corp.google.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="5ODsrXukED74CtPen0os9PtrDQXc4cIli"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aliaksey Kandratsenka <alkondratenko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--5ODsrXukED74CtPen0os9PtrDQXc4cIli
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 25/03/15 08:19 PM, David Rientjes wrote:
> On Wed, 25 Mar 2015, Daniel Micay wrote:
>=20
>>> I'm not sure I get your description right. The problem I know about i=
s
>>> where "purging" means madvise(MADV_DONTNEED) and khugepaged later
>>> collapses a new hugepage that will repopulate the purged parts,
>>> increasing the memory usage. One can limit this via
>>> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none . That
>>> setting doesn't affect the page fault THP allocations, which however
>>> happen only in newly accessed hugepage-sized areas and not partially
>>> purged ones, though.
>>
>> Since jemalloc doesn't unmap memory but instead does recycling itself =
in
>> userspace, it ends up with large spans of free virtual memory and gets=

>> *lots* of huge pages from the page fault heuristic. It keeps track of
>> active vs. dirty (not purged) vs. clean (purged / untouched) ranges
>> everywhere, and will purge dirty ranges as they build up.
>>
>> The THP allocation on page faults mean it ends up with memory that's
>> supposed to be clean but is really not.
>>
>> A worst case example with the (up until recently) default chunk size o=
f
>> 4M is allocating a bunch of 2.1M allocations. Chunks are naturally
>> aligned, so each one can be represented as 2 huge pages. It increases
>> memory usage by nearly *50%*. The allocator thinks the tail is clean
>> memory, but it's not. When the allocations are freed, it will purge th=
e
>> 2.1M at the head (once enough dirty memory builds up) but all of the
>> tail memory will be leaked until something else is allocated there and=

>> then freed.
>>
>=20
> With tcmalloc, it's simple to always expand the heap by mmaping 2MB ran=
ges=20
> for size classes <=3D 2MB, allocate its own metadata from an arena that=
 is=20
> also expanded in 2MB range, and always do madvise(MADV_DONTNEED) for th=
e=20
> longest span on the freelist when it does periodic memory freeing back =
to=20
> the kernel, and even better if the freed memory splits at most one=20
> hugepage.  When memory is pulled from the freelist of memory that has=20
> already been returned to the kernel, you can return a span that will ma=
ke=20
> it eligible to be collapsed into a hugepage based on your setting of=20
> max_ptes_none, trying to consolidate the memory as much as possible.  I=
f=20
> your malloc is implemented in a way to understand the benefit of=20
> hugepages, and how much memory you're willing to sacrifice (max_ptes_no=
ne)=20
> for it, then you should _never_ be increasing memory usage by 50%.

If khugepaged was the only source of huge pages, sure. The primary
source of huge pages is the heuristic handing out an entire 2M page on
the first page fault in a 2M range.


--5ODsrXukED74CtPen0os9PtrDQXc4cIli
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVE1HKAAoJEPnnEuWa9fIq81gP/ihneKZkcRMMF9GR77Ji4vCn
NgjcItz9yk1IKwRixjCxGtv4O0FWW16y2pgeqgNitjw9hzAyutJS29Z1IC0Um0vF
Zyh1cFBlCvyjLfjlQ4ZkjIEkXlQHbwFAvLBOL/wVK7cqV22vwoLDXy9t0X0Tj+DS
GvWIVlqmDcrWdwt5BfSDufHPkI7LB5y5Hhkr6WjvvoxVy6r21JvaukT9vNq3vAsZ
HGzgMBR9skE3jGeC5Xn4AwcWmiWRuscyq3UiNSAnU8R4gnLhnyW6KAvOwbDyFQwo
EnhhNhopRg+zeb6W3OQeVwP5t9oscUdugDmsxuqQWkeCaVBos02PjEwYEJlXb6zl
v6pfAboWmo/MR5s1tqx+orEm71362cewHfWKH+a/6kZBTIwsr5ql3TAkELV4PmJ4
Wxxb2Y9JCMVFvuCXxZaKhuLQsPpVbAA6PjJj8I00aVm0c8v924A30ef8SEonUnr0
wqxd75e+AAlU5Mfhvj5xmE5BBcdPFJA9Wu2icDwADTCChIg49irLKYu/RUPyS0BG
EvYAj8lz6WYdfMyDjLMQhiKDNz/+YP79U1bVtVtMoH1iGI8aDGz9NlwO1u+Naw94
KZ5AWPCggLp7ccvVZ79yn/eQ7otOfSZ/L+hqVrolhFSuPDM+f6A1A92/hRhw6xci
yx7o71J3zqgpqgGuExhb
=l9L7
-----END PGP SIGNATURE-----

--5ODsrXukED74CtPen0os9PtrDQXc4cIli--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
