Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 306FE6B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 20:12:09 -0400 (EDT)
Date: Wed, 10 Jun 2009 08:58:58 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: fix mem_cgroup_isolate_lru_page to use the same
 rotate logic at busy path
Message-Id: <20090610085858.fd3a60ed.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090609182253.009c98a3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
	<20090609182253.009c98a3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jun 2009 18:22:53 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch tries to fix memcg's lru rotation sanity...make memcg use
> the same logic as global LRU does.
> 
> Now, at __isolate_lru_page() retruns -EBUSY, the page is rotated to
> the tail of LRU in global LRU's isolate LRU pages. But in memcg,
> it's not handled. This makes memcg do the same behavior as global LRU
> and rotate LRU in the page is busy.
> 
> Note: __isolate_lru_page() is not isolate_lru_page() and it's just used
> in sc->isolate_pages() logic.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
Looks good to me.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

> ---
>  mm/memcontrol.c |   13 ++++++++++++-
>  mm/vmscan.c     |    4 +++-
>  2 files changed, 15 insertions(+), 2 deletions(-)
> 
> Index: mmotm-2.6.30-Jun4/mm/vmscan.c
> ===================================================================
> --- mmotm-2.6.30-Jun4.orig/mm/vmscan.c
> +++ mmotm-2.6.30-Jun4/mm/vmscan.c
> @@ -842,7 +842,6 @@ int __isolate_lru_page(struct page *page
>  		 */
>  		ClearPageLRU(page);
>  		ret = 0;
> -		mem_cgroup_del_lru(page);
>  	}
>  
>  	return ret;
> @@ -890,12 +889,14 @@ static unsigned long isolate_lru_pages(u
>  		switch (__isolate_lru_page(page, mode, file)) {
>  		case 0:
>  			list_move(&page->lru, dst);
> +			mem_cgroup_del_lru(page);
>  			nr_taken++;
>  			break;
>  
>  		case -EBUSY:
>  			/* else it is being freed elsewhere */
>  			list_move(&page->lru, src);
> +			mem_cgroup_rotate_lru_list(page, page_lru(page));
>  			continue;
>  
>  		default:
> @@ -937,6 +938,7 @@ static unsigned long isolate_lru_pages(u
>  			switch (__isolate_lru_page(cursor_page, mode, file)) {
>  			case 0:
>  				list_move(&cursor_page->lru, dst);
> +				mem_cgroup_del_lru(page);
>  				nr_taken++;
>  				scan++;
>  				break;
> Index: mmotm-2.6.30-Jun4/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.30-Jun4.orig/mm/memcontrol.c
> +++ mmotm-2.6.30-Jun4/mm/memcontrol.c
> @@ -649,6 +649,7 @@ unsigned long mem_cgroup_isolate_pages(u
>  	int zid = zone_idx(z);
>  	struct mem_cgroup_per_zone *mz;
>  	int lru = LRU_FILE * !!file + !!active;
> +	int ret;
>  
>  	BUG_ON(!mem_cont);
>  	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
> @@ -666,9 +667,19 @@ unsigned long mem_cgroup_isolate_pages(u
>  			continue;
>  
>  		scan++;
> -		if (__isolate_lru_page(page, mode, file) == 0) {
> +		ret = __isolate_lru_page(page, mode, file);
> +		switch (ret) {
> +		case 0:
>  			list_move(&page->lru, dst);
> +			mem_cgroup_del_lru(page);
>  			nr_taken++;
> +			break;
> +		case -EBUSY:
> +			/* we don't affect global LRU but rotate in our LRU */
> +			mem_cgroup_rotate_lru_list(page, page_lru(page));
> +			break;
> +		default:
> +			break;
>  		}
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
