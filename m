Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 00C3F6B006C
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:17:33 -0400 (EDT)
Received: by wixw10 with SMTP id w10so23428518wix.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:17:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gx6si3264076wib.50.2015.03.24.23.17.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:17:31 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 01/12] mm: oom_kill: remove unnecessary locking in oom_enable()
Date: Wed, 25 Mar 2015 02:17:05 -0400
Message-Id: <1427264236-17249-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

Setting oom_killer_disabled to false is atomic, there is no need for
further synchronization with ongoing allocations trying to OOM-kill.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2b665da1b3c9..73763e489e86 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -488,9 +488,7 @@ bool oom_killer_disable(void)
  */
 void oom_killer_enable(void)
 {
-	down_write(&oom_sem);
 	oom_killer_disabled = false;
-	up_write(&oom_sem);
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
