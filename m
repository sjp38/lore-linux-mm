Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CF7D16B00C4
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:52:35 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so543198pbc.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 07:52:35 -0800 (PST)
Date: Fri, 30 Nov 2012 07:52:28 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/4] replace cgroup_lock with local lock in memcg
Message-ID: <20121130155228.GE3873@htj.dyndns.org>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354282286-32278-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

Hey, Glauber.

I don't know enough about memcg to be acking this but overall it looks
pretty good to me.

On Fri, Nov 30, 2012 at 05:31:22PM +0400, Glauber Costa wrote:
> For the problem of attaching tasks, I am using something similar to cpusets:
> when task attaching starts, we will flip a flag "attach_in_progress", that will
> be flipped down when it finishes. This way, all readers can know that a task is
> joining the group and take action accordingly. With this, we can guarantee that
> the behavior of move_charge_at_immigrate continues safe

Yeap, attach_in_progress is useful if there are some conditions which
shouldn't change between ->can_attach() and ->attach().  With the
immigrate thing gone, this no longer is necessary, right?

> Protecting against children creation requires a bit more work. For those, the
> calls to cgroup_lock() all live in handlers like mem_cgroup_hierarchy_write(),
> where we change a tunable in the group, that is hierarchy-related. For
> instance, the use_hierarchy flag cannot be changed if the cgroup already have
> children.
> 
> Furthermore, those values are propageted from the parent to the child when a
> new child is created. So if we don't lock like this, we can end up with the
> following situation:
> 
> A                                   B
>  memcg_css_alloc()                       mem_cgroup_hierarchy_write()
>  copy use hierarchy from parent          change use hierarchy in parent
>  finish creation.
> 
> This is mainly because during create, we are still not fully connected to the
> css tree. So all iterators and the such that we could use, will fail to show
> that the group has children.
> 
> My observation is that all of creation can proceed in parallel with those
> tasks, except value assignment. So what this patchseries does is to first move
> all value assignment that is dependent on parent values from css_alloc to
> css_online, where the iterators all work, and then we lock only the value
> assignment. This will guarantee that parent and children always have
> consistent values.

Right, exactly the reason ->css_online() exists.

Thanks a lot!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
