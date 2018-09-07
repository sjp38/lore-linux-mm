Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 505876B7DDB
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 07:24:05 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b8-v6so16684724oib.4
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 04:24:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d82-v6si5660161oic.195.2018.09.07.04.24.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 04:24:04 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] syzbot: Dump all threads upon OOM.
Date: Fri,  7 Sep 2018 20:23:43 +0900
Message-Id: <1536319423-9344-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>

syzbot is getting stalls with linux-next kernels because dump_tasks() from
out_of_memory() is printing 6600 tasks. Most of these tasks are syzbot
processes but syzbot is supposed not to create so many processes.
Therefore, let's start from checking what these tasks are doing.
This change will be removed after the bug is fixed.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/oom_kill.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..867fd6a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -41,6 +41,7 @@
 #include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
+#include <linux/sched/debug.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -446,6 +447,10 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 		if (is_dump_unreclaim_slabs())
 			dump_unreclaimable_slab();
 	}
+#ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
+	show_state();
+	panic("Out of memory");
+#endif
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(oc->memcg, oc->nodemask);
 }
-- 
1.8.3.1
