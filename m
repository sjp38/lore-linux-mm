Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 3DE588D0002
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:12:50 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 06/11] zcache: Move debugfs code out of zcache-main.c file.
Date: Wed, 14 Nov 2012 14:12:14 -0500
Message-Id: <1352920339-10183-7-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
References: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/Makefile      |    1 +
 drivers/staging/ramster/debug.c       |  113 +++++++++++++++
 drivers/staging/ramster/debug.h       |  183 ++++++++++++++++++++++++
 drivers/staging/ramster/zcache-main.c |  247 +--------------------------------
 4 files changed, 304 insertions(+), 240 deletions(-)
 create mode 100644 drivers/staging/ramster/debug.c
 create mode 100644 drivers/staging/ramster/debug.h

diff --git a/drivers/staging/ramster/Makefile b/drivers/staging/ramster/Makefile
index fcb25cb..61f5050 100644
--- a/drivers/staging/ramster/Makefile
+++ b/drivers/staging/ramster/Makefile
@@ -4,4 +4,5 @@ zcache-y	+=	ramster/ramster.o ramster/r2net.o
 zcache-y	+=	ramster/nodemanager.o ramster/tcp.o
 zcache-y	+=	ramster/heartbeat.o ramster/masklog.o
 endif
+zcache-y-$(CONFIG_ZCACHE_DEBUG)	+= debug.o
 obj-$(CONFIG_MODULES)	+= zcache.o
