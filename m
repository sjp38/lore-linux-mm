Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 047656B00BD
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:12:45 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 04/11] zcache: Fix compile warnings due to usage of debugfs_create_size_t
Date: Wed, 14 Nov 2012 14:12:12 -0500
Message-Id: <1352920339-10183-5-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
References: <1352920339-10183-1-git-send-email-konrad.wilk@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

When we compile we get tons of:
include/linux/debugfs.h:80:16: note: expected a??size_t *a?? but argument is
of type a??long int *a??
drivers/staging/ramster/zcache-main.c:279:2: warning: passing argument 4
of a??debugfs_create_size_ta?? from incompatible pointer type [enabled by d
efault]

which is b/c we end up using 'unsigned' or 'unsigned long' instead
of 'ssize_t'. So lets fix this up and use the proper type.

Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |  135 +++++++++++++++++----------------
 1 files changed, 68 insertions(+), 67 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 9e6b6d3..6988f5c 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -134,23 +134,23 @@ static struct kmem_cache *zcache_obj_cache;
 static DEFINE_PER_CPU(struct zcache_preload, zcache_preloads) = { 0, };
 
 /* we try to keep these statistics SMP-consistent */
-static long zcache_obj_count;
+static ssize_t zcache_obj_count;
 static atomic_t zcache_obj_atomic = ATOMIC_INIT(0);
-static long zcache_obj_count_max;
+static ssize_t zcache_obj_count_max;
 static inline void inc_zcache_obj_count(void)
 {
 	zcache_obj_count = atomic_inc_return(&zcache_obj_atomic);
 	if (zcache_obj_count > zcache_obj_count_max)
 		zcache_obj_count_max = zcache_obj_count;
 }
-static long zcache_objnode_count;
+static ssize_t zcache_objnode_count;
 static inline void dec_zcache_obj_count(void)
 {
 	zcache_obj_count = atomic_dec_return(&zcache_obj_atomic);
 	BUG_ON(zcache_obj_count < 0);
 };
 static atomic_t zcache_objnode_atomic = ATOMIC_INIT(0);
-static long zcache_objnode_count_max;
+static ssize_t zcache_objnode_count_max;
 static inline void inc_zcache_objnode_count(void)
 {
 	zcache_objnode_count = atomic_inc_return(&zcache_objnode_atomic);
@@ -184,64 +184,65 @@ static inline void inc_zcache_pers_zbytes(unsigned clen)
 	if (zcache_pers_zbytes > zcache_pers_zbytes_max)
 		zcache_pers_zbytes_max = zcache_pers_zbytes;
 }
-static long zcache_eph_pageframes;
+static ssize_t zcache_eph_pageframes;
 static inline void dec_zcache_pers_zbytes(unsigned zsize)
 {
 	zcache_pers_zbytes = atomic_long_sub_return(zsize, &zcache_pers_zbytes_atomic);
 }
 static atomic_t zcache_eph_pageframes_atomic = ATOMIC_INIT(0);
-static long zcache_eph_pageframes_max;
+static ssize_t zcache_eph_pageframes_max;
 static inline void inc_zcache_eph_pageframes(void)
 {
 	zcache_eph_pageframes = atomic_inc_return(&zcache_eph_pageframes_atomic);
 	if (zcache_eph_pageframes > zcache_eph_pageframes_max)
 		zcache_eph_pageframes_max = zcache_eph_pageframes;
 };
-static long zcache_pers_pageframes;
+static ssize_t zcache_pers_pageframes;
 static inline void dec_zcache_eph_pageframes(void)
 {
 	zcache_eph_pageframes = atomic_dec_return(&zcache_eph_pageframes_atomic);
 };
 static atomic_t zcache_pers_pageframes_atomic = ATOMIC_INIT(0);
-static long zcache_pers_pageframes_max;
+static ssize_t zcache_pers_pageframes_max;
 static inline void inc_zcache_pers_pageframes(void)
 {
 	zcache_pers_pageframes = atomic_inc_return(&zcache_pers_pageframes_atomic);
 	if (zcache_pers_pageframes > zcache_pers_pageframes_max)
 		zcache_pers_pageframes_max = zcache_pers_pageframes;
 }
-static long zcache_pageframes_alloced;
+static ssize_t zcache_pageframes_alloced;
 static inline void dec_zcache_pers_pageframes(void)
 {
 	zcache_pers_pageframes = atomic_dec_return(&zcache_pers_pageframes_atomic);
 }
 static atomic_t zcache_pageframes_alloced_atomic = ATOMIC_INIT(0);
+static ssize_t zcache_pageframes_freed;
+static atomic_t zcache_pageframes_freed_atomic = ATOMIC_INIT(0);
+static ssize_t zcache_eph_zpages;
 static inline void inc_zcache_pageframes_alloced(void)
 {
 	zcache_pageframes_alloced = atomic_inc_return(&zcache_pageframes_alloced_atomic);
 };
