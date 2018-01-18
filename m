Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B807D6B0260
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:49:08 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u16so18411082pfh.7
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 08:49:08 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0055.outbound.protection.outlook.com. [104.47.37.55])
        by mx.google.com with ESMTPS id u3si6993558pfh.248.2018.01.18.08.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 08:49:07 -0800 (PST)
From: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Subject: [PATCH 2/4] oom: take per file badness into account
Date: Thu, 18 Jan 2018 11:47:50 -0500
Message-ID: <1516294072-17841-3-git-send-email-andrey.grodzovsky@amd.com>
In-Reply-To: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Cc: Christian.Koenig@amd.com, Andrey Grodzovsky <andrey.grodzovsky@amd.com>

Try to make better decisions which process to kill based on
per file OOM badness

Signed-off-by: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
---
 mm/oom_kill.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 29f8555..825ed52 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -49,6 +49,8 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
 
+#include <linux/fdtable.h>
+
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
@@ -182,6 +184,21 @@ static bool is_dump_unreclaim_slabs(void)
 }
 
 /**
+ * oom_file_badness - add per file badness
+ * @points: pointer to summed up badness points
+ * @file: tasks open file
+ * @n: file descriptor id (unused)
+ */
+static int oom_file_badness(const void *points, struct file *file, unsigned n)
+{
+	if (file->f_op->oom_file_badness)
+		*((long *)points) += file->f_op->oom_file_badness(file);
+
+	return 0;
+}
+
+
+/**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
  * @totalpages: total present RAM allowed for page allocation
@@ -222,6 +239,12 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 */
 	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
 		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+
+	/*
+	 * Add how much memory a task uses in opened files, e.g. device drivers.
+	 */
+	iterate_fd(p->files, 0, oom_file_badness, &points);
+
 	task_unlock(p);
 
 	/*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
