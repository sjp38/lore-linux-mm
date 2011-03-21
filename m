Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F0FD58D003A
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 05:41:56 -0400 (EDT)
Date: Mon, 21 Mar 2011 09:41:49 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110321094149.GH707@csn.ul.ie>
References: <20110315161926.595bdb65.akpm@linux-foundation.org>
 <4D80D65C.5040504@fiec.espol.edu.ec>
 <20110316150208.7407c375.akpm@linux-foundation.org>
 <4D827CC1.4090807@fiec.espol.edu.ec>
 <20110317144727.87a461f9.akpm@linux-foundation.org>
 <20110318111300.GF707@csn.ul.ie>
 <4D839EDB.9080703@fiec.espol.edu.ec>
 <20110319134628.GG707@csn.ul.ie>
 <4D84D3F2.4010200@fiec.espol.edu.ec>
 <20110319235144.GG10696@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110319235144.GG10696@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alex Villac??s Lasso <avillaci@fiec.espol.edu.ec>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Sun, Mar 20, 2011 at 12:51:44AM +0100, Andrea Arcangeli wrote:
> On Sat, Mar 19, 2011 at 11:04:02AM -0500, Alex Villaci-s Lasso wrote:
> > The patch did not help. I have attached a sysrq-w trace with the patch applied in the bug report.
> 
> Most processes are stuck in udf_writepage. That's because migrate is
> calling ->writepage on dirty pages even when sync=0.
> 
> This may do better, can you test it in replacement of the previous
> patch?
> 
> ===
> Subject: compaction: use async migrate for __GFP_NO_KSWAPD
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> __GFP_NO_KSWAPD allocations are usually very expensive and not mandatory to
> succeed (they have graceful fallback). Waiting for I/O in those, tends to be
> overkill in terms of latencies, so we can reduce their latency by disabling
> sync migrate.
> 
> Stop calling ->writepage on dirty cache when migrate sync mode is not set.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/migrate.c    |   35 ++++++++++++++++++++++++++---------
>  mm/page_alloc.c |    2 +-
>  2 files changed, 27 insertions(+), 10 deletions(-)
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2085,7 +2085,7 @@ rebalance:
>  					sync_migration);
>  	if (page)
>  		goto got_pg;
> -	sync_migration = true;
> +	sync_migration = !(gfp_mask & __GFP_NO_KSWAPD);
>  
>  	/* Try direct reclaim and then allocating */
>  	page = __alloc_pages_direct_reclaim(gfp_mask, order,
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -536,10 +536,15 @@ static int writeout(struct address_space
>   * Default handling if a filesystem does not provide a migration function.
>   */
>  static int fallback_migrate_page(struct address_space *mapping,
> -	struct page *newpage, struct page *page)
> +				 struct page *newpage, struct page *page,
> +				 int sync)
>  {
> -	if (PageDirty(page))
> -		return writeout(mapping, page);
> +	if (PageDirty(page)) {
> +		if (sync)
> +			return writeout(mapping, page);
> +		else
> +			return -EBUSY;
> +	}
>  
>  	/*
>  	 * Buffers may be managed in a filesystem specific way.

The check is at the wrong level I believe because it misses NFS pages which
will still get queued for IO which can block waiting on a request to complete.

> @@ -564,7 +569,7 @@ static int fallback_migrate_page(struct 
>   *  == 0 - success
>   */
>  static int move_to_new_page(struct page *newpage, struct page *page,
> -						int remap_swapcache)
> +			    int remap_swapcache, int sync)

sync should be bool.

>  {
>  	struct address_space *mapping;
>  	int rc;
> @@ -597,7 +602,7 @@ static int move_to_new_page(struct page 
>  		rc = mapping->a_ops->migratepage(mapping,
>  						newpage, page);
>  	else
> -		rc = fallback_migrate_page(mapping, newpage, page);
> +		rc = fallback_migrate_page(mapping, newpage, page, sync);
>  
>  	if (rc) {
>  		newpage->mapping = NULL;
> @@ -641,6 +646,10 @@ static int unmap_and_move(new_page_t get
>  	rc = -EAGAIN;
>  
>  	if (!trylock_page(page)) {
> +		if (!sync) {
> +			rc = -EBUSY;
> +			goto move_newpage;
> +		}

It's overkill to return EBUSY just because we failed to get a lock which could
be released very quickly. If we left rc as -EAGAIN it would retry again.
The worst case scenario is that the current process is the holder of the
lock and the loop is pointless but this is a relatively rare situation
(other than Hugh's loopback test aside which seems to be particularly good
at triggering that situation).

>  		if (!force)
>  			goto move_newpage;
>  
> @@ -686,7 +695,11 @@ static int unmap_and_move(new_page_t get
>  	BUG_ON(charge);
>  
>  	if (PageWriteback(page)) {
> -		if (!force || !sync)
> +		if (!sync) {
> +			rc = -EBUSY;
> +			goto uncharge;
> +		}
> +		if (!force)
>  			goto uncharge;

Where as this is ok because if the page is being written back, it's fairly
unlikely it'll get cleared quickly enough for the retry loop to make sense.

>  		wait_on_page_writeback(page);
>  	}
> @@ -757,7 +770,7 @@ static int unmap_and_move(new_page_t get
>  
>  skip_unmap:
>  	if (!page_mapped(page))
> -		rc = move_to_new_page(newpage, page, remap_swapcache);
> +		rc = move_to_new_page(newpage, page, remap_swapcache, sync);
>  
>  	if (rc && remap_swapcache)
>  		remove_migration_ptes(page, page);
> @@ -834,7 +847,11 @@ static int unmap_and_move_huge_page(new_
>  	rc = -EAGAIN;
>  
>  	if (!trylock_page(hpage)) {
> -		if (!force || !sync)
> +		if (!sync) {
> +			rc = -EBUSY;
> +			goto out;
> +		}
> +		if (!force)
>  			goto out;
>  		lock_page(hpage);
>  	}

As before, it's worth retrying to get the lock as it could be released
very shortly.

> @@ -850,7 +867,7 @@ static int unmap_and_move_huge_page(new_
>  	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
>  
>  	if (!page_mapped(hpage))
> -		rc = move_to_new_page(new_hpage, hpage, 1);
> +		rc = move_to_new_page(new_hpage, hpage, 1, sync);
>  
>  	if (rc)
>  		remove_migration_ptes(hpage, hpage);
> 

Because of the NFS pages and being a bit aggressive about using -EBUSY,
how about the following instead? (build tested only unfortunately)

==== CUT HERE ====
mm: compaction: Use async migration for __GFP_NO_KSWAPD and enforce no writeback

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
 mm/migrate.c    |   47 ++++++++++++++++++++++++++++++-----------------
 mm/page_alloc.c |    2 +-
 2 files changed, 31 insertions(+), 18 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 352de555..1b45508 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -564,7 +564,7 @@ static int fallback_migrate_page(struct address_space *mapping,
  *  == 0 - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
-						int remap_swapcache)
+					int remap_swapcache, bool sync)
 {
 	struct address_space *mapping;
 	int rc;
@@ -586,18 +586,23 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	mapping = page_mapping(page);
 	if (!mapping)
 		rc = migrate_page(mapping, newpage, page);
-	else if (mapping->a_ops->migratepage)
-		/*
-		 * Most pages have a mapping and most filesystems
-		 * should provide a migration function. Anonymous
-		 * pages are part of swap space which also has its
-		 * own migration function. This is the most common
-		 * path for page migration.
-		 */
-		rc = mapping->a_ops->migratepage(mapping,
-						newpage, page);
-	else
-		rc = fallback_migrate_page(mapping, newpage, page);
+	else {
+		/* Do not writeback pages if !sync */
+		if (PageDirty(page) && !sync)
+			rc = -EBUSY;
+		else if (mapping->a_ops->migratepage)
+			/*
+		 	* Most pages have a mapping and most filesystems
+		 	* should provide a migration function. Anonymous
+		 	* pages are part of swap space which also has its
+		 	* own migration function. This is the most common
+		 	* path for page migration.
+		 	*/
+			rc = mapping->a_ops->migratepage(mapping,
+							newpage, page);
+		else
+			rc = fallback_migrate_page(mapping, newpage, page);
+	}
 
 	if (rc) {
 		newpage->mapping = NULL;
@@ -641,7 +646,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {
-		if (!force)
+		if (!force || !sync)
 			goto move_newpage;
 
 		/*
@@ -686,7 +691,15 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
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
@@ -757,7 +770,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 
 skip_unmap:
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, remap_swapcache);
+		rc = move_to_new_page(newpage, page, remap_swapcache, sync);
 
 	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
@@ -850,7 +863,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
 	if (!page_mapped(hpage))
-		rc = move_to_new_page(new_hpage, hpage, 1);
+		rc = move_to_new_page(new_hpage, hpage, 1, sync);
 
 	if (rc)
 		remove_migration_ptes(hpage, hpage);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cdef1d4..ce6d601 100644
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
