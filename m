Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id A061D6B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 05:37:52 -0400 (EDT)
Received: by qkdg63 with SMTP id g63so35117746qkd.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 02:37:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e78si16994556qka.16.2015.08.07.02.37.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 02:37:51 -0700 (PDT)
Message-ID: <55C47C63.6050406@redhat.com>
Date: Fri, 07 Aug 2015 11:37:39 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/4] enhance shmem process and swap accounting
References: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="npXRt4jMk2kVF812haRkpA6FK7vf77bND"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Minchan Kim <minchan@kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--npXRt4jMk2kVF812haRkpA6FK7vf77bND
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/05/2015 03:01 PM, Vlastimil Babka wrote:
> Reposting due to lack of feedback in May. I hope at least patches 1 and=
 2
> could be merged as they are IMHO bugfixes. 3 and 4 is optional but IMHO=
 useful.
>=20
> Changes since v2:
> o Rebase on next-20150805.
> o This means that /proc/pid/maps has the proportional swap share (SwapP=
ss:)
>   field as per https://lkml.org/lkml/2015/6/15/274
>   It's not clear what to do with shmem here so it's 0 for now.
>   - swapped out shmem doesn't have swap entries, so we would have to lo=
ok at who
>     else has the shmem object (partially) mapped
>   - to be more precise we should also check if his range actually inclu=
des=20
>     the offset in question, which could get rather involved
>   - or is there some easy way I don't see?

Hmm... This is much more difficult than I envision when commenting on
Minchan patch. One possibility could be to have the pte of paged out
shmem pages set in a similar way than regular swap entry are. But that
would need to use some very precious estate on the pte.
As it is, a zero value, while obviously wrong, has the advantage of not
being misleading like a bad approximation would be (like the kind which
doesn't properly accounts for partial mapping).

Jerome

> o Konstantin suggested for patch 3/4 that I drop the CONFIG_SHMEM #ifde=
fs
>   I didn't see the point in going against tinyfication when the work is=

>   already done, but I can do that if more people think it's better and =
it
>   would block the series.
>=20
> Changes since v1:
> o In Patch 2, rely on SHMEM_I(inode)->swapped if possible, and fallback=
 to
>   radix tree iterator on partially mapped shmem objects, i.e. decouple =
shmem
>   swap usage determination from the page walk, for performance reasons.=

>   Thanks to Jerome and Konstantin for the tips.
>   The downside is that mm/shmem.c had to be touched.
>=20
> This series is based on Jerome Marchand's [1] so let me quote the first=

> paragraph from there:
>=20
> There are several shortcomings with the accounting of shared memory
> (sysV shm, shared anonymous mapping, mapping to a tmpfs file). The
> values in /proc/<pid>/status and statm don't allow to distinguish
> between shmem memory and a shared mapping to a regular file, even
> though theirs implication on memory usage are quite different: at
> reclaim, file mapping can be dropped or write back on disk while shmem
> needs a place in swap. As for shmem pages that are swapped-out or in
> swap cache, they aren't accounted at all.
>=20
> The original motivation for myself is that a customer found (IMHO right=
fully)
> confusing that e.g. top output for process swap usage is unreliable wit=
h
> respect to swapped out shmem pages, which are not accounted for.
>=20
> The fundamental difference between private anonymous and shmem pages is=
 that
> the latter has PTE's converted to pte_none, and not swapents. As such, =
they are
> not accounted to the number of swapents visible e.g. in /proc/pid/statu=
s VmSwap
> row. It might be theoretically possible to use swapents when swapping o=
ut shmem
> (without extra cost, as one has to change all mappers anyway), and on s=
wap in
> only convert the swapent for the faulting process, leaving swapents in =
other
> processes until they also fault (so again no extra cost). But I don't k=
now how
> many assumptions this would break, and it would be too disruptive chang=
e for a
> relatively small benefit.
>=20
> Instead, my approach is to document the limitation of VmSwap, and provi=
de means
> to determine the swap usage for shmem areas for those who are intereste=
d and
> willing to pay the price, using /proc/pid/smaps. Because outside of ipc=
s, I
> don't think it's possible to currently to determine the usage at all.  =
The
> previous patchset [1] did introduce new shmem-specific fields into smap=
s
> output, and functions to determine the values. I take a simpler approac=
h,
> noting that smaps output already has a "Swap: X kB" line, where current=
ly X =3D=3D
> 0 always for shmem areas. I think we can just consider this a bug and p=
rovide
> the proper value by consulting the radix tree, as e.g. mincore_page() d=
oes. In the
> patch changelog I explain why this is also not perfect (and cannot be w=
ithout
> swapents), but still arguably much better than showing a 0.
>=20
> The last two patches are adapted from Jerome's patchset and provide a V=
mRSS
> breakdown to VmAnon, VmFile and VmShm in /proc/pid/status. Hugh noted t=
hat
> this is a welcome addition, and I agree that it might help e.g. debuggi=
ng
> process memory usage at albeit non-zero, but still rather low cost of e=
xtra
> per-mm counter and some page flag checks. I updated these patches to 4.=
0-rc1,
> made them respect !CONFIG_SHMEM so that tiny systems don't pay the cost=
, and
> optimized the page flag checking somewhat.
>=20
> [1] http://lwn.net/Articles/611966/
>=20
> Jerome Marchand (2):
>   mm, shmem: Add shmem resident memory accounting
>   mm, procfs: Display VmAnon, VmFile and VmShm in /proc/pid/status
>=20
> Vlastimil Babka (2):
>   mm, documentation: clarify /proc/pid/status VmSwap limitations
>   mm, proc: account for shmem swap in /proc/pid/smaps
>=20
>  Documentation/filesystems/proc.txt | 18 ++++++++++---
>  arch/s390/mm/pgtable.c             |  5 +---
>  fs/proc/task_mmu.c                 | 52 ++++++++++++++++++++++++++++++=
++++--
>  include/linux/mm.h                 | 28 ++++++++++++++++++++
>  include/linux/mm_types.h           |  9 ++++---
>  include/linux/shmem_fs.h           |  6 +++++
>  kernel/events/uprobes.c            |  2 +-
>  mm/memory.c                        | 30 +++++++--------------
>  mm/oom_kill.c                      |  5 ++--
>  mm/rmap.c                          | 15 +++--------
>  mm/shmem.c                         | 54 ++++++++++++++++++++++++++++++=
++++++++
>  11 files changed, 178 insertions(+), 46 deletions(-)
>=20



--npXRt4jMk2kVF812haRkpA6FK7vf77bND
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVxHxnAAoJEHTzHJCtsuoCDvIH/1Ji0r3+7bEvoTW7mn9QeSge
X/tzhiWZuFpzyZAvlxB0gP3OcnU+x4llbwIcaN1Z9GPY60bGcJcfNFDsFbuxxo2J
CCjXDjU/2DgYcHCTmi/PlUoaaJCa8SceUtzqsb30m5AjYCM4t+rxAIfp32CxZknZ
uH+rZ//SpWZHd2LGf5olNDepa2z34aBRzNa4wNk5CeuGvuZEL2tihHuxRXkrq7T/
Y5/3N5X75sZUskgM4fEfIOXnHZ79qwYq2Vuob5/8PdtYadGH2iOyHguurB/R28mv
JTsAq7PXAhvXwJYtbnFAs9MRoHs9mKvq+UJRpOL7ISFSdFA0pPxH4lYR7xKO0J4=
=o0La
-----END PGP SIGNATURE-----

--npXRt4jMk2kVF812haRkpA6FK7vf77bND--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
