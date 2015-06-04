Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 78775900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 15:07:09 -0400 (EDT)
Received: by wgme6 with SMTP id e6so40783036wgm.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 12:07:09 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bq3si8925665wjc.50.2015.06.04.12.07.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 12:07:07 -0700 (PDT)
Date: Thu, 4 Jun 2015 15:06:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] memcg: close the race window between OOM detection
 and killing
Message-ID: <20150604190649.GA5867@cmpxchg.org>
References: <20150603031544.GC7579@mtj.duckdns.org>
 <20150603144414.GG16201@dhcp22.suse.cz>
 <20150603193639.GH20091@mtj.duckdns.org>
 <20150604093031.GB4806@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604093031.GB4806@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 04, 2015 at 11:30:31AM +0200, Michal Hocko wrote:
> There have been suggestions to add an OOM timeout and ignore the
> previous OOM victim after the timeout expires and select a new
> victim. This sounds attractive but this approach has its own problems
> (http://marc.info/?l=linux-mm&m=141686814824684&w=2).

Since this list of concerns have been brought up but never really
addressed, let me give it a shot.  From David's email:

: The oom killer timeout is always an attractive remedy to this situation 
: and gets proposed quite often.  Several problems: (1) you can needlessly 
: panic the machine because no other processes are eligible for oom kill 
: after declaring that the first oom kill victim cannot make progress,

If we run out of OOM victims that can successfully exit, then we are
genuinely deadlocked.  What else is there to do?  A panic() is better
than locking up quietly in that case.

: (2) it can lead to unnecessary oom killing if the oom kill victim
: can exit but hasn't be scheduled or is in the process of exiting,

We can set the timeout sufficiently high that this should be a fair
trade-off.  Let's say 10 seconds.  If your only remaining means of
reclaiming memory, which is waiting for that one task to exit, takes
longer than 10 seconds, aren't you in big enough trouble already?  It
seems reasonable to assume that there won't be any more progress.  But
even if there were, the machine is in a state bad enough that a second
OOM kill should not be the end of the world.

: (3) you can easily turn the oom killer into a serial oom killer
: since there's no guarantee the next process that is chosen won't be
: affected by the same problem,

Again, this would still be better than deadlocking.

: and (4) this doesn't fix the problem if an oom disabled process is
: wedged trying to allocate memory while holding a mutex that others
: are waiting on.

I don't follow.  If another OOM victim is chosen and can exit, the
task that is trying to allocate with the lock held will finish the
allocation and release the lock.

> I am convinced that a more appropriate solution for this is to not
> pretend that small allocation never fail and start failing them after
> OOM killer is not able to make any progress (GFP_NOFS allocations would
> be the first candidate and the easiest one to trigger deadlocks via
> i_mutex). Johannes was also suggesting an OOM memory reserve which would
> be used for OOM contexts.

I am no longer convinced we can ever go back to failing smaller
allocations and NOFS allocations.  The filesystem people involved in
that discussion have proven completely uncooperative on that subject.

So I think we should make the OOM killer as robust as possible.  It's
just unnecessary to deadlock on a single process when there are more
candidates out there that we could try instead.  We are already in a
worst-case state, killing more tasks is not going to make it worse.

> Also OOM killer can be improved and shrink some of the victims memory
> before killing it (e.g. drop private clean pages and their page tables).

That might work too.  It's just a bit more complex and I don't really
see the downside of moving on to other victims after a timeout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
