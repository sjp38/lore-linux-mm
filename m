Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 68A3F6B0027
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 09:01:50 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 13 Apr 2013 22:52:55 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0A0562BB0050
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 23:01:46 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3DCmDcL65470600
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 22:48:13 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3DD1d6c019344
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 23:01:39 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH PART3 v4 1/6] staging: ramster: Move debugfs code out of ramster.c file
Date: Sat, 13 Apr 2013 21:01:27 +0800
Message-Id: <1365858092-21920-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365858092-21920-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365858092-21920-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Note that at this point there is no CONFIG_RAMSTER_DEBUG
option in the Kconfig. So in effect all of the counters
are nop until that option gets introduced in patch:
ramster/debug: Add CONFIG_RAMSTER_DEBUG Kconfig entry

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/Makefile          |    1 +
 drivers/staging/zcache/ramster/debug.c   |   70 ++++++++++++++++++
 drivers/staging/zcache/ramster/debug.h   |   78 ++++++++++++++++++++
 drivers/staging/zcache/ramster/ramster.c |  115 ++----------------------------
 4 files changed, 154 insertions(+), 110 deletions(-)
 create mode 100644 drivers/staging/zcache/ramster/debug.c
 create mode 100644 drivers/staging/zcache/ramster/debug.h

diff --git a/drivers/staging/zcache/Makefile b/drivers/staging/zcache/Makefile
index 24fd6aa..4956fa0 100644
--- a/drivers/staging/zcache/Makefile
+++ b/drivers/staging/zcache/Makefile
@@ -1,5 +1,6 @@
 zcache-y	:=		zcache-main.o tmem.o zbud.o
 zcache-$(CONFIG_ZCACHE_DEBUG) += debug.o
