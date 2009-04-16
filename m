Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F1A8E5F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 20:48:24 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3G0n8FQ031025
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Apr 2009 09:49:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D79A45DD79
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 09:49:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BA0C45DE51
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 09:49:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 57FEA1DB8038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 09:49:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 009B71DB8040
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 09:49:08 +0900 (JST)
Date: Thu, 16 Apr 2009 09:47:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg remove warning at DEBUG_VM=off
Message-Id: <20090416094738.2904c799.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090415101317.GA3240@linux>
References: <20090408142042.3fb62eea.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408052715.GX7082@balbir.in.ibm.com>
	<20090409222512.bd026a40.akpm@linux-foundation.org>
	<20090410153335.b52c5f74.kamezawa.hiroyu@jp.fujitsu.com>
	<20090415101317.GA3240@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <righi.andrea@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Apr 2009 12:13:17 +0200
Andrea Righi <righi.andrea@gmail.com> wrote:

> The warning is still there actually. I've just written a fix and seen
> this discussion, maybe I can offload a little bit Kame. ;)
> 
> -Andrea

Thank you.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> memcg: remove warning when CONFIG_DEBUG_VM is not set
> 
> Fix the following warning removing mem_cgroup_is_obsolete():
> 
>   mm/memcontrol.c:318: warning: ‘mem_cgroup_is_obsolete’ defined but not used
> 
> Moreover, split the VM_BUG_ON() checks in two parts to be aware of which
> one triggered the bug.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
> ---
>  mm/memcontrol.c |   11 ++---------
>  1 files changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e44fb0f..8cd6358 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -314,14 +314,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>  	return mem;
>  }
>  
> -static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
> -{
> -	if (!mem)
> -		return true;
> -	return css_is_removed(&mem->css);
> -}
> -
> -
>  /*
>   * Call callback function against all cgroup under hierarchy tree.
>   */
> @@ -932,7 +924,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  	if (unlikely(!mem))
>  		return 0;
>  
> -	VM_BUG_ON(!mem || mem_cgroup_is_obsolete(mem));
> +	VM_BUG_ON(!mem);
> +	VM_BUG_ON(css_is_removed(&mem->css));
>  
>  	while (1) {
>  		int ret;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
