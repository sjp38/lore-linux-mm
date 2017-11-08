Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 149194403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 06:35:36 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p2so1943202pfk.13
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 03:35:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z4si3636684pgs.301.2017.11.08.03.35.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 03:35:34 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/5] mm,oom: Use ALLOC_OOM for OOM victim's last second allocation.
Date: Wed,  8 Nov 2017 20:01:46 +0900
Message-Id: <1510138908-6265-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Manish Jaggi <mjaggi@caviumnetworks.com>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
count causes random kernel panics when an OOM victim which consumed memory
in a way the OOM reaper does not help was selected by the OOM killer [1].
Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
victim's mm were not able to try allocation from memory reserves after the
OOM reaper gave up reclaiming memory.

Therefore, this patch allows OOM victims to use ALLOC_OOM watermark for
last second allocation attempt.

[1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com

Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 764f24c..fbbc95a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4153,13 +4153,19 @@ struct page *alloc_pages_before_oomkill(const struct oom_control *oc)
 	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
 	 * already held. And since this allocation attempt does not sleep,
 	 * there is no reason we must use high watermark here.
+	 * But anyway, make sure that OOM victims can try ALLOC_OOM watermark
+	 * in case they haven't tried ALLOC_OOM watermark.
 	 */
 	int alloc_flags = ALLOC_CPUSET | ALLOC_WMARK_HIGH;
 	gfp_t gfp_mask = oc->gfp_mask | __GFP_HARDWALL;
+	int reserve_flags;
 
 	if (!oc->ac)
 		return NULL;
 	gfp_mask &= ~__GFP_DIRECT_RECLAIM;
+	reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
+	if (reserve_flags)
+		alloc_flags = reserve_flags;
 	return get_page_from_freelist(gfp_mask, oc->order, alloc_flags, oc->ac);
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
