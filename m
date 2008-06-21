Date: Sat, 21 Jun 2008 23:41:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
Message-ID: <20080621224135.GD4692@csn.ul.ie>
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Cc: kernel-testers@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (21/06/08 16:57), Alexander Beregalov didst pronounce:
> One more try, added some CC's.
> 

Thanks for the report. I was offline for two weeks and I would have missed
this without a direct cc. Today is my first day back online so if I miss
any context, sorry about that. What I have is;

1. This appeared in 2.6.26-rc1 (http://lkml.org/lkml/2008/5/10/60 is a copy
   of the original report)

2. The circular lock itself was considered to be a false positive by David
   Chinner (http://lkml.org/lkml/2008/5/11/253). I've added David to the
   cc. I hate to ask the obvious, but is it possible that LOCKDEP checking
   was not turned on for the kernels before 2.6.26-rc1?

3. The bisect shows commit 54a6eb5c4765aa573a030ceeba2c14e3d2ea5706 to trigger
   the circular locking logic. Even if the deadlock warning is a false
   positive, it's possible that reclaim has been altered in some way.

For each stack listed in the report, I'm going to look at how the patch affects
that path and see can I spot where the problem alteration happened. I'm still
dozy after holidays so a double check of reasoning from anyone watching would
be a plus as this is not a trivial revert.

I spotted at least one problem in the patch in a change made to SLAB that
needs to be fixed but it is not relevant to the problem at hand as I believe
Alexandar is using SLUB instead of SLAB.  That patch is at the end of the
mail. Christoph, can you double check that patch please?

Have I missed any other relevant context?

> 2008/6/12 Alexander Beregalov <a.beregalov@gmail.com>:
> > I have bisected it and it seems introduced here:
> > How could it be?
> >
> > 54a6eb5c4765aa573a030ceeba2c14e3d2ea5706 is first bad commit
> > commit 54a6eb5c4765aa573a030ceeba2c14e3d2ea5706
> > Author: Mel Gorman <mel@csn.ul.ie>
> > Date:   Mon Apr 28 02:12:16 2008 -0700
> >
> >    mm: use two zonelist that are filtered by GFP mask
> >
> > <SNIP>
> >
> > :040000 040000 89cdad93d855fa839537454113f2716011ca0e26
> > 57aa307f4bddd264e70c759a2fb2076bfde363eb M      arch
> > :040000 040000 4add802178c0088a85d3738b42ec42ca33e07d60
> > 126d3b170424a18b60074a7901c4e9b98f3bdee5 M      fs
> > :040000 040000 9d215d6248382dab53003d230643f0169f3e3e84
> > 67d196d890a27d2211b3bf7e833e6366addba739 M      include
> > :040000 040000 6502d185e8ea6338953027c29cc3ab960d6f9bad
> > c818e0fc538cdc40016e2d5fe33661c9c54dc8a5 M      mm
> >
> 
> > I remind the log message (it still happens on -rc5):
> > Machine hangs for few seconds.
> > I can caught such thing during the first hour of running.
> >

I'm assuming that the few seconds are being spent in reclaim rather than
working out lock dependency logic. Any chance there is profile information
showing where all the time is being spent? Just in case, does the stall
still occur with lockdep turned off?

In the questionable patch, the first relevant change is how buffers are
freed up here;

diff --git a/fs/buffer.c b/fs/buffer.c
index 7135849..9b5434a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -360,16 +360,18 @@ void invalidate_bdev(struct block_device *bdev)
  */
 static void free_more_memory(void)
 {
-	struct zonelist *zonelist;
+	struct zone **zones;
 	int nid;
 
 	wakeup_pdflush(1024);
 	yield();
 
 	for_each_online_node(nid) {
-		zonelist = node_zonelist(nid, GFP_NOFS);
-		if (zonelist->zones[0])
-			try_to_free_pages(zonelist, 0, GFP_NOFS);
+		zones = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
+						gfp_zone(GFP_NOFS));
+		if (*zones)
+			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
+						GFP_NOFS);
 	}
 }

Mainline has different code to here actually as there were other patches
altering this path but even so...

