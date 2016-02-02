Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4AEE86B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 06:48:24 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id 65so102662793pfd.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 03:48:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id yp7si1531515pab.66.2016.02.02.03.48.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Feb 2016 03:48:23 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452094975-551-2-git-send-email-mhocko@kernel.org>
	<alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com>
	<20160128214247.GD621@dhcp22.suse.cz>
	<alpine.DEB.2.10.1602011843250.31751@chino.kir.corp.google.com>
	<20160202085758.GE19910@dhcp22.suse.cz>
In-Reply-To: <20160202085758.GE19910@dhcp22.suse.cz>
Message-Id: <201602022048.GCJ04176.tOFFSVFHLMJOQO@I-love.SAKURA.ne.jp>
Date: Tue, 2 Feb 2016 20:48:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, mgorman@suse.de, penguin-kernel@i-love.sakura.ne.jp, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > In this case, the oom reaper has ignored the next victim and doesn't do 
> > anything; the simple race has prevented it from zapping memory and does 
> > not reduce the livelock probability.
> > 
> > This can be solved either by queueing mm's to reap or involving the oom 
> > reaper into the oom killer synchronization itself.
> 
> as we have already discussed previously oom reaper is really tricky to
> be called from the direct OOM context. I will go with queuing. 
>  

OK. But it is not easy to build a reliable OOM-reap queuing chain. I think
that a dedicated kernel thread which does OOM-kill operation and OOM-reap
operation will be expected. That will also handle the "sleeping for too
long with oom_lock held after sending SIGKILL" problem.

> > I'm baffled by any reference to "memcg oom heavy loads", I don't 
> > understand this paragraph, sorry.  If a memcg is oom, we shouldn't be
> > disrupting the global runqueue by running oom_reaper at a high priority.  
> > The disruption itself is not only in first wakeup but also in how long the 
> > reaper can run and when it is rescheduled: for a lot of memory this is 
> > potentially long.  The reaper is best-effort, as the changelog indicates, 
> > and we shouldn't have a reliance on this high priority: oom kill exiting 
> > can't possibly be expected to be immediate.  This high priority should be 
> > removed so memcg oom conditions are isolated and don't affect other loads.
> 
> If this is a concern then I would be tempted to simply disable oom
> reaper for memcg oom altogether. For me it is much more important that
> the reaper, even though a best effort, is guaranteed to schedule if
> something goes terribly wrong on the machine.

I think that if something goes terribly wrong on the machine, a guarantee for
scheduling the reaper will not help unless we build a reliable queuing chain.
Building a reliable queuing chain will break some of assumptions provided by
current behavior. For me, a guarantee for scheduling for next OOM-kill
operation (with globally opening some or all of memory reserves) before
building a reliable queuing chain is much more important.

>                       But ohh well... I will queue up a patch to do this
> on top. I plan to repost the full patchset shortly.

Maybe we all agree with introducing OOM reaper without queuing, but I do
want to see a guarantee for scheduling for next OOM-kill operation before
trying to build a reliable queuing chain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
