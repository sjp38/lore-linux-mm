Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 49CDB8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:54:40 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DC89A3EE0B3
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:54:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C177245DE57
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:54:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8A4945DE4D
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:54:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A97B1DB803C
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:54:36 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AA401DB8037
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 08:54:36 +0900 (JST)
Date: Tue, 1 Feb 2011 08:48:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/3] memcg: prevent endless loop when charging huge
 pages
Message-Id: <20110201084829.86b7290c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1296482635-13421-2-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 31 Jan 2011 15:03:53 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The charging code can encounter a charge size that is bigger than a
> regular page in two situations: one is a batched charge to fill the
> per-cpu stocks, the other is a huge page charge.
> 
> This code is distributed over two functions, however, and only the
> outer one is aware of huge pages.  In case the charging fails, the
> inner function will tell the outer function to retry if the charge
> size is bigger than regular pages--assuming batched charging is the
> only case.  And the outer function will retry forever charging a huge
> page.
> 
> This patch makes sure the inner function can distinguish between batch
> charging and a single huge page charge.  It will only signal another
> attempt if batch charging failed, and go into regular reclaim when it
> is called on behalf of a huge page.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Thank you very much.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memcontrol.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d572102..73ea323 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1837,8 +1837,15 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
>  		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
>  	} else
>  		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> -
> -	if (csize > PAGE_SIZE) /* change csize and retry */
> +	/*
> +	 * csize can be either a huge page (HPAGE_SIZE), a batch of
> +	 * regular pages (CHARGE_SIZE), or a single regular page
> +	 * (PAGE_SIZE).
> +	 *
> +	 * Never reclaim on behalf of optional batching, retry with a
> +	 * single page instead.
> +	 */
> +	if (csize == CHARGE_SIZE)
>  		return CHARGE_RETRY;
>  
>  	if (!(gfp_mask & __GFP_WAIT))
> -- 
> 1.7.3.5
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
