Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED8946B00D6
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 20:46:58 -0400 (EDT)
Date: Fri, 29 Oct 2010 09:38:53 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [patch] memcg: null dereference on allocation failure
Message-Id: <20101029093853.49e75309.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101028111241.GC6062@bicker>
References: <20101028111241.GC6062@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Carpenter <error27@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

(I add Andrew to CC-list)

On Thu, 28 Oct 2010 13:12:41 +0200
Dan Carpenter <error27@gmail.com> wrote:

> The original code had a null dereference if alloc_percpu() failed.
> This was introduced in 711d3d2c9bc3 "memcg: cpu hotplug aware percpu
> count updates"
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9a99cfa..2efa8ea 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4208,15 +4208,17 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  
>  	memset(mem, 0, size);
>  	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
> -	if (!mem->stat) {
> -		if (size < PAGE_SIZE)
> -			kfree(mem);
> -		else
> -			vfree(mem);
> -		mem = NULL;
> -	}
> +	if (!mem->stat)
> +		goto out_free;
>  	spin_lock_init(&mem->pcp_counter_lock);
>  	return mem;
> +
> +out_free:
> +	if (size < PAGE_SIZE)
> +		kfree(mem);
> +	else
> +		vfree(mem);
> +	return NULL;
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
