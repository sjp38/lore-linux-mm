Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2586B00B3
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 01:04:33 -0500 (EST)
Date: Mon, 23 Feb 2009 14:58:28 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] Reduce size of swap_cgroup by CSS ID v2
Message-Id: <20090223145828.d14ff015.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090209145557.d0754a9f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090209145557.d0754a9f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

I'm sorry for my late reply.

It looks good basically, but I have 1 comment.

>  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  {
> -	struct mem_cgroup *mem;
> +	unsigned short id;
> +	struct mem_cgroup *mem = NULL;
>  	swp_entry_t ent;
>  
>  	if (!PageSwapCache(page))
>  		return NULL;
>  
>  	ent.val = page_private(page);
> -	mem = lookup_swap_cgroup(ent);
> -	if (!mem)
> -		return NULL;
> +	id = lookup_swap_cgroup(ent);
> +	rcu_read_lock();
> +	mem = mem_cgroup_lookup(id);
>  	if (!css_tryget(&mem->css))
We should check whether "mem" is NULL or not before css_tryget, because
"mem" can be NULL(or "id" can be 0) if the page is on swapcache,
that is, remove_from_swap_cache has not been called yet.

Actually, I got NULL pointer dereference bug here.

> -		return NULL;
> +		mem = NULL;
> +	rcu_read_unlock();
>  	return mem;
>  }
>  


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
