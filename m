Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 98A576B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:51:43 -0400 (EDT)
Received: by wgra20 with SMTP id a20so61069649wgr.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:51:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bo3si10256482wib.21.2015.03.26.04.51.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 04:51:41 -0700 (PDT)
Date: Thu, 26 Mar 2015 12:51:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 01/12] mm: oom_kill: remove unnecessary locking in
 oom_enable()
Message-ID: <20150326115140.GC15257@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-2-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.10.1503251744290.32157@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503251744290.32157@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Wed 25-03-15 17:51:31, David Rientjes wrote:
> On Wed, 25 Mar 2015, Johannes Weiner wrote:
> 
> > Setting oom_killer_disabled to false is atomic, there is no need for
> > further synchronization with ongoing allocations trying to OOM-kill.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/oom_kill.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 2b665da1b3c9..73763e489e86 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -488,9 +488,7 @@ bool oom_killer_disable(void)
> >   */
> >  void oom_killer_enable(void)
> >  {
> > -	down_write(&oom_sem);
> >  	oom_killer_disabled = false;
> > -	up_write(&oom_sem);
> >  }
> >  
> >  #define K(x) ((x) << (PAGE_SHIFT-10))
> 
> I haven't looked through the new disable-oom-killer-for-pm patchset that 
> was merged, but this oom_killer_disabled thing already looks improperly 
> handled.  I think any correctness or cleanups in this area would be very 
> helpful.
> 
> I think mark_tsk_oom_victim() in mem_cgroup_out_of_memory() is just 
> luckily not racing with a call to oom_killer_enable() and triggering the 
                                    ^^^^^^^^^^
                                    oom_killer_disable?

> WARN_ON(oom_killer_disabled) since there's no "oom_sem" held here, and 
> it's an improper context based on the comment of mark_tsk_oom_victim().

OOM killer is disabled only _after_ all user tasks have been frozen. So
we cannot get any page fault and a race. So the semaphore is not needed
in this path although the comment says otherwise. I can add a comment
clarifying this...
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f2017e37..20828ecaf3ba 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1536,6 +1536,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+		/*
+		 * We do not hold oom_sem in this path because we know
+		 * we cannot race with oom_kill_disable(). No user runable
+		 * tasks are allowed at the time oom_kill_disable is called.
+		 */
 		mark_tsk_oom_victim(current);
 		return;
 	}

> There might be something else that is intended but not implemented 
> correctly that I'm unaware of, but I know of no reason why setting of 
> oom_killer_disabled would need to take a semaphore?
> 
> I'm thinking it has something to do with the remainder of that comment, 
> specifically the "never after oom has been disabled already."
> 
> Michal?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
