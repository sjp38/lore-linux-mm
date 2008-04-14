Date: Mon, 14 Apr 2008 09:47:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] account swapcache
Message-Id: <20080414094709.fb9c3745.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47FF57A7.5000704@mxp.nes.nec.co.jp>
References: <20080408190734.70ab55b0.kamezawa.hiroyu@jp.fujitsu.com>
	<20080408191311.73b167bb.kamezawa.hiroyu@jp.fujitsu.com>
	<47FF57A7.5000704@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Apr 2008 21:20:55 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> IMO, not charging swap caches as memory occasionally causes a problem
> that swap caches are not freed even when a process that owns
> those pages try to free them(e.g. task exit).
> 
> For example:
> 
>   Some pages are being reclaimed via memcg memory reclaim.
> 
>   Assume that shrink_page_list() has already moved those pages
>   to swap cache, unmapped them from ptes, removed from mz->lru,
>   and is working on other pages on page_list.
>   Those swap cache pages are unlocked and
>   page_count of them are 2(swap cache, isolate_page).
> 
>   At the same time on other CPU, if the process that owns those
>   pages are trying to free them, free_swap_and_cache() cannot
>   free those pages unless vm_swap_full, because find_get_pages()
>   increases page_count.
> 
> I think this rare case itself also exists on global memory reclaim,
> but global memory reclaim does not assume that those pases have
> been freed, so, if it need to free more memory, those pases
> will be freed later because they remain on global inactive list.
> 
yes.

> The problem here is that those swap cache pages are uncharged
> from memcg, so memcg can never reclaim those pages that belonged
> to the group.
> 
why "never" uncharged ? 

Assume "page" is SwapCache and unmapped and clean. 
==
 shrink_page_list()
	-> PageSwapCache() == true
	-> PageWriteback() == false
	-> PageDirty()     == false
	-> PagePrivate()   == true or false
	-> remove_mapping()
		-> page_count() == 2
		-> PageDirty()  == false
		-> PageSwapCache() == true
			-> __delete_from_swap_cache()
			-> true
	-> page will be freed
==

page shirinking can free SwapCache regardless of vm_swap_full() result.
Of course, my patch handles __delete_from_swap_cache().
 
Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
