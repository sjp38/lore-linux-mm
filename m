Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id AB32A6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:04:56 -0400 (EDT)
Received: by dakp5 with SMTP id p5so270788dak.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:04:56 -0700 (PDT)
Date: Tue, 26 Jun 2012 11:04:51 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120626180451.GP3869@google.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340725634-9017-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 26, 2012 at 07:47:14PM +0400, Glauber Costa wrote:
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

So, ummm, I don't think we can do this.  We CAN NOT silently flip the
default behavior like this.  Hell, no.  What we can do is something
like the following.

1. Make .use_hierarchy a global property and convert .use_hierarchy
   file to reject writes to the setting which is different from the
   global one.  Rip out partial hierarchy related code (how little
   they may be).  Note that the default should still be flat
   hierarchy.

2. Mark flat hierarchy deprecated and produce a warning message if
   memcg is mounted w/o hierarchy option for a year or two.

3. After the existing users had enough chance to move away from flat
   hierarchy, rip out flat hierarchy code and error if hierarchy
   option is not specified.

Later on, we may decide to get rid of the hierarchy mount option but I
don't think that matters all that much.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
