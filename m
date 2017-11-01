Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA666B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 07:59:09 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j126so2232747oib.9
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 04:59:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d78si302722oih.31.2017.11.01.04.59.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 04:59:07 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171031124855.rszis5gefbxwriiz@dhcp22.suse.cz>
	<201710312213.BDB35457.MtFJOQVLOFSOHF@I-love.SAKURA.ne.jp>
	<20171031132259.irkladqbucz2qa3g@dhcp22.suse.cz>
	<201710312251.HBH43789.QVOFOtLFFSOHJM@I-love.SAKURA.ne.jp>
	<20171031141034.bg25xbo5cyfafnyp@dhcp22.suse.cz>
In-Reply-To: <20171031141034.bg25xbo5cyfafnyp@dhcp22.suse.cz>
Message-Id: <201711012058.CIF81791.OQOFHFLOFMSJtV@I-love.SAKURA.ne.jp>
Date: Wed, 1 Nov 2017 20:58:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Tue 31-10-17 22:51:49, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 31-10-17 22:13:05, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Tue 31-10-17 21:42:23, Tetsuo Handa wrote:
> > > > > > > While both have some merit, the first reason is mostly historical
> > > > > > > because we have the explicit locking now and it is really unlikely that
> > > > > > > the memory would be available right after we have given up trying.
> > > > > > > Last attempt allocation makes some sense of course but considering that
> > > > > > > the oom victim selection is quite an expensive operation which can take
> > > > > > > a considerable amount of time it makes much more sense to retry the
> > > > > > > allocation after the most expensive part rather than before. Therefore
> > > > > > > move the last attempt right before we are trying to kill an oom victim
> > > > > > > to rule potential races when somebody could have freed a lot of memory
> > > > > > > in the meantime. This will reduce the time window for potentially
> > > > > > > pre-mature OOM killing considerably.
> > > > > > 
> > > > > > But this is about "doing last second allocation attempt after selecting
> > > > > > an OOM victim". This is not about "allowing OOM victims to try ALLOC_OOM
> > > > > > before selecting next OOM victim" which is the actual problem I'm trying
> > > > > > to deal with.
> > > > > 
> > > > > then split it into two. First make the general case and then add a more
> > > > > sophisticated on top. Dealing with multiple issues at once is what makes
> > > > > all those brain cells suffer.
> > > > 
> > > > I'm failing to understand. I was dealing with single issue at once.
> > > > The single issue is "MMF_OOM_SKIP prematurely prevents OOM victims from trying
> > > > ALLOC_OOM before selecting next OOM victims". Then, what are the general case and
> > > > a more sophisticated? I wonder what other than "MMF_OOM_SKIP should allow OOM
> > > > victims to try ALLOC_OOM for once before selecting next OOM victims" can exist...
> > > 
> > > Try to think little bit out of your very specific and borderline usecase
> > > and it will become obvious. ALLOC_OOM is a trivial update on top of
> > > moving get_page_from_freelist to oom_kill_process which is a more
> > > generic race window reducer.
> > 
> > So, you meant "doing last second allocation attempt after selecting an OOM victim"
> > as the general case and "using ALLOC_OOM at last second allocation attempt" as a
> > more sophisticated. Then, you won't object conditionally switching ALLOC_WMARK_HIGH
> > and ALLOC_OOM for last second allocation attempt, will you?
> 
> yes for oom_victims

OK.

> 
> > But doing ALLOC_OOM for last second allocation attempt from out_of_memory() involve
> > duplicating code (e.g. rebuilding zone list).
> 
> Why would you do it? Do not blindly copy and paste code without
> a good reason. What kind of problem does this actually solve?

prepare_alloc_pages()/finalise_ac() initializes as

	ac->high_zoneidx = gfp_zone(gfp_mask);
	ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
						     ac->high_zoneidx, ac->nodemask);

and selecting as an OOM victim reinitializes as

	ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
						     ac->high_zoneidx, ac->nodemask);

and I assume that this reinitialization might affect which memory reserve
the OOM victim allocates from.

You mean such difference is too trivial to care about?

> 
> > What is your preferred approach?
> > Duplicate relevant code? Use get_page_from_freelist() without rebuilding the zone list?
> > Use __alloc_pages_nodemask() ?
> 
> Just do what we do now with ALLOC_WMARK_HIGH and in a separate patch use
> ALLOC_OOM for oom victims. There shouldn't be any reasons to play
> additional tricks here.
> 

