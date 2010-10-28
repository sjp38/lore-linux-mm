Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B4D456B00DD
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 11:52:23 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9SFa1SP026971
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 11:36:01 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9SFqFse191772
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 11:52:15 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9SFqExx010334
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:52:15 -0600
Date: Thu, 28 Oct 2010 21:22:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch] memcg: null dereference on allocation failure
Message-ID: <20101028155207.GB3769@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101028111241.GC6062@bicker>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101028111241.GC6062@bicker>
Sender: owner-linux-mm@kvack.org
To: Dan Carpenter <error27@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Dan Carpenter <error27@gmail.com> [2010-10-28 13:12:41]:

> The original code had a null dereference if alloc_percpu() failed.
> This was introduced in 711d3d2c9bc3 "memcg: cpu hotplug aware percpu
> count updates"
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
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

Good catch!
Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
