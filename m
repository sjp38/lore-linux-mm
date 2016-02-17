Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B9A936B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 09:31:40 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id yy13so12174370pab.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:31:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y64si2323158pfi.87.2016.02.17.06.31.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 06:31:39 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are OOM-unkillable.
Date: Wed, 17 Feb 2016 23:31:00 +0900
Message-Id: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

oom_scan_process_thread() returns OOM_SCAN_SELECT when there is a
thread which returns oom_task_origin() == true. But it is possible
that such thread is marked as OOM-unkillable. In that case, the OOM
killer must not select such process.

Since it is meaningless to return OOM_SCAN_OK for OOM-unkillable
process because subsequent oom_badness() call will return 0, this
patch changes oom_scan_process_thread to return OOM_SCAN_CONTINUE
if that process is marked as OOM-unkillable (regardless of
oom_task_origin()).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Suggested-by: Michal Hocko <mhocko@kernel.org>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7653055..cf87153 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -282,7 +282,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 		if (!is_sysrq_oom(oc))
 			return OOM_SCAN_ABORT;
 	}
-	if (!task->mm)
+	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 		return OOM_SCAN_CONTINUE;
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
