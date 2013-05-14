Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 3ABA06B0033
	for <linux-mm@kvack.org>; Tue, 14 May 2013 01:22:50 -0400 (EDT)
Date: Tue, 14 May 2013 15:22:44 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 00/31] kmemcg shrinkers
Message-ID: <20130514052244.GC29466@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <20130513071359.GM32675@dastard>
 <51909D84.7040800@parallels.com>
 <20130514014805.GA29466@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130514014805.GA29466@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org

On Tue, May 14, 2013 at 11:48:05AM +1000, Dave Chinner wrote:
> On Mon, May 13, 2013 at 12:00:04PM +0400, Glauber Costa wrote:
> > On 05/13/2013 11:14 AM, Dave Chinner wrote:
> > > Now, the read-only workload is iterating through a cold-cache lookup
> > > workload of 50 million inodes - at roughly 150,000/s. It's a
> > > touch-once workload, so shoul dbe turning the cache over completely
> > > every 10 seconds. However, in the time it's taken for me to explain
> > > this:
> > > 
> > >  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
> > > 1954493 1764661  90%    1.12K  69831       28   2234592K xfs_inode
> > > 1643868 281962  17%    0.22K  45663       36    365304K xfs_ili   
> > > 
> > > Only 200k xfs_ili's have been freed. So the rate of reclaim of them
> > > is roughly 5k/s. Given the read-only nature of this workload, they
> > > should be gone from the cache in a few seconds. Another indication
> > > of problems here is the level of internal fragmentation of the
> > > xfs_ili slab. They should cycle out of the cache in LRU manner, just
> > > like inodes - the modify workload is a "touch once" workload as
> > > well, so there should be no internal fragmentation of the slab
> > > cache.
> > > 
> > 
> > Initial testing I have done indicates - although it does not undoubtly
> > prove  - that the problem may be with dentries, not inodes
> 
> That tallies with the stats I'm seeing showing a significant
> difference in the balance of allocated vs "free" dentries. On a 3.9 kernel,
> the is little difference between them - dentries move quickly to the
> LRU and are considered free, while this patchset starts the same
> they quickly diverge, with the free count dropping well away from
> the allocated count.

So, there's something early on going wrong in the patch set.  This
is from a tree at this patch in the series:

803d32a inode: convert inode lru list to generic lru list code.

Which is before the dentry cache is converted to the new LRU list
code. So there's something wrong either in the underlying linux-next

   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
1894912 1610470  84%    0.06K  29608       64    118432K kmalloc-64
1894738 1660467  87%    1.12K  67696       28   2166272K xfs_inode
1892232 1633839  86%    0.22K  52562       36    420496K xfs_ili
1887962 1614100  85%    0.21K  51026       37    408208K dentry
 562744 562191  99%    0.55K  20098       28    321568K radix_tree_node

And:

$ cat /proc/sys/fs/dentry-state 
1702143 96055   45      0       0       0
$

Which reflects this:

struct dentry_stat_t {
        int nr_dentry;
        int nr_unused;
        int age_limit;          /* age in seconds */
        int want_pages;         /* pages requested by system */
        int dummy[2];
};

Which basicaly says we have 1.7 million allocated dentrys, but only
100k dentries on the LRU lists.  So there's something wrong either
in the underlying linux-next tree, or the initial 3 dentry cache
patches are now buggy.

<revert back to linux-next tree base>

<groan>

test-4 login: [   71.106361] XFS (vdc): Mounting Filesystem
[   71.130097] XFS (vdc): Ending clean mount
[   91.980679] fs_mark (4394) used greatest stack depth: 3048 bytes left
[   92.286173] fs_mark (4396) used greatest stack depth: 3032 bytes left
[   92.340949] fs_mark (4397) used greatest stack depth: 3024 bytes left
[  120.162200] lowmemorykiller: send sigkill to 2948 (rsyslogd), adj 0, size 209
[  122.518167] fs_mark (4434) used greatest stack depth: 2952 bytes left
[  127.213331] lowmemorykiller: send sigkill to 3421 (pmcd), adj 0, size 202
[  165.402109] lowmemorykiller: send sigkill to 3302 (cron), adj 0, size 94
[  165.435809] lowmemorykiller: send sigkill to 1 (init), adj 0, size 87
[  169.003846] fs_mark (4484) used greatest stack depth: 2720 bytes left
[  189.093392] lowmemorykiller: send sigkill to 1 (init), adj 0, size 86
[  195.153252] lowmemorykiller: send sigkill to 1 (init), adj 0, size 80
[  209.016457] lowmemorykiller: send sigkill to 1 (init), adj 0, size 86
[  219.431805] lowmemorykiller: send sigkill to 1 (init), adj 0, size 86

