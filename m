Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8679D6B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 04:04:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id i1-v6so14856374pld.11
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 01:04:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7-v6si38091975plp.304.2018.06.01.01.04.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jun 2018 01:04:48 -0700 (PDT)
Date: Fri, 1 Jun 2018 10:04:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180601080443.GX15278@dhcp22.suse.cz>
References: <7276d450-5e66-be56-3a17-0fc77596a3b6@i-love.sakura.ne.jp>
 <20180531184721.GU15278@dhcp22.suse.cz>
 <201806010121.w511LDbC077249@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201806010121.w511LDbC077249@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org

On Fri 01-06-18 10:21:13, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 01-06-18 00:23:57, Tetsuo Handa wrote:
> > > On 2018/05/31 19:44, Michal Hocko wrote:
> > > > On Thu 31-05-18 19:10:48, Tetsuo Handa wrote:
> > > >> On 2018/05/30 8:07, Andrew Morton wrote:
> > > >>> On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > > >>>
> > > >>>>> I suggest applying
> > > >>>>> this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
> > > >>>>
> > > >>>> Well, I hope the whole pile gets merged in the upcoming merge window
> > > >>>> rather than stall even more.
> > > >>>
> > > >>> I'm more inclined to drop it all.  David has identified significant
> > > >>> shortcomings and I'm not seeing a way of addressing those shortcomings
> > > >>> in a backward-compatible fashion.  Therefore there is no way forward
> > > >>> at present.
> > > >>>
> > > >>
> > > >> Can we apply my patch as-is first?
> > > > 
> > > > No. As already explained before. Sprinkling new sleeps without a strong
> > > > reason is not acceptable. The issue you are seeing is pretty artificial
> > > > and as such doesn're really warrant an immediate fix. We should rather
> > > > go with a well thought trhough fix. In other words we should simply drop
> > > > the sleep inside the oom_lock for starter unless it causes some really
> > > > unexpected behavior change.
> > > > 
> > > 
> > > The OOM killer did not require schedule_timeout_killable(1) to return
> > > as long as the OOM victim can call __mmput(). But now the OOM killer
> > > requires schedule_timeout_killable(1) to return in order to allow the
> > > OOM victim to call __oom_reap_task_mm(). Thus, this is a regression.
> > > 
> > > Artificial cannot become the reason to postpone my patch. If we don't care
> > > artificialness/maliciousness, we won't need to care Spectre/Meltdown bugs.
> > > 
> > > I'm not sprinkling new sleeps. I'm just merging existing sleeps (i.e.
> > > mutex_trylock() case and !mutex_trylock() case) and updating the outdated
> > > comments.
> > 
> > Sigh. So what exactly is wrong with going simple and do
> > http://lkml.kernel.org/r/20180528124313.GC27180@dhcp22.suse.cz ?
> > 
> 
> Because
> 
>   (1) You are trying to apply this fix after Roman's patchset which
>       Andrew Morton is more inclined to drop.
> 
>   (2) You are making this fix difficult to backport because this
>       patch depends on Roman's patchset.
> 
>   (3) You are not fixing the bug in Roman's patchset.

Sigh. Would you be more happy if this was on top of linus tree? I mean
this is trivial to do so. I have provided _something_ for testing
exactly as you asked for. Considering that the cgroup aware oom killer
shouldn't stand in a way for global oom killer without a special
configurion I do no see what is the actual problem.

>   (4) You are not updating the outdated comment in my patch and
>       Roman's patchset.

But the comment is not really related to the sleep in any way. This
should be a separate patch AFAICS.

>   (5) You are not evaluating the side effect of not sleeping
>       outside of the OOM path, despite you said

Exactly. There is no point in preserving the status quo if you cannot
reasonably argue of the effect. And I do not see the actual problem to
be honest. If there are any, we can always fix up (note that OOM are
rare events we do not optimize for) with the proper justification.

>       > If we _really_ need to touch should_reclaim_retry then
>       > it should be done in a separate patch with some numbers/tracing
>       > data backing that story.
> 
>       and I consider that "whether moving the short sleep to
>       should_reclaim_retry() has negative impact" and "whether
>       eliminating the short sleep has negative impact" should be
>       evaluated in a separate patch.
> 
> but I will tolerate below patch if you can accept below patch "as-is"
> (because it explicitly notes what actually happens and there might be
> unexpected side effect of not sleeping outside of the OOM path).

Well, I do not mind. If you really insist then I just do not care enough
to argue. But please note that this very patch breaks your 1, 2, 3 :p
So if you are really serious you should probably apply and test the
following on top of Linus tree:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb88cf58..ed9d473c571e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1077,15 +1077,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen && oc->chosen != (void *)-1UL) {
+	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return !!oc->chosen;
 }
 
-- 
Michal Hocko
SUSE Labs
