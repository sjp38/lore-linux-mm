Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED286B000D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 03:22:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so1835673edi.20
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:22:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f20-v6si365781edt.166.2018.07.04.00.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 00:22:29 -0700 (PDT)
Date: Wed, 4 Jul 2018 09:22:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup
 problem.
Message-ID: <20180704072228.GC22503@dhcp22.suse.cz>
References: <20180703151223.GP16767@dhcp22.suse.cz>
 <20180703152922.GR16767@dhcp22.suse.cz>
 <201807040222.w642Mtlr099513@www262.sakura.ne.jp>
 <20180704071632.GB22503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704071632.GB22503@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penguin-kernel@i-love.sakura.ne.jp
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Wed 04-07-18 09:16:32, Michal Hocko wrote:
> On Wed 04-07-18 11:22:55, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > On Tue 03-07-18 23:25:01, Tetsuo Handa wrote:
> > > > > This series provides
> > > > > 
> > > > >   (1) Mitigation and a fix for CVE-2016-10723.
> > > > > 
> > > > >   (2) A mitigation for needlessly selecting next OOM victim reported
> > > > >       by David Rientjes and rejected by Michal Hocko.
> > > > > 
> > > > >   (3) A preparation for handling many concurrent OOM victims which
> > > > >       could become real by introducing memcg-aware OOM killer.
> > > > 
> > > > It would have been great to describe the overal design in the cover
> > > > letter. So let me summarize just to be sure I understand the proposal.
> > 
> > You understood the proposal correctly.
> > 
> > > > You are removing the oom_reaper and moving the oom victim tear down to
> > > > the oom path.
> > 
> > Yes. This is for getting rid of the lie
> > 
> > 	/*
> > 	 * Acquire the oom lock.  If that fails, somebody else is
> > 	 * making progress for us.
> > 	 */
> > 	if (!mutex_trylock(&oom_lock)) {
> > 		*did_some_progress = 1;
> > 		schedule_timeout_uninterruptible(1);
> > 		return NULL;
> > 	}
> > 
> > which is leading to CVE-2016-10723. By reclaiming from the OOM killer path,
> > we can eliminate this heuristic.
> > 
> > Of course, we don't have to remove the OOM reaper kernel thread.
> 
> The thing is that the current design uses the oom_reaper only as a
> backup to get situation unstuck. Once you move all that heavy lifting
> into the oom path directly then you will have to handle all sorts of
> issues. E.g. how do you handle that a random process hitting OOM path
> has to pay the full price to tear down multi TB process? This is a lot
> of time.

And one more thing. Your current design doesn't solve any of the current
shortcomings. mlocked pages are still not reclaimable from the direct
oom tear down. Blockable mmu notifiers still prevent the direct tear
down. So the only thing that you achieve with a large and disruptive
patch is that the exit vs. oom locking protocol got simplified and that
you can handle oom domains from tasks belonging to them. This is not bad
but it has its own downsides which either fail to see or reluctant to
describe and explain.
-- 
Michal Hocko
SUSE Labs
