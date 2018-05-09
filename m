Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6D76B0583
	for <linux-mm@kvack.org>; Wed,  9 May 2018 16:02:41 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s8-v6so20028404pgf.0
        for <linux-mm@kvack.org>; Wed, 09 May 2018 13:02:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t25sor8179392pfj.60.2018.05.09.13.02.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 13:02:40 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 5/6] mm: Use overflow helpers in kvmalloc()
Date: Wed,  9 May 2018 13:02:22 -0700
Message-Id: <20180509200223.22451-6-keescook@chromium.org>
In-Reply-To: <20180509200223.22451-1-keescook@chromium.org>
References: <20180509200223.22451-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

Instead of open-coded multiplication and bounds checking, use the new
overflow helper. Additionally prepare for vmalloc() users to add
array_size()-family helpers in the future.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/mm.h      | 7 +++++--
 include/linux/vmalloc.h | 1 +
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06a4be6..7cb1c6a6bf82 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -25,6 +25,7 @@
 #include <linux/err.h>
 #include <linux/page_ref.h>
 #include <linux/memremap.h>
+#include <linux/overflow.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -560,10 +561,12 @@ static inline void *kvzalloc(size_t size, gfp_t flags)
 
 static inline void *kvmalloc_array(size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > SIZE_MAX / size)
+	size_t bytes;
+
+	if (unlikely(check_mul_overflow(n, size, &bytes)))
 		return NULL;
 
-	return kvmalloc(n * size, flags);
+	return kvmalloc(bytes, flags);
 }
 
 extern void kvfree(const void *addr);
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 1e5d8c392f15..398e9c95cd61 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -8,6 +8,7 @@
 #include <linux/llist.h>
 #include <asm/page.h>		/* pgprot_t */
 #include <linux/rbtree.h>
+#include <linux/overflow.h>
 
 struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 struct notifier_block;		/* in notifier.h */
-- 
2.17.0
