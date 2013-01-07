Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 0F3136B0072
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 03:12:39 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9936C3EE0C7
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 17:12:38 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7557C45DD74
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 17:12:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A32F45DE50
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 17:12:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E7871DB803C
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 17:12:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C3F1B1DB8042
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 17:12:37 +0900 (JST)
Message-ID: <50EA8355.5080007@jp.fujitsu.com>
Date: Mon, 07 Jan 2013 17:12:05 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET] cpuset: decouple cpuset locking from cgroup core,
 take#2
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
In-Reply-To: <1357248967-24959-1-git-send-email-tj@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2013/01/04 6:35), Tejun Heo wrote:
> Hello, guys.
> 
> This is the second attempt at decoupling cpuset locking from cgroup
> core.  Changes from the last take[L] are
> 
> * cpuset-drop-async_rebuild_sched_domains.patch moved from 0007 to
>    0009.  This reordering makes cpu hotplug handling async first and
>    removes the temporary cyclic locking dependency.
> 
> * 0006-cpuset-cleanup-cpuset-_can-_attach.patch no longer converts
>    cpumask_var_t to cpumask_t as per Rusty Russell.
> 
> * 0008-cpuset-don-t-nest-cgroup_mutex-inside-get_online_cpu.patch now
>    synchronously rebuilds sched domains from cpu hotplug callback.
>    This fixes various issues caused by confused scheduler puttings
>    tasks into a dead cpu including the RCU stall problem reported by Li
>    Zefan.
> 
> Original patchset description follows.
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

Okay...but If Costa has a new version of his patch, I'd like to see it.
I'm sorry if I missed his new patches for removing cgroup_lock.

Thanks,
-Kame

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
