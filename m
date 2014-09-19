Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE376B0037
	for <linux-mm@kvack.org>; Fri, 19 Sep 2014 09:22:12 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so285205wgh.12
        for <linux-mm@kvack.org>; Fri, 19 Sep 2014 06:22:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ji10si1689049wid.43.2014.09.19.06.22.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Sep 2014 06:22:10 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: lockless page counters
Date: Fri, 19 Sep 2014 09:22:08 -0400
Message-Id: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Memory is internally accounted in bytes, using spinlock-protected
64-bit counters, even though the smallest accounting delta is a page.
The counter interface is also convoluted and does too many things.

Introduce a new lockless word-sized page counter API, then change all
memory accounting over to it and remove the old one.  The translation
from and to bytes then only happens when interfacing with userspace.

Aside from the locking costs, this gets rid of the icky unsigned long
long types in the very heart of memcg, which is great for 32 bit and
also makes the code a lot more readable.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/hugetlb.txt          |   2 +-
 Documentation/cgroups/memory.txt           |   4 +-
 Documentation/cgroups/resource_counter.txt | 197 --------
 include/linux/hugetlb_cgroup.h             |   1 -
 include/linux/memcontrol.h                 |  37 +-
 include/linux/res_counter.h                | 223 ---------
 include/net/sock.h                         |  25 +-
 init/Kconfig                               |   9 +-
 kernel/Makefile                            |   1 -
 kernel/res_counter.c                       | 211 --------
 mm/hugetlb_cgroup.c                        | 100 ++--
 mm/memcontrol.c                            | 740 ++++++++++++++++-------------
 net/ipv4/tcp_memcontrol.c                  |  83 ++--
 13 files changed, 541 insertions(+), 1092 deletions(-)
 delete mode 100644 Documentation/cgroups/resource_counter.txt
 delete mode 100644 include/linux/res_counter.h
 delete mode 100644 kernel/res_counter.c

diff --git a/Documentation/cgroups/hugetlb.txt b/Documentation/cgroups/hugetlb.txt
index a9faaca1f029..106245c3aecc 100644
--- a/Documentation/cgroups/hugetlb.txt
+++ b/Documentation/cgroups/hugetlb.txt
@@ -29,7 +29,7 @@ Brief summary of control files
 
  hugetlb.<hugepagesize>.limit_in_bytes     # set/show limit of "hugepagesize" hugetlb usage
  hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
- hugetlb.<hugepagesize>.usage_in_bytes     # show current res_counter usage for "hugepagesize" hugetlb
+ hugetlb.<hugepagesize>.usage_in_bytes     # show current usage for "hugepagesize" hugetlb
  hugetlb.<hugepagesize>.failcnt		   # show the number of allocation failure due to HugeTLB limit
 
 For a system supporting two hugepage size (16M and 16G) the control
diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 02ab997a1ed2..f624727ab404 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -52,9 +52,9 @@ Brief summary of control files.
  tasks				 # attach a task(thread) and show list of threads
  cgroup.procs			 # show list of processes
  cgroup.event_control		 # an interface for event_fd()
- memory.usage_in_bytes		 # show current res_counter usage for memory
+ memory.usage_in_bytes		 # show current usage for memory
 				 (See 5.5 for details)
- memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
+ memory.memsw.usage_in_bytes	 # show current usage for memory+Swap
 				 (See 5.5 for details)
  memory.limit_in_bytes		 # set/show limit of memory usage
  memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
deleted file mode 100644
index 762ca54eb929..000000000000
--- a/Documentation/cgroups/resource_counter.txt
+++ /dev/null
@@ -1,197 +0,0 @@
-
-		The Resource Counter
-
-The resource counter, declared at include/linux/res_counter.h,
-is supposed to facilitate the resource management by controllers
-by providing common stuff for accounting.
-
-This "stuff" includes the res_counter structure and routines
-to work with it.
-
-
-
-1. Crucial parts of the res_counter structure
-
- a. unsigned long long usage
-
- 	The usage value shows the amount of a resource that is consumed
-	by a group at a given time. The units of measurement should be
-	determined by the controller that uses this counter. E.g. it can
-	be bytes, items or any other unit the controller operates on.
-
- b. unsigned long long max_usage
-
- 	The maximal value of the usage over time.
-
- 	This value is useful when gathering statistical information about
-	the particular group, as it shows the actual resource requirements
-	for a particular group, not just some usage snapshot.
-
- c. unsigned long long limit
-
- 	The maximal allowed amount of resource to consume by the group. In
-	case the group requests for more resources, so that the usage value
-	would exceed the limit, the resource allocation is rejected (see
-	the next section).
-
- d. unsigned long long failcnt
-
- 	The failcnt stands for "failures counter". This is the number of
-	resource allocation attempts that failed.
-
- c. spinlock_t lock
-
- 	Protects changes of the above values.
-
-
-
-2. Basic accounting routines
-
- a. void res_counter_init(struct res_counter *rc,
-				struct res_counter *rc_parent)
-
- 	Initializes the resource counter. As usual, should be the first
-	routine called for a new counter.
-
-	The struct res_counter *parent can be used to define a hierarchical
-	child -> parent relationship directly in the res_counter structure,
-	NULL can be used to define no relationship.
-
- c. int res_counter_charge(struct res_counter *rc, unsigned long val,
-				struct res_counter **limit_fail_at)
-
-	When a resource is about to be allocated it has to be accounted
-	with the appropriate resource counter (controller should determine
-	which one to use on its own). This operation is called "charging".
-
-	This is not very important which operation - resource allocation
-	or charging - is performed first, but
-	  * if the allocation is performed first, this may create a
-	    temporary resource over-usage by the time resource counter is
-	    charged;
-	  * if the charging is performed first, then it should be uncharged
-	    on error path (if the one is called).
-
-	If the charging fails and a hierarchical dependency exists, the
-	limit_fail_at parameter is set to the particular res_counter element
-	where the charging failed.
-
- d. u64 res_counter_uncharge(struct res_counter *rc, unsigned long val)
-
-	When a resource is released (freed) it should be de-accounted
-	from the resource counter it was accounted to.  This is called
-	"uncharging". The return value of this function indicate the amount
-	of charges still present in the counter.
-
-	The _locked routines imply that the res_counter->lock is taken.
-
- e. u64 res_counter_uncharge_until
-		(struct res_counter *rc, struct res_counter *top,
-		 unsigned long val)
-
-	Almost same as res_counter_uncharge() but propagation of uncharge
-	stops when rc == top. This is useful when kill a res_counter in
-	child cgroup.
-
- 2.1 Other accounting routines
-
-    There are more routines that may help you with common needs, like
-    checking whether the limit is reached or resetting the max_usage
-    value. They are all declared in include/linux/res_counter.h.
-
-
-
-3. Analyzing the resource counter registrations
-
- a. If the failcnt value constantly grows, this means that the counter's
-    limit is too tight. Either the group is misbehaving and consumes too
-    many resources, or the configuration is not suitable for the group
-    and the limit should be increased.
-
- b. The max_usage value can be used to quickly tune the group. One may
-    set the limits to maximal values and either load the container with
-    a common pattern or leave one for a while. After this the max_usage
-    value shows the amount of memory the container would require during
-    its common activity.
-
-    Setting the limit a bit above this value gives a pretty good
-    configuration that works in most of the cases.
-
- c. If the max_usage is much less than the limit, but the failcnt value
-    is growing, then the group tries to allocate a big chunk of resource
-    at once.
-
- d. If the max_usage is much less than the limit, but the failcnt value
-    is 0, then this group is given too high limit, that it does not
-    require. It is better to lower the limit a bit leaving more resource
-    for other groups.
-
-
-
-4. Communication with the control groups subsystem (cgroups)
-
-All the resource controllers that are using cgroups and resource counters
-should provide files (in the cgroup filesystem) to work with the resource
-counter fields. They are recommended to adhere to the following rules:
-
- a. File names
-
- 	Field name	File name
-	---------------------------------------------------
-	usage		usage_in_<unit_of_measurement>
-	max_usage	max_usage_in_<unit_of_measurement>
-	limit		limit_in_<unit_of_measurement>
-	failcnt		failcnt
-	lock		no file :)
-
- b. Reading from file should show the corresponding field value in the
-    appropriate format.
-
- c. Writing to file
-
- 	Field		Expected behavior
-	----------------------------------
-	usage		prohibited
-	max_usage	reset to usage
-	limit		set the limit
-	failcnt		reset to zero
-
-
-
-5. Usage example
-
- a. Declare a task group (take a look at cgroups subsystem for this) and
-    fold a res_counter into it
-
-	struct my_group {
-		struct res_counter res;
-
-		<other fields>
-	}
-
- b. Put hooks in resource allocation/release paths
-
- 	int alloc_something(...)
-	{
-		if (res_counter_charge(res_counter_ptr, amount) < 0)
-			return -ENOMEM;
-
-		<allocate the resource and return to the caller>
-	}
-
-	void release_something(...)
-	{
-		res_counter_uncharge(res_counter_ptr, amount);
-
-		<release the resource>
-	}
-
-    In order to keep the usage value self-consistent, both the
-    "res_counter_ptr" and the "amount" in release_something() should be
-    the same as they were in the alloc_something() when the releasing
-    resource was allocated.
-
- c. Provide the way to read res_counter values and set them (the cgroups
-    still can help with it).
-
- c. Compile and run :)
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 0129f89cf98d..bcc853eccc85 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -16,7 +16,6 @@
 #define _LINUX_HUGETLB_CGROUP_H
 
 #include <linux/mmdebug.h>
-#include <linux/res_counter.h>
 
 struct hugetlb_cgroup;
 /*
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 19df5d857411..bf8fb1a05597 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -54,6 +54,38 @@ struct mem_cgroup_reclaim_cookie {
 };
 
 #ifdef CONFIG_MEMCG
+
+struct page_counter {
+	atomic_long_t count;
+	unsigned long limit;
+	struct page_counter *parent;
+
+	/* legacy */
+	unsigned long watermark;
+	unsigned long limited;
+};
+
+#if BITS_PER_LONG == 32
+#define PAGE_COUNTER_MAX ULONG_MAX
+#else
+#define PAGE_COUNTER_MAX (ULONG_MAX / PAGE_SIZE)
+#endif
+
+static inline void page_counter_init(struct page_counter *counter,
+				     struct page_counter *parent)
+{
+	atomic_long_set(&counter->count, 0);
+	counter->limit = PAGE_COUNTER_MAX;
+	counter->parent = parent;
+}
+
+int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
+int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
+			struct page_counter **fail);
+int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
+int page_counter_limit(struct page_counter *counter, unsigned long limit);
+int page_counter_memparse(const char *buf, unsigned long *nr_pages);
+
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 			  gfp_t gfp_mask, struct mem_cgroup **memcgp);
 void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
