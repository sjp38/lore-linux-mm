Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3A4585F0001
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 02:18:46 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3I6J040021636
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 18 Apr 2009 15:19:01 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BF9F845DE53
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:19:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A76B45DE4F
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:19:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C52C1DB803F
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:19:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 380B61DB8038
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:19:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my case?
In-Reply-To: <49E8292D.7050904@gmail.com>
References: <49E8292D.7050904@gmail.com>
Message-Id: <20090418151620.1258.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 18 Apr 2009 15:18:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> "
> +/**
> + * get_user_pages_fast() - pin user pages in memory
> + * @start:     starting user address
> + * @nr_pages:  number of pages from start to pin
> + * @write:     whether pages will be written to
> + * @pages:     array that receives pointers to the pages pinned.
> + *             Should be at least nr_pages long.
> "
> 
>    But after I digged the code of kswap and the get_user_pages(called by 
> get_user_pages_fast),
> I did not find how the pages pinned in memory.I really need the pages 
> pinned in memory.
> 
>    Assume page A is one of the pages obtained by get_user_pages_fast() 
> during page-fault.
> 
> [1] page A will on the LRU_ACTIVE_ANON list;
>    the _count of page A increment by one;
>    PTE for page A will be set ACCESSED.
> 
> [2] kswapd will scan the lru list,and move page A from LRU_ACTIVE_ANON  
> to LRU_INACTIVE_ANON.
>    In the shrink_page_list(), there is nothing can stop page A been 
> swapped out.
>    I don't think the page_reference() can move page A back to 
> LRU_ACTIVE_ANON.In my driver,
>    I am not sure if the VLC can access the page A.
> 
>    Is this a bug? or I miss something?
>    Thanks .

BUG.

We are talking about it just now.

see the following thread in lkml
	"[RFC][PATCH 0/6] IO pinning(get_user_pages()) vs fork race fix"


but unfortunately, we don't have no painful fix. perhaps you need change
your code...





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
