Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B5E436B004D
	for <linux-mm@kvack.org>; Sun, 26 Apr 2009 21:15:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3R1FqmA013300
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Apr 2009 10:15:53 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C9E1845DD7D
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:15:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ABE6445DD7B
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:15:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ECBB1DB803B
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:15:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 402661DB8037
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:15:52 +0900 (JST)
Date: Mon, 27 Apr 2009 10:14:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix try_get_mem_cgroup_from_swapcache()
Message-Id: <20090427101419.465467f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090427095100.29173bc1.nishimura@mxp.nes.nec.co.jp>
References: <20090426231752.36498c90.d-nishimura@mtf.biglobe.ne.jp>
	<20090427095100.29173bc1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 09:51:00 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> memcg: fix try_get_mem_cgroup_from_swapcache()
> 
> This is a bugfix for commit 3c776e64660028236313f0e54f3a9945764422df(included 2.6.30-rc1).
> Used bit of swapcache is solid under page lock, but considering move_account,
> pc->mem_cgroup is not.
> 
> We need lock_page_cgroup() anyway.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

you are right.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memcontrol.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ccc69b4..84f856c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1024,9 +1024,7 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  		return NULL;
>  
>  	pc = lookup_page_cgroup(page);
> -	/*
> -	 * Used bit of swapcache is solid under page lock.
> -	 */
> +	lock_page_cgroup(pc);
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		if (mem && !css_tryget(&mem->css))
> @@ -1040,6 +1038,7 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  			mem = NULL;
>  		rcu_read_unlock();
>  	}
> +	unlock_page_cgroup(pc);
>  	return mem;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
