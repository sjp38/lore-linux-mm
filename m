Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE486B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:02:46 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id l4-v6so7039906otf.9
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:02:46 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0107.outbound.protection.outlook.com. [104.47.33.107])
        by mx.google.com with ESMTPS id d5si491389qtd.199.2018.04.04.08.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 08:02:38 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH -mm] mm, gup: prevent pmd checking race in
 follow_pmd_mask()
Date: Wed, 04 Apr 2018 11:02:26 -0400
Message-ID: <65E6BD75-FBA6-43AC-AC5A-B952DE409BC8@cs.rutgers.edu>
In-Reply-To: <20180404032257.11422-1-ying.huang@intel.com>
References: <20180404032257.11422-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_CB9590E2-828B-403D-9360-2645EC49EC8A_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_CB9590E2-828B-403D-9360-2645EC49EC8A_=
Content-Type: text/plain

On 3 Apr 2018, at 23:22, Huang, Ying wrote:

> From: Huang Ying <ying.huang@intel.com>
>
> mmap_sem will be read locked when calling follow_pmd_mask().  But this
> cannot prevent PMD from being changed for all cases when PTL is
> unlocked, for example, from pmd_trans_huge() to pmd_none() via
> MADV_DONTNEED.  So it is possible for the pmd_present() check in
> follow_pmd_mask() encounter a none PMD.  This may cause incorrect
> VM_BUG_ON() or infinite loop.  Fixed this via reading PMD entry again
> but only once and checking the local variable and pmd_none() in the
> retry loop.
>
> As Kirill pointed out, with PTL unlocked, the *pmd may be changed
> under us, so read it directly again and again may incur weird bugs.
> So although using *pmd directly other than pmd_present() checking may
> be safe, it is still better to replace them to read *pmd once and
> check the local variable for multiple times.

I see you point there. The patch wants to provide a consistent value
for all race checks. Specifically, this patch is trying to avoid the inconsistent
reads of *pmd for if-statements, which causes problem when both if-condition reads *pmd and
the statements inside "if" reads *pmd again and two reads can give different values.
Am I right about this?

If yes, the problem can be solved by something like:

if (!pmd_present(tmpval = *pmd)) {
    check tmpval instead of *pmd;
}

Right?

I just wonder if we need some general code for all race checks.

Thanks.

--
Best Regards
Yan Zi

--=_MailMate_CB9590E2-828B-403D-9360-2645EC49EC8A_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJaxOkCAAoJEEGLLxGcTqbMZU8H/1RA0Gu02wy0myF4tXGBkeFp
6TPYuRa1qbFQcyl6+2u3jU2gmKEWNN2JSHErUk97CZrgzuZ44tjcyf7VCtWff26c
lGGI2hBnNiln8w9A2rsZcxV/rKcNbyZftiXUoosR/WVhqOzlqIa+6zbXz426FwJs
9fCpogLVZrAJio/cCRHaBsuZxw7HD94wUARB9ofHHLuDPbcaQH/a8H4jp/Funa28
hT6ngohFqquFCCTVLkOSiNush8juSXXrS0QSqf35FWZKaW9QyvqLvx82CsXgveJ7
y/oSN7+fL+NGiyrqGdImkFG/AQsjcp5zfKfTh+MV4rSuMSGhbHH0WtRTnQaaCvk=
=DDkr
-----END PGP SIGNATURE-----

--=_MailMate_CB9590E2-828B-403D-9360-2645EC49EC8A_=--
