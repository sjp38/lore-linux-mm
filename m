Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85BF06B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 08:02:45 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d15so46081931qke.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 05:02:45 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id c41si439269qtc.80.2017.02.06.05.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 05:02:44 -0800 (PST)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Date: Mon, 06 Feb 2017 07:02:41 -0600
Message-ID: <786096BE-B071-4635-B92F-348BB72D2304@sent.com>
In-Reply-To: <20170206074337.GB30339@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170206074337.GB30339@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_1923E910-9BFF-469F-98A4-9BB5D3293035_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, Zi Yan <ziy@nvidia.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_1923E910-9BFF-469F-98A4-9BB5D3293035_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 6 Feb 2017, at 1:43, Naoya Horiguchi wrote:

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
>
> If USE_SPLIT_PMD_PTLOCKS is true, pmd_lock() returns different ptl for
> each pmd. The following code runs over pmds within [addr, end) with
> a single ptl (of the first pmd,) so I suspect this locking really works=
=2E
> Maybe pmd_lock() should be called inside while loop?

According to include/linux/mm.h, pmd_lockptr() first gets the page the pm=
d is in,
using mask =3D ~(PTRS_PER_PMD * sizeof(pmd_t) -1) =3D 0xfffffffffffff000 =
and virt_to_page().
Then, ptlock_ptr() gets spinlock_t either from page->ptl (split case) or
mm->page_table_lock (not split case).

It seems to me that all PMDs in one page table page share a single spinlo=
ck. Let me know
if I misunderstand any code.

But your suggestion can avoid holding the pmd lock for long without cond_=
sched(),
I can move the spinlock inside the loop.

Thanks.

diff --git a/mm/memory.c b/mm/memory.c
index 5299b261c4b4..ff61d45eaea7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1260,31 +1260,34 @@ static inline unsigned long zap_pmd_range(struct =
mmu_gather *tlb,
                                struct zap_details *details)
 {
        pmd_t *pmd;
-       spinlock_t *ptl;
+       spinlock_t *ptl =3D NULL;
        unsigned long next;

        pmd =3D pmd_offset(pud, addr);
-       ptl =3D pmd_lock(vma->vm_mm, pmd);
        do {
+               ptl =3D pmd_lock(vma->vm_mm, pmd);
                next =3D pmd_addr_end(addr, end);
                if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devm=
ap(*pmd)) {
                        if (next - addr !=3D HPAGE_PMD_SIZE) {
                                VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
                                    !rwsem_is_locked(&tlb->mm->mmap_sem),=
 vma);
                                __split_huge_pmd_locked(vma, pmd, addr, f=
alse);
-                       } else if (__zap_huge_pmd_locked(tlb, vma, pmd, a=
ddr))
-                               continue;
+                       } else if (__zap_huge_pmd_locked(tlb, vma, pmd, a=
ddr)) {
+                               spin_unlock(ptl);
+                               goto next;
+                       }
                        /* fall through */
                }

-               if (pmd_none_or_clear_bad(pmd))
-                       continue;
+               if (pmd_none_or_clear_bad(pmd)) {
+                       spin_unlock(ptl);
+                       goto next;
+               }
                spin_unlock(ptl);
                next =3D zap_pte_range(tlb, vma, pmd, addr, next, details=
);
+next:
                cond_resched();
-               spin_lock(ptl);
        } while (pmd++, addr =3D next, addr !=3D end);
-       spin_unlock(ptl);

        return addr;
 }


>
> Thanks,
> Naoya Horiguchi
>
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


--
Best Regards
Yan Zi

--=_MailMate_1923E910-9BFF-469F-98A4-9BB5D3293035_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYmHPyAAoJEEGLLxGcTqbMdOYIAI0LUUfHkCPYpBQcT6ADHVna
Qdp5Y2P3OSkgJwaGikXPb9g33GZYN0MzXa6g60FWbjNrAW5ITM9zJmEKnHIiy8Ju
L/b92wVAVIs4caOOPTr53LQzELZIfXAGskN4L4q5Km93r2n6rsEVdrghTGF7S6VZ
cePtEkloV4XH3cTwq8ARR7+4uaVsOVjUZmxi/hAt9qT/qzQOkuAM+WzLXM9OMFIm
DclrvR04kXKGPdXRkMg75UzTF2ESaukeA1FKycRTrOxtgust6O/XZQUu8sniACAx
S0ddEt+5S1EwGhMiRRSDF3R8alJ+VtmTbI9Swfrnw/jw4TRJliMjvZm/TtuLY/U=
=Ho+z
-----END PGP SIGNATURE-----

--=_MailMate_1923E910-9BFF-469F-98A4-9BB5D3293035_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
