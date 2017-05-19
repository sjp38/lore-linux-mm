Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 186F12806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 12:31:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d127so63111289pga.11
        for <linux-mm@kvack.org>; Fri, 19 May 2017 09:31:17 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0118.outbound.protection.outlook.com. [104.47.41.118])
        by mx.google.com with ESMTPS id j13si9123913pgn.258.2017.05.19.09.31.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 May 2017 09:31:15 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v5 01/11] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to
 bit 1
Date: Fri, 19 May 2017 12:31:08 -0400
Message-ID: <07441274-3C64-4376-8225-39CD052399B4@cs.rutgers.edu>
In-Reply-To: <76a36bee-0f1c-a2f4-6f5c-78394ac46ee4@intel.com>
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-2-zi.yan@sent.com>
 <76a36bee-0f1c-a2f4-6f5c-78394ac46ee4@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_3756686B-DFCA-40C3-9666-A90C788D8246_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_3756686B-DFCA-40C3-9666-A90C788D8246_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 19 May 2017, at 11:55, Dave Hansen wrote:

> On 04/20/2017 01:47 PM, Zi Yan wrote:
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
>
> This description lacks a problem statement.  What's the problem?
>
> 	_PAGE_PSE is used to distinguish between a truly non-present
> 	(_PAGE_PRESENT=3D0) PMD, and a PMD which is undergoing a THP
> 	split and should be treated as present.
>
> 	But _PAGE_SWP_SOFT_DIRTY currently uses the _PAGE_PSE bit,
> 	which would cause confusion between one of those PMDs
> 	undergoing a THP split, and a soft-dirty PMD.
>
> 	Thus, we need to move the bit.
>
> Does that capture it?

Yes. I will add this in the next version.


>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  arch/x86/include/asm/pgtable_64.h    | 12 +++++++++---
>>  arch/x86/include/asm/pgtable_types.h | 10 +++++-----
>>  2 files changed, 14 insertions(+), 8 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/=
pgtable_64.h
>> index 73c7ccc38912..770b5ae271ed 100644
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
>
> So, this diagram was incomplete before?  It should have had "SD" under
> bit 7 for swap entries?

Right. SD bit is used only when CONFIG_MEM_SOFT_DIRTY is enabled, but it =
is good
to mark it in the diagram to avoid conflicts.

>
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
>> + * but also L and G.
>>   */

--
Best Regards
Yan Zi

--=_MailMate_3756686B-DFCA-40C3-9666-A90C788D8246_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZHx3MAAoJEEGLLxGcTqbMY8oH/i5aUg+WqqwKxedY35B5iNk8
ksoYhtA2H3cGNtiSbpGwzKyEnk9/vTOWfp2ipIyGRv8jBakh49BYwL+islthYVgw
38V69YGpumbxOjnO4vnc9FNTcWwO3280LNtvWa8vWz5JZEifoCujNLTBQycZmVNg
ZkGaDEHHRJmkCPxUQKADFT34l/HB6/u9LccXknXikLOMP5PcthwCsHJYd3devp8i
AC+jmMNyz0TXskZ/d0ngimzYzz6BHLIKvw4Fqb16P2bxPLV4g6NoISDsDI7Sdpip
emkShiiKvRdQEk2koCUuEmZF8ozzu3ZTkQXdyWrYQfy4hBhDgflTaP9H9kCSIx8=
=CNSM
-----END PGP SIGNATURE-----

--=_MailMate_3756686B-DFCA-40C3-9666-A90C788D8246_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
