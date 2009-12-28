Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0110E60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 23:51:04 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS4p2sm032693
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 13:51:02 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B58945DE61
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:51:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4348F45DE5D
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:51:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 18CD91DB803B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:51:02 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C81DF1DB803C
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:51:01 +0900 (JST)
Date: Mon, 28 Dec 2009 13:47:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Fix wrong rss count of smaps
Message-Id: <20091228134752.44d13c34.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091228134619.92ba28f6.minchan.kim@barrios-desktop>
References: <20091228134619.92ba28f6.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 13:46:19 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> 
> I am not sure we have to account zero page with file_rss. 
> Hugh and Kame's new zero page doesn't do it. 
> As side effect of this, we can prevent innocent process which have a lot
> of zero page when OOM happens. 
> (But I am not sure there is a process like this :)
> So I think not file_rss counting is not bad. 
> 
> RSS counting zero page with file_rss helps any program using smaps?
> If we have to keep the old behavior, I have to remake this patch. 
> 
> == CUT_HERE ==
> 
> Long time ago, We regards zero page as file_rss and
> vm_normal_page doesn't return NULL.
> 
> But now, we reinstated ZERO_PAGE and vm_normal_page's implementation
> can return NULL in case of zero page. Also we don't count it with
> file_rss any more.
> 
> Then, RSS and PSS can't be matched.
> For consistency, Let's ignore zero page in smaps_pte_range.
> 
> CC: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, how about counting ZERO page in smaps ? Ignoring them completely sounds
not very good.

Thanks,
-Kame

> ---
>  fs/proc/task_mmu.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 47c03f4..f277c4a 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -361,12 +361,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  		if (!pte_present(ptent))
>  			continue;
>  
> -		mss->resident += PAGE_SIZE;
> -
>  		page = vm_normal_page(vma, addr, ptent);
>  		if (!page)
>  			continue;
>  
> +		mss->resident += PAGE_SIZE;
>  		/* Accumulate the size in pages that have been accessed. */
>  		if (pte_young(ptent) || PageReferenced(page))
>  			mss->referenced += PAGE_SIZE;
> -- 
> 1.5.6.3
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
