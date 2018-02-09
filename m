Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B4CBA6B0006
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 09:47:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d6so2597765pgv.21
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 06:47:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q17si1473324pgv.144.2018.02.09.06.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Feb 2018 06:47:28 -0800 (PST)
Date: Fri, 9 Feb 2018 06:47:26 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180209144726.GD16666@bombadil.infradead.org>
References: <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
 <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
 <20180119030447.GA26245@bombadil.infradead.org>
 <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
 <20180119132145.GB2897@bombadil.infradead.org>
 <9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
 <32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
 <20180126194058.GA31600@bombadil.infradead.org>
 <9ff38687-edde-6b4e-4532-9c150f8ea647@rimuhosting.com>
 <20180131105456.GC28275@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180131105456.GC28275@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen@randonwebstuff.com
Cc: Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org


ping?

On Wed, Jan 31, 2018 at 02:54:56AM -0800, Matthew Wilcox wrote:
> On Tue, Jan 30, 2018 at 11:26:42AM +1300, xen@randonwebstuff.com wrote:
> > After, received this stack.
> > 
> > Have not tried memtest86.  These are production hosts.  This has occurred on
> > multiple hosts.  I can only recall this occurring on 32 bit kernels.  I
> > cannot recall issues with other VMs not running that kernel on the same
> > hosts.
> > 
> > [  125.329163] Bad swp_entry: e000000
> 
> Mixed news here then ... 'e' is 8 | 4 | 2, so it's not a single bitflip.
> So no point in running memtest86.
> 
> I should have made the printk produce leading zeroes, because that's
> 0x0e00'0000.  ptes use the top 5 bits to encode the swapfile, so
> this swap entry is decoded as swapfile 1, page number 0x0600'0000.
> That's clearly ludicrous because you don't have a swapfile 1, and if
> you did, it wouldn't be so large as a terabyte.
> 
> I think the next step in debugging this is printing the PTE which gave
> us this swp_entry.  If you can drop the patch I asked you to try, and
> apply this patch instead, we'll have more idea about what's going on.
> 
> Thanks!
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 403934297a3d..8caaddb07747 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2892,6 +2892,10 @@ int do_swap_page(struct vm_fault *vmf)
>  	if (!page)
>  		page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
>  					 vmf->address);
> +	if (IS_ERR(page)) {
> +		pte_ERROR(vmf->orig_pte);
> +		page = NULL;
> +	}
>  	if (!page) {
>  		struct swap_info_struct *si = swp_swap_info(entry);
>  
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 7fbe67be86fa..905fa34e022a 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1651,6 +1651,10 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  	if (swap.val) {
>  		/* Look it up and read it in.. */
>  		page = lookup_swap_cache(swap, NULL, 0);
> +		if (IS_ERR(page)) {
> +			pte_ERROR(vmf->orig_pte);
> +			page = NULL;
> +		}
>  		if (!page) {
>  			/* Or update major stats only when swapin succeeds?? */
>  			if (fault_type) {
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 39ae7cfad90f..7ee594c8eadd 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -334,8 +334,14 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
>  	struct page *page;
>  	unsigned long ra_info;
>  	int win, hits, readahead;
> +	struct address_space *swapper_space = swap_address_space(entry);
> +
> +	if (!swapper_space) {
> +		pr_err("Bad swp_entry: %lx\n", entry.val);
> +		return ERR_PTR(-EFAULT);
> +	}
>  
> -	page = find_get_page(swap_address_space(entry), swp_offset(entry));
> +	page = find_get_page(swapper_space, swp_offset(entry));
>  
>  	INC_CACHE_INFO(find_total);
>  	if (page) {
> @@ -676,6 +682,10 @@ struct page *swap_readahead_detect(struct vm_fault *vmf,
>  	if ((unlikely(non_swap_entry(entry))))
>  		return NULL;
>  	page = lookup_swap_cache(entry, vma, faddr);
> +	if (IS_ERR(page)) {
> +		pte_ERROR(vmf->orig_pte);
> +		page = NULL;
> +	}
>  	if (page)
>  		return page;
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
