Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3306B006C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:32 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so91250223wic.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fr8si14217180wib.3.2015.04.27.12.06.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:29 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/9] mm: oom_kill: remove unnecessary locking in oom_enable()
Date: Mon, 27 Apr 2015 15:05:47 -0400
Message-Id: <1430161555-6058-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Setting oom_killer_disabled to false is atomic, there is no need for
further synchronization with ongoing allocations trying to OOM-kill.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2b665da..73763e4 100644
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
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
