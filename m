Message-ID: <447BD9CE.2020505@yahoo.com.au>
Date: Tue, 30 May 2006 15:36:14 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au>
In-Reply-To: <447BD31E.7000503@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------050607000805040600010202"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050607000805040600010202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> Anyway, clearly a plug friendly bugfix needs to be implemented
> regardless.

I actually think it would be cleaner to introduce a new
mapping_lock_page(mapping, page) or something that does the
unplug on the _mapping_, and have lock_page be callable with
no ref on the inode. Should be a mechanical conversion for
most of the safe callers.

But for 2.6.17, how's this?

-- 
SUSE Labs, Novell Inc.

--------------050607000805040600010202
Content-Type: text/plain;
 name="mm-non-syncing-lock_page.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-non-syncing-lock_page.patch"

lock_page needs the caller to have a reference on the page->mapping inode
due to sync_page. So set_page_dirty_lock is obviously buggy according to
its comments.

Solve it by introducing a new lock_page_nosync which does not do a sync_page. 

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2006-05-19 12:49:06.000000000 +1000
+++ linux-2.6/include/linux/pagemap.h	2006-05-30 15:12:54.000000000 +1000
@@ -168,6 +168,7 @@ static inline pgoff_t linear_page_index(
 }
 
 extern void FASTCALL(__lock_page(struct page *page));
+extern void FASTCALL(__lock_page_nosync(struct page *page));
 extern void FASTCALL(unlock_page(struct page *page));
 
 static inline void lock_page(struct page *page)
@@ -176,6 +177,13 @@ static inline void lock_page(struct page
 	if (TestSetPageLocked(page))
 		__lock_page(page);
 }
+
+static inline void lock_page_nosync(struct page *page)
+{
+	might_sleep();
+	if (TestSetPageLocked(page))
+		__lock_page_nosync(page);
+}
 	
 /*
  * This is exported only for wait_on_page_locked/wait_on_page_writeback.
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2006-05-30 15:07:58.000000000 +1000
+++ linux-2.6/mm/filemap.c	2006-05-30 15:31:46.000000000 +1000
@@ -544,6 +544,23 @@ void fastcall __lock_page(struct page *p
 }
 EXPORT_SYMBOL(__lock_page);
 
+static int __sleep_on_page_lock(void *word)
+{
+	io_schedule();
+	return 0;
+}
+
+/*
+ * Variant of lock_page that does not require the caller to hold a reference
+ * on the page's mapping.
+ */
+void fastcall __lock_page_nosync(struct page *page)
+{
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	__wait_on_bit_lock(page_waitqueue(page), &wait, __sleep_on_page_lock,
+							TASK_UNINTERRUPTIBLE);
+}
+
 /*
  * a rather lightweight function, finding and getting a reference to a
  * hashed page atomically.
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2006-05-19 12:48:01.000000000 +1000
+++ linux-2.6/mm/page-writeback.c	2006-05-30 15:13:59.000000000 +1000
@@ -702,7 +702,7 @@ int set_page_dirty_lock(struct page *pag
 {
 	int ret;
 
-	lock_page(page);
+	lock_page_nosync(page);
 	ret = set_page_dirty(page);
 	unlock_page(page);
 	return ret;

--------------050607000805040600010202--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
