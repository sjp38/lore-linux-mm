Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7136B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 18:19:10 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id ho8so30463259pac.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:19:10 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id 74si19700336pfa.156.2016.01.28.15.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 15:19:09 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id 65so31071953pfd.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:19:09 -0800 (PST)
Date: Thu, 28 Jan 2016 15:19:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/3] mm, oom: drop the last allocation attempt before
 out_of_memory
In-Reply-To: <20160128213634.GA4903@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1601281508380.31035@chino.kir.corp.google.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <1454013603-3682-1-git-send-email-mhocko@kernel.org> <20160128213634.GA4903@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, 28 Jan 2016, Johannes Weiner wrote:

> The check has to happen while holding the OOM lock, otherwise we'll
> end up killing much more than necessary when there are many racing
> allocations.
> 

Right, we need to try with ALLOC_WMARK_HIGH after oom_lock has been 
acquired.

The situation is still somewhat fragile, however, but I think it's 
tangential to this patch series.  If the ALLOC_WMARK_HIGH allocation fails 
because an oom victim hasn't freed its memory yet, and then the TIF_MEMDIE 
thread isn't visible during the oom killer's tasklist scan because it has 
exited, we still end up killing more than we should.  The likelihood of 
this happening grows with the length of the tasklist.

Perhaps we should try testing watermarks after a victim has been selected 
and immediately before killing?  (Aside: we actually carry an internal 
patch to test mem_cgroup_margin() in the memcg oom path after selecting a 
victim because we have been hit with this before in the memcg path.)

I would think that retrying with ALLOC_WMARK_HIGH would be enough memory 
to deem that we aren't going to immediately reenter an oom condition so 
the deferred killing is a waste of time.

The downside is how sloppy this would be because it's blurring the line 
between oom killer and page allocator.  We'd need the oom killer to return 
the selected victim to the page allocator, try the allocation, and then 
call oom_kill_process() if necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
