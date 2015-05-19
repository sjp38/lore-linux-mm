Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 761AA6B00A1
	for <linux-mm@kvack.org>; Tue, 19 May 2015 05:03:47 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so109205040wic.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 02:03:47 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id di1si22280784wjb.37.2015.05.19.02.03.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 02:03:46 -0700 (PDT)
Received: by wichy4 with SMTP id hy4so13635308wic.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 02:03:45 -0700 (PDT)
Date: Tue, 19 May 2015 11:03:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/7] memcg: restructure mem_cgroup_can_attach()
Message-ID: <20150519090343.GC6847@dhcp22.suse.cz>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-3-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431978595-12176-3-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Mon 18-05-15 15:49:50, Tejun Heo wrote:
> Restructure it to lower nesting level and help the planned threadgroup
> leader iteration changes.
> 
> This is pure reorganization.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 61 ++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 32 insertions(+), 29 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 14c2f20..b1b834d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4997,10 +4997,12 @@ static void mem_cgroup_clear_mc(void)
>  static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
>  				 struct cgroup_taskset *tset)
>  {
> -	struct task_struct *p = cgroup_taskset_first(tset);
> -	int ret = 0;
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	struct mem_cgroup *from;
> +	struct task_struct *p;
> +	struct mm_struct *mm;
>  	unsigned long move_flags;
> +	int ret = 0;
>  
>  	/*
>  	 * We are now commited to this value whatever it is. Changes in this
> @@ -5008,36 +5010,37 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
>  	 * So we need to save it, and keep it going.
>  	 */
>  	move_flags = READ_ONCE(memcg->move_charge_at_immigrate);
> -	if (move_flags) {
> -		struct mm_struct *mm;
> -		struct mem_cgroup *from = mem_cgroup_from_task(p);
> +	if (!move_flags)
> +		return 0;
>  
> -		VM_BUG_ON(from == memcg);
> +	p = cgroup_taskset_first(tset);
> +	from = mem_cgroup_from_task(p);
>  
> -		mm = get_task_mm(p);
> -		if (!mm)
> -			return 0;
> -		/* We move charges only when we move a owner of the mm */
> -		if (mm->owner == p) {
> -			VM_BUG_ON(mc.from);
> -			VM_BUG_ON(mc.to);
> -			VM_BUG_ON(mc.precharge);
> -			VM_BUG_ON(mc.moved_charge);
> -			VM_BUG_ON(mc.moved_swap);
> -
> -			spin_lock(&mc.lock);
> -			mc.from = from;
> -			mc.to = memcg;
> -			mc.flags = move_flags;
> -			spin_unlock(&mc.lock);
> -			/* We set mc.moving_task later */
> -
> -			ret = mem_cgroup_precharge_mc(mm);
> -			if (ret)
> -				mem_cgroup_clear_mc();
> -		}
> -		mmput(mm);
> +	VM_BUG_ON(from == memcg);
> +
> +	mm = get_task_mm(p);
> +	if (!mm)
> +		return 0;
> +	/* We move charges only when we move a owner of the mm */
> +	if (mm->owner == p) {
> +		VM_BUG_ON(mc.from);
> +		VM_BUG_ON(mc.to);
> +		VM_BUG_ON(mc.precharge);
> +		VM_BUG_ON(mc.moved_charge);
> +		VM_BUG_ON(mc.moved_swap);
> +
> +		spin_lock(&mc.lock);
> +		mc.from = from;
> +		mc.to = memcg;
> +		mc.flags = move_flags;
> +		spin_unlock(&mc.lock);
> +		/* We set mc.moving_task later */
> +
> +		ret = mem_cgroup_precharge_mc(mm);
> +		if (ret)
> +			mem_cgroup_clear_mc();
>  	}
> +	mmput(mm);
>  	return ret;
>  }
>  
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
