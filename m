Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C15B8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:19:18 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id s50so2286498edd.11
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 04:19:18 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15si3619344eds.266.2019.01.16.04.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 04:19:16 -0800 (PST)
Date: Wed, 16 Jan 2019 13:19:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Tolerate processes sharing mm with different
 view of oom_score_adj.
Message-ID: <20190116121915.GJ24149@dhcp22.suse.cz>
References: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190116110937.GI24149@dhcp22.suse.cz>
 <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Yong-Taek Lee <ytk.lee@samsung.com>

On Wed 16-01-19 20:30:25, Tetsuo Handa wrote:
> On 2019/01/16 20:09, Michal Hocko wrote:
> > On Wed 16-01-19 19:55:21, Tetsuo Handa wrote:
> >> This patch reverts both commit 44a70adec910d692 ("mm, oom_adj: make sure
> >> processes sharing mm have same view of oom_score_adj") and commit
> >> 97fd49c2355ffded ("mm, oom: kill all tasks sharing the mm") in order to
> >> close a race and reduce the latency at __set_oom_adj(), and reduces the
> >> warning at __oom_kill_process() in order to minimize the latency.
> >>
> >> Commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper managed
> >> to unmap the address space") introduced the worst case mentioned in
> >> 44a70adec910d692. But since the OOM killer skips mm with MMF_OOM_SKIP set,
> >> only administrators can trigger the worst case.
> >>
> >> Since 44a70adec910d692 did not take latency into account, we can hold RCU
> >> for minutes and trigger RCU stall warnings by calling printk() on many
> >> thousands of thread groups. Even without calling printk(), the latency is
> >> mentioned by Yong-Taek Lee [1]. And I noticed that 44a70adec910d692 is
> >> racy, and trying to fix the race will require a global lock which is too
> >> costly for rare events.
> >>
> >> If the worst case in 44a70adec910d692 happens, it is an administrator's
> >> request. Therefore, tolerate the worst case and speed up __set_oom_adj().
> > 
> > I really do not think we care about latency. I consider the overal API
> > sanity much more important. Besides that the original report you are
> > referring to was never exaplained/shown to represent real world usecase.
> > oom_score_adj is not really a an interface to be tweaked in hot paths.
> 
> I do care about the latency. Holding RCU for more than 2 minutes is insane.

Creating 8k threads could be considered insane as well. But more
seriously. I absolutely do not insist on holding a single RCU section
for the whole operation. But that doesn't really mean that we want to
revert these changes. for_each_process is by far not only called from
this path.

-- 
Michal Hocko
SUSE Labs
