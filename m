Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 91E4B6B005A
	for <linux-mm@kvack.org>; Sat, 15 Feb 2014 23:00:55 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so13475962pdj.40
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 20:00:55 -0800 (PST)
Received: from mail-pb0-x236.google.com (mail-pb0-x236.google.com [2607:f8b0:400e:c01::236])
        by mx.google.com with ESMTPS id vb2si10600796pbc.217.2014.02.15.20.00.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Feb 2014 20:00:54 -0800 (PST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so13890804pbc.41
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 20:00:53 -0800 (PST)
Date: Sat, 15 Feb 2014 20:00:03 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] mm/vmscan: remove two un-needed mem_cgroup_page_lruvec()
 call
In-Reply-To: <000001cf2ac7$9abf23b0$d03d6b10$%yang@samsung.com>
Message-ID: <alpine.LSU.2.11.1402151953180.10073@eggly.anvils>
References: <000001cf2ac7$9abf23b0$d03d6b10$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: riel@redhat.com, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, weijie.yang.kh@gmail.com, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sun, 16 Feb 2014, Weijie Yang wrote:

> In putback_inactive_pages() and move_active_pages_to_lru(),
> lruvec is already an input parameter and pages are all from this lruvec,
> therefore there is no need to call mem_cgroup_page_lruvec() in loop.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Looks plausible but I believe it's incorrect.  The lruvec passed in
is the one we took the pages from, but there's a small but real chance
that the page has become uncharged meanwhile, and should now be put back
on the root_mem_cgroup's lruvec instead of the original memcg's lruvec.

Hugh

> ---
>  mm/vmscan.c |    3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a9c74b4..4804fdb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1393,8 +1393,6 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>  			continue;
>  		}
>  
> -		lruvec = mem_cgroup_page_lruvec(page, zone);
> -
>  		SetPageLRU(page);
>  		lru = page_lru(page);
>  		add_page_to_lru_list(page, lruvec, lru);
> @@ -1602,7 +1600,6 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>  
>  	while (!list_empty(list)) {
>  		page = lru_to_page(list);
> -		lruvec = mem_cgroup_page_lruvec(page, zone);
>  
>  		VM_BUG_ON_PAGE(PageLRU(page), page);
>  		SetPageLRU(page);
> -- 
> 1.7.10.4
> 
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
