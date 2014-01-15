Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6466E6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 15:30:56 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id d7so871390bkh.25
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 12:30:55 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id w8si3709979bkn.212.2014.01.15.12.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 12:30:55 -0800 (PST)
Date: Wed, 15 Jan 2014 15:30:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/3] memcg: notify userspace about OOM only when and action
 is due
Message-ID: <20140115203047.GK6963@cmpxchg.org>
References: <1389798068-19885-1-git-send-email-mhocko@suse.cz>
 <1389798068-19885-2-git-send-email-mhocko@suse.cz>
 <20140115175655.GJ6963@cmpxchg.org>
 <20140115190015.GA22196@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140115190015.GA22196@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 15, 2014 at 08:00:15PM +0100, Michal Hocko wrote:
> On Wed 15-01-14 12:56:55, Johannes Weiner wrote:
> > On Wed, Jan 15, 2014 at 04:01:06PM +0100, Michal Hocko wrote:
> > > Userspace is currently notified about OOM condition after reclaim
> > > fails to uncharge any memory after MEM_CGROUP_RECLAIM_RETRIES rounds.
> > > This usually means that the memcg is really in troubles and an
> > > OOM action (either done by userspace or kernel) has to be taken.
> > > The kernel OOM killer however bails out and doesn't kill anything
> > > if it sees an already dying/exiting task in a good hope a memory
> > > will be released and the OOM situation will be resolved.
> > > 
> > > Therefore it makes sense to notify userspace only after really all
> > > measures have been taken and an userspace action is required or
> > > the kernel kills a task.
> > > 
> > > This patch is based on idea by David Rientjes to not notify
> > > userspace when the current task is killed or in a late exiting.
> > > The original patch, however, didn't handle in kernel oom killer
> > > back offs which is implemtented by this patch.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > OOM is a temporary state because any task can exit at a time that is
> > not under our control and outside our knowledge.  That's why the OOM
> > situation is defined by failing an allocation after a certain number
> > of reclaim and charge attempts.
> > 
> > As of right now, the OOM sampling window is MEM_CGROUP_RECLAIM_RETRIES
> > loops of charge attempts and reclaim.  If a racing task is exiting and
> > releasing memory during that window, the charge will succeed fine.  If
> > the sampling window is too short in practice, it will have to be
> > extended, preferrably through increasing MEM_CGROUP_RECLAIM_RETRIES.
> 
> The patch doesn't try to address the above race because that one is
> unfixable. I hope that is clear.
> 
> It just tries to reduce burden on the userspace oom notification
> consumers and given them a simple semantic. Notification comes only if
> an action will be necessary (either kernel kills something or user space
> is expected).

I.e. turn the OOM notification into an OOM kill event notification.

> E.g. consider a handler which tries to clean up after kernel handled
> OOM and killed something. If the kernel could back off and refrain
> from killing anything after the norification already fired up then the
> userspace has no practical way to detect that (except for checking the
> kernel log to search for OOM messages which might get suppressed due to
> rate limitting etc.. Nothing I would call optimal).
> Or do you think that such a use case doesn't make much sense and it is
> an abuse of the notification interface?

I'm not sure what such a cleanup would be doing, a real life usecase
would be useful when we are about to change notification semantics.
I've heard "taking down the remaining tasks of the job" before, but
that would be better solved by having the OOM killer operate on
cgroups as single entities instead of taking out individual tasks.

On the other hand, I can see how people use the OOM notification to
monitor system/cgroup health.  David argued that vmpressure "critical"
would be the same thing.  But first of all, this is not an argument to
change semantics of an established interface.  And secondly, it only
tells you that reclaim is struggling, it doesn't give you the point of
failure (the OOM condition), regardless of what the docs claim.

So, please, if you need a new interface, make a clear case for it and
then we can discuss if it's the right way to go.  We do the same for
every other user interface, whether it's a syscall, an ioctl, a procfs
file etc.  Just taking something existing that is close enough and
skewing the semantics in your favor like this is not okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