So, the lowmemory killer is fucked up in the linux-next tree, not by
this patchset. Before it killed pmcd, it looked like the dentry
counters were running as per 3.9.0. Reboot, try again:

[   79.304611] lowmemorykiller: send sigkill to 4593 (fs_mark), adj 0, size 2121
[  131.334226] lowmemorykiller: send sigkill to 4647 (find), adj 0, size 7658
[  131.762285] lowmemorykiller: send sigkill to 4645 (find), adj 0, size 7658
[  131.858137] lowmemorykiller: send sigkill to 4653 (find), adj 0, size 7658
[  131.982366] lowmemorykiller: send sigkill to 4655 (find), adj 0, size 7658
[  132.455610] lowmemorykiller: send sigkill to 4657 (find), adj 0, size 7658
[  132.983835] lowmemorykiller: send sigkill to 4659 (find), adj 0, size 7658
[  133.136868] lowmemorykiller: send sigkill to 4661 (find), adj 0, size 7658
[  133.762004] lowmemorykiller: send sigkill to 4665 (find), adj 0, size 7658
[  139.666345] lowmemorykiller: send sigkill to 4685 (rm), adj 0, size 8195
[  142.964679] lowmemorykiller: send sigkill to 4691 (rm), adj 0, size 8195
[  154.573456] lowmemorykiller: send sigkill to 4686 (rm), adj 0, size 8293

Right, I'm turning that crap off.

Ok, that's more like what I expect:

$ cat /proc/sys/fs/dentry-state 
937104  929728  45      0       0       0
$ cat /proc/sys/fs/dentry-state 
1124254 1116881 45      0       0       0
$ cat /proc/sys/fs/dentry-state 
1256143 1248768 45      0       0       0
$ cat /proc/sys/fs/dentry-state 
761321  753937  45      0       0       0
$ cat /proc/sys/fs/dentry-state 
177308  169925  45      0       0       0
$ cat /proc/sys/fs/dentry-state 
614756  607371  45      0       0       0
$ cat /proc/sys/fs/dentry-state 
848316  840932  45      0       0       0

unused tracks allocated very closely.

So it's patch 4 that is broken:

dcache: remove dentries from LRU before putting on dispose list

I've found the problem. dentry_kill() returns the current dentry if
it cannot lock the dentry->d_inode or the dentry->d_parent, and when
that happens try_prune_one_dentry() silently fails to prune the
dentry.  But, at this point, we've already removed the dentry from
both the LRU and the shrink list, and so it gets dropped on the
floor.

patch 4 needs some work:

	- fix the above leak shrink list leak
	- fix the scope of the sb locking inside shrink_dcache_sb()
	- remove the readditional of dentry_lru_prune().

The reworked patch below does this.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

dcache: remove dentries from LRU before putting on dispose list

From: Dave Chinner <dchinner@redhat.com>

One of the big problems with modifying the way the dcache shrinker
and LRU implementation works is that the LRU is abused in several
ways. One of these is shrink_dentry_list().

Basically, we can move a dentry off the LRU onto a different list
without doing any accounting changes, and then use dentry_lru_prune()
to remove it from what-ever list it is now on to do the LRU
accounting at that point.

This makes it -really hard- to change the LRU implementation. The
use of the per-sb LRU lock serialises movement of the dentries
between the different lists and the removal of them, and this is the
only reason that it works. If we want to break up the dentry LRU
lock and lists into, say, per-node lists, we remove the only
serialisation that allows this lru list/dispose list abuse to work.

To make this work effectively, the dispose list has to be isolated
from the LRU list - dentries have to be removed from the LRU
*before* being placed on the dispose list. This means that the LRU
accounting and isolation is completed before disposal is started,
and that means we can change the LRU implementation freely in
future.

