Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED4986B007E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:17 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 06/11] vfs: Implement generic per-cpu counters for delayed allocation
Date: Mon, 15 Jun 2009 19:59:53 +0200
Message-Id: <1245088797-29533-7-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Implement free blocks and reserved blocks counters for delayed
allocation. These counters are reliable in the sence that when
they return success, the subsequent conversion from reserved to
allocated blocks always succeeds (see comments in the code for
details). This is useful for ext? based filesystems to implement
delayed allocation in particular for allocation in page_mkwrite.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/Kconfig                       |    4 ++
 fs/Makefile                      |    1 +
 fs/delalloc_counter.c            |  109 ++++++++++++++++++++++++++++++++++++++
 fs/ext3/Kconfig                  |    1 +
 include/linux/delalloc_counter.h |   63 ++++++++++++++++++++++
 5 files changed, 178 insertions(+), 0 deletions(-)
 create mode 100644 fs/delalloc_counter.c
 create mode 100644 include/linux/delalloc_counter.h

diff --git a/fs/Kconfig b/fs/Kconfig
index 525da2e..82882b9 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -19,6 +19,10 @@ config FS_XIP
 source "fs/jbd/Kconfig"
 source "fs/jbd2/Kconfig"
 
+config DELALLOC_COUNTER
+	bool
+	default y if EXT3_FS=y
+
 config FS_MBCACHE
 # Meta block cache for Extended Attributes (ext2/ext3/ext4)
 	tristate
diff --git a/fs/Makefile b/fs/Makefile
index af6d047..b5614fc 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -19,6 +19,7 @@ else
 obj-y +=	no-block.o
 endif
 
+obj-$(CONFIG_DELALLOC_COUNTER)	+= delalloc_counter.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY) += bio-integrity.o
 obj-y				+= notify/
 obj-$(CONFIG_EPOLL)		+= eventpoll.o
