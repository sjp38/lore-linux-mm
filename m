Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAC4sCHD003632
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 10:24:12 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAC4sCHv3338414
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 10:24:12 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAC4sBaL014506
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:54:12 +1100
Message-ID: <491A6163.4040100@linux.vnet.ibm.com>
Date: Wed, 12 Nov 2008 10:23:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] [BUGFIX]cgroup: fix potential deadlock in pre_destroy.
References: <20081112133002.15c929c3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112133002.15c929c3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Balbir, Paul, Li, How about this ?
> =
> As Balbir pointed out, memcg's pre_destroy handler has potential deadlock.
> 
> It has following lock sequence.
> 
> 	cgroup_mutex (cgroup_rmdir)
> 	    -> pre_destroy
> 		-> mem_cgroup_pre_destroy
> 			-> force_empty
> 			   -> lru_add_drain_all->
> 			      -> schedule_work_on_all_cpus
>                                  -> get_online_cpus -> cpuhotplug.lock.
> 
> But, cpuset has following.
> 	cpu_hotplug.lock (call notifier)
> 		-> cgroup_mutex. (within notifier)
> 
> Then, this lock sequence should be fixed.
> 
> Considering how pre_destroy works, it's not necessary to holding
> cgroup_mutex() while calling it. 
> 
> As side effect, we don't have to wait at this mutex while memcg's force_empty
> works.(it can be long when there are tons of pages.)
> 
> Note: memcg is an only user of pre_destroy, now.
> 

I thought about this and it seems promising. My concern is that with
cgroup_mutex given, the state of cgroup within pre-destroy will be
unpredictable. I suspect, if pre-destory really needs cgroup_mutex, we can hold
it within pre-destroy.

BTW, your last check, does not seem right

+	if (atomic_read(&cgrp->count)
+	    || list_empty(&cgrp->children)

Why should list_empty() result in EBUSY, shouldn't it be !list_empty()?

+	    || cgroup_has_css_refs(cgrp)) {


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
