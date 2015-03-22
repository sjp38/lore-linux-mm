Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 94DF06B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 03:22:12 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so19160810igb.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 00:22:12 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id j9si2969168igg.60.2015.03.22.00.22.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 00:22:11 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so19160706igb.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 00:22:11 -0700 (PDT)
Message-ID: <550E6D9D.1060507@gmail.com>
Date: Sun, 22 Mar 2015 03:22:05 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>	<550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
In-Reply-To: <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="RXIPR1cVLoe2WCNcXpQB3CBoxQxj4NUU1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksey Kandratsenka <alkondratenko@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RXIPR1cVLoe2WCNcXpQB3CBoxQxj4NUU1
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> Yes, that might be useful feature. (Assuming I understood it correctly)=

> I believe
> tcmalloc would likely use:
>=20
> mremap(old_ptr, move_size, move_size,
>        MREMAP_MAYMOVE | MREMAP_FIXED | MREMAP_NOHOLE,
>        new_ptr);
>=20
> as optimized equivalent of:
>=20
> memcpy(new_ptr, old_ptr, move_size);
> madvise(old_ptr, move_size, MADV_DONTNEED);

Yeah, it's essentially an optimized memcpy for when you don't need the
source allocation anymore.

> a) what is the smallest size where mremap is going to be faster ?

There are probably a lot of variables here like the CPU design and the
speed of system calls (syscall auditing makes them much slower!) in
addition to the stuff you've pointed out.

> My initial thinking was that we'd likely use mremap in all cases where
> we know
> that touching destination would cause minor page faults (i.e. when
> destination
> chunk was MADV_DONTNEED-ed or is brand new mapping). And then also
> always when
> size is large enough, i.e. because "teleporting" large count of pages i=
s
> likely
> to be faster than copying them.
>=20
> But now I realize that it is more interesting than that. I.e. because a=
s
> Daniel
> pointed out, mremap holds mmap_sem exclusively, while page faults are
> holding it
> for read. That could be optimized of course. Either by separate
> "teleport ptes"
> syscall (again, as noted by Daniel), or by having mremap drop mmap_sem
> for write
> and retaking it for read for "moving pages" part of work. Being not rea=
lly
> familiar with kernel code I have no idea if that's doable or not. But i=
t
> looks
> like it might be quite important.

I think it's doable but it would pessimize the case where the dest VMA
isn't reusable. It would need to optimistically take the reader lock to
find out and then drop it. However, userspace knows when this is surely
going to work and could give it a hint.

I have a good idea about what the *ideal* API for the jemalloc/tcmalloc
case would be. It would be extremely specific though... they want the
kernel to move pages from a source VMA to a destination VMA where both
are anon/private with identical flags so only the reader lock is
necessary. On top of that, they really want to keep around as many
destination pages as possible, maybe by swapping as many as possible
back to the source.

That's *extremely* specific though and I now think the best way to get
there is by landing this feature and then extending it as necessary down
the road. An allocator may actually want to manage other kinds of
mappings itself and it would want the mmap_sem optimization to be an
optional hint.

> And I confirm that with all default settings tcmalloc and jemalloc lose=
 to
> glibc. Also, notably, recent dev build of jemalloc (what is going to be=
 4.0
> AFAIK) actually matches or exceeds glibc speed, despite still not doing=

> mremap. Apparently it is smarter about avoiding moving allocation for t=
hose
> realloc-s. And it was even able to resist my attempt to force it to mov=
e
> allocation. I haven't investigated why. Note that I built it couple
> weeks or so
> ago from dev branch, so it might simply have bugs.

I submitted patches teaching jemalloc to expand/shrink huge allocations
in-place, so it's hitting the in-place resize path after the initial
iteration on a repeated reallocation benchmark that's not doing any
other allocations.

In jemalloc, everything is allocated via naturally aligned chunks (4M
before, recently down to 256k in master) so if you want to block
in-place huge reallocation you'll either need to force a new non-huge
chunk to be allocated or make one that's at least as large as the chunk
size.

I don't think in-place reallocation is very common in long-running
programs. It's probably more common now that jemalloc is experimenting
with first-fit for chunk/huge allocation rather than address-ordered
best-fit. The best-fit algorithm is designed to keep the opportunity for
in-place reallocation to a minimum, although address ordering does
counter it :).

