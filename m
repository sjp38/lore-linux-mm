Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 385776B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 19:58:57 -0500 (EST)
Message-ID: <4966A117.9030201@cn.fujitsu.com>
Date: Fri, 09 Jan 2009 08:57:59 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/4] memcg: fix for mem_cgroup_get_reclaim_stat_from_page
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp> <20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, menage@google.com
List-ID: <linux-mm.kvack.org>

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2996b8..62e69d8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -559,6 +559,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  		return NULL;
>  
>  	pc = lookup_page_cgroup(page);
> +	smp_rmb();

It is better to add a comment to explain this smp_rmb. I think it's recommended
that every memory barrier has a comment.

> +	if (!PageCgroupUsed(pc))
> +		return NULL;
> +
>  	mz = page_cgroup_zoneinfo(pc);
>  	if (!mz)
>  		return NULL;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
