Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 456656B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:16:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t3so20151641wme.9
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 08:16:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q48si12784834wrb.280.2017.07.17.08.16.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 08:16:05 -0700 (PDT)
Date: Mon, 17 Jul 2017 17:15:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170717151558.GL12888@dhcp22.suse.cz>
References: <1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170717085605.GE12888@dhcp22.suse.cz>
 <201707172250.DFE18753.VOSMOFOFFLQHtJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707172250.DFE18753.VOSMOFOFFLQHtJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Mon 17-07-17 22:50:47, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 16-07-17 19:59:51, Tetsuo Handa wrote:
> > > Since the whole memory reclaim path has never been designed to handle the
> > > scheduling priority inversions, those locations which are assuming that
> > > execution of some code path shall eventually complete without using
> > > synchronization mechanisms can get stuck (livelock) due to scheduling
> > > priority inversions, for CPU time is not guaranteed to be yielded to some
> > > thread doing such code path.
> > > 
> > > mutex_trylock() in __alloc_pages_may_oom() (waiting for oom_lock) and
> > > schedule_timeout_killable(1) in out_of_memory() (already held oom_lock) is
> > > one of such locations, and it was demonstrated using artificial stressing
> > > that the system gets stuck effectively forever because SCHED_IDLE priority
> > > thread is unable to resume execution at schedule_timeout_killable(1) if
> > > a lot of !SCHED_IDLE priority threads are wasting CPU time [1].
> > 
> > I do not understand this. All the contending tasks will go and sleep for
> > 1s. How can they preempt the lock holder?
> 
> Not 1s. It sleeps for only 1 jiffies, which is 1ms if CONFIG_HZ=1000.

Right, for some reason I have seen HZ. My bad!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
