Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 912B56B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 07:36:47 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so8389174wjc.2
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:36:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z80si7008493wmd.57.2016.12.14.04.36.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 04:36:46 -0800 (PST)
Date: Wed, 14 Dec 2016 13:36:44 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214123644.GE16064@pathway.suse.cz>
References: <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
 <201612142037.EED00059.VJMOFLtSOQFFOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612142037.EED00059.VJMOFLtSOQFFOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.com, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On Wed 2016-12-14 20:37:51, Tetsuo Handa wrote:
> Petr Mladek wrote:
> > On Tue 2016-12-13 21:06:57, Tetsuo Handa wrote:
> > > Uptime > 400 are testcases where the stresser was invoked via "taskset -c 0".
> > > Since there are some "** XXX printk messages dropped **" messages, I can't
> > > tell whether the OOM killer was able to make forward progress. But guessing
> > >  from the result that there is no corresponding "Killed process" line for
> > > "Out of memory: " line at uptime = 450 and the duration of PID 14622 stalled,
> > > I think it is OK to say that the system got stuck because the OOM killer was
> > > not able to make forward progress.
> > 
> > I am afraid that as long as you see "** XXX printk messages dropped
> > **" then there is something that is able to keep warn_alloc() busy,
> > never leave the printk()/console_unlock() and and block OOM killer
> > progress.
> 
> Excuse me, but it is not warn_alloc() but functions that call printk()
> which are kept busy with oom_lock held (e.g. oom_kill_process()).

No, they are keeping busy each other. If I get it properly,
this is a livelock:

First, OOM killer stalls inside console_unlock() because
other processes produce new messages faster than it is able to
push to console.

Second, the other processes stall because they are waiting for
the OOM killer to get some free memory.

Now, the blocked processes try to inform about the situation
and produce that many messages. But there are also other
producers, like the hung task detector that see the problems
from outside and tries to inform about it as well.


There are basically two solution for this situation:

1. Fix printk() so that it does not block forever. This will
   get solved by the async printk patchset[*]. In the meantime,
   a particular sensitive location might be worked around
   by using printk_deferred() instead of printk()[**]

2. Reduce the amount of messages. It is insane to report
   the same problem many times so that the same messages
   fill the entire log buffer. Note that the allocator
   is not the only sinner here.

In fact, both solutions makes sense together.


[*] The async printk patchset is flying around in many
    modifications for years. I am more optimistic after
    the discussions on the last Kernel Summit. Anyway,
    it will not be in mainline before 4.12.

[**] printk_deferred() only puts massages into the log
     buffer. It does not call
     console_trylock()/console_unlock(). Therefore,
     it is always "fast".

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
