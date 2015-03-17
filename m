Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A04B66B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 22:08:45 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so82355769pab.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 19:08:45 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id rb6si25981559pab.79.2015.03.16.19.08.43
        for <linux-mm@kvack.org>;
        Mon, 16 Mar 2015 19:08:44 -0700 (PDT)
Date: Tue, 17 Mar 2015 11:08:46 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/page_alloc: Call kernel_map_pages in
 unset_migrateype_isolate
Message-ID: <20150317020846.GD19483@js1304-P5Q-DELUXE>
References: <1426530585-11367-1-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426530585-11367-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Mon, Mar 16, 2015 at 11:29:45AM -0700, Laura Abbott wrote:
> Commit 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated pageblock")
> changed the logic of unset_migratetype_isolate to check the buddy allocator
> and explicitly call __free_pages to merge. The page that is being freed in
> this path never had prep_new_page called so set_page_refcounted is called
> explicitly but there is no call to kernel_map_pages. With the default
> kernel_map_pages this is mostly harmless but if kernel_map_pages does any
> manipulation of the page tables (unmapping or setting pages to read only) this
> may trigger a fault:
> 
>     alloc_contig_range test_pages_isolated(ceb00, ced00) failed
>     Unable to handle kernel paging request at virtual address ffffffc0cec00000
>     pgd = ffffffc045fc4000
>     [ffffffc0cec00000] *pgd=0000000000000000
>     Internal error: Oops: 9600004f [#1] PREEMPT SMP
>     Modules linked in: exfatfs
>     CPU: 1 PID: 23237 Comm: TimedEventQueue Not tainted 3.10.49-gc72ad36-dirty #1
>     task: ffffffc03de52100 ti: ffffffc015388000 task.ti: ffffffc015388000
>     PC is at memset+0xc8/0x1c0
>     LR is at kernel_map_pages+0x1ec/0x244
> 
> Fix this by calling kernel_map_pages to ensure the page is set in the
> page table properly
> 
> Fixes: 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated pageblock")
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Xishi Qiu <qiuxishi@huawei.com>
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Gioh Kim <gioh.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
> Note this was found on a backport to 3.10 and the code to make kernel_map_pages
> change the page table state is currently out of tree. The original had stable,
> so this may need to go into stable as well.

I found that some implementation of kernel_map_pages() in mainline also require
this change. Some implementation doesn't check previous state of page table, but
some others check previous state of page table when calling kernel_map_pages().

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

> ---
>  mm/page_isolation.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 72f5ac3..755a42c 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -103,6 +103,7 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  
>  			if (!is_migrate_isolate_page(buddy)) {
>  				__isolate_free_page(page, order);
> +				kernel_map_pages(page, (1 << order), 1);
>  				set_page_refcounted(page);
>  				isolated_page = page;
>  			}
> -- 
> Qualcomm Innovation Center, Inc.
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
> This e-mail address will be inactive after March 20, 2015
> Please contact privately for follow up after that date.
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
