Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 077C66B0266
	for <linux-mm@kvack.org>; Thu, 31 May 2018 21:21:31 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id n40-v6so14044708ote.13
        for <linux-mm@kvack.org>; Thu, 31 May 2018 18:21:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j131-v6si13003180oia.26.2018.05.31.18.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 18:21:29 -0700 (PDT)
Message-Id: <201806010121.w511LDbC077249@www262.sakura.ne.jp>
Subject: Re: [PATCH] mm,oom: Don't call =?ISO-2022-JP?B?c2NoZWR1bGVfdGltZW91dF9r?=
 =?ISO-2022-JP?B?aWxsYWJsZSgpIHdpdGggb29tX2xvY2sgaGVsZC4=?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 01 Jun 2018 10:21:13 +0900
References: <7276d450-5e66-be56-3a17-0fc77596a3b6@i-love.sakura.ne.jp> <20180531184721.GU15278@dhcp22.suse.cz>
In-Reply-To: <20180531184721.GU15278@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 01-06-18 00:23:57, Tetsuo Handa wrote:
> > On 2018/05/31 19:44, Michal Hocko wrote:
> > > On Thu 31-05-18 19:10:48, Tetsuo Handa wrote:
> > >> On 2018/05/30 8:07, Andrew Morton wrote:
> > >>> On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > >>>
> > >>>>> I suggest applying
> > >>>>> this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
> > >>>>
> > >>>> Well, I hope the whole pile gets merged in the upcoming merge window
> > >>>> rather than stall even more.
> > >>>
> > >>> I'm more inclined to drop it all.  David has identified significant
> > >>> shortcomings and I'm not seeing a way of addressing those shortcomings
> > >>> in a backward-compatible fashion.  Therefore there is no way forward
> > >>> at present.
> > >>>
> > >>
> > >> Can we apply my patch as-is first?
> > > 
> > > No. As already explained before. Sprinkling new sleeps without a strong
> > > reason is not acceptable. The issue you are seeing is pretty artificial
> > > and as such doesn're really warrant an immediate fix. We should rather
> > > go with a well thought trhough fix. In other words we should simply drop
> > > the sleep inside the oom_lock for starter unless it causes some really
> > > unexpected behavior change.
> > > 
> > 
> > The OOM killer did not require schedule_timeout_killable(1) to return
> > as long as the OOM victim can call __mmput(). But now the OOM killer
> > requires schedule_timeout_killable(1) to return in order to allow the
> > OOM victim to call __oom_reap_task_mm(). Thus, this is a regression.
> > 
> > Artificial cannot become the reason to postpone my patch. If we don't care
> > artificialness/maliciousness, we won't need to care Spectre/Meltdown bugs.
> > 
> > I'm not sprinkling new sleeps. I'm just merging existing sleeps (i.e.
> > mutex_trylock() case and !mutex_trylock() case) and updating the outdated
> > comments.
> 
> Sigh. So what exactly is wrong with going simple and do
> http://lkml.kernel.org/r/20180528124313.GC27180@dhcp22.suse.cz ?
> 

Because

  (1) You are trying to apply this fix after Roman's patchset which
      Andrew Morton is more inclined to drop.

  (2) You are making this fix difficult to backport because this
      patch depends on Roman's patchset.

  (3) You are not fixing the bug in Roman's patchset.

  (4) You are not updating the outdated comment in my patch and
      Roman's patchset.

  (5) You are not evaluating the side effect of not sleeping
      outside of the OOM path, despite you said

      > If we _really_ need to touch should_reclaim_retry then
      > it should be done in a separate patch with some numbers/tracing
      > data backing that story.

      and I consider that "whether moving the short sleep to
      should_reclaim_retry() has negative impact" and "whether
      eliminating the short sleep has negative impact" should be
      evaluated in a separate patch.

but I will tolerate below patch if you can accept below patch "as-is"
(because it explicitly notes what actually happens and there might be
unexpected side effect of not sleeping outside of the OOM path).
