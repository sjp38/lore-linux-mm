Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8768D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 02:52:22 -0500 (EST)
Date: Fri, 28 Jan 2011 08:52:15 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for
 hugepage
Message-ID: <20110128075215.GA2213@cmpxchg.org>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 12:24:49PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Current memory cgroup's code tends to assume page_size == PAGE_SIZE
> and arrangement for THP is not enough yet.
> 
> This is one of fixes for supporing THP. This adds
> mem_cgroup_check_margin() and checks whether there are required amount of
> free resource after memory reclaim. By this, THP page allocation
> can know whether it really succeeded or not and avoid infinite-loop
> and hangup.
> 
> Total fixes for do_charge()/reclaim memory will follow this patch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/res_counter.h |   11 +++++++++++
>  mm/memcontrol.c             |   25 ++++++++++++++++++++++++-
>  2 files changed, 35 insertions(+), 1 deletion(-)
> 
> Index: mmotm-0125/include/linux/res_counter.h
> ===================================================================
> --- mmotm-0125.orig/include/linux/res_counter.h
> +++ mmotm-0125/include/linux/res_counter.h
> @@ -182,6 +182,17 @@ static inline bool res_counter_check_und
>  	return ret;
>  }
>  
> +static inline s64 res_counter_check_margin(struct res_counter *cnt)
> +{
> +	s64 ret;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	ret = cnt->limit - cnt->usage;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}

This function does not check anything.  You could name it
res_counter_get_margin() e.g.  But if you do that, I will complain
that it's asymmetric to res_counter_check_under_limit().  And the
result will be pretty close to my version...

> @@ -1853,7 +1869,14 @@ static int __mem_cgroup_do_charge(struct
>  	 * Check the limit again to see if the reclaim reduced the
>  	 * current usage of the cgroup before giving up
>  	 */
> -	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
> +	if (mem_cgroup_check_margin(mem_over_limit) >= csize)
> +		return CHARGE_RETRY;
> +
> +	/*
> + 	 * If the charge size is a PAGE_SIZE, it's not hopeless while
> + 	 * we can reclaim a page.
> + 	 */
> +	if (csize == PAGE_SIZE && ret)
>  		return CHARGE_RETRY;

That makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
