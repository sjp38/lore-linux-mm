Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 52CDC6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 00:51:10 -0500 (EST)
Received: by igdg1 with SMTP id g1so97603641igd.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 21:51:10 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id o6si1038220ioe.63.2015.11.03.21.51.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 21:51:09 -0800 (PST)
Received: by iofz202 with SMTP id z202so43295811iof.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 21:51:09 -0800 (PST)
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <56399CA5.8090101@gmail.com>
Date: Wed, 4 Nov 2015 00:50:29 -0500
MIME-Version: 1.0
In-Reply-To: <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="fGNIRpdGvX8H58Gstk3c5vtSEB1I11B1A"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, Shaohua Li <shli@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin.wang2010@gmail.com, Mel Gorman <mgorman@suse.de>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fGNIRpdGvX8H58Gstk3c5vtSEB1I11B1A
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> Does this set the write protect bit?
>=20
> What happens on architectures without hardware dirty tracking?

It's supposed to avoid needing page faults when the data is accessed
again, but it can just be implemented via page faults on architectures
without a way to check for access or writes. MADV_DONTNEED is also a
valid implementation of MADV_FREE if it comes to that (which is what it
does on swapless systems for now).

> Using the dirty bit for these semantics scares me.  This API creates a
> page that can have visible nonzero contents and then can
> asynchronously and magically zero itself thereafter.  That makes me
> nervous.  Could we use the accessed bit instead?  Then the observable
> semantics would be equivalent to having MADV_FREE either zero the page
> or do nothing, except that it doesn't make up its mind until the next
> read.

FWIW, those are already basically the semantics provided by GCC and LLVM
for data the compiler considers uninitialized (they could be more
aggressive since C just says it's undefined, but in practice they allow
it but can produce inconsistent results even if it isn't touched).

http://llvm.org/docs/LangRef.html#undefined-values

It doesn't seem like there would be an advantage to checking if the data
was written to vs. whether it was accessed if checking for both of those
is comparable in performance. I don't know enough about that.

>> +                       ptent =3D pte_mkold(ptent);
>> +                       ptent =3D pte_mkclean(ptent);
>> +                       set_pte_at(mm, addr, pte, ptent);
>> +                       tlb_remove_tlb_entry(tlb, pte, addr);
>=20
> It looks like you are flushing the TLB.  In a multithreaded program,
> that's rather expensive.  Potentially silly question: would it be
> better to just zero the page immediately in a multithreaded program
> and then, when swapping out, check the page is zeroed and, if so, skip
> swapping it out?  That could be done without forcing an IPI.

In the common case it will be passed many pages by the allocator. There
will still be a layer of purging logic on top of MADV_FREE but it can be
much thinner than the current workarounds for MADV_DONTNEED. So the
allocator would still be coalescing dirty ranges and only purging when
the ratio of dirty:clean pages rises above some threshold. It would be
able to weight the largest ranges for purging first rather than logic
based on stuff like aging as is used for MADV_DONTNEED.


--fGNIRpdGvX8H58Gstk3c5vtSEB1I11B1A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOZylAAoJEPnnEuWa9fIq0RwP+wWio9N+5lM0AsP6nSzbc6Zc
m0MkA92ZboJ4vG0HrLOduBnGJs9DDJADnHjcuwXsH1r/jPOPxgozY4/Kp/4rgcU2
4sqgdCTAFF3n8ezMI2AVP0gkiut05VDL/PNkBMTjEyhEVvNRtg0MUJMR9+ge75E2
c9EWsFfYKl2iRIHOmxspuSnP/hN82IcsSE3mXK1ud97kTLjZvS/OMsoOe1jdxr+s
cKWH53lZuRvztTZ1rADrHmcWD7p2Y8obt03ivmvulU2oQ+ThgOkRN6960t4t8cfw
y44CeFZTcLIs3A5/ftzW9V9tzKQyILVElfVGOBK9HaMyJw2rt5vvQCbZR1lIncos
bFnzWTqUuJLwgrK9eRiYUI96oQ+xFBxIcrsdTxiEpWu2bDqUnLe4WaHrFwa1b37x
hpF1PLTTloJ6O2EEb9+llyJV47pwCY06SSftZb0BhmxWRHGgfbPbMPQQ6HEP4Jo5
jUeX+Qg1BPt8YMJGOJh38+TUmAdAhw3xO4pF8RThsL1TQ2xVgLrGq55r/MGXYsWB
b2agIiGkeciJQNWR1MlnhjQKzk2yAanan4UMSFdXn3IXJTK84U9M+FGN5ow4rKeF
dnrsPUx9mrvgHeyFsKkGpJXNgPuMiaF47eLbQRaKluMtlQYv0Iq6/9v9DfwuFUv6
KJi5sibrJ+3dGoXLIJxA
=Kj1y
-----END PGP SIGNATURE-----

--fGNIRpdGvX8H58Gstk3c5vtSEB1I11B1A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
