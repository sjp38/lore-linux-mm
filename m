Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 615C76B0163
	for <linux-mm@kvack.org>; Thu, 21 May 2015 10:12:30 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so15488438wic.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 07:12:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fr8si1420196wib.3.2015.05.21.07.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 May 2015 07:12:28 -0700 (PDT)
Date: Thu, 21 May 2015 16:12:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150521141225.GB14475@dhcp22.suse.cz>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-4-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431978595-12176-4-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Mon 18-05-15 15:49:51, Tejun Heo wrote:
> If move_charge flag is set, memcg tries to move memory charges to the
> destnation css.  The current implementation migrates memory whenever
> any thread of a process is migrated making the behavior somewhat
> arbitrary.  Let's tie memory operations to the threadgroup leader so
> that memory is migrated only when the leader is migrated.
> 
> While this is a behavior change, given the inherent fuziness, this
> change is not too likely to be noticed and allows us to clearly define
> who owns the memory (always the leader) and helps the planned atomic
> multi-process migration.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>

OK, I guess the discussion with Oleg confirmed that the patch is not
really needed because mm_struct->owner check implies thread group
leader. This should be sufficient for your purpose Tejun, right?

> ---
>  mm/memcontrol.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b1b834d..74fcea3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5014,6 +5014,9 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
>  		return 0;
>  
>  	p = cgroup_taskset_first(tset);
> +	if (!thread_group_leader(p))
> +		return 0;
> +
>  	from = mem_cgroup_from_task(p);
>  
>  	VM_BUG_ON(from == memcg);
> -- 
> 2.4.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
