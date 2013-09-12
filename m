Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 86A616B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 07:46:02 -0400 (EDT)
Date: Thu, 12 Sep 2013 13:46:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
Message-ID: <20130912114600.GB4828@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1309062254470.11420@eggly.anvils>
 <20130909110847.GB18056@dhcp22.suse.cz>
 <20130911154057.GA16765@teo>
 <20130911160357.GA32273@dhcp22.suse.cz>
 <alpine.LNX.2.00.1309111233200.2912@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1309111233200.2912@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anton Vorontsov <anton@enomsg.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 11-09-13 13:04:33, Hugh Dickins wrote:
> On Wed, 11 Sep 2013, Michal Hocko wrote:
[...]
> > From 888745909da34f8aee8a208a82d467236b828d0d Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Wed, 11 Sep 2013 17:48:10 +0200
> > Subject: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
> > 
> > Hugh Dickins has reported a division by 0 when a vmpressure event is
> > processed. The reason for the exception is that a single vmpressure
> > work item (which is per memcg) might be processed by multiple CPUs
> > because it is enqueued on system_wq which is !WQ_NON_REENTRANT.
> > This means that the out of lock vmpr->scanned check in
> > vmpressure_work_fn is inherently racy and the racing workers will see
> > already zeroed scanned value after they manage to take the spin lock.
> > 
> > The patch simply moves the vmp->scanned check inside the sr_lock to fix
> > the race.
> > 
> > The issue was there since the very beginning but "vmpressure: change
> > vmpressure::sr_lock to spinlock" might have made it more visible as the
> > racing workers would sleep on the mutex and give it more time to see
> > updated value. The issue was still there, though.
> > 
> > Reported-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Cc: stable@vger.kernel.org
> 
> Nack!  But equally Nack to my original.
> 
> Many thanks for looking into how this might have happened, Michal,
> and for mentioning the WQ_NON_REENTRANT flag: which I knew nothing
> about, but have now followed up.
> I owe you all an abject apology: what I didn't mention in my patch
> was that actually I hit the problem on a v3.3-based kernel to which
> vmpressure had been backported.
> 
> I have not yet seen the problem on v3.11 or v3.10, and now believe
> that it cannot happen there - which would explain why I was the
> first to hit it.
> 
> When I looked up WQ_NON_REENTRANT in the latest tree, I found
> 	WQ_NON_REENTRANT	= 1 << 0, /* DEPRECATED */
> and git blame on that line leads to Tejun explaining
>     
>     dbf2576e37 ("workqueue: make all workqueues non-reentrant") made
>     WQ_NON_REENTRANT no-op but the following patches didn't remove the
>     flag or update the documentation.  Let's mark the flag deprecated and
>     update the documentation accordingly.

Goon point. I didn't check the code and relied on the documentation.
Thanks for pointing this out.

> dbf2576e37 went into v3.7, so I now believe this divide-by-0 could
> only happen on a backport of vmpressure to an earlier kernel than that.

git grep WQ_NON_REENTRANT on kernel/workqueue.c really shows nothing so
I guess you are right.

Andrew, please drop the patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