Code before - Find the zonelist for this node and GFP_NOFS. If the zonelist
	has zones, try to free pages within that zonelist

code after - Lookup the first zone that would be scanned on this node for
	the GFP_NOFS flags. If that list is not NULL, call try_to_free_pages.

At a glance, it appears functionally equivilant. try_to_free_pages is still
getting a GFP_NOFS flag and it should be getting an equivilant zonelist. I
find it difficult to believe that the filtering could be taking seconds. If
filtering itself was bust, then the zonelists would be all wrong and it
would have been obvious before now.

> >  [ INFO: possible circular locking dependency detected ]
> >  2.6.26-rc5-00084-g39b945a #3
> >  -------------------------------------------------------
> >  nfsd/3457 is trying to acquire lock:
> >  (iprune_mutex){--..}, at: [<c016fb6c>] shrink_icache_memory+0x38/0x19b
> >
> >  but task is already holding lock:
> >  (&(&ip->i_iolock)->mr_lock){----}, at: [<c021108f>] xfs_ilock+0xa2/0xd6
> >
> >  which lock already depends on the new lock.
> >
> >
> >  the existing dependency chain (in reverse order) is:
> >
> >  -> #1 (&(&ip->i_iolock)->mr_lock){----}:
> >        [<c0135416>] __lock_acquire+0xa0c/0xbc6
> >        [<c013563a>] lock_acquire+0x6a/0x86
> >        [<c012c4f2>] down_write_nested+0x33/0x6a
> >        [<c0211068>] xfs_ilock+0x7b/0xd6
> >        [<c02111e1>] xfs_ireclaim+0x1d/0x59
> >        [<c022f342>] xfs_finish_reclaim+0x173/0x195
> >        [<c0231496>] xfs_reclaim+0xb3/0x138
> >        [<c023ba0f>] xfs_fs_clear_inode+0x55/0x8e
> >        [<c016f830>] clear_inode+0x83/0xd2
> >        [<c016faaf>] dispose_list+0x3c/0xc1
> >        [<c016fca7>] shrink_icache_memory+0x173/0x19b
> >        [<c014a7fa>] shrink_slab+0xda/0x153
> >        [<c014aa53>] try_to_free_pages+0x1e0/0x2a1

