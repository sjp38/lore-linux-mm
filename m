Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD7A8D0004
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 02:33:20 -0400 (EDT)
From: <zeng.zhaoming@freescale.com>
Subject: [PATCH] mm: add rcu read lock to protect pid structure
Date: Thu, 28 Oct 2010 06:33:36 +0800
Message-ID: <1288218816-1800-1-git-send-email-zeng.zhaoming@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Zeng Zhaoming <zengzm.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Zeng Zhaoming <zengzm.kernel@gmail.com>

find_task_by_vpid should be protected by rcu_read_lock(),
to prevent free_pid() reclaiming pid.

Signed-off-by: Zeng Zhaoming <zengzm.kernel@gmail.com>
---
 mm/mempolicy.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 81a1276..ceaf0d8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1307,15 +1307,18 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 		goto out;
 
 	/* Find the mm_struct */
+	rcu_read_lock();
 	read_lock(&tasklist_lock);
 	task = pid ? find_task_by_vpid(pid) : current;
 	if (!task) {
 		read_unlock(&tasklist_lock);
+		rcu_read_unlock();
 		err = -ESRCH;
 		goto out;
 	}
 	mm = get_task_mm(task);
 	read_unlock(&tasklist_lock);
+	rcu_read_unlock();
 
 	err = -EINVAL;
 	if (!mm)
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
