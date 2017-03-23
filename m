Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C04E96B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 04:28:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p78so102185353lfd.0
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 01:28:30 -0700 (PDT)
Received: from smtp52.i.mail.ru (smtp52.i.mail.ru. [94.100.177.112])
        by mx.google.com with ESMTPS id u139si2895521lff.291.2017.03.23.01.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 01:28:29 -0700 (PDT)
Date: Thu, 23 Mar 2017 11:28:22 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH] mm: workingset: fix premature shadow node shrinking with
 cgroups
Message-ID: <20170323082822.GA17625@esperanza>
References: <20170322005320.8165-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170322005320.8165-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Mar 21, 2017 at 08:53:20PM -0400, Johannes Weiner wrote:
> 0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
> enabled cgroup-awareness in the shadow node shrinker, but forgot to
> also enable cgroup-awareness in the list_lru the shadow nodes sit on.
> 
> Consequently, all shadow nodes are sitting on a global (per-NUMA node)
> list, while the shrinker applies the limits according to the amount of
> cache in the cgroup its shrinking. The result is excessive pressure on
> the shadow nodes from cgroups that have very little cache.
> 
> Enable memcg-mode on the shadow node LRUs, such that per-cgroup limits
> are applied to per-cgroup lists.
> 
> Fixes: 0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@vger.kernel.org> # 4.6+

Acked-by: Vladimir Davydov <vdavydov@tarantool.org>

> ---
>  mm/workingset.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/workingset.c b/mm/workingset.c
> index ac839fca0e76..eda05c71fa49 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -532,7 +532,7 @@ static int __init workingset_init(void)
>  	pr_info("workingset: timestamp_bits=%d max_order=%d bucket_order=%u\n",
>  	       timestamp_bits, max_order, bucket_order);
>  
> -	ret = list_lru_init_key(&shadow_nodes, &shadow_nodes_key);
> +	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
>  	if (ret)
>  		goto err;
>  	ret = register_shrinker(&workingset_shadow_shrinker);
> -- 
> 2.12.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
