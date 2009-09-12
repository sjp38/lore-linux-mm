Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 476366B004D
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 00:58:19 -0400 (EDT)
Date: Sat, 12 Sep 2009 13:58:25 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH 4/4][mmotm] memcg: coalescing charge
Message-Id: <20090912135825.7f78a247.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090909174533.3b607bd7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090909174533.3b607bd7.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

> @@ -1320,6 +1423,9 @@ static int __mem_cgroup_try_charge(struc
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
>  
> +		/* we don't make stocks if failed */
> +		csize = PAGE_SIZE;
> +
>  		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
>  						gfp_mask, flags);
>  		if (ret)
It might be a nitpick though, isn't it better to move csize modification
before checking __GFP_WAIT ?
It might look like:

	/* we don't make stocks if failed */
	if (csize > PAGE_SIZE) {
		csize = PAGE_SIZE;
		continue;
	}

	if (!(gfp_mask & __GFP_WAIT))
		goto nomem;

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
