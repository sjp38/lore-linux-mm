Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id BBD3E4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 10:37:34 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id r129so32022004wmr.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 07:37:34 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kj7si15540945wjb.87.2016.02.05.07.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 07:37:33 -0800 (PST)
Date: Fri, 5 Feb 2016 10:37:16 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: make tree_{stat,events} fetch all
 stats
Message-ID: <20160205153716.GA15544@cmpxchg.org>
References: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
 <20160204204540.GD8208@cmpxchg.org>
 <20160205095821.GA29522@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160205095821.GA29522@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 05, 2016 at 12:58:21PM +0300, Vladimir Davydov wrote:
> @@ -2745,14 +2745,20 @@ static void tree_events(struct mem_cgroup *memcg, unsigned long *events)
>  
>  static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  {
> -	unsigned long stat[MEMCG_NR_STAT];
> -	unsigned long val;
> +	unsigned long val = 0;
>  
>  	if (mem_cgroup_is_root(memcg)) {
> -		tree_stat(memcg, stat);
> -		val = stat[MEM_CGROUP_STAT_CACHE] + stat[MEM_CGROUP_STAT_RSS];
> -		if (swap)
> -			val += stat[MEM_CGROUP_STAT_SWAP];
> +		struct mem_cgroup *iter;
> +
> +		for_each_mem_cgroup_tree(iter, memcg) {
> +			val += mem_cgroup_read_stat(iter,
> +					MEM_CGROUP_STAT_CACHE);
> +			val += mem_cgroup_read_stat(iter,
> +					MEM_CGROUP_STAT_RSS);
> +			if (swap)
> +				val += mem_cgroup_read_stat(iter,
> +						MEM_CGROUP_STAT_SWAP);
> +		}
>  	} else {
>  		if (!swap)
>  			val = page_counter_read(&memcg->memory);

Looks good to me, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
