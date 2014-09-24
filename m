Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id AA3936B0038
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 22:03:23 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id s18so9867277lam.28
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:03:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8si20933298lbp.24.2014.09.23.19.03.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 19:03:22 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 24 Sep 2014 11:28:32 +1000
Subject: [PATCH 2/5] MM: export page_wakeup functions
Message-ID: <20140924012832.4838.33763.stgit@notabene.brown>
In-Reply-To: <20140924012422.4838.29188.stgit@notabene.brown>
References: <20140924012422.4838.29188.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>

This will allow NFS to wait for PG_private to be cleared and,
particularly, to send a wake-up when it is.

Signed-off-by: NeilBrown <neilb@suse.de>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/pagemap.h |   10 ++++++++--
 mm/filemap.c            |    8 ++------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 87f9e4230d3a..2dca0cef3506 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -496,8 +496,8 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 }
 
 /*
- * This is exported only for wait_on_page_locked/wait_on_page_writeback.
- * Never use this directly!
+ * This is exported only for wait_on_page_locked/wait_on_page_writeback,
+ * and for filesystems which need to wait on PG_private.
  */
 extern void wait_on_page_bit(struct page *page, int bit_nr);
 
@@ -512,6 +512,12 @@ static inline int wait_on_page_locked_killable(struct page *page)
 	return 0;
 }
 
+extern wait_queue_head_t *page_waitqueue(struct page *page);
+static inline void wake_up_page(struct page *page, int bit)
+{
+	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
+}
+
 /* 
  * Wait for a page to be unlocked.
  *
diff --git a/mm/filemap.c b/mm/filemap.c
index 4a19c084bdb1..c9ba09f2ad3c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -670,17 +670,13 @@ EXPORT_SYMBOL(__page_cache_alloc);
  * at a cost of "thundering herd" phenomena during rare hash
  * collisions.
  */
-static wait_queue_head_t *page_waitqueue(struct page *page)
+wait_queue_head_t *page_waitqueue(struct page *page)
 {
 	const struct zone *zone = page_zone(page);
 
 	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
 }
-
-static inline void wake_up_page(struct page *page, int bit)
-{
-	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
-}
+EXPORT_SYMBOL(page_waitqueue);
 
 void wait_on_page_bit(struct page *page, int bit_nr)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
