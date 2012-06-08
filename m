Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 3BBBF6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 23:10:29 -0400 (EDT)
Received: by qafl39 with SMTP id l39so651078qaf.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 20:10:28 -0700 (PDT)
Message-ID: <4FD16D21.9000106@gmail.com>
Date: Thu, 07 Jun 2012 23:10:25 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix ununiform page status when writing new file with
 small buffer
References: <1338982770-2856-1-git-send-email-hao.bigrat@gmail.com>
In-Reply-To: <1338982770-2856-1-git-send-email-hao.bigrat@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Dong <hao.bigrat@gmail.com>
Cc: linux-mm@kvack.org, Robin Dong <sanbai@taobao.com>, kosaki.motohiro@gmail.com

(6/6/12 7:39 AM), Robin Dong wrote:
> From: Robin Dong<sanbai@taobao.com>
> 
> When writing a new file with 2048 bytes buffer, such as write(fd, buffer, 2048), it will
> call generic_perform_write() twice for every page:
> 
> 	write_begin
> 	mark_page_accessed(page)
> 	write_end
> 
> 	write_begin
> 	mark_page_accessed(page)
> 	write_end
> 
> The page 1~13th will be added to lru_add_pvecs in write_begin() and will *NOT* be added to
> active_list even they have be accessed twice because they are not PageLRU(page).
> But when page 14th comes, all pages will be moved from lru_add_pvecs to active_list
> (by __lru_cache_add() ) in first write_begin(), now page 14th *is* PageLRU(page) and after
> second write_end() it will be in active_list.
> 
> In Hadoop environment, we do comes to this situation: after writing a file, we find
> out that only 14th, 28th, 42th... page are in active_list and others in inactive_list. Now
> kswaped works, shrinks the inactive_list, the file only have 14th, 28th...pages in memory,
> the readahead request size will be broken to only 52k (13*4k), system's performance falls
> dramatically.
> 
> This problem can also replay by below steps (the machine has 8G memory):
> 
> 	1. dd if=/dev/zero of=/test/file.out bs=1024 count=1048576
> 	2. cat another 7.5G file to /dev/null
> 	3. vmtouch -m 1G -v /test/file.out, it will show:
> 
> 	/test/file.out
> 	[oooooooooooooooooooOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO] 187847/262144
> 
> 	the 'o' means same pages are in memory but same are not.
> 
> 
> The solution for this problem is simple: the 14th page should be added to lru_add_pvecs
> before mark_page_accessed() just as other pages.
> 
> Signed-off-by: Robin Dong<sanbai@taobao.com>
> ---
>   mm/swap.c |    3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 4e7e2ec..0874d44 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -399,8 +399,9 @@ void __lru_cache_add(struct page *page, enum lru_list lru)
>   	struct pagevec *pvec =&get_cpu_var(lru_add_pvecs)[lru];
> 
>   	page_cache_get(page);
> -	if (!pagevec_add(pvec, page))
> +	if (!pagevec_space(pvec))
>   		__pagevec_lru_add(pvec, lru);
> +	pagevec_add(pvec, page);
>   	put_cpu_var(lru_add_pvecs);
>   }
>   EXPORT_SYMBOL(__lru_cache_add);

Please remove pagevec completely instead of insane hacking.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
