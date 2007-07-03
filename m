Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id l637OPpp191248
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 07:24:25 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l637OPmT2023502
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 09:24:25 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l637OPLE007749
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 09:24:25 +0200
Subject: Re: [patch 3/5] remove ptep_test_and_clear_dirty and
	ptep_clear_flush_dirty.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <4689A691.9090908@vmware.com>
References: <20070629135530.912094590@de.ibm.com>
	 <20070629141528.060235678@de.ibm.com>  <4689A691.9090908@vmware.com>
Content-Type: text/plain
Date: Tue, 03 Jul 2007 09:26:38 +0200
Message-Id: <1183447598.9766.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zachary Amsden <zach@vmware.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-02 at 18:29 -0700, Zachary Amsden wrote:
> > -static inline int
> > -ptep_test_and_clear_dirty (struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
> > -{
> > -#ifdef CONFIG_SMP
> > -	if (!pte_dirty(*ptep))
> > -		return 0;
> > -	return test_and_clear_bit(_PAGE_D_BIT, ptep);
> > -#else
> > -	pte_t pte = *ptep;
> > -	if (!pte_dirty(pte))
> > -		return 0;
> > -	set_pte_at(vma->vm_mm, addr, ptep, pte_mkclean(pte));
> > -	return 1;
> > -#endif
> > -}
> 
> I've not followed all the changes lately - what is the current protocol 
> for clearing dirty bit?  Is it simply pte_clear followed by set or is it 
> not done at all?  At least for i386 and virtualization, we had several 
> optimizations to the test_and_clear path that are not possible with a 
> pte_clear / set_pte approach.

Imho with a sequence of ptep_get_and_clear, pte_wrprotect, set_pte_at.
One of the reasons why ptep_test_and_clear_dirty doesn't make sense
anymore is the shared dirty page tracking. You never just test and clear
the dirty bit, the latest code always sets the write protect bit as
well.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
