Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id C7E0E6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 14:34:11 -0400 (EDT)
Received: by mail-ye0-f169.google.com with SMTP id m1so3261597yen.14
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 11:34:10 -0700 (PDT)
Date: Fri, 12 Jul 2013 11:34:04 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
Message-ID: <20130712183404.GA23680@mtj.dyndns.org>
References: <20130710184254.GA16979@mtj.dyndns.org>
 <20130711083110.GC21667@dhcp22.suse.cz>
 <51DE701C.6010800@huawei.com>
 <20130711092542.GD21667@dhcp22.suse.cz>
 <51DE7AAF.6070004@huawei.com>
 <20130711093300.GE21667@dhcp22.suse.cz>
 <20130711154408.GA9229@mtj.dyndns.org>
 <20130711162215.GM21667@dhcp22.suse.cz>
 <20130711163238.GC9229@mtj.dyndns.org>
 <20130712084039.GA13224@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712084039.GA13224@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hello, Michal.

On Fri, Jul 12, 2013 at 10:40:39AM +0200, Michal Hocko wrote:
> > It's not something white and black but for things which can be made
> > trivially synchrnous, it usually is better to do it that way,
> 
> True in general but it is also true (in general) that once we have a
> reference counting for controlling life cycle for an object we should
> not bypass it.

When you have a reference count with staged destruction like cgroup,
the object goes two stagages before being released.  It first gets
deactivated or removed from further access and the base ref is
dropped.  This state presists until the left-over references drain.
When all the references are dropped, the object is actually released.

Now, between the initiation of destruction and actual release, the
object often isn't in the same state as before the destruction
started.  It depends on the specifics of the subsystem but usually
only subset of the original functionalities are accessible.  At times,
it becomes tricky discerning what's safe and what's not and we do end
up with latent subtle bugs which are only triggered when tricky
conditions are met - things like certain operations stretching across
destruction point.

It is important to distinguish the boundary between things which
remain accessible after destruction point and it often is easier and
less dangerous to avoid expanding that set unless necessary, so it is
not "bypassing" an existing mechanism at all.  It is an inherent part
of that model and various kernel subsystems have been doing that
forever.

> So I guess we are safe with the code as is but this all is really
> _tricky_ and deserves a fat comment. So rather than adding flushing work
> item code we should document it properly.
> 
> Or am I missing something?

Two things.

* I have no idea what would prevent the work item execution kicking in
  way after the inode is released.  The execution is not flushed and
  the work item isn't pinning the underlying data structure.  There's
  nothing preventing the work item execution to happen after or
  stretch across inode release.

* You're turning something which has a clearly established pattern of
  usage - work item shutdown which is usually done by disabling
  issuance and then flushing / canceling - into something really
  tricky and deserving a fat comment.  In general, kernel engineering
  is never about finding the most optimal / minimal / ingenious
  solution for each encountered instances of problems.  In most cases,
  it's usually about identifying established patterns and applying
  them so that the code is not only safe and correct but also remains
  accessible to the fellow kernel developers.

  Here, people who are familiary with workqueue usage would
  automatically look for shutdown sequence as the work item is
  contained in a dynamic object.  There are cases where
  synchronization happens externally and you don't necessarily need
  flush / cancel, but even then, if you consider readability and
  maintainability, following the established pattern is often then
  right thing to do.  It makes the code easier to follow and verify
  for others and avoids unintentional breakages afterwards as you
  separate out work item draining from the external synchronization
  which may change later on without noticing how it's interlocked with
  work item draining.

> OK, I haven't realized the action waits for finishing. /me is not
> regular work_queue user...

So, please, follow the established patterns.  This really isn't the
place for ingenuity.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
