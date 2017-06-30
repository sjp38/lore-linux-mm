Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0417C2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 12:19:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id j85so8094908wmj.2
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 09:19:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w72si6428364wrc.393.2017.06.30.09.19.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 09:19:11 -0700 (PDT)
Date: Fri, 30 Jun 2017 18:19:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170630161907.GC9714@dhcp22.suse.cz>
References: <20170309180540.GA8678@cmpxchg.org>
 <20170310102010.GD3753@dhcp22.suse.cz>
 <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
 <201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp>
 <20170630133236.GM22917@dhcp22.suse.cz>
 <201707010059.EAE43714.FOVOMOSLFHJFQt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707010059.EAE43714.FOVOMOSLFHJFQt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 01-07-17 00:59:56, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 30-06-17 09:14:22, Tetsuo Handa wrote:
> > [...]
> > > Ping? Ping? When are we going to apply this patch or watchdog patch?
> > > This problem occurs with not so insane stress like shown below.
> > > I can't test almost OOM situation because test likely falls into either
> > > printk() v.s. oom_lock lockup problem or this too_many_isolated() problem.
> > 
> > So you are saying that the patch fixes this issue. Do I understand you
> > corretly? And you do not see any other negative side effectes with it
> > applied?
> 
> I hit this problem using http://lkml.kernel.org/r/20170626130346.26314-1-mhocko@kernel.org
> on next-20170628. We won't be able to test whether the patch fixes this issue without
> seeing any other negative side effects without sending this patch to linux-next.git.
> But at least we know that even this patch is sent to linux-next.git, we will still see
> bugs like http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp .

It is really hard to pursue this half solution when there is no clear
indication it helps in your testing. So could you try to test with only
this patch on top of the current linux-next tree (or Linus tree) and see
if you can reproduce the problem?

It is possible that there are other potential problems but we at least
need to know whether it is worth going with the patch now.
 
[...]
> > Rik, Johannes what do you think? Should we go with the simpler approach
> > for now and think of a better plan longterm?
> 
> I don't hurry if we can check using watchdog whether this problem is occurring
> in the real world. I have to test corner cases because watchdog is missing.
> 
> Watchdog does not introduce negative side effects, will avoid soft lockups like
> http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com ,
> will avoid console_unlock() v.s. oom_lock mutext lockups due to warn_alloc(),
> will catch similar bugs which people are failing to reproduce.

this way of pushing your patch is really annoying. Please do realize
that repeating the same thing all around will not make a patch more
likely to merge. You have proposed something, nobody has nacked it
so it waits for people to actually find it important enough to justify
the additional code. So please stop this.

I really do appreciate your testing because it uncovers corner cases
most people do not test for and we can actually make the code better in
the end.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
