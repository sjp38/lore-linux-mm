Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4FB6B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:05:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 87so24084301lfy.9
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:05:41 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id v26si1942052ljb.452.2017.07.25.05.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 05:05:40 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id w199so2551849lff.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:05:39 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:05:37 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm, memcg: reset low limit during memcg offlining
Message-ID: <20170725120537.o4kgzjhcjcjmopzc@esperanza>
References: <20170725114047.4073-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725114047.4073-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 25, 2017 at 12:40:47PM +0100, Roman Gushchin wrote:
> A removed memory cgroup with a defined low limit and some belonging
> pagecache has very low chances to be freed.
> 
> If a cgroup has been removed, there is likely no memory pressure inside
> the cgroup, and the pagecache is protected from the external pressure
> by the defined low limit. The cgroup will be freed only after
> the reclaim of all belonging pages. And it will not happen until
> there are any reclaimable memory in the system. That means,
> there is a good chance, that a cold pagecache will reside
> in the memory for an undefined amount of time, wasting
> system resources.
> 
> Fix this issue by zeroing memcg->low during memcg offlining.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index aed11b2d0251..2aa204b8f9fd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4300,6 +4300,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  	}
>  	spin_unlock(&memcg->event_list_lock);
>  
> +	memcg->low = 0;
> +
>  	memcg_offline_kmem(memcg);
>  	wb_memcg_offline(memcg);
>  

We already have that - see mem_cgroup_css_reset().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
