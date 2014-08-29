Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id CEF236B0044
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:17:25 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id x13so2845405qcv.37
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:17:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s75si1352646qgs.94.2014.08.29.12.17.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 12:17:25 -0700 (PDT)
Date: Fri, 29 Aug 2014 15:17:19 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] Convert a few VM_BUG_ON callers to VM_BUG_ON_VMA
Message-ID: <20140829191719.GC12774@nhori.bos.redhat.com>
References: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
 <1409324059-28692-3-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1409324059-28692-3-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 29, 2014 at 10:54:19AM -0400, Sasha Levin wrote:
> Trivially convert a few VM_BUG_ON calls to VM_BUG_ON_VMA to extract
> more information when they trigger.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
...
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 3e8491c..5fbd0fe 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
...
> @@ -897,7 +897,7 @@ void page_move_anon_rmap(struct page *page,
>  	struct anon_vma *anon_vma = vma->anon_vma;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> -	VM_BUG_ON(!anon_vma);
> +	VM_BUG_ON_VMA(!anon_vma, vma);

>  	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);

This line contains both of vma and page.
But I'm not sure that introducing another macro like VM_BUG_ON_PAGE_AND_VMA()
is worth doing. So it's ok for me to keep it untouched.

>  
>  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> @@ -1024,7 +1024,7 @@ void do_page_add_anon_rmap(struct page *page,
>  void page_add_new_anon_rmap(struct page *page,
>  	struct vm_area_struct *vma, unsigned long address)
>  {
> -	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> +	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
>  	SetPageSwapBacked(page);
>  	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
>  	if (PageTransHuge(page))
> @@ -1666,7 +1666,7 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
>  	 * structure at mapping cannot be freed and reused yet,
>  	 * so we can safely take mapping->i_mmap_mutex.
>  	 */
> -	VM_BUG_ON(!PageLocked(page));
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);

This is not the replacement with VM_BUG_ON_VMA(), but it's fine :)

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
