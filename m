Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2A17A6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 01:32:43 -0500 (EST)
Received: by padhx2 with SMTP id hx2so31052482pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 22:32:42 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ch2si2521518pad.150.2015.12.01.22.32.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Dec 2015 22:32:42 -0800 (PST)
From: <chenjie6@huawei.com>
Subject: [PATCH] oom kill init lead panic
Date: Wed, 2 Dec 2015 14:30:56 +0800
Message-ID: <1449037856-23990-1-git-send-email-chenjie6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com
Cc: chenjie6@huawei.com, lizefan@huawei.com, akpm@linux-foundation.org, stable@vger.kernel.org

From: chenjie <chenjie6@huawei.com>

when oom happened we can see:
Out of memory: Kill process 9134 (init) score 3 or sacrifice child
Killed process 9134 (init) total-vm:1868kB, anon-rss:84kB, file-rss:572kB
Kill process 1 (init) sharing same memory
...
Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009

That's because:
        the busybox init will vfork a process,oom_kill_process found
the init not the children,their mm is the same when vfork.

Cc: <stable@vger.kernel.org>
Signed-off-by: Chen Jie <chenjie6@huawei.com>

---
 mm/oom_kill.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d13a339..a0ddebd 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -608,6 +608,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
+		if (!is_global_init(p))
+			continue;
 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 			continue;
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
