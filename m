Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0C92562008B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 11:15:02 -0400 (EDT)
Date: Wed, 5 May 2010 16:14:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] fix count_vm_event preempt in memory compaction direct
	reclaim
Message-ID: <20100505151439.GQ20979@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie> <1271797276-31358-13-git-send-email-mel@csn.ul.ie> <20100505121908.GA5835@random.random> <20100505125156.GM20979@csn.ul.ie> <20100505131112.GB5835@random.random> <20100505135537.GO20979@csn.ul.ie> <20100505144813.GI5835@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100505144813.GI5835@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 04:48:13PM +0200, Andrea Arcangeli wrote:
> On Wed, May 05, 2010 at 02:55:38PM +0100, Mel Gorman wrote:
> > I haven't seen this problem. The testing I'd have been doing with compaction
> > were stress tests allocating huge pages but not from the fault path.
> 
> That explains it! But anything can call alloc_pages(order>0) with some
> semaphore held.
> 

True.

> > It's not mandatory but the LRU lists should be drained so they can be properly
> > isolated. It'd make a slight difference to success rates as there will be
> > pages that cannot be isolated because they are on some pagevec.
> 
> Yes success rate will be slightly worse but this also applies to all
> regular vmscan paths that don't send IPI but they only flush the local
> queue with lru_add_drain, simply pages won't be freed until there will
> be some other cpu holding the refcount on them, it is not specific to
> compaction.c but it applies to vmscan.c and vmscan likely not wanting
> to send an IPI flood because it could too if it wanted.
> 

Again, true.

> But I guess I should at least use lru_add_drain() in replacement of
> migrate_prep...
> 

Or a migrate_prep_local? migrate_prep() was there in case there was extensive
work that needed to be done. At least if the two versions were beside each
other, it would be a bit clearer if migrate_prep was ever modified. It'd
also be self-documenting that migrate_prep() was omitted on purpose.

> > While true, is compaction density that high under normal workloads? I guess
> > it would be if a scanner was constantly trying to promote pages.  If the
> > IPI load is out of hand, I'm ok with disabling in some cases. For example,
> > I'd be ok with it being skipped if it was part of a daemon doing speculative
> > promotion but I'd prefer it to still be used if the static hugetlbfs pool
> > was being resized if that was possible.
> 
> I don't know if IPI is measurable, but it usually is...
> 

Actually, it's not an IPI in this case is it?  As it's schedule_on_each_cpu,
it should be added to a workqueue and executed by keventd at some point in the
future. It's still not great to be giving other CPUs work just for compaction.

> > > -----
> > > Subject: disable migrate_prep()
> > > 
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > I get trouble from lockdep if I leave it enabled:
> > > 
> > > =======================================================
> > > [ INFO: possible circular locking dependency detected ]
> > > 2.6.34-rc3 #50
> > > -------------------------------------------------------
> > > largepages/4965 is trying to acquire lock:
> > >  (events){+.+.+.}, at: [<ffffffff8105b788>] flush_work+0x38/0x130
> > > 
> > >  but task is already holding lock:
> > >   (&mm->mmap_sem){++++++}, at: [<ffffffff8141b022>] do_page_fault+0xd2/0x430
> > > 
> > 
> > Hmm, I'm not seeing where in the fault path flush_work is getting called
> > from. Can you point it out to me please?
> 
> lru_add_drain_all->schedule_on_each_cpu->flush_work
> 

/me slaps self

> > We already do some IPI work in the page allocator although it happens after
> > direct reclaim and only for high-order pages. What happens there and what
> > happens in migrate_prep are very similar so if there was a problem with IPI
> > and fault paths, I'd have expected to see it from hugetlbfs at some stage.
> 
> Where? I never triggered other issues in the page allocator with
> lockdep, just this one pops up.
> 

Ah, it's the difference between schedule_on_each_cpu that migrate_prep does
and on_each_cpu that the page allocator uses. That's why I haven't seen
it before.

How about the following as an alternative to dropp migrate_prep?

==== CUT HERE ====
mm,compaction: Do not schedule work on other CPUs for compaction

Migration normally requires a call to migrate_prep() as a preparation
step. This schedules work on all CPUs for pagevecs to be drained. This
makes sense for move_pages and memory hot-remove but is unnecessary
for memory compaction.

To avoid queueing work on multiple CPUs, this patch introduces
migrate_prep_local() which drains just local pagevecs.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/migrate.h |    2 ++
 mm/compaction.c         |    2 +-
 mm/migrate.c            |   11 ++++++++++-
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 05d2292..6dec3ef 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -19,6 +19,7 @@ extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
 
 extern int migrate_prep(void);
+extern int migrate_prep_local(void);
 extern int migrate_vmas(struct mm_struct *mm,
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
@@ -32,6 +33,7 @@ static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, int offlining) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
+static inline int migrate_prep_local(void) { return -ENOSYS; }
 
 static inline int migrate_vmas(struct mm_struct *mm,
 		const nodemask_t *from, const nodemask_t *to,
diff --git a/mm/compaction.c b/mm/compaction.c
index bd13560..94cce51 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -383,7 +383,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
 	cc->free_pfn &= ~(pageblock_nr_pages-1);
 
-	migrate_prep();
+	migrate_prep_local();
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		unsigned long nr_migrate, nr_remaining;
diff --git a/mm/migrate.c b/mm/migrate.c
index 053fd39..7dd64b8 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -40,7 +40,8 @@
 
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
- * to be migrated using isolate_lru_page().
+ * to be migrated using isolate_lru_page(). If IPIs are undesirable, use
+ * migrate_prep_local()
  */
 int migrate_prep(void)
 {
@@ -55,6 +56,14 @@ int migrate_prep(void)
 	return 0;
 }
 
+/* Do the necessary work of migrate_prep but not if it involves IPIs */
+int migrate_prep_local(void)
+{
+	lru_add_drain();
+
+	return 0;
+}
+
 /*
  * Add isolated pages on the list back to the LRU under page lock
  * to avoid leaking evictable pages back onto unevictable list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
