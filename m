Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 057FE6B0260
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:08:17 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id c123so14045040pga.17
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:08:16 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a6si8549271plt.76.2017.11.15.06.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:08:15 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 05/16] sched: convert numa_group.refcount to refcount_t
Date: Wed, 15 Nov 2017 16:03:29 +0200
Message-Id: <1510754620-27088-6-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
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

**Important note for maintainers:

Some functions from refcount_t API defined in lib/refcount.c
have different memory ordering guarantees than their atomic
counterparts.
The full comparison can be seen in
https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
in state to be merged to the documentation tree.
Normally the differences should not matter since refcount_t provides
enough guarantees to satisfy the refcounting use cases, but in
some rare cases it might matter.
Please double check that you don't have some undocumented
memory guarantees for this variable usage.

For the numa_group.refcount it might make a difference
in following places:
 - get_numa_group(): increment in refcount_inc_not_zero() only
   guarantees control dependency on success vs. fully ordered
   atomic counterpart
 - put_numa_group(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 kernel/sched/fair.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 4037e19..b456b94 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1052,7 +1052,7 @@ unsigned int sysctl_numa_balancing_scan_size = 256;
 unsigned int sysctl_numa_balancing_scan_delay = 1000;
 
 struct numa_group {
-	atomic_t refcount;
+	refcount_t refcount;
 
 	spinlock_t lock; /* nr_tasks, tasks */
 	int nr_tasks;
@@ -1121,7 +1121,7 @@ static unsigned int task_scan_start(struct task_struct *p)
 		unsigned long shared = group_faults_shared(ng);
 		unsigned long private = group_faults_priv(ng);
 
-		period *= atomic_read(&ng->refcount);
+		period *= refcount_read(&ng->refcount);
 		period *= shared + 1;
 		period /= private + shared + 1;
 	}
@@ -1144,7 +1144,7 @@ static unsigned int task_scan_max(struct task_struct *p)
 		unsigned long private = group_faults_priv(ng);
 		unsigned long period = smax;
 
-		period *= atomic_read(&ng->refcount);
+		period *= refcount_read(&ng->refcount);
 		period *= shared + 1;
 		period /= private + shared + 1;
 
@@ -2229,12 +2229,12 @@ static void task_numa_placement(struct task_struct *p)
 
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
 
@@ -2255,7 +2255,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
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
