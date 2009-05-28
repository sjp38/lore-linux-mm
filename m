Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E9B7F6B0083
	for <linux-mm@kvack.org>; Thu, 28 May 2009 04:50:30 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4S8pGFU032257
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 May 2009 17:51:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B32A45DD7E
	for <linux-mm@kvack.org>; Thu, 28 May 2009 17:51:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D82845DD7F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 17:51:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 03C2E1DB8038
	for <linux-mm@kvack.org>; Thu, 28 May 2009 17:51:16 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ABA501DB8037
	for <linux-mm@kvack.org>; Thu, 28 May 2009 17:51:15 +0900 (JST)
Date: Thu, 28 May 2009 17:49:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RESEND] [PATCH] memcg: Fix build warning and avoid checking
 for mem != null again and again
Message-Id: <20090528174943.d4447480.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200905281420.44338.knikanth@suse.de>
References: <200905281420.44338.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 28 May 2009 14:20:43 +0530
Nikanth Karthikesan <knikanth@suse.de> wrote:

> 
> Resending the patch to Andrew for inclusion in -mm tree.
> 
> Thanks
> Nikanth
> 
> Fix build warning, "mem_cgroup_is_obsolete defined but not used" when
> CONFIG_DEBUG_VM is not set. Also avoid checking for !mem again and again.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 01c2d8f..d253846 100644
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
> @@ -932,7 +924,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  	if (unlikely(!mem))
>  		return 0;
>  
> -	VM_BUG_ON(!mem || mem_cgroup_is_obsolete(mem));
> +	VM_BUG_ON(css_is_removed(&mem->css));
>  
>  	while (1) {
>  		int ret;
> 
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
