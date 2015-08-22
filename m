Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 354FC6B0255
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 06:45:35 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so10523991wid.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:45:34 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id ek10si4315693wib.60.2015.08.22.03.45.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Aug 2015 03:45:31 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so33786668wid.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:45:31 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 2/3] mm/vmalloc: Track vmalloc info changes
Date: Sat, 22 Aug 2015 12:44:59 +0200
Message-Id: <1440240300-6206-3-git-send-email-mingo@kernel.org>
In-Reply-To: <1440240300-6206-1-git-send-email-mingo@kernel.org>
References: <1440240300-6206-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Hansen <dave@sr71.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Linus Torvalds <torvalds@linux-foundation.org>

Add a 'vmap_info_changed' flag to track changes to vmalloc()
statistics.

For simplicity this flag is set every time we unlock the
vmap_area_lock.

This flag is not yet used.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/vmalloc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 605138083880..d21febaa557a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -276,7 +276,9 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define VM_LAZY_FREEING	0x02
 #define VM_VM_AREA	0x04
 
-static DEFINE_SPINLOCK(vmap_area_lock);
+static __cacheline_aligned_in_smp DEFINE_SPINLOCK(vmap_area_lock);
+
+static int vmap_info_changed;
 
 static inline void vmap_lock(void)
 {
@@ -285,6 +287,7 @@ static inline void vmap_lock(void)
 
 static inline void vmap_unlock(void)
 {
+	vmap_info_changed = 1;
 	spin_unlock(&vmap_area_lock);
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
