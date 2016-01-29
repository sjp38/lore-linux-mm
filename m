Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 96D366B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:23:10 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id r129so73149622wmr.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:23:10 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id i187si11615334wma.47.2016.01.29.07.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 07:23:09 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id r129so10483596wmr.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:23:09 -0800 (PST)
Date: Fri, 29 Jan 2016 16:23:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/3] mm, oom: drop the last allocation attempt before
 out_of_memory
Message-ID: <20160129152307.GF32174@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <1454013603-3682-1-git-send-email-mhocko@kernel.org>
 <20160128213634.GA4903@cmpxchg.org>
 <alpine.DEB.2.10.1601281508380.31035@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601281508380.31035@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 28-01-16 15:19:08, David Rientjes wrote:
> On Thu, 28 Jan 2016, Johannes Weiner wrote:
> 
> > The check has to happen while holding the OOM lock, otherwise we'll
> > end up killing much more than necessary when there are many racing
> > allocations.
> > 
> 
> Right, we need to try with ALLOC_WMARK_HIGH after oom_lock has been 
> acquired.
> 
> The situation is still somewhat fragile, however, but I think it's 
> tangential to this patch series.  If the ALLOC_WMARK_HIGH allocation fails 
> because an oom victim hasn't freed its memory yet, and then the TIF_MEMDIE 
> thread isn't visible during the oom killer's tasklist scan because it has 
> exited, we still end up killing more than we should.  The likelihood of 
> this happening grows with the length of the tasklist.

Yes exactly the point I made in the original thread which brought the
question about ALLOC_WMARK_HIGH originally. The race window after the
last attempt is much larger than between the last wmark check and the
attempt.

> Perhaps we should try testing watermarks after a victim has been selected 
> and immediately before killing?  (Aside: we actually carry an internal 
> patch to test mem_cgroup_margin() in the memcg oom path after selecting a 
> victim because we have been hit with this before in the memcg path.)
> 
> I would think that retrying with ALLOC_WMARK_HIGH would be enough memory 
> to deem that we aren't going to immediately reenter an oom condition so 
> the deferred killing is a waste of time.
> 
> The downside is how sloppy this would be because it's blurring the line 
> between oom killer and page allocator.  We'd need the oom killer to return 
> the selected victim to the page allocator, try the allocation, and then 
> call oom_kill_process() if necessary.

Yes the layer violation is definitely not nice.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
