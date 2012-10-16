Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id B5D036B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:34:43 -0400 (EDT)
Date: Tue, 16 Oct 2012 15:34:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
Message-ID: <20121016133439.GI13991@dhcp22.suse.cz>
References: <1350382328-28977-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1350382328-28977-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>, David Rientjes <rientjes@google.com>

On Tue 16-10-12 18:12:08, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Sysctl oom_kill_allocating_task enables or disables killing the OOM-triggering
> task in out-of-memory situations, but it only works on overall system-wide oom.
> But it's also a useful indication in memcg so we take it into consideration
> while oom happening in memcg. Other sysctl such as panic_on_oom has already
> been memcg-ware.

Could you be more specific about the motivation for this patch? Is it
"let's be consistent with the global oom" or you have a real use case
for this knob.

The primary motivation for oom_kill_allocating_task AFAIU was to reduce
search over huge tasklists and reduce task_lock holding times. I am not
sure whether the original concern is still valid since 6b0c81b (mm,
oom: reduce dependency on tasklist_lock) as the tasklist_lock usage has
been reduced conciderably in favor of RCU read locks is taken but maybe
even that can be too disruptive?
David?

Moreover memcg oom killer doesn't iterate over tasklist (it uses
cgroup_iter*) so this shouldn't cause the performance problem like
for the global case.
On the other hand we are taking css_set_lock for reading for the whole
iteration which might cause some issues as well but those should better
be described in the changelog.

> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  mm/memcontrol.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e4e9b18..c329940 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1486,6 +1486,15 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  
>  	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
>  	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
> +	if (sysctl_oom_kill_allocating_task && current->mm &&
> +	    !oom_unkillable_task(current, memcg, NULL) &&
> +	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> +		get_task_struct(current);
> +		oom_kill_process(current, gfp_mask, order, 0, totalpages, memcg, NULL,
> +				 "Memory cgroup out of memory (oom_kill_allocating_task)");
> +		return;
> +	}
> +
>  	for_each_mem_cgroup_tree(iter, memcg) {
>  		struct cgroup *cgroup = iter->css.cgroup;
>  		struct cgroup_iter it;
> -- 
> 1.7.6.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
