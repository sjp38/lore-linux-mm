Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 308F36B0278
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:58:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id r53-v6so1549207qtc.0
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:58:42 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k14-v6sor20320772qvh.15.2018.10.09.06.58.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 06:58:41 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Date: Tue, 09 Oct 2018 09:58:36 -0400
Message-ID: <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
In-Reply-To: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_D24ABCAE-03FA-4552-A378-F6F6EC1FF47E_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_D24ABCAE-03FA-4552-A378-F6F6EC1FF47E_=
Content-Type: text/plain

cc: Naoya Horiguchi (who proposed to use !_PAGE_PRESENT && !_PAGE_PSE for x86
PMD migration entry check)

On 8 Oct 2018, at 23:58, Anshuman Khandual wrote:

> A normal mapped THP page at PMD level should be correctly differentiated
> from a PMD migration entry while walking the page table. A mapped THP would
> additionally check positive for pmd_present() along with pmd_trans_huge()
> as compared to a PMD migration entry. This just adds a new conditional test
> differentiating the two while walking the page table.
>
> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
> exclusive which makes the current conditional block work for both mapped
> and migration entries. This is not same with arm64 where pmd_trans_huge()

!pmd_present() && pmd_trans_huge() is used to represent THPs under splitting,
since _PAGE_PRESENT is cleared during THP splitting but _PAGE_PSE is not.
See the comment in pmd_present() for x86, in arch/x86/include/asm/pgtable.h

> returns positive for both mapped and migration entries. Could some one
> please explain why pmd_trans_huge() has to return false for migration
> entries which just install swap bits and its still a PMD ? Nonetheless
> pmd_present() seems to be a better check to distinguish between mapped
> and (non-mapped non-present) migration entries without any ambiguity.

If arm64 does it differently, I just wonder how THP splitting is handled
in arm64.


--
Best Regards
Yan Zi

--=_MailMate_D24ABCAE-03FA-4552-A378-F6F6EC1FF47E_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlu8tAwWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzDkDB/0UH4oRh+cOCW0EYDRVhKtKBjs1
e1BD1S/Pcq/XFtgVfFoziz+3TRHYESnnwDOG86L7hyWON0yL20X6OIaKcQjRkRo7
OLReAB5Jq13CPF4q1U9jjRyNdl9dYvOEBtDsc02F8xv/8Hge3aIAqYH1eouCmAVa
Zo1hIRSxdHbWlLRLOOdNc2vD218gNuqtrcCsR78fddklGnItibcyokilXd3VBPRe
5gTJxg4s172rqL7IxkUs3N3KsiHnDDmH383tGZzIl7tULdLcboMvPK+ops5pOWTZ
UhCmfX0iauJoG8uHTkhQZvR2WiUz7gptJOA6QzlV80DqfgapNSpdzaJbn8mt
=ULbu
-----END PGP SIGNATURE-----

--=_MailMate_D24ABCAE-03FA-4552-A378-F6F6EC1FF47E_=--
