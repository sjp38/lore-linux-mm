Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8993E6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 18:49:28 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id e65so12707332pfe.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 15:49:28 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id qw9si5673231pab.126.2016.01.20.15.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 15:49:27 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id cy9so12503363pac.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 15:49:27 -0800 (PST)
Date: Wed, 20 Jan 2016 15:49:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
In-Reply-To: <201601202336.BJC04687.FOFVOQJOLSFtMH@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601201538070.18155@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1601141400170.16227@chino.kir.corp.google.com> <20160114225850.GA23382@cmpxchg.org> <alpine.DEB.2.10.1601141500370.22665@chino.kir.corp.google.com> <201601151936.IJJ09362.OOFLtVFJHSFQMO@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com> <201601202336.BJC04687.FOFVOQJOLSFtMH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 20 Jan 2016, Tetsuo Handa wrote:

> > > My goal is to ask the OOM killer not to toss the OOM killer's duty away.
> > > What is important for me is that the OOM killer takes next action when
> > > current action did not solve the OOM situation.
> > > 
> > 
> > What is the "next action" when there are no more processes on your system, 
> 
> Just call panic(), as with select_bad_process() from out_of_memory() returned
> NULL.
> 

No way is that a possible solution for a system-wide oom condition.  We 
could have megabytes of memory available in memory reserves and a simple 
allocation succeeding could fix the livelock quite easily (and can be 
demonstrated with my testcase).  A panic is never better than allowing an 
allocation to succeed through the use of available memory reserves.

For the memcg case, we wouldn't panic() when there are no more killable 
processes, and this livelock problem can easily be exhibited in memcg 
hierarchy oom conditions as well (and quite easier since it's in 
isolation and doesn't get interferred with by external process freeing 
elsewhere on the system).  So, again, your approach offers no solution to 
this case and you presumably suggest that we should leave the hierarchy 
livelocked forever.  Again, not a possible solution.

> If we can agree on combining both approaches, I'm OK with it. That will keep
> the OOM reaper simple, for the OOM reaper will not need to clear TIF_MEMDIE
> flag which is unfriendly for wait_event() in oom_killer_disable(), and the
> OOM reaper will not need to care about situations where TIF_MEMDIE flag is
> set when it is not safe to reap.
> 

Please, allow us to review and get the oom reaper merged first and then 
evaluate the problem afterwards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
