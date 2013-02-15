Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 889AE6B0008
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 03:11:25 -0500 (EST)
Date: Fri, 15 Feb 2013 09:11:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 2/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20130215081122.GB31032@dhcp22.suse.cz>
References: <1360848396-16564-1-git-send-email-mhocko@suse.cz>
 <1360848396-16564-3-git-send-email-mhocko@suse.cz>
 <511DEBBD.1050102@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <511DEBBD.1050102@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri 15-02-13 17:03:09, KAMEZAWA Hiroyuki wrote:
[...]
> > @@ -1158,31 +1161,74 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >   
> >   			mz = mem_cgroup_zoneinfo(root, nid, zid);
> >   			iter = &mz->reclaim_iter[reclaim->priority];
> > -			if (prev && reclaim->generation != iter->generation)
> > -				goto out_css_put;
> > -			id = iter->position;
> > +			spin_lock(&iter->iter_lock);
> > +			last_visited = iter->last_visited;
> > +			if (prev && reclaim->generation != iter->generation) {
> > +				if (last_visited) {
> > +					css_put(&last_visited->css);
> > +					iter->last_visited = NULL;
> > +				}
> > +				spin_unlock(&iter->iter_lock);
> > +				goto out_unlock;
> > +			}
[...]
> > +		/*
> > +		 * Even if we found a group we have to make sure it is alive.
> > +		 * css && !memcg means that the groups should be skipped and
> > +		 * we should continue the tree walk.
> > +		 * last_visited css is safe to use because it is protected by
> > +		 * css_get and the tree walk is rcu safe.
> > +		 */
> > +		if (css == &root->css || (css && css_tryget(css)))
> > +			memcg = mem_cgroup_from_css(css);
> >   
> >   		if (reclaim) {
> > -			iter->position = id;
> > +			struct mem_cgroup *curr = memcg;
> > +
> > +			if (last_visited)
> > +				css_put(&last_visited->css);
> > +
> > +			if (css && !memcg)
> > +				curr = mem_cgroup_from_css(css);
> > +
> > +			/* make sure that the cached memcg is not removed */
> > +			if (curr)
> > +				css_get(&curr->css);
> I'm sorry if I miss something...
> 
> This curr is  curr == memcg = mem_cgroup_from_css(css) <= already try_get() done.
> double refcounted ?

Yes we get 2 references here. One for the returned memcg - which will be
released either by mem_cgroup_iter_break or a next iteration round
(where it would be prev) and the other is for last_visited which is
released when a new memcg is cached.
 
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
