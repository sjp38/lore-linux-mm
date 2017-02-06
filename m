Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD8486B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 23:03:02 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so95340174pgc.2
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 20:03:02 -0800 (PST)
Received: from out0-142.mail.aliyun.com (out0-142.mail.aliyun.com. [140.205.0.142])
        by mx.google.com with ESMTP id r14si32578192pli.158.2017.02.05.20.03.01
        for <linux-mm@kvack.org>;
        Sun, 05 Feb 2017 20:03:01 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170205161252.85004-1-zi.yan@sent.com> <20170205161252.85004-4-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-4-zi.yan@sent.com>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in zap_pmd_range()
Date: Mon, 06 Feb 2017 12:02:54 +0800
Message-ID: <001101d2802d$e4ec9800$aec5c800$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Zi Yan' <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, 'Zi Yan' <ziy@nvidia.com>


On February 06, 2017 12:13 AM Zi Yan wrote: 
> 
> @@ -1233,33 +1233,31 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
>  				struct zap_details *details)
>  {
>  	pmd_t *pmd;
> +	spinlock_t *ptl;
>  	unsigned long next;
> 
>  	pmd = pmd_offset(pud, addr);
> +	ptl = pmd_lock(vma->vm_mm, pmd);
>  	do {
>  		next = pmd_addr_end(addr, end);
>  		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
>  			if (next - addr != HPAGE_PMD_SIZE) {
>  				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
>  				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
> -				__split_huge_pmd(vma, pmd, addr, false, NULL);
> -			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
> -				goto next;
> +				__split_huge_pmd_locked(vma, pmd, addr, false);
> +			} else if (__zap_huge_pmd_locked(tlb, vma, pmd, addr))
> +				continue;
>  			/* fall through */
>  		}
> -		/*
> -		 * Here there can be other concurrent MADV_DONTNEED or
> -		 * trans huge page faults running, and if the pmd is
> -		 * none or trans huge it can change under us. This is
> -		 * because MADV_DONTNEED holds the mmap_sem in read
> -		 * mode.
> -		 */
> -		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
> -			goto next;
> +
> +		if (pmd_none_or_clear_bad(pmd))
> +			continue;
> +		spin_unlock(ptl);
>  		next = zap_pte_range(tlb, vma, pmd, addr, next, details);
> -next:
>  		cond_resched();
> +		spin_lock(ptl);
>  	} while (pmd++, addr = next, addr != end);

spin_lock() is appointed to the bench of pmd_lock().

> +	spin_unlock(ptl);
> 
>  	return addr;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
