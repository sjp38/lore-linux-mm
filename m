Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2D3D26B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 19:46:43 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBI0kehN011115
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Dec 2009 09:46:40 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FA612AEAA1
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:46:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F188345DE4F
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:46:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB81F1DB803C
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:46:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 87DDF1DB8038
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:46:39 +0900 (JST)
Date: Fri, 18 Dec 2009 09:43:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC 2/4] add mm event counter
Message-Id: <20091218094336.cb479a36.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216101107.GA15031@basil.fritz.box>
	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216102806.GC15031@basil.fritz.box>
	<28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
	<20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Add version counter to mm_struct. It's updated when
write_lock is held and released. And this patch also adds
task->mm_version. By this, mm_semaphore can provides some
operation like seqlock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm_types.h |    1 +
 include/linux/sched.h    |    2 +-
 mm/mm_accessor.c         |   29 ++++++++++++++++++++++++++---
 3 files changed, 28 insertions(+), 4 deletions(-)

Index: mmotm-mm-accessor/include/linux/mm_types.h
===================================================================
--- mmotm-mm-accessor.orig/include/linux/mm_types.h
+++ mmotm-mm-accessor/include/linux/mm_types.h
@@ -216,6 +216,7 @@ struct mm_struct {
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
+	int version;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
Index: mmotm-mm-accessor/include/linux/sched.h
===================================================================
--- mmotm-mm-accessor.orig/include/linux/sched.h
+++ mmotm-mm-accessor/include/linux/sched.h
@@ -1276,7 +1276,7 @@ struct task_struct {
 	struct plist_node pushable_tasks;
 
 	struct mm_struct *mm, *active_mm;
-
+	int mm_version;
 /* task state */
 	int exit_state;
 	int exit_code, exit_signal;
Index: mmotm-mm-accessor/mm/mm_accessor.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mm_accessor.c
+++ mmotm-mm-accessor/mm/mm_accessor.c
@@ -1,15 +1,20 @@
-#include <linux/mm_types.h>
+#include <linux/sched.h>
 #include <linux/module.h>
 
 void mm_read_lock(struct mm_struct *mm)
 {
 	down_read(&mm->mmap_sem);
+	if (current->mm == mm && current->mm_version != mm->version)
+		current->mm_version = mm->version;
 }
 EXPORT_SYMBOL(mm_read_lock);
 
 int mm_read_trylock(struct mm_struct *mm)
 {
-	return down_read_trylock(&mm->mmap_sem);
+	int ret = down_read_trylock(&mm->mmap_sem);
+	if (ret && current->mm == mm && current->mm_version != mm->version)
+		current->mm_version = mm->version;
+	return ret;
 }
 EXPORT_SYMBOL(mm_read_trylock);
 
@@ -22,18 +27,24 @@ EXPORT_SYMBOL(mm_read_unlock);
 void mm_write_lock(struct mm_struct *mm)
 {
 	down_write(&mm->mmap_sem);
+	mm->version++;
 }
 EXPORT_SYMBOL(mm_write_lock);
 
 void mm_write_unlock(struct mm_struct *mm)
 {
+	mm->version++;
 	up_write(&mm->mmap_sem);
 }
 EXPORT_SYMBOL(mm_write_unlock);
 
 int mm_write_trylock(struct mm_struct *mm)
 {
-	return down_write_trylock(&mm->mmap_sem);
+	int ret = down_write_trylock(&mm->mmap_sem);
+
+	if (ret)
+		mm->version++;
+	return ret;
 }
 EXPORT_SYMBOL(mm_write_trylock);
 
@@ -45,6 +56,7 @@ EXPORT_SYMBOL(mm_is_locked);
 
 void mm_write_to_read_lock(struct mm_struct *mm)
 {
+	mm->version++;
 	downgrade_write(&mm->mmap_sem);
 }
 EXPORT_SYMBOL(mm_write_to_read_lock);
@@ -78,3 +90,14 @@ void mm_read_might_lock(struct mm_struct
 	might_lock_read(&mm->mmap_sem);
 }
 EXPORT_SYMBOL(mm_read_might_lock);
+
+/*
+ * Called when mm is accessed without read-lock or for chekcing
+ * per-thread cached value is stale or not.
+ */
+int mm_version_check(struct mm_struct *mm)
+{
+	if ((current->mm == mm) && (current->mm_version != mm->version))
+		return 0;
+	return 1;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
