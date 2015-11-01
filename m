Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4FEC482F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 01:30:22 -0500 (EST)
Received: by iofz202 with SMTP id z202so116482391iof.2
        for <linux-mm@kvack.org>; Sat, 31 Oct 2015 23:30:22 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id 17si13280249ioz.121.2015.10.31.23.30.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 Oct 2015 23:30:21 -0700 (PDT)
Received: by igbhv6 with SMTP id hv6so35896299igb.0
        for <linux-mm@kvack.org>; Sat, 31 Oct 2015 23:30:21 -0700 (PDT)
Subject: Re: [PATCH 0/8] MADV_FREE support
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <alpine.DEB.2.10.1510312142560.10406@chino.kir.corp.google.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <5635B159.8030307@gmail.com>
Date: Sun, 1 Nov 2015 01:29:45 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1510312142560.10406@chino.kir.corp.google.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="EuRHwMLBw5CVJE0huIu9LbpjktbvTsiIP"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EuRHwMLBw5CVJE0huIu9LbpjktbvTsiIP
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 01/11/15 12:51 AM, David Rientjes wrote:
> On Fri, 30 Oct 2015, Minchan Kim wrote:
>=20
>> MADV_FREE is on linux-next so long time. The reason was two, I think.
>>
>> 1. MADV_FREE code on reclaim path was really mess.
>>
>> 2. Andrew really want to see voice of userland people who want to use
>>    the syscall.
>>
>> A few month ago, Daniel Micay(jemalloc active contributor) requested m=
e
>> to make progress upstreaming but I was busy at that time so it took
>> so long time for me to revist the code and finally, I clean it up the
>> mess recently so it solves the #2 issue.
>>
>> As well, Daniel and Jason(jemalloc maintainer) requested it to Andrew
>> again recently and they said it would be great to have even though
>> it has swap dependency now so Andrew decided he will do that for v4.4.=

>>
>=20
> First, thanks very much for refreshing the patchset and reposting after=
 a=20
> series of changes have been periodically added to -mm, it makes it much=
=20
> easier.
>=20
> For tcmalloc, we can do some things in the allocator itself to increase=
=20
> the amount of memory backed by thp.  Specifically, we can prefer to=20
> release Spans to pageblocks that are already not backed by thp so there=
 is=20
> no additional split on each scavenge.  This is somewhat easy if all mem=
ory=20
> is organized into hugepage-aligned pageblocks in the allocator itself. =
=20
> Second, we can prefer to release Spans of longer length on each scaveng=
e=20
> so we can delay scavenging for as long as possible in a hope we can fin=
d=20
> more pages to coalesce.  Third, we can discount refaulted released memo=
ry=20
> from the scavenging period.
>=20
> That significantly improves the amount of memory backed by thp for=20
> tcmalloc.  The problem, however, is that tcmalloc uses MADV_DONTNEED to=
=20
> release memory to the system and MADV_FREE wouldn't help at all in a=20
> swapless environment.
>=20
> To combat that, I've proposed a new MADV bit that simply caches the=20
> ranges freed by the allocator per vma and places them on both a per-vma=
=20
> and per-memcg list.  During reclaim, this list is iterated and ptes are=
=20
> freed after thp split period to the normal directed reclaim.  Without=20
> memory pressure, this backs 100% of the heap with thp with a relatively=
=20
> lightweight kernel change (the majority is vma manipulation on split) a=
nd=20
> a couple line change to tcmalloc.  When pulling memory from the returne=
d=20
> freelists, the memory that we have MADV_DONTNEED'd, we need to use anot=
her=20
> MADV bit to remove it from this cache, so there is a second madvise(2) =

> syscall involved but the freeing call is much less expensive since ther=
e=20
> is no pagetable walk without memory pressure or synchronous thp split.
>=20
> I've been looking at MADV_FREE to see if there is common ground that co=
uld=20
> be shared, but perhaps it's just easier to ask what your proposed strat=
egy=20
> is so that tcmalloc users, especially those in swapless environments,=20
> would benefit from any of your work?

The current implementation requires swap because the kernel already has
robust infrastructure for swapping out anonymous memory when there's
memory pressure. The MADV_FREE implementation just has to hook in there
and cause pages to be dropped instead of swapped out. There's no reason
it couldn't be extended to work in swapless environments, but it will
take additional design and implementation work. As a stop-gap, I think
zram and friends will work fine as a form of swap for this.

It can definitely be improved to cooperate well with THP too. I've been
following the progress, and most of the problems seem to have been with
the THP and that's a very active area of development. Seems best to deal
with that after a simple, working implementation lands.

The best aspect of MADV_FREE is that it completely avoids page faults
when there's no memory pressure. Making use of the freed memory only
triggers page faults if the pages had to be dropped because the system
ran out of memory. It also avoids needing to zero the pages. The memory
can also still be freed at any time if there's memory pressure again
even if it's handed out as an allocation until it's actually touched.

The call to madvise still has significant overhead, but it's much
cheaper than MADV_DONTNEED. Allocators will be able to lean on the
kernel to make good decisions rather than implementing lazy freeing
entirely on their own. It should improve performance *and* behavior
under memory pressure since allocators can be more aggressive with it
than MADV_DONTNEED.

A nice future improvement would be landing MADV_FREE_UNDO feature to
allow an attempt to pin the pages in memory again. It would make this
work very well for implementing caches that are dropped under memory
pressure. Windows has this via MEM_RESET (essentially MADV_FREE) and
MEM_RESET_UNDO. Android has it for ashmem too (pinning/unpinning). I
think browser vendors would be very interested in it.


--EuRHwMLBw5CVJE0huIu9LbpjktbvTsiIP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWNbFdAAoJEPnnEuWa9fIqHEEP/0bBbBm8k0VQdktVYKeRRPZD
iZzk92/p0lvhPbaN9tpXQK4TBeZGYIhxblsm3qqoiwaWdtzzePbujouyea9x5gar
PGf0wB55zio3lfYgwjNLf/SRgMOsDmJEOhXDoB5a0f0EvpvZdXSbvI9r03z6HaSP
Z2YRbybhHl1Xda6xb5CJUqzpG4E9k5oxMvRBoBxFT8+YUujf5weK8Ats8JFLO239
GTU6jAySYpkGfG5kTyG7QRag2/zfOLvwb+3mToFsdlKDHl1tAiqix7PW2fMHq6Ua
FVLg3Efl7uzAqdQnsc8XMG5Jax56KOj1dqfdb0FfJyPbwKMDX6uF6DaLl/QJtsag
wLvn7uQMgtWc/GCVPi/ZdwwjpHga/1NB+xaZqLEkFi6KOqYoXNvhh4QiPidaAnZ4
InnUiUC/Fz8cvxaHlB1Gz8aTK1IIGfYEdPx+LeOBkeXZVWWx7CQ3FAowTBpM+kIq
EzeTLesaig60WV7AjtxsQ/NmTnY4v8Y9lIbQY2COD1p+25XhZckZ+Y9XdQaTEq8/
CRcEc3uiyz64cwL8OhUfLCnHlFEg53uOjypt2BBTsT+UwbRBGeISPnni9Ltt5Zuq
ZJSmzeFIEsej6Hy4JkB24bLzvEPdIFxYCn+xGYF0nL5AUPqGuBkMd+8IpuHInn1v
PNtOKzoIvZaJ4CODt8oE
=0//q
-----END PGP SIGNATURE-----

--EuRHwMLBw5CVJE0huIu9LbpjktbvTsiIP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
