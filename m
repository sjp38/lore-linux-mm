Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 612326B0070
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:17:36 -0400 (EDT)
Received: by wibg7 with SMTP id g7so66616329wib.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:17:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ew8si20784269wid.77.2015.03.24.23.17.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:17:35 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 03/12] mm: oom_kill: switch test-and-clear of known TIF_MEMDIE to clear
Date: Wed, 25 Mar 2015 02:17:07 -0400
Message-Id: <1427264236-17249-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

exit_oom_victim() already knows that TIF_MEMDIE is set, and nobody
else can clear it concurrently.  Use clear_thread_flag() directly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b2f081fe4b1a..4b9547be9170 100644
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
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
