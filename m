Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D9523280247
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 19:56:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d28so22405533pfe.1
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 16:56:25 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m26si8673463pli.826.2017.11.15.16.56.24
        for <linux-mm@kvack.org>;
        Wed, 15 Nov 2017 16:56:24 -0800 (PST)
Date: Thu, 16 Nov 2017 09:56:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171116005622.GC12222@bbox>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115090251.umpd53zpvp42xkvi@dhcp22.suse.cz>
 <201711151958.CBI60413.FHQMtFLFOOSOJV@I-love.SAKURA.ne.jp>
 <20171115115143.yh4xl43w3iteqh35@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115115143.yh4xl43w3iteqh35@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 15, 2017 at 12:51:43PM +0100, Michal Hocko wrote:
< snip >
> > Since it is possible for a local unpriviledged user to lockup the system at least
> > due to mute_trylock(&oom_lock) versus (printk() or schedule_timeout_killable(1)),
> > I suggest completely eliminating scheduling priority problem (i.e. a very low
> > scheduling priority thread might take 100 seconds inside some do_shrink_slab()
> > call) by not relying on an assumption of shortly returning from do_shrink_slab().
> > My first patch + my second patch will eliminate relying on such assumption, and
> > avoid potential khungtaskd warnings.
> 
> It doesn't, because the priority issues will be still there when anybody
> can preempt your shrinker for extensive amount of time. So no you are
> not fixing the problem. You are merely make it less probable and limited
> only to the removed shrinker. You still do not have any control over
> what happens while that shrinker is executed, though.
> 
> Anyway, I do not claim your patch is a wrong approach. It is just quite
> complex and maybe unnecessarily so for most workloads. Therefore going
> with a simpler solution should be preferred until we see it
> insufficient.

That's exactly what I intended.

Try simple one firstly. Then, wait until the simple one is broken.
If it is broken, we can add more complicated thing this time.

By that model, we are going forwad to complicated stuff with good
justification without losing the chance to understand/learn new workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
