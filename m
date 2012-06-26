Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id B069A6B005C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:52:32 -0400 (EDT)
Date: Tue, 26 Jun 2012 17:52:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] fix bad behavior in use_hierarchy file
Message-ID: <20120626155229.GH9566@tiehlicka.suse.cz>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340725634-9017-2-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dhaval Giani <dhaval.giani@gmail.com>

On Tue 26-06-12 19:47:13, Glauber Costa wrote:
> I have an application that does the following:
> 
> * copy the state of all controllers attached to a hierarchy
> * replicate it as a child of the current level.
> 
> I would expect writes to the files to mostly succeed, since they
> are inheriting sane values from parents.
> 
> But that is not the case for use_hierarchy. If it is set to 0, we
> succeed ok. If we're set to 1, the value of the file is automatically
> set to 1 in the children, but if userspace tries to write the
> very same 1, it will fail. That same situation happens if we
> set use_hierarchy, create a child, and then try to write 1 again.
> 
> Now, there is no reason whatsoever for failing to write a value
> that is already there. It doesn't even match the comments, that
> states:
> 
>  /* If parent's use_hierarchy is set, we can't make any modifications
>   * in the child subtrees...
> 
> since we are not changing anything.
> 
> The following patch tests the new value against the one we're storing,
> and automatically return 0 if we're not proposing a change.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Dhaval Giani <dhaval.giani@gmail.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index df8c9fb..85f7790 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3989,6 +3989,10 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  		parent_memcg = mem_cgroup_from_cont(parent);
>  
>  	cgroup_lock();
> +
> +	if (memcg->use_hierarchy == val)
> +		goto out;
> +
>  	/*
>  	 * If parent's use_hierarchy is set, we can't make any modifications
>  	 * in the child subtrees. If it is unset, then the change can
> @@ -4005,6 +4009,8 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  			retval = -EBUSY;
>  	} else
>  		retval = -EINVAL;
> +
> +out:
>  	cgroup_unlock();
>  
>  	return retval;
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
