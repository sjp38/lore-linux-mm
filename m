Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 960C06B007D
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:47 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:46 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 06/12] rmap: annotate lock context change on page_[un]lock_anon_vma()
Date: Thu, 30 Sep 2010 12:50:15 +0900
Message-Id: <1285818621-29890-7-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The page_lock_anon_vma() conditionally grabs RCU and anon_vma lock
but page_unlock_anon_vma() releases them unconditionally. This leads
sparse to complain about context imbalance. Annotate them.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 include/linux/rmap.h |   15 ++++++++++++++-
 mm/rmap.c            |    4 +++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 31b2fd7..0fa7769 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -230,7 +230,20 @@ int try_to_munlock(struct page *);
 /*
  * Called by memory-failure.c to kill processes.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page);
+struct anon_vma *__page_lock_anon_vma(struct page *page);
+
+static inline struct anon_vma *page_lock_anon_vma(struct page *page)
+{
+	struct anon_vma *anon_vma;
+
+	__cond_lock(RCU, anon_vma = __page_lock_anon_vma(page));
+
+	/* (void) is needed to make gcc happy */
+	(void) __cond_lock(&anon_vma->root->lock, anon_vma);
+
+	return anon_vma;
+}
+
 void page_unlock_anon_vma(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 9d2ba01..244ff06 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -314,7 +314,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *__page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma, *root_anon_vma;
 	unsigned long anon_mapping;
@@ -348,6 +348,8 @@ out:
 }
 
 void page_unlock_anon_vma(struct anon_vma *anon_vma)
+	__releases(&anon_vma->root->lock)
+	__releases(RCU)
 {
 	anon_vma_unlock(anon_vma);
 	rcu_read_unlock();
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
