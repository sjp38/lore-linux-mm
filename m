Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id BAA276B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 12:27:01 -0400 (EDT)
Received: by lffy185 with SMTP id y185so23741474lff.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 09:27:01 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h20si6960502lbo.151.2015.10.21.09.26.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 09:26:59 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm, slub, kasan: enable user tracking by default with KASAN=y
Date: Wed, 21 Oct 2015 19:27:00 +0300
Message-ID: <1445444820-27929-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

It's recommended to have slub's user tracking enabled with CONFIG_KASAN,
because:
a) User tracking disables slab merging which improves
    detecting out-of-bounds accesses.
b) User tracking metadata acts as redzone which also improves
    detecting out-of-bounds accesses.
c) User tracking provides additional information about object.
    This information helps to understand bugs.

Currently it is not enabled by default. Besides recompiling the kernel
with KASAN and reinstalling it, user also have to change the boot cmdline,
which is not very handy.

Enable slub user tracking by default with KASAN=y, since there is no
good reason to not do this.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 Documentation/kasan.txt | 3 +--
 lib/Kconfig.kasan       | 3 +--
 mm/slub.c               | 2 ++
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
index 94c88157..3107467 100644
--- a/Documentation/kasan.txt
+++ b/Documentation/kasan.txt
@@ -28,8 +28,7 @@ the latter is 1.1 - 2 times faster. Inline instrumentation requires a GCC
 version 5.0 or later.
 
 Currently KASAN works only with the SLUB memory allocator.
-For better bug detection and nicer report, enable CONFIG_STACKTRACE and put
-at least 'slub_debug=U' in the boot cmdline.
+For better bug detection and nicer report and enable CONFIG_STACKTRACE.
 
 To disable instrumentation for specific files or directories, add a line
 similar to the following to the respective kernel Makefile:
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 39f24d6..0fee5ac 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -15,8 +15,7 @@ config KASAN
 	  global variables requires gcc 5.0 or later.
 	  This feature consumes about 1/8 of available memory and brings about
 	  ~x3 performance slowdown.
-	  For better error detection enable CONFIG_STACKTRACE,
-	  and add slub_debug=U to boot cmdline.
+	  For better error detection enable CONFIG_STACKTRACE.
 
 choice
 	prompt "Instrumentation type"
diff --git a/mm/slub.c b/mm/slub.c
index ae28dff..f208835 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -463,6 +463,8 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
  */
 #ifdef CONFIG_SLUB_DEBUG_ON
 static int slub_debug = DEBUG_DEFAULT_FLAGS;
+#elif defined(CONFIG_KASAN)
+static int slub_debug = SLAB_STORE_USER;
 #else
 static int slub_debug;
 #endif
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
