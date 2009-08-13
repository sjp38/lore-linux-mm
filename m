Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EEF826B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 21:06:56 -0400 (EDT)
Date: Thu, 13 Aug 2009 10:03:50 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] Help Resource Counters Scale better (v4.1)
Message-Id: <20090813100350.bc09c568.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090812045716.GH7176@balbir.in.ibm.com>
References: <20090811144405.GW7176@balbir.in.ibm.com>
	<20090811163159.ddc5f5fd.akpm@linux-foundation.org>
	<20090812045716.GH7176@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, menage@google.com, prarit@redhat.com, andi.kleen@intel.com, xemul@openvz.org, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -1855,9 +1883,14 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  		break;
>  	}
>  
> -	res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
> -	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> -		res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> +	if (!mem_cgroup_is_root(mem)) {
> +		res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
> +		if (do_swap_account &&
> +				(ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> +			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> +	}
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT && mem_cgroup_is_root(mem))
> +		mem_cgroup_swap_statistics(mem, true);
I think mem_cgroup_is_root(mem) would be unnecessary here.
Otherwise, MEM_CGROUP_STAT_SWAPOUT of groups except root memcgroup wouldn't
be counted properly.


> @@ -2461,10 +2496,26 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  	name = MEMFILE_ATTR(cft->private);
>  	switch (type) {
>  	case _MEM:
> -		val = res_counter_read_u64(&mem->res, name);
> +		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
> +			val = mem_cgroup_read_stat(&mem->stat,
> +					MEM_CGROUP_STAT_CACHE);
> +			val += mem_cgroup_read_stat(&mem->stat,
> +					MEM_CGROUP_STAT_RSS);
> +			val <<= PAGE_SHIFT;
> +		} else
> +			val = res_counter_read_u64(&mem->res, name);
>  		break;
>  	case _MEMSWAP:
> -		val = res_counter_read_u64(&mem->memsw, name);
> +		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
> +			val = mem_cgroup_read_stat(&mem->stat,
> +					MEM_CGROUP_STAT_CACHE);
> +			val += mem_cgroup_read_stat(&mem->stat,
> +					MEM_CGROUP_STAT_RSS);
> +			val += mem_cgroup_read_stat(&mem->stat,
> +					MEM_CGROUP_STAT_SWAPOUT);
> +			val <<= PAGE_SHIFT;
> +		} else
> +			val = res_counter_read_u64(&mem->memsw, name);
>  		break;
>  	default:
>  		BUG();
Considering use_hierarchy==1 case in the root memcgroup, shouldn't we use
mem_cgroup_walk_tree() here to sum up all the children's usage ?
*.usage_in_bytes show sum of all the children's usage now if use_hierarchy==1.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