> NOTE: TCMALLOC_AGGRESSIVE_DECOMMIT=3Dt (and default since 2.4) makes tc=
malloc
> MADV_DONTNEED large free blocks immediately. As opposed to less rare wi=
th
> setting of "false". And it makes big difference on page faults counts
> and thus
> on runtime.
>=20
> Another notable thing is how mlock effectively disables MADV_DONTNEED f=
or
> jemalloc{1,2} and tcmalloc, lowers page faults count and thus improves
> runtime. It can be seen that tcmalloc+mlock on thp-less configuration i=
s
> slightly better on runtime to glibc. The later spends a ton of time in
> kernel,
> probably handling minor page faults, and the former burns cpu in user s=
pace
> doing memcpy-s. So "tons of memcpys" seems to be competitive to what
> glibc is
> doing in this benchmark.

When I taught jemalloc to use the MREMAP_RETAIN flag it was getting
significant wins over glibc, so this might be caused by the time spent
managing metadata, etc.

> THP changes things however. Where apparently minor page faults become a=
 lot
> cheaper. Which makes glibc case a lot faster than even tcmalloc+mlock
> case. So
> in THP case, cost of page faults is smaller than cost of large memcpy.
>=20
> So results are somewhat mixed, but overall I'm not sure that I'm able t=
o see
> very convincing story for MREMAP_HOLE yet. However:
>=20
> 1) it is possible that I am missing something. If so, please, educate m=
e.
>=20
> 2) if kernel implements this API, I'm going to use it in tcmalloc.
>=20
> P.S. benchmark results also seem to indicate that tcmalloc could do
> something to
> explicitly enable THP and maybe better adapt to it's presence. Perhaps
> with some
> collaboration with kernel, i.e. to prevent that famous delay-ful-ness w=
hich
> causes people to disable THP.

BTW, THP currently interacts very poorly with the jemalloc/tcmalloc
madvise purging. The part where khugepaged assigns huge pages to dense
spans of pages is *great*. The part where the kernel hands out a huge
page on for a fault in a 2M span can be awful. It causes the model
inside the allocator of uncommitted vs. committed pages to break down.

For example, the allocator might use 1M of a huge page and then start
purging. The purging will split it into 4k pages, so there will be 1M of
zeroed 4k pages that are considered purged by the allocator. Over time,
this can cripple purging. Search for "jemalloc huge pages" and you'll
find lots of horror stories about this.

I think a THP implementation playing that played well with purging would
need to drop the page fault heuristic and rely on a significantly better
khugepaged. This would mean faulting in a span of memory would no longer
be faster. Having a flag to populate a range with madvise would help a
lot though, since the allocator knows exactly how much it's going to
clobber with the memcpy. There will still be a threshold where mremap
gets significantly faster, but it would move it higher.


--RXIPR1cVLoe2WCNcXpQB3CBoxQxj4NUU1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVDm2dAAoJEPnnEuWa9fIqweIP/1TSbDTLpyZoSEMyddd9HvUp
1rZFVBsttdgwJ34h3nYcs29j0i4+887Hbq666Wf1YmPnPC2lE2B38ynXOtzitLqI
0grcELnsVW9eWTRn1OOi9ROw0Wh+era8CQU0QR5BYSYcHcs5RX8Yl62LNu/LzLBR
ynmAtkrMVa3G3XR4iNXdFN+yNu2DYM0YoECbk+GAILoUPqSnOl8e9p0lfUAjwt7c
bZzDWBcqmCJROVCrtxaroXzw4glm/7rBDcHAFXPaYmGS5IpmxKukHLAFS1MIK4JM
X9q3Ezg4xiuB3fYKYJ8uEkEvXVhuxqVOp8vTH02aUziUHM4VJ9HS/lMXgzLKAXp1
yo+hqiLKK+UIedzBF62FZBxCDV55VsLOoeupN+azdOgytPMj1w49o+9qJBt99LpH
YrZynYzVb2WUzMxLSxpfeuZw3G55z3tVDAMl5pJiDc3lTLGWUzH850NExHDLqb98
r2+Pejc9jESwL1l1khWZ2dIbq4vQv76I+9JG7EjmOlBZchJyo8mA/PNLmOImM94g
xLZNnjStWgKjphCkaYE0asHH1EPhybgwg4cnUx2aDxVmCezmS92EWb9kt8DWZiNR
elBVuCDRBbDfP8NBAeWti6iRY0RFfUK96CFze72L/RmT1SjnidN8HNaVk4OO1yQX
n/PpyGO67h+tu8mlszSW
=GNL8
-----END PGP SIGNATURE-----

--RXIPR1cVLoe2WCNcXpQB3CBoxQxj4NUU1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
