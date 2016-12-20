Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31B996B0342
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 13:12:13 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 26so155344716pgy.6
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:12:13 -0800 (PST)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id k129si23172517pgk.90.2016.12.20.10.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 10:12:12 -0800 (PST)
Received: by mail-pg0-x234.google.com with SMTP id y62so23240458pgy.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:12:12 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 2/2] kasan: add memcg kmem_cache test
Date: Tue, 20 Dec 2016 10:11:02 -0800
Message-Id: <1482257462-36948-2-git-send-email-gthelen@google.com>
In-Reply-To: <1482257462-36948-1-git-send-email-gthelen@google.com>
References: <1482257462-36948-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

Make a kasan test which uses a SLAB_ACCOUNT slab cache.  If the test is
run within a non default memcg, then it uncovers the bug fixed by
"kasan: drain quarantine of memcg slab objects"[1].

If run without fix [1] it shows "Slab cache still has objects", and the
kmem_cache structure is leaked.
Here's an unpatched kernel test:
$ dmesg -c > /dev/null
$ mkdir /sys/fs/cgroup/memory/test
$ echo $$ > /sys/fs/cgroup/memory/test/tasks
$ modprobe test_kasan 2> /dev/null
$ dmesg | grep -B1 still
[ 123.456789] kasan test: memcg_accounted_kmem_cache allocate memcg accounted object
[ 124.456789] kmem_cache_destroy test_cache: Slab cache still has objects

Kernels with fix [1] don't have the "Slab cache still has objects"
warning or the underlying leak.

The new test runs and passes in the default (root) memcg, though in the
root memcg it won't uncover the problem fixed by [1].

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 lib/test_kasan.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index fbdf87920093..0b1d3140fbb8 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -11,6 +11,7 @@
 
 #define pr_fmt(fmt) "kasan test: %s " fmt, __func__
 
+#include <linux/delay.h>
 #include <linux/kernel.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
@@ -331,6 +332,38 @@ static noinline void __init kmem_cache_oob(void)
 	kmem_cache_destroy(cache);
 }
 
+static noinline void __init memcg_accounted_kmem_cache(void)
+{
+	int i;
+	char *p;
+	size_t size = 200;
+	struct kmem_cache *cache;
+
+	cache = kmem_cache_create("test_cache", size, 0, SLAB_ACCOUNT, NULL);
+	if (!cache) {
+		pr_err("Cache allocation failed\n");
+		return;
+	}
+
+	pr_info("allocate memcg accounted object\n");
+	/*
+	 * Several allocations with a delay to allow for lazy per memcg kmem
+	 * cache creation.
+	 */
+	for (i = 0; i < 5; i++) {
+		p = kmem_cache_alloc(cache, GFP_KERNEL);
+		if (!p) {
+			pr_err("Allocation failed\n");
+			goto free_cache;
+		}
+		kmem_cache_free(cache, p);
+		msleep(100);
+	}
+
+free_cache:
+	kmem_cache_destroy(cache);
+}
+
 static char global_array[10];
 
 static noinline void __init kasan_global_oob(void)
@@ -460,6 +493,7 @@ static int __init kmalloc_tests_init(void)
 	kmalloc_uaf_memset();
 	kmalloc_uaf2();
 	kmem_cache_oob();
+	memcg_accounted_kmem_cache();
 	kasan_stack_oob();
 	kasan_global_oob();
 	ksize_unpoisons_memory();
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
