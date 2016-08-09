Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7176B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:29:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so27896006wme.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:29:19 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id tj3si35513788wjb.290.2016.08.09.09.29.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 09:29:18 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id q128so4221836wma.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:29:18 -0700 (PDT)
Date: Tue, 9 Aug 2016 19:29:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] rmap: Fix compound check logic in page_remove_file_rmap
Message-ID: <20160809162915.GA10293@node.shutemov.name>
References: <1470746075-20856-1-git-send-email-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470746075-20856-1-git-send-email-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, shijie.huang@arm.com, will.deacon@arm.com, catalin.marinas@arm.com

On Tue, Aug 09, 2016 at 01:34:35PM +0100, Steve Capper wrote:
> In page_remove_file_rmap(.) we have the following check:
>   VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);
> 
> This is meant to check for either HugeTLB pages or THP when a compound
> page is passed in.
> 
> Unfortunately, if one disables CONFIG_TRANSPARENT_HUGEPAGE, then
> PageTransHuge(.) will always return false provoking BUGs when one runs
> the libhugetlbfs test suite.
> 
> Changing the definition of PageTransHuge to be defined for
> !CONFIG_TRANSPARENT_HUGEPAGE turned out to provoke build bugs; so this
> patch instead replaces the errant check with:
>   PageTransHuge(page) || PageHuge(page)

I think PageHead() check should be enough to cover this.

> 
> Fixes: dd78fedde4b9 ("rmap: support file thp")
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Steve Capper <steve.capper@arm.com>
> ---
>  mm/rmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 709bc83..ad8fc51 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1303,7 +1303,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
>  {
>  	int i, nr = 1;
>  
> -	VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);
> +	VM_BUG_ON_PAGE(compound && !(PageTransHuge(page) || PageHuge(page)), page);
>  	lock_page_memcg(page);
>  
>  	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
> -- 
> 1.8.3.1
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
