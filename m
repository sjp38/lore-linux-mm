Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 079936B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:12:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h191so723094wmd.15
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:12:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor4422584edj.10.2017.10.17.04.12.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 04:12:48 -0700 (PDT)
Date: Tue, 17 Oct 2017 14:12:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
Message-ID: <20171017111246.7rhmy7klggxjozom@node.shutemov.name>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-2-git-send-email-changbin.du@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508145557-9944-2-git-send-email-changbin.du@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: changbin.du@intel.com
Cc: akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 16, 2017 at 05:19:16PM +0800, changbin.du@intel.com wrote:
> @@ -501,6 +501,45 @@ void prep_transhuge_page(struct page *page)
>  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
>  }
>  
> +struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> +		struct vm_area_struct *vma, unsigned long addr)
> +{
> +	struct page *page;
> +
> +	page = alloc_pages_vma(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
> +			       vma, addr, numa_node_id(), true);
> +	if (unlikely(!page))
> +		return NULL;
> +	prep_transhuge_page(page);
> +	return page;
> +}
> +
> +struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
> +		int preferred_nid, nodemask_t *nmask)
> +{
> +	struct page *page;
> +
> +	page = __alloc_pages_nodemask(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
> +				      preferred_nid, nmask);
> +	if (unlikely(!page))
> +		return NULL;
> +	prep_transhuge_page(page);
> +	return page;
> +}
> +
> +struct page *alloc_transhuge_page(gfp_t gfp_mask)
> +{
> +	struct page *page;
> +
> +	VM_BUG_ON(!(gfp_mask & __GFP_COMP));

Why do you check for __GFP_COMP only in this helper?

> +	page = alloc_pages(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER);

And still apply __GFP_COMP anyway?

> +	if (unlikely(!page))
> +		return NULL;
> +	prep_transhuge_page(page);
> +	return page;
> +}
> +
>  unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
>  		loff_t off, unsigned long flags, unsigned long size)
>  {

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