This means that dentries *must* be marked with DCACHE_SHRINK_LIST
when they are placed on the dispose list so that we don't think that
parent dentries found in try_prune_one_dentry() are on the LRU when
the are actually on the dispose list. This would result in
accounting the dentry to the LRU a second time. Hence
dentry_lru_del() has to handle the DCACHE_SHRINK_LIST case
differently because the dentry isn't on the LRU list.

[ v2: don't decrement nr unused twice, spotted by Sha Zhengju ]
[ v7: (dchinner)
- shrink list leaks dentries when inode/parent can't be locked in
  dentry_kill().
- fix the scope of the sb locking inside shrink_dcache_sb()
- remove the readdition of dentry_lru_prune(). ]

Signed-off-by: Dave Chinner <dchinner@redhat.com>

---
 fs/dcache.c |   90 ++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 68 insertions(+), 22 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 795c15d..edaf462 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -315,7 +315,7 @@ static void dentry_unlink_inode(struct dentry * dentry)
 }
 
 /*
- * dentry_lru_(add|del|prune|move_tail) must be called with d_lock held.
+ * dentry_lru_(add|del|move_list) must be called with d_lock held.
  */
 static void dentry_lru_add(struct dentry *dentry)
 {
@@ -341,7 +341,8 @@ static void __dentry_lru_del(struct dentry *dentry)
  */
 static void dentry_lru_del(struct dentry *dentry)
 {
-	if (!list_empty(&dentry->d_lru)) {
+	if (!list_empty(&dentry->d_lru) &&
+	    !(dentry->d_flags & DCACHE_SHRINK_LIST)) {
 		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 		__dentry_lru_del(dentry);
 		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
@@ -350,13 +351,15 @@ static void dentry_lru_del(struct dentry *dentry)
 
 static void dentry_lru_move_list(struct dentry *dentry, struct list_head *list)
 {
+	BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
+
 	spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 	if (list_empty(&dentry->d_lru)) {
 		list_add_tail(&dentry->d_lru, list);
-		dentry->d_sb->s_nr_dentry_unused++;
-		this_cpu_inc(nr_dentry_unused);
 	} else {
 		list_move_tail(&dentry->d_lru, list);
+		dentry->d_sb->s_nr_dentry_unused--;
+		this_cpu_dec(nr_dentry_unused);
 	}
 	spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
 }
@@ -454,7 +457,8 @@ EXPORT_SYMBOL(d_drop);
  * If ref is non-zero, then decrement the refcount too.
  * Returns dentry requiring refcount drop, or NULL if we're done.
  */
-static inline struct dentry *dentry_kill(struct dentry *dentry, int ref)
+static inline struct dentry *
+dentry_kill(struct dentry *dentry, int ref, int unlock_on_failure)
 	__releases(dentry->d_lock)
 {
 	struct inode *inode;
@@ -463,8 +467,10 @@ static inline struct dentry *dentry_kill(struct dentry *dentry, int ref)
 	inode = dentry->d_inode;
 	if (inode && !spin_trylock(&inode->i_lock)) {
 relock:
-		spin_unlock(&dentry->d_lock);
-		cpu_relax();
+		if (unlock_on_failure) {
+			spin_unlock(&dentry->d_lock);
+			cpu_relax();
+		}
 		return dentry; /* try again with same dentry */
 	}
 	if (IS_ROOT(dentry))
@@ -551,7 +557,7 @@ repeat:
 	return;
 
 kill_it:
-	dentry = dentry_kill(dentry, 1);
+	dentry = dentry_kill(dentry, 1, 1);
 	if (dentry)
 		goto repeat;
 }
@@ -750,12 +756,12 @@ EXPORT_SYMBOL(d_prune_aliases);
  *
  * This may fail if locks cannot be acquired no problem, just try again.
  */
-static void try_prune_one_dentry(struct dentry *dentry)
+static struct dentry * try_prune_one_dentry(struct dentry *dentry)
 	__releases(dentry->d_lock)
 {
 	struct dentry *parent;
 
-	parent = dentry_kill(dentry, 0);
+	parent = dentry_kill(dentry, 0, 0);
 	/*
 	 * If dentry_kill returns NULL, we have nothing more to do.
 	 * if it returns the same dentry, trylocks failed. In either
@@ -767,9 +773,9 @@ static void try_prune_one_dentry(struct dentry *dentry)
 	 * fragmentation.
 	 */
 	if (!parent)
-		return;
+		return NULL;
 	if (parent == dentry)
-		return;
+		return dentry;
 
 	/* Prune ancestors. */
 	dentry = parent;
@@ -778,9 +784,9 @@ static void try_prune_one_dentry(struct dentry *dentry)
 		if (dentry->d_count > 1) {
 			dentry->d_count--;
 			spin_unlock(&dentry->d_lock);
-			return;
+			return NULL;
 		}
-		dentry = dentry_kill(dentry, 1);
+		dentry = dentry_kill(dentry, 1, 1);
 	}
 }
 
@@ -800,21 +806,31 @@ static void shrink_dentry_list(struct list_head *list)
 		}
 
 		/*
+		 * The dispose list is isolated and dentries are not accounted
+		 * to the LRU here, so we can simply remove it from the list
+		 * here regardless of whether it is referenced or not.
+		 */
+		list_del_init(&dentry->d_lru);
+		dentry->d_flags &= ~DCACHE_SHRINK_LIST;
+
+		/*
 		 * We found an inuse dentry which was not removed from
-		 * the LRU because of laziness during lookup.  Do not free
-		 * it - just keep it off the LRU list.
+		 * the LRU because of laziness during lookup. Do not free it.
 		 */
 		if (dentry->d_count) {
-			dentry_lru_del(dentry);
 			spin_unlock(&dentry->d_lock);
 			continue;
 		}
-
 		rcu_read_unlock();
 
-		try_prune_one_dentry(dentry);
+		dentry = try_prune_one_dentry(dentry);
 
 		rcu_read_lock();
+		if (dentry) {
+			dentry->d_flags |= DCACHE_SHRINK_LIST;
+			list_add(&dentry->d_lru, list);
+			spin_unlock(&dentry->d_lock);
+		}
 	}
 	rcu_read_unlock();
 }
