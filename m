Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1468C6B006A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 03:18:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6781cq1031224
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Jul 2009 17:01:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ACD1945DE58
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 17:01:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AEA3C45DE5A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 17:01:35 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F6A6E08005
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 17:01:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BE9B1DB8044
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 17:01:33 +0900 (JST)
Date: Tue, 7 Jul 2009 16:59:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/4] get_user_pages READ fault handling special cases
Message-Id: <20090707165950.7a84145a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

most of parts are overwritten by 4/4 patch.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, get_user_pages(READ) can return ZERO_PAGE but it creates some trouble.
This patch is a workaround for each callers.
 - mlock() ....ignore ZERO_PAGE if found. This happens only when mlock against
		read-only mapping finds zero pages.
 - futex() ....if ZERO PAGE is found....BUG ?(but possible...)
 - lookup_node() .... no good idea..this is the same behavior to 2.6.23 age.

Others ?

I wonder it's better to add some function to replace
ZERO PAGE to be an usual page..(do copy-on-write if ZERO_PAGE)
in some special cases. (like futex in above.) 

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: zeropage-trial/mm/mlock.c
===================================================================
--- zeropage-trial.orig/mm/mlock.c
+++ zeropage-trial/mm/mlock.c
@@ -220,19 +220,24 @@ static long __mlock_vma_pages_range(stru
 		for (i = 0; i < ret; i++) {
 			struct page *page = pages[i];
 
-			lock_page(page);
+
 			/*
 			 * Because we lock page here and migration is blocked
 			 * by the elevated reference, we need only check for
 			 * page truncation (file-cache only).
+			 *
+			 * The page can be ZERO_PAGE if VM_WRITE is not set.
 			 */
-			if (page->mapping) {
-				if (mlock)
-					mlock_vma_page(page);
-				else
-					munlock_vma_page(page);
+			if (!page_is_zero(page)) {
+				lock_page(page);
+				if (page->mapping) {
+					if (mlock)
+						mlock_vma_page(page);
+					else
+						munlock_vma_page(page);
+				}
+				unlock_page(page);
 			}
-			unlock_page(page);
 			put_page(page);		/* ref from get_user_pages() */
 
 			/*
Index: zeropage-trial/kernel/futex.c
===================================================================
--- zeropage-trial.orig/kernel/futex.c
+++ zeropage-trial/kernel/futex.c
@@ -249,9 +249,23 @@ again:
 
 	lock_page(page);
 	if (!page->mapping) {
+		if (!page_is_zero(page)) {
+			unlock_page(page);
+			put_page(page);
+			goto again;
+		}
+		/*
+	 	* Finding ZERO PAGE here is obviously user's BUG because
+	 	* futex_wake()etc. is called against never-written page.
+	 	* Considering how futex is used, this kind of bug should not
+	 	* happen i.e. very strange system bug. Then, print out message.
+	 	*/
 		unlock_page(page);
 		put_page(page);
-		goto again;
+		printk(KERN_WARNING "futex is called against not-initialized"
+				     "memory %d(%s) at %p", current->pid,
+				     current->comm, (void*)address);
+		return -EINVAL;
 	}
 
 	/*
Index: zeropage-trial/mm/mempolicy.c
===================================================================
--- zeropage-trial.orig/mm/mempolicy.c
+++ zeropage-trial/mm/mempolicy.c
@@ -684,6 +684,10 @@ static int lookup_node(struct mm_struct 
 	struct page *p;
 	int err;
 
+	/*
+	 * This get_user_page() may catch ZERO PAGE. In that case, returned
+	 * value will not be very useful. But we can't return error here.
+	 */
 	err = get_user_pages(current, mm, addr & PAGE_MASK, 1, 0, 0, &p, NULL);
 	if (err >= 0) {
 		err = page_to_nid(p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
