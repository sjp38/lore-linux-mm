Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5B76B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 06:08:52 -0500 (EST)
Received: by wmec201 with SMTP id c201so26008369wme.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 03:08:51 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id t7si4021181wjf.187.2015.11.26.03.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 03:08:50 -0800 (PST)
Received: by wmec201 with SMTP id c201so26007605wme.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 03:08:50 -0800 (PST)
Date: Thu, 26 Nov 2015 12:08:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: introduce oom reaper
Message-ID: <20151126110849.GC7953@dhcp22.suse.cz>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <20151125200806.GA13388@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125200806.GA13388@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 25-11-15 15:08:06, Johannes Weiner wrote:
> Hi Michal,
> 
> I think whatever we end up doing to smoothen things for the "common
> case" (as much as OOM kills can be considered common), we need a plan
> to resolve the memory deadlock situations in a finite amount of time.
> 
> Eventually we have to attempt killing another task. Or kill all of
> them to save the kernel.
> 
> It just strikes me as odd to start with smoothening the common case,
> rather than making it functionally correct first.

I believe there is not an universally correct solution for this
problem. OOM killer is a heuristic and a destructive one so I think we
should limit it as much as possible. I do agree that we should allow an
administrator to define a policy when things go terribly wrong - e.g.
panic/emerg. reboot after the system is trashing on OOM for more than
a defined amount of time. But I think that this is orthogonal to this
patch. This patch should remove one large class of potential deadlocks
and corner cases without too much cost or maintenance burden. It doesn't
remove a need for the last resort solution though.
 
> On Wed, Nov 25, 2015 at 04:56:58PM +0100, Michal Hocko wrote:
> > A kernel thread has been chosen because we need a reliable way of
> > invocation so workqueue context is not appropriate because all the
> > workers might be busy (e.g. allocating memory). Kswapd which sounds
> > like another good fit is not appropriate as well because it might get
> > blocked on locks during reclaim as well.
> 
> Why not do it directly from the allocating context? I.e. when entering
> the OOM killer and finding a lingering TIF_MEMDIE from a previous kill
> just reap its memory directly then and there. It's not like the
> allocating task has anything else to do in the meantime...

One reason is that we have to exclude race with exit_mmap so we have to
increase mm_users but we cannot mmput in this context because we might
deadlock. So we have to tear down from a different context. Another
reason is that address space of the victim might be really large and
reaping from on behalf of one (random) task might be really unfair
wrt. others. Doing that from a kernel threads sounds like an easy and
relatively cheap way to workaround both issues.

> 
> > @@ -1123,7 +1126,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
> >  			continue;
> >  		}
> >  		/* If details->check_mapping, we leave swap entries. */
> > -		if (unlikely(details))
> > +		if (unlikely(details || !details->check_swap_entries))
> >  			continue;
> 
> &&

Ups, thanks for catching this! I was playing with the condition and
rearranged the code multiple times before posting.

Thanks!
---
diff --git a/mm/memory.c b/mm/memory.c
index 4750d7e942a3..49cafa195527 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1125,8 +1125,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			}
 			continue;
 		}
-		/* If details->check_mapping, we leave swap entries. */
-		if (unlikely(details || !details->check_swap_entries))
+		/* only check swap_entries if explicitly asked for in details */
+		if (unlikely(details && !details->check_swap_entries))
 			continue;
 
 		entry = pte_to_swp_entry(ptent);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
