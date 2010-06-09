Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 658D66B01D9
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 23:59:27 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o593xP9S003524
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:25 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by wpaz29.hot.corp.google.com with ESMTP id o593xLim012397
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:24 -0700
Received: by pwi6 with SMTP id 6so5228887pwi.0
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 20:59:24 -0700 (PDT)
Date: Tue, 8 Jun 2010 20:59:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 4/6] oom: introduce find_lock_task_mm to fix mm false
 positives fix
In-Reply-To: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082058120.6219@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

find_lock_task_mm() should be documented so that we clearly understand
what it does and why we need it.

At the same time, remove a stale coment about dereferencing of a local
variable "mm" in badness() which no longer exists and was removed when
find_lock_task_mm() was added.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -81,6 +81,12 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
 }
 #endif /* CONFIG_NUMA */
 
+/*
+ * The process p may have detached its own ->mm while exiting or through
+ * use_mm(), but one or more of its subthreads may still have a valid
+ * pointer.  Return p, or any of its subthreads with a valid ->mm, with
+ * task_lock() held.
+ */
 static struct task_struct *find_lock_task_mm(struct task_struct *p)
 {
 	struct task_struct *t = p;
@@ -135,10 +141,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	 * The memory size of the process is the basis for the badness.
 	 */
 	points = p->mm->total_vm;
-
-	/*
-	 * After this unlock we can no longer dereference local variable `mm'
-	 */
 	task_unlock(p);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