@@ -471,9 +503,8 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 	/*
 	 * __GFP_NOFAIL allocations will move on even if charging is not
 	 * possible. Therefore we don't even try, and have this allocation
-	 * unaccounted. We could in theory charge it with
-	 * res_counter_charge_nofail, but we hope those allocations are rare,
-	 * and won't be worth the trouble.
+	 * unaccounted. We could in theory charge it forcibly, but we hope
+	 * those allocations are rare, and won't be worth the trouble.
 	 */
 	if (gfp & __GFP_NOFAIL)
 		return true;
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
deleted file mode 100644
index 56b7bc32db4f..000000000000
--- a/include/linux/res_counter.h
+++ /dev/null
@@ -1,223 +0,0 @@
-#ifndef __RES_COUNTER_H__
-#define __RES_COUNTER_H__
-
-/*
- * Resource Counters
- * Contain common data types and routines for resource accounting
- *
- * Copyright 2007 OpenVZ SWsoft Inc
- *
- * Author: Pavel Emelianov <xemul@openvz.org>
- *
- * See Documentation/cgroups/resource_counter.txt for more
- * info about what this counter is.
- */
-
-#include <linux/spinlock.h>
-#include <linux/errno.h>
-
-/*
- * The core object. the cgroup that wishes to account for some
- * resource may include this counter into its structures and use
- * the helpers described beyond
- */
-
-struct res_counter {
-	/*
-	 * the current resource consumption level
-	 */
-	unsigned long long usage;
-	/*
-	 * the maximal value of the usage from the counter creation
-	 */
-	unsigned long long max_usage;
-	/*
-	 * the limit that usage cannot exceed
-	 */
-	unsigned long long limit;
-	/*
-	 * the limit that usage can be exceed
-	 */
-	unsigned long long soft_limit;
-	/*
-	 * the number of unsuccessful attempts to consume the resource
-	 */
-	unsigned long long failcnt;
-	/*
-	 * the lock to protect all of the above.
-	 * the routines below consider this to be IRQ-safe
-	 */
-	spinlock_t lock;
-	/*
-	 * Parent counter, used for hierarchial resource accounting
-	 */
-	struct res_counter *parent;
-};
-
-#define RES_COUNTER_MAX ULLONG_MAX
-
-/**
- * Helpers to interact with userspace
- * res_counter_read_u64() - returns the value of the specified member.
- * res_counter_read/_write - put/get the specified fields from the
- * res_counter struct to/from the user
- *
- * @counter:     the counter in question
- * @member:  the field to work with (see RES_xxx below)
- * @buf:     the buffer to opeate on,...
- * @nbytes:  its size...
- * @pos:     and the offset.
- */
-
-u64 res_counter_read_u64(struct res_counter *counter, int member);
-
-ssize_t res_counter_read(struct res_counter *counter, int member,
-		const char __user *buf, size_t nbytes, loff_t *pos,
-		int (*read_strategy)(unsigned long long val, char *s));
-
-int res_counter_memparse_write_strategy(const char *buf,
-					unsigned long long *res);
-
-/*
- * the field descriptors. one for each member of res_counter
- */
-
-enum {
-	RES_USAGE,
-	RES_MAX_USAGE,
-	RES_LIMIT,
-	RES_FAILCNT,
-	RES_SOFT_LIMIT,
-};
-
-/*
- * helpers for accounting
- */
-
-void res_counter_init(struct res_counter *counter, struct res_counter *parent);
-
-/*
- * charge - try to consume more resource.
- *
- * @counter: the counter
- * @val: the amount of the resource. each controller defines its own
- *       units, e.g. numbers, bytes, Kbytes, etc
- *
- * returns 0 on success and <0 if the counter->usage will exceed the
- * counter->limit
- *
- * charge_nofail works the same, except that it charges the resource
- * counter unconditionally, and returns < 0 if the after the current
- * charge we are over limit.
- */
-
-int __must_check res_counter_charge(struct res_counter *counter,
-		unsigned long val, struct res_counter **limit_fail_at);
-int res_counter_charge_nofail(struct res_counter *counter,
-		unsigned long val, struct res_counter **limit_fail_at);
-
-/*
- * uncharge - tell that some portion of the resource is released
- *
- * @counter: the counter
- * @val: the amount of the resource
- *
- * these calls check for usage underflow and show a warning on the console
- *
- * returns the total charges still present in @counter.
- */
-
-u64 res_counter_uncharge(struct res_counter *counter, unsigned long val);
-
-u64 res_counter_uncharge_until(struct res_counter *counter,
-			       struct res_counter *top,
-			       unsigned long val);
-/**
- * res_counter_margin - calculate chargeable space of a counter
- * @cnt: the counter
- *
- * Returns the difference between the hard limit and the current usage
- * of resource counter @cnt.
- */
-static inline unsigned long long res_counter_margin(struct res_counter *cnt)
-{
-	unsigned long long margin;
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	if (cnt->limit > cnt->usage)
-		margin = cnt->limit - cnt->usage;
-	else
-		margin = 0;
-	spin_unlock_irqrestore(&cnt->lock, flags);
-	return margin;
-}
-
-/**
- * Get the difference between the usage and the soft limit
- * @cnt: The counter
- *
- * Returns 0 if usage is less than or equal to soft limit
- * The difference between usage and soft limit, otherwise.
- */
-static inline unsigned long long
-res_counter_soft_limit_excess(struct res_counter *cnt)
-{
-	unsigned long long excess;
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	if (cnt->usage <= cnt->soft_limit)
-		excess = 0;
-	else
-		excess = cnt->usage - cnt->soft_limit;
-	spin_unlock_irqrestore(&cnt->lock, flags);
-	return excess;
-}
-
-static inline void res_counter_reset_max(struct res_counter *cnt)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	cnt->max_usage = cnt->usage;
-	spin_unlock_irqrestore(&cnt->lock, flags);
-}
-
-static inline void res_counter_reset_failcnt(struct res_counter *cnt)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	cnt->failcnt = 0;
-	spin_unlock_irqrestore(&cnt->lock, flags);
-}
-
-static inline int res_counter_set_limit(struct res_counter *cnt,
-		unsigned long long limit)
-{
-	unsigned long flags;
-	int ret = -EBUSY;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	if (cnt->usage <= limit) {
-		cnt->limit = limit;
-		ret = 0;
-	}
-	spin_unlock_irqrestore(&cnt->lock, flags);
-	return ret;
-}
-
-static inline int
-res_counter_set_soft_limit(struct res_counter *cnt,
-				unsigned long long soft_limit)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	cnt->soft_limit = soft_limit;
-	spin_unlock_irqrestore(&cnt->lock, flags);
-	return 0;
-}
-
-#endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 515a4d01e932..f41749982668 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -55,7 +55,6 @@
 #include <linux/slab.h>
 #include <linux/uaccess.h>
 #include <linux/memcontrol.h>
-#include <linux/res_counter.h>
 #include <linux/static_key.h>
 #include <linux/aio.h>
 #include <linux/sched.h>
@@ -1066,7 +1065,7 @@ enum cg_proto_flags {
 };
 
 struct cg_proto {
-	struct res_counter	memory_allocated;	/* Current allocated memory. */
+	struct page_counter	memory_allocated;	/* Current allocated memory. */
 	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
 	int			memory_pressure;
 	long			sysctl_mem[3];
@@ -1218,34 +1217,26 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 					      unsigned long amt,
 					      int *parent_status)
 {
-	struct res_counter *fail;
-	int ret;
+	page_counter_charge(&prot->memory_allocated, amt, NULL);
 
-	ret = res_counter_charge_nofail(&prot->memory_allocated,
-					amt << PAGE_SHIFT, &fail);
-	if (ret < 0)
+	if (atomic_long_read(&prot->memory_allocated.count) >
+	    prot->memory_allocated.limit)
 		*parent_status = OVER_LIMIT;
 }
 
 static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
 					      unsigned long amt)
 {
-	res_counter_uncharge(&prot->memory_allocated, amt << PAGE_SHIFT);
-}
-
-static inline u64 memcg_memory_allocated_read(struct cg_proto *prot)
-{
-	u64 ret;
-	ret = res_counter_read_u64(&prot->memory_allocated, RES_USAGE);
-	return ret >> PAGE_SHIFT;
+	page_counter_uncharge(&prot->memory_allocated, amt);
 }
 
 static inline long
 sk_memory_allocated(const struct sock *sk)
 {
 	struct proto *prot = sk->sk_prot;
+
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return memcg_memory_allocated_read(sk->sk_cgrp);
+		return atomic_long_read(&sk->sk_cgrp->memory_allocated.count);
 
 	return atomic_long_read(prot->memory_allocated);
 }
@@ -1259,7 +1250,7 @@ sk_memory_allocated_add(struct sock *sk, int amt, int *parent_status)
 		memcg_memory_allocated_add(sk->sk_cgrp, amt, parent_status);
 		/* update the root cgroup regardless */
 		atomic_long_add_return(amt, prot->memory_allocated);
-		return memcg_memory_allocated_read(sk->sk_cgrp);
+		return atomic_long_read(&sk->sk_cgrp->memory_allocated.count);
 	}
 
 	return atomic_long_add_return(amt, prot->memory_allocated);
diff --git a/init/Kconfig b/init/Kconfig
index 0471be99ec38..1cf42b563834 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -975,15 +975,8 @@ config CGROUP_CPUACCT
 	  Provides a simple Resource Controller for monitoring the
 	  total CPU consumed by the tasks in a cgroup.
 
-config RESOURCE_COUNTERS
-	bool "Resource counters"
-	help
-	  This option enables controller independent resource accounting
-	  infrastructure that works with cgroups.
-
 config MEMCG
 	bool "Memory Resource Controller for Control Groups"
-	depends on RESOURCE_COUNTERS
 	select EVENTFD
 	help
 	  Provides a memory resource controller that manages both anonymous
