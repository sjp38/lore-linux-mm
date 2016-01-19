Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 096FA6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 18:13:49 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so183002302pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:13:49 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id tl10si2630004pac.177.2016.01.19.15.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 15:13:48 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id e65so183572180pfe.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:13:48 -0800 (PST)
Date: Tue, 19 Jan 2016 15:13:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
In-Reply-To: <201601151936.IJJ09362.OOFLtVFJHSFQMO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com>
References: <20160113180147.GL17512@dhcp22.suse.cz> <201601142026.BHI87005.FSOFJVFQMtHOOL@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1601141400170.16227@chino.kir.corp.google.com> <20160114225850.GA23382@cmpxchg.org> <alpine.DEB.2.10.1601141500370.22665@chino.kir.corp.google.com>
 <201601151936.IJJ09362.OOFLtVFJHSFQMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Jan 2016, Tetsuo Handa wrote:

> Leaving a system OOM-livelocked forever is very very annoying thing.

Agreed.

> My goal is to ask the OOM killer not to toss the OOM killer's duty away.
> What is important for me is that the OOM killer takes next action when
> current action did not solve the OOM situation.
> 

What is the "next action" when there are no more processes on your system, 
or attached to your memcg hierarchy, that are killable?

Of course your proposal offers no solution for that.  Extend it further: 
what is the "next action" when the process holding the mutex needed by the 
victim is oom disabled?

I don't think it's in the best interest of the user to randomly kill 
processes until one exits and implicitly hoping that one of your 
selections will be able to do so (your notion of "pick and pray").

> >                                         These additional kills can result
> > in the same livelock that is already problematic, and killing additional
> > processes has made the situation worse since memory reserves are more
> > depleted.
> 
> Why are you still assuming that memory reserves are more depleted if we kill
> additional processes? We are introducing the OOM reaper which can compensate
> memory reserves if we kill additional processes. We can make the OOM reaper
> update oom priority of all processes that use a mm the OOM killer chose
> ( http://lkml.kernel.org/r/201601131915.BCI35488.FHSFQtVMJOOOLF@I-love.SAKURA.ne.jp )
> so that we can help the OOM reaper compensate memory reserves by helping
> the OOM killer to select a different mm.
> 

We are not adjusting the selection heuristic, which is already 
determinisitic and people use to fine tune through procfs, for what the 
oom reaper can free.

Even if you can free memory immediately, there is no guarantee that a 
process holding a mutex needed for the victim to exit will be able to 
allocate from that memory.  Continuing to kill more and more processes may 
eventually solve the situation which simply granting access to memory 
reserves temporarily would have also solved, but at the cost of, well, 
many processes.

The final solution may combine both approaches, which are the only real 
approaches on how to make forward progress.  We could first try allowing 
temporary access to memory reserves when a livelock has been detected, 
similar to my patch, and then fallback to killing additional processes 
since the oom reaper should be able to at least free some of that memory 
immediately, if it fails.

However, I think the best course of action at the moment is to review and 
get the oom reaper merged, if applicable, since it should greatly aid this 
issue and then look at livelock issues as they arise once it is deployed.  
I'm not enthusiastic about adding additional heuristics and tunables for 
theoretical issues that may arise, especially considering the oom reaper 
is not even upstream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
