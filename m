Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 505646B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 03:22:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0E8Mlck009597
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Jan 2009 17:22:47 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59D7D45DD83
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 17:22:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2884445DD7E
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 17:22:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A21621DB8037
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 17:22:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CE7F1DB804B
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 17:22:42 +0900 (JST)
Date: Wed, 14 Jan 2009 17:21:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix return value of mem_cgroup_hierarchy_write()
Message-Id: <20090114172138.d73a8be8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <496D9E0C.4060806@cn.fujitsu.com>
References: <496D9E0C.4060806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jan 2009 16:10:52 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> When there are sub-dirs, writing to memory.use_hierarchy returns -EBUSY,
> this doesn't seem to fit the meaning of EBUSY, and is inconsistent with
> memory.swappiness, which returns -EINVAL in this case.
> 

Hmm...I'm not sure what error code is the best.

In usual, -EINVAL means parameter to write() is bad. In this case, it isn't.

Considering that, -EBUSY seems ok at returning error because of children.
How about change swappiness to return -EBUSY ?

Thanks,
-Kame






> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  mm/memcontrol.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bc8f101..2497f7d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1760,6 +1760,9 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  	struct cgroup *parent = cont->parent;
>  	struct mem_cgroup *parent_mem = NULL;
>  
> +	if (val != 0 && val != 1)
> +		return -EINVAL;
> +
>  	if (parent)
>  		parent_mem = mem_cgroup_from_cont(parent);
>  
> @@ -1773,12 +1776,9 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  	 * set if there are no children.
>  	 */
>  	if ((!parent_mem || !parent_mem->use_hierarchy) &&
> -				(val == 1 || val == 0)) {
> -		if (list_empty(&cont->children))
> +	    list_empty(&cont->children))
>  			mem->use_hierarchy = val;
> -		else
> -			retval = -EBUSY;
> -	} else
> +	else
>  		retval = -EINVAL;
>  	cgroup_unlock();
>  
> -- 
> 1.5.4.rc3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
