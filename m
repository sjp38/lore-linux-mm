Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E51098D0004
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 01:52:56 -0400 (EDT)
Received: by wwe15 with SMTP id 15so823339wwe.2
        for <linux-mm@kvack.org>; Wed, 27 Oct 2010 22:52:54 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 28 Oct 2010 13:52:54 +0800
Message-ID: <AANLkTi=f2AQBMOU4jn=jrYB1Z5rOE9va_eR7KoFSGNPL@mail.gmail.com>
Subject: [PATCH] mm: add rcu read lock to protect pid structure
From: Zeng Zhaoming <zengzm.kernel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
@@ -1307,15 +1307,18 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid,
unsigned long, maxnode,
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