diff --git a/drivers/staging/ramster/debug.c b/drivers/staging/ramster/debug.c
new file mode 100644
index 0000000..0d19715
--- /dev/null
+++ b/drivers/staging/ramster/debug.c
@@ -0,0 +1,113 @@
+#include <linux/atomic.h>
+#include "debug.h"
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#define	zdfs	debugfs_create_size_t
+#define	zdfs64	debugfs_create_u64
+int zcache_debugfs_init(void)
+{
+	struct dentry *root = debugfs_create_dir("zcache", NULL);
+	if (root == NULL)
+		return -ENXIO;
+
+	zdfs("obj_count", S_IRUGO, root, &zcache_obj_count);
+	zdfs("obj_count_max", S_IRUGO, root, &zcache_obj_count_max);
+	zdfs("objnode_count", S_IRUGO, root, &zcache_objnode_count);
+	zdfs("objnode_count_max", S_IRUGO, root, &zcache_objnode_count_max);
+	zdfs("flush_total", S_IRUGO, root, &zcache_flush_total);
+	zdfs("flush_found", S_IRUGO, root, &zcache_flush_found);
+	zdfs("flobj_total", S_IRUGO, root, &zcache_flobj_total);
+	zdfs("flobj_found", S_IRUGO, root, &zcache_flobj_found);
+	zdfs("failed_eph_puts", S_IRUGO, root, &zcache_failed_eph_puts);
+	zdfs("failed_pers_puts", S_IRUGO, root, &zcache_failed_pers_puts);
+	zdfs("failed_get_free_pages", S_IRUGO, root,
+				&zcache_failed_getfreepages);
+	zdfs("failed_alloc", S_IRUGO, root, &zcache_failed_alloc);
+	zdfs("put_to_flush", S_IRUGO, root, &zcache_put_to_flush);
+	zdfs("compress_poor", S_IRUGO, root, &zcache_compress_poor);
+	zdfs("mean_compress_poor", S_IRUGO, root, &zcache_mean_compress_poor);
+	zdfs("eph_ate_tail", S_IRUGO, root, &zcache_eph_ate_tail);
+	zdfs("eph_ate_tail_failed", S_IRUGO, root, &zcache_eph_ate_tail_failed);
+	zdfs("pers_ate_eph", S_IRUGO, root, &zcache_pers_ate_eph);
+	zdfs("pers_ate_eph_failed", S_IRUGO, root, &zcache_pers_ate_eph_failed);
+	zdfs("evicted_eph_zpages", S_IRUGO, root, &zcache_evicted_eph_zpages);
+	zdfs("evicted_eph_pageframes", S_IRUGO, root,
+				&zcache_evicted_eph_pageframes);
+	zdfs("eph_pageframes", S_IRUGO, root, &zcache_eph_pageframes);
+	zdfs("eph_pageframes_max", S_IRUGO, root, &zcache_eph_pageframes_max);
+	zdfs("pers_pageframes", S_IRUGO, root, &zcache_pers_pageframes);
+	zdfs("pers_pageframes_max", S_IRUGO, root, &zcache_pers_pageframes_max);
+	zdfs("eph_zpages", S_IRUGO, root, &zcache_eph_zpages);
+	zdfs("eph_zpages_max", S_IRUGO, root, &zcache_eph_zpages_max);
+	zdfs("pers_zpages", S_IRUGO, root, &zcache_pers_zpages);
+	zdfs("pers_zpages_max", S_IRUGO, root, &zcache_pers_zpages_max);
+	zdfs("last_active_file_pageframes", S_IRUGO, root,
+				&zcache_last_active_file_pageframes);
+	zdfs("last_inactive_file_pageframes", S_IRUGO, root,
+				&zcache_last_inactive_file_pageframes);
+	zdfs("last_active_anon_pageframes", S_IRUGO, root,
+				&zcache_last_active_anon_pageframes);
+	zdfs("last_inactive_anon_pageframes", S_IRUGO, root,
+				&zcache_last_inactive_anon_pageframes);
+	zdfs("eph_nonactive_puts_ignored", S_IRUGO, root,
+				&zcache_eph_nonactive_puts_ignored);
+	zdfs("pers_nonactive_puts_ignored", S_IRUGO, root,
+				&zcache_pers_nonactive_puts_ignored);
+	zdfs64("eph_zbytes", S_IRUGO, root, &zcache_eph_zbytes);
+	zdfs64("eph_zbytes_max", S_IRUGO, root, &zcache_eph_zbytes_max);
+	zdfs64("pers_zbytes", S_IRUGO, root, &zcache_pers_zbytes);
+	zdfs64("pers_zbytes_max", S_IRUGO, root, &zcache_pers_zbytes_max);
+	return 0;
+}
+#undef	zdebugfs
+#undef	zdfs64
+
+/* developers can call this in case of ooms, e.g. to find memory leaks */
+void zcache_dump(void)
+{
+	pr_debug("zcache: obj_count=%u\n", zcache_obj_count);
+	pr_debug("zcache: obj_count_max=%u\n", zcache_obj_count_max);
+	pr_debug("zcache: objnode_count=%u\n", zcache_objnode_count);
+	pr_debug("zcache: objnode_count_max=%u\n", zcache_objnode_count_max);
+	pr_debug("zcache: flush_total=%u\n", zcache_flush_total);
+	pr_debug("zcache: flush_found=%u\n", zcache_flush_found);
+	pr_debug("zcache: flobj_total=%u\n", zcache_flobj_total);
+	pr_debug("zcache: flobj_found=%u\n", zcache_flobj_found);
+	pr_debug("zcache: failed_eph_puts=%u\n", zcache_failed_eph_puts);
+	pr_debug("zcache: failed_pers_puts=%u\n", zcache_failed_pers_puts);
+	pr_debug("zcache: failed_get_free_pages=%u\n",
+				zcache_failed_getfreepages);
+	pr_debug("zcache: failed_alloc=%u\n", zcache_failed_alloc);
+	pr_debug("zcache: put_to_flush=%u\n", zcache_put_to_flush);
+	pr_debug("zcache: compress_poor=%u\n", zcache_compress_poor);
+	pr_debug("zcache: mean_compress_poor=%u\n",
+				zcache_mean_compress_poor);
+	pr_debug("zcache: eph_ate_tail=%u\n", zcache_eph_ate_tail);
+	pr_debug("zcache: eph_ate_tail_failed=%u\n",
+				zcache_eph_ate_tail_failed);
+	pr_debug("zcache: pers_ate_eph=%u\n", zcache_pers_ate_eph);
+	pr_debug("zcache: pers_ate_eph_failed=%u\n",
+				zcache_pers_ate_eph_failed);
+	pr_debug("zcache: evicted_eph_zpages=%u\n", zcache_evicted_eph_zpages);
+	pr_debug("zcache: evicted_eph_pageframes=%u\n",
+				zcache_evicted_eph_pageframes);
+	pr_debug("zcache: eph_pageframes=%u\n", zcache_eph_pageframes);
+	pr_debug("zcache: eph_pageframes_max=%u\n", zcache_eph_pageframes_max);
+	pr_debug("zcache: pers_pageframes=%u\n", zcache_pers_pageframes);
+	pr_debug("zcache: pers_pageframes_max=%u\n",
+				zcache_pers_pageframes_max);
+	pr_debug("zcache: eph_zpages=%u\n", zcache_eph_zpages);
+	pr_debug("zcache: eph_zpages_max=%u\n", zcache_eph_zpages_max);
+	pr_debug("zcache: pers_zpages=%u\n", zcache_pers_zpages);
+	pr_debug("zcache: pers_zpages_max=%u\n", zcache_pers_zpages_max);
+	pr_debug("zcache: eph_zbytes=%llu\n",
+				(unsigned long long)zcache_eph_zbytes);
+	pr_debug("zcache: eph_zbytes_max=%llu\n",
+				(unsigned long long)zcache_eph_zbytes_max);
+	pr_debug("zcache: pers_zbytes=%llu\n",
+				(unsigned long long)zcache_pers_zbytes);
+	pr_debug("zcache: pers_zbytes_max=%llu\n",
+			(unsigned long long)zcache_pers_zbytes_max);
+}
+#endif
diff --git a/drivers/staging/ramster/debug.h b/drivers/staging/ramster/debug.h
new file mode 100644
index 0000000..496735b
--- /dev/null
+++ b/drivers/staging/ramster/debug.h
@@ -0,0 +1,183 @@
+#ifdef CONFIG_ZCACHE_DEBUG
+
+/* we try to keep these statistics SMP-consistent */
+static ssize_t zcache_obj_count;
+static atomic_t zcache_obj_atomic = ATOMIC_INIT(0);
+static ssize_t zcache_obj_count_max;
+static inline void inc_zcache_obj_count(void)
+{
+	zcache_obj_count = atomic_inc_return(&zcache_obj_atomic);
+	if (zcache_obj_count > zcache_obj_count_max)
+		zcache_obj_count_max = zcache_obj_count;
+}
+static inline void dec_zcache_obj_count(void)
+{
+	zcache_obj_count = atomic_dec_return(&zcache_obj_atomic);
+	BUG_ON(zcache_obj_count < 0);
+};
+static ssize_t zcache_objnode_count;
+static atomic_t zcache_objnode_atomic = ATOMIC_INIT(0);
+static ssize_t zcache_objnode_count_max;
+static inline void inc_zcache_objnode_count(void)
+{
+	zcache_objnode_count = atomic_inc_return(&zcache_objnode_atomic);
+	if (zcache_objnode_count > zcache_objnode_count_max)
+		zcache_objnode_count_max = zcache_objnode_count;
+};
+static inline void dec_zcache_objnode_count(void)
+{
+	zcache_objnode_count = atomic_dec_return(&zcache_objnode_atomic);
+	BUG_ON(zcache_objnode_count < 0);
+};
+static u64 zcache_eph_zbytes;
+static atomic_long_t zcache_eph_zbytes_atomic = ATOMIC_INIT(0);
+static u64 zcache_eph_zbytes_max;
+static inline void inc_zcache_eph_zbytes(unsigned clen)
+{
+	zcache_eph_zbytes = atomic_long_add_return(clen, &zcache_eph_zbytes_atomic);
+	if (zcache_eph_zbytes > zcache_eph_zbytes_max)
+		zcache_eph_zbytes_max = zcache_eph_zbytes;
+};
+static inline void dec_zcache_eph_zbytes(unsigned zsize)
+{
+	zcache_eph_zbytes = atomic_long_sub_return(zsize, &zcache_eph_zbytes_atomic);
+};
+extern  u64 zcache_pers_zbytes;
+static atomic_long_t zcache_pers_zbytes_atomic = ATOMIC_INIT(0);
+static u64 zcache_pers_zbytes_max;
+static inline void inc_zcache_pers_zbytes(unsigned clen)
+{
+	zcache_pers_zbytes = atomic_long_add_return(clen, &zcache_pers_zbytes_atomic);
+	if (zcache_pers_zbytes > zcache_pers_zbytes_max)
+		zcache_pers_zbytes_max = zcache_pers_zbytes;
+}
+static inline void dec_zcache_pers_zbytes(unsigned zsize)
+{
+	zcache_pers_zbytes = atomic_long_sub_return(zsize, &zcache_pers_zbytes_atomic);
+}
+extern ssize_t zcache_eph_pageframes;
+static atomic_t zcache_eph_pageframes_atomic = ATOMIC_INIT(0);
+static ssize_t zcache_eph_pageframes_max;
+static inline void inc_zcache_eph_pageframes(void)
+{
+	zcache_eph_pageframes = atomic_inc_return(&zcache_eph_pageframes_atomic);
+	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
+		zcache_eph_pageframes_max = zcache_eph_pageframes;
+};
+static inline void dec_zcache_eph_pageframes(void)
+{
+	zcache_eph_pageframes = atomic_dec_return(&zcache_eph_pageframes_atomic);
+};
+extern ssize_t zcache_pers_pageframes;
+static atomic_t zcache_pers_pageframes_atomic = ATOMIC_INIT(0);
+static ssize_t zcache_pers_pageframes_max;
+static inline void inc_zcache_pers_pageframes(void)
+{
+	zcache_pers_pageframes = atomic_inc_return(&zcache_pers_pageframes_atomic);
+	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
+		zcache_pers_pageframes_max = zcache_pers_pageframes;
+}
+static inline void dec_zcache_pers_pageframes(void)
+{
+	zcache_pers_pageframes = atomic_dec_return(&zcache_pers_pageframes_atomic);
+}
+static ssize_t zcache_pageframes_alloced;
+static atomic_t zcache_pageframes_alloced_atomic = ATOMIC_INIT(0);
+static inline void inc_zcache_pageframes_alloced(void)
+{
+	zcache_pageframes_alloced = atomic_inc_return(&zcache_pageframes_alloced_atomic);
+};
+static ssize_t zcache_pageframes_freed;
+static atomic_t zcache_pageframes_freed_atomic = ATOMIC_INIT(0);
+static inline void inc_zcache_pageframes_freed(void)
+{
+	zcache_pageframes_freed = atomic_inc_return(&zcache_pageframes_freed_atomic);
+}
+static ssize_t zcache_eph_zpages;
+static atomic_t zcache_eph_zpages_atomic = ATOMIC_INIT(0);
+static ssize_t zcache_eph_zpages_max;
+static inline void inc_zcache_eph_zpages(void)
+{
+	zcache_eph_zpages = atomic_inc_return(&zcache_eph_zpages_atomic);
+	if (zcache_eph_zpages > zcache_eph_zpages_max)
+		zcache_eph_zpages_max = zcache_eph_zpages;
+}
+static inline void dec_zcache_eph_zpages(unsigned zpages)
+{
+	zcache_eph_zpages = atomic_sub_return(zpages, &zcache_eph_zpages_atomic);
+}
+extern ssize_t zcache_pers_zpages;
+static atomic_t zcache_pers_zpages_atomic = ATOMIC_INIT(0);
+static ssize_t zcache_pers_zpages_max;
+static inline void inc_zcache_pers_zpages(void)
+{
+	zcache_pers_zpages = atomic_inc_return(&zcache_pers_zpages_atomic);
+	if (zcache_pers_zpages > zcache_pers_zpages_max)
+		zcache_pers_zpages_max = zcache_pers_zpages;
+}
+static inline void dec_zcache_pers_zpages(unsigned zpages)
+{
+	zcache_pers_zpages = atomic_sub_return(zpages, &zcache_pers_zpages_atomic);
+}
+
+static inline unsigned long curr_pageframes_count(void)
+{
+	return zcache_pageframes_alloced -
+		atomic_read(&zcache_pageframes_freed_atomic) -
+		atomic_read(&zcache_eph_pageframes_atomic) -
+		atomic_read(&zcache_pers_pageframes_atomic);
+};
+/* but for the rest of these, counting races are ok */
+extern ssize_t zcache_flush_total;
+extern ssize_t zcache_flush_found;
+extern ssize_t zcache_flobj_total;
+extern ssize_t zcache_flobj_found;
+extern ssize_t zcache_failed_eph_puts;
+extern ssize_t zcache_failed_pers_puts;
+extern ssize_t zcache_failed_getfreepages;
+extern ssize_t zcache_failed_alloc;
+extern ssize_t zcache_put_to_flush;
+extern ssize_t zcache_compress_poor;
+extern ssize_t zcache_mean_compress_poor;
+extern ssize_t zcache_eph_ate_tail;
+extern ssize_t zcache_eph_ate_tail_failed;
+extern ssize_t zcache_pers_ate_eph;
+extern ssize_t zcache_pers_ate_eph_failed;
+extern ssize_t zcache_evicted_eph_zpages;
+extern ssize_t zcache_evicted_eph_pageframes;
+extern ssize_t zcache_last_active_file_pageframes;
+extern ssize_t zcache_last_inactive_file_pageframes;
+extern ssize_t zcache_last_active_anon_pageframes;
+extern ssize_t zcache_last_inactive_anon_pageframes;
+extern ssize_t zcache_eph_nonactive_puts_ignored;
+extern ssize_t zcache_pers_nonactive_puts_ignored;
+
+int zcache_debugfs_init(void);
+#else
+static inline void inc_zcache_obj_count(void) { };
+static inline void dec_zcache_obj_count(void) { };
+static inline void inc_zcache_objnode_count(void) { };
+static inline void dec_zcache_objnode_count(void) { };
+static inline void inc_zcache_eph_zbytes(unsigned clen) { };
+static inline void dec_zcache_eph_zbytes(unsigned zsize) { };
+static inline void inc_zcache_pers_zbytes(unsigned clen) { };
+static inline void dec_zcache_pers_zbytes(unsigned zsize) { };
+static inline void inc_zcache_eph_pageframes(void) { };
+static inline void dec_zcache_eph_pageframes(void) { };
+static inline void inc_zcache_pers_pageframes(void) { };
+static inline void dec_zcache_pers_pageframes(void) { };
+static inline void inc_zcache_pageframes_alloced(void) { };
+static inline void inc_zcache_pageframes_freed(void) { };
+static inline void inc_zcache_eph_zpages(void) { };
+static inline void dec_zcache_eph_zpages(unsigned zpages) { };
+static inline void inc_zcache_pers_zpages(void) { };
+static inline void dec_zcache_pers_zpages(unsigned zpages) { };
+static inline unsigned long curr_pageframes_count(void)
+{
+	return 0;
+};
+static inline int zcache_debugfs_init(void)
+{
+	return 0;
+};
+#endif
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index a43c3b0..52c29de 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -29,6 +29,7 @@
 #include "zcache.h"
 #include "zbud.h"
 #include "ramster.h"
