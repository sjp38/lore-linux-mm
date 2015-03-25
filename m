Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id B298C6B0072
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:17:39 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so10610403wib.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:17:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gs6si20773419wib.101.2015.03.24.23.17.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:17:38 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 05/12] mm: oom_kill: generalize OOM progress waitqueue
Date: Wed, 25 Mar 2015 02:17:09 -0400
Message-Id: <1427264236-17249-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

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
---
 mm/oom_kill.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 88aa9ba40fa5..d3490b019d46 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -437,11 +437,7 @@ void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
 
-	/*
-	 * There is no need to signal the lasst oom_victim if there
-	 * is nobody who cares.
-	 */
-	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
+	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
 }
 
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
