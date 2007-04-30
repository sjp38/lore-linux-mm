Date: Mon, 30 Apr 2007 21:11:47 +0100
Subject: Re: [PATCH 4/4] Add __GFP_TEMPORARY to identify allocations that are short-lived
Message-ID: <20070430201147.GB8205@skynet.ie>
References: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie> <20070430185644.7142.89206.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0704301202490.7258@schroedinger.engr.sgi.com> <20070430194427.GA8205@skynet.ie> <Pine.LNX.4.64.0704301250580.8361@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704301250580.8361@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (30/04/07 12:52), Christoph Lameter didst pronounce:
> On Mon, 30 Apr 2007, Mel Gorman wrote:
> 
> > > White space damage.
> > >
> > 
> > Fixed. to be ( GFP_TEMPORARY ) although that itself looks odd.
> 
> Needs to be (GFP_TEMPORARY)
> 

agreed. Fixed

> > >> --- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/journal.c	2007-04-27 22:04:33.000000000 +0100
> > >> +++ linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/journal.c	2007-04-30 16:38:41.000000000 +0100
> > >> @@ -1739,8 +1739,7 @@ static struct journal_head *journal_allo
> > >>  #ifdef CONFIG_JBD_DEBUG
> > >>  	atomic_inc(&nr_journal_heads);
> > >>  #endif
> > >> -	ret = kmem_cache_alloc(journal_head_cache,
> > >> -			set_migrateflags(GFP_NOFS, __GFP_RECLAIMABLE));
> > >> +	ret = kmem_cache_alloc(journal_head_cache, GFP_NOFS);
> > >>  	if (ret == 0) {
> > >
> > > This chunk belongs into the earlier patch.
> > >
> > 
> > Why? kmem_cache_create() is changed here in this patch to use SLAB_TEMPORARY 
> > which is not defined until this patch.
> 
> I do not see a SLAB_TEMPORARY here.

Here are the relevant portions of the fourth patch.

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/include/linux/slab.h linux-2.6.21-rc7-mm2-003_temporary/include/linux/slab.h
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/include/linux/slab.h	2007-04-27 22:04:34.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/include/linux/slab.h	2007-04-30 16:10:55.000000000 +0100
@@ -26,12 +26,15 @@ typedef struct kmem_cache kmem_cache_t _
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
-#define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
 #define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
 
+/* The following flags affect grouping pages by mobility */
+#define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
+#define SLAB_TEMPORARY	SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
+
 /* Flags passed to a constructor functions */
 #define SLAB_CTOR_CONSTRUCTOR	0x001UL		/* If not set, then deconstructor */

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/journal.c linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/journal.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/journal.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/journal.c	2007-04-30 16:38:41.000000000 +0100
@@ -2017,7 +2015,7 @@ static int __init journal_init_handle_ca
 	jbd_handle_cache = kmem_cache_create("journal_handle",
 				sizeof(handle_t),
 				0,		/* offset */
-				0,		/* flags */
+				SLAB_TEMPORARY,	/* flags */
 				NULL,		/* ctor */
 				NULL);		/* dtor */
 	if (jbd_handle_cache == NULL) {

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/revoke.c linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/revoke.c
--- linux-2.6.21-rc7-mm2-002_account_reclaimable/fs/jbd/revoke.c	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-003_temporary/fs/jbd/revoke.c	2007-04-30 16:39:43.000000000 +0100
@@ -169,7 +169,9 @@ int __init journal_init_revoke_caches(vo
 {
 	revoke_record_cache = kmem_cache_create("revoke_record",
 					   sizeof(struct jbd_revoke_record_s),
-					   0, SLAB_HWCACHE_ALIGN, NULL, NULL);
+					   0,
+					   SLAB_HWCACHE_ALIGN|SLAB_TEMPORARY,
+					   NULL, NULL);
 	if (revoke_record_cache == 0)
 		return -ENOMEM;
 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