-static long zcache_pageframes_freed;
-static atomic_t zcache_pageframes_freed_atomic = ATOMIC_INIT(0);
 static inline void inc_zcache_pageframes_freed(void)
 {
 	zcache_pageframes_freed = atomic_inc_return(&zcache_pageframes_freed_atomic);
 }
-static long zcache_eph_zpages;
+static ssize_t zcache_eph_zpages;
 static atomic_t zcache_eph_zpages_atomic = ATOMIC_INIT(0);
-static long zcache_eph_zpages_max;
+static ssize_t zcache_eph_zpages_max;
 static inline void inc_zcache_eph_zpages(void)
 {
 	zcache_eph_zpages = atomic_inc_return(&zcache_eph_zpages_atomic);
 	if (zcache_eph_zpages > zcache_eph_zpages_max)
 		zcache_eph_zpages_max = zcache_eph_zpages;
 }
-static long zcache_pers_zpages;
+static ssize_t zcache_pers_zpages;
 static inline void dec_zcache_eph_zpages(unsigned zpages)
 {
 	zcache_eph_zpages = atomic_sub_return(zpages, &zcache_eph_zpages_atomic);
 }
 static atomic_t zcache_pers_zpages_atomic = ATOMIC_INIT(0);
-static long zcache_pers_zpages_max;
+static ssize_t zcache_pers_zpages_max;
 static inline void inc_zcache_pers_zpages(void)
 {
 	zcache_pers_zpages = atomic_inc_return(&zcache_pers_zpages_atomic);
@@ -261,29 +262,29 @@ static inline unsigned long curr_pageframes_count(void)
 		atomic_read(&zcache_pers_pageframes_atomic);
 };
 /* but for the rest of these, counting races are ok */
