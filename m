Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA14542
	for <linux-mm@kvack.org>; Sun, 8 Sep 2002 13:41:54 -0700 (PDT)
Message-ID: <3D7BB97A.6B6E4CA5@digeo.com>
Date: Sun, 08 Sep 2002 13:56:26 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slabasap-mm5_A2
References: <200209071006.18869.tomlins@cam.org> <200209081142.02839.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> Hi,
> 
> Here is a rewritten slablru - this time its not using the lru...  If changes long standing slab
> behavior.  Now slab.c releases pages as soon as possible.  This was done since we noticed
> that slablru was taking a long time to release the pages it freed - from other vm experiences
> this is not a good thing.

Right.  There remains the issue that we're ripping away constructed
objects from slabs which have constructors, as Stephen points out.

I doubt if that matters.  slab constructors just initialise stuff.
If the memory is in cache then the initialisation is negligible.
If the memory is not in cache then the initialisation will pull
it into cache, which is something which we needed to do anyway.  And
unless the slab's access pattern is extremely LIFO, chances are that
most allocations will come in from part-filled slab pages anyway.

And other such waffly words ;)  I'll do the global LIFO page hotlists
soonl; that'll fix it up.

 
> In this patch I have tried to make as few changes as possible.

Thanks.  I've shuffled the patching sequence (painful), and diddled
a few things.  We actually do have the "number of scanned pages"
in there, so we can use that.  I agree that the ratio should be 
nr_scanned/total rather than nr_reclaimed/total.   This way, if
nr_reclaimed < nr_scanned (page reclaim is in trouble) then we
put more pressure on slabs.

>   With this in mind I am using
> the percentage of the active+inactive pages reclaimed to recover the same percentage of the
> pruneable caches.  In slablru the affect was to age the pruneable caches by percentage of
> the active+inactive pages scanned - this could be done but required more code so I went
> used pages reclaimed.  The same choise was made about accounting of pages freed by
> the shrink_<something>_memory calls.
> 
> There is also a question as to if we should only use the ZONE_DMA and ZONE_NORMAL to
> drive the cache shrinking.  Talk with Rik on irc convinced me to go with the choise that
> required less code, so we use all zones.

OK.  We could do with a `gimme_the_direct_addressed_classzone' utility
anyway.  It is currently open-coded in fs/buffer.c:free_more_memory().
We can just pull that out of there and use memclass() on it for this.

> To apply the patch to mm5 use the follow procedure:
> copy the two slablru patch and discard all but the vmscan changes.
> replace the slablru patch with the just created patches that just hit vmscan
> after applying the mm5 patches apply the following patch to adjust vmscan and add slabasap.
> 
> This passes the normal group of tests I apply to my patches (mm4 stalled force watchdog to
> reboot).   The varient for bk linus also survives these tests.
> 
> I have seen some unexpected messages from the kde artsd daemon when I left kde running all
> night.  This may imply we want to have slab be a little less aggressive freeing high order slabs.
> Would like to see if other have problems though - it could just be debian and kde 3.0.3 (which
> is not offical yet).

hm.
 
> Please let me know if you want any changes or the addition of any of the options mentioned.
> 

In here:

        int entries = inodes_stat.nr_inodes / ratio + 1;

what is the "+ 1" for?  If it is to avoid divide-by-zero then
it needs parentheses.  I added the "+ 1" to the call site to cover that.

>From a quick test, the shrinking rate seems quite reasonable to
me.  mem=512m, with twenty megs of ext2 inodes in core, a `dd'
of one gigabyte (twice the size of memory) steadily pushed the
ext2 inodes down to 2.5 megs (although total memory was still
9 megs - internal fragmentation of the slab).

A second 1G dd pushed it down to 1M/3M.

A third 1G dd pushed it down to .25M/1.25M

Seems OK.

A few things we should do later:

- We're calling prune_icache with a teeny number of inodes, many times.
  Would be better to batch that up a bit.

