Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6913C8D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 09:51:10 -0400 (EDT)
Date: Mon, 21 Mar 2011 14:48:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-ID: <20110321134832.GC5719@random.random>
References: <4D80D65C.5040504@fiec.espol.edu.ec>
 <20110316150208.7407c375.akpm@linux-foundation.org>
 <4D827CC1.4090807@fiec.espol.edu.ec>
 <20110317144727.87a461f9.akpm@linux-foundation.org>
 <20110318111300.GF707@csn.ul.ie>
 <4D839EDB.9080703@fiec.espol.edu.ec>
 <20110319134628.GG707@csn.ul.ie>
 <4D84D3F2.4010200@fiec.espol.edu.ec>
 <20110319235144.GG10696@random.random>
 <20110321094149.GH707@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110321094149.GH707@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alex Villac??s Lasso <avillaci@fiec.espol.edu.ec>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Mon, Mar 21, 2011 at 09:41:49AM +0000, Mel Gorman wrote:
> The check is at the wrong level I believe because it misses NFS pages which
> will still get queued for IO which can block waiting on a request to complete.

But for example ->migratepage won't block at all for swapcache... it's
just a pointer for migrate_page... so I didnt' want to skip what could
be nonblocking, it just makes migrate less reliable for no good in
some case. The fallback case is very likely blocking instead so I only
returned -EBUSY there.

Best would be to pass a sync/nonblock param to migratepage(nonblock)
so that nfs_migrate_page can pass "nonblock" instead of "false" to
nfs_find_and_lock_request.

> sync should be bool.

That's better thanks.

> It's overkill to return EBUSY just because we failed to get a lock which could
> be released very quickly. If we left rc as -EAGAIN it would retry again.
> The worst case scenario is that the current process is the holder of the
> lock and the loop is pointless but this is a relatively rare situation
> (other than Hugh's loopback test aside which seems to be particularly good
> at triggering that situation).

This change was only meant to possibly avoid some cpu waste in the
tight loop, not really "blocking" related so I'm sure ok to drop it
for now. The page lock holder better to be quick because with sync=0
the tight loop will retry real fast. If the holder blocks we're not so
smart at retrying in a tight loop but for now it's ok.

> >  			goto move_newpage;
> >  
> > @@ -686,7 +695,11 @@ static int unmap_and_move(new_page_t get
> >  	BUG_ON(charge);
> >  
> >  	if (PageWriteback(page)) {
> > -		if (!force || !sync)
> > +		if (!sync) {
> > +			rc = -EBUSY;
> > +			goto uncharge;
> > +		}
> > +		if (!force)
> >  			goto uncharge;
> 
> Where as this is ok because if the page is being written back, it's fairly
> unlikely it'll get cleared quickly enough for the retry loop to make sense.

Agreed.

> Because of the NFS pages and being a bit aggressive about using -EBUSY,
> how about the following instead? (build tested only unfortunately)

I tested my version below but I think one needs udf with lots of dirty
pages plus the usb to trigger this which I don't have setup
immediately.

> @@ -586,18 +586,23 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>  	mapping = page_mapping(page);
>  	if (!mapping)
>  		rc = migrate_page(mapping, newpage, page);
> -	else if (mapping->a_ops->migratepage)
> -		/*
> -		 * Most pages have a mapping and most filesystems
> -		 * should provide a migration function. Anonymous
> -		 * pages are part of swap space which also has its
> -		 * own migration function. This is the most common
> -		 * path for page migration.
> -		 */
> -		rc = mapping->a_ops->migratepage(mapping,
> -						newpage, page);
> -	else
> -		rc = fallback_migrate_page(mapping, newpage, page);
> +	else {
> +		/* Do not writeback pages if !sync */
> +		if (PageDirty(page) && !sync)
> +			rc = -EBUSY;

I think it's better to at least change it to:

if (PageDirty(page) && !sync && mapping->a_ops->migratepage != migrate_page))

I wasn't sure how to handle noblocking ->migratepage for swapcache and
tmpfs but probably the above check is a good enough approximation.

Before sending my patch I thought of adding a "sync" parameter to
->migratepage(..., sync/nonblock) but then the patch become
bigger... and I just wanted to know if this was the problem or not so
I deferred it.

If we're sure that all migratepage blocks except for things like
swapcache/tmpfs or other not-filebacked things that defines it to
migrate_page, we're pretty well covered by adding a check like above
migratepage == migrate_page and maybe we don't need to add a
"sync/nonblock" parameter to ->migratepage(). For example the
buffer_migrate_page can block too in lock_buffer.

This is the patch I'm trying with the addition of the above check and
some comment space/tab issue cleanup.

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
