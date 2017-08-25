Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3D344088B
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 04:00:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c28so1925678wra.12
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 01:00:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q127si796631wmb.43.2017.08.25.01.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 01:00:24 -0700 (PDT)
Date: Fri, 25 Aug 2017 10:00:20 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after
 selecting an OOM victim.
Message-ID: <20170825080020.GE25498@dhcp22.suse.cz>
References: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170824131836.GN5943@dhcp22.suse.cz>
 <201708242340.ICG00066.JtFOFVSMOHOLFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708242340.ICG00066.JtFOFVSMOHOLFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Thu 24-08-17 23:40:36, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 24-08-17 21:18:26, Tetsuo Handa wrote:
> > > Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> > > count causes random kernel panics when an OOM victim which consumed memory
> > > in a way the OOM reaper does not help was selected by the OOM killer [1].
> > > 
> > > Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> > > oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> > > to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> > > victim's mm were not able to try allocation from memory reserves after the
> > > OOM reaper gave up reclaiming memory.
> > > 
> > > I proposed a patch which alllows task_will_free_mem(current) in
> > > out_of_memory() to ignore MMF_OOM_SKIP for once so that all OOM victim
> > > threads are guaranteed to have tried ALLOC_OOM allocation attempt before
> > > start selecting next OOM victims [2], for Michal Hocko did not like
> > > calling get_page_from_freelist() from the OOM killer which is a layer
> > > violation [3]. But now, Michal thinks that calling get_page_from_freelist()
> > > after task_will_free_mem(current) test is better than allowing
> > > task_will_free_mem(current) to ignore MMF_OOM_SKIP for once [4], for
> > > this would help other cases when we race with an exiting tasks or somebody
> > > managed to free memory while we were selecting an OOM victim which can take
> > > quite some time.
> > 
> > This a lot of text which can be more confusing than helpful. Could you
> > state the problem clearly without detours? Yes, the oom killer selection
> > can race with those freeing memory. And it has been like that since
> > basically ever.
> 
> The problem which Manish Jaggi reported (and I can still reproduce) is that
> the OOM killer ignores MMF_OOM_SKIP mm too early. And the problem became real
> in 4.8 due to commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks"). Thus, it has _not_ been like that since basically ever.

Again, you are mixing more things together. Manish usecase triggers a
pathological case where the oom reaper is not able to reclaim basically
any memory and so we unnecessarily kill another victim if the original
one doesn't finish quick enough.

This patch and your former attempts will only help (for that particular
case) if the victim itself wanted to allocate and didn't manage to pass
through the ALLOC_OOM attempt since it was killed. This yet again a
corner case and something this patch won't plug in general (it only
takes another task to go that path). That's why I consider that
confusing to mention in the changelog.

What I am trying to say is that time-to-check vs time-to-kill has
been a race window since ever and a large amount of memory can be
released during that time. This patch definitely reduces that time
window _considerably_. There is still a race window left but this is
inherently racy so you could argue that the remaining window is small to
lose sleep over. After all this is a corner case again. From my years of
experience with OOM reports I haven't met many (if any) cases like that.
So the primary question is whether we do care about this race window
enough to even try to fix it. Considering an absolute lack of reports
I would tend to say we don't but if the fix can be made non-intrusive
which seems likely then we actually can try it out at least.

> >                                        I wanted to remove this some time
> > ago but it has been pointed out that this was really needed
> > https://patchwork.kernel.org/patch/8153841/ Maybe things have changed
> > and if so please explain.
> 
> get_page_from_freelist() in __alloc_pages_may_oom() will remain needed
> because it can help allocations which do not call oom_kill_process() (i.e.
> allocations which do "goto out;" in __alloc_pages_may_oom() without calling
> out_of_memory(), and allocations which do "return;" in out_of_memory()
> without calling oom_kill_process() (e.g. !__GFP_FS)) to succeed.

I do not understand. Those request will simply back off and retry the
allocation or bail out and fail the allocation. My primary question was

: that the above link contains an explanation from Andrea that the reason
: for the high wmark is to reduce the likelihood of livelocks and be sure
: to invoke the OOM killer,

I am not sure how much that reason applies to the current code but if it
still applies then we should do the same for later
last-minute-allocation as well. Having both and disagreeing is just a
mess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
