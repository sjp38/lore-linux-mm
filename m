Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC4uU3x017695
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 13:56:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CD8BE45DE3D
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 13:56:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D64D1EF085
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 13:56:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FD79E08001
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 13:56:30 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D7691DB803E
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 13:56:25 +0900 (JST)
Date: Wed, 12 Nov 2008 13:55:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [BUGFIX]cgroup: fix potential deadlock in pre_destroy.
Message-Id: <20081112135548.74503b7b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <491A6163.4040100@linux.vnet.ibm.com>
References: <20081112133002.15c929c3.kamezawa.hiroyu@jp.fujitsu.com>
	<491A6163.4040100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 10:23:55 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Balbir, Paul, Li, How about this ?
> > =
> > As Balbir pointed out, memcg's pre_destroy handler has potential deadlock.
> > 
> > It has following lock sequence.
> > 
> > 	cgroup_mutex (cgroup_rmdir)
> > 	    -> pre_destroy
> > 		-> mem_cgroup_pre_destroy
> > 			-> force_empty
> > 			   -> lru_add_drain_all->
> > 			      -> schedule_work_on_all_cpus
> >                                  -> get_online_cpus -> cpuhotplug.lock.
> > 
> > But, cpuset has following.
> > 	cpu_hotplug.lock (call notifier)
> > 		-> cgroup_mutex. (within notifier)
> > 
> > Then, this lock sequence should be fixed.
> > 
> > Considering how pre_destroy works, it's not necessary to holding
> > cgroup_mutex() while calling it. 
> > 
> > As side effect, we don't have to wait at this mutex while memcg's force_empty
> > works.(it can be long when there are tons of pages.)
> > 
> > Note: memcg is an only user of pre_destroy, now.
> > 
> 
> I thought about this and it seems promising. My concern is that with
> cgroup_mutex given, the state of cgroup within pre-destroy will be
> unpredictable. I suspect, if pre-destory really needs cgroup_mutex, we can hold
> it within pre-destroy.
> 
I agree.

> BTW, your last check, does not seem right
> 
> +	if (atomic_read(&cgrp->count)
> +	    || list_empty(&cgrp->children)
> 
> Why should list_empty() result in EBUSY, shouldn't it be !list_empty()?
> 
> +	    || cgroup_has_css_refs(cgrp)) {
>
Oh, my bad...

will fix soon.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
