Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 791A96B027A
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 10:39:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l5so2739385oib.0
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 07:39:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a52si514341ota.32.2017.11.01.07.39.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 07:39:08 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171031132259.irkladqbucz2qa3g@dhcp22.suse.cz>
	<201710312251.HBH43789.QVOFOtLFFSOHJM@I-love.SAKURA.ne.jp>
	<20171031141034.bg25xbo5cyfafnyp@dhcp22.suse.cz>
	<201711012058.CIF81791.OQOFHFLOFMSJtV@I-love.SAKURA.ne.jp>
	<20171101124601.aqk3ayjp643ifdw3@dhcp22.suse.cz>
In-Reply-To: <20171101124601.aqk3ayjp643ifdw3@dhcp22.suse.cz>
Message-Id: <201711012338.AGB30781.JHOMFQFVSFtOLO@I-love.SAKURA.ne.jp>
Date: Wed, 1 Nov 2017 23:38:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Wed 01-11-17 20:58:50, Tetsuo Handa wrote:
> > > > But doing ALLOC_OOM for last second allocation attempt from out_of_memory() involve
> > > > duplicating code (e.g. rebuilding zone list).
> > > 
> > > Why would you do it? Do not blindly copy and paste code without
> > > a good reason. What kind of problem does this actually solve?
> > 
> > prepare_alloc_pages()/finalise_ac() initializes as
> > 
> > 	ac->high_zoneidx = gfp_zone(gfp_mask);
> > 	ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
> > 	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > 						     ac->high_zoneidx, ac->nodemask);
> > 
> > and selecting as an OOM victim reinitializes as
> > 
> > 	ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> > 	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > 						     ac->high_zoneidx, ac->nodemask);
> > 
> > and I assume that this reinitialization might affect which memory reserve
> > the OOM victim allocates from.
> > 
> > You mean such difference is too trivial to care about?
> 
> You keep repeating what the _current_ code does without explaining _why_
> do we need the same thing in the oom path. Could you finaly answer my
> question please?

Because I consider that following what the current code does is reasonable
unless there are explicit reasons not to follow.

> 
> > > > What is your preferred approach?
> > > > Duplicate relevant code? Use get_page_from_freelist() without rebuilding the zone list?
> > > > Use __alloc_pages_nodemask() ?
> > > 
> > > Just do what we do now with ALLOC_WMARK_HIGH and in a separate patch use
> > > ALLOC_OOM for oom victims. There shouldn't be any reasons to play
> > > additional tricks here.
> > > 
> > 
> > Posted as http://lkml.kernel.org/r/1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .
> > 
> > But I'm still unable to understand why "moving get_page_from_freelist to
> > oom_kill_process" is better than "copying get_page_from_freelist to
> > oom_kill_process", for "moving" increases possibility of allocation failures
> > when out_of_memory() is not called.
> 
> The changelog I have provided to you should answer that. It is highly
> unlikely there high wmark would succeed _right_ after we have just given
> up. If this assumption is not correct then we can _add_ such a call
> based on a real data rather than add more bloat "just because we used to
> do that". As I've said I completely hate the cargo cult programming. Do
> not add more.

I think that it is highly unlikely high wmark would succeed. But
I don't think that it is highly unlikely normal wmark would succeed.

> 
> > Also, I'm still unable to understand why
> > to use ALLOC_WMARK_HIGH. I think that using regular watermark for last second
> > allocation attempt is better (as described below).
> 
> If you believe that a standard wmark is sufficient then make it a
> separate patch with the full explanation why.
> 
> > __alloc_pages_may_oom() is doing last second allocation attempt using
> > ALLOC_WMARK_HIGH before calling out_of_memory(). This has two motivations.
> > The first one is explained by the comment that it aims to catch potential
> > parallel OOM killing and the second one was explained by Andrea Arcangeli
> > as follows:
> > : Elaborating the comment: the reason for the high wmark is to reduce
> > : the likelihood of livelocks and be sure to invoke the OOM killer, if
> > : we're still under pressure and reclaim just failed. The high wmark is
> > : used to be sure the failure of reclaim isn't going to be ignored. If
> > : using the min wmark like you propose there's risk of livelock or
> > : anyway of delayed OOM killer invocation.
> > 
> > But neither motivation applies to current code. Regarding the former,
> > there is no parallel OOM killing (in the sense that out_of_memory() is
> > called "concurrently") because we serialize out_of_memory() calls using
> > oom_lock. Regarding the latter, there is no possibility of OOM livelocks
> > nor possibility of failing to invoke the OOM killer because we mask
> > __GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
> > prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
> > second allocation attempt depends on from failing.
> 
> Read that comment again. I believe you have misunderstood it. It is not
> about gfp flags at all. It is that we simply never invoke oom killer
> just because of small allocation fluctuations.

