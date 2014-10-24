Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6EE6B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 14:30:35 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ex7so1986829wid.10
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:30:34 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id n9si2771631wix.16.2014.10.24.11.30.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 11:30:34 -0700 (PDT)
Received: by mail-wg0-f48.google.com with SMTP id k14so1672793wgh.19
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:30:33 -0700 (PDT)
Date: Fri, 24 Oct 2014 20:30:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/3] mm: memcontrol: pull the NULL check from
 __mem_cgroup_same_or_subtree()
Message-ID: <20141024183032.GB18956@dhcp22.suse.cz>
References: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
 <1414158589-26094-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414158589-26094-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 24-10-14 09:49:48, Johannes Weiner wrote:
> The NULL in mm_match_cgroup() comes from a possibly exiting mm->owner.
> It makes a lot more sense to check where it's looked up, rather than
> check for it in __mem_cgroup_same_or_subtree() where it's unexpected.
> 
> No other callsite passes NULL to __mem_cgroup_same_or_subtree().

Much better!

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memcontrol.h | 5 +++--
>  mm/memcontrol.c            | 2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index ea007615e8f9..e32ab948f589 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -83,11 +83,12 @@ static inline
>  bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
>  {
>  	struct mem_cgroup *task_memcg;
> -	bool match;
> +	bool match = false;
>  
>  	rcu_read_lock();
>  	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> -	match = __mem_cgroup_same_or_subtree(memcg, task_memcg);
> +	if (task_memcg)
> +		match = __mem_cgroup_same_or_subtree(memcg, task_memcg);
>  	rcu_read_unlock();
>  	return match;
>  }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bdf8520979cf..15b1c5110a8f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1316,7 +1316,7 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  {
>  	if (root_memcg == memcg)
>  		return true;
> -	if (!root_memcg->use_hierarchy || !memcg)
> +	if (!root_memcg->use_hierarchy)
>  		return false;
>  	return cgroup_is_descendant(memcg->css.cgroup, root_memcg->css.cgroup);
>  }
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
