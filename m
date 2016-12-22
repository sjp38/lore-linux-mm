Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7AC28025E
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:24:11 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so6060462wmi.6
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 11:24:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iq8si3063356wjb.259.2016.12.22.11.24.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 11:24:10 -0800 (PST)
Date: Thu, 22 Dec 2016 20:24:07 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161222192406.GB19898@dhcp22.suse.cz>
References: <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
 <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
 <20161219122738.GB427@tigerII.localdomain>
 <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <201612222233.CBC56295.LFOtMOVQSJOFHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612222233.CBC56295.LFOtMOVQSJOFHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky@gmail.com, linux-mm@kvack.org, pmladek@suse.cz

On Thu 22-12-16 22:33:40, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Now, what options are left other than replacing !mutex_trylock(&oom_lock)
> > with mutex_lock_killable(&oom_lock) which also stops wasting CPU time?
> > Are we waiting for offloading sending to consoles?
> 
>  From http://lkml.kernel.org/r/20161222115057.GH6048@dhcp22.suse.cz :
> > > Although I don't know whether we agree with mutex_lock_killable(&oom_lock)
> > > change, I think this patch alone can go as a cleanup.
> > 
> > No, we don't agree on that part. As this is a printk issue I do not want
> > to workaround it in the oom related code. That is just ridiculous. The
> > very same issue would be possible due to other continous source of log
> > messages.
> 
> I don't think so. Lockup caused by printk() is printk's problem. But printk
> is not the only source of lockup. If CONFIG_PREEMPT=y, it is possible that
> a thread which held oom_lock can sleep for unbounded period depending on
> scheduling priority.

Unless there is some runaway realtime process then the holder of the oom
lock shouldn't be preempted for the _unbounded_ amount of time. It might
take quite some time, though. But that is not reduced to the OOM killer.
Any important part of the system (IO flushers and what not) would suffer
from the same issue.

> Then, you call such latency as scheduler's problem?
> mutex_lock_killable(&oom_lock) change helps coping with whatever delays
> OOM killer/reaper might encounter.

It helps _your_ particular insane workload. I believe you can construct
many others which which would cause a similar problem and the above
suggestion wouldn't help a bit. Until I can see this is easily
triggerable on a reasonably configured system then I am not convinced
we should add more non trivial changes to the oom killer path.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
