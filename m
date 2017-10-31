Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8314F6B026B
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:42:44 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q81so42601434ioi.12
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:42:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f141si1789514ita.110.2017.10.31.05.42.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 05:42:43 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1509178029-10156-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171030141815.lk76bfetmspf7f4x@dhcp22.suse.cz>
	<201710311940.FDJ52199.OHMtSFVFOJLOQF@I-love.SAKURA.ne.jp>
	<20171031121032.lm3wxx3l5tkpo2ni@dhcp22.suse.cz>
In-Reply-To: <20171031121032.lm3wxx3l5tkpo2ni@dhcp22.suse.cz>
Message-Id: <201710312142.DBB81723.FOOFJMQLStFVOH@I-love.SAKURA.ne.jp>
Date: Tue, 31 Oct 2017 21:42:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Tue 31-10-17 19:40:09, Tetsuo Handa wrote:
> > The reason I used __alloc_pages_slowpath() in alloc_pages_before_oomkill() is
> > to avoid duplicating code (such as checking for ALLOC_OOM and rebuilding zone
> > list) which needs to be maintained in sync with __alloc_pages_slowpath().
> >
> > If you don't like calling __alloc_pages_slowpath() from
> > alloc_pages_before_oomkill(), I'm OK with calling __alloc_pages_nodemask()
> > (with __GFP_DIRECT_RECLAIM/__GFP_NOFAIL cleared and __GFP_NOWARN set), for
> > direct reclaim functions can call __alloc_pages_nodemask() (with PF_MEMALLOC
> > set in order to avoid recursion of direct reclaim).
> > 
> > We are rebuilding zone list if selected as an OOM victim, for
> > __gfp_pfmemalloc_flags() returns ALLOC_OOM if oom_reserves_allowed(current)
> > is true.
> 
> So your answer is copy&paste without a deeper understanding, righ?

Right. I wanted to avoid duplicating code.
But I had to duplicate in order to allow OOM victims to try ALLOC_OOM.

> 
> [...]
> 
> > The reason I'm proposing this "mm,oom: Try last second allocation before and
> > after selecting an OOM victim." is that since oom_reserves_allowed(current) can
> > become true when current is between post __gfp_pfmemalloc_flags(gfp_mask) and
> > pre mutex_trylock(&oom_lock), an OOM victim can fail to try ALLOC_OOM attempt
> > before selecting next OOM victim when MMF_OOM_SKIP was set quickly.
> 
> ENOPARSE. I am not even going to finish this email sorry. This is way
> beyond my time budget.
> 
> Can you actually come with something that doesn't make ones head explode
> and yet describe what the actual problem is and how you deal with it?

http://lkml.kernel.org/r/201708191523.BJH90621.MHOOFFQSOLJFtV@I-love.SAKURA.ne.jp
is least head exploding while it describes what the actual problem is and
how I deal with it.

> 
> E.g something like this
> "
> OOM killer is invoked after all the reclaim attempts have failed and
> there doesn't seem to be a viable chance for the situation to change.
> __alloc_pages_may_oom tries to reduce chances of a race during OOM
> handling by taking oom lock so only one caller is allowed to really
> invoke the oom killer.

OK.
> 
> __alloc_pages_may_oom also tries last time ALLOC_WMARK_HIGH allocation
> request before really invoking out_of_memory handler. This has two
> motivations. The first one is explained by the comment and it aims to
> catch potential parallel OOM killing and the second one was explained by
> Andrea Arcangeli as follows:
> : Elaborating the comment: the reason for the high wmark is to reduce
> : the likelihood of livelocks and be sure to invoke the OOM killer, if
> : we're still under pressure and reclaim just failed. The high wmark is
> : used to be sure the failure of reclaim isn't going to be ignored. If
> : using the min wmark like you propose there's risk of livelock or
> : anyway of delayed OOM killer invocation.
> 

OK.

> While both have some merit, the first reason is mostly historical
> because we have the explicit locking now and it is really unlikely that
> the memory would be available right after we have given up trying.
> Last attempt allocation makes some sense of course but considering that
> the oom victim selection is quite an expensive operation which can take
> a considerable amount of time it makes much more sense to retry the
> allocation after the most expensive part rather than before. Therefore
> move the last attempt right before we are trying to kill an oom victim
> to rule potential races when somebody could have freed a lot of memory
> in the meantime. This will reduce the time window for potentially
> pre-mature OOM killing considerably.

But this is about "doing last second allocation attempt after selecting
an OOM victim". This is not about "allowing OOM victims to try ALLOC_OOM
before selecting next OOM victim" which is the actual problem I'm trying
to deal with. Moving last second allocation attempt from "before" to
"after" does not solve the problem if ALLOC_OOM cannot be used. What I'm
proposing is to allow OOM victims to try ALLOC_OOM.

> "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
