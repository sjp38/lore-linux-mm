Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22D246B025E
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 13:23:02 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so1522587876pgc.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:23:02 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id d189si69745282pga.29.2017.01.03.10.23.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 10:23:01 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id c4so25978592pfb.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:23:01 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 2/2] mm: un-export wake_up_page functions
Date: Wed,  4 Jan 2017 04:22:34 +1000
Message-Id: <20170103182234.30141-3-npiggin@gmail.com>
In-Reply-To: <20170103182234.30141-1-npiggin@gmail.com>
References: <20170103182234.30141-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-nfs@vger.kernel.org, linux-mm@kvack.org, NeilBrown <neilb@suse.de>, Trond Myklebust <trond.myklebust@primarydata.com>

These are no longer used outside mm/filemap.c, so un-export them and
make them static where possible. These were exported specifically for
NFS use in commit a4796e37c12e ("MM: export page_wakeup functions").

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 include/linux/pagemap.h | 12 ++----------
 mm/filemap.c            | 10 ++++++++--
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 324c8dbad1e1..b572f5530392 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -482,19 +482,11 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 }
 
 /*
- * This is exported only for wait_on_page_locked/wait_on_page_writeback,
- * and for filesystems which need to wait on PG_private.
+ * This is exported only for wait_on_page_locked/wait_on_page_writeback, etc.,
+ * and should not be used directly.
  */
 extern void wait_on_page_bit(struct page *page, int bit_nr);
 extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
-extern void wake_up_page_bit(struct page *page, int bit_nr);
-
-static inline void wake_up_page(struct page *page, int bit)
-{
-	if (!PageWaiters(page))
-		return;
-	wake_up_page_bit(page, bit);
-}
 
 /* 
  * Wait for a page to be unlocked.
diff --git a/mm/filemap.c b/mm/filemap.c
index d0e4d1002059..52115b967688 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -788,7 +788,7 @@ static int wake_page_function(wait_queue_t *wait, unsigned mode, int sync, void
 	return autoremove_wake_function(wait, mode, sync, key);
 }
 
-void wake_up_page_bit(struct page *page, int bit_nr)
+static void wake_up_page_bit(struct page *page, int bit_nr)
 {
 	wait_queue_head_t *q = page_waitqueue(page);
 	struct wait_page_key key;
@@ -821,7 +821,13 @@ void wake_up_page_bit(struct page *page, int bit_nr)
 	}
 	spin_unlock_irqrestore(&q->lock, flags);
 }
-EXPORT_SYMBOL(wake_up_page_bit);
+
+static void wake_up_page(struct page *page, int bit)
+{
+	if (!PageWaiters(page))
+		return;
+	wake_up_page_bit(page, bit);
+}
 
 static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 		struct page *page, int bit_nr, int state, bool lock)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
