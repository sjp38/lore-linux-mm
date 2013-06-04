Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 17E826B0083
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 05:55:17 -0400 (EDT)
Date: Tue, 4 Jun 2013 11:55:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130604095514.GC31242@dhcp22.suse.cz>
References: <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601102058.GA19474@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031102480.7956@chino.kir.corp.google.com>
 <20130603193147.GC23659@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 03-06-13 14:17:54, David Rientjes wrote:
> On Mon, 3 Jun 2013, Michal Hocko wrote:
> 
> > > What do you suggest when you read the "tasks" file and it returns -ENOMEM 
> > > because kmalloc() fails because the userspace oom handler's memcg is also 
> > > oom? 
> > 
> > That would require that you track kernel allocations which is currently
> > done only for explicit caches.
> > 
> 
> That will not always be the case, and I think this could be a prerequisite 
> patch for such support that we have internally. 

> I'm not sure a userspace oom notifier would want to keep a
> preallocated buffer around that is mlocked in memory for all possible
> lengths of this file.

Well, an oom handler which allocates memory under the same restricted
memory doesn't make much sense to me. Tracking all kmem allocations
makes it almost impossible to implement a non-trivial handler.

> > > Obviously it's not a situation we want to get into, but unless you 
> > > know that handler's exact memory usage across multiple versions, nothing 
> > > else is sharing that memcg, and it's a perfect implementation, you can't 
> > > guarantee it.  We need to address real world problems that occur in 
> > > practice.
> > 
> > If you really need to have such a guarantee then you can have a _global_
> > watchdog observing oom_control of all groups that provide such a vague
> > requirements for oom user handlers.
> > 
> 
> The whole point is to allow the user to implement their own oom policy.

OK, maybe I just wasn't clear enough or I am missing your point. Your
users _can_ implement and register their oom handlers. But as your
requirements are rather benevolent for handlers implementation you would
have a global watchdog which would sit on the oom_control of those
groups (which are allowed to have own handlers - all of them in your
case I guess) and trigger (user defined/global) timeout when it gets a
notification. If the group was under oom always during the timeout then
just disable oom_control until oom is settled (under_oom is 0).

Why wouldn't something like this work for your use case?

> If the policy was completely encapsulated in kernel code, we don't need to 
> ever disable the oom killer even with memory.oom_control.  Users may 
> choose to kill the largest process, the newest process, the oldest 
> process, sacrifice children instead of parents, prevent forkbombs, 
> implement their own priority scoring (which is what we do), kill the 
> allocating task, etc.
> 
> To not merge this patch, I'd ask that you show an alternative that allows 
> users to implement their own userspace oom handlers and not require admin 
> intervention when things go wrong.

Hohmm, so you are insisting on something that can be implemented in the
userspace and put it into the kernel because it is more convenient for
you and your use case. This doesn't sound like a way for accepting a
feature.

To make this absolutely clear. I do understand your requirements but you
haven't shown any _argument_ why the timeout you are proposing cannot be
implemented in the userspace. I will not ack this without this
reasoning.

And yes we should make memcg oom handling less deadlock prone and
Johannes' work in this thread is a good step forward.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
