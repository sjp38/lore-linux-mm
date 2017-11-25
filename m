Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD426B0033
	for <linux-mm@kvack.org>; Sat, 25 Nov 2017 06:37:02 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x202so24636349pgx.1
        for <linux-mm@kvack.org>; Sat, 25 Nov 2017 03:37:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v3si2043247plb.385.2017.11.25.03.37.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 25 Nov 2017 03:37:01 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/3] mm,oom: Use ALLOC_OOM for OOM victim's last second allocation.
Date: Sat, 25 Nov 2017 19:52:48 +0900
Message-Id: <1511607169-5084-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511607169-5084-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
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
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7fa95ea..dbaff7f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4154,13 +4154,19 @@ struct page *alloc_pages_before_oomkill(const struct oom_control *oc)
 	 * we're still under heavy pressure. But make sure that this reclaim
 	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
 	 * allocation which will never fail due to oom_lock already held.
+	 * Also, make sure that OOM victims can try ALLOC_OOM watermark
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
