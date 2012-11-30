Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 496C26B0070
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 22:22:35 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7F0BA3EE0BD
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:22:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 583F245DEC0
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:22:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 33CDB45DEBA
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:22:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 20D6B1DB8043
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:22:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE3B91DB8040
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:22:31 +0900 (JST)
Message-ID: <50B8263C.7060908@jp.fujitsu.com>
Date: Fri, 30 Nov 2012 12:21:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
In-Reply-To: <1354138460-19286-1-git-send-email-tj@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/11/29 6:34), Tejun Heo wrote:
> Hello, guys.
> 
> Depending on cgroup core locking - cgroup_mutex - is messy and makes
> cgroup prone to locking dependency problems.  The current code already
> has lock dependency loop - memcg nests get_online_cpus() inside
> cgroup_mutex.  cpuset the other way around.
> 
> Regardless of the locking details, whatever is protecting cgroup has
> inherently to be something outer to most other locking constructs.
> cgroup calls into a lot of major subsystems which in turn have to
> perform subsystem-specific locking.  Trying to nest cgroup
> synchronization inside other locks isn't something which can work
> well.
> 
> cgroup now has enough API to allow subsystems to implement their own
> locking and cgroup_mutex is scheduled to be made private to cgroup
> core.  This patchset makes cpuset implement its own locking instead of
> relying on cgroup_mutex.
> 
> cpuset is rather nasty in this respect.  Some of it seems to have come
> from the implementation history - cgroup core grew out of cpuset - but
> big part stems from cpuset's need to migrate tasks to an ancestor
> cgroup when an hotunplug event makes a cpuset empty (w/o any cpu or
> memory).
> 
> This patchset decouples cpuset locking from cgroup_mutex.  After the
> patchset, cpuset uses cpuset-specific cpuset_mutex instead of
> cgroup_mutex.  This also removes the lockdep warning triggered during
> cpu offlining (see 0009).
> 
> Note that this leaves memcg as the only external user of cgroup_mutex.
> Michal, Kame, can you guys please convert memcg to use its own locking
> too?
> 

Hmm. let me see....at quick glance cgroup_lock() is used at
  hierarchy policy change
  kmem_limit
  migration policy change
  swapiness change
  oom control

Because all aboves takes care of changes in hierarchy,
Having a new memcg's mutex in ->create() may be a way.

Ah, hm, Costa is mentioning task-attach. is the task-attach problem in memcg ?

Thanks,
-Kame











> This patchset contains the following thirteen patches.
> 
>   0001-cpuset-remove-unused-cpuset_unlock.patch
>   0002-cpuset-remove-fast-exit-path-from-remove_tasks_in_em.patch
>   0003-cpuset-introduce-css_on-offline.patch
>   0004-cpuset-introduce-CS_ONLINE.patch
>   0005-cpuset-introduce-cpuset_for_each_child.patch
>   0006-cpuset-cleanup-cpuset-_can-_attach.patch
>   0007-cpuset-drop-async_rebuild_sched_domains.patch
>   0008-cpuset-reorganize-CPU-memory-hotplug-handling.patch
>   0009-cpuset-don-t-nest-cgroup_mutex-inside-get_online_cpu.patch
>   0010-cpuset-make-CPU-memory-hotplug-propagation-asynchron.patch
>   0011-cpuset-pin-down-cpus-and-mems-while-a-task-is-being-.patch
>   0012-cpuset-schedule-hotplug-propagation-from-cpuset_atta.patch
>   0013-cpuset-replace-cgroup_mutex-locking-with-cpuset-inte.patch
> 
> 0001-0006 are prep patches.
> 
> 0007-0009 make cpuset nest get_online_cpus() inside cgroup_mutex, not
> the other way around.
> 
> 0010-0012 plug holes which would be exposed by switching to
> cpuset-specific locking.
> 
> 0013 replaces cgroup_mutex with cpuset_mutex.
> 
> This patchset is on top of cgroup/for-3.8 (fddfb02ad0) and also
> available in the following git branch.
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cpuset-locking
> 
> diffstat follows.
> 
>   kernel/cpuset.c |  750 +++++++++++++++++++++++++++++++-------------------------
>   1 file changed, 423 insertions(+), 327 deletions(-)
> 
> Thanks.
> 
> --
> tejun
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
