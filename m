Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D55C760021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 05:25:42 -0500 (EST)
Received: by yxe10 with SMTP id 10so5544269yxe.12
        for <linux-mm@kvack.org>; Mon, 28 Dec 2009 02:25:40 -0800 (PST)
Message-ID: <4B38879E.3060205@gmail.com>
Date: Mon, 28 Dec 2009 19:25:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3 -mmotm-2009-12-10-17-19] Fix wrong rss counting of
 smap
References: <ceeec51bdc2be64416e05ca16da52a126b598e17.1258773030.git.minchan.kim@gmail.com> <ae2928fe7bb3d94a7ca18d3b3274fdfeb009803a.1258773030.git.minchan.kim@gmail.com> <ff0a209159ef985681ae071d770edd9b9cd0ecf0.1258773030.git.minchan.kim@gmail.com>
In-Reply-To: <ff0a209159ef985681ae071d770edd9b9cd0ecf0.1258773030.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

I missed Hugn and Matt. 

Minchan Kim wrote:
> After return zero_page, vm_normal_page can return
> NULL if the page is zero page.
> 
> In such case, RSS and PSS can be mismatched.
> This patch fixes it.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  fs/proc/task_mmu.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 47c03f4..1a47be9 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -361,12 +361,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  		if (!pte_present(ptent))
>  			continue;
>  
> -		mss->resident += PAGE_SIZE;
> -
>  		page = vm_normal_page(vma, addr, ptent);
> -		if (!page)
> +		if (!page && !is_zero_pfn(pte_pfn(ptent)))
>  			continue;
>  
> +		mss->resident += PAGE_SIZE;
>  		/* Accumulate the size in pages that have been accessed. */
>  		if (pte_young(ptent) || PageReferenced(page))
>  			mss->referenced += PAGE_SIZE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
