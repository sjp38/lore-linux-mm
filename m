Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 053D66B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 00:18:23 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so4651200igb.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 21:18:22 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id h8si5143583igh.81.2015.10.07.21.18.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Oct 2015 21:18:21 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH -next] mm/vmacache: inline vmacache_valid_mm()
Date: Wed,  7 Oct 2015 21:17:59 -0700
Message-Id: <1444277879-22039-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Davidlohr Bueso <dbueso@suse.de>

This function incurs in very hot paths and merely
does a few loads for validity check. Lets inline it,
such that we can save the function call overhead.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/vmacache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmacache.c b/mm/vmacache.c
index b6e3662..fd09dc9 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -52,7 +52,7 @@ void vmacache_flush_all(struct mm_struct *mm)
  * Also handle the case where a kernel thread has adopted this mm via use_mm().
  * That kernel thread's vmacache is not applicable to this mm.
  */
-static bool vmacache_valid_mm(struct mm_struct *mm)
+static inline bool vmacache_valid_mm(struct mm_struct *mm)
 {
 	return current->mm == mm && !(current->flags & PF_KTHREAD);
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
