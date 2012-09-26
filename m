Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D205E6B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 12:01:29 -0400 (EDT)
Date: Wed, 26 Sep 2012 18:01:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120926160126.GF15801@dhcp22.suse.cz>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
 <1347977050-29476-5-git-send-email-glommer@parallels.com>
 <20120926140347.GD15801@dhcp22.suse.cz>
 <50631226.9050304@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50631226.9050304@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 26-09-12 18:33:10, Glauber Costa wrote:
> On 09/26/2012 06:03 PM, Michal Hocko wrote:
> > On Tue 18-09-12 18:04:01, Glauber Costa wrote:
[...]
> >> @@ -4961,6 +5015,12 @@ mem_cgroup_create(struct cgroup *cont)
> >>  		int cpu;
> >>  		enable_swap_cgroup();
> >>  		parent = NULL;
> >> +
> >> +#ifdef CONFIG_MEMCG_KMEM
> >> +		WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys,
> >> +					   kmem_cgroup_files));
> >> +#endif
> >> +
> >>  		if (mem_cgroup_soft_limit_tree_init())
> >>  			goto free_out;
> >>  		root_mem_cgroup = memcg;
> >> @@ -4979,6 +5039,7 @@ mem_cgroup_create(struct cgroup *cont)
> >>  	if (parent && parent->use_hierarchy) {
> >>  		res_counter_init(&memcg->res, &parent->res);
> >>  		res_counter_init(&memcg->memsw, &parent->memsw);
> >> +		res_counter_init(&memcg->kmem, &parent->kmem);
> > 
> > Haven't we already discussed that a new memcg should inherit kmem_accounted
> > from its parent for use_hierarchy?
> > Say we have
> > root
> > |
> > A (kmem_accounted = 1, use_hierachy = 1)
> >  \
> >   B (kmem_accounted = 0)
> >    \
> >     C (kmem_accounted = 1)
> > 
> > B find's itself in an awkward situation becuase it doesn't want to
> > account u+k but it ends up doing so becuase C.
> > 
> 
> Ok, I haven't updated it here. But that should be taken care of in the
> lifecycle patch.

I am not sure which patch you are thinking about but I would prefer to
have it here because it is safe wrt. races and it is more obvious as
well.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