So the relevant parts for that alter this path appear to be

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ef8551e..0515b8f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1249,15 +1249,13 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
+	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	unsigned long nr_reclaimed = 0;
-	struct zone **zones = zonelist->zones;
-	int i;
-
+	struct zone **z;
+	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
-	for (i = 0; zones[i] != NULL; i++) {
-		struct zone *zone = zones[i];
-
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		if (!populated_zone(zone))
 			continue;
 		/*

Code before - Walk the zonelist for GFP_KERNEL
Code after - Filter zonelist based on what is allowed for GFP_KERNEL

This would allow the filesystem to be re-entered but otherwise, I am not
spotting an actual change in behaviour in the reclaim logic.


@@ -1311,8 +1309,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
-	struct zone **zones = zonelist->zones;
-	int i;
+	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 
 	if (scan_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
@@ -1320,8 +1319,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	 * mem_cgroup will not do shrink_slab.
 	 */
 	if (scan_global_lru(sc)) {
-		for (i = 0; zones[i] != NULL; i++) {
-			struct zone *zone = zones[i];
+		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
@@ -1385,8 +1383,7 @@ out:
 		priority = 0;
 
 	if (scan_global_lru(sc)) {
-		for (i = 0; zones[i] != NULL; i++) {
-			struct zone *zone = zones[i];
+		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;

Next three hunks are similar in principal to the first one.

> >        [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
> >        [<c0146c56>] __alloc_pages+0xa/0xc
> >        [<c015b8c2>] __slab_alloc+0x1c7/0x513
> >        [<c015beef>] kmem_cache_alloc+0x45/0xb3
> >        [<c01a5afe>] reiserfs_alloc_inode+0x12/0x23
> >        [<c016f308>] alloc_inode+0x14/0x1a9
> >        [<c016f5ed>] iget5_locked+0x47/0x133
> >        [<c019dffd>] reiserfs_iget+0x29/0x7d
> >        [<c019b655>] reiserfs_lookup+0xb1/0xee
> >        [<c01657c2>] do_lookup+0xa9/0x146
> >        [<c0166deb>] __link_path_walk+0x734/0xb2f
> >        [<c016722f>] path_walk+0x49/0x96
> >        [<c01674e0>] do_path_lookup+0x12f/0x149
> >        [<c0167d08>] __user_walk_fd+0x2f/0x48
> >        [<c0162157>] vfs_lstat_fd+0x16/0x3d
> >        [<c01621e9>] vfs_lstat+0x11/0x13
> >        [<c01621ff>] sys_lstat64+0x14/0x28
> >        [<c0102bb9>] sysenter_past_esp+0x6a/0xb1
> >        [<ffffffff>] 0xffffffff
> >
> >  -> #0 (iprune_mutex){--..}:
> >        [<c0135333>] __lock_acquire+0x929/0xbc6
> >        [<c013563a>] lock_acquire+0x6a/0x86
> >        [<c037db3e>] mutex_lock_nested+0xba/0x232
> >        [<c016fb6c>] shrink_icache_memory+0x38/0x19b
> >        [<c014a7fa>] shrink_slab+0xda/0x153
> >        [<c014aa53>] try_to_free_pages+0x1e0/0x2a1

Here it is the same as above except the mask is probably
GFP_HIGHUESR_PAGECACHE. Filesystems can be re-entered but it should be the
same behaviour.

> >        [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
> >        [<c0146c56>] __alloc_pages+0xa/0xc
> >        [<c01484f2>] __do_page_cache_readahead+0xaa/0x16a
> >        [<c01487ac>] ondemand_readahead+0x119/0x127
> >        [<c014880c>] page_cache_async_readahead+0x52/0x5d
> >        [<c0179410>] generic_file_splice_read+0x290/0x4a8
> >        [<c023a46a>] xfs_splice_read+0x4b/0x78
> >        [<c0237c78>] xfs_file_splice_read+0x24/0x29
> >        [<c0178712>] do_splice_to+0x45/0x63
> >        [<c017899e>] splice_direct_to_actor+0xc3/0x190
> >        [<c01ceddd>] nfsd_vfs_read+0x1ed/0x2d0
> >        [<c01cf24c>] nfsd_read+0x82/0x99
> >        [<c01d47b8>] nfsd3_proc_read+0xdf/0x12a
> >        [<c01cb907>] nfsd_dispatch+0xcf/0x19e
> >        [<c036356c>] svc_process+0x3b3/0x68b
> >        [<c01cbe35>] nfsd+0x168/0x26b
> >        [<c01037db>] kernel_thread_helper+0x7/0x10
> >        [<ffffffff>] 0xffffffff
> >
> >  other info that might help us debug this:
> >
> >  3 locks held by nfsd/3457:
> >  #0:  (hash_sem){..--}, at: [<c01d1a34>] exp_readlock+0xd/0xf
> >  #1:  (&(&ip->i_iolock)->mr_lock){----}, at: [<c021108f>] xfs_ilock+0xa2/0xd6
> >  #2:  (shrinker_rwsem){----}, at: [<c014a744>] shrink_slab+0x24/0x153
> >
> >  stack backtrace:
> >  Pid: 3457, comm: nfsd Not tainted 2.6.26-rc5-00084-g39b945a #3
> >  [<c01335c8>] print_circular_bug_tail+0x5a/0x65
> >  [<c0133ec9>] ? print_circular_bug_header+0xa8/0xb3
> >  [<c0135333>] __lock_acquire+0x929/0xbc6
> >  [<c013563a>] lock_acquire+0x6a/0x86
> >  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
> >  [<c037db3e>] mutex_lock_nested+0xba/0x232
> >  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
> >  [<c016fb6c>] ? shrink_icache_memory+0x38/0x19b
> >  [<c016fb6c>] shrink_icache_memory+0x38/0x19b
> >  [<c014a7fa>] shrink_slab+0xda/0x153
> >  [<c014aa53>] try_to_free_pages+0x1e0/0x2a1
> >  [<c0149993>] ? isolate_pages_global+0x0/0x3e
> >  [<c0146ad7>] __alloc_pages_internal+0x23f/0x3a7
> >  [<c0146c56>] __alloc_pages+0xa/0xc
> >  [<c01484f2>] __do_page_cache_readahead+0xaa/0x16a
> >  [<c01487ac>] ondemand_readahead+0x119/0x127
> >  [<c014880c>] page_cache_async_readahead+0x52/0x5d
> >  [<c0179410>] generic_file_splice_read+0x290/0x4a8
> >  [<c037f425>] ? _spin_unlock+0x27/0x3c
> >  [<c025140d>] ? _atomic_dec_and_lock+0x25/0x30
> >  [<c01355b4>] ? __lock_acquire+0xbaa/0xbc6
> >  [<c01787d5>] ? spd_release_page+0x0/0xf
> >  [<c023a46a>] xfs_splice_read+0x4b/0x78
> >  [<c0237c78>] xfs_file_splice_read+0x24/0x29
> >  [<c0178712>] do_splice_to+0x45/0x63
> >  [<c017899e>] splice_direct_to_actor+0xc3/0x190
> >  [<c01ceec0>] ? nfsd_direct_splice_actor+0x0/0xf
> >  [<c01ceddd>] nfsd_vfs_read+0x1ed/0x2d0
> >  [<c01cf24c>] nfsd_read+0x82/0x99
> >  [<c01d47b8>] nfsd3_proc_read+0xdf/0x12a
> >  [<c01cb907>] nfsd_dispatch+0xcf/0x19e
> >  [<c036356c>] svc_process+0x3b3/0x68b
> >  [<c01cbe35>] nfsd+0x168/0x26b
> >  [<c01cbccd>] ? nfsd+0x0/0x26b
> >  [<c01037db>] kernel_thread_helper+0x7/0x10
> >  =======================
> 

Looking through the rest of the patch, there was one functionally inequivilant
change made that might be relevant. It's this hunk

diff --git a/mm/slab.c b/mm/slab.c
index 5488c54..2985184 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3243,6 +3243,8 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	struct zonelist *zonelist;
 	gfp_t local_flags;
 	struct zone **z;
+	struct zone *zone;
+	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
 
@@ -3257,10 +3259,10 @@ retry:
 	 * Look through allowed nodes for objects available
 	 * from existing per node queues.
 	 */
-	for (z = zonelist->zones; *z && !obj; z++) {
-		nid = zone_to_nid(*z);
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+		nid = zone_to_nid(zone);
 
-		if (cpuset_zone_allowed_hardwall(*z, flags) &&
+		if (cpuset_zone_allowed_hardwall(zone, flags) &&
 			cache->nodelists[nid] &&
 			cache->nodelists[nid]->free_objects)
 				obj = ____cache_alloc_node(cache,

Note how that loop no longer breaks out when an object is found before the
patch but not afterwards. The patch to fix that is below but I don't think
it helps Alexander assuming he is using SLUB.

At the moment, I'm a little stumped. I'm going to start looking at diffs
between 2.6.25 and 2.6.26-rc5 and see what jumps out but alternative theories
are welcome :/

=========
Subject: Do not leak memory in the slab allocator in fallback_alloc()

When slab uses fallback_alloc(), it should stop scanning when an object has
been successfully allocated. Otherwise, memory can leak

Signed-off-by: Mel Gorman <mel@csn.ul.ie
--- 
 mm/slab.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc5-clean/mm/slab.c linux-2.6.26-rc5-fix-slab-leak/mm/slab.c
--- linux-2.6.26-rc5-clean/mm/slab.c	2008-06-05 04:10:44.000000000 +0100
+++ linux-2.6.26-rc5-fix-slab-leak/mm/slab.c	2008-06-21 22:50:07.000000000 +0100
@@ -3266,6 +3266,10 @@ retry:
 			cache->nodelists[nid]->free_objects)
 				obj = ____cache_alloc_node(cache,
 					flags | GFP_THISNODE, nid);
+
+		/* Do not scan further once an object has been allocated */
+		if (obj)
+			break;
 	}
 
 	if (!obj) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
