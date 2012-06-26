Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 00B826B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:25:23 -0400 (EDT)
Date: Tue, 26 Jun 2012 15:25:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] fix bad behavior in use_hierarchy file
Message-Id: <20120626152522.c7161b5a.akpm@linux-foundation.org>
In-Reply-To: <1340725634-9017-2-git-send-email-glommer@parallels.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
	<1340725634-9017-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dhaval Giani <dhaval.giani@gmail.com>, Tejun Heo <tj@kernel.org>

On Tue, 26 Jun 2012 19:47:13 +0400
Glauber Costa <glommer@parallels.com> wrote:

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

hm.  The various .write_u64() implementations go and return zero on
success and cgroup_write_X64() sees this and rewrites the return value
to `nbytes'.

That was a bit naughty of us - it prevents a .write_u64() instance from
being able to fully implement a partial write.  We can *partially*
implement a partial write, by returning a value between 1 and nbytes-1,
but we can't return zero.  It's a weird interface, it's a surprising
interface and it was quite unnecessary to do it this way.  Someone
please slap Paul.

It's hardly a big problem I, but that's why the unix write() interface
was designed the way it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
