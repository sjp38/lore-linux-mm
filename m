Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 328016B0073
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 09:50:32 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 09/11] zcache: Use an array to initialize/use debugfs attributes.
Date: Mon,  5 Nov 2012 09:37:32 -0500
Message-Id: <1352126254-28933-10-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
References: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, ngupta@vflare.org, minchan@kernel.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org
Cc: akpm@linux-foundation.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

It makes it neater and also allows us to piggyback on that
in the zcache_dump function.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/debug.c |  141 +++++++++++++--------------------------
 1 files changed, 47 insertions(+), 94 deletions(-)

diff --git a/drivers/staging/ramster/debug.c b/drivers/staging/ramster/debug.c
index 0d19715..3a252a5 100644
--- a/drivers/staging/ramster/debug.c
+++ b/drivers/staging/ramster/debug.c
@@ -3,111 +3,64 @@
 
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
-#define	zdfs	debugfs_create_size_t
-#define	zdfs64	debugfs_create_u64
+
+#define ATTR(x)  { .name = #x, .val = &zcache_##x, }
+static struct debug_entry {
+	const char *name;
+	ssize_t *val;
+} attrs[] = {
+	ATTR(obj_count), ATTR(obj_count_max),
+	ATTR(objnode_count), ATTR(objnode_count_max),
+	ATTR(flush_total), ATTR(flush_found),
+	ATTR(flobj_total), ATTR(flobj_found),
+	ATTR(failed_eph_puts), ATTR(failed_pers_puts),
+	ATTR(failed_getfreepages), ATTR(failed_alloc),
+	ATTR(put_to_flush),
+	ATTR(compress_poor), ATTR(mean_compress_poor),
+	ATTR(eph_ate_tail), ATTR(eph_ate_tail_failed),
+	ATTR(pers_ate_eph), ATTR(pers_ate_eph_failed),
+	ATTR(evicted_eph_zpages), ATTR(evicted_eph_pageframes),
+	ATTR(eph_pageframes), ATTR(eph_pageframes_max),
+	ATTR(eph_zpages), ATTR(eph_zpages_max),
+	ATTR(pers_zpages), ATTR(pers_zpages_max),
+	ATTR(last_active_file_pageframes),
+	ATTR(last_inactive_file_pageframes),
+	ATTR(last_active_anon_pageframes),
+	ATTR(last_inactive_anon_pageframes),
+	ATTR(eph_nonactive_puts_ignored),
+	ATTR(pers_nonactive_puts_ignored),
+};
+#undef ATTR
 int zcache_debugfs_init(void)
 {
+	unsigned int i;
 	struct dentry *root = debugfs_create_dir("zcache", NULL);
 	if (root == NULL)
 		return -ENXIO;
 
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
+	for (i = 0; i < ARRAY_SIZE(attrs); i++)
+		if (!debugfs_create_size_t(attrs[i].name, S_IRUGO, root, attrs[i].val))
+			goto out;
+
+	debugfs_create_u64("eph_zbytes", S_IRUGO, root, &zcache_eph_zbytes);
+	debugfs_create_u64("eph_zbytes_max", S_IRUGO, root, &zcache_eph_zbytes_max);
+	debugfs_create_u64("pers_zbytes", S_IRUGO, root, &zcache_pers_zbytes);
+	debugfs_create_u64("pers_zbytes_max", S_IRUGO, root, &zcache_pers_zbytes_max);
 	return 0;
+out:
+	return -ENODEV;
 }
-#undef	zdebugfs
-#undef	zdfs64
 
 /* developers can call this in case of ooms, e.g. to find memory leaks */
 void zcache_dump(void)
 {
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
+	unsigned int i;
+	for (i = 0; i < ARRAY_SIZE(attrs); i++)
+		pr_debug("zcache: %s=%u\n", attrs[i].name, *attrs[i].val);
+
+	pr_debug("zcache: eph_zbytes=%llu\n", (unsigned long long)zcache_eph_zbytes);
+	pr_debug("zcache: eph_zbytes_max=%llu\n", (unsigned long long)zcache_eph_zbytes_max);
+	pr_debug("zcache: pers_zbytes=%llu\n", (unsigned long long)zcache_pers_zbytes);
+	pr_debug("zcache: pers_zbytes_max=%llu\n", (unsigned long long)zcache_pers_zbytes_max);
 }
 #endif
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
