Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E248E6B0072
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:41 -0400 (EDT)
Received: by widdi4 with SMTP id di4so2328695wid.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:41 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qs6si34658782wjc.68.2015.04.27.12.06.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:34 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 5/9] mm: oom_kill: remove unnecessary locking in exit_oom_victim()
Date: Mon, 27 Apr 2015 15:05:51 -0400
Message-Id: <1430161555-6058-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Disabling the OOM killer needs to exclude allocators from entering,
not existing victims from exiting.

Right now the only waiter is suspend code, which achieves quiescence
by disabling the OOM killer.  But later on we want to add waits that
hold the lock instead to stop new victims from showing up.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 472f124..d3490b0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -437,10 +437,8 @@ void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
 
-	down_read(&oom_sem);
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
-	up_read(&oom_sem);
 }
 
 /**
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
