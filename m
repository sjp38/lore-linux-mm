Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D400B6B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 23:27:27 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0E4RPHj009999
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Jan 2009 13:27:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 52E592AEA81
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 13:27:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2832A1EF081
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 13:27:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 076CD1DB803C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 13:27:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8315E1DB805D
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 13:27:21 +0900 (JST)
Date: Wed, 14 Jan 2009 13:26:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: fix a race when setting memcg.swappiness
Message-Id: <20090114132616.3cb7d568.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <496D5AE2.2020403@cn.fujitsu.com>
References: <496D5AE2.2020403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jan 2009 11:24:18 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> (suppose: memcg->use_hierarchy == 0 and memcg->swappiness == 60)
> 
> echo 10 > /memcg/0/swappiness   |
>   mem_cgroup_swappiness_write() |
>     ...                         | echo 1 > /memcg/0/use_hierarchy
>                                 | mkdir /mnt/0/1
>                                 |   sub_memcg->swappiness = 60;
>     memcg->swappiness = 10;     |
> 
> In the above scenario, we end up having 2 different swappiness
> values in a single hierarchy.
> 
> Note we can't use hierarchy_lock here, because it doesn't protect
> the create() method.
> 
> Though IMO use cgroup_lock() in simple write functions is OK,
> Paul would like to avoid it. And he sugguested use a counter to
> count the number of children instead of check cgrp->children list:
> 
> =================
> create() does:
> 
> lock memcg_parent
> memcg->swappiness = memcg->parent->swappiness;
> memcg_parent->child_count++;
> unlock memcg_parent
> 
> and write() does:
> 
> lock memcg
> if (!memcg->child_count) {
>   memcg->swappiness = swappiness;
> } else {
>   report error;
> }
> unlock memcg
> 
> destroy() does:
> lock memcg_parent
> memcg_parent->child_count--;
> unlock memcg_parent
> 
> =================
> 
> And there is a suble differnce with checking cgrp->children,
> that a cgroup is removed from parent's list in cgroup_rmdir(),
> while memcg->child_count is decremented in cgroup_diput().
> 
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Seems reasonable, but, hmm...

Why hierarchy_mutex can't be used for create() ?

-Kame

> ---
>  mm/memcontrol.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2996b8..0274223 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1971,6 +1971,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
>  	struct mem_cgroup *parent;
> +
>  	if (val > 100)
>  		return -EINVAL;
>  
> @@ -1978,15 +1979,22 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  		return -EINVAL;
>  
>  	parent = mem_cgroup_from_cont(cgrp->parent);
> +
> +	cgroup_lock();
> +
>  	/* If under hierarchy, only empty-root can set this value */
>  	if ((parent->use_hierarchy) ||
> -	    (memcg->use_hierarchy && !list_empty(&cgrp->children)))
> +	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> +		cgroup_unlock();
>  		return -EINVAL;
> +	}
>  
>  	spin_lock(&memcg->reclaim_param_lock);
>  	memcg->swappiness = val;
>  	spin_unlock(&memcg->reclaim_param_lock);
>  
> +	cgroup_unlock();
> +
>  	return 0;
>  }
>  
> -- 
> 1.5.4.rc3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
