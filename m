Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 56E1D6B026F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:48:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q127so7702478wmd.1
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:48:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f19si1206409wre.420.2017.10.31.05.48.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 05:48:57 -0700 (PDT)
Date: Tue, 31 Oct 2017 13:48:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after
 selecting an OOM victim.
Message-ID: <20171031124855.rszis5gefbxwriiz@dhcp22.suse.cz>
References: <1509178029-10156-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171030141815.lk76bfetmspf7f4x@dhcp22.suse.cz>
 <201710311940.FDJ52199.OHMtSFVFOJLOQF@I-love.SAKURA.ne.jp>
 <20171031121032.lm3wxx3l5tkpo2ni@dhcp22.suse.cz>
 <201710312142.DBB81723.FOOFJMQLStFVOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710312142.DBB81723.FOOFJMQLStFVOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Tue 31-10-17 21:42:23, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 31-10-17 19:40:09, Tetsuo Handa wrote:
> > > The reason I used __alloc_pages_slowpath() in alloc_pages_before_oomkill() is
> > > to avoid duplicating code (such as checking for ALLOC_OOM and rebuilding zone
> > > list) which needs to be maintained in sync with __alloc_pages_slowpath().
> > >
> > > If you don't like calling __alloc_pages_slowpath() from
> > > alloc_pages_before_oomkill(), I'm OK with calling __alloc_pages_nodemask()
> > > (with __GFP_DIRECT_RECLAIM/__GFP_NOFAIL cleared and __GFP_NOWARN set), for
> > > direct reclaim functions can call __alloc_pages_nodemask() (with PF_MEMALLOC
> > > set in order to avoid recursion of direct reclaim).
> > > 
> > > We are rebuilding zone list if selected as an OOM victim, for
> > > __gfp_pfmemalloc_flags() returns ALLOC_OOM if oom_reserves_allowed(current)
> > > is true.
> > 
> > So your answer is copy&paste without a deeper understanding, righ?
> 
> Right. I wanted to avoid duplicating code.
> But I had to duplicate in order to allow OOM victims to try ALLOC_OOM.

I absolutely hate this cargo cult programming!

[...]

> > While both have some merit, the first reason is mostly historical
> > because we have the explicit locking now and it is really unlikely that
> > the memory would be available right after we have given up trying.
> > Last attempt allocation makes some sense of course but considering that
> > the oom victim selection is quite an expensive operation which can take
> > a considerable amount of time it makes much more sense to retry the
> > allocation after the most expensive part rather than before. Therefore
> > move the last attempt right before we are trying to kill an oom victim
> > to rule potential races when somebody could have freed a lot of memory
> > in the meantime. This will reduce the time window for potentially
> > pre-mature OOM killing considerably.
> 
> But this is about "doing last second allocation attempt after selecting
> an OOM victim". This is not about "allowing OOM victims to try ALLOC_OOM
> before selecting next OOM victim" which is the actual problem I'm trying
> to deal with.

then split it into two. First make the general case and then add a more
sophisticated on top. Dealing with multiple issues at once is what makes
all those brain cells suffer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
