Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1456B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 16:27:57 -0500 (EST)
Date: Mon, 10 Jan 2011 16:26:28 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/9] mm: add apply_to_page_range_batch()
Message-ID: <20110110212628.GC15016@dumpdata.com>
References: <cover.1292450600.git.jeremy.fitzhardinge@citrix.com>
 <8c28c76840fcc7b76c7c8ce4dc28a57241243df7.1292450600.git.jeremy.fitzhardinge@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8c28c76840fcc7b76c7c8ce4dc28a57241243df7.1292450600.git.jeremy.fitzhardinge@citrix.com>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Haavard Skinnemoen <hskinnemoen@atmel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Xen-devel <xen-devel@lists.xensource.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
List-ID: <linux-mm.kvack.org>

. snip..
>  static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>  				     unsigned long addr, unsigned long end,
> -				     pte_fn_t fn, void *data)
> +				     pte_batch_fn_t fn, void *data)
>  {
>  	pte_t *pte;
>  	int err;
> -	pgtable_t token;
>  	spinlock_t *uninitialized_var(ptl);
>  
>  	pte = (mm == &init_mm) ?
> @@ -1940,25 +1939,17 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
>  	BUG_ON(pmd_huge(*pmd));
>  
>  	arch_enter_lazy_mmu_mode();
> -
> -	token = pmd_pgtable(*pmd);
> -
> -	do {
> -		err = fn(pte++, addr, data);
> -		if (err)
> -			break;
> -	} while (addr += PAGE_SIZE, addr != end);
> -
> +	err = fn(pte, (end - addr) / PAGE_SIZE, addr, data);
>  	arch_leave_lazy_mmu_mode();
>  
>  	if (mm != &init_mm)
> -		pte_unmap_unlock(pte-1, ptl);
> +		pte_unmap_unlock(pte, ptl);

That looks like a bug fix as well? Did this hit us before the change or was
it masked by the fact that the code never go to here?

>  	return err;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
