Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 74F1A6B0073
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 04:33:52 -0500 (EST)
Message-ID: <50B87D79.5090403@parallels.com>
Date: Fri, 30 Nov 2012 13:33:45 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
References: <1354138460-19286-1-git-send-email-tj@kernel.org> <50B8263C.7060908@jp.fujitsu.com> <50B875B4.2020507@parallels.com> <20121130092435.GD29317@dhcp22.suse.cz>
In-Reply-To: <20121130092435.GD29317@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, paul@paulmenage.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/30/2012 01:24 PM, Michal Hocko wrote:
> On Fri 30-11-12 13:00:36, Glauber Costa wrote:
>> On 11/30/2012 07:21 AM, Kamezawa Hiroyuki wrote:
>>> (2012/11/29 6:34), Tejun Heo wrote:
>>>> Hello, guys.
>>>>
>>>> Depending on cgroup core locking - cgroup_mutex - is messy and makes
>>>> cgroup prone to locking dependency problems.  The current code already
>>>> has lock dependency loop - memcg nests get_online_cpus() inside
>>>> cgroup_mutex.  cpuset the other way around.
>>>>
>>>> Regardless of the locking details, whatever is protecting cgroup has
>>>> inherently to be something outer to most other locking constructs.
>>>> cgroup calls into a lot of major subsystems which in turn have to
>>>> perform subsystem-specific locking.  Trying to nest cgroup
>>>> synchronization inside other locks isn't something which can work
>>>> well.
>>>>
>>>> cgroup now has enough API to allow subsystems to implement their own
>>>> locking and cgroup_mutex is scheduled to be made private to cgroup
>>>> core.  This patchset makes cpuset implement its own locking instead of
>>>> relying on cgroup_mutex.
>>>>
>>>> cpuset is rather nasty in this respect.  Some of it seems to have come
>>>> from the implementation history - cgroup core grew out of cpuset - but
>>>> big part stems from cpuset's need to migrate tasks to an ancestor
>>>> cgroup when an hotunplug event makes a cpuset empty (w/o any cpu or
>>>> memory).
>>>>
>>>> This patchset decouples cpuset locking from cgroup_mutex.  After the
>>>> patchset, cpuset uses cpuset-specific cpuset_mutex instead of
>>>> cgroup_mutex.  This also removes the lockdep warning triggered during
>>>> cpu offlining (see 0009).
>>>>
>>>> Note that this leaves memcg as the only external user of cgroup_mutex.
>>>> Michal, Kame, can you guys please convert memcg to use its own locking
>>>> too?
>>>>
>>>
>>> Hmm. let me see....at quick glance cgroup_lock() is used at
>>>   hierarchy policy change
>>>   kmem_limit
>>>   migration policy change
>>>   swapiness change
>>>   oom control
>>>
>>> Because all aboves takes care of changes in hierarchy,
>>> Having a new memcg's mutex in ->create() may be a way.
>>>
>>> Ah, hm, Costa is mentioning task-attach. is the task-attach problem in memcg ?
>>>
>>
>> We disallow the kmem limit to be set if a task already exists in the
>> cgroup. So we can't allow a new task to attach if we are setting the limit.
> 
> This is racy without additional locking, isn't it?
> 
Apparently, the way Tejun fixed this for cpuset was by using the
"attach_in_progress" indicator, that IIUC, is flipped up in
->can_attach, and down in ->attach.

A similar scheme would work for us.

And we should also be using a similar scheme for cgroup creation:
the css is not really connected to the parent until after
memcg_alloc_css. So if we use the memcg iterator to figure out if
children exist, we may get a race where we believe no children exist,
but one appear right after.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
