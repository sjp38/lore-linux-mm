Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id CCB096B0005
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 08:06:41 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p63so70181532wmp.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:06:41 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id d3si39794862wja.39.2016.02.01.05.06.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 05:06:40 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id r129so69513372wmr.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:06:40 -0800 (PST)
Date: Mon, 1 Feb 2016 15:06:38 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Use linear_page_index() in do_fault()
Message-ID: <20160201130638.GB29337@node.shutemov.name>
References: <1454242401-17005-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454242401-17005-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun, Jan 31, 2016 at 11:13:21PM +1100, Matthew Wilcox wrote:
> do_fault assumes that PAGE_SIZE is the same as PAGE_CACHE_SIZE.
> Use linear_page_index() to calculate pgoff in the correct units.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

'linear' part of helper name is not relevant any more since we've dropped
non-linear mappings. Probably, we should rename helpers.

> ---
>  mm/memory.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 554816b..5224c06 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3161,8 +3161,7 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unsigned long address, pte_t *page_table, pmd_t *pmd,
>  		unsigned int flags, pte_t orig_pte)
>  {
> -	pgoff_t pgoff = (((address & PAGE_MASK)
> -			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> +	pgoff_t pgoff = linear_page_index(vma, address);
>  
>  	pte_unmap(page_table);
>  	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
> -- 
> 2.7.0.rc3
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
