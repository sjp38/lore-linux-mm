Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 857446B006C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 05:33:13 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb30so2942871vcb.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 02:33:12 -0800 (PST)
Date: Fri, 23 Nov 2012 11:33:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: debugging facility to access dangling memcgs.
Message-ID: <20121123103307.GH24698@dhcp22.suse.cz>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
 <1353580190-14721-3-git-send-email-glommer@parallels.com>
 <20121123092010.GD24698@dhcp22.suse.cz>
 <50AF42F0.6040407@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50AF42F0.6040407@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On Fri 23-11-12 13:33:36, Glauber Costa wrote:
> On 11/23/2012 01:20 PM, Michal Hocko wrote:
> > On Thu 22-11-12 14:29:50, Glauber Costa wrote:
> > [...]
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 05b87aa..46f7cfb 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> > [...]
> >> @@ -349,6 +366,33 @@ struct mem_cgroup {
> >>  #endif
> >>  };
> >>  
> >> +#if defined(CONFIG_MEMCG_KMEM) || defined(CONFIG_MEMCG_SWAP)
> > 
> > Can we have a common config for this something like CONFIG_MEMCG_ASYNC_DESTROY
> > which would be selected if either of the two (or potentially others)
> > would be selected.
> > Also you are saying that the feature is only for debugging purposes so
> > it shouldn't be on by default probably.
> > 
> 
> I personally wouldn't mind. But the big value I see from it is basically
> being able to turn it off. For all the rest, we would have to wrap it
> under one of those config options anyway...

Sure you would need to habe mem_cgroup_dangling_FOO wrapped by the
correct one anyway but that still need to live inside a bigger ifdef and
naming all the FOO is awkward. Besides that one
CONFIG_MEMCG_ASYNC_DESTROY_DEBUG could have a Kconfig entry and so be
enabled separately.

> >> +static LIST_HEAD(dangling_memcgs);
> >> +static DEFINE_MUTEX(dangling_memcgs_mutex);
> >> +
> >> +static inline void memcg_dangling_free(struct mem_cgroup *memcg)
> >> +{
> >> +	mutex_lock(&dangling_memcgs_mutex);
> >> +	list_del(&memcg->dead);
> >> +	mutex_unlock(&dangling_memcgs_mutex);
> >> +	kfree(memcg->memcg_name);
> >> +}
> >> +
> >> +static inline void memcg_dangling_add(struct mem_cgroup *memcg)
> >> +{
> >> +
> >> +	memcg->memcg_name = kstrdup(cgroup_name(memcg->css.cgroup), GFP_KERNEL);
> > 
> > Who gets charged for this allocation? What if the allocation fails (not
> > that it would be probable but still...)?
> > 
> 
> Well, yeah, the lack of test is my bad - sorry.
> 
> As for charging, This will be automatically charged to whoever calls
> mem_cgroup_destroy().

Which can be anybody as it depends e.g. on css reference counting.

> It is certainly not in the cgroup being destroyed, otherwise it would
> have a task and destruction would not be possible.
> 
> But now that you mention, maybe it would be better to get it to the root
> cgroup every time? This way this can't itself hold anybody in memory.

yes, root cgroup sounds good.

[...]
> > It would be better if we could preserve the whole group name (something
> > like cgroup_path does) but I guess this would break caches names, right?
> 
> I can't see how it would influence the cache names either way. I mean -
> the effect of that would be that patches 1 and 2 here would be totally
> independent, since we would be using cgroup_path instead of cgroup_name
> in this facility.

Ohh, you are right you are using kmem_cache name for those. Sorry for
the confusion
 
> > And finally it would be really nice if you described what is the
> > exported information good for. Can I somehow change the current state
> > (e.g. force freeing those objects so that the memcg can finally pass out
> > in piece)?
> > 
> I am open, but I would personally like to have this as a view-only
> interface,

And I was not proposing to make it RW. I am just missing a description
that would explain: "Ohh well, the file says there are some dangling
memcgs. Should I report a bug or sue somebody or just have a coffee and
wait some more?"

> just so we suspect a leak occurs, we can easily see what is
> the dead memcg contribution to it. It shows you where the data come
> from, and if you want to free it, you go search for subsystem-specific
> ways to force a free should you want.

Yes, I can imagine its usefulness for developers but I do not see much
of an use for admins yet. So I am a bit hesitant for this being on by
default.

> I really can't see anything good coming from being able to force changes
> to the kernel from this interface.

Agreed. Definitely not from this interface.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
