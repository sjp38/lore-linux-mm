Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 581AE6B007B
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 22:57:43 -0400 (EDT)
Message-ID: <4FD55EA4.1070806@kernel.org>
Date: Mon, 11 Jun 2012 11:57:40 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix ununiform page status when writing new file with
 small buffer
References: <1338982770-2856-1-git-send-email-hao.bigrat@gmail.com>
In-Reply-To: <1338982770-2856-1-git-send-email-hao.bigrat@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Dong <hao.bigrat@gmail.com>
Cc: linux-mm@kvack.org, Robin Dong <sanbai@taobao.com>

On 06/06/2012 08:39 PM, Robin Dong wrote:

> From: Robin Dong <sanbai@taobao.com>
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
                                                                          ^^^^
                                                                          inactive list

> (by __lru_cache_add() ) in first write_begin(), now page 14th *is* PageLRU(page) and after
> second write_end() it will be in active_list.

> 
> In Hadoop environment, we do comes to this situation: after writing a file, we find
> out that only 14th, 28th, 42th... page are in active_list and others in inactive_list. Now
> kswaped works, shrinks the inactive_list, the file only have 14th, 28th...pages in memory,

   ^^^^^
  kswapd

> the readahead request size will be broken to only 52k (13*4k), system's performance falls
> dramatically.


Good catch!

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
> Signed-off-by: Robin Dong <sanbai@taobao.com>


Reviewed-by: Minchan Kim <minchan@kernel.org>

Nitpick:
Please comment in function as well as description.
It will prevent some guy restore original code for the consistency with other pagevec_add call sites.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
