Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A16AD6B4898
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 10:08:55 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id o10-v6so23779203plk.16
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 07:08:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m198si3972116pga.98.2018.11.27.07.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Nov 2018 07:08:54 -0800 (PST)
Date: Tue, 27 Nov 2018 07:08:52 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: fix insert_pfn() return value
Message-ID: <20181127150852.GA10377@bombadil.infradead.org>
References: <20181127144351.9137-1-mans@mansr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127144351.9137-1-mans@mansr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mans Rullgard <mans@mansr.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 27, 2018 at 02:43:51PM +0000, Mans Rullgard wrote:
> Commit 9b5a8e00d479 ("mm: convert insert_pfn() to vm_fault_t") accidentally
> made insert_pfn() always return an error.  Fix this.

Umm.  VM_FAULT_NOPAGE is not an error.  It's saying "I inserted the PFN,
there's no struct page for the core VM to do anything with".  Which is
the correct response from a device driver which has called insert_pfn().

Could you explain a bit more what led you to think there's a problem here?

Also, rather rude of you not to cc the patch author when you claim to
be fixing a bug in their patch.

> Fixes: 9b5a8e00d479 ("mm: convert insert_pfn() to vm_fault_t")
> Signed-off-by: Mans Rullgard <mans@mansr.com>
> ---
>  mm/memory.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 4ad2d293ddc2..15baf50e3908 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1524,12 +1524,14 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  			pfn_t pfn, pgprot_t prot, bool mkwrite)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> +	int retval;
>  	pte_t *pte, entry;
>  	spinlock_t *ptl;
>  
>  	pte = get_locked_pte(mm, addr, &ptl);
>  	if (!pte)
>  		return VM_FAULT_OOM;
> +	retval = VM_FAULT_NOPAGE;
>  	if (!pte_none(*pte)) {
>  		if (mkwrite) {
>  			/*
> @@ -1567,9 +1569,10 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  	set_pte_at(mm, addr, pte, entry);
>  	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
>  
> +	retval = 0;
>  out_unlock:
>  	pte_unmap_unlock(pte, ptl);
> -	return VM_FAULT_NOPAGE;
> +	return retval;
>  }
>  
>  /**
> -- 
> 2.19.2
> 
