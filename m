Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06EF26B004F
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:51:53 -0500 (EST)
Date: Thu, 18 Dec 2008 10:50:27 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 6/9] memcg: use css_tryget()
Message-Id: <20081218105027.2fafff27.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081216181739.60a27df3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
	<20081216181739.60a27df3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 16 Dec 2008 18:17:39 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> From:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Use css_tryget() in memcg.
> 
> css_tryget() newly is added and we can know css is alive or not and
> get refcnt of css in very safe way.
> ("alive" here means "rmdir/destroy" is not called.)
> 
> This patch replaces css_get() to css_tryget(), where I cannot explain
> why css_get() is safe. And removes memcg->obsolete flag.
> 
> Changelog (v0) -> (v1):
>   - fixed css_ref leak bug at swap-in.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

(snip)

> +/*
> + * While swap-in, try_charge -> commit or cancel, the page is locked.
> + * And when try_charge() successfully returns, one refcnt to memcg without
> + * struct page_cgroup is aquired. This refcnt will be cumsumed by
> + * "commit()" or removed by "cancel()"
> + */
>  int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  				 struct page *page,
>  				 gfp_t mask, struct mem_cgroup **ptr)
>  {
>  	struct mem_cgroup *mem;
>  	swp_entry_t     ent;
> +	int ret;
>  
>  	if (mem_cgroup_disabled())
>  		return 0;
> @@ -1089,10 +1115,15 @@ int mem_cgroup_try_charge_swapin(struct 
>  	ent.val = page_private(page);
>  
>  	mem = lookup_swap_cgroup(ent);
> -	if (!mem || mem->obsolete)
> +	if (!mem)
> +		goto charge_cur_mm;
> +	if (!css_tryget(&mem->css))
>  		goto charge_cur_mm;
I haven't noticed the bug here which existed in RFC version.

Actually, I found a problem at rmdir(cannot remove directry because of refcnt leak)
in testing RFC version, and have been digging it.
I've confirmed it is fixed in this version.

This version looks good to me and I think this patch is definitely needed
to remove buggy "obsolete" flag.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
