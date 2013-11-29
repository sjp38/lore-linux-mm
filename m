Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 956EB6B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 04:45:06 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id q58so9185063wes.33
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 01:45:05 -0800 (PST)
Received: from mail-ea0-x229.google.com (mail-ea0-x229.google.com [2a00:1450:4013:c01::229])
        by mx.google.com with ESMTPS id d8si13931371wiv.76.2013.11.29.01.45.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 01:45:05 -0800 (PST)
Received: by mail-ea0-f169.google.com with SMTP id l9so6685094eaj.0
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 01:45:05 -0800 (PST)
Date: Fri, 29 Nov 2013 10:45:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix kmem_account_flags check in
 memcg_can_account_kmem()
Message-ID: <20131129094502.GD25893@dhcp22.suse.cz>
References: <1385567162-14973-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1385567162-14973-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed 27-11-13 19:46:01, Vladimir Davydov wrote:
> We should start kmem accounting for a memory cgroup only after both its
> kmem limit is set (KMEM_ACCOUNTED_ACTIVE) and related call sites are
> patched (KMEM_ACCOUNTED_ACTIVATED).

This should be vice-versa, no? ACTIVE is set after
static_key_slow_inc(&memcg_kmem_enabled_key) AFAICS.

> Currently memcg_can_account_kmem() allows kmem accounting even if only
> one of the conditions is true.
> Fix it.

It would be nice to describe, what is the actual problem here. I assume
this is a charge vs. enable race. Let me try

So we have KMEM_ACCOUNTED_ACTIVATED (set by memcg_update_cache_sizes)
but the static key is not enabled yet (so KMEM_ACCOUNTED_ACTIVE is not
set yet). memcg_can_account_kmem is called from 2 contexts during charge
	- memcg_kmem_get_cache via __memcg_kmem_get_cache
	- memcg_kmem_newpage_charge via __memcg_kmem_newpage_charge

both of them start by checking memcg_kmem_enabled which is our
static key before memcg_can_account_kmem. This would suggest that
static_key+ACTIVE check memcg_can_account_kmem is sufficient. No?

That being said the proposed change is not incorrect it just doesn't
seem to _fix_ anything. I would much rather see a comprehensive
documentation of the whole enabling workflow. E.g. why do we need
ACTIVATED at all? Nobody seem to care in the code...
 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f1a0ae6..40efb9d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2956,7 +2956,8 @@ static DEFINE_MUTEX(set_limit_mutex);
>  static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
>  {
>  	return !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
> -		(memcg->kmem_account_flags & KMEM_ACCOUNTED_MASK);
> +		(memcg->kmem_account_flags & KMEM_ACCOUNTED_MASK) ==
> +							KMEM_ACCOUNTED_MASK;
>  }
>  
>  /*
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