+zcache-$(CONFIG_RAMSTER) += ramster/debug.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/ramster.o ramster/r2net.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/nodemanager.o ramster/tcp.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/heartbeat.o ramster/masklog.o
diff --git a/drivers/staging/zcache/ramster/debug.c b/drivers/staging/zcache/ramster/debug.c
new file mode 100644
index 0000000..76861e4
--- /dev/null
+++ b/drivers/staging/zcache/ramster/debug.c
@@ -0,0 +1,70 @@
+#include <linux/atomic.h>
+#include "debug.h"
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#define zdfs    debugfs_create_size_t
+#define zdfs64  debugfs_create_u64
+
+ssize_t ramster_eph_pages_remoted;
+ssize_t ramster_pers_pages_remoted;
+ssize_t ramster_eph_pages_remote_failed;
+ssize_t ramster_pers_pages_remote_failed;
+ssize_t ramster_remote_eph_pages_succ_get;
+ssize_t ramster_remote_pers_pages_succ_get;
+ssize_t ramster_remote_eph_pages_unsucc_get;
+ssize_t ramster_remote_pers_pages_unsucc_get;
+ssize_t ramster_pers_pages_remote_nomem;
+ssize_t ramster_remote_objects_flushed;
+ssize_t ramster_remote_object_flushes_failed;
+ssize_t ramster_remote_pages_flushed;
+ssize_t ramster_remote_page_flushes_failed;
+
+int __init ramster_debugfs_init(void)
+{
+	struct dentry *root = debugfs_create_dir("ramster", NULL);
+	if (root == NULL)
+		return -ENXIO;
+
+	zdfs("eph_pages_remoted", S_IRUGO, root, &ramster_eph_pages_remoted);
+	zdfs("pers_pages_remoted", S_IRUGO, root, &ramster_pers_pages_remoted);
+	zdfs("eph_pages_remote_failed", S_IRUGO, root,
+		&ramster_eph_pages_remote_failed);
+	zdfs("pers_pages_remote_failed", S_IRUGO, root,
+		&ramster_pers_pages_remote_failed);
+	zdfs("remote_eph_pages_succ_get", S_IRUGO, root,
+		&ramster_remote_eph_pages_succ_get);
+	zdfs("remote_pers_pages_succ_get", S_IRUGO, root,
+		&ramster_remote_pers_pages_succ_get);
+	zdfs("remote_eph_pages_unsucc_get", S_IRUGO, root,
+		&ramster_remote_eph_pages_unsucc_get);
+	zdfs("remote_pers_pages_unsucc_get", S_IRUGO, root,
+		&ramster_remote_pers_pages_unsucc_get);
+	zdfs("pers_pages_remote_nomem", S_IRUGO, root,
+		&ramster_pers_pages_remote_nomem);
+	zdfs("remote_objects_flushed", S_IRUGO, root,
+		&ramster_remote_objects_flushed);
+	zdfs("remote_pages_flushed", S_IRUGO, root,
+		&ramster_remote_pages_flushed);
+	zdfs("remote_object_flushes_failed", S_IRUGO, root,
+		&ramster_remote_object_flushes_failed);
+	zdfs("remote_page_flushes_failed", S_IRUGO, root,
+		&ramster_remote_page_flushes_failed);
+	zdfs("foreign_eph_pages", S_IRUGO, root,
+		&ramster_foreign_eph_pages);
+	zdfs("foreign_eph_pages_max", S_IRUGO, root,
+		&ramster_foreign_eph_pages_max);
+	zdfs("foreign_pers_pages", S_IRUGO, root,
+		&ramster_foreign_pers_pages);
+	zdfs("foreign_pers_pages_max", S_IRUGO, root,
+		&ramster_foreign_pers_pages_max);
+	return 0;
+}
+#undef  zdebugfs
+#undef  zdfs64
+#else
+static inline int ramster_debugfs_init(void)
+{
+	return 0;
+}
+#endif
diff --git a/drivers/staging/zcache/ramster/debug.h b/drivers/staging/zcache/ramster/debug.h
new file mode 100644
index 0000000..3f608b7
--- /dev/null
+++ b/drivers/staging/zcache/ramster/debug.h
@@ -0,0 +1,78 @@
+#include <linux/bug.h>
+
+#ifdef CONFIG_RAMSTER
+
+extern long ramster_flnodes;
+static atomic_t ramster_flnodes_atomic = ATOMIC_INIT(0);
+static unsigned long ramster_flnodes_max;
+static inline void inc_ramster_flnodes(void)
+{
+	ramster_flnodes = atomic_inc_return(&ramster_flnodes_atomic);
+	if (ramster_flnodes > ramster_flnodes_max)
+		ramster_flnodes_max = ramster_flnodes;
+}
+static inline void dec_ramster_flnodes(void)
+{
+	ramster_flnodes = atomic_dec_return(&ramster_flnodes_atomic);
+}
+extern ssize_t ramster_foreign_eph_pages;
+static atomic_t ramster_foreign_eph_pages_atomic = ATOMIC_INIT(0);
+static ssize_t ramster_foreign_eph_pages_max;
+static inline void inc_ramster_foreign_eph_pages(void)
+{
+	ramster_foreign_eph_pages = atomic_inc_return(
+		&ramster_foreign_eph_pages_atomic);
+	if (ramster_foreign_eph_pages > ramster_foreign_eph_pages_max)
+		ramster_foreign_eph_pages_max = ramster_foreign_eph_pages;
+}
+static inline void dec_ramster_foreign_eph_pages(void)
+{
+	ramster_foreign_eph_pages = atomic_dec_return(
+		&ramster_foreign_eph_pages_atomic);
+}
+extern ssize_t ramster_foreign_pers_pages;
+static atomic_t ramster_foreign_pers_pages_atomic = ATOMIC_INIT(0);
+static ssize_t ramster_foreign_pers_pages_max;
+static inline void inc_ramster_foreign_pers_pages(void)
+{
+	ramster_foreign_pers_pages = atomic_inc_return(
+		&ramster_foreign_pers_pages_atomic);
+	if (ramster_foreign_pers_pages > ramster_foreign_pers_pages_max)
+		ramster_foreign_pers_pages_max = ramster_foreign_pers_pages;
+}
+static inline void dec_ramster_foreign_pers_pages(void)
+{
+	ramster_foreign_pers_pages = atomic_dec_return(
+		&ramster_foreign_pers_pages_atomic);
+}
+
+extern ssize_t ramster_eph_pages_remoted;
+extern ssize_t ramster_pers_pages_remoted;
+extern ssize_t ramster_eph_pages_remote_failed;
+extern ssize_t ramster_pers_pages_remote_failed;
+extern ssize_t ramster_remote_eph_pages_succ_get;
+extern ssize_t ramster_remote_pers_pages_succ_get;
+extern ssize_t ramster_remote_eph_pages_unsucc_get;
+extern ssize_t ramster_remote_pers_pages_unsucc_get;
+extern ssize_t ramster_pers_pages_remote_nomem;
+extern ssize_t ramster_remote_objects_flushed;
+extern ssize_t ramster_remote_object_flushes_failed;
+extern ssize_t ramster_remote_pages_flushed;
+extern ssize_t ramster_remote_page_flushes_failed;
+
+int ramster_debugfs_init(void);
+
+#else
+
+static inline void inc_ramster_flnodes(void) { };
+static inline void dec_ramster_flnodes(void) { };
+static inline void inc_ramster_foreign_eph_pages(void) { };
+static inline void dec_ramster_foreign_eph_pages(void) { };
+static inline void inc_ramster_foreign_pers_pages(void) { };
+static inline void dec_ramster_foreign_pers_pages(void) { };
+
+static inline int ramster_debugfs_init(void)
+{
+	return 0;
+}
+#endif
diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging/zcache/ramster/ramster.c
index 444189e..1d29f5b 100644
--- a/drivers/staging/zcache/ramster/ramster.c
+++ b/drivers/staging/zcache/ramster/ramster.c
@@ -42,6 +42,7 @@
 #include "ramster.h"
 #include "ramster_nodemanager.h"
 #include "tcp.h"
