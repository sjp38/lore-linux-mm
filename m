Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 0883012241
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:08:07 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 14 of 16] oom select should only take rss into account
Message-Id: <dbd70ffd95f34cd12f1f.1181332992@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:12 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332962 -7200
# Node ID dbd70ffd95f34cd12f1fd2f05a9cc0f9a50edb4a
# Parent  dfac333eb29032dab87dd2c46f71a22037a6dc4a
oom select should only take rss into account

Running workloads where many tasks grow their virtual memory
simultaneously, so they all have a relatively small virtual memory when
oom triggers (if compared to innocent longstanding tasks), the oom
killer then selects mysql/apache and other things with very large VM but
very small RSS. RSS is the only thing that matters, killing a task with
huge VM but zero RSS is not useful. Many apps tend to have large VM but
small RSS in the first place (regardless of swapping activity) and they
shouldn't be penalized like this.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -66,7 +66,7 @@ unsigned long badness(struct task_struct
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = mm->total_vm;
+	points = get_mm_rss(mm);
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -90,7 +90,7 @@ unsigned long badness(struct task_struct
 	list_for_each_entry(child, &p->children, sibling) {
 		task_lock(child);
 		if (child->mm != mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
+			points += get_mm_rss(child->mm)/2 + 1;
 		task_unlock(child);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
