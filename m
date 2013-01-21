Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 1E2AC6B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 03:34:22 -0500 (EST)
Date: Mon, 21 Jan 2013 09:34:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 4/7] memcg: fast hierarchy-aware child test.
Message-ID: <20130121083418.GA7798@dhcp22.suse.cz>
References: <1357897527-15479-1-git-send-email-glommer@parallels.com>
 <1357897527-15479-5-git-send-email-glommer@parallels.com>
 <20130118160610.GI10701@dhcp22.suse.cz>
 <50FCF539.6070000@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FCF539.6070000@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Mon 21-01-13 11:58:49, Glauber Costa wrote:
> On 01/18/2013 08:06 PM, Michal Hocko wrote:
> >> +	/* bounce at first found */
> >> > +	for_each_mem_cgroup_tree(iter, memcg) {
> > This will not work. Consider you will see a !online memcg. What happens?
> > mem_cgroup_iter will css_get group that it returns and css_put it when
> > it visits another one or finishes the loop. So your poor iter will be
> > released before it gets born. Not good.
> > 
> Reading this again, I don't really follow. The iterator is not supposed
> to put() anything it hasn't get()'d before, so we will never release the
> group. Note that if it ever appears in here, the css refcnt is expected
> to be at least 1 already.
> 
> The online test relies on the memcg refcnt, not on the css refcnt.

Bahh, yeah, sorry about the confusion. Damn, it's not the first time I
managed to mix those two...

> Actually, now that the value setting is all done in css_online, the css
> refcnt should be enough to denote if the cgroup already has children,
> without a memcg-specific test. The css refcnt is bumped somewhere
> between alloc and online. 

Yes, in init_cgroup_css.

> Unless Tejun objects it, I think I will just get rid of the online
> test, and rely on the fact that if the iterator sees any children, we
> should already online.

Which means that we are back to list_empty(&cgrp->children) test, aren't
we. We just call it a different name. If you really insist on not using
children directly then do something like:
	struct cgroup *pos;

	if (!memcg->use_hierarchy)
		cgroup_for_each_child(pos, memcg->css.cgroup)
			return true;

	return false;

This still has an issue that a change (e.g. vm_swappiness) that requires
this check will fail even though the child creation fails after it is
made visible (e.g. during css_online).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
