Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80C7D6B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 14:30:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e1so7946316pfd.9
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 11:30:37 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0108.outbound.protection.outlook.com. [104.47.41.108])
        by mx.google.com with ESMTPS id l70si3771044pge.75.2017.03.24.11.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 11:30:36 -0700 (PDT)
Message-ID: <58D565C5.2080001@cs.rutgers.edu>
Date: Fri, 24 Mar 2017 13:30:29 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v4 01/11] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit
 7 to bit 1
References: <20170313154507.3647-1-zi.yan@sent.com>  <20170313154507.3647-2-zi.yan@sent.com> <1490379805.2733.133.camel@linux.intel.com>
In-Reply-To: <1490379805.2733.133.camel@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enig7AEDB524ED0655C9B8BC2D8F"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, dnellans@nvidia.com

--------------enig7AEDB524ED0655C9B8BC2D8F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Tim Chen wrote:
> On Mon, 2017-03-13 at 11:44 -0400, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid
>> false negative return when it races with thp spilt
>> (during which _PAGE_PRESENT is temporary cleared.) I don't think that
>> dropping _PAGE_PSE check in pmd_present() works well because it can
>> hurt optimization of tlb handling in thp split.
>> In the current kernel, bits 1-4 are not used in non-present format
>> since commit 00839ee3b299 ("x86/mm: Move swap offset/type up in PTE to=

>> work around erratum"). So let's move _PAGE_SWP_SOFT_DIRTY to bit 1.
>> Bit 7 is used as reserved (always clear), so please don't use it for
>> other purpose.
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  arch/x86/include/asm/pgtable_64.h    | 12 +++++++++---
>>  arch/x86/include/asm/pgtable_types.h | 10 +++++-----
>>  2 files changed, 14 insertions(+), 8 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/=
pgtable_64.h
>> index 73c7ccc38912..a5c4fc62e078 100644
>> --- a/arch/x86/include/asm/pgtable_64.h
>> +++ b/arch/x86/include/asm/pgtable_64.h
>> @@ -157,15 +157,21 @@ static inline int pgd_large(pgd_t pgd) { return =
0; }
>>  /*
>>   * Encode and de-code a swap entry
>>   *
>> - * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0| <- bit numb=
er
>> - * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit name=
s
>> - * | OFFSET (14->63) | TYPE (9-13)  |0|X|X|X| X| X|X|X|0| <- swp entr=
y
>> + * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2| 1|0| <- bit num=
ber
>> + * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U| W|P| <- bit nam=
es
>> + * | OFFSET (14->63) | TYPE (9-13)  |0|0|X|X| X| X|X|SD|0| <- swp ent=
ry
>>   *
>>   * G (8) is aliased and used as a PROT_NONE indicator for
>>   * !present ptes.  We need to start storing swap entries above
>>   * there.  We also need to avoid using A and D because of an
>>   * erratum where they can be incorrectly set by hardware on
>>   * non-present PTEs.
>> + *
>> + * SD (1) in swp entry is used to store soft dirty bit, which helps u=
s
>> + * remember soft dirty over page migration
>> + *
>> + * Bit 7 in swp entry should be 0 because pmd_present checks not only=
 P,
>> + * but also G.
>=20
> but also L and G.

Got it. Thanks.

--=20
Best Regards,
Yan Zi


--------------enig7AEDB524ED0655C9B8BC2D8F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJY1WXFAAoJEEGLLxGcTqbMtvEH/jDZx2rPiOFQMaBtzYW9Sfgx
hNidwOsXgXoNpBMul74m4LYBqcMSvTNr/+c1NKmM+Ge5RfACzW4aQF4JSXOsxzoL
zgqkRRisuy5FuPDklpUJ77MBfuQZ5k2PswsrnxC/VGPJ3jNo4JxnhTKwB4M7Uull
G1OsqdOIY4ITpv3FXiPE2mjAYQ2e7sHf1JjosDEy2jrq4j/DtUjJ8oD8psAinQ8C
t1vezK/nKjGjx3dW/EP728v//g6bphS91x8xyZhGlxaQrz9vC1hPPsmLSlSyOx2x
SawnLATtBrjj3YMRFosk7/jP0jTnJzmtYpR8/jzrCqOZs02m2gqmdWEDweIG0/g=
=7Ew2
-----END PGP SIGNATURE-----

--------------enig7AEDB524ED0655C9B8BC2D8F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
