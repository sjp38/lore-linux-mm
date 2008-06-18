Date: Wed, 18 Jun 2008 16:29:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH -mm][BUGFIX] migration_entry_wait fix. v2
Message-Id: <20080618162944.2f8fd265.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080618155233.7dd79312.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<200806181535.58036.nickpiggin@yahoo.com.au>
	<20080618150436.dca5eb75.kamezawa.hiroyu@jp.fujitsu.com>
	<200806181642.38379.nickpiggin@yahoo.com.au>
	<20080618155233.7dd79312.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

In speculative page cache look up protocol, page_count(page) is set to 0
while radix-tree modification is going on, truncation, migration, etc...

While page migration, a page fault to page under migration does
 - look up page table
 - find it is migration_entry_pte
 - decode pfn from migration_entry_pte and get page of pfn_page(pfn)
 - wait until page is unlocked 

It does get_page() -> wait_on_page_locked() -> put_page() now.

In page migration's radix-tree replacement, page_freeze_refs() ->
page_unfreeze_refs() is called. And page_count(page) turns to be zero
and must be kept to be zero while radix-tree replacement.

If get_page() is called against a page under radix-tree replacement,
the kernel panics(). To avoid this, we shouldn't increment page_count()
if it is zero. This patch uses get_page_unless_zero().

Even if get_page_unless_zero() fails, the caller just retries.
But will be a bit busier.

Change log v1->v2:
 - rewrote the patch description and added comments.

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/migrate.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

Index: test-2.6.26-rc5-mm3/mm/migrate.c
===================================================================
--- test-2.6.26-rc5-mm3.orig/mm/migrate.c
+++ test-2.6.26-rc5-mm3/mm/migrate.c
@@ -242,8 +242,15 @@ void migration_entry_wait(struct mm_stru
 		goto out;
 
 	page = migration_entry_to_page(entry);
-
-	get_page(page);
+	/*
+	 * Once radix-tree replacement of page migration started, page_count
+	 * *must* be zero. And, we don't want to call wait_on_page_locked()
+	 * against a page without get_page().
+	 * So, we use get_page_unless_zero(), here. Even failed, page fault
+	 * will occur again.
+	 */
+	if (!get_page_unless_zero(page))
+		goto out;
 	pte_unmap_unlock(ptep, ptl);
 	wait_on_page_locked(page);
 	put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