@@ -1051,7 +1044,7 @@ config MEMCG_KMEM
 
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
-	depends on RESOURCE_COUNTERS && HUGETLB_PAGE
+	depends on MEMCG && HUGETLB_PAGE
 	default n
 	help
 	  Provides a cgroup Resource Controller for HugeTLB pages.
diff --git a/kernel/Makefile b/kernel/Makefile
index 726e18443da0..245953354974 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -58,7 +58,6 @@ obj-$(CONFIG_USER_NS) += user_namespace.o
 obj-$(CONFIG_PID_NS) += pid_namespace.o
 obj-$(CONFIG_DEBUG_SYNCHRO_TEST) += synchro-test.o
 obj-$(CONFIG_IKCONFIG) += configs.o
-obj-$(CONFIG_RESOURCE_COUNTERS) += res_counter.o
 obj-$(CONFIG_SMP) += stop_machine.o
 obj-$(CONFIG_KPROBES_SANITY_TEST) += test_kprobes.o
 obj-$(CONFIG_AUDIT) += audit.o auditfilter.o
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
deleted file mode 100644
index e791130f85a7..000000000000
--- a/kernel/res_counter.c
+++ /dev/null
@@ -1,211 +0,0 @@
-/*
- * resource cgroups
- *
- * Copyright 2007 OpenVZ SWsoft Inc
- *
- * Author: Pavel Emelianov <xemul@openvz.org>
- *
- */
-
-#include <linux/types.h>
-#include <linux/parser.h>
-#include <linux/fs.h>
-#include <linux/res_counter.h>
-#include <linux/uaccess.h>
-#include <linux/mm.h>
-
-void res_counter_init(struct res_counter *counter, struct res_counter *parent)
-{
-	spin_lock_init(&counter->lock);
-	counter->limit = RES_COUNTER_MAX;
-	counter->soft_limit = RES_COUNTER_MAX;
-	counter->parent = parent;
-}
-
-static u64 res_counter_uncharge_locked(struct res_counter *counter,
-				       unsigned long val)
-{
-	if (WARN_ON(counter->usage < val))
-		val = counter->usage;
-
-	counter->usage -= val;
-	return counter->usage;
-}
-
-static int res_counter_charge_locked(struct res_counter *counter,
-				     unsigned long val, bool force)
-{
-	int ret = 0;
-
-	if (counter->usage + val > counter->limit) {
-		counter->failcnt++;
-		ret = -ENOMEM;
-		if (!force)
-			return ret;
-	}
-
-	counter->usage += val;
-	if (counter->usage > counter->max_usage)
-		counter->max_usage = counter->usage;
-	return ret;
-}
-
-static int __res_counter_charge(struct res_counter *counter, unsigned long val,
-				struct res_counter **limit_fail_at, bool force)
-{
-	int ret, r;
-	unsigned long flags;
-	struct res_counter *c, *u;
-
-	r = ret = 0;
-	*limit_fail_at = NULL;
-	local_irq_save(flags);
-	for (c = counter; c != NULL; c = c->parent) {
-		spin_lock(&c->lock);
-		r = res_counter_charge_locked(c, val, force);
-		spin_unlock(&c->lock);
-		if (r < 0 && !ret) {
-			ret = r;
-			*limit_fail_at = c;
-			if (!force)
-				break;
-		}
-	}
-
-	if (ret < 0 && !force) {
-		for (u = counter; u != c; u = u->parent) {
-			spin_lock(&u->lock);
-			res_counter_uncharge_locked(u, val);
-			spin_unlock(&u->lock);
-		}
-	}
-	local_irq_restore(flags);
-
-	return ret;
-}
-
-int res_counter_charge(struct res_counter *counter, unsigned long val,
-			struct res_counter **limit_fail_at)
-{
-	return __res_counter_charge(counter, val, limit_fail_at, false);
-}
-
-int res_counter_charge_nofail(struct res_counter *counter, unsigned long val,
-			      struct res_counter **limit_fail_at)
-{
-	return __res_counter_charge(counter, val, limit_fail_at, true);
-}
-
-u64 res_counter_uncharge_until(struct res_counter *counter,
-			       struct res_counter *top,
-			       unsigned long val)
-{
-	unsigned long flags;
-	struct res_counter *c;
-	u64 ret = 0;
-
-	local_irq_save(flags);
-	for (c = counter; c != top; c = c->parent) {
-		u64 r;
-		spin_lock(&c->lock);
-		r = res_counter_uncharge_locked(c, val);
-		if (c == counter)
-			ret = r;
-		spin_unlock(&c->lock);
-	}
-	local_irq_restore(flags);
-	return ret;
-}
-
-u64 res_counter_uncharge(struct res_counter *counter, unsigned long val)
-{
-	return res_counter_uncharge_until(counter, NULL, val);
-}
-
-static inline unsigned long long *
-res_counter_member(struct res_counter *counter, int member)
-{
-	switch (member) {
-	case RES_USAGE:
-		return &counter->usage;
-	case RES_MAX_USAGE:
-		return &counter->max_usage;
-	case RES_LIMIT:
-		return &counter->limit;
-	case RES_FAILCNT:
-		return &counter->failcnt;
-	case RES_SOFT_LIMIT:
-		return &counter->soft_limit;
-	};
-
-	BUG();
-	return NULL;
-}
-
-ssize_t res_counter_read(struct res_counter *counter, int member,
-		const char __user *userbuf, size_t nbytes, loff_t *pos,
-		int (*read_strategy)(unsigned long long val, char *st_buf))
-{
-	unsigned long long *val;
-	char buf[64], *s;
-
-	s = buf;
-	val = res_counter_member(counter, member);
-	if (read_strategy)
-		s += read_strategy(*val, s);
-	else
-		s += sprintf(s, "%llu\n", *val);
-	return simple_read_from_buffer((void __user *)userbuf, nbytes,
-			pos, buf, s - buf);
-}
-
-#if BITS_PER_LONG == 32
-u64 res_counter_read_u64(struct res_counter *counter, int member)
-{
-	unsigned long flags;
-	u64 ret;
-
-	spin_lock_irqsave(&counter->lock, flags);
-	ret = *res_counter_member(counter, member);
-	spin_unlock_irqrestore(&counter->lock, flags);
-
-	return ret;
-}
-#else
-u64 res_counter_read_u64(struct res_counter *counter, int member)
-{
-	return *res_counter_member(counter, member);
-}
-#endif
-
-int res_counter_memparse_write_strategy(const char *buf,
-					unsigned long long *resp)
-{
-	char *end;
-	unsigned long long res;
-
-	/* return RES_COUNTER_MAX(unlimited) if "-1" is specified */
-	if (*buf == '-') {
-		int rc = kstrtoull(buf + 1, 10, &res);
-
-		if (rc)
-			return rc;
-		if (res != 1)
-			return -EINVAL;
-		*resp = RES_COUNTER_MAX;
-		return 0;
-	}
-
-	res = memparse(buf, &end);
-	if (*end != '\0')
-		return -EINVAL;
-
-	if (PAGE_ALIGN(res) >= res)
-		res = PAGE_ALIGN(res);
-	else
-		res = RES_COUNTER_MAX;
-
-	*resp = res;
-
-	return 0;
-}
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index a67c26e0f360..e619b6b62f1f 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -14,6 +14,7 @@
  */
 
 #include <linux/cgroup.h>
+#include <linux/memcontrol.h>
 #include <linux/slab.h>
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
@@ -23,7 +24,7 @@ struct hugetlb_cgroup {
 	/*
 	 * the counter to account for hugepages from hugetlb.
 	 */
-	struct res_counter hugepage[HUGE_MAX_HSTATE];
+	struct page_counter hugepage[HUGE_MAX_HSTATE];
 };
 
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
@@ -60,7 +61,7 @@ static inline bool hugetlb_cgroup_have_usage(struct hugetlb_cgroup *h_cg)
 	int idx;
 
 	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
-		if ((res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE)) > 0)
+		if (atomic_long_read(&h_cg->hugepage[idx].count))
 			return true;
 	}
 	return false;
@@ -79,12 +80,12 @@ hugetlb_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	if (parent_h_cgroup) {
 		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
-			res_counter_init(&h_cgroup->hugepage[idx],
-					 &parent_h_cgroup->hugepage[idx]);
+			page_counter_init(&h_cgroup->hugepage[idx],
+					  &parent_h_cgroup->hugepage[idx]);
 	} else {
 		root_h_cgroup = h_cgroup;
 		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
-			res_counter_init(&h_cgroup->hugepage[idx], NULL);
+			page_counter_init(&h_cgroup->hugepage[idx], NULL);
 	}
 	return &h_cgroup->css;
 }
@@ -108,9 +109,8 @@ static void hugetlb_cgroup_css_free(struct cgroup_subsys_state *css)
 static void hugetlb_cgroup_move_parent(int idx, struct hugetlb_cgroup *h_cg,
 				       struct page *page)
 {
-	int csize;
-	struct res_counter *counter;
-	struct res_counter *fail_res;
+	unsigned int nr_pages;
+	struct page_counter *counter;
 	struct hugetlb_cgroup *page_hcg;
 	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(h_cg);
 
@@ -123,15 +123,15 @@ static void hugetlb_cgroup_move_parent(int idx, struct hugetlb_cgroup *h_cg,
 	if (!page_hcg || page_hcg != h_cg)
 		goto out;
 
-	csize = PAGE_SIZE << compound_order(page);
+	nr_pages = 1 << compound_order(page);
 	if (!parent) {
 		parent = root_h_cgroup;
 		/* root has no limit */
-		res_counter_charge_nofail(&parent->hugepage[idx],
-					  csize, &fail_res);
+		page_counter_charge(&parent->hugepage[idx], nr_pages, NULL);
 	}
 	counter = &h_cg->hugepage[idx];
-	res_counter_uncharge_until(counter, counter->parent, csize);
+	/* Take the pages off the local counter */
+	page_counter_cancel(counter, nr_pages);
 
 	set_hugetlb_cgroup(page, parent);
 out:
@@ -166,9 +166,8 @@ int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
 				 struct hugetlb_cgroup **ptr)
 {
 	int ret = 0;
-	struct res_counter *fail_res;
+	struct page_counter *counter;
 	struct hugetlb_cgroup *h_cg = NULL;
-	unsigned long csize = nr_pages * PAGE_SIZE;
 
 	if (hugetlb_cgroup_disabled())
 		goto done;
@@ -187,7 +186,7 @@ again:
 	}
 	rcu_read_unlock();
 
-	ret = res_counter_charge(&h_cg->hugepage[idx], csize, &fail_res);
+	ret = page_counter_charge(&h_cg->hugepage[idx], nr_pages, &counter);
 	css_put(&h_cg->css);
 done:
 	*ptr = h_cg;
@@ -213,7 +212,6 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 				  struct page *page)
 {
 	struct hugetlb_cgroup *h_cg;
-	unsigned long csize = nr_pages * PAGE_SIZE;
 
 	if (hugetlb_cgroup_disabled())
 		return;
@@ -222,61 +220,73 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 	if (unlikely(!h_cg))
 		return;
 	set_hugetlb_cgroup(page, NULL);
-	res_counter_uncharge(&h_cg->hugepage[idx], csize);
+	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
 	return;
 }
 
 void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
 				    struct hugetlb_cgroup *h_cg)
 {
-	unsigned long csize = nr_pages * PAGE_SIZE;
-
 	if (hugetlb_cgroup_disabled() || !h_cg)
 		return;
 
 	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
 		return;
 
-	res_counter_uncharge(&h_cg->hugepage[idx], csize);
+	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
 	return;
 }
 
