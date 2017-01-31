Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 356396B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 14:54:46 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c80so189173045iod.4
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 11:54:46 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0130.outbound.protection.outlook.com. [104.47.32.130])
        by mx.google.com with ESMTPS id p73si11046148itc.10.2017.01.31.11.54.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 11:54:45 -0800 (PST)
Message-ID: <5890EB58.3050100@cs.rutgers.edu>
Date: Tue, 31 Jan 2017 13:54:00 -0600
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com> <b6f7dd5d-47aa-0ec2-b18a-bb4074ab2a2a@linux.vnet.ibm.com>
In-Reply-To: <b6f7dd5d-47aa-0ec2-b18a-bb4074ab2a2a@linux.vnet.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enig69312C755C158C734ACD21BC"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

--------------enig69312C755C158C734ACD21BC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I am also doing some tests on THP migration and discover that there are
some corner cases not handled in this patchset.

For example, in handle_mm_fault, without taking pmd_lock, the kernel may
see pmd_none(*pmd) during THP migrations, which leads to
handle_pte_fault or even deeper in the code path. At that moment,
pmd_trans_unstable() will treat a pmd_migration_entry as pmd_bad and
clear it. This leads to application crashing and page table leaks, since
a deposited PTE page is not released when the application crashes.

Even after I add is_pmd_migration_entry() into pmd_trans_unstable(), I
still see application data corruptions.

I hope someone can shed some light on how to debug this. Should I also
look into pmd_trans_huge() call sites where pmd_migration_entry should
be handled differently?

Thanks.

Anshuman Khandual wrote:
> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
>> Hi everyone,
>>
>> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27=

>> with feedbacks for ver.1.
>=20
> Hello Noaya,
>=20
> I have been working with Zi Yan on the parallel huge page migration ser=
ies
> (https://lkml.org/lkml/2016/11/22/457) and planning to post them on top=
 of
> this THP migration enhancement series. Hence we were wondering if you h=
ave
> plans to post a new version of this series in near future ?
>=20
> Regards
> Anshuman
>=20

--=20
Best Regards,
Yan Zi


--------------enig69312C755C158C734ACD21BC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJYkOt/AAoJEEGLLxGcTqbMEmgH/RGfR7f5boRco6eWExeZ1adJ
6kRYWmYXipya1xJV7afp+px+MVsHA86IuCM2j+p/tSW000vRge2ydfIgHxrmIk1Q
pzXu1ILdMr91/sST1Zz4EBHSU2cB40EsbPq0nUT9OGda67XCWCcW7c6H9HQagMFm
w3NtHXgseJmr8vjcX5d44z1/zSBdDUQ1yNE8dzYHV5hZ7Mq47oRHju35pox+bQ6I
BOfRyDDtNAOuRGigEowTPBE8iLuoCQk9Ij0Re6NmBRIRquWrUYm0Up85iOGBK96a
GRL9vBAVZRAXNkVOygjwnSYxRKcbr05P0uIp6P/SWhtnoALneWA906M7nXqDHZA=
=fpdi
-----END PGP SIGNATURE-----

--------------enig69312C755C158C734ACD21BC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