???

Does "that comment" refer to

  Go through the zonelist yet one more time, keep very high watermark
  here, this is only to catch a parallel oom killing, we must fail if
  we're still under heavy pressure.

part? Then, I know it is not about gfp flags.

Am I misunderstanding what "we must fail" means? My interpretation is
that "we must call out_of_memory() if the system is under memory pressure
that is enough to fail ALLOC_WMARK_HIGH". And I think that "enough to fail
ALLOC_WMARK_MIN" is heavier pressure than "enough to fail ALLOC_WMARK_HIGH".

Does "that comment" refer to

  Elaborating the comment: the reason for the high wmark is to reduce
  the likelihood of livelocks and be sure to invoke the OOM killer, if
  we're still under pressure and reclaim just failed. The high wmark is
  used to be sure the failure of reclaim isn't going to be ignored. If
  using the min wmark like you propose there's risk of livelock or
  anyway of delayed OOM killer invocation.

part? Then, I know it is not about gfp flags.

But how can OOM livelock happen when the last second allocation does not
wait for memory reclaim (because __GFP_DIRECT_RECLAIM is masked) ?
The last second allocation shall return immediately, and we will call
out_of_memory() if the last second allocation failed.

> 
> [...]
> >   Thread1           Thread2           Thread3
> > 
> >     Enters __alloc_pages_may_oom().
> >                     Enters __alloc_pages_may_oom().
> >                                       Enters __alloc_pages_may_oom().
> >     Preempted by somebody else.
> >                     Preempted by somebody else.
> >                                       mutex_trylock(&oom_lock) succeeds.
> >                                       get_page_from_freelist(ALLOC_WMARK_HIGH) fails. And get_page_from_freelist(ALLOC_WMARK_MIN) would have failed.
> >                                       Calls out_of_memory() and kills a not-such-memhog victim.
> >                                       Calls mutex_unlock(&oom_lock)
> >                     Returns from preemption.
> >                     mutex_trylock(&oom_lock) succeeds.
> >                     get_page_from_freelist(ALLOC_WMARK_HIGH) fails. But get_page_from_freelist(ALLOC_WMARK_MIN) would have succeeded.
> >                     Calls out_of_memory() and kills next not-such-memhog victim.
> >                     Calls mutex_unlock(&oom_lock)
> >     Returns from preemption.
> >     mutex_trylock(&oom_lock) succeeds.
> >     get_page_from_freelist(ALLOC_WMARK_HIGH) fails. But get_page_from_freelist(ALLOC_WMARK_MIN) would have succeeded.
> >     Calls out_of_memory() and kills next not-such-memhog victim.
> >     Calls mutex_unlock(&oom_lock)
> > 
> > and Thread1/Thread2 did not need to OOM-kill if ALLOC_WMARK_MIN were used.
> > When we hit sequence like above, using ALLOC_WMARK_HIGH for last second allocation
> > attempt unlikely helps avoiding potential parallel OOM killing. Rather, using
> > ALLOC_WMARK_MIN likely helps avoiding potential parallel OOM killing.
> 
> I am not sure such a scenario matters all that much because it assumes
> that the oom victim doesn't really free much memory [1] (basically less than
> HIGH-MIN). Most OOM situation simply have a memory hog consuming
> significant amount of memory.

The OOM killer does not always kill a memory hog consuming significant amount
of memory. The OOM killer kills a process with highest OOM score (and instead
one of its children if any). I don't think that assuming an OOM victim will free
memory enough to succeed ALLOC_WMARK_HIGH is appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
