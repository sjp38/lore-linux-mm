Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5627A6B0071
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 15:00:46 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch] memcg: fix unit mismatch in memcg oom limit calculation
References: <20101109110521.GS23393@cmpxchg.org>
Date: Tue, 09 Nov 2010 12:00:26 -0800
Message-ID: <xr93iq068dyd.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> writes:

> Adding the number of swap pages to the byte limit of a memory control
> group makes no sense.  Convert the pages to bytes before adding them.
>
> The only user of this code is the OOM killer, and the way it is used
> means that the error results in a higher OOM badness value.  Since the
> cgroup limit is the same for all tasks in the cgroup, the error should
> have no practical impact at the moment.
>
> But let's not wait for future or changing users to trip over it.

Thanks for the fix.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Greg Thelen <gthelen@google.com>

> ---
>  mm/memcontrol.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1552,8 +1552,9 @@ u64 mem_cgroup_get_limit(struct mem_cgro
>  	u64 limit;
>  	u64 memsw;
>  
> -	limit = res_counter_read_u64(&memcg->res, RES_LIMIT) +
> -			total_swap_pages;
> +	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> +	limit += total_swap_pages << PAGE_SHIFT;
> +
>  	memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
>  	/*
>  	 * If memsw is finite and limits the amount of swap space available

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
