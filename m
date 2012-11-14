Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 227086B0080
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 03:51:33 -0500 (EST)
Date: Wed, 14 Nov 2012 09:51:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/5] memcg: rework mem_cgroup_iter to use cgroup iterators
Message-ID: <20121114085129.GC17111@dhcp22.suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <1352820639-13521-3-git-send-email-mhocko@suse.cz>
 <20121113161442.GA18227@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121113161442.GA18227@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>

On Tue 13-11-12 08:14:42, Tejun Heo wrote:
> On Tue, Nov 13, 2012 at 04:30:36PM +0100, Michal Hocko wrote:
> > @@ -1063,8 +1063,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  				   struct mem_cgroup *prev,
> >  				   struct mem_cgroup_reclaim_cookie *reclaim)
> >  {
> > -	struct mem_cgroup *memcg = NULL;
> > -	int id = 0;
> > +	struct mem_cgroup *memcg = NULL,
> > +			  *last_visited = NULL;
> 
> Nitpick but please don't do this.

OK, will make it grep friendlier;

> > +		/*
> > +		 * Root is not visited by cgroup iterators so it needs a special
> > +		 * treatment.
> > +		 */
> > +		if (!last_visited) {
> > +			css = &root->css;
> > +		} else {
> > +			struct cgroup *next_cgroup;
> > +
> > +			next_cgroup = cgroup_next_descendant_pre(
> > +					last_visited->css.cgroup,
> > +					root->css.cgroup);
> > +			if (next_cgroup)
> > +				css = cgroup_subsys_state(next_cgroup,
> > +						mem_cgroup_subsys_id);
> 
> Hmmm... wouldn't it be better to move the reclaim logic into a
> function and do the following?
> 
> 	reclaim(root);
> 	for_each_descendent_pre()
> 		reclaim(descendant);

We cannot do for_each_descendent_pre here because we do not iterate
through the whole hierarchy all the time. Check shrink_zone.

> If this is a problem, I'd be happy to add a iterator which includes
> the top node.  

This would help with the above if-else but I do not think this is the
worst thing in the function ;)

> I'd prefer controllers not using the next functions directly.

Well, we will need to use it directly because of the single group
reclaim mentioned above.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
