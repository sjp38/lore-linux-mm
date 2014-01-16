Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4AE6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 09:10:34 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id d17so1527858eek.22
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 06:10:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si14913320eef.66.2014.01.16.06.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 06:10:32 -0800 (PST)
Date: Thu, 16 Jan 2014 15:10:31 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] memcg: notify userspace about OOM only when and action
 is due
Message-ID: <20140116141031.GE28157@dhcp22.suse.cz>
References: <1389798068-19885-1-git-send-email-mhocko@suse.cz>
 <1389798068-19885-2-git-send-email-mhocko@suse.cz>
 <20140115175655.GJ6963@cmpxchg.org>
 <20140115190015.GA22196@dhcp22.suse.cz>
 <20140115203047.GK6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140115203047.GK6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 15-01-14 15:30:47, Johannes Weiner wrote:
> On Wed, Jan 15, 2014 at 08:00:15PM +0100, Michal Hocko wrote:
> > On Wed 15-01-14 12:56:55, Johannes Weiner wrote:
> > > On Wed, Jan 15, 2014 at 04:01:06PM +0100, Michal Hocko wrote:
> > > > Userspace is currently notified about OOM condition after reclaim
> > > > fails to uncharge any memory after MEM_CGROUP_RECLAIM_RETRIES rounds.
> > > > This usually means that the memcg is really in troubles and an
> > > > OOM action (either done by userspace or kernel) has to be taken.
> > > > The kernel OOM killer however bails out and doesn't kill anything
> > > > if it sees an already dying/exiting task in a good hope a memory
> > > > will be released and the OOM situation will be resolved.
> > > > 
> > > > Therefore it makes sense to notify userspace only after really all
> > > > measures have been taken and an userspace action is required or
> > > > the kernel kills a task.
> > > > 
> > > > This patch is based on idea by David Rientjes to not notify
> > > > userspace when the current task is killed or in a late exiting.
> > > > The original patch, however, didn't handle in kernel oom killer
> > > > back offs which is implemtented by this patch.
> > > > 
> > > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > 
> > > OOM is a temporary state because any task can exit at a time that is
> > > not under our control and outside our knowledge.  That's why the OOM
> > > situation is defined by failing an allocation after a certain number
> > > of reclaim and charge attempts.
> > > 
> > > As of right now, the OOM sampling window is MEM_CGROUP_RECLAIM_RETRIES
> > > loops of charge attempts and reclaim.  If a racing task is exiting and
> > > releasing memory during that window, the charge will succeed fine.  If
> > > the sampling window is too short in practice, it will have to be
> > > extended, preferrably through increasing MEM_CGROUP_RECLAIM_RETRIES.
> > 
> > The patch doesn't try to address the above race because that one is
> > unfixable. I hope that is clear.
> > 
> > It just tries to reduce burden on the userspace oom notification
> > consumers and given them a simple semantic. Notification comes only if
> > an action will be necessary (either kernel kills something or user space
> > is expected).
> 
> I.e. turn the OOM notification into an OOM kill event notification.

OK, maybe it's just me but I've considered OOM -> OOM kill. Because if
we for some reason do not need to perform an action then we are not OOM
really (one of them is the state the other part is an action).  Maybe
it's because you cannot find out you are under OOM unless you see the
OOM killer in action for ages (well memcg has changed that but...)

I might be wrong here of course...

> > E.g. consider a handler which tries to clean up after kernel handled
> > OOM and killed something. If the kernel could back off and refrain
> > from killing anything after the norification already fired up then the
> > userspace has no practical way to detect that (except for checking the
> > kernel log to search for OOM messages which might get suppressed due to
> > rate limitting etc.. Nothing I would call optimal).
> > Or do you think that such a use case doesn't make much sense and it is
> > an abuse of the notification interface?
> 
> I'm not sure what such a cleanup would be doing, a real life usecase
> would be useful when we are about to change notification semantics.
> I've heard "taking down the remaining tasks of the job" before, but
> that would be better solved by having the OOM killer operate on
> cgroups as single entities instead of taking out individual tasks.

I am not a direct user of the interface myself but I can imagine that
there might be many clean up actions to be done. The task receives
SIG_KILL so it doesn't have any chance to do the cleanup itself. This
might be something like reverting to the last consistent state for the
internal data or removing temporary files which, for some reason, had to
be visible througout the process life and many others.

> On the other hand, I can see how people use the OOM notification to
> monitor system/cgroup health.  David argued that vmpressure "critical"
> would be the same thing.  But first of all, this is not an argument to
> change semantics of an established interface. And secondly, it only
> tells you that reclaim is struggling, it doesn't give you the point of
> failure (the OOM condition), regardless of what the docs claim.

> So, please, if you need a new interface, make a clear case for it and
> then we can discuss if it's the right way to go.  We do the same for
> every other user interface, whether it's a syscall, an ioctl, a procfs
> file etc.  Just taking something existing that is close enough and
> skewing the semantics in your favor like this is not okay.

Agreed, that's why this has been sent as a request for comments and
discussion. It is sad that the discussion ended before it started...
I realize that the previous one was quite frustrating but maybe we can
do better.

I am not going to push for this very strong because I believe that last
second back offs before OOM killer fires doesn't happen all that often. 
Do we have any numbers for that, btw?
Maybe we should start by adding a counter and report it in (memcg)
statistics (quick patch on top of mmotm bellow). And base our future
decisions on those numbers? Because to be honest, something tells me
that the overall difference will be barely noticeable most workloads.

Anyway, I liked the notification to be tighter to the action because
it makes userspace notifiers easier to implement because they wouldn't
have to worry about back offs. Also the semantic is much cleaner IMO
because you get a notification that the situation is so bad that the
kernel had to use an emergency measures.

---
