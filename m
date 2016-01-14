Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 76610828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 18:09:59 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id e65so107365829pfe.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 15:09:59 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id mj8si12062216pab.50.2016.01.14.15.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 15:09:58 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id q63so110259830pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 15:09:58 -0800 (PST)
Date: Thu, 14 Jan 2016 15:09:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
In-Reply-To: <20160114225850.GA23382@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1601141500370.22665@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com> <201601132111.GIG81705.LFOOHFOtQJSMVF@I-love.SAKURA.ne.jp> <20160113162610.GD17512@dhcp22.suse.cz> <20160113165609.GA21950@cmpxchg.org> <20160113180147.GL17512@dhcp22.suse.cz>
 <201601142026.BHI87005.FSOFJVFQMtHOOL@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1601141400170.16227@chino.kir.corp.google.com> <20160114225850.GA23382@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jan 2016, Johannes Weiner wrote:

> > This is where me and you disagree; the goal should not be to continue to 
> > oom kill more and more processes since there is no guarantee that further 
> > kills will result in forward progress.  These additional kills can result 
> > in the same livelock that is already problematic, and killing additional 
> > processes has made the situation worse since memory reserves are more 
> > depleted.
> > 
> > I believe what is better is to exhaust reclaim, check if the page 
> > allocator is constantly looping due to waiting for the same victim to 
> > exit, and then allowing that allocation with memory reserves, see the 
> > attached patch which I have proposed before.
> 
> If giving the reserves to another OOM victim is bad, how is giving
> them to the *allocating* task supposed to be better?

Unfortunately, due to rss and oom priority, it is possible to repeatedly 
select processes which are all waiting for the same mutex.  This is 
possible when loading shards, for example, and all processes have the same 
oom priority and are livelocked on i_mutex which is the most common 
occurrence in our environments.  The livelock came about because we 
selected a process that could not make forward progress, there is no 
guarantee that we will not continue to select such processes.

Giving access to the memory allocator eventually allows all allocators to 
successfully allocate, giving the holder of i_mutex the ability to 
eventually drop it.  This happens in a very rate-limited manner depending 
on how you define when the page allocator has looped enough waiting for 
the same process to exit in my patch.

In the past, we have even increased the scheduling priority of oom killed 
processes so that they have a greater likelihood of picking up i_mutex and 
exiting.

> We need to make the OOM killer conclude in a fixed amount of time, no
> matter what happens. If the system is irrecoverably deadlocked on
> memory it needs to panic (and reboot) so we can get on with it. And
> it's silly to panic while there are still killable tasks available.
> 

What is the solution when there are no additional processes that may be 
killed?  It is better to give access to memory reserves so a single 
stalling allocation can succeed so the livelock can be resolved rather 
than panicking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
