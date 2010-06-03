Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B52216B021D
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 06:38:12 -0400 (EDT)
Date: Thu, 3 Jun 2010 19:38:09 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH 1/2] memcg clean up try_charge main loop
Message-Id: <20100603193809.9d5f6314.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100603152830.8b9e5e27.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100603114837.6e6d4d0f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100603150619.4bbe61bb.nishimura@mxp.nes.nec.co.jp>
	<20100603152830.8b9e5e27.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

One more comment.

> +	ret = res_counter_charge(&mem->res, csize, &fail_res);
> +
> +	if (likely(!ret)) {
> +		if (!do_swap_account)
> +			return CHARGE_OK;
> +		ret = res_counter_charge(&mem->memsw, csize, &fail_res);
> +		if (likely(!ret))
> +			return CHARGE_OK;
> +
> +		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
This must be mem_cgroup_from_res_counter(fail_res, memsw).
We will access to an invalid pointer, otherwise.

> +		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
> +	} else
> +		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> +

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
