Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77F306B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 23:14:15 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id c80so72993389iod.4
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 20:14:15 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0100.outbound.protection.outlook.com. [104.47.34.100])
        by mx.google.com with ESMTPS id b14si8353452iob.39.2017.02.05.20.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 05 Feb 2017 20:14:14 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Date: Sun, 5 Feb 2017 22:14:05 -0600
Message-ID: <5FAC4169-EEFD-4E9C-8BAE-A5C7E483935B@cs.rutgers.edu>
In-Reply-To: <001101d2802d$e4ec9800$aec5c800$@alibaba-inc.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <001101d2802d$e4ec9800$aec5c800$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_F2A380AE-E6A2-41AF-8C54-4CC1D511986D_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <ziy@nvidia.com>

--=_MailMate_F2A380AE-E6A2-41AF-8C54-4CC1D511986D_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 5 Feb 2017, at 22:02, Hillf Danton wrote:

> On February 06, 2017 12:13 AM Zi Yan wrote:
>>
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
>
> spin_lock() is appointed to the bench of pmd_lock().

Any problem with this?

The code is trying to lock this PMD page to avoid other changes
and only unlock it when we want to go deeper to PTE range.

Locking the PMD page for at most 512-entry handling should be
acceptable, since zap_pte_range() does similar work for 512 PTEs.

>
>> +	spin_unlock(ptl);
>>
>>  	return addr;
>>  }


--
Best Regards
Yan Zi

--=_MailMate_F2A380AE-E6A2-41AF-8C54-4CC1D511986D_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYl/gNAAoJEEGLLxGcTqbMuuAH/3JiWjaJD3oEXZSFdcOEx2v2
VzSGCxiqrt7aMeZqK3NcV6eixCfbrW/ZOILOtjHZU3Y5+EwMMBSmDRgjLD+B9dts
2hsiFBiz7kIKYFav6/aBq2dwpvuHHK5YPQX5Lq80meZwNBPFrRLA8CU3vLtszy3k
7zl1FPHdcsDBLr6phw5OxL78+Jcd2qpLUgSiCLC+eaZGbG8ep6s+02NoTn+J53+t
P9W+BY2aDKgNrwOoAEUXtV0zbJTu3SheBLnP3oasOzRV7HM4+0S/bDgrwMomiLkp
vy8aANHSImL2KlMxjAaEWgYp0F+QrL712hpfRHUDc8Zt7lJtBSPIcfpV+MDF2Bw=
=Q6xc
-----END PGP SIGNATURE-----

--=_MailMate_F2A380AE-E6A2-41AF-8C54-4CC1D511986D_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
