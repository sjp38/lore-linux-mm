Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE25D6B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 09:51:06 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r74so11563500oie.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 06:51:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q184si10795622oig.116.2017.07.17.06.51.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 06:51:05 -0700 (PDT)
Subject: Re: [PATCH v2] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170717085605.GE12888@dhcp22.suse.cz>
In-Reply-To: <20170717085605.GE12888@dhcp22.suse.cz>
Message-Id: <201707172250.DFE18753.VOSMOFOFFLQHtJ@I-love.SAKURA.ne.jp>
Date: Mon, 17 Jul 2017 22:50:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sun 16-07-17 19:59:51, Tetsuo Handa wrote:
> > Since the whole memory reclaim path has never been designed to handle the
> > scheduling priority inversions, those locations which are assuming that
> > execution of some code path shall eventually complete without using
> > synchronization mechanisms can get stuck (livelock) due to scheduling
> > priority inversions, for CPU time is not guaranteed to be yielded to some
> > thread doing such code path.
> > 
> > mutex_trylock() in __alloc_pages_may_oom() (waiting for oom_lock) and
> > schedule_timeout_killable(1) in out_of_memory() (already held oom_lock) is
> > one of such locations, and it was demonstrated using artificial stressing
> > that the system gets stuck effectively forever because SCHED_IDLE priority
> > thread is unable to resume execution at schedule_timeout_killable(1) if
> > a lot of !SCHED_IDLE priority threads are wasting CPU time [1].
> 
> I do not understand this. All the contending tasks will go and sleep for
> 1s. How can they preempt the lock holder?

Not 1s. It sleeps for only 1 jiffies, which is 1ms if CONFIG_HZ=1000.

And 1ms may not be long enough to allow the owner of oom_lock when there are
many threads doing the same thing. I demonstrated that SCHED_IDLE oom_lock
owner is completely defeated by a bunch of !SCHED_IDLE contending threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
