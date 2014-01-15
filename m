Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3F46B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 14:00:19 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id d13so4208106wiw.12
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 11:00:19 -0800 (PST)
Received: from mail-ee0-x229.google.com (mail-ee0-x229.google.com [2a00:1450:4013:c00::229])
        by mx.google.com with ESMTPS id de3si1550948wib.7.2014.01.15.11.00.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 11:00:18 -0800 (PST)
Received: by mail-ee0-f41.google.com with SMTP id e49so1088579eek.0
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 11:00:18 -0800 (PST)
Date: Wed, 15 Jan 2014 20:00:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] memcg: notify userspace about OOM only when and action
 is due
Message-ID: <20140115190015.GA22196@dhcp22.suse.cz>
References: <1389798068-19885-1-git-send-email-mhocko@suse.cz>
 <1389798068-19885-2-git-send-email-mhocko@suse.cz>
 <20140115175655.GJ6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140115175655.GJ6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 15-01-14 12:56:55, Johannes Weiner wrote:
> On Wed, Jan 15, 2014 at 04:01:06PM +0100, Michal Hocko wrote:
> > Userspace is currently notified about OOM condition after reclaim
> > fails to uncharge any memory after MEM_CGROUP_RECLAIM_RETRIES rounds.
> > This usually means that the memcg is really in troubles and an
> > OOM action (either done by userspace or kernel) has to be taken.
> > The kernel OOM killer however bails out and doesn't kill anything
> > if it sees an already dying/exiting task in a good hope a memory
> > will be released and the OOM situation will be resolved.
> > 
> > Therefore it makes sense to notify userspace only after really all
> > measures have been taken and an userspace action is required or
> > the kernel kills a task.
> > 
> > This patch is based on idea by David Rientjes to not notify
> > userspace when the current task is killed or in a late exiting.
> > The original patch, however, didn't handle in kernel oom killer
> > back offs which is implemtented by this patch.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> OOM is a temporary state because any task can exit at a time that is
> not under our control and outside our knowledge.  That's why the OOM
> situation is defined by failing an allocation after a certain number
> of reclaim and charge attempts.
> 
> As of right now, the OOM sampling window is MEM_CGROUP_RECLAIM_RETRIES
> loops of charge attempts and reclaim.  If a racing task is exiting and
> releasing memory during that window, the charge will succeed fine.  If
> the sampling window is too short in practice, it will have to be
> extended, preferrably through increasing MEM_CGROUP_RECLAIM_RETRIES.

The patch doesn't try to address the above race because that one is
unfixable. I hope that is clear.

It just tries to reduce burden on the userspace oom notification
consumers and given them a simple semantic. Notification comes only if
an action will be necessary (either kernel kills something or user space
is expected).

E.g. consider a handler which tries to clean up after kernel handled
OOM and killed something. If the kernel could back off and refrain
from killing anything after the norification already fired up then the
userspace has no practical way to detect that (except for checking the
kernel log to search for OOM messages which might get suppressed due to
rate limitting etc.. Nothing I would call optimal).
Or do you think that such a use case doesn't make much sense and it is
an abuse of the notification interface?

> But a random task exiting a split second after the sampling window has
> closed will always be a possibility, regardless of how long it is.

Agreed and this is not what the patch is about. If the kernel oom killer
couldn't back off then I would completely agree with you here.

> There is nothing to be gained from this layering violation and it's
> mind-boggling that you two still think this is a meaningful change.
> 
> Nacked-by: Johannes Weiner <hannes@cmpxchg.org>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
