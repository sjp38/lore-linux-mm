Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE156B025F
	for <linux-mm@kvack.org>; Fri, 27 May 2016 10:08:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w143so168803512oiw.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:08:24 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0126.outbound.protection.outlook.com. [157.56.112.126])
        by mx.google.com with ESMTPS id t3si13260568oie.152.2016.05.27.07.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 May 2016 07:08:23 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: zap ZONE_OOM_LOCKED
Date: Fri, 27 May 2016 17:08:13 +0300
Message-ID: <1464358093-22663-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Not used since oom_lock was instroduced.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/mmzone.h | 1 -
 mm/oom_kill.c          | 4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 02069c23486d..3388ccbab7d6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -524,7 +524,6 @@ struct zone {
 
 enum zone_flags {
 	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
-	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
 	ZONE_CONGESTED,			/* zone has many dirty pages backed by
 					 * a congested BDI
 					 */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1685890d424e..b95c4c101b35 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -997,8 +997,8 @@ bool out_of_memory(struct oom_control *oc)
 
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
- * parallel oom killing is already in progress so do nothing.
+ * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
+ * killing is already in progress so do nothing.
  */
 void pagefault_out_of_memory(void)
 {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
