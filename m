Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52A546B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:11:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b204so27773241qkc.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:11:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x191si4536484ybe.227.2016.09.12.08.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 08:09:51 -0700 (PDT)
Message-ID: <1473692983.32433.235.camel@redhat.com>
Subject: Re: [PATCH] sched,numa,mm: revert to checking pmd/pte_write instead
 of VMA flags
From: Rik van Riel <riel@redhat.com>
Date: Mon, 12 Sep 2016 11:09:43 -0400
In-Reply-To: <20160911162402.GA2775@suse.de>
References: <20160908213053.07c992a9@annuminas.surriel.com>
	 <20160911162402.GA2775@suse.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-2cmrlBgGTOZii60NBkbF"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, aarcange@redhat.com


--=-2cmrlBgGTOZii60NBkbF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-09-11 at 17:24 +0100, Mel Gorman wrote:
> On Thu, Sep 08, 2016 at 09:30:53PM -0400, Rik van Riel wrote:
> > Commit 4d9424669946 ("mm: convert p[te|md]_mknonnuma and remaining
> > page table manipulations") changed NUMA balancing from _PAGE_NUMA
> > to using PROT_NONE, and was quickly found to introduce a regression
> > with NUMA grouping.
> >=20
> > It was followed up by these changesets:
> >=20
> > 53da3bc2ba9e ("mm: fix up numa read-only thread grouping logic")
> > bea66fbd11af ("mm: numa: group related processes based on VMA flags
> > instead of page table flags")
> > b191f9b106ea ("mm: numa: preserve PTE write permissions across a
> > NUMA hinting fault")
> >=20
> > The first of those two changesets try alternate approaches to NUMA
> > grouping, which apparently do not work as well as looking at the
> > PTE
> > write permissions.
> >=20
> > The latter patch preserves the PTE write permissions across a NUMA
> > protection fault. However, it forgets to revert the condition for
> > whether or not to group tasks together back to what it was before
> > 3.19, even though the information is now preserved in the page
> > tables
> > once again.
> >=20
> > This patch brings the NUMA grouping heuristic back to what it was
> > before changeset 4d9424669946, which the changelogs of subsequent
> > changesets suggest worked best.
> >=20
> > We have all the information again. We should probably use it.
> >=20
>=20
> Patch looks ok other than the comment above the second hunk being out
> of
> date. Out of curiousity, what workload benefitted from this? I saw a
> mix
> of marginal results when I ran this on a 2-socket and 4-socket box.

I did not performance test the change, because I believe
the VM_WRITE test has a small logical error.

Specifically, VM_WRITE is also true for VMAs that are
PROT_WRITE|MAP_PRIVATE, which we do NOT want to group
on. Every shared library mapped on my system seems to
have a (small) read-write VMA:

00007f5adacff000=C2=A0=C2=A0=C2=A01764K r-x-- libc-2.23.so
00007f5adaeb8000=C2=A0=C2=A0=C2=A02044K ----- libc-2.23.so
00007f5adb0b7000=C2=A0=C2=A0=C2=A0=C2=A0=C2=A016K r---- libc-2.23.so
00007f5adb0bb000=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A08K rw--- libc-2.23.so

In other words, the code that is currently upstream
could result in programs being grouped into a numa
group due to accesses to libc.so, if they happened
to get started up right at the same time.

This will not catch many programs, since most of them
will have private copies of the pages in the small
read-write segments by the time other programs start
up, but it could catch a few of them.

Testing on VM_WRITE|VM_SHARED would solve that issue,
but at that point it would be essentially identical
to reverting the code to the old pte_write() test
that we had in 3.19 and before.

I do not expect the performance impact to be visible,
except when somebody gets very unlucky with application
startup timing.

--=20

All Rights Reversed.
--=-2cmrlBgGTOZii60NBkbF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX1sU3AAoJEM553pKExN6DZVAH/jhLcDRAlZO+gcP8ZXxDLPHe
+CK/qWazGJuaghEG1zSAnzkALgfkP+B134jzcE+9hJ4W44ZwaJMxO8K6FNloEg3s
h/v0gXBXEEWMRXfaozTlVeDm7tfzeYbgJPSP5A0mg1bREcoNceptRbrjs+B/E8N3
l+1AZ8ow5Dakj4PwQdDqjM5F1MS8BihDU3jy9r2B5ijKNUdIkHJK39Ys+JdyIWPc
7ZNgu55qo/RVyA6LD8uLsGGhPtPQigSvRebOi+3IDHuUTNSKE8YjAFV9KNQffWc9
C3XQvI64G2/hkh+cch/d6xSQhNoOYEBzzVPbRgB8OLD6t1nb0MfNHjVqQk+QAYU=
=XQb6
-----END PGP SIGNATURE-----

--=-2cmrlBgGTOZii60NBkbF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
