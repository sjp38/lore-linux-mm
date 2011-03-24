Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4FE8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 05:34:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4BE833EE0BD
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:34:40 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A54845DE62
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:34:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBB9145DE5F
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:34:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5621E08003
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:34:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A929E18004
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:34:39 +0900 (JST)
Date: Thu, 24 Mar 2011 18:28:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/5] forkbomb : mm histroy scanning and locks
Message-Id: <20110324182812.df71e831.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>

This patch adds a code for scanning mm_history tree. Later, we need
to scan all mm_histroy from children->parent direction.

And this patch adds a global lock which will be required for scanning.
Because scanning isn't called frequently, using rwsem with a help of
percpu variable.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/oom_kill.c |  116 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 116 insertions(+)

Index: mm-work2/mm/oom_kill.c
===================================================================
--- mm-work2.orig/mm/oom_kill.c
+++ mm-work2/mm/oom_kill.c
@@ -31,6 +31,7 @@
 #include <linux/memcontrol.h>
 #include <linux/mempolicy.h>
 #include <linux/security.h>
+#include <linux/cpu.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
@@ -764,6 +765,58 @@ void pagefault_out_of_memory(void)
 
 #ifdef CONFIG_FORKBOMB_KILLER
 
+static DEFINE_PER_CPU(unsigned long, pcpu_history_lock);
+static DECLARE_RWSEM(hist_rwsem);
+static int need_global_history_lock;
+
+static void update_history_lock(void)
+{
+retry:
+	preempt_disable();
+	this_cpu_inc(pcpu_history_lock);
+	smp_rmb();
+	if (need_global_history_lock) {
+		this_cpu_dec(pcpu_history_lock);
+		preempt_enable();
+		down_read(&hist_rwsem);
+		up_read(&hist_rwsem);
+		goto retry;
+	}
+}
+
+static void update_history_unlock(void)
+{
+	this_cpu_dec(pcpu_history_lock);
+	preempt_enable();
+}
+
+static void scan_history_lock(void)
+{
+	int cpu;
+	bool loop;
+
+	down_write(&hist_rwsem);
+	need_global_history_lock++;
+	do {
+		loop = false;
+		get_online_cpus();
+		for_each_online_cpu(cpu)
+			if (per_cpu(pcpu_history_lock, cpu)) {
+				loop = true;
+				break;
+			}
+		put_online_cpus();
+		cpu_relax();
+	} while (loop);
+}
+
+static void scan_history_unlock(void)
+{
+	need_global_history_lock--;
+	up_write(&hist_rwsem);
+}
+
+
 struct mm_history {
 	spinlock_t	lock;
 	struct mm_struct *mm;
@@ -791,6 +844,7 @@ void track_mm_history(struct mm_struct *
 	hist = kmalloc(sizeof(*hist), GFP_KERNEL);
 	if (!hist)
 		return;
+	update_history_lock();
 	spin_lock_init(&hist->lock);
 	INIT_LIST_HEAD(&hist->children);
 	hist->mm = new;
@@ -806,6 +860,7 @@ void track_mm_history(struct mm_struct *
 	spin_lock(&phist->lock);
 	list_add_tail(&hist->siblings, &phist->children);
 	spin_unlock(&phist->lock);
+	update_history_unlock();
 	return;
 }
 
@@ -816,6 +871,7 @@ void delete_mm_history(struct mm_struct 
 
 	if (!mm->history)
 		return;
+	update_history_lock();
 	hist = mm->history;
 	spin_lock(&hist->lock);
 	nochild = list_empty(&hist->children);
@@ -833,6 +889,66 @@ void delete_mm_history(struct mm_struct 
 		kfree(hist);
 		hist = phist;
 	}
+	update_history_unlock();
 }
 
+/* Because we have global scan lock, we need no lock at scaning. */
+static struct mm_history* __first_child(struct mm_history *p)
+{
+	if (list_empty(&p->children))
+		return NULL;
+	return list_first_entry(&p->children, struct mm_history, siblings);
+}
+
+static struct mm_history* __next_sibling(struct mm_history *p)
+{
+	if (p->siblings.next == &p->parent->children)
+		return NULL;
+	return list_first_entry(&p->siblings, struct mm_history, siblings);
+}
+
+static struct mm_history *first_deepest_child(struct mm_history *p)
+{
+	struct mm_history *tmp;
+
+	do {
+		tmp = __first_child(p);
+		if (!tmp)
+			return p;
+		p = tmp;
+	} while (1);
+}
+
+static struct mm_history *mm_history_scan_start(struct mm_history *hist)
+{
+	return first_deepest_child(hist);
+}
+
+static struct mm_history *mm_history_scan_next(struct mm_history *pos)
+{
+	struct mm_history *tmp;
+
+	tmp = __next_sibling(pos);
+	if (!tmp)
+		return pos->parent;
+	pos = tmp;
+	pos = first_deepest_child(pos);
+	return pos;
+}
+
+#define for_each_mm_history_under(pos, root)\
+	for (pos = mm_history_scan_start(root);\
+		pos != root;\
+		pos = mm_history_scan_next(pos))
+
+#define for_each_mm_history_safe_under(pos, root, tmp)\
+	for (pos =  mm_history_scan_start(root),\
+		tmp = mm_history_scan_next(pos);\
+		pos != root;\
+		pos = tmp, tmp = mm_history_scan_next(pos))
+
+#define for_each_mm_history(pos) for_each_mm_history_under((pos), &init_hist)
+#define for_each_mm_history_safe(pos, tmp)\
+	for_each_mm_history_safe_under((pos), &init_hist, (tmp))
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