-static unsigned long zcache_flush_total;
-static unsigned long zcache_flush_found;
-static unsigned long zcache_flobj_total;
-static unsigned long zcache_flobj_found;
-static unsigned long zcache_failed_eph_puts;
-static unsigned long zcache_failed_pers_puts;
-static unsigned long zcache_failed_getfreepages;
-static unsigned long zcache_failed_alloc;
-static unsigned long zcache_put_to_flush;
-static unsigned long zcache_compress_poor;
-static unsigned long zcache_mean_compress_poor;
-static unsigned long zcache_eph_ate_tail;
-static unsigned long zcache_eph_ate_tail_failed;
-static unsigned long zcache_pers_ate_eph;
-static unsigned long zcache_pers_ate_eph_failed;
-static unsigned long zcache_evicted_eph_zpages;
-static unsigned long zcache_evicted_eph_pageframes;
-static unsigned long zcache_last_active_file_pageframes;
-static unsigned long zcache_last_inactive_file_pageframes;
-static unsigned long zcache_last_active_anon_pageframes;
-static unsigned long zcache_last_inactive_anon_pageframes;
-static unsigned long zcache_eph_nonactive_puts_ignored;
-static unsigned long zcache_pers_nonactive_puts_ignored;
+static ssize_t zcache_flush_total;
+static ssize_t zcache_flush_found;
+static ssize_t zcache_flobj_total;
+static ssize_t zcache_flobj_found;
+static ssize_t zcache_failed_eph_puts;
+static ssize_t zcache_failed_pers_puts;
+static ssize_t zcache_failed_getfreepages;
+static ssize_t zcache_failed_alloc;
+static ssize_t zcache_put_to_flush;
+static ssize_t zcache_compress_poor;
+static ssize_t zcache_mean_compress_poor;
+static ssize_t zcache_eph_ate_tail;
+static ssize_t zcache_eph_ate_tail_failed;
+static ssize_t zcache_pers_ate_eph;
+static ssize_t zcache_pers_ate_eph_failed;
+static ssize_t zcache_evicted_eph_zpages;
+static ssize_t zcache_evicted_eph_pageframes;
+static ssize_t zcache_last_active_file_pageframes;
+static ssize_t zcache_last_inactive_file_pageframes;
+static ssize_t zcache_last_active_anon_pageframes;
+static ssize_t zcache_last_inactive_anon_pageframes;
+static ssize_t zcache_eph_nonactive_puts_ignored;
+static ssize_t zcache_pers_nonactive_puts_ignored;
 
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
@@ -353,41 +354,41 @@ static int zcache_debugfs_init(void)
 /* developers can call this in case of ooms, e.g. to find memory leaks */
 void zcache_dump(void)
 {
-	pr_info("zcache: obj_count=%lu\n", zcache_obj_count);
-	pr_info("zcache: obj_count_max=%lu\n", zcache_obj_count_max);
-	pr_info("zcache: objnode_count=%lu\n", zcache_objnode_count);
-	pr_info("zcache: objnode_count_max=%lu\n", zcache_objnode_count_max);
-	pr_info("zcache: flush_total=%lu\n", zcache_flush_total);
-	pr_info("zcache: flush_found=%lu\n", zcache_flush_found);
-	pr_info("zcache: flobj_total=%lu\n", zcache_flobj_total);
-	pr_info("zcache: flobj_found=%lu\n", zcache_flobj_found);
-	pr_info("zcache: failed_eph_puts=%lu\n", zcache_failed_eph_puts);
-	pr_info("zcache: failed_pers_puts=%lu\n", zcache_failed_pers_puts);
-	pr_info("zcache: failed_get_free_pages=%lu\n",
+	pr_info("zcache: obj_count=%u\n", zcache_obj_count);
+	pr_info("zcache: obj_count_max=%u\n", zcache_obj_count_max);
+	pr_info("zcache: objnode_count=%u\n", zcache_objnode_count);
+	pr_info("zcache: objnode_count_max=%u\n", zcache_objnode_count_max);
+	pr_info("zcache: flush_total=%u\n", zcache_flush_total);
+	pr_info("zcache: flush_found=%u\n", zcache_flush_found);
+	pr_info("zcache: flobj_total=%u\n", zcache_flobj_total);
+	pr_info("zcache: flobj_found=%u\n", zcache_flobj_found);
+	pr_info("zcache: failed_eph_puts=%u\n", zcache_failed_eph_puts);
+	pr_info("zcache: failed_pers_puts=%u\n", zcache_failed_pers_puts);
+	pr_info("zcache: failed_get_free_pages=%u\n",
 				zcache_failed_getfreepages);
-	pr_info("zcache: failed_alloc=%lu\n", zcache_failed_alloc);
-	pr_info("zcache: put_to_flush=%lu\n", zcache_put_to_flush);
-	pr_info("zcache: compress_poor=%lu\n", zcache_compress_poor);
-	pr_info("zcache: mean_compress_poor=%lu\n",
+	pr_info("zcache: failed_alloc=%u\n", zcache_failed_alloc);
+	pr_info("zcache: put_to_flush=%u\n", zcache_put_to_flush);
+	pr_info("zcache: compress_poor=%u\n", zcache_compress_poor);
+	pr_info("zcache: mean_compress_poor=%u\n",
 				zcache_mean_compress_poor);
-	pr_info("zcache: eph_ate_tail=%lu\n", zcache_eph_ate_tail);
-	pr_info("zcache: eph_ate_tail_failed=%lu\n",
+	pr_info("zcache: eph_ate_tail=%u\n", zcache_eph_ate_tail);
+	pr_info("zcache: eph_ate_tail_failed=%u\n",
 				zcache_eph_ate_tail_failed);
-	pr_info("zcache: pers_ate_eph=%lu\n", zcache_pers_ate_eph);
-	pr_info("zcache: pers_ate_eph_failed=%lu\n",
+	pr_info("zcache: pers_ate_eph=%u\n", zcache_pers_ate_eph);
+	pr_info("zcache: pers_ate_eph_failed=%u\n",
 				zcache_pers_ate_eph_failed);
-	pr_info("zcache: evicted_eph_zpages=%lu\n", zcache_evicted_eph_zpages);
-	pr_info("zcache: evicted_eph_pageframes=%lu\n",
+	pr_info("zcache: evicted_eph_zpages=%u\n", zcache_evicted_eph_zpages);
+	pr_info("zcache: evicted_eph_pageframes=%u\n",
 				zcache_evicted_eph_pageframes);
-	pr_info("zcache: eph_pageframes=%lu\n", zcache_eph_pageframes);
-	pr_info("zcache: eph_pageframes_max=%lu\n", zcache_eph_pageframes_max);
-	pr_info("zcache: pers_pageframes=%lu\n", zcache_pers_pageframes);
-	pr_info("zcache: pers_pageframes_max=%lu\n",
+	pr_info("zcache: eph_pageframes=%u\n", zcache_eph_pageframes);
+	pr_info("zcache: eph_pageframes_max=%u\n", zcache_eph_pageframes_max);
+	pr_info("zcache: pers_pageframes=%u\n", zcache_pers_pageframes);
+	pr_info("zcache: pers_pageframes_max=%u\n",
 				zcache_pers_pageframes_max);
-	pr_info("zcache: eph_zpages=%lu\n", zcache_eph_zpages);
-	pr_info("zcache: eph_zpages_max=%lu\n", zcache_eph_zpages_max);
-	pr_info("zcache: pers_zpages=%lu\n", zcache_pers_zpages);
-	pr_info("zcache: pers_zpages_max=%lu\n", zcache_pers_zpages_max);
+	pr_info("zcache: eph_zpages=%u\n", zcache_eph_zpages);
+	pr_info("zcache: eph_zpages_max=%u\n", zcache_eph_zpages_max);
+	pr_info("zcache: pers_zpages=%u\n", zcache_pers_zpages);
+	pr_info("zcache: pers_zpages_max=%u\n", zcache_pers_zpages_max);
 	pr_info("zcache: eph_zbytes=%llu\n",
 				(unsigned long long)zcache_eph_zbytes);
 	pr_info("zcache: eph_zbytes_max=%llu\n",
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
