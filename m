Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6F05F6B0071
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:39 -0400 (EDT)
Received: by wizk4 with SMTP id k4so111780119wiz.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dm9si34634422wjb.138.2015.04.27.12.06.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:32 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/9] mm: oom_kill: generalize OOM progress waitqueue
Date: Mon, 27 Apr 2015 15:05:50 -0400
Message-Id: <1430161555-6058-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It turns out that the mechanism to wait for exiting OOM victims is
less generic than it looks: it won't issue wakeups unless the OOM
killer is disabled.

The reason this check was added was the thought that, since only the
OOM disabling code would wait on this queue, wakeup operations could
be saved when that specific consumer is known to be absent.

However, this is quite the handgrenade.  Later attempts to reuse the
waitqueue for other purposes will lead to completely unexpected bugs
and the failure mode will appear seemingly illogical.  Generally,
providers shouldn't make unnecessary assumptions about consumers.

This could have been replaced with waitqueue_active(), but it only
saves a few instructions in one of the coldest paths in the kernel.
Simply remove it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4b9547b..472f124 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -438,11 +438,7 @@ void exit_oom_victim(void)
 	clear_thread_flag(TIF_MEMDIE);
 
 	down_read(&oom_sem);
-	/*
-	 * There is no need to signal the lasst oom_victim if there
-	 * is nobody who cares.
-	 */
-	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
+	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
 	up_read(&oom_sem);
 }
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
