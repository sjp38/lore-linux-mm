Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1DCC38D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 11:41:44 -0400 (EDT)
Date: Mon, 21 Mar 2011 16:40:10 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110321154010.GE5719@random.random>
References: <4D827CC1.4090807@fiec.espol.edu.ec>
 <20110317144727.87a461f9.akpm@linux-foundation.org>
 <20110318111300.GF707@csn.ul.ie>
 <4D839EDB.9080703@fiec.espol.edu.ec>
 <20110319134628.GG707@csn.ul.ie>
 <4D84D3F2.4010200@fiec.espol.edu.ec>
 <20110319235144.GG10696@random.random>
 <20110321094149.GH707@csn.ul.ie>
 <20110321134832.GC5719@random.random>
 <4D876D43.3020409@fiec.espol.edu.ec>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4D876D43.3020409@fiec.espol.edu.ec>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?iso-8859-1?B?VmlsbGFj7a1z?= Lasso <avillaci@fiec.espol.edu.ec>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Mon, Mar 21, 2011 at 10:22:43AM -0500, Alex Villaci-s Lasso wrote:
> I will try to apply the patch manually.

Hmm, I checked that this latest version below applies clean both
against vanilla 2.6.38 and current current git. It should apply clean
if you run:

     "git fetch; git checkout -f origin/master"

or "git checkout -f v2.6.38"

I got this and another migrate patch from Hugh both applied in aa.git
so you may use that one too if you want:

     "git clone --reference linux-2.6 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git"

(with --reference it should clone very fast, linux-2.6 must be a clone
of the upstream linux-2.6.git tree)

Thanks,
Andrea

===
Subject: mm: compaction: Use async migration for __GFP_NO_KSWAPD and enforce no writeback

From: Andrea Arcangeli <aarcange@redhat.com>

__GFP_NO_KSWAPD allocations are usually very expensive and not mandatory
to succeed as they have graceful fallback. Waiting for I/O in those, tends
to be overkill in terms of latencies, so we can reduce their latency by
disabling sync migrate.

Unfortunately, even with async migration it's still possible for the
process to be blocked waiting for a request slot (e.g. get_request_wait
in the block layer) when ->writepage is called. To prevent __GFP_NO_KSWAPD
blocking, this patch prevents ->writepage being called on dirty page cache
for asynchronous migration.

[mel@csn.ul.ie: Avoid writebacks for NFS, retry locked pages, use bool]
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/migrate.c    |   48 +++++++++++++++++++++++++++++++++---------------
 mm/page_alloc.c |    2 +-
 2 files changed, 34 insertions(+), 16 deletions(-)

--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -564,7 +564,7 @@ static int fallback_migrate_page(struct 
  *  == 0 - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
-						int remap_swapcache)
+					int remap_swapcache, bool sync)
 {
 	struct address_space *mapping;
 	int rc;
@@ -586,18 +586,28 @@ static int move_to_new_page(struct page 
 	mapping = page_mapping(page);
 	if (!mapping)
 		rc = migrate_page(mapping, newpage, page);
-	else if (mapping->a_ops->migratepage)
+	else {
 		/*
-		 * Most pages have a mapping and most filesystems
-		 * should provide a migration function. Anonymous
-		 * pages are part of swap space which also has its
-		 * own migration function. This is the most common
-		 * path for page migration.
+		 * Do not writeback pages if !sync and migratepage is
+		 * not pointing to migrate_page() which is nonblocking
+		 * (swapcache/tmpfs uses migratepage = migrate_page).
 		 */
-		rc = mapping->a_ops->migratepage(mapping,
-						newpage, page);
-	else
-		rc = fallback_migrate_page(mapping, newpage, page);
+		if (PageDirty(page) && !sync &&
+		    mapping->a_ops->migratepage != migrate_page)
+			rc = -EBUSY;
+		else if (mapping->a_ops->migratepage)
+			/*
+			 * Most pages have a mapping and most filesystems
+			 * should provide a migration function. Anonymous
+			 * pages are part of swap space which also has its
+			 * own migration function. This is the most common
+			 * path for page migration.
+			 */
+			rc = mapping->a_ops->migratepage(mapping,
+							newpage, page);
+		else
+			rc = fallback_migrate_page(mapping, newpage, page);
+	}
 
 	if (rc) {
 		newpage->mapping = NULL;
@@ -641,7 +651,7 @@ static int unmap_and_move(new_page_t get
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {
-		if (!force)
+		if (!force || !sync)
 			goto move_newpage;
 
 		/*
@@ -686,7 +696,15 @@ static int unmap_and_move(new_page_t get
 	BUG_ON(charge);
 
 	if (PageWriteback(page)) {
-		if (!force || !sync)
+		/*
+		 * For !sync, there is no point retrying as the retry loop
+		 * is expected to be too short for PageWriteback to be cleared
+		 */
+		if (!sync) {
+			rc = -EBUSY;
+			goto uncharge;
+		}
+		if (!force)
 			goto uncharge;
 		wait_on_page_writeback(page);
 	}
@@ -757,7 +775,7 @@ static int unmap_and_move(new_page_t get
 
 skip_unmap:
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, remap_swapcache);
+		rc = move_to_new_page(newpage, page, remap_swapcache, sync);
 
 	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
@@ -850,7 +868,7 @@ static int unmap_and_move_huge_page(new_
 	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
 	if (!page_mapped(hpage))
-		rc = move_to_new_page(new_hpage, hpage, 1);
+		rc = move_to_new_page(new_hpage, hpage, 1, sync);
 
 	if (rc)
 		remove_migration_ptes(hpage, hpage);
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2085,7 +2085,7 @@ rebalance:
 					sync_migration);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+	sync_migration = !(gfp_mask & __GFP_NO_KSWAPD);
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
