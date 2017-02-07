Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 837F16B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 09:12:54 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h10so113662115ith.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 06:12:54 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0135.outbound.protection.outlook.com. [104.47.42.135])
        by mx.google.com with ESMTPS id o93si11786115ioi.151.2017.02.07.06.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 06:12:53 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Date: Tue, 7 Feb 2017 08:12:43 -0600
Message-ID: <366917AD-792F-40E7-BC20-978A13EABB73@cs.rutgers.edu>
In-Reply-To: <87bmueqf59.fsf@skywalker.in.ibm.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170206160751.GA29962@node.shutemov.name>
 <87bmueqf59.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_5B4C82F0-AB41-4B85-9D32-50E7A4C06C9F_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, mgorman@techsingularity.net, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

--=_MailMate_5B4C82F0-AB41-4B85-9D32-50E7A4C06C9F_=
Content-Type: text/plain; markup=markdown

On 7 Feb 2017, at 7:55, Aneesh Kumar K.V wrote:

> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
>
>> On Sun, Feb 05, 2017 at 11:12:41AM -0500, Zi Yan wrote:
>>> From: Zi Yan <ziy@nvidia.com>
>>>
>>> Originally, zap_pmd_range() checks pmd value without taking pmd lock.
>>> This can cause pmd_protnone entry not being freed.
>>>
>>> Because there are two steps in changing a pmd entry to a pmd_protnone
>>> entry. First, the pmd entry is cleared to a pmd_none entry, then,
>>> the pmd_none entry is changed into a pmd_protnone entry.
>>> The racy check, even with barrier, might only see the pmd_none entry
>>> in zap_pmd_range(), thus, the mapping is neither split nor zapped.
>>
>> That's definately a good catch.
>>
>> But I don't agree with the solution. Taking pmd lock on each
>> zap_pmd_range() is a significant hit by scalability of the code path.
>> Yes, split ptl lock helps, but it would be nice to avoid the lock in first
>> place.
>>
>> Can we fix change_huge_pmd() instead? Is there a reason why we cannot
>> setup the pmd_protnone() atomically?
>>
>> Mel? Rik?
>>
>
> I am also trying to fixup the usage of set_pte_at on ptes that are
> valid/present (that this autonuma ptes). I guess what we are missing is a
> variant of pte update routines that can atomically update a pte without
> clearing it and that also doesn't do a tlb flush ?

I think so. The key point is to have a atomic PTE update function instead
of current two-step pte/pmd_get_clear() then set_pte/pmd_at(). We can always
add a wrapper to include TLB flush, once we have this atomic update function.

I used xchg() to replace xxx_get_clear() & set_xxx_at() in pmd_protnone(),
set_pmd_migration_entry(), and remove_pmd_migration(),
then ran my test overnight. I did not see kernel crashing nor data corruption.
So I think the atomic PTE/PMD update function works without taking locks
in zap_pmd_range().

Aneesh, in your patch of fixing PowerPC's autonuma pte problem, why didn't you
use atomic operations? Is there any limitation on PowerPC?

My question is why current kernel uses xxx_get_clear() and set_xxx_at()
in the first place? Is there any limitation I do not know?


Thanks.

--
Best Regards
Yan Zi

--=_MailMate_5B4C82F0-AB41-4B85-9D32-50E7A4C06C9F_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYmdXbAAoJEEGLLxGcTqbMVT8H/3V4BbjxZ4uVRS/AShwtEkt6
WvRTuQwnf/U3W8Oti/LgqgBNG6xm/tR9o3FSwr7XJ1tORO64GNGH3sxdZuWyt0U+
ekvggYYDrVvZDTe0Zu+lcvrClT1uQwL/+4NKG/MIu6cbuxzgZ8PbdFcOFCwDKbaj
KmZ4XKjScDlKQdNYOjLWnFyE84gDi9+gvMgassx/O67e/PAYS48h4UjwjsRYETH/
UxyUWhLTlSss1HTGpSCZfudcM65ZsZrRNUSNjPISM++ALzqDdMCR2otRC+Q2UCTo
LQwhurA8frjkPmfx/yG1ntwrFuuuxs7MmOu7/Kbwhswe5O2kK4PYdJOXJzlEYUQ=
=Lv/q
-----END PGP SIGNATURE-----

--=_MailMate_5B4C82F0-AB41-4B85-9D32-50E7A4C06C9F_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
