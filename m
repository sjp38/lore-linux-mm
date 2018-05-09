Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 17B076B02F2
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:46 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x2-v6so2741836plv.0
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a33-v6sor8246907pli.106.2018.05.08.17.42.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:44 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 05/13] mm: Use array_size() helpers for kvmalloc()
Date: Tue,  8 May 2018 17:42:21 -0700
Message-Id: <20180509004229.36341-6-keescook@chromium.org>
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
References: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Instead of open-coded multiplication, use the new array_size() helper
to detect overflow in kvmalloc()-family functions.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/mm.h      | 6 +++---
 include/linux/vmalloc.h | 1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06a4be6..c97ed9aa3412 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -25,6 +25,7 @@
 #include <linux/err.h>
 #include <linux/page_ref.h>
 #include <linux/memremap.h>
+#include <linux/overflow.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -560,10 +561,9 @@ static inline void *kvzalloc(size_t size, gfp_t flags)
 
 static inline void *kvmalloc_array(size_t n, size_t size, gfp_t flags)
 {
-	if (size != 0 && n > SIZE_MAX / size)
-		return NULL;
+	size_t bytes = array_size(n, size);
 
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
