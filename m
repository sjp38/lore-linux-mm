Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 785936B0261
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:11:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so17339356pab.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 23:11:09 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id b2si805745pfg.14.2016.08.17.23.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 23:11:08 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id i6so1197226pfe.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 23:11:08 -0700 (PDT)
Date: Thu, 18 Aug 2016 02:09:31 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH v2 2/2] fs: super.c: Add tracepoint to get name of superblock
 shrinker
Message-ID: <600943d0701ae15596c36194684453fef9ee075e.1471496833.git.janani.rvchndrn@gmail.com>
References: <cover.1471496832.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1471496832.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

This patch adds a new tracepoint to gather specific name information
of the superblock types.
This tracepoint can be used in conjunction with mm_shrink_slab_start and
mm_shrink_slab_end to get information like latency, number of
objects scanned by that particular shrinker, etc. The shrinker struct
address printed by mm_shrink_slab_start, mm_shrink_slab_end 
and the new tracepoint can help tie information together.

However, the specific superblock type can only be identified if the
while condition in do_shrink_slab() of vmscan.c is true and the 
callback for the superblock shrinker is invoked.

Here's a sample output of a postprocessing script to observe how long
the shrinkers took. In this case, the while condition was true each time
and the superblock callback was invoked. The names cgroup, ext4, proc,
etc were obtained from the new tracepoint in the callback.

name:ext4_es_scan 518582ns
name:super_cache_scan/cgroup 1319939ns
name:super_cache_scan/ext4 16954600ns
name:super_cache_scan/proc 27466703ns
name:super_cache_scan/sysfs 11412903ns
name:super_cache_scan/tmpfs 71323ns

However, in cases where the callback is not invoked, it is not possible
to obtain name information from the new tracepoint. In such cases, the
output would be something like:

name:deferred_split_scan 345972ns
name:ext4_es_scan 2719002ns
name:i915_gem_shrinker_scan 10915266ns
name:scan_shadow_nodes 3349303ns
name:super_cache_scan 18970732ns
name:super_cache_scan/ext4 1293938ns
name:super_cache_scan/tmpfs 21588ns

On line 5,we can see that there were times when the super_cache_scan
callback wasn't invoked and therefore no name information was obtained.

Signed-off-by: Janani Ravichandran <janani.rvchndrn@gmail.com>
---

Changes since v1:

v1 did not have any mechanism to print names of specific superblock
types . This version introduces that.

 fs/super.c                    |  2 ++
 include/trace/events/vmscan.h | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/fs/super.c b/fs/super.c
index c2ff475..be7b493 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -35,6 +35,7 @@
 #include <linux/lockdep.h>
 #include <linux/user_namespace.h>
 #include "internal.h"
+#include <trace/events/vmscan.h>
 
 
 static LIST_HEAD(super_blocks);
@@ -64,6 +65,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	long	inodes;
 
 	sb = container_of(shrink, struct super_block, s_shrink);
+	trace_mm_shrinker_callback(shrink, sb->s_type->name);
 
 	/*
 	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 7091c29..5c8703e 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -283,6 +283,27 @@ TRACE_EVENT(mm_shrink_slab_end,
 		__entry->retval)
 );
 
+TRACE_EVENT(mm_shrinker_callback,
+	TP_PROTO(struct shrinker *shr, const char *shrinker_name),
+
+	TP_ARGS(shr, shrinker_name),
+
+	TP_STRUCT__entry(
+		__field(struct shrinker *, shr)
+		__array(char, shrinker_name, SHRINKER_NAME_LEN)
+	),
+
+	TP_fast_assign(
+		__entry->shr = shr;
+		strlcpy(__entry->shrinker_name, shrinker_name,
+		       	SHRINKER_NAME_LEN);
+	),
+
+	TP_printk("shrinker:%p shrinker_name:%s",
+		__entry->shr,
+		__entry->shrinker_name)
+);
+
 DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 
 	TP_PROTO(int classzone_idx,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