Posted as http://lkml.kernel.org/r/1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

But I'm still unable to understand why "moving get_page_from_freelist to
oom_kill_process" is better than "copying get_page_from_freelist to
oom_kill_process", for "moving" increases possibility of allocation failures
when out_of_memory() is not called. Also, I'm still unable to understand why
to use ALLOC_WMARK_HIGH. I think that using regular watermark for last second
allocation attempt is better (as described below).

__alloc_pages_may_oom() is doing last second allocation attempt using
ALLOC_WMARK_HIGH before calling out_of_memory(). This has two motivations.
The first one is explained by the comment that it aims to catch potential
parallel OOM killing and the second one was explained by Andrea Arcangeli
as follows:
: Elaborating the comment: the reason for the high wmark is to reduce
: the likelihood of livelocks and be sure to invoke the OOM killer, if
: we're still under pressure and reclaim just failed. The high wmark is
: used to be sure the failure of reclaim isn't going to be ignored. If
: using the min wmark like you propose there's risk of livelock or
: anyway of delayed OOM killer invocation.

But neither motivation applies to current code. Regarding the former,
there is no parallel OOM killing (in the sense that out_of_memory() is
called "concurrently") because we serialize out_of_memory() calls using
oom_lock. Regarding the latter, there is no possibility of OOM livelocks
nor possibility of failing to invoke the OOM killer because we mask
__GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
second allocation attempt depends on from failing.

However, parallel OOM killing still exists (in the sense that
out_of_memory() is called "consecutively") because last second allocation
attempt cannot fully utilize memory reclaimed by previous round of OOM
killer invocation due to use of ALLOC_WMARK_HIGH. Sometimes doing last second
allocation attempt after selecting an OOM victim can succeed because
somebody might have managed to free memory while we were selecting an OOM
victim which can take quite some time. This suggests that giving up last
second allocation attempt as soon as ALLOC_WMARK_HIGH fails can be premature.

Even if last second allocation attempt after selecting an OOM victim would
still fail, already killed OOM victim might allow ALLOC_WMARK_MIN to succeed.
We don't need to select next OOM victims if ALLOC_WMARK_MIN can succeed.
Also, we don't need to select next OOM victims if existing OOM victims can
proceed with ALLOC_OOM. And these are what we are after all doing if
mutex_trylock(&oom_lock) in __alloc_pages_may_oom() fails. But it is
theoretically possible to hit sequence like

  Thread1           Thread2           Thread3

    Enters __alloc_pages_may_oom().
                    Enters __alloc_pages_may_oom().
                                      Enters __alloc_pages_may_oom().
    Preempted by somebody else.
                    Preempted by somebody else.
                                      mutex_trylock(&oom_lock) succeeds.
                                      get_page_from_freelist(ALLOC_WMARK_HIGH) fails. And get_page_from_freelist(ALLOC_WMARK_MIN) would have failed.
                                      Calls out_of_memory() and kills a not-such-memhog victim.
                                      Calls mutex_unlock(&oom_lock)
                    Returns from preemption.
                    mutex_trylock(&oom_lock) succeeds.
                    get_page_from_freelist(ALLOC_WMARK_HIGH) fails. But get_page_from_freelist(ALLOC_WMARK_MIN) would have succeeded.
                    Calls out_of_memory() and kills next not-such-memhog victim.
                    Calls mutex_unlock(&oom_lock)
    Returns from preemption.
    mutex_trylock(&oom_lock) succeeds.
    get_page_from_freelist(ALLOC_WMARK_HIGH) fails. But get_page_from_freelist(ALLOC_WMARK_MIN) would have succeeded.
    Calls out_of_memory() and kills next not-such-memhog victim.
    Calls mutex_unlock(&oom_lock)

and Thread1/Thread2 did not need to OOM-kill if ALLOC_WMARK_MIN were used.
When we hit sequence like above, using ALLOC_WMARK_HIGH for last second allocation
attempt unlikely helps avoiding potential parallel OOM killing. Rather, using
ALLOC_WMARK_MIN likely helps avoiding potential parallel OOM killing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
