Date: Fri, 1 Feb 2008 11:14:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/4] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080201104959.GJ26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0802011113390.18163@schroedinger.engr.sgi.com>
References: <20080201050439.009441434@sgi.com> <20080201050623.344041545@sgi.com>
 <20080201104959.GJ26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Argh. Did not see this soon enougn. Maybe this one is better since it 
avoids the additional unlocks?

On Fri, 1 Feb 2008, Robin Holt wrote:

> do_wp_page can reach the _end callout without passing the _begin
> callout.  This prevents making the _end unles the _begin has also
> been made.
> 
> Index: mmu_notifiers-cl-v5/mm/memory.c
> ===================================================================
> --- mmu_notifiers-cl-v5.orig/mm/memory.c	2008-02-01 04:44:03.000000000 -0600
> +++ mmu_notifiers-cl-v5/mm/memory.c	2008-02-01 04:46:18.000000000 -0600
> @@ -1564,7 +1564,7 @@ static int do_wp_page(struct mm_struct *
>  {
>  	struct page *old_page, *new_page;
>  	pte_t entry;
> -	int reuse = 0, ret = 0;
> +	int reuse = 0, ret = 0, invalidate_started = 0;
>  	int page_mkwrite = 0;
>  	struct page *dirty_page = NULL;
>  
> @@ -1649,6 +1649,8 @@ gotten:
>  
>  	mmu_notifier(invalidate_range_begin, mm, address,
>  				address + PAGE_SIZE, 0);
> +	invalidate_started = 1;
> +
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> @@ -1687,7 +1689,8 @@ gotten:
>  		page_cache_release(old_page);
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
> -	mmu_notifier(invalidate_range_end, mm,
> +	if (invalidate_started)
> +		mmu_notifier(invalidate_range_end, mm,
>  				address, address + PAGE_SIZE, 0);
>  	if (dirty_page) {
>  		if (vma->vm_file)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
