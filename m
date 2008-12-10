Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBABTgRk026213
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 20:29:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D1A645DE4F
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 20:29:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DB3645DD72
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 20:29:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 65A4F1DB803B
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 20:29:42 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DED81DB803A
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 20:29:42 +0900 (JST)
Message-ID: <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com><20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
    <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
Date: Wed, 10 Dec 2008 20:29:41 +0900 (JST)
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Paul Menage said:
> The reason for needing this patch is because of the non-atomic locking
> in cgroup_rmdir() that was introduced due to the circular locking
> dependency between the hotplug lock and the cgroup_mutex.
>
> But rather than adding a whole bunch more complexity, this looks like
> another case that could be solved by the hierarchy_mutex patches that
> I posted a while ago.
>
removing cgroup_lock() from memcg's reclaim path is okay.
(and I posted patch...)
But, prevent css_get() after pre_destroy() is another problem.

(BTW, I don't like hierarchy-walk-by-small-locks approarch now because
 I'd like to implement scan-and-stop-continue routine.
 See how readdir() aginst /proc scans PID. It's very roboust against
 very temporal PIDs.)

> Those allow the cpuset hotplug notifier (and any other subsystem that
> wants a stable hierarchy) to take ss->hierarchy_mutex, to prevent
> mkdir/rmdir/bind in its hierarchy, which helps to remove the deadlock
> that the above dropping of cgroup_mutex was introduced to work around.
>
>>
>> Considering above sequence, new tasks can be added while
>>        (B) and (C)
>> swap-in recored can be charged back to a cgroup after pre_destroy()
>>        at (C) and (D), (E)
>> (means cgrp's refcnt not comes from task but from other persistent
>> objects.)
>
> Which "persistent object" are you getting the css refcount from?
>
page_cgroup generated from swap_cgroup.

> Is the problem that swap references aren't refcounted because you want
> to avoid swap from keeping a cgroup alive?
Yes. There is no operations allows users to make swap on memory.
> But you still want to be able to do css_get() on the mem_cgroup*
obtained from a swap
> reference, and be safely synchronized with concurrent rmdir operations
> without having to take a heavy lock?
>
yes. I don't want any locks.

> The solution that I originally tried to use for this in an early
> version of cgroups (but dropped as I thought it was not needed) was to
> treat css->refcount as follows:
>
>  0 => trying to remove or removed
>  1 => normal state with no additional refs
>
> So to get a reference on a possibly removed css we'd have:
>
> int css_tryget(css) {
>   while (!atomic_inc_not_zero(&css->refcount)) {
>     if (test_bit(CSS_REMOVED, &css->flags)) {
>       return 0;
>     }
>   }
>   return 1;
> }
>
> and cgroup_rmdir would do:
>
> for_each_subsys() {
>   if (cmpxchg(&css->refcount, 0, -1)) {
>     // busy, roll back -1s to 0s, give error
>     ...
>   }
> }
> // success
> for_each_subsys() {
>   set_bit(CSS_REMOVED, &css->flags);
> }
>
> This makes it easy to have weak references to a css that can be
> dropped in a destroy() callback.
I tried similar patch and made it to use only one shared refcnt.
(my previous patch...)

We need rolling update of refcnts and rollback. Such code tends to make
a hole (This was what my first patch did...).
And there is no fundamental difference between my shared refcnt and
css_tryget() patch. Maybe above will give us better cache localily.

Anyway, I have no objections to rolling update of refcnt and tryget().
If it's a way to go, I'll go ahead.

> Would this maybe even remove the need for mem_cgroup_pre_destroy()?
>
Yes and No. not sure. but my thinking is No.

1. pre_destroy() is called by rmdir(), in synchronized manner.
   This means that all refs in memcg will be removed at rmdir().
   If we drop refs at destroy(), it happens when dput()'s refcnt finally
   goes down to 0. This asynchronous manner is not good for users.

2. Current pre_destroy() code is very young. And we don't find any
   corner case in which pre_destroy() can't complete thier works.
   So, I don't want to remove pre_destroy() for a while.

3. Sometimes, pre_destroy() have to call try_to_free_pages() and
   we cannot know we can call try_to_free_page() in dput().

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
