Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 8F1F46B0114
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:46:14 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so64586qcs.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:46:13 -0700 (PDT)
Message-ID: <4FD5CC71.4060002@gmail.com>
Date: Mon, 11 Jun 2012 06:46:09 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: fix ununiform page status when writing new file
 with small buffer
References: <1339411335-23326-1-git-send-email-hao.bigrat@gmail.com>
In-Reply-To: <1339411335-23326-1-git-send-email-hao.bigrat@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Dong <hao.bigrat@gmail.com>
Cc: linux-mm@kvack.org, Robin Dong <sanbai@taobao.com>, kosaki.motohiro@gmail.com

(6/11/12 6:42 AM), Robin Dong wrote:
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
> The page 1~13th will be added to lru-pvecs in write_begin() and will *NOT* be added to
> active_list even they have be accessed twice because they are not PageLRU(page).
> But when page 14th comes, all pages in lru-pvecs will be moved to inactive_list
> (by __lru_cache_add() ) in first write_begin(), now page 14th *is* PageLRU(page).
> And after second write_end() only page 14th  will be in active_list.
> 
> In Hadoop environment, we do comes to this situation: after writing a file, we find
> out that only 14th, 28th, 42th... page are in active_list and others in inactive_list. Now
> kswapd works, shrinks the inactive_list, the file only have 14th, 28th...pages in memory,
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
> Reviewed-by: Minchan Kim<minchan@kernel.org>
> ---
>   mm/swap.c |    8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 4e7e2ec..08e83ad 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -394,13 +394,19 @@ void mark_page_accessed(struct page *page)
>   }
>   EXPORT_SYMBOL(mark_page_accessed);
> 
> +/*
> + * Check pagevec space before adding new page into as
> + * it will prevent ununiform page status in
> + * mark_page_accessed() after __lru_cache_add()
> + */
>   void __lru_cache_add(struct page *page, enum lru_list lru)
>   {
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

No change from v1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
