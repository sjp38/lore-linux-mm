Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 487C86B0275
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:23:44 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t83so203864978oie.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:23:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 97si2025158otb.120.2016.09.22.08.23.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 08:23:29 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,page_alloc: Allow !__GFP_FS allocations to invoke the OOM killer
Date: Fri, 23 Sep 2016 00:22:57 +0900
Message-Id: <1474557777-8288-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Historically we did not invoke the OOM killer for small !__GFP_FS memory
allocation requests when such allocation requests failed to make progress,
but we keep such allocation requests retry inside the page allocator by
telling a lie that some progress was made rather than make such allocation
requests fail. Such behavior might lead to silent OOM livelock situation
where nobody can invoke the OOM killer, but making such allocation requests
fail is inadvisable because it led to significant loss of reliability as
shown by http://lkml.kernel.org/r/201502202020.BGG05734.FJOSMLtHFQOFOV@I-love.SAKURA.ne.jp
and workarounded by commit cc87317726f85153 ("mm: page_alloc: revert
inadvertent !__GFP_FS retry behavior change").

There is a way to stop telling the lie by explicitly specifying either
__GFP_NOFAIL or __GFP_NORETRY to !__GFP_FS memory allocation requests.
We actually added __GFP_NOFAIL to some of such allocation requests as shown
by http://lkml.kernel.org/r/1438768284-30927-1-git-send-email-mhocko@kernel.org ,
but I did not agree with making !__GFP_NOFAIL !__GFP_FS memory allocation
requests fail.



I think that it is a too much assertive way to require all !__GFP_FS
memory allocation requests which can return an error code to userspace
processes to specify either __GFP_NOFAIL or __GFP_NORETRY (but making
!__GFP_NOFAIL !__GFP_FS memory allocation requests fail by default is
as well a too much assertive way).

In Linux, I think that the existence of the OOM killer and oom_score_adj
governs behavior when memory is exhausted, and specifying __GFP_NORETRY
goes against expectations controlled by oom_score_adj. In most cases,
userspace processes will terminate upon unexpected ENOMEM error. Such
consequence is not so different from killing some userspace process via
invoking the OOM killer. It is not desirable to return ENOMEM error to
userspace processes because an !__GFP_FS allocation request failed.
It is not a problem of userspace processes but the kernel's convenience
that whether memory allocation request which caused ENOMEM error was
__GFP_FS or not. It is annoying that an OOM unkillable userspace process
unexpectedly terminates rather than the OOM killer kills a process which
is most suitable for being OOM-killed.

Also, regarding !__GFP_FS memory allocation requests which cannot return
an error code to userspace, it is too late to recover as soon as such
allocation requests fail. It is sad that delayed writes (buffered I/O) are
lost simply due to the kernel's memory management's convenience. It will
be a significant loss of performance that userspace processes are asked
to use fsync() (or not to use delayed writes) for their self-defense
in case of system-wide OOM events.

Therefore, for userspace processes, allowing !__GFP_FS memory allocation
requests to invoke the OOM killer will be least painful approach.



Since most of memory allocation requests include __GFP_KSWAPD_RECLAIM,
kswapd will be woken up and kswapd will do __GFP_FS reclaim in the
background. Thus, effectively we can assume as if somebody is doing
__GFP_FS memory allocation request as long as !__GFP_FS memory allocation
requests are looping inside the page allocator. However, this assumption
depends on that somebody can invoke the OOM killer when nobody can reclaim
memory.

__GFP_FS memory allocation requests might wait for !__GFP_FS memory
allocation requests. For example, memory allocation requests are blocked
at too_many_isolated() from shrink_inactive_list() while kswapd is
blocked on fs locks waiting for fs writeback. Since the threshold of
too_many_isolated() for __GFP_FS memory allocation requests and !__GFP_FS
memory allocation requests differ, it is possible that only !__GFP_FS
memory allocation requests can arrive at __alloc_pages_may_oom() whereas
__GFP_FS memory allocation requests are blocked at too_many_isolated().
Therefore, the value of __GFP_FS's ability to invoke the OOM killer will be
lost unless it is guaranteed that !__GFP_FS memory allocation requests
are guaranteed to be able to make forward progress. Like explained above,
it is annoying thing for userspace processes that !__GFP_FS memory allocation
requests fail.

If I understand http://lkml.kernel.org/r/20150812091104.GA14940@dhcp22.suse.cz
correctly, currently not having a way to determine whether somebody else
can make progress via __GFP_FS reclaim is the reason not to invoke the
OOM killer. But regarding the OOM killer/reaper, we are eliminating
locations which may fall into OOM livelock (e.g.
http://lkml.kernel.org/r/201602171930.AII18204.FMOSVFQFOJtLOH@I-love.SAKURA.ne.jp ).
As a result, __GFP_FS check in out_of_memory() is the last location
which may fall into OOM livelock after out_of_memory() is called.



It is not clean that __GFP_FS has a role of allowing invoking the OOM
killer when __GFP_NOFAIL is not included. I think that __GFP_FS should be
independent with whether to invoke the OOM killer. Regarding behavior after
the OOM killer is invoked, (though CONFIG_MMU=y kernels only) we can now
guarantee forward progress. Thus, if we allow !__GFP_FS memory allocation
requests to invoke the OOM killer, (though CONFIG_MMU=y kernels only) we
can guarantee forward progress and eliminate possibility of silent OOM
livelock.

As a first step, I do want to eliminate possibility of silent OOM livelock.
If this patch causes !__GFP_FS memory allocation requests to invoke the
OOM killer trivially, at least we will be able to emit warning messages
periodically as long as we are telling the lie instead of invoking the
OOM killer. Without knowing which caller is falling into OOM livelock,
we will remain too cowardly to determine when we can stop telling the
lie and we will bother administrators with silent OOM livelock.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f284e92..7893c5c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1005,15 +1005,6 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	/*
-	 * The OOM killer does not compensate for IO-less reclaim.
-	 * pagefault_out_of_memory lost its gfp context so we have to
-	 * make sure exclude 0 mask - all other users should have at least
-	 * ___GFP_DIRECT_RECLAIM to get here.
-	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
-		return true;
-
-	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA and memcg) that may require different handling.
 	 */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
