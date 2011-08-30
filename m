Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 65720900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 03:43:44 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p7U7havF006098
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:43:37 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by wpaz33.hot.corp.google.com with ESMTP id p7U7hYch006021
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:43:35 -0700
Received: by pzk6 with SMTP id 6so15261734pzk.36
        for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:43:34 -0700 (PDT)
Date: Tue, 30 Aug 2011 00:43:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] oom: fix race while temporarily setting current's
 oom_score_adj
In-Reply-To: <alpine.DEB.2.00.1108300040490.21066@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1108300041330.21066@chino.kir.corp.google.com>
References: <20110727163159.GA23785@redhat.com> <20110727163610.GJ23793@redhat.com> <20110727175624.GA3950@redhat.com> <20110728154324.GA22864@redhat.com> <alpine.DEB.2.00.1107281341060.16093@chino.kir.corp.google.com> <20110729141431.GA3501@redhat.com>
 <20110730143426.GA6061@redhat.com> <20110730152238.GA17424@redhat.com> <4E369372.80105@jp.fujitsu.com> <20110829183743.GA15216@redhat.com> <alpine.DEB.2.00.1108291611070.32495@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1108300040490.21066@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

test_set_oom_score_adj() was introduced in 72788c385604 (oom: replace
PF_OOM_ORIGIN with toggling oom_score_adj) to temporarily elevate
current's oom_score_adj for ksm and swapoff without requiring an
additional per-process flag.

Using that function to both set oom_score_adj to OOM_SCORE_ADJ_MAX and
then reinstate the previous value is racy since it's possible that
userspace can set the value to something else itself before the old value
is reinstated.  That results in userspace setting current's oom_score_adj
to a different value and then the kernel immediately setting it back to
its previous value without notification.

To fix this, a new compare_swap_oom_score_adj() function is introduced
with the same semantics as the compare and swap CAS instruction, or
CMPXCHG on x86.  It is used to reinstate the previous value of
oom_score_adj if and only if the present value is the same as the old
value.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    1 +
 mm/ksm.c            |    3 ++-
 mm/oom_kill.c       |   19 +++++++++++++++++++
 mm/swapfile.c       |    2 +-
 4 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -40,6 +40,7 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
+extern void compare_swap_oom_score_adj(int old_val, int new_val);
 extern int test_set_oom_score_adj(int new_val);
 
 extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
diff --git a/mm/ksm.c b/mm/ksm.c
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1905,7 +1905,8 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 
 			oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
 			err = unmerge_and_remove_all_rmap_items();
-			test_set_oom_score_adj(oom_score_adj);
+			compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX,
+								oom_score_adj);
 			if (err) {
 				ksm_run = KSM_RUN_STOP;
 				count = err;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -38,6 +38,25 @@ int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
+/*
+ * compare_swap_oom_score_adj() - compare and swap current's oom_score_adj
+ * @old_val: old oom_score_adj for compare
+ * @new_val: new oom_score_adj for swap
+ *
+ * Sets the oom_score_adj value for current to @new_val iff its present value is
+ * @old_val.  Usually used to reinstate a previous value to prevent racing with
+ * userspacing tuning the value in the interim.
+ */
+void compare_swap_oom_score_adj(int old_val, int new_val)
+{
+	struct sighand_struct *sighand = current->sighand;
+
+	spin_lock_irq(&sighand->siglock);
+	if (current->signal->oom_score_adj == old_val)
+		current->signal->oom_score_adj = new_val;
+	spin_unlock_irq(&sighand->siglock);
+}
+
 /**
  * test_set_oom_score_adj() - set current's oom_score_adj and return old value
  * @new_val: new oom_score_adj value
diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1617,7 +1617,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 
 	oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
 	err = try_to_unuse(type);
-	test_set_oom_score_adj(oom_score_adj);
+	compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX, oom_score_adj);
 
 	if (err) {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
