Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0BA6B0038
	for <linux-mm@kvack.org>; Sun, 29 Nov 2015 21:54:24 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so174046995pab.0
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 18:54:23 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id r72si26087140pfi.0.2015.11.29.18.54.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 29 Nov 2015 18:54:23 -0800 (PST)
From: <chenjie6@huawei.com>
Subject: [PATCH] bugfix oom kill init lead panic
Date: Mon, 30 Nov 2015 18:54:29 +0800
Message-ID: <1448880869-20506-1-git-send-email-chenjie6@huawei.com>
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
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4d87d7c..de77cbc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -513,7 +513,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	rcu_read_lock();
 	for_each_process(p)
 		if (p->mm == mm && !same_thread_group(p, victim) &&
-		    !(p->flags & PF_KTHREAD)) {
+		    !(p->flags & PF_KTHREAD) && !is_global_init(p)) {
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