- It would be nice to bring back the pruner callbacks.  The post-facto
  hook registration thing will be fine.  Hit me with a stick for making
  you change the kmem_cache_create() prototype.  Sorry about that.

If we have the pruner callbacks then vmscan can just do:

	kmem_shrink_stuff(ratio);

and then kmem_shrink_stuff() can do:

	cachep->nr_to_prune += cacheb->inuse / ratio;
	if (cachep->nr_to_prune > cachep->prune_batch) {
		int prune = cachep->nr_to_prune;

		cachep->nr_to_prune = 0;
		(*cachep->pruner)(nr_to_prune);
	}

But let's get the current code settled in before doing these
refinements.

There are some usage patterns in which the dentry/inode aging
might be going wrong.  Try, with mem=512m

	cp -a linux a
	cp -a linux b
	cp -a linux c

etc.

Possibly the inode/dentry cache is just being FIFO here and is doing
exactly the wrong thing.  But the dcache referenced-bit logic should
cause the inodes in `linux' to be pinned with this test, so that 
should be OK.  Dunno.

The above test will be hurt a bit by the aggressively lowered (10%)
background writeback threshold - more reads competing with writes.
Maybe I should not kick off background writeback until the dirty
threshold reaches 30% if there are reads queued against the device.
That's easy enough to do.

drop-behind should help here too.

 fs/dcache.c            |   21 +++++----------------
 fs/dquot.c             |   19 +++++--------------
 fs/inode.c             |   24 +++++++-----------------
 include/linux/dcache.h |    2 +-
 include/linux/mm.h     |    1 +
 mm/page_alloc.c        |   11 +++++++++++
 mm/slab.c              |    8 ++++++--
 mm/vmscan.c            |   28 +++++++++++++++++++---------
 8 files changed, 55 insertions(+), 59 deletions(-)

--- 2.5.33/fs/dcache.c~slabasap	Sun Sep  8 12:42:41 2002
+++ 2.5.33-akpm/fs/dcache.c	Sun Sep  8 12:42:43 2002
@@ -573,19 +573,11 @@ void shrink_dcache_anon(struct list_head
 
 /*
  * This is called from kswapd when we think we need some
- * more memory, but aren't really sure how much. So we
- * carefully try to free a _bit_ of our dcache, but not
- * too much.
- *
- * Priority:
- *   1 - very urgent: shrink everything
- *  ...
- *   6 - base-level: try to shrink a bit.
+ * more memory. 
  */
-int shrink_dcache_memory(int priority, unsigned int gfp_mask)
+int shrink_dcache_memory(int ratio, unsigned int gfp_mask)
 {
-	int count = 0;
-
+	int entries = dentry_stat.nr_dentry / ratio + 1;
 	/*
 	 * Nasty deadlock avoidance.
 	 *
@@ -600,11 +592,8 @@ int shrink_dcache_memory(int priority, u
 	if (!(gfp_mask & __GFP_FS))
 		return 0;
 
-	count = dentry_stat.nr_unused / priority;
-
-	prune_dcache(count);
-	kmem_cache_shrink(dentry_cache);
-	return 0;
+	prune_dcache(entries);
+	return entries;
 }
 
 #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
--- 2.5.33/fs/dquot.c~slabasap	Sun Sep  8 12:42:41 2002
+++ 2.5.33-akpm/fs/dquot.c	Sun Sep  8 12:42:43 2002
@@ -480,26 +480,17 @@ static void prune_dqcache(int count)
 
 /*
  * This is called from kswapd when we think we need some
- * more memory, but aren't really sure how much. So we
- * carefully try to free a _bit_ of our dqcache, but not
- * too much.
- *
- * Priority:
- *   1 - very urgent: shrink everything
- *   ...
- *   6 - base-level: try to shrink a bit.
+ * more memory
  */
 
-int shrink_dqcache_memory(int priority, unsigned int gfp_mask)
+int shrink_dqcache_memory(int ratio, unsigned int gfp_mask)
 {
-	int count = 0;
+	entries = dqstats.allocated_dquots / ratio + 1;
 
 	lock_kernel();
-	count = dqstats.free_dquots / priority;
-	prune_dqcache(count);
+	prune_dqcache(entries);
 	unlock_kernel();
-	kmem_cache_shrink(dquot_cachep);
-	return 0;
+	return entries;
 }
 
 /*
--- 2.5.33/fs/inode.c~slabasap	Sun Sep  8 12:42:41 2002
+++ 2.5.33-akpm/fs/inode.c	Sun Sep  8 13:10:15 2002
@@ -409,7 +409,7 @@ void prune_icache(int goal)
 	struct list_head *entry, *freeable = &list;
 	int count;
 	struct inode * inode;
-
+printk("prune_icache(%d/%d)\n", goal, inodes_stat.nr_unused);
 	spin_lock(&inode_lock);
 
 	count = 0;
@@ -442,19 +442,11 @@ void prune_icache(int goal)
 
 /*
  * This is called from kswapd when we think we need some
- * more memory, but aren't really sure how much. So we
- * carefully try to free a _bit_ of our icache, but not
- * too much.
- *
- * Priority:
- *   1 - very urgent: shrink everything
- *  ...
- *   6 - base-level: try to shrink a bit.
+ * more memory. 
  */
-int shrink_icache_memory(int priority, int gfp_mask)
+int shrink_icache_memory(int ratio, unsigned int gfp_mask)
 {
-	int count = 0;
-
+	int entries = inodes_stat.nr_inodes / ratio + 1;
 	/*
 	 * Nasty deadlock avoidance..
 	 *
@@ -465,12 +457,10 @@ int shrink_icache_memory(int priority, i
 	if (!(gfp_mask & __GFP_FS))
 		return 0;
 
-	count = inodes_stat.nr_unused / priority;
-
-	prune_icache(count);
-	kmem_cache_shrink(inode_cachep);
-	return 0;
+	prune_icache(entries);
+	return entries;
 }
+EXPORT_SYMBOL(shrink_icache_memory);
 
 /*
  * Called with the inode lock held.
--- 2.5.33/include/linux/dcache.h~slabasap	Sun Sep  8 12:42:41 2002
+++ 2.5.33-akpm/include/linux/dcache.h	Sun Sep  8 12:42:43 2002
@@ -186,7 +186,7 @@ extern int shrink_dcache_memory(int, uns
 extern void prune_dcache(int);
 
 /* icache memory management (defined in linux/fs/inode.c) */
-extern int shrink_icache_memory(int, int);
+extern int shrink_icache_memory(int, unsigned int);
 extern void prune_icache(int);
 
 /* quota cache memory management (defined in linux/fs/dquot.c) */
--- 2.5.33/include/linux/mm.h~slabasap	Sun Sep  8 12:42:41 2002
+++ 2.5.33-akpm/include/linux/mm.h	Sun Sep  8 12:42:43 2002
@@ -509,6 +509,7 @@ extern struct vm_area_struct *find_exten
 
 extern struct page * vmalloc_to_page(void *addr);
 extern unsigned long get_page_cache_size(void);
+extern unsigned int nr_used_zone_pages(void);
 
 #endif /* __KERNEL__ */
 
--- 2.5.33/mm/page_alloc.c~slabasap	Sun Sep  8 12:42:41 2002
+++ 2.5.33-akpm/mm/page_alloc.c	Sun Sep  8 12:42:43 2002
@@ -487,6 +487,17 @@ unsigned int nr_free_pages(void)
 	return sum;
 }
 
+unsigned int nr_used_zone_pages(void)
+{
+	unsigned int pages = 0;
+	struct zone *zone;
+
+	for_each_zone(zone)
+		pages += zone->nr_active + zone->nr_inactive;
+
+	return pages;
+}
+
 static unsigned int nr_free_zone_pages(int offset)
 {
 	pg_data_t *pgdat;
--- 2.5.33/mm/slab.c~slabasap	Sun Sep  8 12:42:41 2002
+++ 2.5.33-akpm/mm/slab.c	Sun Sep  8 12:42:43 2002
@@ -1502,7 +1502,11 @@ static inline void kmem_cache_free_one(k
 		if (unlikely(!--slabp->inuse)) {
 			/* Was partial or full, now empty. */
 			list_del(&slabp->list);
-			list_add(&slabp->list, &cachep->slabs_free);
+/*			list_add(&slabp->list, &cachep->slabs_free); 		*/
+			if (unlikely(list_empty(&cachep->slabs_partial)))
+				list_add(&slabp->list, &cachep->slabs_partial);
+			else
+				kmem_slab_destroy(cachep, slabp);
 		} else if (unlikely(inuse == cachep->num)) {
 			/* Was full. */
 			list_del(&slabp->list);
@@ -1971,7 +1975,7 @@ static int s_show(struct seq_file *m, vo
 	}
 	list_for_each(q,&cachep->slabs_partial) {
 		slabp = list_entry(q, slab_t, list);
-		if (slabp->inuse == cachep->num || !slabp->inuse)
+		if (slabp->inuse == cachep->num)
 			BUG();
 		active_objs += slabp->inuse;
 		active_slabs++;
--- 2.5.33/mm/vmscan.c~slabasap	Sun Sep  8 12:42:41 2002
+++ 2.5.33-akpm/mm/vmscan.c	Sun Sep  8 13:10:24 2002
@@ -71,6 +71,10 @@
 #define prefetchw_prev_lru_page(_page, _base, _field) do { } while (0)
 #endif
 
+#ifndef CONFIG_QUOTA
+#define shrink_dqcache_memory(ratio, gfp_mask) do { } while (0)
+#endif
+
 /* Must be called with page's pte_chain_lock held. */
 static inline int page_mapping_inuse(struct page * page)
 {
@@ -566,10 +570,6 @@ shrink_zone(struct zone *zone, int max_s
 {
 	unsigned long ratio;
 
-	/* This is bogus for ZONE_HIGHMEM? */
-	if (kmem_cache_reap(gfp_mask) >= nr_pages)
-  		return 0;
-
 	/*
 	 * Try to keep the active list 2/3 of the size of the cache.  And
 	 * make sure that refill_inactive is given a decent number of pages.
@@ -597,6 +597,8 @@ shrink_caches(struct zone *classzone, in
 {
 	struct zone *first_classzone;
 	struct zone *zone;
+	int ratio;
+	int pages = nr_used_zone_pages();
 
 	first_classzone = classzone->zone_pgdat->node_zones;
 	for (zone = classzone; zone >= first_classzone; zone--) {
@@ -626,11 +628,19 @@ shrink_caches(struct zone *classzone, in
 		*total_scanned += max_scan;
 	}
 
-	shrink_dcache_memory(priority, gfp_mask);
-	shrink_icache_memory(1, gfp_mask);
-#ifdef CONFIG_QUOTA
-	shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
-#endif
+	/*
+	 * Here we assume it costs one seek to replace a lru page and that
+	 * it also takes a seek to recreate a cache object.  With this in
+	 * mind we age equal percentages of the lru and ageable caches.
+	 * This should balance the seeks generated by these structures.
+	 *
+	 * NOTE: for now I do this for all zones.  If we find this is too
+	 * aggressive on large boxes we may want to exculude ZONE_HIGHMEM
+	 */
+	ratio = (pages / *total_scanned) + 1;
+	shrink_dcache_memory(ratio, gfp_mask);
+	shrink_icache_memory(ratio, gfp_mask);
+	shrink_dqcache_memory(ratio, gfp_mask);
 	return nr_pages;
 }
 

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