diff --git a/fs/delalloc_counter.c b/fs/delalloc_counter.c
new file mode 100644
index 0000000..0f575d5
--- /dev/null
+++ b/fs/delalloc_counter.c
@@ -0,0 +1,109 @@
+/*
+ *  Per-cpu counters for delayed allocation
+ */
+#include <linux/percpu_counter.h>
+#include <linux/delalloc_counter.h>
+#include <linux/module.h>
+#include <linux/log2.h>
+
+static long dac_error(struct delalloc_counter *c)
+{
+#ifdef CONFIG_SMP
+	return c->batch * nr_cpu_ids;
+#else
+	return 0;
+#endif
+}
+
+/*
+ * Reserve blocks for delayed allocation
+ *
+ * This code is subtle because we want to avoid synchronization of processes
+ * doing allocation in the common case when there's plenty of space in the
+ * filesystem.
+ *
+ * The code maintains the following property: Among all the calls to
+ * dac_reserve() that return 0 there exists a simple sequential ordering of
+ * these calls such that the check (free - reserved >= limit) in each call
+ * succeeds. This guarantees that we never reserve blocks we don't have.
+ *
+ * The proof of the above invariant: The function can return 0 either when the
+ * first if succeeds or when both ifs fail. To the first type of callers we
+ * assign the time of read of c->reserved in the first if, to the second type
+ * of callers we assign the time of read of c->reserved in the second if. We
+ * order callers by their assigned time and claim that this is the ordering
+ * required by the invariant. Suppose that a check (free - reserved >= limit)
+ * fails for caller C in the proposed ordering. We distinguish two cases:
+ * 1) function called by C returned zero because the first if succeeded - in
+ *  this case reads of counters in the first if must have seen effects of
+ *  __percpu_counter_add of all the callers before C (even their condition
+ *  evaluation happened before our). The errors accumulated in cpu-local
+ *  variables are clearly < dac_error(c) and thus the condition should fail.
+ *  Contradiction.
+ * 2) function called by C returned zero because the second if failed - again
+ *  the read of the counters must have seen effects of __percpu_counter_add of
+ *  all the callers before C and thus the condition should have succeeded.
+ *  Contradiction.
+ */
+int dac_reserve(struct delalloc_counter *c, s32 amount, s64 limit)
+{
+	s64 free, reserved;
+	int ret = 0;
+
+	__percpu_counter_add(&c->reserved, amount, c->batch);
+	/*
+	 * This barrier makes sure that when effects of the following read of
+	 * c->reserved are observable by another CPU also effects of the
+	 * previous store to c->reserved are seen.
+	 */
+	smp_mb();
+	if (percpu_counter_read(&c->free) - percpu_counter_read(&c->reserved)
+	    - 2 * dac_error(c) >= limit)
+		return ret;
+	/*
+	 * Near the limit - sum the counter to avoid returning ENOSPC too
+	 * early. Note that we can still "unnecessarily" return ENOSPC when
+	 * there are several racing writers. Spinlock in this section would
+	 * solve it but let's ignore it for now.
+	 */
+	free = percpu_counter_sum_positive(&c->free);
+	reserved = percpu_counter_sum_positive(&c->reserved);
+	if (free - reserved < limit) {
+		__percpu_counter_add(&c->reserved, -amount, c->batch);
+		ret = -ENOSPC;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(dac_reserve);
+
+/* Account reserved blocks as allocated */
+void dac_alloc_reserved(struct delalloc_counter *c, s32 amount)
+{
+	__percpu_counter_add(&c->free, -amount, c->batch);
+	/*
+	 * Make sure update of free counter is seen before update of
+	 * reserved counter.
+	 */
+	smp_wmb();
+	__percpu_counter_add(&c->reserved, -amount, c->batch);
+}
+EXPORT_SYMBOL(dac_alloc_reserved);
+
+int dac_init(struct delalloc_counter *c, s64 amount)
+{
+	int err;
+
+	c->batch = 8*(1+ilog2(nr_cpu_ids));
+	err = percpu_counter_init(&c->free, amount);
+	if (!err)
+		err = percpu_counter_init(&c->reserved, 0);
+	return err;
+}
+EXPORT_SYMBOL(dac_init);
+
+void dac_destroy(struct delalloc_counter *c)
+{
+	percpu_counter_destroy(&c->free);
+	percpu_counter_destroy(&c->reserved);
+}
+EXPORT_SYMBOL(dac_destroy);
diff --git a/fs/ext3/Kconfig b/fs/ext3/Kconfig
index fb3c1a2..f4e122f 100644
--- a/fs/ext3/Kconfig
+++ b/fs/ext3/Kconfig
@@ -1,6 +1,7 @@
 config EXT3_FS
 	tristate "Ext3 journalling file system support"
 	select JBD
+	select DELALLOC_COUNTER
 	help
 	  This is the journalling version of the Second extended file system
 	  (often called ext3), the de facto standard Linux file system
diff --git a/include/linux/delalloc_counter.h b/include/linux/delalloc_counter.h
new file mode 100644
index 0000000..9d00b6c
--- /dev/null
+++ b/include/linux/delalloc_counter.h
@@ -0,0 +1,63 @@
+#ifndef _LINUX_DELALLOC_COUNTER_H
+#define _LINUX_DELALLOC_COUNTER_H
+
+#include <linux/percpu_counter.h>
+
+struct delalloc_counter {
+	struct percpu_counter free;
+	struct percpu_counter reserved;
+	int batch;
+};
+
+int dac_reserve(struct delalloc_counter *c, s32 amount, s64 limit);
+void dac_alloc_reserved(struct delalloc_counter *c, s32 amount);
+
+static inline int dac_alloc(struct delalloc_counter *c, s32 amount, s64 limit)
+{
+	int ret = dac_reserve(c, amount, limit);
+	if (!ret)
+		dac_alloc_reserved(c, amount);
+	return ret;
+}
+
+static inline void dac_free(struct delalloc_counter *c, s32 amount)
+{
+        __percpu_counter_add(&c->free, amount, c->batch);
+}
+
+static inline void dac_cancel_reserved(struct delalloc_counter *c, s32 amount)
+{
+        __percpu_counter_add(&c->reserved, -amount, c->batch);
+}
+
+int dac_init(struct delalloc_counter *c, s64 amount);
+void dac_destroy(struct delalloc_counter *c);
+
+static inline s64 dac_get_avail(struct delalloc_counter *c)
+{
+	s64 ret = percpu_counter_read(&c->free) -
+	       percpu_counter_read(&c->reserved);
+	if (ret < 0)
+		return 0;
+	return ret;
+}
+
+static inline s64 dac_get_avail_sum(struct delalloc_counter *c)
+{
+	s64 ret = percpu_counter_sum(&c->free) -
+	       percpu_counter_sum(&c->reserved);
+	if (ret < 0)
+		return 0;
+	return ret;
+}
+
+static inline s64 dac_get_reserved(struct delalloc_counter *c)
+{
+	return percpu_counter_read_positive(&c->reserved);
+}
+
+static inline s64 dac_get_reserved_sum(struct delalloc_counter *c)
+{
+	return percpu_counter_sum_positive(&c->reserved);
+}
+#endif
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