+enum {
+	RES_USAGE,
+	RES_LIMIT,
+	RES_MAX_USAGE,
+	RES_FAILCNT,
+};
+
 static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
 				   struct cftype *cft)
 {
-	int idx, name;
+	struct page_counter *counter;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
 
-	idx = MEMFILE_IDX(cft->private);
-	name = MEMFILE_ATTR(cft->private);
+	counter = &h_cg->hugepage[MEMFILE_IDX(cft->private)];
 
-	return res_counter_read_u64(&h_cg->hugepage[idx], name);
+	switch (MEMFILE_ATTR(cft->private)) {
+	case RES_USAGE:
+		return (u64)atomic_long_read(&counter->count) * PAGE_SIZE;
+	case RES_LIMIT:
+		return (u64)counter->limit * PAGE_SIZE;
+	case RES_MAX_USAGE:
+		return (u64)counter->watermark * PAGE_SIZE;
+	case RES_FAILCNT:
+		return counter->limited;
+	default:
+		BUG();
+	}
 }
 
 static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 				    char *buf, size_t nbytes, loff_t off)
 {
-	int idx, name, ret;
-	unsigned long long val;
+	int ret, idx;
+	unsigned long nr_pages;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
 
+	if (hugetlb_cgroup_is_root(h_cg)) /* Can't set limit on root */
+		return -EINVAL;
+
 	buf = strstrip(buf);
+	ret = page_counter_memparse(buf, &nr_pages);
+	if (ret)
+		return ret;
+
 	idx = MEMFILE_IDX(of_cft(of)->private);
-	name = MEMFILE_ATTR(of_cft(of)->private);
 
-	switch (name) {
+	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:
-		if (hugetlb_cgroup_is_root(h_cg)) {
-			/* Can't set limit on root */
-			ret = -EINVAL;
-			break;
-		}
-		/* This function does all necessary parse...reuse it */
-		ret = res_counter_memparse_write_strategy(buf, &val);
-		if (ret)
-			break;
-		val = ALIGN(val, 1ULL << huge_page_shift(&hstates[idx]));
-		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
+		nr_pages = ALIGN(nr_pages, huge_page_shift(&hstates[idx]));
+		ret = page_counter_limit(&h_cg->hugepage[idx], nr_pages);
 		break;
 	default:
 		ret = -EINVAL;
@@ -288,18 +298,18 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 static ssize_t hugetlb_cgroup_reset(struct kernfs_open_file *of,
 				    char *buf, size_t nbytes, loff_t off)
 {
-	int idx, name, ret = 0;
+	int ret = 0;
+	struct page_counter *counter;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
 
-	idx = MEMFILE_IDX(of_cft(of)->private);
-	name = MEMFILE_ATTR(of_cft(of)->private);
+	counter = &h_cg->hugepage[MEMFILE_IDX(of_cft(of)->private)];
 
-	switch (name) {
+	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_MAX_USAGE:
-		res_counter_reset_max(&h_cg->hugepage[idx]);
+		counter->watermark = atomic_long_read(&counter->count);
 		break;
 	case RES_FAILCNT:
-		res_counter_reset_failcnt(&h_cg->hugepage[idx]);
+		counter->limited = 0;
 		break;
 	default:
 		ret = -EINVAL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2def11f1ec1..dfd3b15a57e8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -25,7 +25,6 @@
  * GNU General Public License for more details.
  */
 
-#include <linux/res_counter.h>
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
@@ -66,6 +65,117 @@
 
 #include <trace/events/vmscan.h>
 
+int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
+{
+	long new;
+
+	new = atomic_long_sub_return(nr_pages, &counter->count);
+
+	if (WARN_ON(unlikely(new < 0)))
+		atomic_long_set(&counter->count, 0);
+
+	return new > 1;
+}
+
+int page_counter_charge(struct page_counter *counter, unsigned long nr_pages,
+			struct page_counter **fail)
+{
+	struct page_counter *c;
+
+	for (c = counter; c; c = c->parent) {
+		for (;;) {
+			unsigned long count;
+			unsigned long new;
+
+			count = atomic_long_read(&c->count);
+
+			new = count + nr_pages;
+			if (new > c->limit) {
+				c->limited++;
+				if (fail) {
+					*fail = c;
+					goto failed;
+				}
+			}
+
+			if (atomic_long_cmpxchg(&c->count, count, new) != count)
+				continue;
+
+			if (new > c->watermark)
+				c->watermark = new;
+
+			break;
+		}
+	}
+	return 0;
+
+failed:
+	for (c = counter; c != *fail; c = c->parent)
+		page_counter_cancel(c, nr_pages);
+
+	return -ENOMEM;
+}
+
+int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages)
+{
+	struct page_counter *c;
+	int ret = 1;
+
+	for (c = counter; c; c = c->parent) {
+		int remainder;
+
+		remainder = page_counter_cancel(c, nr_pages);
+		if (c == counter && !remainder)
+			ret = 0;
+	}
+
+	return ret;
+}
+
+int page_counter_limit(struct page_counter *counter, unsigned long limit)
+{
+	for (;;) {
+		unsigned long count;
+		unsigned long old;
+
+		count = atomic_long_read(&counter->count);
+
+		old = xchg(&counter->limit, limit);
+
+		if (atomic_long_read(&counter->count) != count) {
+			counter->limit = old;
+			continue;
+		}
+
+		if (count > limit) {
+			counter->limit = old;
+			return -EBUSY;
+		}
+
+		return 0;
+	}
+}
+
+int page_counter_memparse(const char *buf, unsigned long *nr_pages)
+{
+	char unlimited[] = "-1";
+	char *end;
+	u64 bytes;
+
+	if (!strncmp(buf, unlimited, sizeof(unlimited))) {
+		*nr_pages = PAGE_COUNTER_MAX;
+		return 0;
+	}
+
+	bytes = memparse(buf, &end);
+	if (*end != '\0')
+		return -EINVAL;
+
+	*nr_pages = min(bytes / PAGE_SIZE, (u64)PAGE_COUNTER_MAX);
+
+	return 0;
+}
+
 struct cgroup_subsys memory_cgrp_subsys __read_mostly;
 EXPORT_SYMBOL(memory_cgrp_subsys);
 
@@ -165,7 +275,7 @@ struct mem_cgroup_per_zone {
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
 	struct rb_node		tree_node;	/* RB tree node */
-	unsigned long long	usage_in_excess;/* Set to the value by which */
+	unsigned long		usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
 	bool			on_tree;
 	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
@@ -198,7 +308,7 @@ static struct mem_cgroup_tree soft_limit_tree __read_mostly;
 
 struct mem_cgroup_threshold {
 	struct eventfd_ctx *eventfd;
-	u64 threshold;
+	unsigned long threshold;
 };
 
 /* For threshold */
@@ -284,24 +394,18 @@ static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
  */
 struct mem_cgroup {
 	struct cgroup_subsys_state css;
-	/*
-	 * the counter to account for memory usage
-	 */
-	struct res_counter res;
+
+	/* Accounted resources */
+	struct page_counter memory;
+	struct page_counter memsw;
+	struct page_counter kmem;
+
+	unsigned long soft_limit;
 
 	/* vmpressure notifications */
 	struct vmpressure vmpressure;
 
 	/*
-	 * the counter to account for mem+swap usage.
-	 */
-	struct res_counter memsw;
-
-	/*
-	 * the counter to account for kernel memory usage.
-	 */
-	struct res_counter kmem;
-	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
@@ -647,7 +751,7 @@ static void disarm_kmem_keys(struct mem_cgroup *memcg)
 	 * This check can't live in kmem destruction function,
 	 * since the charges will outlive the cgroup
 	 */
-	WARN_ON(res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0);
+	WARN_ON(atomic_long_read(&memcg->kmem.count));
 }
 #else
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
@@ -703,7 +807,7 @@ soft_limit_tree_from_page(struct page *page)
 
 static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_zone *mz,
 					 struct mem_cgroup_tree_per_zone *mctz,
-					 unsigned long long new_usage_in_excess)
+					 unsigned long new_usage_in_excess)
 {
 	struct rb_node **p = &mctz->rb_root.rb_node;
 	struct rb_node *parent = NULL;
@@ -752,10 +856,21 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup_per_zone *mz,
 	spin_unlock_irqrestore(&mctz->lock, flags);
 }
 
+static unsigned long soft_limit_excess(struct mem_cgroup *memcg)
+{
+	unsigned long nr_pages = atomic_long_read(&memcg->memory.count);
+	unsigned long soft_limit = ACCESS_ONCE(memcg->soft_limit);
+	unsigned long excess = 0;
+
+	if (nr_pages > soft_limit)
+		excess = nr_pages - soft_limit;
+
+	return excess;
+}
 
 static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
 {
-	unsigned long long excess;
+	unsigned long excess;
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup_tree_per_zone *mctz;
 
@@ -766,7 +881,7 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
 	 */
 	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
 		mz = mem_cgroup_page_zoneinfo(memcg, page);
-		excess = res_counter_soft_limit_excess(&memcg->res);
+		excess = soft_limit_excess(memcg);
 		/*
 		 * We have to update the tree if mz is on RB-tree or
 		 * mem is over its softlimit.
@@ -822,7 +937,7 @@ retry:
 	 * position in the tree.
 	 */
 	__mem_cgroup_remove_exceeded(mz, mctz);
-	if (!res_counter_soft_limit_excess(&mz->memcg->res) ||
+	if (!soft_limit_excess(mz->memcg) ||
 	    !css_tryget_online(&mz->memcg->css))
 		goto retry;
 done:
@@ -1478,7 +1593,7 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 	return inactive * inactive_ratio < active;
 }
 
-#define mem_cgroup_from_res_counter(counter, member)	\
+#define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
 /**
@@ -1490,12 +1605,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
  */
 static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 {
-	unsigned long long margin;
+	unsigned long margin = 0;
+	unsigned long count;
+	unsigned long limit;
 
-	margin = res_counter_margin(&memcg->res);
-	if (do_swap_account)
-		margin = min(margin, res_counter_margin(&memcg->memsw));
-	return margin >> PAGE_SHIFT;
+	count = atomic_long_read(&memcg->memory.count);
+	limit = ACCESS_ONCE(memcg->memory.limit);
+	if (count < limit)
+		margin = limit - count;
+
+	if (do_swap_account) {
+		count = atomic_long_read(&memcg->memsw.count);
+		limit = ACCESS_ONCE(memcg->memsw.limit);
+		if (count < limit)
+			margin = min(margin, limit - count);
+	}
+
+	return margin;
 }
 
 int mem_cgroup_swappiness(struct mem_cgroup *memcg)
@@ -1636,18 +1762,15 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 
 	rcu_read_unlock();
 
-	pr_info("memory: usage %llukB, limit %llukB, failcnt %llu\n",
-		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
-		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
-		res_counter_read_u64(&memcg->res, RES_FAILCNT));
-	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %llu\n",
-		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
-		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
-		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
-	pr_info("kmem: usage %llukB, limit %llukB, failcnt %llu\n",
-		res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
-		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
-		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
+	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
+		K((u64)atomic_long_read(&memcg->memory.count)),
+		K((u64)memcg->memory.limit), memcg->memory.limited);
+	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
+		K((u64)atomic_long_read(&memcg->memsw.count)),
+		K((u64)memcg->memsw.limit), memcg->memsw.limited);
+	pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
+		K((u64)atomic_long_read(&memcg->kmem.count)),
+		K((u64)memcg->kmem.limit), memcg->kmem.limited);
 
 	for_each_mem_cgroup_tree(iter, memcg) {
 		pr_info("Memory cgroup stats for ");
@@ -1685,30 +1808,19 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
 }
 
 /*
- * Return the memory (and swap, if configured) limit for a memcg.
+ * Return the memory (and swap, if configured) maximum consumption for a memcg.
  */
-static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
+static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
-	u64 limit;
+	unsigned long limit;
 
-	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-
-	/*
-	 * Do not consider swap space if we cannot swap due to swappiness
-	 */
+	limit = memcg->memory.limit;
 	if (mem_cgroup_swappiness(memcg)) {
-		u64 memsw;
+		unsigned long memsw_limit;
 
-		limit += total_swap_pages << PAGE_SHIFT;
-		memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-
-		/*
-		 * If memsw is finite and limits the amount of swap space
-		 * available to this memcg, return that limit.
-		 */
-		limit = min(limit, memsw);
+		memsw_limit = memcg->memsw.limit;
+		limit = min(limit + total_swap_pages, memsw_limit);
 	}
-
 	return limit;
 }
 
