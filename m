Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BAA8D60079C
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 12:30:15 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 04 of 31] update futex compound knowledge
Message-Id: <3fbd2869d7b6664243ae.1264439935@v2.random>
In-Reply-To: <patchbomb.1264439931@v2.random>
References: <patchbomb.1264439931@v2.random>
Date: Mon, 25 Jan 2010 18:18:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Futex code is smarter than most other gup_fast O_DIRECT code and knows about
the compound internals. However now doing a put_page(head_page) will not
release the pin on the tail page taken by gup-fast, leading to all sort of
refcounting bugchecks. Getting a stable head_page is a little tricky.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/kernel/futex.c b/kernel/futex.c
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -218,7 +218,7 @@ get_futex_key(u32 __user *uaddr, int fsh
 {
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
-	struct page *page;
+	struct page *page, *page_head;
 	int err;
 
 	/*
@@ -250,10 +250,32 @@ again:
 	if (err < 0)
 		return err;
 
-	page = compound_head(page);
-	lock_page(page);
-	if (!page->mapping) {
-		unlock_page(page);
+	page_head = page;
+	if (unlikely(PageTail(page))) {
+		put_page(page);
+		/* serialize against __split_huge_page_splitting() */
+		local_irq_disable();
+		if (likely(__get_user_pages_fast(address, 1, 1, &page) == 1)) {
+			page_head = compound_head(page);
+			local_irq_enable();
+		} else {
+			local_irq_enable();
+			goto again;
+		}
+	}
+
+	lock_page(page_head);
+	if (unlikely(page_head != page)) {
+		compound_lock(page_head);
+		if (unlikely(!PageTail(page))) {
+			compound_unlock(page_head);
+			unlock_page(page_head);
+			put_page(page);
+			goto again;
+		}
+	}
+	if (!page_head->mapping) {
+		unlock_page(page_head);
 		put_page(page);
 		goto again;
 	}
@@ -265,19 +287,21 @@ again:
 	 * it's a read-only handle, it's expected that futexes attach to
 	 * the object not the particular process.
 	 */
-	if (PageAnon(page)) {
+	if (PageAnon(page_head)) {
 		key->both.offset |= FUT_OFF_MMSHARED; /* ref taken on mm */
 		key->private.mm = mm;
 		key->private.address = address;
 	} else {
 		key->both.offset |= FUT_OFF_INODE; /* inode-based key */
-		key->shared.inode = page->mapping->host;
-		key->shared.pgoff = page->index;
+		key->shared.inode = page_head->mapping->host;
+		key->shared.pgoff = page_head->index;
 	}
 
 	get_futex_key_refs(key);
 
-	unlock_page(page);
+	if (unlikely(PageTail(page)))
+		compound_unlock(page_head);
+	unlock_page(page_head);
 	put_page(page);
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
