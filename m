Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E3F476B0044
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:26:42 -0500 (EST)
Date: Tue, 20 Jan 2009 07:26:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: NULL pointer dereference at rmdir on some NUMA systems
In-Reply-To: <20090119185514.f3681783.kamezawa.hiroyu@jp.fujitsu.com>
References: <49744499.2040101@cn.fujitsu.com> <20090119185514.f3681783.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090121072510.B0B8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> On NUMA, N_POSSIBLE doesn't means there is memory...and force_empty can
> visit invalud node which have no pgdat.
        invalid?


> This happens on some NUMA systems which defines memory-less-node, node-hotplug.
> 
> Note: memcg's its own controll structs are allocated against all POSSIBLE nodes.
> 
> To visit all valid pgdat, N_HIGH_MEMRY should be used.
> 
> Reporetd-by: Li Zefan <lizf@cn.fujitsu.com>
> Tested-by: Li Zefan <lizf@cn.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
> +++ mmotm-2.6.29-Jan16/mm/memcontrol.c
> @@ -1724,7 +1724,7 @@ move_account:
>  		/* This is for making all *used* pages to be on LRU. */
>  		lru_add_drain_all();
>  		ret = 0;
> -		for_each_node_state(node, N_POSSIBLE) {
> +		for_each_node_state(node, N_HIGH_MEMORY) {
>  			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
>  				enum lru_list l;
>  				for_each_lru(l) {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
