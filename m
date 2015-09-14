Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0936B0265
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:46:33 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so143621765wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:32 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id bm10si17278983wib.34.2015.09.14.06.46.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:46:26 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so133848901wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:46:25 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 5/7] kasan: various fixes in documentation
Date: Mon, 14 Sep 2015 15:46:06 +0200
Message-Id: <d9dc110e47fe625c737adca7c261ffbc592a60d7.1442238094.git.andreyknvl@google.com>
In-Reply-To: <cover.1442238094.git.andreyknvl@google.com>
References: <cover.1442238094.git.andreyknvl@google.com>
In-Reply-To: <cover.1442238094.git.andreyknvl@google.com>
References: <cover.1442238094.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dvyukov@google.com, glider@google.com, kcc@google.com, Andrey Konovalov <andreyknvl@google.com>

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 Documentation/kasan.txt | 43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
index 0d32355..d2f4c8f 100644
--- a/Documentation/kasan.txt
+++ b/Documentation/kasan.txt
@@ -1,32 +1,31 @@
-Kernel address sanitizer
-================
+KernelAddressSanitizer (KASAN)
+==============================
 
 0. Overview
 ===========
 
-Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
+KernelAddressSANitizer (KASAN) is a dynamic memory error detector. It provides
 a fast and comprehensive solution for finding use-after-free and out-of-bounds
 bugs.
 
-KASan uses compile-time instrumentation for checking every memory access,
-therefore you will need a gcc version of 4.9.2 or later. KASan could detect out
-of bounds accesses to stack or global variables, but only if gcc 5.0 or later was
-used to built the kernel.
+KASAN uses compile-time instrumentation for checking every memory access,
+therefore you will need a GCC version 4.9.2 or later. GCC 5.0 or later is
+required for detection of out-of-bounds accesses to stack or global variables.
 
-Currently KASan is supported only for x86_64 architecture and requires that the
-kernel be built with the SLUB allocator.
+Currently KASAN is supported only for x86_64 architecture and requires the
+kernel to be built with the SLUB allocator.
 
 1. Usage
-=========
+========
 
 To enable KASAN configure kernel with:
 
 	  CONFIG_KASAN = y
 
-and choose between CONFIG_KASAN_OUTLINE and CONFIG_KASAN_INLINE. Outline/inline
-is compiler instrumentation types. The former produces smaller binary the
-latter is 1.1 - 2 times faster. Inline instrumentation requires a gcc version
-of 5.0 or later.
+and choose between CONFIG_KASAN_OUTLINE and CONFIG_KASAN_INLINE. Outline and
+inline are compiler instrumentation types. The former produces smaller binary
+the latter is 1.1 - 2 times faster. Inline instrumentation requires a GCC
+version 5.0 or later.
 
 Currently KASAN works only with the SLUB memory allocator.
 For better bug detection and nicer report, enable CONFIG_STACKTRACE and put
@@ -42,7 +41,7 @@ similar to the following to the respective kernel Makefile:
                 KASAN_SANITIZE := n
 
 1.1 Error reports
-==========
+=================
 
 A typical out of bounds access report looks like this:
 
@@ -119,14 +118,16 @@ Memory state around the buggy address:
  ffff8800693bc800: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ==================================================================
 
-First sections describe slub object where bad access happened.
-See 'SLUB Debug output' section in Documentation/vm/slub.txt for details.
+The header of the report discribe what kind of bug happend and what kind of
+access caused it. It's followed by the description of the accessed slub object
+(see 'SLUB Debug output' section in Documentation/vm/slub.txt for details) and
+the description of the accessed memory page.
 
 In the last section the report shows memory state around the accessed address.
-Reading this part requires some more understanding of how KASAN works.
+Reading this part requires some understanding of how KASAN works.
 
-Each 8 bytes of memory are encoded in one shadow byte as accessible,
-partially accessible, freed or they can be part of a redzone.
+The state of each 8 aligned bytes of memory is encoded in one shadow byte.
+Those 8 bytes can be accessible, partially accessible, freed or be a redzone.
 We use the following encoding for each shadow byte: 0 means that all 8 bytes
 of the corresponding memory region are accessible; number N (1 <= N <= 7) means
 that the first N bytes are accessible, and other (8 - N) bytes are not;
@@ -139,7 +140,7 @@ the accessed address is partially accessible.
 
 
 2. Implementation details
-========================
+=========================
 
 From a high level, our approach to memory error detection is similar to that
 of kmemcheck: use shadow memory to record whether each byte of memory is safe
-- 
2.6.0.rc0.131.gf624c3d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
