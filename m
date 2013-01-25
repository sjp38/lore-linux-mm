Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 08E6A6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 05:05:01 -0500 (EST)
Message-ID: <510258D0.6060407@parallels.com>
Date: Fri, 25 Jan 2013 14:05:04 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 0/6] replace cgroup_lock with memcg specific locking
References: <1358862461-18046-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1358862461-18046-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On 01/22/2013 05:47 PM, Glauber Costa wrote:
> Hi,
> 
> In memcg, we use the cgroup_lock basically to synchronize against
> attaching new children to a cgroup. We do this because we rely on cgroup core to
> provide us with this information.
> 
> We need to guarantee that upon child creation, our tunables are consistent.
> For those, the calls to cgroup_lock() all live in handlers like
> mem_cgroup_hierarchy_write(), where we change a tunable in the group that is
> hierarchy-related. For instance, the use_hierarchy flag cannot be changed if
> the cgroup already have children.
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
> assignment. This will guarantee that parent and children always have consistent
> values. Together with an online test, that can be derived from the observation
> that the refcount of an online memcg can be made to be always positive, we
> should be able to synchronize our side without the cgroup lock.
> 
> *v4:
>  - revert back to using the set_limit_mutex for kmemcg limit setting.
> 
> *v3:
>  - simplified test for presence of children, and no longer using refcnt for
>    online testing
>  - some cleanups as suggested by Michal
> 
> *v2:
>  - sanitize kmemcg assignment in the light of the current locking change.
>  - don't grab locks on immigrate charges by caching the value during can_attach
> 
> Glauber Costa (6):
>   memcg: prevent changes to move_charge_at_immigrate during task attach
>   memcg: split part of memcg creation to css_online
>   memcg: fast hierarchy-aware child test.
>   memcg: replace cgroup_lock with memcg specific memcg_lock
>   memcg: increment static branch right after limit set.
>   memcg: avoid dangling reference count in creation failure.
> 

Tejun,

This applies ontop of your cpuset patches. Would you pick this (would be
my choice), or would you rather have it routed through somewhere mmish ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
