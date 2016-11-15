Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE5C46B02D2
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:28:24 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so9881988wmf.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:28:24 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id w142si4719615wmw.30.2016.11.15.14.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:28:23 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id a20so4832760wme.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:28:23 -0800 (PST)
Date: Wed, 16 Nov 2016 01:28:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 11/21] mm: Remove unnecessary vma->vm_ops check
Message-ID: <20161115222819.GK23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-12-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-12-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:07AM +0100, Jan Kara wrote:
> We don't check whether vma->vm_ops is NULL in do_shared_fault() so
> there's hardly any point in checking it in wp_page_shared() or
> wp_pfn_shared() which get called only for shared file mappings as well.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Well, I'm not sure about this.

do_shared_fault() doesn't have the check since we checked it upper by
stack: see vma_is_anonymous() in handle_pte_fault().

In principal, it should be fine. But random crappy driver has potential to
blow it up.

> ---
>  mm/memory.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 7be96a43d5ac..26b2858e6a12 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2275,7 +2275,7 @@ static int wp_pfn_shared(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
>  
> -	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
> +	if (vma->vm_ops->pfn_mkwrite) {
>  		int ret;
>  
>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
> @@ -2305,7 +2305,7 @@ static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
>  
>  	get_page(old_page);
>  
> -	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
> +	if (vma->vm_ops->page_mkwrite) {
>  		int tmp;
>  
>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
> -- 
> 2.6.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
