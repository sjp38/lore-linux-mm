Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1934F6B0038
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 01:32:48 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id mc6so6028398lab.31
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 22:32:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si13933489lao.127.2014.09.15.22.32.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 22:32:47 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Tue, 16 Sep 2014 15:31:35 +1000
Subject: [PATCH 2/4] MM: export page_wakeup functions
Message-ID: <20140916053135.22257.22693.stgit@notabene.brown>
In-Reply-To: <20140916051911.22257.24658.stgit@notabene.brown>
References: <20140916051911.22257.24658.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>

This will allow NFS to wait for PG_private to be cleared and,
particularly, to send a wake-up when it is.

Signed-off-by: NeilBrown <neilb@suse.de>
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
