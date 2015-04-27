Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 34B356B0070
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:37 -0400 (EDT)
Received: by wiun10 with SMTP id n10so2267719wiu.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:36 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g14si34674170wjz.39.2015.04.27.12.06.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:32 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/9] mm: oom_kill: switch test-and-clear of known TIF_MEMDIE to clear
Date: Mon, 27 Apr 2015 15:05:49 -0400
Message-Id: <1430161555-6058-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

exit_oom_victim() already knows that TIF_MEMDIE is set, and nobody
else can clear it concurrently.  Use clear_thread_flag() directly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b2f081f..4b9547b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -435,8 +435,7 @@ void mark_oom_victim(struct task_struct *tsk)
  */
 void exit_oom_victim(void)
 {
-	if (!test_and_clear_thread_flag(TIF_MEMDIE))
-		return;
+	clear_thread_flag(TIF_MEMDIE);
 
 	down_read(&oom_sem);
 	/*
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
