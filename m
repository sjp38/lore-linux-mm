Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA25coHs025659
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sun, 2 Nov 2008 14:38:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F91845DD7E
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 14:38:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D4E445DD7B
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 14:38:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E328C1DB803B
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 14:38:49 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A5F41DB8038
	for <linux-mm@kvack.org>; Sun,  2 Nov 2008 14:38:49 +0900 (JST)
Date: Sun, 2 Nov 2008 14:38:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
Message-Id: <20081102143817.99edca6d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081101184902.2575.11443.sendpatchset@balbir-laptop>
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
	<20081101184902.2575.11443.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 02 Nov 2008 00:19:02 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> Don't enable multiple hierarchy support by default. This patch introduces
> a features element that can be set to enable the nested depth hierarchy
> feature. This feature can only be enabled when there is just one cgroup
> (the root cgroup).
> 
Why the flag is for the whole system ?
flag-per-subtree is of no use ?

Thanks,
-Kame

> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  mm/memcontrol.c |   38 +++++++++++++++++++++++++++++++++++++-
>  1 file changed, 37 insertions(+), 1 deletion(-)
> 
> diff -puN mm/memcontrol.c~memcg-add-hierarchy-selector mm/memcontrol.c
> --- linux-2.6.28-rc2/mm/memcontrol.c~memcg-add-hierarchy-selector	2008-11-02 00:15:00.000000000 +0530
> +++ linux-2.6.28-rc2-balbir/mm/memcontrol.c	2008-11-02 00:15:00.000000000 +0530
> @@ -40,6 +40,9 @@
>  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  
> +static unsigned long mem_cgroup_features;
> +#define MEM_CGROUP_FEAT_HIERARCHY	0x1
> +
>  /*
>   * Statistics for memory cgroup.
>   */
> @@ -1080,6 +1083,31 @@ out:
>  	return ret;
>  }
>  
> +static u64 mem_cgroup_feature_read(struct cgroup *cont, struct cftype *cft)
> +{
> +	return mem_cgroup_features;
> +}
> +
> +static int mem_cgroup_feature_write(struct cgroup *cont, struct cftype *cft,
> +			    		u64 val)
> +{
> +	int retval = 0;
> +	struct cgroup *cgroup = init_mem_cgroup.css.cgroup;
> +
> +	if (val & MEM_CGROUP_FEAT_HIERARCHY) {
> +		if (list_empty(&cgroup->children))
> +			mem_cgroup_features |= MEM_CGROUP_FEAT_HIERARCHY;
> +		else
> +			retval = -EBUSY;
> +	} else {
> +		if (list_empty(&cgroup->children))
> +			mem_cgroup_features &= ~MEM_CGROUP_FEAT_HIERARCHY;
> +		else
> +			retval = -EBUSY;
> +	}
> +	return retval;
> +}
> +
>  static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  {
>  	return res_counter_read_u64(&mem_cgroup_from_cont(cont)->res,
> @@ -1214,6 +1242,11 @@ static struct cftype mem_cgroup_files[] 
>  		.name = "stat",
>  		.read_map = mem_control_stat_show,
>  	},
> +	{
> +		.name = "features",
> +		.write_u64 = mem_cgroup_feature_write,
> +		.read_u64 = mem_cgroup_feature_read,
> +	},
>  };
>  
>  static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
> @@ -1292,7 +1325,10 @@ mem_cgroup_create(struct cgroup_subsys *
>  			return ERR_PTR(-ENOMEM);
>  	}
>  
> -	res_counter_init(&mem->res, parent ? &parent->res : NULL);
> +	if ((mem_cgroup_features & MEM_CGROUP_FEAT_HIERARCHY) && parent)
> +		res_counter_init(&mem->res, &parent->res);
> +	else
> +		res_counter_init(&mem->res, NULL);
>  
>  	for_each_node_state(node, N_POSSIBLE)
>  		if (alloc_mem_cgroup_per_zone_info(mem, node))
> _
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
