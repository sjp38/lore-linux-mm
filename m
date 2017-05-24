Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5A6A6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 17:01:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 62so204535488pft.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 14:01:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b17sor1810699pfh.15.2017.05.24.14.01.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 May 2017 14:01:17 -0700 (PDT)
Date: Wed, 24 May 2017 14:01:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] compiler, clang: suppress warning for unused static inline
 functions
Message-ID: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthias Kaehlcke <mka@chromium.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Douglas Anderson <dianders@chromium.org>

GCC explicitly does not warn for unused static inline functions for
-Wunused-function.  The manual states:

	Warn whenever a static function is declared but not defined or
	a non-inline static function is unused.

Clang does warn for static inline functions that are unused.

It turns out that suppressing the warnings avoids potentially complex
#ifdef directives, which also reduces LOC.

Supress the warning for clang.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/compiler-clang.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -15,3 +15,10 @@
  * with any version that can compile the kernel
  */
 #define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __COUNTER__)
+
+/*
+ * GCC does not warn about unused static inline functions for
+ * -Wunused-function.  This turns out to avoid the need for complex #ifdef
+ * directives.  Suppress the warning in clang as well.
+ */
+#define inline inline __attribute__((unused))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
