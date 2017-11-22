Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D03B6B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:56:04 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id g73so22116602ioj.0
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 02:56:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x144si3950894itc.153.2017.11.22.02.56.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 02:56:02 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
	<201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
In-Reply-To: <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
Message-Id: <201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
Date: Wed, 22 Nov 2017 19:53:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, glauber@scylladb.com, mhocko@kernel.org
Cc: linux-mm@kvack.org, david@fromorbit.com, viro@zeniv.linux.org.uk, jack@suse.com, pbonzini@redhat.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

Tetsuo Handa wrote:
> Andrew Morton wrote:
> > On Tue, 21 Nov 2017 21:02:37 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > 
> > > There are users not checking for register_shrinker() failure.
> > > Continuing with ignoring failure can lead to later oops at
> > > unregister_shrinker().
> > > 
> > > ...
> > >
> > > --- a/include/linux/shrinker.h
> > > +++ b/include/linux/shrinker.h
> > > @@ -75,6 +75,6 @@ struct shrinker {
> > >  #define SHRINKER_NUMA_AWARE	(1 << 0)
> > >  #define SHRINKER_MEMCG_AWARE	(1 << 1)
> > >  
> > > -extern int register_shrinker(struct shrinker *);
> > > +extern __must_check int register_shrinker(struct shrinker *);
> > >  extern void unregister_shrinker(struct shrinker *);
> > >  #endif
> > 
> > hm, well, OK, it's a small kmalloc(GFP_KERNEL).  That won't be
> > failing.
> 
> It failed by fault injection and resulted in a report at
> http://lkml.kernel.org/r/001a113f996099503a055e793dd3@google.com .

Since kzalloc() can become > 32KB allocation if CONFIG_NODES_SHIFT > 12
(which might not be impossible in near future), register_shrinker() can
potentially become a costly allocation which might fail without invoking
the OOM killer. It is a good opportunity to think whether we should allow
register_shrinker() to fail.

> 
> > 
> > Affected code seems to be fs/xfs, fs/super.c, fs/quota,
> > arch/x86/kvm/mmu, drivers/gpu/drm/ttm, drivers/md and a bunch of
> > staging stuff.
> > 
> > I'm not sure this is worth bothering about?
> > 
> 
> Continuing with failed register_shrinker() is almost always wrong.
> Though I don't know whether mm/zsmalloc.c case can make sense.
> 

Thinking from the fact that register_shrinker() had been "void" until Linux 3.11
and we did not take appropriate precautions when changing to "int" in Linux 3.12,
we need to consider making register_shrinker() "void" again.

If we could agree with opening up the use of __GFP_NOFAIL for allocating a few
non-contiguous pages on large systems, we can make register_shrinker() "void"
again. (Draft patch is shown below. I choose array of kmalloc(PAGE_SIZE)
rather than kvmalloc() in order to use __GFP_NOFAIL.)


 include/linux/shrinker.h |    4 +++-
 mm/vmscan.c              |   31 ++++++++++++++++++++++---------
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 388ff29..362a871 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -34,6 +34,8 @@ struct shrink_control {
 };
 
 #define SHRINK_STOP (~0UL)
+#define SHRINKER_SLOTS_PER_PAGE (PAGE_SIZE / sizeof(atomic_long_t))
+#define SHRINKER_SLOT_PAGES DIV_ROUND_UP(MAX_NUMNODES, SHRINKER_SLOTS_PER_PAGE)
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
@@ -67,7 +69,7 @@ struct shrinker {
 	/* These are for internal use */
 	struct list_head list;
 	/* objs pending delete, per node */
-	atomic_long_t *nr_deferred;
+	atomic_long_t *nr_deferred[SHRINKER_SLOT_PAGES];
 };
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1c1bc95..da1f633 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -276,14 +276,19 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
  */
 int register_shrinker(struct shrinker *shrinker)
 {
-	size_t size = sizeof(*shrinker->nr_deferred);
+	int i;
+	size_t size = sizeof(atomic_long_t);
 
 	if (shrinker->flags & SHRINKER_NUMA_AWARE)
 		size *= nr_node_ids;
 
-	shrinker->nr_deferred = kzalloc(size, GFP_KERNEL);
-	if (!shrinker->nr_deferred)
-		return -ENOMEM;
+	for (i = 0; i < SHRINKER_SLOT_PAGES; i++) {
+		const size_t s = size >= PAGE_SIZE ? PAGE_SIZE : size;
+
+		size -= s;
+		shrinker->nr_deferred[i] = kzalloc(s,
+						   GFP_KERNEL | __GFP_NOFAIL);
+	}
 
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
@@ -297,10 +302,12 @@ int register_shrinker(struct shrinker *shrinker)
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
+	int i;
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
-	kfree(shrinker->nr_deferred);
+	for (i = 0; i < SHRINKER_SLOT_PAGES; i++)
+		kfree(shrinker->nr_deferred[i]);
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
@@ -321,17 +328,24 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	long batch_size = shrinker->batch ? shrinker->batch
 					  : SHRINK_BATCH;
 	long scanned = 0, next_deferred;
+	atomic_long_t *nr_deferred;
 
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
 	if (freeable == 0)
 		return 0;
 
+	if (SHRINKER_SLOT_PAGES > 1)
+		nr_deferred = &shrinker->nr_deferred
+			[nid / SHRINKER_SLOTS_PER_PAGE]
+			[nid % SHRINKER_SLOTS_PER_PAGE];
+	else
+		nr_deferred = &shrinker->nr_deferred[0][nid];
 	/*
 	 * copy the current shrinker scan count into a local variable
 	 * and zero it so that other concurrent shrinker invocations
 	 * don't also do this scanning work.
 	 */
-	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
+	nr = atomic_long_xchg(nr_deferred, 0);
 
 	total_scan = nr;
 	delta = (4 * nr_scanned) / shrinker->seeks;
@@ -417,10 +431,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
