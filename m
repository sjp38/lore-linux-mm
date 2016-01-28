Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C448C6B0256
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 18:51:35 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l66so46513780wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:51:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e4si18416693wjy.109.2016.01.28.15.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 15:51:34 -0800 (PST)
Date: Thu, 28 Jan 2016 18:51:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/3] mm, oom: drop the last allocation attempt before
 out_of_memory
Message-ID: <20160128235110.GA5805@cmpxchg.org>
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
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Jan 28, 2016 at 03:19:08PM -0800, David Rientjes wrote:
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
> 
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

https://lkml.org/lkml/2015/3/25/40

We could have out_of_memory() wait until the number of outstanding OOM
victims drops to 0. Then __alloc_pages_may_oom() doesn't relinquish
the lock until its kill has been finalized:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 914451a..4dc5b9d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -892,7 +892,9 @@ bool out_of_memory(struct oom_control *oc)
 		 * Give the killed process a good chance to exit before trying
 		 * to allocate memory again.
 		 */
-		schedule_timeout_killable(1);
+		if (!test_thread_flag(TIF_MEMDIE))
+			wait_event_timeout(oom_victims_wait,
+					   !atomic_read(&oom_victims), HZ);
 	}
 	return true;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