@@ -1732,7 +1844,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	}
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
-	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
+	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
 		struct task_struct *task;
@@ -1935,7 +2047,7 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 		.priority = 0,
 	};
 
-	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
+	excess = soft_limit_excess(root_memcg);
 
 	while (1) {
 		victim = mem_cgroup_iter(root_memcg, victim, &reclaim);
@@ -1966,7 +2078,7 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
 						     zone, &nr_scanned);
 		*total_scanned += nr_scanned;
-		if (!res_counter_soft_limit_excess(&root_memcg->res))
+		if (!soft_limit_excess(root_memcg))
 			break;
 	}
 	mem_cgroup_iter_break(root_memcg, victim);
@@ -2293,33 +2405,31 @@ static DEFINE_MUTEX(percpu_charge_mutex);
 static bool consume_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	struct memcg_stock_pcp *stock;
-	bool ret = true;
+	bool ret = false;
 
 	if (nr_pages > CHARGE_BATCH)
-		return false;
+		return ret;
 
 	stock = &get_cpu_var(memcg_stock);
-	if (memcg == stock->cached && stock->nr_pages >= nr_pages)
+	if (memcg == stock->cached && stock->nr_pages >= nr_pages) {
 		stock->nr_pages -= nr_pages;
-	else /* need to call res_counter_charge */
-		ret = false;
+		ret = true;
+	}
 	put_cpu_var(memcg_stock);
 	return ret;
 }
 
 /*
- * Returns stocks cached in percpu to res_counter and reset cached information.
+ * Returns stocks cached in percpu and reset cached information.
  */
 static void drain_stock(struct memcg_stock_pcp *stock)
 {
 	struct mem_cgroup *old = stock->cached;
 
 	if (stock->nr_pages) {
-		unsigned long bytes = stock->nr_pages * PAGE_SIZE;
-
-		res_counter_uncharge(&old->res, bytes);
+		page_counter_uncharge(&old->memory, stock->nr_pages);
 		if (do_swap_account)
-			res_counter_uncharge(&old->memsw, bytes);
+			page_counter_uncharge(&old->memsw, stock->nr_pages);
 		stock->nr_pages = 0;
 	}
 	stock->cached = NULL;
@@ -2348,7 +2458,7 @@ static void __init memcg_stock_init(void)
 }
 
 /*
- * Cache charges(val) which is from res_counter, to local per_cpu area.
+ * Cache charges(val) to local per_cpu area.
  * This will be consumed by consume_stock() function, later.
  */
 static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
@@ -2408,8 +2518,7 @@ out:
 /*
  * Tries to drain stocked charges in other cpus. This function is asynchronous
  * and just put a work per cpu for draining localy on each cpu. Caller can
- * expects some charges will be back to res_counter later but cannot wait for
- * it.
+ * expects some charges will be back later but cannot wait for it.
  */
 static void drain_all_stock_async(struct mem_cgroup *root_memcg)
 {
@@ -2483,9 +2592,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem_over_limit;
-	struct res_counter *fail_res;
+	struct page_counter *counter;
 	unsigned long nr_reclaimed;
-	unsigned long long size;
 	bool may_swap = true;
 	bool drained = false;
 	int ret = 0;
@@ -2496,17 +2604,16 @@ retry:
 	if (consume_stock(memcg, nr_pages))
 		goto done;
 
-	size = batch * PAGE_SIZE;
-	if (!res_counter_charge(&memcg->res, size, &fail_res)) {
+	if (!page_counter_charge(&memcg->memory, batch, &counter)) {
 		if (!do_swap_account)
 			goto done_restock;
-		if (!res_counter_charge(&memcg->memsw, size, &fail_res))
+		if (!page_counter_charge(&memcg->memsw, batch, &counter))
 			goto done_restock;
-		res_counter_uncharge(&memcg->res, size);
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
+		page_counter_uncharge(&memcg->memory, batch);
+		mem_over_limit = mem_cgroup_from_counter(counter, memsw);
 		may_swap = false;
 	} else
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+		mem_over_limit = mem_cgroup_from_counter(counter, memory);
 
 	if (batch > nr_pages) {
 		batch = nr_pages;
@@ -2587,32 +2694,12 @@ done:
 
 static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-	unsigned long bytes = nr_pages * PAGE_SIZE;
-
 	if (mem_cgroup_is_root(memcg))
 		return;
 
-	res_counter_uncharge(&memcg->res, bytes);
+	page_counter_uncharge(&memcg->memory, nr_pages);
 	if (do_swap_account)
-		res_counter_uncharge(&memcg->memsw, bytes);
-}
-
-/*
- * Cancel chrages in this cgroup....doesn't propagate to parent cgroup.
- * This is useful when moving usage to parent cgroup.
- */
-static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
-					unsigned int nr_pages)
-{
-	unsigned long bytes = nr_pages * PAGE_SIZE;
-
-	if (mem_cgroup_is_root(memcg))
-		return;
-
-	res_counter_uncharge_until(&memcg->res, memcg->res.parent, bytes);
-	if (do_swap_account)
-		res_counter_uncharge_until(&memcg->memsw,
-						memcg->memsw.parent, bytes);
+		page_counter_uncharge(&memcg->memsw, nr_pages);
 }
 
 /*
@@ -2736,8 +2823,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 		unlock_page_lru(page, isolated);
 }
 
-static DEFINE_MUTEX(set_limit_mutex);
-
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * The memcg_slab_mutex is held whenever a per memcg kmem cache is created or
@@ -2786,16 +2871,17 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 }
 #endif
 
-static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
+static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
+			     unsigned long nr_pages)
 {
-	struct res_counter *fail_res;
+	struct page_counter *counter;
 	int ret = 0;
 
-	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
-	if (ret)
+	ret = page_counter_charge(&memcg->kmem, nr_pages, &counter);
+	if (ret < 0)
 		return ret;
 
-	ret = try_charge(memcg, gfp, size >> PAGE_SHIFT);
+	ret = try_charge(memcg, gfp, nr_pages);
 	if (ret == -EINTR)  {
 		/*
 		 * try_charge() chose to bypass to root due to OOM kill or
@@ -2812,25 +2898,25 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 		 * when the allocation triggers should have been already
 		 * directed to the root cgroup in memcontrol.h
 		 */
-		res_counter_charge_nofail(&memcg->res, size, &fail_res);
+		page_counter_charge(&memcg->memory, nr_pages, NULL);
 		if (do_swap_account)
-			res_counter_charge_nofail(&memcg->memsw, size,
-						  &fail_res);
+			page_counter_charge(&memcg->memsw, nr_pages, NULL);
 		ret = 0;
 	} else if (ret)
-		res_counter_uncharge(&memcg->kmem, size);
+		page_counter_uncharge(&memcg->kmem, nr_pages);
 
 	return ret;
 }
 