+#include "debug.h"
 #ifdef CONFIG_RAMSTER
 static bool ramster_enabled __read_mostly;
 static bool disable_frontswap_selfshrink __read_mostly;
@@ -133,135 +134,13 @@ static struct kmem_cache *zcache_obj_cache;
 
 static DEFINE_PER_CPU(struct zcache_preload, zcache_preloads) = { 0, };
 
-/* we try to keep these statistics SMP-consistent */
-static ssize_t zcache_obj_count;
-static atomic_t zcache_obj_atomic = ATOMIC_INIT(0);
-static ssize_t zcache_obj_count_max;
-static inline void inc_zcache_obj_count(void)
-{
-	zcache_obj_count = atomic_inc_return(&zcache_obj_atomic);
-	if (zcache_obj_count > zcache_obj_count_max)
-		zcache_obj_count_max = zcache_obj_count;
-}
-static ssize_t zcache_objnode_count;
-static inline void dec_zcache_obj_count(void)
-{
-	zcache_obj_count = atomic_dec_return(&zcache_obj_atomic);
-	BUG_ON(zcache_obj_count < 0);
-};
-static atomic_t zcache_objnode_atomic = ATOMIC_INIT(0);
-static ssize_t zcache_objnode_count_max;
-static inline void inc_zcache_objnode_count(void)
-{
-	zcache_objnode_count = atomic_inc_return(&zcache_objnode_atomic);
-	if (zcache_objnode_count > zcache_objnode_count_max)
-		zcache_objnode_count_max = zcache_objnode_count;
-};
-static inline void dec_zcache_objnode_count(void)
-{
-	zcache_objnode_count = atomic_dec_return(&zcache_objnode_atomic);
-	BUG_ON(zcache_objnode_count < 0);
-};
-static u64 zcache_eph_zbytes;
-static atomic_long_t zcache_eph_zbytes_atomic = ATOMIC_INIT(0);
-static u64 zcache_eph_zbytes_max;
-static inline void inc_zcache_eph_zbytes(unsigned clen)
-{
-	zcache_eph_zbytes = atomic_long_add_return(clen, &zcache_eph_zbytes_atomic);
-	if (zcache_eph_zbytes > zcache_eph_zbytes_max)
-		zcache_eph_zbytes_max = zcache_eph_zbytes;
-};
-static inline void dec_zcache_eph_zbytes(unsigned zsize)
-{
-	zcache_eph_zbytes = atomic_long_sub_return(zsize, &zcache_eph_zbytes_atomic);
-};
-static u64 zcache_pers_zbytes;
-static atomic_long_t zcache_pers_zbytes_atomic = ATOMIC_INIT(0);
-static u64 zcache_pers_zbytes_max;
-static inline void inc_zcache_pers_zbytes(unsigned clen)
-{
-	zcache_pers_zbytes = atomic_long_add_return(clen, &zcache_pers_zbytes_atomic);
-	if (zcache_pers_zbytes > zcache_pers_zbytes_max)
-		zcache_pers_zbytes_max = zcache_pers_zbytes;
-}
-static ssize_t zcache_eph_pageframes;
-static inline void dec_zcache_pers_zbytes(unsigned zsize)
-{
-	zcache_pers_zbytes = atomic_long_sub_return(zsize, &zcache_pers_zbytes_atomic);
-}
-static atomic_t zcache_eph_pageframes_atomic = ATOMIC_INIT(0);
-static ssize_t zcache_eph_pageframes_max;
-static inline void inc_zcache_eph_pageframes(void)
-{
-	zcache_eph_pageframes = atomic_inc_return(&zcache_eph_pageframes_atomic);
-	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
-		zcache_eph_pageframes_max = zcache_eph_pageframes;
-};
-static ssize_t zcache_pers_pageframes;
-static inline void dec_zcache_eph_pageframes(void)
-{
-	zcache_eph_pageframes = atomic_dec_return(&zcache_eph_pageframes_atomic);
-};
-static atomic_t zcache_pers_pageframes_atomic = ATOMIC_INIT(0);
-static ssize_t zcache_pers_pageframes_max;
-static inline void inc_zcache_pers_pageframes(void)
-{
-	zcache_pers_pageframes = atomic_inc_return(&zcache_pers_pageframes_atomic);
-	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
-		zcache_pers_pageframes_max = zcache_pers_pageframes;
-}
-static ssize_t zcache_pageframes_alloced;
-static inline void dec_zcache_pers_pageframes(void)
-{
-	zcache_pers_pageframes = atomic_dec_return(&zcache_pers_pageframes_atomic);
-}
-static atomic_t zcache_pageframes_alloced_atomic = ATOMIC_INIT(0);
-static ssize_t zcache_pageframes_freed;
-static atomic_t zcache_pageframes_freed_atomic = ATOMIC_INIT(0);
-static ssize_t zcache_eph_zpages;
-static inline void inc_zcache_pageframes_alloced(void)
-{
-	zcache_pageframes_alloced = atomic_inc_return(&zcache_pageframes_alloced_atomic);
-};
-static inline void inc_zcache_pageframes_freed(void)
-{
-	zcache_pageframes_freed = atomic_inc_return(&zcache_pageframes_freed_atomic);
-}
-static ssize_t zcache_eph_zpages;
-static atomic_t zcache_eph_zpages_atomic = ATOMIC_INIT(0);
-static ssize_t zcache_eph_zpages_max;
-static inline void inc_zcache_eph_zpages(void)
-{
-	zcache_eph_zpages = atomic_inc_return(&zcache_eph_zpages_atomic);
-	if (zcache_eph_zpages > zcache_eph_zpages_max)
-		zcache_eph_zpages_max = zcache_eph_zpages;
-}
-static ssize_t zcache_pers_zpages;
-static inline void dec_zcache_eph_zpages(unsigned zpages)
-{
-	zcache_eph_zpages = atomic_sub_return(zpages, &zcache_eph_zpages_atomic);
-}
-static atomic_t zcache_pers_zpages_atomic = ATOMIC_INIT(0);
-static ssize_t zcache_pers_zpages_max;
-static inline void inc_zcache_pers_zpages(void)
-{
-	zcache_pers_zpages = atomic_inc_return(&zcache_pers_zpages_atomic);
-	if (zcache_pers_zpages > zcache_pers_zpages_max)
-		zcache_pers_zpages_max = zcache_pers_zpages;
-}
-static inline void dec_zcache_pers_zpages(unsigned zpages)
-{
-	zcache_pers_zpages = atomic_sub_return(zpages, &zcache_pers_zpages_atomic);
-}
+/* Used by debug.c */
+ssize_t zcache_pers_zpages;
+u64 zcache_pers_zbytes;
+ssize_t zcache_eph_pageframes;
+ssize_t zcache_pers_pageframes;
 
