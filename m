Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8307560021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 22:00:42 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS30efh021644
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 12:00:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F1EA845DE4F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:00:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D3C6645DE4D
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:00:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B7E6E1DB8040
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:00:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E50E1DB8044
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:00:39 +0900 (JST)
Date: Mon, 28 Dec 2009 11:57:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page
 in LRU list.
Message-Id: <20091228115727.a1730cdf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
References: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 11:53:15 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> 
> VM doesn't add zero page to LRU list. 
> It means zero page's churning in LRU list is pointless. 
> 
> As a matter of fact, zero page can't be promoted by mark_page_accessed
> since it doesn't have PG_lru. 
> 
> This patch prevent unecessary mark_page_accessed call of zero page 
> alghouth caller want FOLL_TOUCH. 
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memory.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 09e4b1b..485f727 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1152,6 +1152,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
>  	spinlock_t *ptl;
>  	struct page *page;
>  	struct mm_struct *mm = vma->vm_mm;
> +	int zero_pfn = 0;
>  
>  	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
>  	if (!IS_ERR(page)) {
> @@ -1196,15 +1197,15 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
>  
>  	page = vm_normal_page(vma, address, pte);
>  	if (unlikely(!page)) {
> -		if ((flags & FOLL_DUMP) ||
> -		    !is_zero_pfn(pte_pfn(pte)))
> +		zero_pfn = is_zero_pfn(pte_pfn(pte));
> +		if ((flags & FOLL_DUMP) || !zero_pfn )
>  			goto bad_page;
>  		page = pte_page(pte);
>  	}
>  
>  	if (flags & FOLL_GET)
>  		get_page(page);
> -	if (flags & FOLL_TOUCH) {
> +	if (flags & FOLL_TOUCH && !zero_pfn) {
>  		if ((flags & FOLL_WRITE) &&
>  		    !pte_dirty(pte) && !PageDirty(page))
>  			set_page_dirty(page);
> -- 
> 1.5.6.3
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
