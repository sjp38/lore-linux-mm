Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 2EAD26B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:15:04 -0400 (EDT)
Date: Tue, 26 Jun 2012 18:15:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120626161501.GI9566@tiehlicka.suse.cz>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340725634-9017-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Tue 26-06-12 19:47:14, Glauber Costa wrote:
> Okay, so after recent discussions, I am proposing the following
> patch. It won't remove hierarchy, or anything like that. Just default
> to true in the root cgroup, and print a warning once if you try
> to set it back to 0.
> 
> I am not adding it to feature-removal-schedule.txt because I don't
> view it as a consensus. Rather, changing the default would allow us
> to give it a time around in the open, and see if people complain
> and what we can learn about that.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Tejun Heo <tj@kernel.org>
> ---
>  mm/memcontrol.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 85f7790..c37e4c1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3993,6 +3993,10 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  	if (memcg->use_hierarchy == val)
>  		goto out;
>  
> +	WARN_ONCE(!parent_memcg && memcg->use_hierarchy,

Do you have to test anything here at all? The test above will get you
out without doing anything if you are not trying to change anything.
The default is true so you have to be trying to disable it.

If you omit !parent_memcg test as well you will get a bonus of the early
warning even if somebody has cgconfig.conf like this:

	group a/b/c {
		memory {
			memory.use_hierarchy = 0;
			[...]
		}
	}

which worked previously...
True there is a risk of a "false warning" when somebody just tries to
set disable hierarchy when it is (and never was) allowed but I do not
think this is that bad.
The configuration like this is rather artificial but I guess we should
try to be foolproof.

> +	"Non-hierarchical memcg is considered for deprecation\n"
> +	"Please consider reorganizing your tree to work with hierarchical accounting\n"
> +	"If you have any reason not to, let us know at cgroups@vger.kernel.org\n");
>  	/*
>  	 * If parent's use_hierarchy is set, we can't make any modifications
>  	 * in the child subtrees. If it is unset, then the change can
> @@ -5221,6 +5225,7 @@ mem_cgroup_create(struct cgroup *cont)
>  			INIT_WORK(&stock->work, drain_local_stock);
>  		}
>  		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
> +		memcg->use_hierarchy = true;
>  	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		memcg->use_hierarchy = parent->use_hierarchy;
> -- 
> 1.7.10.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
