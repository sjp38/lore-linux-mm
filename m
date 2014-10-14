Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id B86226B0070
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 21:46:21 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id q1so7681690lam.36
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 18:46:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id wb3si4567872lbb.112.2014.10.13.18.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Oct 2014 18:46:19 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] kernel: res_counter: remove the unused API
Date: Mon, 13 Oct 2014 21:46:03 -0400
Message-Id: <1413251163-8517-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1413251163-8517-1-git-send-email-hannes@cmpxchg.org>
References: <1413251163-8517-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

All memory accounting and limiting has been switched over to the
lockless page counters.  Bye, res_counter!

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vladimir Davydov <vdavydov@parallels.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 Documentation/cgroups/resource_counter.txt | 197 -------------------------
 include/linux/res_counter.h                | 223 -----------------------------
 init/Kconfig                               |   6 -
 kernel/Makefile                            |   1 -
 kernel/res_counter.c                       | 211 ---------------------------
 5 files changed, 638 deletions(-)
 delete mode 100644 Documentation/cgroups/resource_counter.txt
 delete mode 100644 include/linux/res_counter.h
 delete mode 100644 kernel/res_counter.c

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
diff --git a/init/Kconfig b/init/Kconfig
index d07a1c78d4e7..2229611528db 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -979,12 +979,6 @@ config CGROUP_CPUACCT
 	  Provides a simple Resource Controller for monitoring the
 	  total CPU consumed by the tasks in a cgroup.
 
-config RESOURCE_COUNTERS
-	bool "Resource counters"
-	help
-	  This option enables controller independent resource accounting
-	  infrastructure that works with cgroups.
-
 config PAGE_COUNTER
        bool
 
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
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
