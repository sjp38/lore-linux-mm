Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B901D6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 02:42:52 -0400 (EDT)
Date: Tue, 9 Apr 2013 08:42:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/8] cgroup: implement cgroup_is_ancestor()
Message-ID: <20130409064239.GA29860@dhcp22.suse.cz>
References: <51627DA9.7020507@huawei.com>
 <51627DBB.5050005@huawei.com>
 <20130408144750.GK17178@dhcp22.suse.cz>
 <20130408180335.GA22512@dhcp22.suse.cz>
 <20130408213646.GB17159@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130408213646.GB17159@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon 08-04-13 14:36:46, Tejun Heo wrote:
> On Mon, Apr 08, 2013 at 08:03:44PM +0200, Michal Hocko wrote:
> > __mem_cgroup_same_or_subtree relies on css_is_ancestor if hierarchy is
> > enabled for ages. This, however, is not correct because use_hierarchy
> > doesn't need to be true all the way up the cgroup hierarchy. Consider
> > the following example:
> > root (use_hierarchy=0)
> >  \
> >   A (use_hierarchy=0)
> >    \
> >     B (use_hierarchy=1)
> >      \
> >       C (use_hierarchy=1)
> > 
> > __mem_cgroup_same_or_subtree(A, C) would return true even though C is
> > not from the same hierarchy subtree. The bug shouldn't be critical but
> > at least dump_tasks might print unrelated tasks (via
> > task_in_mem_cgroup).
> 
> Huh?  Isn't that avoided by the !root_memcg->use_hierarchy test?

Yes, it is. My selective blindness strikes again :/ I was convinced that
it was memcg we tested use_hierarchy for...
Sorry about all the churn.

> > @@ -1470,9 +1470,12 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> >  {
> >  	if (root_memcg == memcg)
> >  		return true;
> > -	if (!root_memcg->use_hierarchy || !memcg)
>             ^^^^^^^^^^^^^^^^^^^^^^^^^^
> > +	if (!memcg)
> >  		return false;
> > -	return css_is_ancestor(&memcg->css, &root_memcg->css);
> > +	while ((memcg = parent_mem_cgroup(memcg)))
> > +		if (memcg == root_memcg)
> > +			return true;
> > +	return false;
> >  }
> >  
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