+#include "debug.h"
 
 #define RAMSTER_TESTING
 
@@ -63,118 +64,12 @@ static atomic_t ramster_remote_pers_pages = ATOMIC_INIT(0);
 static bool ramster_nodes_manual_up[MANUAL_NODES] __read_mostly;
 static int ramster_remote_target_nodenum __read_mostly = -1;
 
-/* these counters are made available via debugfs */
-static long ramster_flnodes;
-static atomic_t ramster_flnodes_atomic = ATOMIC_INIT(0);
-static unsigned long ramster_flnodes_max;
-static inline void inc_ramster_flnodes(void)
-{
-	ramster_flnodes = atomic_inc_return(&ramster_flnodes_atomic);
-	if (ramster_flnodes > ramster_flnodes_max)
-		ramster_flnodes_max = ramster_flnodes;
-}
-static inline void dec_ramster_flnodes(void)
-{
-	ramster_flnodes = atomic_dec_return(&ramster_flnodes_atomic);
-}
-static ssize_t ramster_foreign_eph_pages;
-static atomic_t ramster_foreign_eph_pages_atomic = ATOMIC_INIT(0);
-static ssize_t ramster_foreign_eph_pages_max;
-static inline void inc_ramster_foreign_eph_pages(void)
-{
-	ramster_foreign_eph_pages = atomic_inc_return(
-			&ramster_foreign_eph_pages_atomic);
-	if (ramster_foreign_eph_pages > ramster_foreign_eph_pages_max)
-		ramster_foreign_eph_pages_max = ramster_foreign_eph_pages;
-}
-static inline void dec_ramster_foreign_eph_pages(void)
-{
-	ramster_foreign_eph_pages = atomic_dec_return(
-			&ramster_foreign_eph_pages_atomic);
-}
-static ssize_t ramster_foreign_pers_pages;
-static atomic_t ramster_foreign_pers_pages_atomic = ATOMIC_INIT(0);
-static ssize_t ramster_foreign_pers_pages_max;
-static inline void inc_ramster_foreign_pers_pages(void)
-{
-	ramster_foreign_pers_pages = atomic_inc_return(
-		&ramster_foreign_pers_pages_atomic);
-	if (ramster_foreign_pers_pages > ramster_foreign_pers_pages_max)
-		ramster_foreign_pers_pages_max = ramster_foreign_pers_pages;
-}
-static inline void dec_ramster_foreign_pers_pages(void)
-{
-	ramster_foreign_pers_pages = atomic_dec_return(
-		&ramster_foreign_pers_pages_atomic);
-}
-static ssize_t ramster_eph_pages_remoted;
-static ssize_t ramster_pers_pages_remoted;
-static ssize_t ramster_eph_pages_remote_failed;
-static ssize_t ramster_pers_pages_remote_failed;
-static ssize_t ramster_remote_eph_pages_succ_get;
-static ssize_t ramster_remote_pers_pages_succ_get;
-static ssize_t ramster_remote_eph_pages_unsucc_get;
-static ssize_t ramster_remote_pers_pages_unsucc_get;
-static ssize_t ramster_pers_pages_remote_nomem;
-static ssize_t ramster_remote_objects_flushed;
-static ssize_t ramster_remote_object_flushes_failed;
-static ssize_t ramster_remote_pages_flushed;
-static ssize_t ramster_remote_page_flushes_failed;
+/* Used by this code. */
+long ramster_flnodes;
+ssize_t ramster_foreign_eph_pages;
+ssize_t ramster_foreign_pers_pages;
 /* FIXME frontswap selfshrinking knobs in debugfs? */
 
