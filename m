Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A79EF6B00A6
	for <linux-mm@kvack.org>; Tue, 19 May 2015 08:10:42 -0400 (EDT)
Received: by wghq2 with SMTP id q2so15338178wgh.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 05:10:42 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id r7si17976675wiz.113.2015.05.19.05.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 05:10:41 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so114616200wic.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 05:10:40 -0700 (PDT)
Date: Tue, 19 May 2015 14:13:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150519121321.GB6203@dhcp22.suse.cz>
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
> arbitrary. 

This is not true. We have:
                mm = get_task_mm(p);
                if (!mm)
                        return 0;
                /* We move charges only when we move a owner of the mm */
                if (mm->owner == p) {

So we are ignoring threads which are not owner of the mm struct and that
should be the thread group leader AFAICS.

mm_update_next_owner is rather complex (maybe too much and it would
deserve some attention) so there might really be some corner cases but
the whole memcg code relies on mm->owner rather than thread group leader
so I would keep the same logic here.

> Let's tie memory operations to the threadgroup leader so
> that memory is migrated only when the leader is migrated.

This would lead to another strange behavior when the group leader is not
owner (if that is possible at all) and the memory wouldn't get migrated
at all.

I am trying to wrap my head around mm_update_next_owner and maybe we can
change it to use the thread group leader but this needs more thinking...

> While this is a behavior change, given the inherent fuziness, this
> change is not too likely to be noticed and allows us to clearly define
> who owns the memory (always the leader) and helps the planned atomic
> multi-process migration.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
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
