Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7BF4A8D0039
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 19:52:45 -0400 (EDT)
Date: Sun, 20 Mar 2011 00:51:44 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110319235144.GG10696@random.random>
References: <4D7FEDDC.3020607@fiec.espol.edu.ec>
 <20110315161926.595bdb65.akpm@linux-foundation.org>
 <4D80D65C.5040504@fiec.espol.edu.ec>
 <20110316150208.7407c375.akpm@linux-foundation.org>
 <4D827CC1.4090807@fiec.espol.edu.ec>
 <20110317144727.87a461f9.akpm@linux-foundation.org>
 <20110318111300.GF707@csn.ul.ie>
 <4D839EDB.9080703@fiec.espol.edu.ec>
 <20110319134628.GG707@csn.ul.ie>
 <4D84D3F2.4010200@fiec.espol.edu.ec>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4D84D3F2.4010200@fiec.espol.edu.ec>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?iso-8859-1?B?VmlsbGFj7a1z?= Lasso <avillaci@fiec.espol.edu.ec>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Sat, Mar 19, 2011 at 11:04:02AM -0500, Alex Villaci-s Lasso wrote:
> The patch did not help. I have attached a sysrq-w trace with the patch applied in the bug report.

Most processes are stuck in udf_writepage. That's because migrate is
calling ->writepage on dirty pages even when sync=0.

This may do better, can you test it in replacement of the previous
patch?

Thanks,
Andrea

===
Subject: compaction: use async migrate for __GFP_NO_KSWAPD

From: Andrea Arcangeli <aarcange@redhat.com>

__GFP_NO_KSWAPD allocations are usually very expensive and not mandatory to
succeed (they have graceful fallback). Waiting for I/O in those, tends to be
overkill in terms of latencies, so we can reduce their latency by disabling
sync migrate.

Stop calling ->writepage on dirty cache when migrate sync mode is not set.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/migrate.c    |   35 ++++++++++++++++++++++++++---------
 mm/page_alloc.c |    2 +-
 2 files changed, 27 insertions(+), 10 deletions(-)

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
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -536,10 +536,15 @@ static int writeout(struct address_space
  * Default handling if a filesystem does not provide a migration function.
  */
 static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page)
+				 struct page *newpage, struct page *page,
+				 int sync)
 {
-	if (PageDirty(page))
-		return writeout(mapping, page);
+	if (PageDirty(page)) {
+		if (sync)
+			return writeout(mapping, page);
+		else
+			return -EBUSY;
+	}
 
 	/*
 	 * Buffers may be managed in a filesystem specific way.
@@ -564,7 +569,7 @@ static int fallback_migrate_page(struct 
  *  == 0 - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
-						int remap_swapcache)
+			    int remap_swapcache, int sync)
 {
 	struct address_space *mapping;
 	int rc;
@@ -597,7 +602,7 @@ static int move_to_new_page(struct page 
 		rc = mapping->a_ops->migratepage(mapping,
 						newpage, page);
 	else
-		rc = fallback_migrate_page(mapping, newpage, page);
+		rc = fallback_migrate_page(mapping, newpage, page, sync);
 
 	if (rc) {
 		newpage->mapping = NULL;
@@ -641,6 +646,10 @@ static int unmap_and_move(new_page_t get
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {
+		if (!sync) {
+			rc = -EBUSY;
+			goto move_newpage;
+		}
 		if (!force)
 			goto move_newpage;
 
@@ -686,7 +695,11 @@ static int unmap_and_move(new_page_t get
 	BUG_ON(charge);
 
 	if (PageWriteback(page)) {
-		if (!force || !sync)
+		if (!sync) {
+			rc = -EBUSY;
+			goto uncharge;
+		}
+		if (!force)
 			goto uncharge;
 		wait_on_page_writeback(page);
 	}
@@ -757,7 +770,7 @@ static int unmap_and_move(new_page_t get
 
 skip_unmap:
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, remap_swapcache);
+		rc = move_to_new_page(newpage, page, remap_swapcache, sync);
 
 	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
@@ -834,7 +847,11 @@ static int unmap_and_move_huge_page(new_
 	rc = -EAGAIN;
 
 	if (!trylock_page(hpage)) {
-		if (!force || !sync)
+		if (!sync) {
+			rc = -EBUSY;
+			goto out;
+		}
+		if (!force)
 			goto out;
 		lock_page(hpage);
 	}
@@ -850,7 +867,7 @@ static int unmap_and_move_huge_page(new_
 	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
 	if (!page_mapped(hpage))
-		rc = move_to_new_page(new_hpage, hpage, 1);
+		rc = move_to_new_page(new_hpage, hpage, 1, sync);
 
 	if (rc)
 		remove_migration_ptes(hpage, hpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
