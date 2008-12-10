Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id mBADQ072019231
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 18:56:00 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBADP2Pe4173902
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 18:55:02 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id mBADQ0fx013111
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 00:26:00 +1100
Date: Wed, 10 Dec 2008 18:55:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Message-ID: <20081210132559.GF25467@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com> <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-10 20:29:41]:

> Paul Menage said:
> > The reason for needing this patch is because of the non-atomic locking
> > in cgroup_rmdir() that was introduced due to the circular locking
> > dependency between the hotplug lock and the cgroup_mutex.
> >
> > But rather than adding a whole bunch more complexity, this looks like
> > another case that could be solved by the hierarchy_mutex patches that
> > I posted a while ago.
> >

Paul, I can't find those patches in -mm. I will try and dig them out
from my mbox. I agree, we need a hierarchy_mutex, cgroup_mutex is
becoming the next BKL.

> removing cgroup_lock() from memcg's reclaim path is okay.
> (and I posted patch...)
> But, prevent css_get() after pre_destroy() is another problem.
> 
> (BTW, I don't like hierarchy-walk-by-small-locks approarch now because
>  I'd like to implement scan-and-stop-continue routine.
>  See how readdir() aginst /proc scans PID. It's very roboust against
>  very temporal PIDs.)
> 
> > Those allow the cpuset hotplug notifier (and any other subsystem that
> > wants a stable hierarchy) to take ss->hierarchy_mutex, to prevent
> > mkdir/rmdir/bind in its hierarchy, which helps to remove the deadlock
> > that the above dropping of cgroup_mutex was introduced to work around.
> >
> >>
> >> Considering above sequence, new tasks can be added while
> >>        (B) and (C)
> >> swap-in recored can be charged back to a cgroup after pre_destroy()
> >>        at (C) and (D), (E)
> >> (means cgrp's refcnt not comes from task but from other persistent
> >> objects.)
> >
> > Which "persistent object" are you getting the css refcount from?
> >
> page_cgroup generated from swap_cgroup.
> 
> > Is the problem that swap references aren't refcounted because you want
> > to avoid swap from keeping a cgroup alive?
> Yes. There is no operations allows users to make swap on memory.
> > But you still want to be able to do css_get() on the mem_cgroup*
> obtained from a swap
> > reference, and be safely synchronized with concurrent rmdir operations
> > without having to take a heavy lock?
> >
> yes. I don't want any locks.
> 
> > The solution that I originally tried to use for this in an early
> > version of cgroups (but dropped as I thought it was not needed) was to
> > treat css->refcount as follows:
> >
> >  0 => trying to remove or removed
> >  1 => normal state with no additional refs
> >
> > So to get a reference on a possibly removed css we'd have:
> >
> > int css_tryget(css) {
> >   while (!atomic_inc_not_zero(&css->refcount)) {
> >     if (test_bit(CSS_REMOVED, &css->flags)) {
> >       return 0;
> >     }
> >   }
> >   return 1;
> > }
> >
> > and cgroup_rmdir would do:
> >
> > for_each_subsys() {
> >   if (cmpxchg(&css->refcount, 0, -1)) {
> >     // busy, roll back -1s to 0s, give error
> >     ...
> >   }
> > }
> > // success
> > for_each_subsys() {
> >   set_bit(CSS_REMOVED, &css->flags);
> > }
> >
> > This makes it easy to have weak references to a css that can be
> > dropped in a destroy() callback.
> I tried similar patch and made it to use only one shared refcnt.
> (my previous patch...)
> 
> We need rolling update of refcnts and rollback. Such code tends to make
> a hole (This was what my first patch did...).
> And there is no fundamental difference between my shared refcnt and
> css_tryget() patch. Maybe above will give us better cache localily.
> 
> Anyway, I have no objections to rolling update of refcnt and tryget().
> If it's a way to go, I'll go ahead.
> 
> > Would this maybe even remove the need for mem_cgroup_pre_destroy()?
> >
> Yes and No. not sure. but my thinking is No.
> 
> 1. pre_destroy() is called by rmdir(), in synchronized manner.
>    This means that all refs in memcg will be removed at rmdir().
>    If we drop refs at destroy(), it happens when dput()'s refcnt finally
>    goes down to 0. This asynchronous manner is not good for users.
> 
> 2. Current pre_destroy() code is very young. And we don't find any
>    corner case in which pre_destroy() can't complete thier works.
>    So, I don't want to remove pre_destroy() for a while.
> 
> 3. Sometimes, pre_destroy() have to call try_to_free_pages() and
>    we cannot know we can call try_to_free_page() in dput().
> 
> Thanks,
> -Kame
> 
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
