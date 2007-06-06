Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id l56Ixs4p022002
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 11:59:55 -0700
Message-ID: <46670411.1060901@google.com>
Date: Wed, 06 Jun 2007 11:59:29 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [PATCH 1/1] oom: stop allocating user memory if TIF_MEMDIE is set
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

get_user_pages() can try to allocate a nearly unlimited amount of memory on behalf of a user process, even if that process has been OOM killed. The OOM kill occurs upon return to user space via a SIGKILL, but get_user_pages() will try allocate all its memory before returning. Change get_user_pages() to check for TIF_MEMDIE, and if set then return immediately.

Signed-off-by: Ethan Solomita <solo@google.com>
---
diff -uprN -X orig/Documentation/dontdiff orig/mm/memory.c new/mm/memory.c
--- orig/mm/memory.c	2007-06-05 19:01:46.000000000 -0700
+++ new/mm/memory.c	2007-06-05 19:07:15.000000000 -0700
@@ -1084,6 +1084,15 @@ int get_user_pages(struct task_struct *t
 		do {
 			struct page *page;
 
+			/*
+			 * If tsk is ooming, cut off its access to large memory
+			 * allocations. It has a pending SIGKILL, but it can't
+			 * be processed until returning to user space.
+			 */
+
+			if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
+				return -ENOMEM;
+
 			if (write)
 				foll_flags |= FOLL_WRITE;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