@@ -855,8 +871,10 @@ relock:
 			list_move(&dentry->d_lru, &referenced);
 			spin_unlock(&dentry->d_lock);
 		} else {
-			list_move_tail(&dentry->d_lru, &tmp);
+			list_move(&dentry->d_lru, &tmp);
 			dentry->d_flags |= DCACHE_SHRINK_LIST;
+			this_cpu_dec(nr_dentry_unused);
+			sb->s_nr_dentry_unused--;
 			spin_unlock(&dentry->d_lock);
 			if (!--count)
 				break;
@@ -870,6 +888,27 @@ relock:
 	shrink_dentry_list(&tmp);
 }
 
+/*
+ * Mark all the dentries as on being the dispose list so we don't think they are
+ * still on the LRU if we try to kill them from ascending the parent chain in
+ * try_prune_one_dentry() rather than directly from the dispose list.
+ */
+static void
+shrink_dcache_list(
+	struct list_head *dispose)
+{
+	struct dentry *dentry;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(dentry, dispose, d_lru) {
+		spin_lock(&dentry->d_lock);
+		dentry->d_flags |= DCACHE_SHRINK_LIST;
+		spin_unlock(&dentry->d_lock);
+	}
+	rcu_read_unlock();
+	shrink_dentry_list(dispose);
+}
+
 /**
  * shrink_dcache_sb - shrink dcache for a superblock
  * @sb: superblock
@@ -883,9 +922,16 @@ void shrink_dcache_sb(struct super_block *sb)
 
 	spin_lock(&sb->s_dentry_lru_lock);
 	while (!list_empty(&sb->s_dentry_lru)) {
-		list_splice_init(&sb->s_dentry_lru, &tmp);
+		/*
+		 * account for removal here so we don't need to handle it later
+		 * even though the dentry is no longer on the lru list.
+		 */
 		spin_unlock(&sb->s_dentry_lru_lock);
-		shrink_dentry_list(&tmp);
+		list_splice_init(&sb->s_dentry_lru, &tmp);
+		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
+		sb->s_nr_dentry_unused = 0;
+
+		shrink_dcache_list(&tmp);
 		spin_lock(&sb->s_dentry_lru_lock);
 	}
 	spin_unlock(&sb->s_dentry_lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
