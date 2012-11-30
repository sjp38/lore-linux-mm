Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1E9FD6B0071
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 04:24:40 -0500 (EST)
Date: Fri, 30 Nov 2012 10:24:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20121130092435.GD29317@dhcp22.suse.cz>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <50B8263C.7060908@jp.fujitsu.com>
 <50B875B4.2020507@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B875B4.2020507@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, paul@paulmenage.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 30-11-12 13:00:36, Glauber Costa wrote:
> On 11/30/2012 07:21 AM, Kamezawa Hiroyuki wrote:
> > (2012/11/29 6:34), Tejun Heo wrote:
> >> Hello, guys.
> >>
> >> Depending on cgroup core locking - cgroup_mutex - is messy and makes
> >> cgroup prone to locking dependency problems.  The current code already
> >> has lock dependency loop - memcg nests get_online_cpus() inside
> >> cgroup_mutex.  cpuset the other way around.
> >>
> >> Regardless of the locking details, whatever is protecting cgroup has
> >> inherently to be something outer to most other locking constructs.
> >> cgroup calls into a lot of major subsystems which in turn have to
> >> perform subsystem-specific locking.  Trying to nest cgroup
> >> synchronization inside other locks isn't something which can work
> >> well.
> >>
> >> cgroup now has enough API to allow subsystems to implement their own
> >> locking and cgroup_mutex is scheduled to be made private to cgroup
> >> core.  This patchset makes cpuset implement its own locking instead of
> >> relying on cgroup_mutex.
> >>
> >> cpuset is rather nasty in this respect.  Some of it seems to have come
> >> from the implementation history - cgroup core grew out of cpuset - but
> >> big part stems from cpuset's need to migrate tasks to an ancestor
> >> cgroup when an hotunplug event makes a cpuset empty (w/o any cpu or
> >> memory).
> >>
> >> This patchset decouples cpuset locking from cgroup_mutex.  After the
> >> patchset, cpuset uses cpuset-specific cpuset_mutex instead of
> >> cgroup_mutex.  This also removes the lockdep warning triggered during
> >> cpu offlining (see 0009).
> >>
> >> Note that this leaves memcg as the only external user of cgroup_mutex.
> >> Michal, Kame, can you guys please convert memcg to use its own locking
> >> too?
> >>
> > 
> > Hmm. let me see....at quick glance cgroup_lock() is used at
> >   hierarchy policy change
> >   kmem_limit
> >   migration policy change
> >   swapiness change
> >   oom control
> > 
> > Because all aboves takes care of changes in hierarchy,
> > Having a new memcg's mutex in ->create() may be a way.
> > 
> > Ah, hm, Costa is mentioning task-attach. is the task-attach problem in memcg ?
> > 
> 
> We disallow the kmem limit to be set if a task already exists in the
> cgroup. So we can't allow a new task to attach if we are setting the limit.

This is racy without additional locking, isn't it?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
