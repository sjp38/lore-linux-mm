Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 078FB6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:16:57 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d136so3698945qkg.11
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:16:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o6si5779966qtd.174.2017.07.24.02.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 02:16:56 -0700 (PDT)
From: shuwang@redhat.com
Subject: [PATCH v2] kmemleak: add oom=<disable|ignore> runtime parameter
Date: Mon, 24 Jul 2017 17:16:34 +0800
Message-Id: <1500887794-3262-1-git-send-email-shuwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, corbet@lwn.net, akpm@linux-foundation.org
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Shu Wang <shuwang@redhat.com>

From: Shu Wang <shuwang@redhat.com>

When running memory stress tests, kmemleak could be easily disabled in
function create_object as system is out of memory and kmemleak failed to
alloc from object_cache. Since there's no way to enable kmemleak after
it's off, simply ignore the object_cache alloc failure will just loses
track of some memory objects, but could increase the usability of kmemleak
under memory stress.

The default action for oom is still disable kmemleak,
echo oom=ignore > /sys/kernel/debug/kmemleak can change to action to
ignore oom.

Signed-off-by: Shu Wang <shuwang@redhat.com>
---
 Documentation/dev-tools/kmemleak.rst |  5 +++++
 mm/kmemleak.c                        | 10 +++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/Documentation/dev-tools/kmemleak.rst b/Documentation/dev-tools/kmemleak.rst
index cb88626..3013809 100644
--- a/Documentation/dev-tools/kmemleak.rst
+++ b/Documentation/dev-tools/kmemleak.rst
@@ -60,6 +60,11 @@ Memory scanning parameters can be modified at run-time by writing to the
     or free all kmemleak objects if kmemleak has been disabled.
 - dump=<addr>
     dump information about the object found at <addr>
+- oom=disable
+    disable kmemleak after system out of memory (default)
+- oom=ignore
+    do not disable kmemleak after system out of memory
+    (useful for memory stress test, but will lose some objects)
 
 Kmemleak can also be disabled at boot-time by passing ``kmemleak=off`` on
 the kernel command line.
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 7780cd8..b5cb2c6 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -236,6 +236,9 @@ static DEFINE_MUTEX(scan_mutex);
 static int kmemleak_skip_disable;
 /* If there are leaks that can be reported */
 static bool kmemleak_found_leaks;
+/* If disable kmemleak after out of memory */
+static bool kmemleak_oom_disable = true;
+
 
 /*
  * Early object allocation/freeing logging. Kmemleak is initialized after the
@@ -556,7 +559,8 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
 	if (!object) {
 		pr_warn("Cannot allocate a kmemleak_object structure\n");
-		kmemleak_disable();
+		if (kmemleak_oom_disable)
+			kmemleak_disable();
 		return NULL;
 	}
 
@@ -1888,6 +1892,10 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 		kmemleak_scan();
 	else if (strncmp(buf, "dump=", 5) == 0)
 		ret = dump_str_object_info(buf + 5);
+	else if (strncmp(buf, "oom=ignore", 10) == 0)
+		kmemleak_oom_disable = false;
+	else if (strncmp(buf, "oom=disable", 11) == 0)
+		kmemleak_oom_disable = true;
 	else
 		ret = -EINVAL;
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
