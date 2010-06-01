Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 649E86B01E6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:19:19 -0400 (EDT)
Date: Tue, 1 Jun 2010 23:19:14 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][1/3] memcg clean up try charge
Message-Id: <20100601231914.6874165e.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010 18:24:06 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> mem_cgroup_try_charge() has a big loop (doesn't fits in screee) and seems to be
> hard to read. Most of routines are for slow paths. This patch moves codes out
> from the loop and make it clear what's done.
> 
I like this cleanup :)

I have some comments for now.

> -	while (1) {
> -		int ret = 0;
> -		unsigned long flags = 0;
> +	while (ret != CHARGE_OK) {
> +		int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
reset nr_oom_retries at the beginning of every loop ? :)
I think this line should be at the top of this function, and we should do like:

                case CHARGE_RETRY: /* not in OOM situation but retry */
			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
			csize = PAGE_SIZE;
			break;

later.

> +		case CHARGE_NOMEM: /* OOM routine works */
>  			if (!oom)
>  				goto nomem;
> -			if (mem_cgroup_handle_oom(mem_over_limit, gfp_mask)) {
> -				nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -				continue;
> -			}
> -			/* When we reach here, current task is dying .*/
> -			css_put(&mem->css);
> +			/* If !oom, we never return -ENOMEM */
s/!oom/oom ?   


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
