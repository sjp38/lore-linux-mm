Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6ED506B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 11:23:43 -0400 (EDT)
Date: Thu, 6 Jun 2013 17:23:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] memcg: do not sleep on OOM waitqueue with full
 charge context
Message-ID: <20130606152340.GC24115@dhcp22.suse.cz>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
 <1370488193-4747-2-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1306052058340.25115@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306052058340.25115@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-06-13 21:10:51, David Rientjes wrote:
> On Wed, 5 Jun 2013, Johannes Weiner wrote:
[...]
> > While reworking the OOM routine, also remove a needless OOM waitqueue
> > wakeup when invoking the killer.  Only uncharges and limit increases,
> > things that actually change the memory situation, should do wakeups.
> > 
> 
> It's not needless at all, it's vitally required!  The oom killed process 
> needs to be removed from the waitqueue and scheduled now with TIF_MEMDIE 
> that the memcg oom killer provided so the allocation succeeds in the page 
> allocator and memcg bypasses the charge so it can exit.

The tasks are waiting with TASK_KILLABLE flags so it gets woken up and
the bypass happens. Calling memcg_wakeup_oom is actually wrong here
because it wakes all tasks up despite there is no reason for that. No
charges have been released yet so another retry loop could be pointless.
We need to be patient and wait for wake up from a uncharge path.

> Exactly what problem are you trying to address with this patch?  I don't 
> see any description of the user-visible effects or a specific xample of 
> the scenario you're trying to address here.

Maybe I am biased because I've tried to handle the same problem some time
ago, but the changelog clearly says that memcg oom handling is fragile
and deadlock prone because of locks that are held while memory is
charged and oom handled and so oom targets might not get killed because
they are stuck at the same lock which will not get released until the
charge succeeds.
It addresses the problem by moving oom handling outside of any locks
which solves this category of dead locks. I agree that the changelog
could better (well, each one can be). It could use some examples (e.g.
the i_mutex we have seen few months ago or a simple unkillable brk which
is hanging on mmap_sem for writing while a page fault is handled and
memcg oom triggered).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
