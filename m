Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f51.google.com (mail-qe0-f51.google.com [209.85.128.51])
	by kanga.kvack.org (Postfix) with ESMTP id ABF7E6B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 17:05:50 -0500 (EST)
Received: by mail-qe0-f51.google.com with SMTP id 1so2148442qee.10
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 14:05:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v3si3616775qat.133.2013.12.13.14.05.47
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 14:05:49 -0800 (PST)
Date: Fri, 13 Dec 2013 17:05:37 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386972337-x4axszvt-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386917611-11319-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386917611-11319-3-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 2/6] mm/migrate: correct failure handling if
 !hugepage_migration_support()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, Dec 13, 2013 at 03:53:27PM +0900, Joonsoo Kim wrote:
> We should remove the page from the list if we fail with ENOSYS,
> since migrate_pages() consider error cases except -ENOMEM and -EAGAIN
> as permanent failure and it assumes that the page would be removed from
> the list. Without this patch, we could overcount number of failure.
> 
> In addition, we should put back the new hugepage if
> !hugepage_migration_support(). If not, we would leak hugepage memory.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

> diff --git a/mm/migrate.c b/mm/migrate.c
> index c6ac87a..b1cfd01 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1011,7 +1011,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  {
>  	int rc = 0;
>  	int *result = NULL;
> -	struct page *new_hpage = get_new_page(hpage, private, &result);
> +	struct page *new_hpage;
>  	struct anon_vma *anon_vma = NULL;
>  
>  	/*
> @@ -1021,9 +1021,12 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	 * tables or check whether the hugepage is pmd-based or not before
>  	 * kicking migration.
>  	 */
> -	if (!hugepage_migration_support(page_hstate(hpage)))
> +	if (!hugepage_migration_support(page_hstate(hpage))) {
> +		putback_active_hugepage(hpage);
>  		return -ENOSYS;
> +	}
>  
> +	new_hpage = get_new_page(hpage, private, &result);
>  	if (!new_hpage)
>  		return -ENOMEM;
>  
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
