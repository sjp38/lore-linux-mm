Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C420D8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 18:29:48 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 90-v6so4980158pla.18
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 15:29:48 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t9-v6si23641437pgo.68.2018.09.20.15.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 15:29:47 -0700 (PDT)
Subject: [PATCH v4 4/5] async: Add support for queueing on specific node
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Thu, 20 Sep 2018 15:29:45 -0700
Message-ID: <20180920222938.19464.34102.stgit@localhost.localdomain>
In-Reply-To: <20180920215824.19464.8884.stgit@localhost.localdomain>
References: <20180920215824.19464.8884.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, mingo@kernel.org, dave.hansen@intel.com, jglisse@redhat.com, akpm@linux-foundation.org, logang@deltatee.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com

This patch introduces two new variants of the async_schedule_ functions
that allow scheduling on a specific node. These functions are
async_schedule_on and async_schedule_on_domain which end up mapping to
async_schedule and async_schedule_domain but provide NUMA node specific
functionality. The original functions were moved to inline function
definitions that call the new functions while passing NUMA_NO_NODE.

The main motivation behind this is to address the need to be able to
schedule NVDIMM init work on specific NUMA nodes in order to improve
performance of memory initialization.

One additional change I made is I dropped the "extern" from the function
prototypes in the async.h kernel header since they aren't needed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/async.h |   20 +++++++++++++++++---
 kernel/async.c        |   36 +++++++++++++++++++++++++-----------
 2 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/include/linux/async.h b/include/linux/async.h
index 6b0226bdaadc..9878b99cbb01 100644
--- a/include/linux/async.h
+++ b/include/linux/async.h
@@ -14,6 +14,7 @@
 
 #include <linux/types.h>
 #include <linux/list.h>
+#include <linux/numa.h>
 
 typedef u64 async_cookie_t;
 typedef void (*async_func_t) (void *data, async_cookie_t cookie);
@@ -37,9 +38,22 @@ struct async_domain {
 	struct async_domain _name = { .pending = LIST_HEAD_INIT(_name.pending), \
 				      .registered = 0 }
 
-extern async_cookie_t async_schedule(async_func_t func, void *data);
-extern async_cookie_t async_schedule_domain(async_func_t func, void *data,
-					    struct async_domain *domain);
+async_cookie_t async_schedule_on(async_func_t func, void *data, int node);
+async_cookie_t async_schedule_on_domain(async_func_t func, void *data, int node,
+					struct async_domain *domain);
+
+static inline async_cookie_t async_schedule(async_func_t func, void *data)
+{
+	return async_schedule_on(func, data, NUMA_NO_NODE);
+}
+
+static inline async_cookie_t
+async_schedule_domain(async_func_t func, void *data,
+		      struct async_domain *domain)
+{
+	return async_schedule_on_domain(func, data, NUMA_NO_NODE, domain);
+}
+
 void async_unregister_domain(struct async_domain *domain);
 extern void async_synchronize_full(void);
 extern void async_synchronize_full_domain(struct async_domain *domain);
diff --git a/kernel/async.c b/kernel/async.c
index a893d6170944..1d7ce81c1949 100644
--- a/kernel/async.c
+++ b/kernel/async.c
@@ -56,6 +56,7 @@ synchronization with the async_synchronize_full() function, before returning
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/workqueue.h>
+#include <linux/cpu.h>
 
 #include "workqueue_internal.h"
 
@@ -149,8 +150,11 @@ static void async_run_entry_fn(struct work_struct *work)
 	wake_up(&async_done);
 }
 
-static async_cookie_t __async_schedule(async_func_t func, void *data, struct async_domain *domain)
+static async_cookie_t __async_schedule(async_func_t func, void *data,
+				       struct async_domain *domain,
+				       int node)
 {
+	int cpu = WORK_CPU_UNBOUND;
 	struct async_entry *entry;
 	unsigned long flags;
 	async_cookie_t newcookie;
@@ -194,30 +198,40 @@ static async_cookie_t __async_schedule(async_func_t func, void *data, struct asy
 	/* mark that this task has queued an async job, used by module init */
 	current->flags |= PF_USED_ASYNC;
 
+	/* guarantee cpu_online_mask doesn't change during scheduling */
+	get_online_cpus();
+
+	if (node >= 0 && node < MAX_NUMNODES && node_online(node))
+		cpu = cpumask_any_and(cpumask_of_node(node), cpu_online_mask);
+
 	/* schedule for execution */
-	queue_work(system_unbound_wq, &entry->work);
+	queue_work_on(cpu, system_unbound_wq, &entry->work);
+
+	put_online_cpus();
 
 	return newcookie;
 }
 
 /**
- * async_schedule - schedule a function for asynchronous execution
+ * async_schedule_on - schedule a function for asynchronous execution
  * @func: function to execute asynchronously
  * @data: data pointer to pass to the function
+ * @node: NUMA node to complete the work on
  *
  * Returns an async_cookie_t that may be used for checkpointing later.
  * Note: This function may be called from atomic or non-atomic contexts.
  */
-async_cookie_t async_schedule(async_func_t func, void *data)
+async_cookie_t async_schedule_on(async_func_t func, void *data, int node)
 {
-	return __async_schedule(func, data, &async_dfl_domain);
+	return __async_schedule(func, data, &async_dfl_domain, node);
 }
-EXPORT_SYMBOL_GPL(async_schedule);
+EXPORT_SYMBOL_GPL(async_schedule_on);
 
 /**
- * async_schedule_domain - schedule a function for asynchronous execution within a certain domain
+ * async_schedule_on_domain - schedule a function for asynchronous execution within a certain domain
  * @func: function to execute asynchronously
  * @data: data pointer to pass to the function
+ * @node: NUMA node to complete the work on
  * @domain: the domain
  *
  * Returns an async_cookie_t that may be used for checkpointing later.
@@ -226,12 +240,12 @@ async_cookie_t async_schedule(async_func_t func, void *data)
  * synchronization domain is specified via @domain.  Note: This function
  * may be called from atomic or non-atomic contexts.
  */
-async_cookie_t async_schedule_domain(async_func_t func, void *data,
-				     struct async_domain *domain)
+async_cookie_t async_schedule_on_domain(async_func_t func, void *data, int node,
+					struct async_domain *domain)
 {
-	return __async_schedule(func, data, domain);
+	return __async_schedule(func, data, domain, node);
 }
-EXPORT_SYMBOL_GPL(async_schedule_domain);
+EXPORT_SYMBOL_GPL(async_schedule_on_domain);
 
 /**
  * async_synchronize_full - synchronize all asynchronous function calls