-#ifdef CONFIG_DEBUG_FS
-#include <linux/debugfs.h>
-#define	zdfs	debugfs_create_size_t
-#define	zdfs64	debugfs_create_u64
-static int __init ramster_debugfs_init(void)
-{
-	struct dentry *root = debugfs_create_dir("ramster", NULL);
-	if (root == NULL)
-		return -ENXIO;
-
-	zdfs("eph_pages_remoted", S_IRUGO, root, &ramster_eph_pages_remoted);
-	zdfs("pers_pages_remoted", S_IRUGO, root, &ramster_pers_pages_remoted);
-	zdfs("eph_pages_remote_failed", S_IRUGO, root,
-			&ramster_eph_pages_remote_failed);
-	zdfs("pers_pages_remote_failed", S_IRUGO, root,
-			&ramster_pers_pages_remote_failed);
-	zdfs("remote_eph_pages_succ_get", S_IRUGO, root,
-			&ramster_remote_eph_pages_succ_get);
-	zdfs("remote_pers_pages_succ_get", S_IRUGO, root,
-			&ramster_remote_pers_pages_succ_get);
-	zdfs("remote_eph_pages_unsucc_get", S_IRUGO, root,
-			&ramster_remote_eph_pages_unsucc_get);
-	zdfs("remote_pers_pages_unsucc_get", S_IRUGO, root,
-			&ramster_remote_pers_pages_unsucc_get);
-	zdfs("pers_pages_remote_nomem", S_IRUGO, root,
-			&ramster_pers_pages_remote_nomem);
-	zdfs("remote_objects_flushed", S_IRUGO, root,
-			&ramster_remote_objects_flushed);
-	zdfs("remote_pages_flushed", S_IRUGO, root,
-			&ramster_remote_pages_flushed);
-	zdfs("remote_object_flushes_failed", S_IRUGO, root,
-			&ramster_remote_object_flushes_failed);
-	zdfs("remote_page_flushes_failed", S_IRUGO, root,
-			&ramster_remote_page_flushes_failed);
-	zdfs("foreign_eph_pages", S_IRUGO, root,
-			&ramster_foreign_eph_pages);
-	zdfs("foreign_eph_pages_max", S_IRUGO, root,
-			&ramster_foreign_eph_pages_max);
-	zdfs("foreign_pers_pages", S_IRUGO, root,
-			&ramster_foreign_pers_pages);
-	zdfs("foreign_pers_pages_max", S_IRUGO, root,
-			&ramster_foreign_pers_pages_max);
-	return 0;
-}
-#undef	zdebugfs
-#undef	zdfs64
-#else
-static inline int ramster_debugfs_init(void)
-{
-	return 0;
-}
-#endif
-
 static LIST_HEAD(ramster_rem_op_list);
 static DEFINE_SPINLOCK(ramster_rem_op_list_lock);
 static DEFINE_PER_CPU(struct ramster_preload, ramster_preloads);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
