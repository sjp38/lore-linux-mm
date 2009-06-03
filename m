Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 089A26B005D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:00:48 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n533s439024373
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Jun 2009 12:54:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E53545DD7B
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:54:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 45A1E45DD78
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:54:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BED61DB8037
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:54:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CC79F1DB806A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:54:00 +0900 (JST)
Date: Wed, 3 Jun 2009 12:52:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm 2/2] memcg: allow mem.limit bigger than
 memsw.limit iff unlimited
Message-Id: <20090603125228.368ecaf7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090603115027.80f9169b.nishimura@mxp.nes.nec.co.jp>
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
	<20090603115027.80f9169b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009 11:50:27 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Now users cannot set mem.limit bigger than memsw.limit.
> This patch allows mem.limit bigger than memsw.limit iff mem.limit==unlimited.
> 
> By this, users can set memsw.limit without setting mem.limit.
> I think it's usefull if users want to limit memsw only.
> They must set mem.limit first and memsw.limit to the same value now for this purpose.
> They can save the first step by this patch.
> 

I don't like this. No benefits to users.
The user should know when they set memsw.limit they have to set memory.limit.
This just complicates things.

If you want to do this, add an interface as
  memory.all.limit_in_bytes (or some better name)
and allow to set memory.limit and memory.memsw.limit _at once_.

But I'm not sure it's worth to try. Saving user's few steps by the kenerl patch ?

Thanks,
-Kame


> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6629ed2..2b63cb1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1742,11 +1742,12 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		/*
>  		 * Rather than hide all in some function, I do this in
>  		 * open coded manner. You see what this really does.
> -		 * We have to guarantee mem->res.limit < mem->memsw.limit.
> +		 * We have to guarantee mem->res.limit < mem->memsw.limit,
> +		 * except for mem->res.limit == RESOURCE_MAX(unlimited) case.
>  		 */
>  		mutex_lock(&set_limit_mutex);
>  		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -		if (memswlimit < val) {
> +		if (val != RESOURCE_MAX && memswlimit < val) {
>  			ret = -EINVAL;
>  			mutex_unlock(&set_limit_mutex);
>  			break;
> @@ -1789,11 +1790,12 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		/*
>  		 * Rather than hide all in some function, I do this in
>  		 * open coded manner. You see what this really does.
> -		 * We have to guarantee mem->res.limit < mem->memsw.limit.
> +		 * We have to guarantee mem->res.limit < mem->memsw.limit,
> +		 * except for mem->res.limit == RESOURCE_MAX(unlimited) case.
>  		 */
>  		mutex_lock(&set_limit_mutex);
>  		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> -		if (memlimit > val) {
> +		if (memlimit != RESOURCE_MAX && memlimit > val) {
>  			ret = -EINVAL;
>  			mutex_unlock(&set_limit_mutex);
>  			break;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
