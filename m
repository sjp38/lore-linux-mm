Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 50E7A6B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 02:08:24 -0500 (EST)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p0B78LeV007278
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:08:21 -0800
Received: from iwn39 (iwn39.prod.google.com [10.241.68.103])
	by hpaq7.eem.corp.google.com with ESMTP id p0B78HRq013513
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:08:20 -0800
Received: by iwn39 with SMTP id 39so22618192iwn.41
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:08:17 -0800 (PST)
Date: Mon, 10 Jan 2011 23:08:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix migration hangs on anon_vma lock
Message-ID: <alpine.LSU.2.00.1101102259160.24988@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Increased usage of page migration in mmotm reveals that the anon_vma
locking in unmap_and_move() has been deficient since 2.6.36 (or even
earlier).  Review at the time of f18194275c39835cb84563500995e0d503a32d9a
"mm: fix hang on anon_vma->root->lock" missed the issue here: the anon_vma
to which we get a reference may already have been freed back to its slab
(it is in use when we check page_mapped, but that can change), and so its
anon_vma->root may be switched at any moment by reuse in anon_vma_prepare.

Perhaps we could fix that with a get_anon_vma_unless_zero(), but let's not:
just rely on page_lock_anon_vma() to do all the hard thinking for us, then
we don't need any rcu read locking over here.

In removing the rcu_unlock label: since PageAnon is a bit in page->mapping,
it's impossible for a !page->mapping page to be anon; but insert VM_BUG_ON
in case the implementation ever changes.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org [2.6.37, 2.6.36]
---

 mm/migrate.c |   49 ++++++++++++++++++++-----------------------------
 1 file changed, 20 insertions(+), 29 deletions(-)

--- 2.6.37/mm/migrate.c	2011-01-04 16:50:19.000000000 -0800
+++ linux/mm/migrate.c	2011-01-10 17:23:39.000000000 -0800
@@ -620,7 +620,6 @@ static int unmap_and_move(new_page_t get
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
 	int remap_swapcache = 1;
-	int rcu_locked = 0;
 	int charge = 0;
 	struct mem_cgroup *mem = NULL;
 	struct anon_vma *anon_vma = NULL;
@@ -672,20 +671,27 @@ static int unmap_and_move(new_page_t get
 	/*
 	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
 	 * we cannot notice that anon_vma is freed while we migrates a page.
-	 * This rcu_read_lock() delays freeing anon_vma pointer until the end
+	 * This get_anon_vma() delays freeing anon_vma pointer until the end
 	 * of migration. File cache pages are no problem because of page_lock()
 	 * File Caches may use write_page() or lock_page() in migration, then,
 	 * just care Anon page here.
 	 */
 	if (PageAnon(page)) {
-		rcu_read_lock();
-		rcu_locked = 1;
-
-		/* Determine how to safely use anon_vma */
-		if (!page_mapped(page)) {
-			if (!PageSwapCache(page))
-				goto rcu_unlock;
-
+		/*
+		 * Only page_lock_anon_vma() understands the subtleties of
+		 * getting a hold on an anon_vma from outside one of its mms.
+		 */
+		anon_vma = page_lock_anon_vma(page);
+		if (anon_vma) {
+			/*
+			 * Take a reference count on the anon_vma if the
+			 * page is mapped so that it is guaranteed to
+			 * exist when the page is remapped later
+			 */
+			get_anon_vma(anon_vma);
+			page_unlock_anon_vma(anon_vma);
+		}
+		else if (PageSwapCache(page)) {
 			/*
 			 * We cannot be sure that the anon_vma of an unmapped
 			 * swapcache page is safe to use because we don't
@@ -700,13 +706,7 @@ static int unmap_and_move(new_page_t get
 			 */
 			remap_swapcache = 0;
 		} else {
-			/*
-			 * Take a reference count on the anon_vma if the
-			 * page is mapped so that it is guaranteed to
-			 * exist when the page is remapped later
-			 */
-			anon_vma = page_anon_vma(page);
-			get_anon_vma(anon_vma);
+			goto uncharge;
 		}
 	}
 
@@ -723,16 +723,10 @@ static int unmap_and_move(new_page_t get
 	 * free the metadata, so the page can be freed.
 	 */
 	if (!page->mapping) {
-		if (!PageAnon(page) && page_has_private(page)) {
-			/*
-			 * Go direct to try_to_free_buffers() here because
-			 * a) that's what try_to_release_page() would do anyway
-			 * b) we may be under rcu_read_lock() here, so we can't
-			 *    use GFP_KERNEL which is what try_to_release_page()
-			 *    needs to be effective.
-			 */
+		VM_BUG_ON(PageAnon(page));
+		if (page_has_private(page)) {
 			try_to_free_buffers(page);
-			goto rcu_unlock;
+			goto uncharge;
 		}
 		goto skip_unmap;
 	}
@@ -746,14 +740,11 @@ skip_unmap:
 
 	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
-rcu_unlock:
 
 	/* Drop an anon_vma reference if we took one */
 	if (anon_vma)
 		drop_anon_vma(anon_vma);
 
-	if (rcu_locked)
-		rcu_read_unlock();
 uncharge:
 	if (!charge)
 		mem_cgroup_end_migration(mem, page, newpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
