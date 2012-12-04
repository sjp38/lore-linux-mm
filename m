Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id C44D36B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:18:00 -0500 (EST)
Date: Tue, 4 Dec 2012 09:17:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] memcg: split part of memcg creation to css_online
Message-ID: <20121204081756.GA31319@dhcp22.suse.cz>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-4-git-send-email-glommer@parallels.com>
 <20121203173205.GI17093@dhcp22.suse.cz>
 <50BDAEC1.8040805@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BDAEC1.8040805@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On Tue 04-12-12 12:05:21, Glauber Costa wrote:
> On 12/03/2012 09:32 PM, Michal Hocko wrote:
> > On Fri 30-11-12 17:31:25, Glauber Costa wrote:
> >> Although there is arguably some value in doing this per se, the main
> >> goal of this patch is to make room for the locking changes to come.
> >>
> >> With all the value assignment from parent happening in a context where
> >> our iterators can already be used, we can safely lock against value
> >> change in some key values like use_hierarchy, without resorting to the
> >> cgroup core at all.
> > 
> > I am sorry but I really do not get why online_css callback is more
> > appropriate. Quite contrary. With this change iterators can see a group
> > which is not fully initialized which calls for a problem (even though it
> > is not one yet).
> 
> But it should be extremely easy to protect against this. It is just a
> matter of not returning online css in the iterator: then we'll never see
> them until they are online. This also sounds a lot more correct than
> returning allocated css.

Yes but... Look at your other patch which relies on iterator when counting
children to find out if there is any available.
 
> > Could you be more specific why we cannot keep the initialization in
> > mem_cgroup_css_alloc? We can lock there as well, no?
> > 
> Because we need to parent value of things like use_hierarchy and
> oom_control not to change after it was copied to a child.
> 
> If we do it in css_alloc, the iterators won't be working yet - nor will
> cgrp->children list, for that matter - and we will risk a situation
> where another thread thinks no children exist, and flips use_hierarchy
> to 1 (or oom_control, etc), right after the children already got the
> value of 0.

You are right. I must have been blind yesterday evening.
 
> The two other ways to solve this problem that I see, are:
> 
> 1) lock in css_alloc and unlock in css_online, that tejun already ruled
> out as too damn ugly (and I can't possibly disagree)

yes, it is really ugly

> 2) have an alternate indication of emptiness that is working since
> css_alloc (like counting number of children).

I do not think it is worth the complication.

> Since I don't share your concerns about the iterator showing incomplete
> memcgs - trivial to fix, if not fixed already - I deemed my approach
> preferable here.

Agreed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
