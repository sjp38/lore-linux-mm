Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBD66B0372
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 07:35:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z70so29300916wrc.1
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 04:35:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si11164411wmh.10.2017.06.13.04.35.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Jun 2017 04:35:51 -0700 (PDT)
Date: Tue, 13 Jun 2017 13:35:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] memcg: refactor mem_cgroup_resize_limit()
Message-ID: <20170613113545.GH10819@dhcp22.suse.cz>
References: <20170601230212.30578-1-yuzhao@google.com>
 <20170604211807.32685-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170604211807.32685-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, n.borisov.lkml@gmail.com

[Sorry for a late reponse]

On Sun 04-06-17 14:18:07, Yu Zhao wrote:
> mem_cgroup_resize_limit() and mem_cgroup_resize_memsw_limit() have
> identical logics. Refactor code so we don't need to keep two pieces
> of code that does same thing.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

It is nice to see removal of the code duplication. I have one comment
though

[...]

> @@ -2498,22 +2449,24 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>  		}
>  
>  		mutex_lock(&memcg_limit_mutex);
> -		if (limit < memcg->memory.limit) {
> +		inverted = memsw ? limit < memcg->memory.limit :
> +				   limit > memcg->memsw.limit;
> +		if (inverted) {
>  			mutex_unlock(&memcg_limit_mutex);
>  			ret = -EINVAL;
>  			break;
>  		}

This is just too ugly and hard to understand. inverted just doesn't give
you a good clue what is going on. What do you think about something like

		/*
		 * Make sure that the new limit (memsw or hard limit) doesn't
		 * break our basic invariant that memory.limit <= memsw.limit
		 */
		limits_invariant = memsw ? limit >= memcg->memory.limit :
					limit <= mmecg->memsw.limit;
		if (!limits_invariant) {
			mutex_unlock(&memcg_limit_mutex);
			ret = -EINVAL;
			break;
		}

with that feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
