Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA0A56B0038
	for <linux-mm@kvack.org>; Sun, 12 Feb 2017 19:25:23 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id x49so86048667qtc.7
        for <linux-mm@kvack.org>; Sun, 12 Feb 2017 16:25:23 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0118.outbound.protection.outlook.com. [104.47.33.118])
        by mx.google.com with ESMTPS id n14si6078676qtf.236.2017.02.12.16.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 12 Feb 2017 16:25:22 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Date: Sun, 12 Feb 2017 18:25:09 -0600
Message-ID: <44001748-05AC-49B2-88F5-371618C12AD9@cs.rutgers.edu>
In-Reply-To: <20170207174536.GC5578@node.shutemov.name>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170207141956.GA4789@node.shutemov.name> <5899E389.3040801@cs.rutgers.edu>
 <20170207163734.GA5578@node.shutemov.name> <589A0090.3050406@cs.rutgers.edu>
 <20170207174536.GC5578@node.shutemov.name>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_C6E23F04-9067-401A-BF9B-E7067D630DB1_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

--=_MailMate_C6E23F04-9067-401A-BF9B-E7067D630DB1_=
Content-Type: text/plain

Hi Kirill,

>>>> The crash scenario I guess is like:
>>>> 1. A huge page pmd entry is in the middle of being changed into either a
>>>> pmd_protnone or a pmd_migration_entry. It is cleared to pmd_none.
>>>>
>>>> 2. At the same time, the application frees the vma this page belongs to.
>>>
>>> Em... no.
>>>
>>> This shouldn't be possible: your 1. must be done under down_read(mmap_sem).
>>> And we only be able to remove vma under down_write(mmap_sem), so the
>>> scenario should be excluded.
>>>
>>> What do I miss?
>>
>> You are right. This problem will not happen in the upstream kernel.
>>
>> The problem comes from my customized kernel, where I migrate pages away
>> instead of reclaiming them when memory is under pressure. I did not take
>> any mmap_sem when I migrate pages. So I got this error.
>>
>> It is a false alarm. Sorry about that. Thanks for clarifying the problem.
>
> I think there's still a race between MADV_DONTNEED and
> change_huge_pmd(.prot_numa=1) resulting in skipping THP by
> zap_pmd_range(). It need to be addressed.
>
> And MADV_FREE requires a fix.
>
> So, minus one non-bug, plus two bugs.
>

You said a huge page pmd entry needs to be changed under down_read(mmap_sem).
It is only true for huge pages, right?

Since in mm/compaction.c, the kernel does not down_read(mmap_sem) during memory
compaction. Namely, base page migrations do not hold down_read(mmap_sem),
so in zap_pte_range(), the kernel needs to hold PTE page table locks.
Am I right about this?

If yes. IMHO, ultimately, when we need to compact 2MB pages to form 1GB pages,
in zap_pmd_range(), pmd locks have to be taken to make that kind of compactions
possible.

Do you agree?


--
Best Regards
Yan Zi

--=_MailMate_C6E23F04-9067-401A-BF9B-E7067D630DB1_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYoPzlAAoJEEGLLxGcTqbMk2MH+gIQ0g+sgTjOnp1Kg53DjNb1
09qV1KyJAkLNIBVO9chqm8nYhcjvZ8w0jOtcKZWHWicjgLpdCJQAutD20ZLj4Kh1
vmQYN3pbSSm+ibgVAxtOlgkT3N0S9dlFK35QXr2zvFsI2D1oC0hzCT1FqS8OuOnK
0qEPN4m1KCiAM6b8145YjnLkEMK8cf12EavnusyEzBV37nClEs6MDxjCplpLAjJC
3HjI15r3h/t5LAUWPEUsa5w8e+gmFPcfWeLEUH/DsaxmpJIPOT66TEd0R16gKaZd
HhBrybw5VAYVh4Itg8g+qGspfJ+r9HR0BViZUb0Plvngg7oHMxP1aX6CcZms71Y=
=8vKU
-----END PGP SIGNATURE-----

--=_MailMate_C6E23F04-9067-401A-BF9B-E7067D630DB1_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
