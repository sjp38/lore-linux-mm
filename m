Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C603F6B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 09:47:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y22so2332191wmh.11
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 06:47:13 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w11si19822559wmw.152.2017.04.04.06.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 06:47:12 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id x75so6062875wma.1
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 06:47:11 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] oom: improve oom disable handling
Date: Tue,  4 Apr 2017 15:47:05 +0200
Message-Id: <20170404134705.6361-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has reported that sysrq triggered OOM killer will print a
misleading information when no tasks are selected:

[  713.805315] sysrq: SysRq : Manual OOM execution
[  713.808920] Out of memory: Kill process 4468 ((agetty)) score 0 or sacrifice child
[  713.814913] Killed process 4468 ((agetty)) total-vm:43704kB, anon-rss:1760kB, file-rss:0kB, shmem-rss:0kB
[  714.004805] sysrq: SysRq : Manual OOM execution
[  714.005936] Out of memory: Kill process 4469 (systemd-cgroups) score 0 or sacrifice child
[  714.008117] Killed process 4469 (systemd-cgroups) total-vm:10704kB, anon-rss:120kB, file-rss:0kB, shmem-rss:0kB
[  714.189310] sysrq: SysRq : Manual OOM execution
[  714.193425] sysrq: OOM request ignored because killer is disabled
[  714.381313] sysrq: SysRq : Manual OOM execution
[  714.385158] sysrq: OOM request ignored because killer is disabled
[  714.573320] sysrq: SysRq : Manual OOM execution
[  714.576988] sysrq: OOM request ignored because killer is disabled

The real reason is that there are no eligible tasks for the OOM killer
to select but since 7c5f64f84483bd13 ("mm: oom: deduplicate victim
selection code for memcg and global oom") the semantic of out_of_memory
has changed without updating moom_callback.

This patch updates moom_callback to tell that no task was eligible
which is the case for both oom killer disabled and no eligible tasks.
In order to help distinguish first case from the second add printk to
both oom_killer_{enable,disable}. This information is useful on its own
because it might help debugging potential memory allocation failures.

Fixes: 7c5f64f84483bd13 ("mm: oom: deduplicate victim selection code for memcg and global oom")
Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/tty/sysrq.c | 2 +-
 mm/oom_kill.c       | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 71136742e606..a91f58dc2cb6 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -370,7 +370,7 @@ static void moom_callback(struct work_struct *ignored)
 
 	mutex_lock(&oom_lock);
 	if (!out_of_memory(&oc))
-		pr_info("OOM request ignored because killer is disabled\n");
+		pr_info("OOM request ignored. No task eligible\n");
 	mutex_unlock(&oom_lock);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 51c091849dcb..ad2b112cdf3e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -682,6 +682,7 @@ void exit_oom_victim(void)
 void oom_killer_enable(void)
 {
 	oom_killer_disabled = false;
+	pr_info("OOM killer enabled.\n");
 }
 
 /**
@@ -718,6 +719,7 @@ bool oom_killer_disable(signed long timeout)
 		oom_killer_enable();
 		return false;
 	}
+	pr_info("OOM killer disabled.\n");
 
 	return true;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
