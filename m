Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id A404F90001B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 11:16:04 -0400 (EDT)
Date: Thu, 13 Jun 2013 17:16:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130613151602.GG23070@dhcp22.suse.cz>
References: <20130603193147.GC23659@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com>
 <20130604095514.GC31242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com>
 <20130605093937.GK15997@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com>
 <20130610142321.GE5138@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com>
 <20130612202348.GA17282@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306121408490.24902@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306121408490.24902@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed 12-06-13 14:27:05, David Rientjes wrote:
> On Wed, 12 Jun 2013, Michal Hocko wrote:
> 
> > But the objective is to handle oom deadlocks gracefully and you cannot
> > possibly miss those as they are, well, _deadlocks_.
> 
> That's not at all the objective, the changelog quite explicitly states 
> this is a deadlock as the result of userspace having disabled the oom 
> killer so that its userspace oom handler can resolve the condition and it 
> being unresponsive or unable to perform its job.

Ohh, so another round. Sigh. You insist on having user space handlers
running in the context of the limited group. OK, I can understand your
use case, although I think it is pushing the limits of the interface and
it is dangerous.
As the problems/deadlocks are unavoidable with this approach you really
need a backup plan to reduce the damage once it happens. You insist on
having in-kernel solution while there is a user space alternative
possible IMO.

> When you allow users to create their own memcgs, which we do and is 
> possible by chowning the user's root to be owned by it, and implement 
> their own userspace oom notifier, you must then rely on their 
> implementation to work 100% of the time, otherwise all those gigabytes of 
> memory go unfreed forever.  What you're insisting on is that this 
> userspace is perfect

No, I am not saying that. You can let your untrusted users handle
their OOMs as you like. The watchdog (your fallback solution) _has_
to be trusted though and if you want it to do the job then you better
implement it correctly. Is this requirement a problem?

> and there is never any memory allocated (otherwise it may oom its own
> user root memcg where the notifier is hosted)

If the watchdog runs under root memcg then there is no limit so the only
OOM that might happen is the global one and you can protect the watchdog
by oom_adj as I have mentioned earlier.

> and it is always responsive and able to handle the situation.

If it is a trusted code then it can run with a real time priority.

> This is not reality.

It seems you just do not want to accept that there is other solution
because the kernel solution sounds like an easier option for you.

> This is why the kernel has its own oom killer and doesn't wait for a user 
> to go to kill something.  There's no option to disable the kernel oom 
> killer.  It's because we don't want to leave the system in a state where 
> no progress can be made.  The same intention is for memcgs to not be left 
> in a state where no progress can be made even if userspace has the best 
> intentions.
> 
> Your solution of a global entity to prevent these situations doesn't work 
> for the same reason we can't implement the kernel oom killer in userspace.  
> It's the exact same reason. 

No it is not! The core difference is that there is _always_ some memory
for the watchdog (because something else might be killed to free some
memory) while there is none for the global OOM. So the watchdog even
doesn't need to mlock everything in.

> We also want to push patches that allow global oom conditions to
> trigger an eventfd notification on the root memcg with the exact same
> semantics of a memcg oom:

As already mentioned we have discussed this at LSF. I am still not
sure it is the right thing to do though. The interface would be too
tricky. There are other options to implement user defined policy for the
global OOM and they should be considered before there is a decision to
push it into memcg.

> allow it time to respond but 
> step in and kill something if it fails to respond.  Memcg happens to be 
> the perfect place to implement such a userspace policy and we want to have 
> a priority-based killing mechanism that is hierarchical and different from 
> oom_score_adj.

It might sound perfect for your use cases but we should be _really_
careful to not pull another tricky interface into memcg that would fit
a certain scenario.
Remember use_hierarchy thingy? It sounded like a good idea at the time
and it turned into a nightmare over time. It also aimed at solving a
restriction at the time. The restriction is not here anymore AFAICT but
we have a crippled hierarchy semantic.

> For that to work properly, it cannot possibly allocate memory even on page 
> fault so it must be mlocked in memory and have enough buffers to store the 
> priorities of top-level memcgs.  Asking a global watchdog to sit there 
> mlocked in memory to store thousands of memcgs, their priorities, their 
> last oom, their timeouts, etc, is a non-starter.

I have asked you about an estimation already. I do not think that the
memory consumption would really matter here. We are talking about few
megs at most and even that is exaggerated.

> I don't buy your argument that we're pushing any interface to an extreme.  

OK, call it a matter of taste but handling oom in the context of the
oom itself without any requirements to the handler implementation and
without access to any memory reserves because the handler is not trusted
feels weird and scary to me.

> Users having the ability to manipulate their own memcgs and subcontainers 
> isn't extreme, it's explicitly allowed by cgroups! 

Sure thing and no discussion about that. We are just arguing who should
be responsible here. Admin who allows such a setup or kernel.

> What we're asking for is that level of control for memcg is sane and

I can argue that it _is_ quite sane in its current form. The interface
allows you to handle the oom either by increasing the limit which
doesn't allocate any kernel memory or by killing a task which doesn't
allocate any memory either.
If the handler fails to make the oom decision without allocating a
memory and it is running under the restricted environment at the same
time then it calls for troubles. If you, as an admin, want to allow such
a setup then why not, but be aware of potential problems and handle them
when they happen. If there was no sane way to implement such a stopgap
measure then I wouldn't be objecting.

I do not think that your oom_control at root group level argument really
matters now because a) there is nothing like that in the kernel yet and
b) it is questionable it will be ever (as the discussion hasn't started
yet).
Not mentioning that even if it was I think the watchdog could be still
implemented (e.g. re-enable global oom after a timeout from a different
thread in the global watchdog - you can certainly do that without any
allocations).

> that if userspace is unresponsive that we don't lose gigabytes of
> memory forever.  And since we've supported this type of functionality
> even before memcg was created for cpusets and have used and supported
> it for six years, I have no problem supporting such a thing upstream.
> 
> I do understand that we're the largest user of memcg and use it unlike you 
> or others on this thread do, but that doesn't mean our usecase is any less 
> important or that we should aim for the most robust behavior possible.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
