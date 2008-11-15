Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAFAVYm7024185
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 15 Nov 2008 19:31:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C0C845DD7A
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 19:31:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E73C45DD76
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 19:31:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F00F1DB803F
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 19:31:34 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA4211DB8037
	for <linux-mm@kvack.org>; Sat, 15 Nov 2008 19:31:33 +0900 (JST)
Message-ID: <41265.10.75.179.62.1226745093.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081115183721.cfc1b80b.d-nishimura@mtf.biglobe.ne.jp>
References: <20081115183721.cfc1b80b.d-nishimura@mtf.biglobe.ne.jp>
Date: Sat, 15 Nov 2008 19:31:33 +0900 (JST)
Subject: Re: [PATCH mmotm] memcg: make resize limit hold mutex
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
>
> This patch define a new mutex and make both mem_cgroup_resize_limit and
> mem_cgroup_memsw_resize_limit hold it to remove spin_lock_irqsave.
>
Thanks,

>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
<snip>
> -	while (res_counter_set_limit(&memcg->res, val)) {
> +	while (retry_count) {
>  		if (signal_pending(current)) {
>  			ret = -EINTR;
>  			break;
>  		}
> -		if (!retry_count) {
> -			ret = -EBUSY;
> -			break;
> +		/*
> +		 * Rather than hide all in some function, I do this in
> +		 * open coded manner. You see what this really does.
> +		 * We have to guarantee mem->res.limit < mem->memsw.limit.
> +		 */
> +		if (do_swap_account) {
> +			mutex_lock(&set_limit_mutex);
> +			memswlimit = res_counter_read_u64(&memcg->memsw,
> +							RES_LIMIT);
> +			if (memswlimit < val) {
> +				ret = -EINVAL;
> +				mutex_unlock(&set_limit_mutex);
> +				break;
> +			}
> +			ret = res_counter_set_limit(&memcg->res, val);
> +			mutex_unlock(&set_limit_mutex);
>  		}

Maybe !do_swap_account case is not handled.
I think in !do_swap_account case, memsw.limit is inifinite.
So, just removing this "if" is ok.

No objection to your direction, could you fix ?

Thanks,
-Kame

> +
> +		if (!ret)
> +			break;
> +
>  		progress = try_to_free_mem_cgroup_pages(memcg,
>  				GFP_HIGHUSER_MOVABLE, false);
>  		if (!progress)
> @@ -1180,7 +1195,6 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup
> *memcg,
>  				unsigned long long val)
>  {
>  	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
> -	unsigned long flags;
>  	u64 memlimit, oldusage, curusage;
>  	int ret;
>
> @@ -1197,19 +1211,20 @@ int mem_cgroup_resize_memsw_limit(struct
> mem_cgroup *memcg,
>  		 * open coded manner. You see what this really does.
>  		 * We have to guarantee mem->res.limit < mem->memsw.limit.
>  		 */
> -		spin_lock_irqsave(&memcg->res.lock, flags);
> -		memlimit = memcg->res.limit;
> +		mutex_lock(&set_limit_mutex);
> +		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
>  		if (memlimit > val) {
> -			spin_unlock_irqrestore(&memcg->res.lock, flags);
>  			ret = -EINVAL;
> +			mutex_unlock(&set_limit_mutex);
>  			break;
>  		}
>  		ret = res_counter_set_limit(&memcg->memsw, val);
> -		oldusage = memcg->memsw.usage;
> -		spin_unlock_irqrestore(&memcg->res.lock, flags);
> +		mutex_unlock(&set_limit_mutex);
>
>  		if (!ret)
>  			break;
> +
> +		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		try_to_free_mem_cgroup_pages(memcg, GFP_HIGHUSER_MOVABLE, true);
>  		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  		if (curusage >= oldusage)
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
