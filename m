Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8287C6B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 09:16:51 -0400 (EDT)
Message-ID: <4C4844BC.4090709@redhat.com>
Date: Thu, 22 Jul 2010 09:16:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] Fix false positive BUG_ON in __page_set_anon_rmap
References: <20100722164118.d500b850.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100722164118.d500b850.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 07/22/2010 03:41 AM, KAMEZAWA Hiroyuki wrote:
> Rik, how do you think ?
>
> ==
> From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> Problem: wrong BUG_ON() in  __page_set_anon_rmap().
> Kernel version: mmotm-0719

> Description:
>    Even if SwapCache is fully unmapped and mapcount goes down to 0,
>    page->mapping is not cleared and will remain on memory until kswapd or some
>    finds it. If a thread cause a page fault onto such "unmapped-but-not-discarded"
>    swapcache, it will see a swap cache whose mapcount is 0 but page->mapping has a
>    valid value.
>
>    When it's reused at do_swap_page(), __page_set_anon_rmap() is called with
>    "exclusive==1" and hits BUG_ON(). But this BUG_ON() is wrong. Nothing bad
>    with rmapping a page which has page->mapping isn't 0.

Yes, you are absolutely right.

Acked-by: Rik van Riel <riel@redhat.com>

> Index: mmotm-2.6.35-0719/mm/rmap.c
> ===================================================================
> --- mmotm-2.6.35-0719.orig/mm/rmap.c
> +++ mmotm-2.6.35-0719/mm/rmap.c
> @@ -783,8 +783,16 @@ static void __page_set_anon_rmap(struct
>   		if (PageAnon(page))
>   			return;
>   		anon_vma = anon_vma->root;
> -	} else
> -		BUG_ON(PageAnon(page));
> +	} else {
> +		/*
> + 		 * In this case, swapped-out-but-not-discarded swap-cache
> + 		 * is remapped. So, no need to update page->mapping here.
> + 		 * We convice anon_vma poitned by page->mapping is not obsolete
> + 		 * because vma->anon_vma is necessary to be a family of it.
> + 		 */
> +		if (PageAnon(page))
> +			return;
> +	}
>
>   	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
>   	page->mapping = (struct address_space *) anon_vma;
>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
