Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8446B0277
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 21:03:44 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 78so2808079qky.17
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:03:44 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u27si2812644qtj.190.2018.02.21.18.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 18:03:43 -0800 (PST)
From: Howard McLauchlan <hmclauchlan@fb.com>
Subject: [PATCH] mm: make should_failslab always available for fault injection
Date: Wed, 21 Feb 2018 18:03:20 -0800
Message-ID: <20180222020320.6944-1-hmclauchlan@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Josef Bacik <jbacik@fb.com>, Johannes Weiner <jweiner@fb.com>, Alexei Starovoitov <ast@fb.com>, kernel-team@fb.com, Howard McLauchlan <hmclauchlan@fb.com>

should_failslab() is a convenient function to hook into for directed
error injection into kmalloc(). However, it is only available if a
config flag is set.

The following BCC script, for example, fails kmalloc() calls after a
btrfs umount:

from bcc import BPF

prog = r"""
BPF_HASH(flag);

int kprobe__btrfs_close_devices(void *ctx) {
        u64 key = 1;
        flag.update(&key, &key);
        return 0;
}

int kprobe__should_failslab(struct pt_regs *ctx) {
        u64 key = 1;
        u64 *res;
        res = flag.lookup(&key);
        if (res != 0) {
            bpf_override_return(ctx, -ENOMEM);
        }
        return 0;
}
"""
b = BPF(text=prog)

while 1:
    b.kprobe_poll()

This patch refactors the should_failslab implementation so that the
function is always available for error injection, independent of flags.

This change would be similar in nature to commit f5490d3ec921 ("block:
Add should_fail_bio() for bpf error injection").

Signed-off-by: Howard McLauchlan <hmclauchlan@fb.com>
---
 include/linux/fault-inject.h | 5 +++--
 mm/failslab.c                | 2 +-
 mm/slab_common.c             | 8 ++++++++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/fault-inject.h b/include/linux/fault-inject.h
index c3c95d18bf43..7e6c77740413 100644
--- a/include/linux/fault-inject.h
+++ b/include/linux/fault-inject.h
@@ -64,10 +64,11 @@ static inline struct dentry *fault_create_debugfs_attr(const char *name,
 
 struct kmem_cache;
 
+int should_failslab(struct kmem_cache *s, gfp_t gfpflags);
 #ifdef CONFIG_FAILSLAB
-extern bool should_failslab(struct kmem_cache *s, gfp_t gfpflags);
+extern bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags);
 #else
-static inline bool should_failslab(struct kmem_cache *s, gfp_t gfpflags)
+static inline bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags)
 {
 	return false;
 }
diff --git a/mm/failslab.c b/mm/failslab.c
index 8087d976a809..1f2f248e3601 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -14,7 +14,7 @@ static struct {
 	.cache_filter = false,
 };
 
-bool should_failslab(struct kmem_cache *s, gfp_t gfpflags)
+bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags)
 {
 	/* No fault-injection for bootstrap cache */
 	if (unlikely(s == kmem_cache))
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 10f127b2de7c..e99884490f14 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1532,3 +1532,11 @@ EXPORT_TRACEPOINT_SYMBOL(kmalloc_node);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc_node);
 EXPORT_TRACEPOINT_SYMBOL(kfree);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_free);
+
+int should_failslab(struct kmem_cache *s, gfp_t gfpflags)
+{
+	if (__should_failslab(s, gfpflags))
+		return -ENOMEM;
+	return 0;
+}
+ALLOW_ERROR_INJECTION(should_failslab, ERRNO);
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
