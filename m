Message-ID: <4689A691.9090908@vmware.com>
Date: Mon, 02 Jul 2007 18:29:53 -0700
From: Zachary Amsden <zach@vmware.com>
MIME-Version: 1.0
Subject: Re: [patch 3/5] remove ptep_test_and_clear_dirty and ptep_clear_flush_dirty.
References: <20070629135530.912094590@de.ibm.com> <20070629141528.060235678@de.ibm.com>
In-Reply-To: <20070629141528.060235678@de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:
> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
>
> Nobody is using ptep_test_and_clear_dirty and ptep_clear_flush_dirty.
> Remove the functions from all architectures.
>
>
> -static inline int
> -ptep_test_and_clear_dirty (struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
> -{
> -#ifdef CONFIG_SMP
> -	if (!pte_dirty(*ptep))
> -		return 0;
> -	return test_and_clear_bit(_PAGE_D_BIT, ptep);
> -#else
> -	pte_t pte = *ptep;
> -	if (!pte_dirty(pte))
> -		return 0;
> -	set_pte_at(vma->vm_mm, addr, ptep, pte_mkclean(pte));
> -	return 1;
> -#endif
> -}

I've not followed all the changes lately - what is the current protocol 
for clearing dirty bit?  Is it simply pte_clear followed by set or is it 
not done at all?  At least for i386 and virtualization, we had several 
optimizations to the test_and_clear path that are not possible with a 
pte_clear / set_pte approach.

Zach

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
