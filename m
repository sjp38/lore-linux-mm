Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30EB36B0261
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:47:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so67424142pfb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 00:47:28 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id j7si3952107paj.199.2016.04.27.00.47.25
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 00:47:25 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 05/12] zsmalloc: use bit_spin_lock
Date: Wed, 27 Apr 2016 16:48:18 +0900
Message-Id: <1461743305-19970-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1461743305-19970-1-git-send-email-minchan@kernel.org>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Use kernel standard bit spin-lock instead of custom mess. Even, it has
a bug which doesn't disable preemption. The reason we don't have any
problem is that we have used it during preemption disable section
by class->lock spinlock. So no need to go to stable.

Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 8649d0243e6c..d75d9e4b6a4d 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -864,21 +864,17 @@ static unsigned long obj_idx_to_offset(struct page *page,
 
 static inline int trypin_tag(unsigned long handle)
 {
-	unsigned long *ptr = (unsigned long *)handle;
-
-	return !test_and_set_bit_lock(HANDLE_PIN_BIT, ptr);
+	return bit_spin_trylock(HANDLE_PIN_BIT, (unsigned long *)handle);
 }
 
 static void pin_tag(unsigned long handle)
 {
-	while (!trypin_tag(handle));
+	bit_spin_lock(HANDLE_PIN_BIT, (unsigned long *)handle);
 }
 
 static void unpin_tag(unsigned long handle)
 {
-	unsigned long *ptr = (unsigned long *)handle;
-
-	clear_bit_unlock(HANDLE_PIN_BIT, ptr);
+	bit_spin_unlock(HANDLE_PIN_BIT, (unsigned long *)handle);
 }
 
 static void reset_page(struct page *page)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
