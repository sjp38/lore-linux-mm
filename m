Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 409BA6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 14:51:43 -0400 (EDT)
Received: by oibn4 with SMTP id n4so23772045oib.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:51:43 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c22si2310186oib.56.2015.07.24.11.51.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 11:51:42 -0700 (PDT)
Date: Fri, 24 Jul 2015 14:51:36 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv2 09/10] x86/xen: export xen_alloc_p2m_entry()
Message-ID: <20150724185136.GB12824@l.oracle.com>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-10-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437738468-24110-10-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

On Fri, Jul 24, 2015 at 12:47:47PM +0100, David Vrabel wrote:
> Rename alloc_p2m() to xen_alloc_p2m_entry() and export it.
> 
> This is useful for ensuring that a p2m entry is allocated (i.e., not a
> shared missing or identity entry) so that subsequent set_phys_to_machine()
> calls will require no further allocations.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  arch/x86/include/asm/xen/page.h |  2 ++
>  arch/x86/xen/p2m.c              | 16 ++++++++++------
>  2 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/xen/page.h
> index c44a5d5..960b380 100644
> --- a/arch/x86/include/asm/xen/page.h
> +++ b/arch/x86/include/asm/xen/page.h
> @@ -45,6 +45,8 @@ extern unsigned long *xen_p2m_addr;
>  extern unsigned long  xen_p2m_size;
>  extern unsigned long  xen_max_p2m_pfn;
>  
> +extern int xen_alloc_p2m_entry(unsigned long pfn);
> +
>  extern unsigned long get_phys_to_machine(unsigned long pfn);
>  extern bool set_phys_to_machine(unsigned long pfn, unsigned long mfn);
>  extern bool __set_phys_to_machine(unsigned long pfn, unsigned long mfn);
> diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
> index 8b7f18e..ef93ccf 100644
> --- a/arch/x86/xen/p2m.c
> +++ b/arch/x86/xen/p2m.c
> @@ -503,7 +503,7 @@ static pte_t *alloc_p2m_pmd(unsigned long addr, pte_t *pte_pg)
>   * the new pages are installed with cmpxchg; if we lose the race then
>   * simply free the page we allocated and use the one that's there.
>   */
> -static bool alloc_p2m(unsigned long pfn)
> +int xen_alloc_p2m_entry(unsigned long pfn)
>  {
>  	unsigned topidx, mididx;
>  	unsigned long *top_mfn_p, *mid_mfn;
> @@ -524,7 +524,7 @@ static bool alloc_p2m(unsigned long pfn)
>  		/* PMD level is missing, allocate a new one */
>  		ptep = alloc_p2m_pmd(addr, pte_pg);
>  		if (!ptep)
> -			return false;
> +			return -ENOMEM;
>  	}
>  
>  	if (p2m_top_mfn) {
> @@ -541,7 +541,7 @@ static bool alloc_p2m(unsigned long pfn)
>  
>  			mid_mfn = alloc_p2m_page();
>  			if (!mid_mfn)
> -				return false;
> +				return -ENOMEM;
>  
>  			p2m_mid_mfn_init(mid_mfn, p2m_missing);
>  
> @@ -567,7 +567,7 @@ static bool alloc_p2m(unsigned long pfn)
>  
>  		p2m = alloc_p2m_page();
>  		if (!p2m)
> -			return false;
> +			return -ENOMEM;
>  
>  		if (p2m_pfn == PFN_DOWN(__pa(p2m_missing)))
>  			p2m_init(p2m);
> @@ -590,8 +590,9 @@ static bool alloc_p2m(unsigned long pfn)
>  			free_p2m_page(p2m);
>  	}
>  
> -	return true;
> +	return 0;
>  }
> +EXPORT_SYMBOL(xen_alloc_p2m);
>  
>  unsigned long __init set_phys_range_identity(unsigned long pfn_s,
>  				      unsigned long pfn_e)
> @@ -648,7 +649,10 @@ bool __set_phys_to_machine(unsigned long pfn, unsigned long mfn)
>  bool set_phys_to_machine(unsigned long pfn, unsigned long mfn)
>  {
>  	if (unlikely(!__set_phys_to_machine(pfn, mfn))) {
> -		if (!alloc_p2m(pfn))
> +		int ret;
> +
> +		ret = xen_alloc_p2m_entry(pfn);
> +		if (ret < 0)
>  			return false;
>  
>  		return __set_phys_to_machine(pfn, mfn);
> -- 
> 2.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
