Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A16AA6B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 11:00:26 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q83so2110339qke.16
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 08:00:26 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0137.outbound.protection.outlook.com. [104.47.33.137])
        by mx.google.com with ESMTPS id a1si5096331qtc.353.2017.11.03.08.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 08:00:21 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC -mm] mm, userfaultfd, THP: Avoid waiting when PMD under THP
 migration
Date: Fri, 03 Nov 2017 11:00:14 -0400
Message-ID: <D3FBD1E2-FC24-46B1-9CFF-B73295292675@cs.rutgers.edu>
In-Reply-To: <20171103075231.25416-1-ying.huang@intel.com>
References: <20171103075231.25416-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_A623C49A-6A90-489F-A16A-2539662222BC_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.UK>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_A623C49A-6A90-489F-A16A-2539662222BC_=
Content-Type: text/plain

On 3 Nov 2017, at 3:52, Huang, Ying wrote:

> From: Huang Ying <ying.huang@intel.com>
>
> If THP migration is enabled, the following situation is possible,
>
> - A THP is mapped at source address
> - Migration is started to move the THP to another node
> - Page fault occurs
> - The PMD (migration entry) is copied to the destination address in mremap
>

You mean the page fault path follows the source address and sees pmd_none() now
because mremap() clears it and remaps the page with dest address.
Otherwise, it seems not possible to get into handle_userfault(), since it is called in
pmd_none() branch inside do_huge_pmd_anonymous_page().


> That is, it is possible for handle_userfault() encounter a PMD entry
> which has been handled but !pmd_present().  In the current
> implementation, we will wait for such PMD entries, which may cause
> unnecessary waiting, and potential soft lockup.

handle_userfault() should only see pmd_none() in the situation you describe,
whereas !pmd_present() (migration entry case) should lead to
pmd_migration_entry_wait().

Am I missing anything here?


--
Best Regards
Yan Zi

--=_MailMate_A623C49A-6A90-489F-A16A-2539662222BC_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZ/IR/AAoJEEGLLxGcTqbMuoUIALSM9JuTIT4JBK6bqVxn8B60
XlpqJ9uxoxQYBAeiOge6kLlS+9yEwMKBUeLPInLC2WzdU/qWx7RwOmyBx8wcif9y
CO5uVAcz47u1/3xtLyzP5jkws9WJ5Ocm2WX8+t9t65yMX93CbY4TFGhaIBH1aslL
FZWMpDijgSbedMTciyyqNv/lL1eGnaN9EIXTjc/PyCFz3cJPcfAeK+VWFm8hiCdW
lrXcQJqgtT/eBQn8/aeZK96yp83zZXc3y8i2SISv70VUFaxiAJqrG33DSLILrzHn
M4kNwHWv7mkoOwChyrYtIaDyFddjFx8/fdXoyVuoGODDnVdVR5RLP9H7rsbTS4g=
=UjK2
-----END PGP SIGNATURE-----

--=_MailMate_A623C49A-6A90-489F-A16A-2539662222BC_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
