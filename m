Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96DDF6B007E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 07:00:41 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 85so26719851ioq.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 04:00:41 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0144.outbound.protection.outlook.com. [157.56.112.144])
        by mx.google.com with ESMTPS id v22si1552947oif.117.2016.05.24.04.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 04:00:36 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: oom: do not reap task if there are live threads in threadgroup
Date: Tue, 24 May 2016 14:00:28 +0300
Message-ID: <1464087628-7318-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If the current process is exiting, we don't invoke oom killer, instead
we give it access to memory reserves and try to reap its mm in case
nobody is going to use it. There's a mistake in the code performing this
check - we just ignore any process of the same thread group no matter if
it is exiting or not - see try_oom_reaper. Fix it.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/oom_kill.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c0e37dd1422f..03bf7a472296 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -618,8 +618,6 @@ void try_oom_reaper(struct task_struct *tsk)
 
 			if (!process_shares_mm(p, mm))
 				continue;
-			if (same_thread_group(p, tsk))
-				continue;
 			if (fatal_signal_pending(p))
 				continue;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