-static inline unsigned long curr_pageframes_count(void)
-{
-	return zcache_pageframes_alloced -
-		atomic_read(&zcache_pageframes_freed_atomic) -
-		atomic_read(&zcache_eph_pageframes_atomic) -
-		atomic_read(&zcache_pers_pageframes_atomic);
-};
-/* but for the rest of these, counting races are ok */
+/* Used by this code. */
 static ssize_t zcache_flush_total;
 static ssize_t zcache_flush_found;
 static ssize_t zcache_flobj_total;
@@ -285,118 +164,6 @@ static ssize_t zcache_last_active_anon_pageframes;
 static ssize_t zcache_last_inactive_anon_pageframes;
 static ssize_t zcache_eph_nonactive_puts_ignored;
 static ssize_t zcache_pers_nonactive_puts_ignored;
-
-#ifdef CONFIG_DEBUG_FS
-#include <linux/debugfs.h>
-#define	zdfs	debugfs_create_size_t
-#define	zdfs64	debugfs_create_u64
-static int zcache_debugfs_init(void)
-{
-	struct dentry *root = debugfs_create_dir("zcache", NULL);
-	if (root == NULL)
-		return -ENXIO;
-
-	zdfs("obj_count", S_IRUGO, root, &zcache_obj_count);
-	zdfs("obj_count_max", S_IRUGO, root, &zcache_obj_count_max);
-	zdfs("objnode_count", S_IRUGO, root, &zcache_objnode_count);
-	zdfs("objnode_count_max", S_IRUGO, root, &zcache_objnode_count_max);
-	zdfs("flush_total", S_IRUGO, root, &zcache_flush_total);
-	zdfs("flush_found", S_IRUGO, root, &zcache_flush_found);
-	zdfs("flobj_total", S_IRUGO, root, &zcache_flobj_total);
-	zdfs("flobj_found", S_IRUGO, root, &zcache_flobj_found);
-	zdfs("failed_eph_puts", S_IRUGO, root, &zcache_failed_eph_puts);
-	zdfs("failed_pers_puts", S_IRUGO, root, &zcache_failed_pers_puts);
-	zdfs("failed_get_free_pages", S_IRUGO, root,
-				&zcache_failed_getfreepages);
-	zdfs("failed_alloc", S_IRUGO, root, &zcache_failed_alloc);
-	zdfs("put_to_flush", S_IRUGO, root, &zcache_put_to_flush);
-	zdfs("compress_poor", S_IRUGO, root, &zcache_compress_poor);
-	zdfs("mean_compress_poor", S_IRUGO, root, &zcache_mean_compress_poor);
-	zdfs("eph_ate_tail", S_IRUGO, root, &zcache_eph_ate_tail);
-	zdfs("eph_ate_tail_failed", S_IRUGO, root, &zcache_eph_ate_tail_failed);
-	zdfs("pers_ate_eph", S_IRUGO, root, &zcache_pers_ate_eph);
-	zdfs("pers_ate_eph_failed", S_IRUGO, root, &zcache_pers_ate_eph_failed);
-	zdfs("evicted_eph_zpages", S_IRUGO, root, &zcache_evicted_eph_zpages);
-	zdfs("evicted_eph_pageframes", S_IRUGO, root,
-				&zcache_evicted_eph_pageframes);
-	zdfs("eph_pageframes", S_IRUGO, root, &zcache_eph_pageframes);
-	zdfs("eph_pageframes_max", S_IRUGO, root, &zcache_eph_pageframes_max);
-	zdfs("pers_pageframes", S_IRUGO, root, &zcache_pers_pageframes);
-	zdfs("pers_pageframes_max", S_IRUGO, root, &zcache_pers_pageframes_max);
-	zdfs("eph_zpages", S_IRUGO, root, &zcache_eph_zpages);
-	zdfs("eph_zpages_max", S_IRUGO, root, &zcache_eph_zpages_max);
-	zdfs("pers_zpages", S_IRUGO, root, &zcache_pers_zpages);
-	zdfs("pers_zpages_max", S_IRUGO, root, &zcache_pers_zpages_max);
-	zdfs("last_active_file_pageframes", S_IRUGO, root,
-				&zcache_last_active_file_pageframes);
-	zdfs("last_inactive_file_pageframes", S_IRUGO, root,
-				&zcache_last_inactive_file_pageframes);
-	zdfs("last_active_anon_pageframes", S_IRUGO, root,
-				&zcache_last_active_anon_pageframes);
-	zdfs("last_inactive_anon_pageframes", S_IRUGO, root,
-				&zcache_last_inactive_anon_pageframes);
-	zdfs("eph_nonactive_puts_ignored", S_IRUGO, root,
-				&zcache_eph_nonactive_puts_ignored);
-	zdfs("pers_nonactive_puts_ignored", S_IRUGO, root,
-				&zcache_pers_nonactive_puts_ignored);
-	zdfs64("eph_zbytes", S_IRUGO, root, &zcache_eph_zbytes);
-	zdfs64("eph_zbytes_max", S_IRUGO, root, &zcache_eph_zbytes_max);
-	zdfs64("pers_zbytes", S_IRUGO, root, &zcache_pers_zbytes);
-	zdfs64("pers_zbytes_max", S_IRUGO, root, &zcache_pers_zbytes_max);
-	return 0;
-}
-#undef	zdebugfs
-#undef	zdfs64
-#endif
-
-/* developers can call this in case of ooms, e.g. to find memory leaks */
-void zcache_dump(void)
-{
-	pr_debug("zcache: obj_count=%u\n", zcache_obj_count);
-	pr_debug("zcache: obj_count_max=%u\n", zcache_obj_count_max);
-	pr_debug("zcache: objnode_count=%u\n", zcache_objnode_count);
-	pr_debug("zcache: objnode_count_max=%u\n", zcache_objnode_count_max);
-	pr_debug("zcache: flush_total=%u\n", zcache_flush_total);
-	pr_debug("zcache: flush_found=%u\n", zcache_flush_found);
-	pr_debug("zcache: flobj_total=%u\n", zcache_flobj_total);
-	pr_debug("zcache: flobj_found=%u\n", zcache_flobj_found);
-	pr_debug("zcache: failed_eph_puts=%u\n", zcache_failed_eph_puts);
-	pr_debug("zcache: failed_pers_puts=%u\n", zcache_failed_pers_puts);
-	pr_debug("zcache: failed_get_free_pages=%u\n",
-				zcache_failed_getfreepages);
-	pr_debug("zcache: failed_alloc=%u\n", zcache_failed_alloc);
-	pr_debug("zcache: put_to_flush=%u\n", zcache_put_to_flush);
-	pr_debug("zcache: compress_poor=%u\n", zcache_compress_poor);
-	pr_debug("zcache: mean_compress_poor=%u\n",
-				zcache_mean_compress_poor);
-	pr_debug("zcache: eph_ate_tail=%u\n", zcache_eph_ate_tail);
-	pr_debug("zcache: eph_ate_tail_failed=%u\n",
-				zcache_eph_ate_tail_failed);
-	pr_debug("zcache: pers_ate_eph=%u\n", zcache_pers_ate_eph);
-	pr_debug("zcache: pers_ate_eph_failed=%u\n",
-				zcache_pers_ate_eph_failed);
-	pr_debug("zcache: evicted_eph_zpages=%u\n", zcache_evicted_eph_zpages);
-	pr_debug("zcache: evicted_eph_pageframes=%u\n",
-				zcache_evicted_eph_pageframes);
-	pr_debug("zcache: eph_pageframes=%u\n", zcache_eph_pageframes);
-	pr_debug("zcache: eph_pageframes_max=%u\n", zcache_eph_pageframes_max);
-	pr_debug("zcache: pers_pageframes=%u\n", zcache_pers_pageframes);
-	pr_debug("zcache: pers_pageframes_max=%u\n",
-				zcache_pers_pageframes_max);
-	pr_debug("zcache: eph_zpages=%u\n", zcache_eph_zpages);
-	pr_debug("zcache: eph_zpages_max=%u\n", zcache_eph_zpages_max);
-	pr_debug("zcache: pers_zpages=%u\n", zcache_pers_zpages);
-	pr_debug("zcache: pers_zpages_max=%u\n", zcache_pers_zpages_max);
-	pr_debug("zcache: eph_zbytes=%llu\n",
-				(unsigned long long)zcache_eph_zbytes);
-	pr_debug("zcache: eph_zbytes_max=%llu\n",
-				(unsigned long long)zcache_eph_zbytes_max);
-	pr_debug("zcache: pers_zbytes=%llu\n",
-				(unsigned long long)zcache_pers_zbytes);
-	pr_debug("zcache: pers_zbytes_max=%llu\n",
-			(unsigned long long)zcache_pers_zbytes_max);
-}
-
 /*
  * zcache core code starts here
  */
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
