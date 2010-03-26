Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D7AF16B01AC
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 21:02:16 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2Q12D0F008735
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 26 Mar 2010 10:02:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DC9B45DE53
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 10:02:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5367A45DE51
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 10:02:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3828EE18003
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 10:02:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BF2641DB803C
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 10:02:12 +0900 (JST)
Date: Fri, 26 Mar 2010 09:58:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
Message-Id: <20100326095825.69fd63a9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1269530941.1814.21.camel@barrios-desktop>
References: <20100325092131.GK2024@csn.ul.ie>
	<20100325184123.e3e3b009.kamezawa.hiroyu@jp.fujitsu.com>
	<20100325185200.6C8C.A69D9226@jp.fujitsu.com>
	<20100325191229.8e3d2ba1.kamezawa.hiroyu@jp.fujitsu.com>
	<1269530941.1814.21.camel@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Mar 2010 00:29:01 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Kame. 
<snip>

> Which case do we have PageAnon && (page_mapcount == 0) && PageSwapCache ?
> With looking over code which add_to_swap_cache, I found somewhere. 
> 
> 1) shrink_page_list
> I think this case doesn't matter by isolate_lru_xxx.
> 
> 2) shmem_swapin
> It seems to be !PageAnon
> 
> 3) shmem_writepage
> It seems to be !PageAnon. 
> 
> 4) do_swap_page
> page_add_anon_rmap increases _mapcount before setting page->mapping to anon_vma. 
> So It doesn't matter. 

> 
> 
> I think following codes in unmap_and_move seems to handle 3) case. 
> 
> ---
>          * Corner case handling:
>          * 1. When a new swap-cache page is read into, it is added to the LRU
>          * and treated as swapcache but it has no rmap yet.
>         ...
>         if (!page->mapping) {
>                 if (!PageAnon(page) && page_has_private(page)) {
>                 ....
>                 }    
>                 goto skip_unmap;
>         }    
> 
> ---
> 
> Do we really check PageSwapCache in there?
> Do I miss any case?
> 

When a page is fully unmapped, page->mapping is not cleared.

from rmap.c
==
 734 void page_remove_rmap(struct page *page)
 735 {
	....
 758         /*
 759          * It would be tidy to reset the PageAnon mapping here,
 760          * but that might overwrite a racing page_add_anon_rmap
 761          * which increments mapcount after us but sets mapping
 762          * before us: so leave the reset to free_hot_cold_page,
 763          * and remember that it's only reliable while mapped.
 764          * Leaving it set also helps swapoff to reinstate ptes
 765          * faster for those pages still in swapcache.
 766          */
 767 }
==

What happens at memory reclaim is...

	the first vmscan
	1. isolate a page from LRU.
	2. add_to_swap_cache it.
	3. try_to_unmap it
	4. pageout it (PG_reclaim && PG_writeback)
	5. move page to the tail of LRU.
	.....<after some time>
	6. I/O ends and PG_writeback is cleared.

Here, in above cycle, the page is not freed. Still in LRU list.
	next vmscan
	7. isolate a page from LRU.
	8. finds a unmapped clean SwapCache
	9. drop it.

So, to _free_ unmapped SwapCache, sequence 7-9 should happen.
If enough memory is freed by the first itelation of vmscan before I/O end,
next vmscan doesn't happen. Then, we have "unmmaped clean Swapcache which has
anon_vma pointer on page->mapping" on LRU.

Thanks,
-Kame


	



	


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