-static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
+static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
+				unsigned long nr_pages)
 {
-	res_counter_uncharge(&memcg->res, size);
+	page_counter_uncharge(&memcg->memory, nr_pages);
 	if (do_swap_account)
-		res_counter_uncharge(&memcg->memsw, size);
+		page_counter_uncharge(&memcg->memsw, nr_pages);
 
 	/* Not down to 0 */
-	if (res_counter_uncharge(&memcg->kmem, size))
+	if (page_counter_uncharge(&memcg->kmem, nr_pages))
 		return;
 
 	/*
@@ -3107,19 +3193,21 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 {
+	unsigned int nr_pages = 1 << order;
 	int res;
 
-	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp,
-				PAGE_SIZE << order);
+	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp, nr_pages);
 	if (!res)
-		atomic_add(1 << order, &cachep->memcg_params->nr_pages);
+		atomic_add(nr_pages, &cachep->memcg_params->nr_pages);
 	return res;
 }
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 {
-	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
-	atomic_sub(1 << order, &cachep->memcg_params->nr_pages);
+	unsigned int nr_pages = 1 << order;
+
+	memcg_uncharge_kmem(cachep->memcg_params->memcg, nr_pages);
+	atomic_sub(nr_pages, &cachep->memcg_params->nr_pages);
 }
 
 /*
@@ -3240,7 +3328,7 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 		return true;
 	}
 
-	ret = memcg_charge_kmem(memcg, gfp, PAGE_SIZE << order);
+	ret = memcg_charge_kmem(memcg, gfp, 1 << order);
 	if (!ret)
 		*_memcg = memcg;
 
@@ -3257,7 +3345,7 @@ void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
 
 	/* The page allocation failed. Revert */
 	if (!page) {
-		memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
+		memcg_uncharge_kmem(memcg, 1 << order);
 		return;
 	}
 	/*
@@ -3290,7 +3378,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 		return;
 
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
-	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
+	memcg_uncharge_kmem(memcg, 1 << order);
 }
 #else
 static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
@@ -3468,8 +3556,12 @@ static int mem_cgroup_move_parent(struct page *page,
 
 	ret = mem_cgroup_move_account(page, nr_pages,
 				pc, child, parent);
-	if (!ret)
-		__mem_cgroup_cancel_local_charge(child, nr_pages);
+	if (!ret) {
+		/* Take charge off the local counters */
+		page_counter_cancel(&child->memory, nr_pages);
+		if (do_swap_account)
+			page_counter_cancel(&child->memsw, nr_pages);
+	}
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
@@ -3499,7 +3591,7 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
  *
  * Returns 0 on success, -EINVAL on failure.
  *
- * The caller must have charged to @to, IOW, called res_counter_charge() about
+ * The caller must have charged to @to, IOW, called page_counter_charge() about
  * both res and memsw, and called css_get().
  */
 static int mem_cgroup_move_swap_account(swp_entry_t entry,
@@ -3515,7 +3607,7 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 		mem_cgroup_swap_statistics(to, true);
 		/*
 		 * This function is only called from task migration context now.
-		 * It postpones res_counter and refcount handling till the end
+		 * It postpones page_counter and refcount handling till the end
 		 * of task migration(mem_cgroup_clear_mc()) for performance
 		 * improvement. But we cannot postpone css_get(to)  because if
 		 * the process that has been moved to @to does swap-in, the
@@ -3573,49 +3665,42 @@ void mem_cgroup_print_bad_page(struct page *page)
 }
 #endif
 
+static DEFINE_MUTEX(set_limit_mutex);
+
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
-				unsigned long long val)
+				   unsigned long limit)
 {
+	unsigned long curusage;
+	unsigned long oldusage;
+	bool enlarge = false;
 	int retry_count;
-	u64 memswlimit, memlimit;
-	int ret = 0;
-	int children = mem_cgroup_count_children(memcg);
-	u64 curusage, oldusage;
-	int enlarge;
+	int ret;
 
 	/*
 	 * For keeping hierarchical_reclaim simple, how long we should retry
 	 * is depends on callers. We set our retry-count to be function
 	 * of # of children which we should visit in this loop.
 	 */
-	retry_count = MEM_CGROUP_RECLAIM_RETRIES * children;
+	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
+		      mem_cgroup_count_children(memcg);
 
-	oldusage = res_counter_read_u64(&memcg->res, RES_USAGE);
+	oldusage = atomic_long_read(&memcg->memory.count);
 
-	enlarge = 0;
-	while (retry_count) {
+	do {
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
-		/*
-		 * Rather than hide all in some function, I do this in
-		 * open coded manner. You see what this really does.
-		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
-		 */
+
 		mutex_lock(&set_limit_mutex);
-		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-		if (memswlimit < val) {
-			ret = -EINVAL;
+		if (limit > memcg->memsw.limit) {
 			mutex_unlock(&set_limit_mutex);
+			ret = -EINVAL;
 			break;
 		}
-
-		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-		if (memlimit < val)
-			enlarge = 1;
-
-		ret = res_counter_set_limit(&memcg->res, val);
+		if (limit > memcg->memory.limit)
+			enlarge = true;
+		ret = page_counter_limit(&memcg->memory, limit);
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
@@ -3623,13 +3708,14 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 
 		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
 
-		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
+		curusage = atomic_long_read(&memcg->memory.count);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
 			retry_count--;
 		else
 			oldusage = curusage;
-	}
+	} while (retry_count);
+
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
 
@@ -3637,38 +3723,35 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 }
 
 static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
-					unsigned long long val)
+					 unsigned long limit)
 {
+	unsigned long curusage;
+	unsigned long oldusage;
+	bool enlarge = false;
 	int retry_count;
-	u64 memlimit, memswlimit, oldusage, curusage;
-	int children = mem_cgroup_count_children(memcg);
-	int ret = -EBUSY;
-	int enlarge = 0;
+	int ret;
 
 	/* see mem_cgroup_resize_res_limit */
-	retry_count = children * MEM_CGROUP_RECLAIM_RETRIES;
-	oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
-	while (retry_count) {
+	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
+		      mem_cgroup_count_children(memcg);
+
+	oldusage = atomic_long_read(&memcg->memsw.count);
+
+	do {
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
-		/*
-		 * Rather than hide all in some function, I do this in
-		 * open coded manner. You see what this really does.
-		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
-		 */
+
 		mutex_lock(&set_limit_mutex);
-		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-		if (memlimit > val) {
-			ret = -EINVAL;
+		if (limit < memcg->memory.limit) {
 			mutex_unlock(&set_limit_mutex);
+			ret = -EINVAL;
 			break;
 		}
-		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-		if (memswlimit < val)
-			enlarge = 1;
-		ret = res_counter_set_limit(&memcg->memsw, val);
+		if (limit > memcg->memsw.limit)
+			enlarge = true;
+		ret = page_counter_limit(&memcg->memsw, limit);
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
@@ -3676,15 +3759,17 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 
 		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, false);
 
-		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
+		curusage = atomic_long_read(&memcg->memsw.count);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
 			retry_count--;
 		else
 			oldusage = curusage;
-	}
+	} while (retry_count);
+
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
+
 	return ret;
 }
 
@@ -3697,7 +3782,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	unsigned long reclaimed;
 	int loop = 0;
 	struct mem_cgroup_tree_per_zone *mctz;
-	unsigned long long excess;
+	unsigned long excess;
 	unsigned long nr_scanned;
 
 	if (order > 0)
@@ -3751,7 +3836,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 			} while (1);
 		}
 		__mem_cgroup_remove_exceeded(mz, mctz);
-		excess = res_counter_soft_limit_excess(&mz->memcg->res);
+		excess = soft_limit_excess(mz->memcg);
 		/*
 		 * One school of thought says that we should not add
 		 * back the node to the tree if reclaim returns 0.
@@ -3844,7 +3929,6 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 {
 	int node, zid;
-	u64 usage;
 
 	do {
 		/* This is for making all *used* pages to be on LRU. */
@@ -3876,9 +3960,8 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 		 * right after the check. RES_USAGE should be safe as we always
 		 * charge before adding to the LRU.
 		 */
-		usage = res_counter_read_u64(&memcg->res, RES_USAGE) -
-			res_counter_read_u64(&memcg->kmem, RES_USAGE);
-	} while (usage > 0);
+	} while (atomic_long_read(&memcg->memory.count) -
+		 atomic_long_read(&memcg->kmem.count) > 0);
 }
 
 /*
@@ -3918,7 +4001,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 	/* we call try-to-free pages for make this cgroup empty */
 	lru_add_drain_all();
 	/* try to free all pages in this cgroup */
-	while (nr_retries && res_counter_read_u64(&memcg->res, RES_USAGE) > 0) {
+	while (nr_retries && atomic_long_read(&memcg->memory.count)) {
 		int progress;
 
 		if (signal_pending(current))
@@ -3989,8 +4072,8 @@ out:
 	return retval;
 }
 
-static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *memcg,
-					       enum mem_cgroup_stat_index idx)
+static unsigned long tree_stat(struct mem_cgroup *memcg,
+			       enum mem_cgroup_stat_index idx)
 {
 	struct mem_cgroup *iter;
 	long val = 0;
@@ -4008,55 +4091,72 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	u64 val;
 
-	if (!mem_cgroup_is_root(memcg)) {
+	if (mem_cgroup_is_root(memcg)) {
+		val = tree_stat(memcg, MEM_CGROUP_STAT_CACHE);
+		val += tree_stat(memcg, MEM_CGROUP_STAT_RSS);
+		if (swap)
+			val += tree_stat(memcg, MEM_CGROUP_STAT_SWAP);
+	} else {
 		if (!swap)
-			return res_counter_read_u64(&memcg->res, RES_USAGE);
+			val = atomic_long_read(&memcg->memory.count);
 		else
-			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
+			val = atomic_long_read(&memcg->memsw.count);
 	}
-
-	/*
-	 * Transparent hugepages are still accounted for in MEM_CGROUP_STAT_RSS
-	 * as well as in MEM_CGROUP_STAT_RSS_HUGE.
-	 */
-	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
-	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
-
-	if (swap)
-		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAP);
-
 	return val << PAGE_SHIFT;
 }
 
+enum {
+	RES_USAGE,
+	RES_LIMIT,
+	RES_MAX_USAGE,
+	RES_FAILCNT,
+	RES_SOFT_LIMIT,
+};
 
 static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 			       struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	enum res_type type = MEMFILE_TYPE(cft->private);
-	int name = MEMFILE_ATTR(cft->private);
+	struct page_counter *counter;
 
