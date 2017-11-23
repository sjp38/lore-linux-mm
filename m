Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 326B46B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 01:36:18 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id o124so9685953ioo.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 22:36:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w66si5333383ith.3.2017.11.22.22.36.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 22:36:16 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
	<201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
	<201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
	<20171122203907.GI4094@dastard>
In-Reply-To: <20171122203907.GI4094@dastard>
Message-Id: <201711231534.BBI34381.tJOOHLQMOFVFSF@I-love.SAKURA.ne.jp>
Date: Thu, 23 Nov 2017 15:34:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jack@suse.com, pbonzini@redhat.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

Dave Chinner wrote:
> On Wed, Nov 22, 2017 at 07:53:59PM +0900, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > Andrew Morton wrote:
> > > > On Tue, 21 Nov 2017 21:02:37 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > > > 
> > > > > There are users not checking for register_shrinker() failure.
> > > > > Continuing with ignoring failure can lead to later oops at
> > > > > unregister_shrinker().
> > > > > 
> > > > > ...
> > > > >
> > > > > --- a/include/linux/shrinker.h
> > > > > +++ b/include/linux/shrinker.h
> > > > > @@ -75,6 +75,6 @@ struct shrinker {
> > > > >  #define SHRINKER_NUMA_AWARE	(1 << 0)
> > > > >  #define SHRINKER_MEMCG_AWARE	(1 << 1)
> > > > >  
> > > > > -extern int register_shrinker(struct shrinker *);
> > > > > +extern __must_check int register_shrinker(struct shrinker *);
> > > > >  extern void unregister_shrinker(struct shrinker *);
> > > > >  #endif
> > > > 
> > > > hm, well, OK, it's a small kmalloc(GFP_KERNEL).  That won't be
> > > > failing.
> > > 
> > > It failed by fault injection and resulted in a report at
> > > http://lkml.kernel.org/r/001a113f996099503a055e793dd3@google.com .
> > 
> > Since kzalloc() can become > 32KB allocation if CONFIG_NODES_SHIFT > 12
> > (which might not be impossible in near future), register_shrinker() can
> > potentially become a costly allocation which might fail without invoking
> > the OOM killer. It is a good opportunity to think whether we should allow
> > register_shrinker() to fail.
> 
> Just fix the numa aware shrinkers, as they are the only ones that
> will have this problem. There are only 6 of them, and only the 3
> that existed at the time that register_shrinker() was changed to
> return an error fail to check for an error. i.e. the superblock
> shrinker, the XFS dquot shrinker and the XFS buffer cache shrinker.

You are assuming the "too small to fail" memory-allocation rule
by ignoring that this problem is caused by fault injection.

> 
> Seems pretty straight forward to me....
> 
> > > > Affected code seems to be fs/xfs, fs/super.c, fs/quota,
> > > > arch/x86/kvm/mmu, drivers/gpu/drm/ttm, drivers/md and a bunch of
> > > > staging stuff.
> > > > 
> > > > I'm not sure this is worth bothering about?
> > > > 
> > > 
> > > Continuing with failed register_shrinker() is almost always wrong.
> > > Though I don't know whether mm/zsmalloc.c case can make sense.
> > > 
> > 
> > Thinking from the fact that register_shrinker() had been "void" until Linux 3.11
> > and we did not take appropriate precautions when changing to "int" in Linux 3.12,
> > we need to consider making register_shrinker() "void" again.
> > 
> > If we could agree with opening up the use of __GFP_NOFAIL for allocating a few
> > non-contiguous pages on large systems, we can make register_shrinker() "void"
> > again. (Draft patch is shown below. I choose array of kmalloc(PAGE_SIZE)
> > rather than kvmalloc() in order to use __GFP_NOFAIL.)
> 
> That's insane. NACK.

That does not solve the problem. We have fault injection which allows precisely
N'th memory allocation request. As long as we fix only numa aware shrinkers,
fault injection will still allow numa unaware shrinkers to crash.

We need to make sure that all shrinkers are ready to handle allocation request,
or make register_shrinker() never fail, or (a different approach shown below)
let register_shrinker() fallback to numa unaware if memory allocation request
failed (because Michal is assuming that most architectures do not have that
many numa nodes to care which means that kmalloc() unlikely fails).

 include/linux/shrinker.h |  4 +++-
 mm/vmscan.c              | 28 ++++++++++++++--------------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index a389491..9caf67b 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -66,6 +66,8 @@ struct shrinker {
 
 	/* These are for internal use */
 	struct list_head list;
+	/* objs pending delete, global */
+	atomic_long_t nr_deferred_global;
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
@@ -75,6 +77,6 @@ struct shrinker {
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
 
-extern __must_check int register_shrinker(struct shrinker *);
+extern int register_shrinker(struct shrinker *); /* Always returns 0. */
 extern void unregister_shrinker(struct shrinker *);
 #endif
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6a5a72b..7a54229 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -276,15 +276,13 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
  */
 int register_shrinker(struct shrinker *shrinker)
 {
-	size_t size = sizeof(*shrinker->nr_deferred);
-
-	if (shrinker->flags & SHRINKER_NUMA_AWARE)
-		size *= nr_node_ids;
-
-	shrinker->nr_deferred = kzalloc(size, GFP_KERNEL);
-	if (!shrinker->nr_deferred)
-		return -ENOMEM;
-
+	atomic_long_set(&shrinker->nr_deferred_global, 0);
+	if (shrinker->flags & SHRINKER_NUMA_AWARE) {
+		shrinker->nr_deferred = kzalloc(sizeof(atomic_long_t) *
+						nr_node_ids, GFP_KERNEL);
+		if (!shrinker->nr_deferred)
+			shrinker->flags &= ~SHRINKER_NUMA_AWARE;
+	}
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
 	up_write(&shrinker_rwsem);
@@ -300,7 +298,8 @@ void unregister_shrinker(struct shrinker *shrinker)
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
-	kfree(shrinker->nr_deferred);
+	if (shrinker->flags & SHRINKER_NUMA_AWARE)
+		kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
@@ -319,6 +318,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	long batch_size = shrinker->batch ? shrinker->batch
 					  : SHRINK_BATCH;
 	long scanned = 0, next_deferred;
+	atomic_long_t *nr_deferred = (shrinker->flags & SHRINKER_NUMA_AWARE) ?
+		&shrinker->nr_deferred[nid] : &shrinker->nr_deferred_global;
 
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
 	if (freeable == 0)
@@ -329,7 +330,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 * and zero it so that other concurrent shrinker invocations
 	 * don't also do this scanning work.
 	 */
-	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
+	nr = atomic_long_xchg(nr_deferred, 0);
 
 	total_scan = nr;
 	delta = freeable >> priority;
@@ -414,10 +415,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 * scan, there is no need to do an update.
 	 */
 	if (next_deferred > 0)
-		new_nr = atomic_long_add_return(next_deferred,
-						&shrinker->nr_deferred[nid]);
+		new_nr = atomic_long_add_return(next_deferred, nr_deferred);
 	else
-		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
+		new_nr = atomic_long_read(nr_deferred);
 
 	trace_mm_shrink_slab_end(shrinker, nid, freed, nr, new_nr, total_scan);
 	return freed;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
