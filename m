Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id AE0B76B006E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:17:52 -0400 (EDT)
Received: by wgra20 with SMTP id a20so67779948wgr.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 08:17:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id uw10si10405591wjc.110.2015.03.26.08.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 08:17:51 -0700 (PDT)
Date: Thu, 26 Mar 2015 11:17:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 06/12] mm: oom_kill: simplify OOM killer locking
Message-ID: <20150326151746.GC23973@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-7-git-send-email-hannes@cmpxchg.org>
 <20150326133111.GJ15257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326133111.GJ15257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Thu, Mar 26, 2015 at 02:31:11PM +0100, Michal Hocko wrote:
> On Wed 25-03-15 02:17:10, Johannes Weiner wrote:
> > The zonelist locking and the oom_sem are two overlapping locks that
> > are used to serialize global OOM killing against different things.
> > 
> > The historical zonelist locking serializes OOM kills from allocations
> > with overlapping zonelists against each other to prevent killing more
> > tasks than necessary in the same memory domain.  Only when neither
> > tasklists nor zonelists from two concurrent OOM kills overlap (tasks
> > in separate memcgs bound to separate nodes) are OOM kills allowed to
> > execute in parallel.
> > 
> > The younger oom_sem is a read-write lock to serialize OOM killing
> > against the PM code trying to disable the OOM killer altogether.
> > 
> > However, the OOM killer is a fairly cold error path, there is really
> > no reason to optimize for highly performant and concurrent OOM kills.
> > And the oom_sem is just flat-out redundant.
> > 
> > Replace both locking schemes with a single global mutex serializing
> > OOM kills regardless of context.
> 
> OK, this is much simpler.
> 
> You have missed drivers/tty/sysrq.c which should take the lock as well.
> ZONE_OOM_LOCKED can be removed as well. __out_of_memory in the kerneldoc
> should be renamed.

Argh, an older version had the lock inside out_of_memory() and I never
updated the caller when I changed the rules.  Thanks.  I'll fix both.

> > @@ -795,27 +728,21 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >   */
> >  void pagefault_out_of_memory(void)
> >  {
> > -	struct zonelist *zonelist;
> > -
> > -	down_read(&oom_sem);
> >  	if (mem_cgroup_oom_synchronize(true))
> > -		goto unlock;
> > +		return;
> 
> OK, so we are back to what David has asked previously. We do not need
> the lock for memcg and oom_killer_disabled because we know that no tasks
> (except for potential oom victim) are lurking around at the time
> oom_killer_disable() is called. So I guess we want to stick a comment
> into mem_cgroup_oom_synchronize before we check for oom_killer_disabled.

I would prefer everybody that sets TIF_MEMDIE and kills a task to hold
the lock, including memcg.  Simplicity is one thing, but also a global
OOM kill might not even be necessary when it's racing with the memcg.

> After those are fixed, feel free to add
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