-	switch (type) {
+	switch (MEMFILE_TYPE(cft->private)) {
 	case _MEM:
-		if (name == RES_USAGE)
-			return mem_cgroup_usage(memcg, false);
-		return res_counter_read_u64(&memcg->res, name);
+		counter = &memcg->memory;
+		break;
 	case _MEMSWAP:
-		if (name == RES_USAGE)
-			return mem_cgroup_usage(memcg, true);
-		return res_counter_read_u64(&memcg->memsw, name);
+		counter = &memcg->memsw;
+		break;
 	case _KMEM:
-		return res_counter_read_u64(&memcg->kmem, name);
+		counter = &memcg->kmem;
 		break;
 	default:
 		BUG();
 	}
+
+	switch (MEMFILE_ATTR(cft->private)) {
+	case RES_USAGE:
+		if (counter == &memcg->memory)
+			return mem_cgroup_usage(memcg, false);
+		if (counter == &memcg->memsw)
+			return mem_cgroup_usage(memcg, true);
+		return (u64)atomic_long_read(&counter->count) * PAGE_SIZE;
+	case RES_LIMIT:
+		return (u64)counter->limit * PAGE_SIZE;
+	case RES_MAX_USAGE:
+		return (u64)counter->watermark * PAGE_SIZE;
+	case RES_FAILCNT:
+		return counter->limited;
+	case RES_SOFT_LIMIT:
+		return (u64)memcg->soft_limit * PAGE_SIZE;
+	default:
+		BUG();
+	}
 }
 
 #ifdef CONFIG_MEMCG_KMEM
 /* should be called with activate_kmem_mutex held */
 static int __memcg_activate_kmem(struct mem_cgroup *memcg,
-				 unsigned long long limit)
+				 unsigned long nr_pages)
 {
 	int err = 0;
 	int memcg_id;
@@ -4103,7 +4203,7 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	 * We couldn't have accounted to this cgroup, because it hasn't got the
 	 * active bit set yet, so this should succeed.
 	 */
-	err = res_counter_set_limit(&memcg->kmem, limit);
+	err = page_counter_limit(&memcg->kmem, nr_pages);
 	VM_BUG_ON(err);
 
 	static_key_slow_inc(&memcg_kmem_enabled_key);
@@ -4119,25 +4219,25 @@ out:
 }
 
 static int memcg_activate_kmem(struct mem_cgroup *memcg,
-			       unsigned long long limit)
+			       unsigned long nr_pages)
 {
 	int ret;
 
 	mutex_lock(&activate_kmem_mutex);
-	ret = __memcg_activate_kmem(memcg, limit);
+	ret = __memcg_activate_kmem(memcg, nr_pages);
 	mutex_unlock(&activate_kmem_mutex);
 	return ret;
 }
 
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long long val)
+				   unsigned long limit)
 {
 	int ret;
 
 	if (!memcg_kmem_is_active(memcg))
-		ret = memcg_activate_kmem(memcg, val);
+		ret = memcg_activate_kmem(memcg, limit);
 	else
-		ret = res_counter_set_limit(&memcg->kmem, val);
+		ret = page_counter_limit(&memcg->kmem, limit);
 	return ret;
 }
 
@@ -4155,13 +4255,13 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	 * after this point, because it has at least one child already.
 	 */
 	if (memcg_kmem_is_active(parent))
-		ret = __memcg_activate_kmem(memcg, RES_COUNTER_MAX);
+		ret = __memcg_activate_kmem(memcg, ULONG_MAX);
 	mutex_unlock(&activate_kmem_mutex);
 	return ret;
 }
 #else
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long long val)
+				   unsigned long limit)
 {
 	return -EINVAL;
 }
@@ -4175,110 +4275,69 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
-	enum res_type type;
-	int name;
-	unsigned long long val;
+	unsigned long nr_pages;
 	int ret;
 
 	buf = strstrip(buf);
-	type = MEMFILE_TYPE(of_cft(of)->private);
-	name = MEMFILE_ATTR(of_cft(of)->private);
+	ret = page_counter_memparse(buf, &nr_pages);
+	if (ret)
+		return ret;
 
-	switch (name) {
+	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:
 		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
 			ret = -EINVAL;
 			break;
 		}
-		/* This function does all necessary parse...reuse it */
-		ret = res_counter_memparse_write_strategy(buf, &val);
-		if (ret)
+		switch (MEMFILE_TYPE(of_cft(of)->private)) {
+		case _MEM:
+			ret = mem_cgroup_resize_limit(memcg, nr_pages);
 			break;
-		if (type == _MEM)
-			ret = mem_cgroup_resize_limit(memcg, val);
-		else if (type == _MEMSWAP)
-			ret = mem_cgroup_resize_memsw_limit(memcg, val);
-		else if (type == _KMEM)
-			ret = memcg_update_kmem_limit(memcg, val);
-		else
-			return -EINVAL;
-		break;
-	case RES_SOFT_LIMIT:
-		ret = res_counter_memparse_write_strategy(buf, &val);
-		if (ret)
+		case _MEMSWAP:
+			ret = mem_cgroup_resize_memsw_limit(memcg, nr_pages);
 			break;
-		/*
-		 * For memsw, soft limits are hard to implement in terms
-		 * of semantics, for now, we support soft limits for
-		 * control without swap
-		 */
-		if (type == _MEM)
-			ret = res_counter_set_soft_limit(&memcg->res, val);
-		else
-			ret = -EINVAL;
+		case _KMEM:
+			ret = memcg_update_kmem_limit(memcg, nr_pages);
+			break;
+		}
 		break;
-	default:
-		ret = -EINVAL; /* should be BUG() ? */
+	case RES_SOFT_LIMIT:
+		memcg->soft_limit = nr_pages;
+		ret = 0;
 		break;
 	}
 	return ret ?: nbytes;
 }
 
-static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
-		unsigned long long *mem_limit, unsigned long long *memsw_limit)
-{
-	unsigned long long min_limit, min_memsw_limit, tmp;
-
-	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-	if (!memcg->use_hierarchy)
-		goto out;
-
-	while (memcg->css.parent) {
-		memcg = mem_cgroup_from_css(memcg->css.parent);
-		if (!memcg->use_hierarchy)
-			break;
-		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
-		min_limit = min(min_limit, tmp);
-		tmp = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-		min_memsw_limit = min(min_memsw_limit, tmp);
-	}
-out:
-	*mem_limit = min_limit;
-	*memsw_limit = min_memsw_limit;
-}
-
 static ssize_t mem_cgroup_reset(struct kernfs_open_file *of, char *buf,
 				size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
-	int name;
-	enum res_type type;
+	struct page_counter *counter;
 
-	type = MEMFILE_TYPE(of_cft(of)->private);
-	name = MEMFILE_ATTR(of_cft(of)->private);
+	switch (MEMFILE_TYPE(of_cft(of)->private)) {
+	case _MEM:
+		counter = &memcg->memory;
+		break;
+	case _MEMSWAP:
+		counter = &memcg->memsw;
+		break;
+	case _KMEM:
+		counter = &memcg->kmem;
+		break;
+	default:
+		BUG();
+	}
 
-	switch (name) {
+	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_MAX_USAGE:
-		if (type == _MEM)
-			res_counter_reset_max(&memcg->res);
-		else if (type == _MEMSWAP)
-			res_counter_reset_max(&memcg->memsw);
-		else if (type == _KMEM)
-			res_counter_reset_max(&memcg->kmem);
-		else
-			return -EINVAL;
+		counter->watermark = atomic_long_read(&counter->count);
 		break;
 	case RES_FAILCNT:
-		if (type == _MEM)
-			res_counter_reset_failcnt(&memcg->res);
-		else if (type == _MEMSWAP)
-			res_counter_reset_failcnt(&memcg->memsw);
-		else if (type == _KMEM)
-			res_counter_reset_failcnt(&memcg->kmem);
-		else
-			return -EINVAL;
+		counter->limited = 0;
 		break;
+	default:
+		BUG();
 	}
 
 	return nbytes;
@@ -4375,6 +4434,7 @@ static inline void mem_cgroup_lru_names_not_uptodate(void)
 static int memcg_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long memory, memsw;
 	struct mem_cgroup *mi;
 	unsigned int i;
 
@@ -4394,14 +4454,16 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 			   mem_cgroup_nr_lru_pages(memcg, BIT(i)) * PAGE_SIZE);
 
 	/* Hierarchical information */
