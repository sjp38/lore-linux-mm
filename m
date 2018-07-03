Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 721AD6B026F
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:26:40 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k13-v6so347905ite.5
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:26:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b1-v6si810680ioh.138.2018.07.03.07.26.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:26:39 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 4/8] mm,page_alloc: Make oom_reserves_allowed() even.
Date: Tue,  3 Jul 2018 23:25:05 +0900
Message-Id: <1530627910-3415-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

Since CONFIG_MMU=n kernels no longer waits for OOM victims forever,
there is no possibiligty of OOM lockup. Therefore, we can get rid of
special handling of oom_reserves_allowed().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/page_alloc.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6205d34..b915533 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3862,21 +3862,6 @@ static void wake_all_kswapds(unsigned int order, gfp_t gfp_mask,
 	return alloc_flags;
 }
 
-static bool oom_reserves_allowed(struct task_struct *tsk)
-{
-	if (!tsk_is_oom_victim(tsk))
-		return false;
-
-	/*
-	 * !MMU doesn't have oom reaper so give access to memory reserves
-	 * only to the thread with TIF_MEMDIE set
-	 */
-	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
-		return false;
-
-	return true;
-}
-
 /*
  * Distinguish requests which really need access to full memory
  * reserves from oom victims which can live with a portion of it
@@ -3892,7 +3877,7 @@ static inline int __gfp_pfmemalloc_flags(gfp_t gfp_mask)
 	if (!in_interrupt()) {
 		if (current->flags & PF_MEMALLOC)
 			return ALLOC_NO_WATERMARKS;
-		else if (oom_reserves_allowed(current))
+		else if (tsk_is_oom_victim(current))
 			return ALLOC_OOM;
 	}
 
-- 
1.8.3.1
