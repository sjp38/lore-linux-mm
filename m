Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D1F386B006C
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 17:35:35 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so218664wiw.4
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 14:35:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m10si16551876wie.93.2015.01.12.14.35.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 14:35:35 -0800 (PST)
Date: Mon, 12 Jan 2015 17:35:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: provide a find_page vma operation
Message-ID: <20150112223528.GD25609@phnom.home.cmpxchg.org>
References: <1421077993-7909-1-git-send-email-david.vrabel@citrix.com>
 <1421077993-7909-2-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421077993-7909-2-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 12, 2015 at 03:53:12PM +0000, David Vrabel wrote:
> The optional find_page VMA operation is used to lookup the pages
> backing a VMA.  This is useful in cases where the normal mechanisms
> for finding the page don't work.  This is only called if the PTE is
> special.
> 
> One use case is a Xen PV guest mapping foreign pages into userspace.
> 
> In a Xen PV guest, the PTEs contain MFNs so get_user_pages() (for
> example) must do an MFN to PFN (M2P) lookup before it can get the
> page.  For foreign pages (those owned by another guest) the M2P lookup
> returns the PFN as seen by the foreign guest (which would be
> completely the wrong page for the local guest).
> 
> This cannot be fixed up improving the M2P lookup since one MFN may be
> mapped onto two or more pages so getting the right page is impossible
> given just the MFN.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Looks much better to me, thanks.

> ---
>  include/linux/mm.h |    3 +++
>  mm/memory.c        |    2 ++
>  2 files changed, 5 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80fc92a..1306643 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -290,6 +290,9 @@ struct vm_operations_struct {
>  	/* called by sys_remap_file_pages() to populate non-linear mapping */
>  	int (*remap_pages)(struct vm_area_struct *vma, unsigned long addr,
>  			   unsigned long size, pgoff_t pgoff);
> +
> +	struct page * (*find_page)(struct vm_area_struct *vma,
> +				   unsigned long addr);

Could you please add a comment what that method is used for?

It would probably also be useful if the name reflected that this only
applies to special ptes.  find_special_page()?  lookup_special_pte()?
pte_special_page()?

Thanks

> @@ -754,6 +754,8 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  	if (HAVE_PTE_SPECIAL) {
>  		if (likely(!pte_special(pte)))
>  			goto check_pfn;
> +		if (vma->vm_ops && vma->vm_ops->find_page)
> +			return vma->vm_ops->find_page(vma, addr);
>  		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
>  			return NULL;
>  		if (!is_zero_pfn(pfn))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
