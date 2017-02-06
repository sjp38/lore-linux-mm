Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85C1D6B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 07:10:20 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id s186so45155748qkb.5
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 04:10:20 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id d39si337967qtf.224.2017.02.06.04.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 04:10:19 -0800 (PST)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v3 01/14] mm: thp: make __split_huge_pmd_locked visible.
Date: Mon, 06 Feb 2017 06:10:17 -0600
Message-ID: <47D53C68-7A1B-42AC-B526-F05A6CA48FA5@sent.com>
In-Reply-To: <20170206061232.GB1659@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-2-zi.yan@sent.com>
 <20170206061232.GB1659@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_ED95CEB1-D094-4CF5-AB18-5639831E7D2A_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, Zi Yan <ziy@nvidia.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_ED95CEB1-D094-4CF5-AB18-5639831E7D2A_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 6 Feb 2017, at 0:12, Naoya Horiguchi wrote:

> On Sun, Feb 05, 2017 at 11:12:39AM -0500, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> It allows splitting huge pmd while you are holding the pmd lock.
>> It is prepared for future zap_pmd_range() use.
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  include/linux/huge_mm.h |  2 ++
>>  mm/huge_memory.c        | 22 ++++++++++++----------
>>  2 files changed, 14 insertions(+), 10 deletions(-)
>>
> ...
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 03e4566fc226..cd66532ef667 100644
> ...
>> @@ -2036,10 +2039,9 @@ void __split_huge_pmd(struct vm_area_struct *vm=
a, pmd_t *pmd,
>>  			clear_page_mlock(page);
>>  	} else if (!pmd_devmap(*pmd))
>>  		goto out;
>> -	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
>> +	__split_huge_pmd_locked(vma, pmd, address, freeze);
>
> Could you explain what is intended on this change?
> If some caller (f.e. wp_huge_pmd?) could call __split_huge_pmd() with
> address not aligned with pmd border, __split_huge_pmd_locked() results =
in
> triggering VM_BUG_ON(haddr & ~HPAGE_PMD_MASK).

This change is intended for any caller already hold pmd lock. Now it is f=
or this
call site only.

In Patch 2, I moved unsigned long haddr =3D address & HPAGE_PMD_MASK;
from __split_huge_pmd() to __split_huge_pmd_locked(), so VM_BUG_ON(haddr =
& ~HPAGE_PMD_MASK)
will not be triggered.



>
> Thanks,
> Naoya Horiguchi
>
>>  out:
>>  	spin_unlock(ptl);
>> -	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE)=
;
>>  }
>>
>>  void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long=
 address,
>> -- =

>> 2.11.0
>>


--
Best Regards
Yan Zi

--=_MailMate_ED95CEB1-D094-4CF5-AB18-5639831E7D2A_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYmGepAAoJEEGLLxGcTqbMqG4H/3OgBBQpWDETrOGGMOv9cgc4
LPQ4utd1nwky7I5uqqKgehZW9cgbCx39h14kKtHX32silGubM1ha/s4q1nL8zv1/
S7Ai2OtHz72dnNInJIdOlSo7FUFtFu2eDlzbEX4L2IbRuysbcMzJbT9ZoTdD8hEH
YHQZtycIzqQfIW036aFi4qoP0ZIqXLL3phcan8nKbpDn5wxo0sfB+7iT70zIMJ8V
W9SaP+xqWUiRAbuTMqJD3QVq85gCw1HCVUnzplxtNwrDG1GqNhRuHS8NR1IMLH/9
bt+HIXt2Ni2gTVsnqzy6WwI0ERRlmrx5zYFLwNq0Ah/ms/CIZntiVyPZ5lSIRlc=
=uU0c
-----END PGP SIGNATURE-----

--=_MailMate_ED95CEB1-D094-4CF5-AB18-5639831E7D2A_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
