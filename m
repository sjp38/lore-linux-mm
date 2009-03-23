Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 579426B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:11:50 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N04vqb015510
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 09:04:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F72545DD72
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:04:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D2DF45DE4F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:04:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E28C1DB8038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:04:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CF3F21DB803F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:04:56 +0900 (JST)
Date: Mon, 23 Mar 2009 09:03:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH mmotm] memcg: try_get_mem_cgroup_from_swapcache
 fix
Message-Id: <20090323090331.74f085f5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323000238.e650c65e.d-nishimura@mtf.biglobe.ne.jp>
References: <20090323000238.e650c65e.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 00:02:38 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> css_tryget can be called twice in !PageCgroupUsed case.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thank you
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtsu.com>

> ---
> This is a fix for cgroups-use-css-id-in-swap-cgroup-for-saving-memory-v5.patch
> 
>  mm/memcontrol.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5de6be9..55dea59 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1027,9 +1027,11 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  	/*
>  	 * Used bit of swapcache is solid under page lock.
>  	 */
> -	if (PageCgroupUsed(pc))
> +	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
> -	else {
> +		if (mem && !css_tryget(&mem->css))
> +			mem = NULL;
> +	} else {
>  		ent.val = page_private(page);
>  		id = lookup_swap_cgroup(ent);
>  		rcu_read_lock();
> @@ -1038,10 +1040,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  			mem = NULL;
>  		rcu_read_unlock();
>  	}
> -	if (!mem)
> -		return NULL;
> -	if (!css_tryget(&mem->css))
> -		return NULL;
>  	return mem;
>  }
>  
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
