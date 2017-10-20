Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9DF06B026D
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z80so10042359pff.11
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e1si544394pln.687.2017.10.20.05.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:17 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 04/15] sched: convert numa_group.refcount to refcount_t
Date: Fri, 20 Oct 2017 15:15:46 +0300
Message-Id: <1508501757-15784-5-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable numa_group.refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 kernel/sched/fair.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 27a2241..b4f0eb2 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1050,7 +1050,7 @@ unsigned int sysctl_numa_balancing_scan_size = 256;
 unsigned int sysctl_numa_balancing_scan_delay = 1000;
 
 struct numa_group {
-	atomic_t refcount;
+	refcount_t refcount;
 
 	spinlock_t lock; /* nr_tasks, tasks */
 	int nr_tasks;
@@ -1119,7 +1119,7 @@ static unsigned int task_scan_start(struct task_struct *p)
 		unsigned long shared = group_faults_shared(ng);
 		unsigned long private = group_faults_priv(ng);
 
-		period *= atomic_read(&ng->refcount);
+		period *= refcount_read(&ng->refcount);
 		period *= shared + 1;
 		period /= private + shared + 1;
 	}
@@ -1142,7 +1142,7 @@ static unsigned int task_scan_max(struct task_struct *p)
 		unsigned long private = group_faults_priv(ng);
 		unsigned long period = smax;
 
-		period *= atomic_read(&ng->refcount);
+		period *= refcount_read(&ng->refcount);
 		period *= shared + 1;
 		period /= private + shared + 1;
 
@@ -2227,12 +2227,12 @@ static void task_numa_placement(struct task_struct *p)
 
 static inline int get_numa_group(struct numa_group *grp)
 {
-	return atomic_inc_not_zero(&grp->refcount);
+	return refcount_inc_not_zero(&grp->refcount);
 }
 
 static inline void put_numa_group(struct numa_group *grp)
 {
-	if (atomic_dec_and_test(&grp->refcount))
+	if (refcount_dec_and_test(&grp->refcount))
 		kfree_rcu(grp, rcu);
 }
 
@@ -2253,7 +2253,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
 		if (!grp)
 			return;
 
-		atomic_set(&grp->refcount, 1);
+		refcount_set(&grp->refcount, 1);
 		grp->active_nodes = 1;
 		grp->max_faults_cpu = 0;
 		spin_lock_init(&grp->lock);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
