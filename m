Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E86C6B0005
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 13:04:10 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b8-v6so9069128qto.16
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 10:04:10 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id f36-v6si3014333qtf.100.2018.07.06.10.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 10:04:09 -0700 (PDT)
Message-ID: <1530896635.5350.25.camel@surriel.com>
Subject: mm,tlb: revert 4647706ebeee?
From: Rik van Riel <riel@surriel.com>
Date: Fri, 06 Jul 2018 13:03:55 -0400
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-zb/vom+066eg5F7hihUM"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "kirill.shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team <kernel-team@fb.com>


--=-zb/vom+066eg5F7hihUM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello,

It looks like last summer, there were 2 sets of patches
in flight to fix the issue of simultaneous mprotect/madvise
calls unmapping PTEs, and some pages not being flushed from
the TLB before returning to userspace.

Minchan posted these patches:
56236a59556c ("mm: refactor TLB gathering API")
99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem")

Around the same time, Mel posted:
4647706ebeee ("mm: always flush VMA ranges affected by zap_page_range")

They both appear to solve the same bug.

Only one of the two solutions is needed.

However, 4647706ebeee appears to introduce extra TLB
flushes - one per VMA, instead of one over the entire
range unmapped, and also extra flushes when there are
no simultaneous unmappers of the same mm.

For that reason, it seems like we should revert
4647706ebeee and keep only Minchan's solution in
the kernel.

Am I overlooking any reason why we should not revert
4647706ebeee?

kind regards,

Rik
--=20
All Rights Reversed.
--=-zb/vom+066eg5F7hihUM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAls/oPsACgkQznnekoTE
3oOwCQf/fCp6/SmsfPwk5QdUpaiKb9p4zW3RmAuc3LZ3DPkduCTH1SPlJeW/5bDj
1n2bKWKRPF7oAbxc3gpcgLpraEteJIEB8uCibo3KB7pGlqm1ItQPg1Fme5FNZpOy
tTAcgvjiwKMkVNwQhpbjEoR0mYZ1GtuNe9waTIRSwYvMKGijVMTeQAhuty4mxY7Y
fGYrhNcw8YDfoa9iBmnG7mXVGNl7g2gDSJDfmijr9aCaAHNKwpnKo74A5Hj65gTy
nEuV64dz6WWpT9w00MTSORUVAYVfb9CHaZfTsigUc5MvcaI0Q6L+LDL2nx21Yqyb
h4nD+F21Gf2PQSQ2uZjWHdtwqVSBNw==
=/P1I
-----END PGP SIGNATURE-----

--=-zb/vom+066eg5F7hihUM--
