Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1221E82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 16:16:42 -0500 (EST)
Received: by igbhv6 with SMTP id hv6so45291458igb.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 13:16:41 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id o85si3774726ioi.173.2015.11.04.13.16.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 13:16:41 -0800 (PST)
Received: by igbdj2 with SMTP id dj2so44944438igb.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 13:16:41 -0800 (PST)
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <20151104200006.GA46783@kernel.org>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <563A7591.7080607@gmail.com>
Date: Wed, 4 Nov 2015 16:16:01 -0500
MIME-Version: 1.0
In-Reply-To: <20151104200006.GA46783@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="CuneNnFdlk8k24ClMQJxchbWeXnOJPeC3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, bmaurer@fb.com

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CuneNnFdlk8k24ClMQJxchbWeXnOJPeC3
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

> Compared to MADV_DONTNEED, MADV_FREE's lazy memory free is a huge win t=
o reduce
> page fault. But there is one issue remaining, the TLB flush. Both MADV_=
DONTNEED
> and MADV_FREE do TLB flush. TLB flush overhead is quite big in contempo=
rary
> multi-thread applications. In our production workload, we observed 80% =
CPU
> spending on TLB flush triggered by jemalloc madvise(MADV_DONTNEED) some=
times.
> We haven't tested MADV_FREE yet, but the result should be similar. It's=
 hard to
> avoid the TLB flush issue with MADV_FREE, because it helps avoid data
> corruption.
>=20
> The new proposal tries to fix the TLB issue. We introduce two madvise v=
erbs:
>=20
> MARK_FREE. Userspace notifies kernel the memory range can be discarded.=
 Kernel
> just records the range in current stage. Should memory pressure happen,=
 page
> reclaim can free the memory directly regardless the pte state.
>=20
> MARK_NOFREE. Userspace notifies kernel the memory range will be reused =
soon.
> Kernel deletes the record and prevents page reclaim discards the memory=
=2E If the
> memory isn't reclaimed, userspace will access the old memory, otherwise=
 do
> normal page fault handling.
>=20
> The point is to let userspace notify kernel if memory can be discarded,=
 instead
> of depending on pte dirty bit used by MADV_FREE. With these, no TLB flu=
sh is
> required till page reclaim actually frees the memory (page reclaim need=
 do the
> TLB flush for MADV_FREE too). It still preserves the lazy memory free m=
erit of
> MADV_FREE.
>=20
> Compared to MADV_FREE, reusing memory with the new proposal isn't trans=
parent,
> eg must call MARK_NOFREE. But it's easy to utilize the new API in jemal=
loc.
>=20
> We don't have code to backup this yet, sorry. We'd like to discuss it i=
f it
> makes sense.

That's comparable to Android's pinning / unpinning API for ashmem and I
think it makes sense if it's faster. It's different than the MADV_FREE
API though, because the new allocations that are handed out won't have
the usual lazy commit which MADV_FREE provides. Pages in an allocation
that's handed out can still be dropped until they are actually written
to. It's considered active by jemalloc either way, but only a subset of
the active pages are actually committed. There's probably a use case for
both of these systems.


--CuneNnFdlk8k24ClMQJxchbWeXnOJPeC3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOnWRAAoJEPnnEuWa9fIqdeEP/iVWpgU10VwM9SIZZenn5154
aolJpC1qXALGsnrIcMkJXpmlq1Fky4Ew/lhua+Ca1NidemR76TnEZEfZuAghQ3hf
37p7aQDhm9j7WmAcMfxm0iJCcCepKMtp504eRAgUSBoXXdK3Y5VgbPVMZSzNsNBI
Ct9/2RjevChz8ILIz5JFw3C9a4WKOxOBDQELCdU+/ObZ7Ll/xocbBkUEaLu4NlGX
7dAe3EigCMzx2rqoAXuKgbBpVEu4PmBoUu2ORvfQKUZRmsHZ1i9t/Mm8aTU2ynQW
SEw1FjArwGE35RozI3WvKgyGJ9L0GVYw9w8L2ol2ZOzASLBffVaLJd9ODqnhF0Vj
/0gHIJQVWg4Jkn4uJLBjIW7x6Xugr99SlD8/RCwbiU5DLPCWi+IEKCaj0iELad1v
7Ljh+lUpm62kixw0VgucfXWXf0QR9TieI2xXJUnbLLwdYzEsPCmwNhw6EMpKY7ui
LW2+XuZrk9dczLYL2opzc7ln473lV5VJWFuYWHl4bqhjcfJOyNUVWPZtgnqxvvsl
B6ppmCAgFJqD5gUlZuLnNGNDX7Ne7eRFxjJEYbn9bKPXGtHumi/aNQ/ZAkyf93KV
O0LpTD84RabknhROgjKE9IU6BSwtKOGWNH9p4eSJDijX5KaQqqSE18ET6/e/xIVE
bxjp/MAvfZvEN30aJSjA
=PR5d
-----END PGP SIGNATURE-----

--CuneNnFdlk8k24ClMQJxchbWeXnOJPeC3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