-	{
-		unsigned long long limit, memsw_limit;
-		memcg_get_hierarchical_limit(memcg, &limit, &memsw_limit);
-		seq_printf(m, "hierarchical_memory_limit %llu\n", limit);
-		if (do_swap_account)
-			seq_printf(m, "hierarchical_memsw_limit %llu\n",
-				   memsw_limit);
+	memory = memsw = PAGE_COUNTER_MAX;
+	for (mi = memcg; mi; mi = parent_mem_cgroup(mi)) {
+		memory = min(memory, mi->memory.limit);
+		memsw = min(memsw, mi->memsw.limit);
 	}
+	seq_printf(m, "hierarchical_memory_limit %llu\n",
+		   (u64)memory * PAGE_SIZE);
+	if (do_swap_account)
+		seq_printf(m, "hierarchical_memsw_limit %llu\n",
+			   (u64)memsw * PAGE_SIZE);
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		long long val = 0;
@@ -4485,7 +4547,7 @@ static int mem_cgroup_swappiness_write(struct cgroup_subsys_state *css,
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
-	u64 usage;
+	unsigned long usage;
 	int i;
 
 	rcu_read_lock();
@@ -4584,10 +4646,11 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 {
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
-	u64 threshold, usage;
+	unsigned long threshold;
+	unsigned long usage;
 	int i, size, ret;
 
-	ret = res_counter_memparse_write_strategy(args, &threshold);
+	ret = page_counter_memparse(args, &threshold);
 	if (ret)
 		return ret;
 
@@ -4677,7 +4740,7 @@ static void __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
 {
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
-	u64 usage;
+	unsigned long usage;
 	int i, j, size;
 
 	mutex_lock(&memcg->thresholds_lock);
@@ -4871,7 +4934,7 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 
 	memcg_kmem_mark_dead(memcg);
 
-	if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
+	if (atomic_long_read(&memcg->kmem.count))
 		return;
 
 	if (memcg_kmem_test_and_clear_dead(memcg))
@@ -5351,9 +5414,9 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
  */
 struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 {
-	if (!memcg->res.parent)
+	if (!memcg->memory.parent)
 		return NULL;
-	return mem_cgroup_from_res_counter(memcg->res.parent, res);
+	return mem_cgroup_from_counter(memcg->memory.parent, memory);
 }
 EXPORT_SYMBOL(parent_mem_cgroup);
 
@@ -5398,9 +5461,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	/* root ? */
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
-		res_counter_init(&memcg->res, NULL);
-		res_counter_init(&memcg->memsw, NULL);
-		res_counter_init(&memcg->kmem, NULL);
+		page_counter_init(&memcg->memory, NULL);
+		page_counter_init(&memcg->memsw, NULL);
+		page_counter_init(&memcg->kmem, NULL);
 	}
 
 	memcg->last_scanned_node = MAX_NUMNODES;
@@ -5438,18 +5501,18 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	memcg->swappiness = mem_cgroup_swappiness(parent);
 
 	if (parent->use_hierarchy) {
-		res_counter_init(&memcg->res, &parent->res);
-		res_counter_init(&memcg->memsw, &parent->memsw);
-		res_counter_init(&memcg->kmem, &parent->kmem);
+		page_counter_init(&memcg->memory, &parent->memory);
+		page_counter_init(&memcg->memsw, &parent->memsw);
+		page_counter_init(&memcg->kmem, &parent->kmem);
 
 		/*
 		 * No need to take a reference to the parent because cgroup
 		 * core guarantees its existence.
 		 */
 	} else {
-		res_counter_init(&memcg->res, NULL);
-		res_counter_init(&memcg->memsw, NULL);
-		res_counter_init(&memcg->kmem, NULL);
+		page_counter_init(&memcg->memory, NULL);
+		page_counter_init(&memcg->memsw, NULL);
+		page_counter_init(&memcg->kmem, NULL);
 		/*
 		 * Deeper hierachy with use_hierarchy == false doesn't make
 		 * much sense so let cgroup subsystem know about this
@@ -5520,7 +5583,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	/*
 	 * XXX: css_offline() would be where we should reparent all
 	 * memory to prepare the cgroup for destruction.  However,
-	 * memcg does not do css_tryget_online() and res_counter charging
+	 * memcg does not do css_tryget_online() and page_counter charging
 	 * under the same RCU lock region, which means that charging
 	 * could race with offlining.  Offlining only happens to
 	 * cgroups with no tasks in them but charges can show up
@@ -5540,7 +5603,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	 * call_rcu()
 	 *   offline_css()
 	 *     reparent_charges()
-	 *                           res_counter_charge()
+	 *                           page_counter_charge()
 	 *                           css_put()
 	 *                             css_free()
 	 *                           pc->mem_cgroup = dead memcg
@@ -5575,10 +5638,10 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-	mem_cgroup_resize_limit(memcg, ULLONG_MAX);
-	mem_cgroup_resize_memsw_limit(memcg, ULLONG_MAX);
-	memcg_update_kmem_limit(memcg, ULLONG_MAX);
-	res_counter_set_soft_limit(&memcg->res, ULLONG_MAX);
+	mem_cgroup_resize_limit(memcg, PAGE_COUNTER_MAX);
+	mem_cgroup_resize_memsw_limit(memcg, PAGE_COUNTER_MAX);
+	memcg_update_kmem_limit(memcg, PAGE_COUNTER_MAX);
+	memcg->soft_limit = 0;
 }
 
 #ifdef CONFIG_MMU
@@ -5892,19 +5955,18 @@ static void __mem_cgroup_clear_mc(void)
 	if (mc.moved_swap) {
 		/* uncharge swap account from the old cgroup */
 		if (!mem_cgroup_is_root(mc.from))
-			res_counter_uncharge(&mc.from->memsw,
-					     PAGE_SIZE * mc.moved_swap);
-
-		for (i = 0; i < mc.moved_swap; i++)
-			css_put(&mc.from->css);
+			page_counter_uncharge(&mc.from->memsw, mc.moved_swap);
 
 		/*
-		 * we charged both to->res and to->memsw, so we should
-		 * uncharge to->res.
+		 * we charged both to->memory and to->memsw, so we
+		 * should uncharge to->memory.
 		 */
 		if (!mem_cgroup_is_root(mc.to))
-			res_counter_uncharge(&mc.to->res,
-					     PAGE_SIZE * mc.moved_swap);
+			page_counter_uncharge(&mc.to->memory, mc.moved_swap);
+
+		for (i = 0; i < mc.moved_swap; i++)
+			css_put(&mc.from->css);
+
 		/* we've already done css_get(mc.to) */
 		mc.moved_swap = 0;
 	}
@@ -6270,7 +6332,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 	memcg = mem_cgroup_lookup(id);
 	if (memcg) {
 		if (!mem_cgroup_is_root(memcg))
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			page_counter_uncharge(&memcg->memsw, 1);
 		mem_cgroup_swap_statistics(memcg, false);
 		css_put(&memcg->css);
 	}
@@ -6436,11 +6498,9 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 
 	if (!mem_cgroup_is_root(memcg)) {
 		if (nr_mem)
-			res_counter_uncharge(&memcg->res,
-					     nr_mem * PAGE_SIZE);
+			page_counter_uncharge(&memcg->memory, nr_mem);
 		if (nr_memsw)
-			res_counter_uncharge(&memcg->memsw,
-					     nr_memsw * PAGE_SIZE);
+			page_counter_uncharge(&memcg->memsw, nr_memsw);
 		memcg_oom_recover(memcg);
 	}
 
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 1d191357bf88..9a448bdb19e9 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -9,13 +9,13 @@
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	/*
-	 * The root cgroup does not use res_counters, but rather,
+	 * The root cgroup does not use page_counters, but rather,
 	 * rely on the data already collected by the network
 	 * subsystem
 	 */
-	struct res_counter *res_parent = NULL;
-	struct cg_proto *cg_proto, *parent_cg;
 	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+	struct page_counter *counter_parent = NULL;
+	struct cg_proto *cg_proto, *parent_cg;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
@@ -29,9 +29,9 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 
 	parent_cg = tcp_prot.proto_cgroup(parent);
 	if (parent_cg)
-		res_parent = &parent_cg->memory_allocated;
+		counter_parent = &parent_cg->memory_allocated;
 
-	res_counter_init(&cg_proto->memory_allocated, res_parent);
+	page_counter_init(&cg_proto->memory_allocated, counter_parent);
 	percpu_counter_init(&cg_proto->sockets_allocated, 0, GFP_KERNEL);
 
 	return 0;
@@ -50,7 +50,7 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(tcp_destroy_cgroup);
 
-static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
+static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 {
 	struct cg_proto *cg_proto;
 	int i;
@@ -60,20 +60,17 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 	if (!cg_proto)
 		return -EINVAL;
 
-	if (val > RES_COUNTER_MAX)
-		val = RES_COUNTER_MAX;
-
-	ret = res_counter_set_limit(&cg_proto->memory_allocated, val);
+	ret = page_counter_limit(&cg_proto->memory_allocated, nr_pages);
 	if (ret)
 		return ret;
 
 	for (i = 0; i < 3; i++)
-		cg_proto->sysctl_mem[i] = min_t(long, val >> PAGE_SHIFT,
+		cg_proto->sysctl_mem[i] = min_t(long, nr_pages,
 						sysctl_tcp_mem[i]);
 
-	if (val == RES_COUNTER_MAX)
+	if (nr_pages == ULONG_MAX / PAGE_SIZE)
 		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
-	else if (val != RES_COUNTER_MAX) {
+	else {
 		/*
 		 * The active bit needs to be written after the static_key
 		 * update. This is what guarantees that the socket activation
@@ -102,11 +99,18 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 	return 0;
 }
 
+enum {
+	RES_USAGE,
+	RES_LIMIT,
+	RES_MAX_USAGE,
+	RES_FAILCNT,
+};
+
 static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
-	unsigned long long val;
+	unsigned long nr_pages;
 	int ret = 0;
 
 	buf = strstrip(buf);
@@ -114,10 +118,10 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 	switch (of_cft(of)->private) {
 	case RES_LIMIT:
 		/* see memcontrol.c */
-		ret = res_counter_memparse_write_strategy(buf, &val);
+		ret = page_counter_memparse(buf, &nr_pages);
 		if (ret)
 			break;
-		ret = tcp_update_limit(memcg, val);
+		ret = tcp_update_limit(memcg, nr_pages);
 		break;
 	default:
 		ret = -EINVAL;
@@ -126,43 +130,35 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 	return ret ?: nbytes;
 }
 
-static u64 tcp_read_stat(struct mem_cgroup *memcg, int type, u64 default_val)
-{
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return default_val;
-
-	return res_counter_read_u64(&cg_proto->memory_allocated, type);
-}
-
-static u64 tcp_read_usage(struct mem_cgroup *memcg)
-{
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
-
-	return res_counter_read_u64(&cg_proto->memory_allocated, RES_USAGE);
-}
-
 static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct cg_proto *cg_proto = tcp_prot.proto_cgroup(memcg);
 	u64 val;
 
 	switch (cft->private) {
 	case RES_LIMIT:
-		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
+		if (!cg_proto)
+			return PAGE_COUNTER_MAX;
+		val = cg_proto->memory_allocated.limit;
+		val *= PAGE_SIZE;
 		break;
 	case RES_USAGE:
-		val = tcp_read_usage(memcg);
+		if (!cg_proto)
+			return atomic_long_read(&tcp_memory_allocated);
+		val = atomic_long_read(&cg_proto->memory_allocated.count);
+		val *= PAGE_SIZE;
 		break;
 	case RES_FAILCNT:
+		if (!cg_proto)
+			return 0;
+		val = cg_proto->memory_allocated.limited;
+		break;
 	case RES_MAX_USAGE:
-		val = tcp_read_stat(memcg, cft->private, 0);
+		if (!cg_proto)
+			return 0;
+		val = cg_proto->memory_allocated.watermark;
+		val *= PAGE_SIZE;
 		break;
 	default:
 		BUG();
@@ -183,10 +179,11 @@ static ssize_t tcp_cgroup_reset(struct kernfs_open_file *of,
 
 	switch (of_cft(of)->private) {
 	case RES_MAX_USAGE:
-		res_counter_reset_max(&cg_proto->memory_allocated);
+		cg_proto->memory_allocated.watermark =
+			atomic_long_read(&cg_proto->memory_allocated.count);
 		break;
 	case RES_FAILCNT:
-		res_counter_reset_failcnt(&cg_proto->memory_allocated);
+		cg_proto->memory_allocated.limited = 0;
 		break;
 	}
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
