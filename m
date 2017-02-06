Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A24C6B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 11:32:14 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d15so49620913qke.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 08:32:14 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id o6si844812qtd.124.2017.02.06.08.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 08:32:13 -0800 (PST)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Date: Mon, 06 Feb 2017 10:32:10 -0600
Message-ID: <1D482D89-0504-4E98-9931-B160BAEB3D75@sent.com>
In-Reply-To: <20170206160751.GA29962@node.shutemov.name>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170206160751.GA29962@node.shutemov.name>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_8A4EA27D-D4B0-4992-BA83-9D688E26540A_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: mgorman@techsingularity.net, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_8A4EA27D-D4B0-4992-BA83-9D688E26540A_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 6 Feb 2017, at 10:07, Kirill A. Shutemov wrote:

> On Sun, Feb 05, 2017 at 11:12:41AM -0500, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> Originally, zap_pmd_range() checks pmd value without taking pmd lock.
>> This can cause pmd_protnone entry not being freed.
>>
>> Because there are two steps in changing a pmd entry to a pmd_protnone
>> entry. First, the pmd entry is cleared to a pmd_none entry, then,
>> the pmd_none entry is changed into a pmd_protnone entry.
>> The racy check, even with barrier, might only see the pmd_none entry
>> in zap_pmd_range(), thus, the mapping is neither split nor zapped.
>
> That's definately a good catch.
>
> But I don't agree with the solution. Taking pmd lock on each
> zap_pmd_range() is a significant hit by scalability of the code path.
> Yes, split ptl lock helps, but it would be nice to avoid the lock in fi=
rst
> place.
>
> Can we fix change_huge_pmd() instead? Is there a reason why we cannot
> setup the pmd_protnone() atomically?

If you want to setup the pmd_protnone() atomically, we need a new way of
changing pmds, like pmdp_huge_cmp_exchange_and_clear(). Otherwise, due to=

the nature of racy check of pmd in zap_pmd_range(), it is impossible to
eliminate the chance of catching this bug if pmd_protnone() is setup
in two steps: first, clear it, second, set it.

However, if we use pmdp_huge_cmp_exchange_and_clear() to change pmds from=
 now on,
instead of current two-step approach, it will eliminate the possibility o=
f
using batched TLB shootdown optimization (introduced by Mel Gorman for ba=
se page swapping)
when THP is swappable in the future. Maybe other optimizations?

Why do you think holding pmd lock is bad? In zap_pte_range(), pte lock
is also held when each PTE is zapped.

BTW, I am following Naoya's suggestion and going to take pmd lock inside
the loop. So pmd lock is held when each pmd is being checked and it will =
be released
when the pmd entry is zapped, split, or pointed to a page table.
Does it still hurt much on performance?

Thanks.



>
> Mel? Rik?
>
>>
>> Later, in free_pmd_range(), pmd_none_or_clear() will see the
>> pmd_protnone entry and clear it as a pmd_bad entry. Furthermore,
>> since the pmd_protnone entry is not properly freed, the corresponding
>> deposited pte page table is not freed either.
>>
>> This causes memory leak or kernel crashing, if VM_BUG_ON() is enabled.=

>>
>> This patch relies on __split_huge_pmd_locked() and
>> __zap_huge_pmd_locked().
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  mm/memory.c | 24 +++++++++++-------------
>>  1 file changed, 11 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 3929b015faf7..7cfdd5208ef5 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1233,33 +1233,31 @@ static inline unsigned long zap_pmd_range(stru=
ct mmu_gather *tlb,
>>  				struct zap_details *details)
>>  {
>>  	pmd_t *pmd;
>> +	spinlock_t *ptl;
>>  	unsigned long next;
>>
>>  	pmd =3D pmd_offset(pud, addr);
>> +	ptl =3D pmd_lock(vma->vm_mm, pmd);
>>  	do {
>>  		next =3D pmd_addr_end(addr, end);
>>  		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
>>  			if (next - addr !=3D HPAGE_PMD_SIZE) {
>>  				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
>>  				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
>> -				__split_huge_pmd(vma, pmd, addr, false, NULL);
>> -			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
>> -				goto next;
>> +				__split_huge_pmd_locked(vma, pmd, addr, false);
>> +			} else if (__zap_huge_pmd_locked(tlb, vma, pmd, addr))
>> +				continue;
>>  			/* fall through */
>>  		}
>> -		/*
>> -		 * Here there can be other concurrent MADV_DONTNEED or
>> -		 * trans huge page faults running, and if the pmd is
>> -		 * none or trans huge it can change under us. This is
>> -		 * because MADV_DONTNEED holds the mmap_sem in read
>> -		 * mode.
>> -		 */
>> -		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
>> -			goto next;
>> +
>> +		if (pmd_none_or_clear_bad(pmd))
>> +			continue;
>> +		spin_unlock(ptl);
>>  		next =3D zap_pte_range(tlb, vma, pmd, addr, next, details);
>> -next:
>>  		cond_resched();
>> +		spin_lock(ptl);
>>  	} while (pmd++, addr =3D next, addr !=3D end);
>> +	spin_unlock(ptl);
>>
>>  	return addr;
>>  }
>> -- =

>> 2.11.0
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
> -- =

>  Kirill A. Shutemov


--
Best Regards
Yan Zi

--=_MailMate_8A4EA27D-D4B0-4992-BA83-9D688E26540A_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYmKULAAoJEEGLLxGcTqbMZ98H/A1afpRqS0+68/BX/Uic+8py
WfiJn84vOc19iVaYcP1rAZS9HToqyLk5GRaMitS+9sjSRUxFT4dQa0/3A/PSeWbk
plNVofEtEtr5Zvv15/Q8GJFwrH5PxuZaDynJ2wqs4hfP19DGGiRpTSOgR7kYFbnM
D53YJu9BzCSmVqWKDtFx2031WMvSVR7I1VBnEGtiEypaWfZtBQzwPxQHrynQ4fcA
6Z4Gnvvtaza0t85f/mlfAjkrPq+335ofYfpZBbn33QepKY7WRJj/ppJKNzFbvHW+
C9m3HKVcLZMIuhJ5wG9MX9s//ewtT49QJ+kfkziifoyF5BF9BdlJyDpGn4syCEU=
=yxf5
-----END PGP SIGNATURE-----

--=_MailMate_8A4EA27D-D4B0-4992-BA83-9D688E26540A_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
