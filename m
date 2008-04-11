Message-Id: <47FF57A7.5000704@mxp.nes.nec.co.jp>
Date: Fri, 11 Apr 2008 21:20:55 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/3] account swapcache
References: <20080408190734.70ab55b0.kamezawa.hiroyu@jp.fujitsu.com> <20080408191311.73b167bb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080408191311.73b167bb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Hi, KAMEZAWA-san.

KAMEZAWA Hiroyuki wrote:
> Now swapcache is not accounted. (because it had some troubles.)
> 
> This is retrying account swap cache, based on remove-refcnt patch.
> 
> This does.
>  * When a page is swap-cache,  mem_cgroup_uncharge_page() will *not*
>    uncharge page even if page->mapcount == 0.
>  * When a page is removed from swap-cache, mem_cgroup_uncharge_page()
>    is called again.
>  * A swapcache page is newly charged only when it's mapped.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

I agree with the idea that swap caches should be charged as memory.
(I think they may be charged as swap at the same time.)

IMO, not charging swap caches as memory occasionally causes a problem
that swap caches are not freed even when a process that owns
those pages try to free them(e.g. task exit).

For example:

  Some pages are being reclaimed via memcg memory reclaim.

  Assume that shrink_page_list() has already moved those pages
  to swap cache, unmapped them from ptes, removed from mz->lru,
  and is working on other pages on page_list.
  Those swap cache pages are unlocked and
  page_count of them are 2(swap cache, isolate_page).

  At the same time on other CPU, if the process that owns those
  pages are trying to free them, free_swap_and_cache() cannot
  free those pages unless vm_swap_full, because find_get_pages()
  increases page_count.

I think this rare case itself also exists on global memory reclaim,
but global memory reclaim does not assume that those pases have
been freed, so, if it need to free more memory, those pases
will be freed later because they remain on global inactive list.

The problem here is that those swap cache pages are uncharged
from memcg, so memcg can never reclaim those pages that belonged
to the group.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
