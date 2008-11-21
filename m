Message-ID: <49261F87.50209@cn.fujitsu.com>
Date: Fri, 21 Nov 2008 10:40:07 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/9] memcg : mem+swap controlelr core
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com> <20081114191949.926bf99d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081114191949.926bf99d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> @@ -513,12 +531,25 @@ static int __mem_cgroup_try_charge(struc
>  		css_get(&mem->css);
>  	}
>  
> +	while (1) {

This loop will never break out if memory.limit_in_bytes is too low.

Actually, when I set the limit to 0 and moved a task into the cgroup and let
the task allocate a page, then the whole system froze, and I had to reset
my machine.

And small memory.limit will make the process stuck:
# mkdir /memcg/0
# echo 40K > /memcg/0/memory.limit_in_bytes
# echo $$ > tasks
# ls
(stuck)

(another console)
# echo 100K > /memcg/0/memory.limit_in_bytes
(then the above 'ls' can continue)

> +		int ret;
> +		bool noswap = false;
>  
> -	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
> +		ret = res_counter_charge(&mem->res, PAGE_SIZE);
> +		if (likely(!ret)) {
> +			if (!do_swap_account)
> +				break;
> +			ret = res_counter_charge(&mem->memsw, PAGE_SIZE);
> +			if (likely(!ret))
> +				break;
> +			/* mem+swap counter fails */
> +			res_counter_uncharge(&mem->res, PAGE_SIZE);
> +			noswap = true;
> +		}
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
>  
> -		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
> +		if (try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap))
>  			continue;
>  
>  		/*
> @@ -527,8 +558,13 @@ static int __mem_cgroup_try_charge(struc
>  		 * moved to swap cache or just unmapped from the cgroup.
>  		 * Check the limit again to see if the reclaim reduced the
>  		 * current usage of the cgroup before giving up
> +		 *
>  		 */
> -		if (res_counter_check_under_limit(&mem->res))
> +		if (!do_swap_account &&
> +			res_counter_check_under_limit(&mem->res))
> +			continue;
> +		if (do_swap_account &&
> +			res_counter_check_under_limit(&mem->memsw))
>  			continue;
>  
>  		if (!nr_retries--) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
