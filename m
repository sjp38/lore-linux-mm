Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8E6A78D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 19:05:48 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A7A0F3EE0B5
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:05:17 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E9E145DE51
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:05:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 75C7645DE4E
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:05:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 69D59EF8002
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:05:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 354AD1DB8037
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:05:17 +0900 (JST)
Date: Fri, 4 Feb 2011 08:59:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch rfc] memcg: remove NULL check from lookup_page_cgroup()
 result
Message-Id: <20110204085913.1b4780df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110203141230.GG2286@cmpxchg.org>
References: <20110203141230.GG2286@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Feb 2011 15:12:30 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The page_cgroup array is set up before even fork is initialized.  I
> seriously doubt that this code executes before the array is alloc'd.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I don't have solid answer to this. If some module use radix-tree and enter pages
to it, mem_cgroup may see it. But..

For my opinion, tring this is good.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memcontrol.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a145c9e..6abaa10 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2343,10 +2343,7 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
>  	}
>  
>  	pc = lookup_page_cgroup(page);
> -	/* can happen at boot */
> -	if (unlikely(!pc))
> -		return 0;
> -	prefetchw(pc);
> +	BUG_ON(!pc); /* XXX: remove this and move pc lookup into commit */
>  
>  	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, oom, page_size);
>  	if (ret || !mem)
> -- 
> 1.7.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
