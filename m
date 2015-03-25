Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDF06B0071
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:17:38 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so23324120wib.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:17:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p9si3288473wia.22.2015.03.24.23.17.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:17:36 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 04/12] mm: oom_kill: remove unnecessary locking in exit_oom_victim()
Date: Wed, 25 Mar 2015 02:17:08 -0400
Message-Id: <1427264236-17249-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

Disabling the OOM killer needs to exclude allocators from entering,
not existing victims from exiting.

Right now the only waiter is suspend code, which achieves quiescence
by disabling the OOM killer.  But later on we want to add waits that
hold the lock instead to stop new victims from showing up.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4b9547be9170..88aa9ba40fa5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -437,14 +437,12 @@ void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
 
-	down_read(&oom_sem);
 	/*
 	 * There is no need to signal the lasst oom_victim if there
 	 * is nobody who cares.
 	 */
 	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
 		wake_up_all(&oom_victims_wait);
-	up_read(&oom_sem);
 }
 
 /**
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
