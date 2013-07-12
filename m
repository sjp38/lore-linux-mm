Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8A3F46B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 04:40:43 -0400 (EDT)
Date: Fri, 12 Jul 2013 10:40:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] vmpressure: make sure memcg stays alive until all
 users are signaled
Message-ID: <20130712084039.GA13224@dhcp22.suse.cz>
References: <20130710184254.GA16979@mtj.dyndns.org>
 <20130711083110.GC21667@dhcp22.suse.cz>
 <51DE701C.6010800@huawei.com>
 <20130711092542.GD21667@dhcp22.suse.cz>
 <51DE7AAF.6070004@huawei.com>
 <20130711093300.GE21667@dhcp22.suse.cz>
 <20130711154408.GA9229@mtj.dyndns.org>
 <20130711162215.GM21667@dhcp22.suse.cz>
 <20130711163238.GC9229@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130711163238.GC9229@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu 11-07-13 09:32:38, Tejun Heo wrote:
> Hello,
> 
> On Thu, Jul 11, 2013 at 06:22:15PM +0200, Michal Hocko wrote:
> > I would rather not put vmpressure clean up code into memcg offlining.
> > We have reference counting for exactly this purposes so it feels strange
> > to overcome it like that.
> 
> It's not something white and black but for things which can be made
> trivially synchrnous, it usually is better to do it that way,

True in general but it is also true (in general) that once we have a
reference counting for controlling life cycle for an object we should
not bypass it.

> especially while shutting down objects as they enter a lingering stage
> where they're de-registered but not destroyed and you should be
> careful which parts of the object are still accessible.  I haven't
> read it carefully but here I'm not sure whether it's safe to do event
> related operations after removal.  From cgroup core side, event list
> is shut down synchronously from cgroup_destroy_locked().  It doesn't
> seem like that part is explicitly built to remain accessible
> afterwards.

/me goes and checks the code

vmpressure_event sends signals to _registered_ events but those are
unregistered from the work queue context by cgroup_event_remove (via
vmpressure_unregister_event) queued from cgroup_destroy_locked.

I am not sure what are the guarantees for ordering on the workqueue but
this all suggests that either vmpressure_event sees an empty vmpr->events
or it can safely send signals as cgroup_event_remove is pending on the
queue.

cgroup_event_remove drops a reference to cgrp->dentry after everything
is unregistered and event->wait removed from the wait queue so
cgroup_free_fn couldn't have been called yet and so memcg is still
alive. This means that even css_get/put is not necessary.

So I guess we are safe with the code as is but this all is really
_tricky_ and deserves a fat comment. So rather than adding flushing work
item code we should document it properly.

Or am I missing something?

> > Besides that wouldn't be that racy? The work item could be already
> > executing and preempted and we do not want vmpr to disappear from under
> > our feet. I know this is _highly_ unlikely but why to play games?
> 
> Hmmm?  flush_work() and cancel_work_sync() guarantee that the work
> item isn't executing on return unless it's being requeued.  There's no
> race condition.

OK, I haven't realized the action waits for finishing. /me is not
regular work_queue user...
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
