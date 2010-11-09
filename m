Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 013E76B00C6
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 22:46:20 -0500 (EST)
Date: Tue, 9 Nov 2010 12:44:26 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: avoid overflow in
 memcg_hierarchical_free_pages()
Message-Id: <20101109124426.312f9979.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1289265320-7025-1-git-send-email-gthelen@google.com>
References: <1289265320-7025-1-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon,  8 Nov 2010 17:15:20 -0800
Greg Thelen <gthelen@google.com> wrote:

> Use page counts rather than byte counts to avoid overflowing
> unsigned long local variables.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
>  mm/memcontrol.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6c7115d..b287afd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1345,17 +1345,17 @@ memcg_hierarchical_free_pages(struct mem_cgroup *mem)
>  {
>  	unsigned long free, min_free;
>  
hmm, the default value of RES_LIMIT is LLONG_MAX, so I think we must declare
"free" as unsinged long long to avoid overflow.

Thanks,
Daisuke Nishimura.

> -	min_free = global_page_state(NR_FREE_PAGES) << PAGE_SHIFT;
> +	min_free = global_page_state(NR_FREE_PAGES);
>  
>  	while (mem) {
> -		free = res_counter_read_u64(&mem->res, RES_LIMIT) -
> -			res_counter_read_u64(&mem->res, RES_USAGE);
> +		free = (res_counter_read_u64(&mem->res, RES_LIMIT) -
> +			res_counter_read_u64(&mem->res, RES_USAGE)) >>
> +			PAGE_SHIFT;
>  		min_free = min(min_free, free);
>  		mem = parent_mem_cgroup(mem);
>  	}
>  
> -	/* Translate free memory in pages */
> -	return min_free >> PAGE_SHIFT;
> +	return min_free;
>  }
>  
>  /*
> -- 
> 1.7.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
