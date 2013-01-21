Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DFE286B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 07:31:05 -0500 (EST)
Date: Mon, 21 Jan 2013 13:30:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 6/6] memcg: avoid dangling reference count in creation
 failure.
Message-ID: <20130121123057.GH7798@dhcp22.suse.cz>
References: <1358766813-15095-1-git-send-email-glommer@parallels.com>
 <1358766813-15095-7-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358766813-15095-7-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Mon 21-01-13 15:13:33, Glauber Costa wrote:
> When use_hierarchy is enabled, we acquire an extra reference count
> in our parent during cgroup creation. We don't release it, though,
> if any failure exist in the creation process.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reported-by: Michal Hocko <mhocko@suse>

If you put this one to the head of the series we can backport it to
stable which is preferred, although nobody have seen this as a problem.

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5a247de..3949123 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6167,6 +6167,8 @@ mem_cgroup_css_online(struct cgroup *cont)
>  		 * call __mem_cgroup_free, so return directly
>  		 */
>  		mem_cgroup_put(memcg);
> +		if (parent->use_hierarchy)
> +			mem_cgroup_put(parent);
>  	}
>  	return error;
>  }
> -- 
> 1.8.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
