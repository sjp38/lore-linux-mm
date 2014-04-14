Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B57E26B0037
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 19:57:30 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so8722905pdj.9
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 16:57:30 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id py5si3626595pbc.400.2014.04.14.16.57.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 16:57:29 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 3/3] mm,vmacache: optimize overflow system-wide flushing
Date: Mon, 14 Apr 2014 16:57:21 -0700
Message-Id: <1397519841-24847-4-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397519841-24847-1-git-send-email-davidlohr@hp.com>
References: <1397519841-24847-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, davidlohr@hp.com, aswin@hp.com

For single threaded workloads, we can avoid flushing
and iterating through the entire list of tasks, making
the whole function a lot faster, requiring only a single
atomic read for the mm_users.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/vmacache.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/vmacache.c b/mm/vmacache.c
index e167da2..61c38ae 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -17,6 +17,16 @@ void vmacache_flush_all(struct mm_struct *mm)
 {
 	struct task_struct *g, *p;
 
+	/*
+	 * Single threaded tasks need not iterate the entire
+	 * list of process. We can avoid the flushing as well
+	 * since the mm's seqnum was increased and don't have
+	 * to worry about other threads' seqnum. Current's
+	 * flush will occur upon the next lookup.
+	 */
+	if (atomic_read(&mm->mm_users) == 1)
+		return;
+
 	rcu_read_lock();
 	for_each_process_thread(g, p) {
 		/*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
