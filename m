Subject: Re: [PATCH 6/6] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HZ3Q9-00062G-00@dorka.pomaz.szeredi.hu>
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
	 <20070403144224.709586192@taijtu.programming.kicks-ass.net>
	 <E1HZ1so-0005q8-00@dorka.pomaz.szeredi.hu> <1175681794.6483.43.camel@twins>
	 <E1HZ2kU-0005xx-00@dorka.pomaz.szeredi.hu> <1175684461.6483.64.camel@twins>
	 <E1HZ3Q9-00062G-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 14:05:56 +0200
Message-Id: <1175688356.6483.81.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 13:12 +0200, Miklos Szeredi wrote:
> > > > so it could be that: scale / cycle > 1
> > > > by a very small amount; however:
> > > 
> > > No, I'm worried about the case when scale is too small.  If the
> > > per-bdi threshold becomes smaller than stat_threshold, then things
> > > won't work, because dirty+writeback will never go below the threshold,
> > > possibly resulting in the deadlock we are trying to avoid.
> > 
> > /me goes refresh the deadlock details..
> > 
> > A writes to B; A exceeds the dirty limit but writeout is blocked by B
> > because the dirty limit is exceeded, right?
> > 
> > This cannot happen when we decouple the BDI dirty thresholds, even when
> > a threshold is 0.
> > 
> > A write to B; A exceeds A's limit and writes to B, B has limit of 0, the
> > 1 dirty page gets written out (we gain ratio) and life goes on.
> > 
> > Right?
> 
> If the limit is zero, then we need the per-bdi dirty+write to go to
> zero, otherwise balance_dirty_pages() loops.  But the per-bdi
> writeback counter is not necessarily updated after the writeback,
> because the per-bdi per-CPU counter may not trip the update of the
> per-bdi counter.

Aaah, Doh, yeah, that makes sense. I must be dense.

Funny that that never triggered, I do run SMP boxen. Hmm, what to do?

Preferably you'd want to be able to 'flush' the per cpu diffs or
something like that in cases where thresh ~< NR_CPUS * stat_diff.

How about something like this:

---
 include/linux/backing-dev.h |    5 ++++
 mm/backing-dev.c            |   51 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c         |    4 +++
 3 files changed, 60 insertions(+)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -117,6 +117,8 @@ void mod_bdi_stat(struct backing_dev_inf
 void inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
 void dec_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
 
+void bdi_flush_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
+void bdi_flush_all(struct backing_dev_info *bdi, enum bdi_stat_item item);
 #else /* CONFIG_SMP */
 
 static inline void __mod_bdi_stat(struct backing_dev_info *bdi,
@@ -142,6 +144,9 @@ static inline void __dec_bdi_stat(struct
 #define mod_bdi_stat __mod_bdi_stat
 #define inc_bdi_stat __inc_bdi_stat
 #define dec_bdi_stat __dec_bdi_stat
+
+#define bdi_flush_stat(bdi, item) do { } while (0)
+#define bdi_flush_all(bdi) do { } while (0)
 #endif
 
 void bdi_stat_init(struct backing_dev_info *bdi);
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c
+++ linux-2.6/mm/backing-dev.c
@@ -188,4 +188,55 @@ void dec_bdi_stat(struct backing_dev_inf
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(dec_bdi_stat);
+
+void ___bdi_flush_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
+{
+	struct bdi_per_cpu_data *pcd = &bdi->pcd[smp_processor_id()];
+	s8 *p = pcd->bdi_stat_diff + item;
+
+	bdi_stat_add(*p, bdi, item);
+	*p = 0;
+}
+
+struct bdi_flush_struct {
+	struct backing_dev_info *bdi;
+	enum bdi_stat_item item;
+};
+
+void __bdi_flush_stat(struct bdi_flush_struct *flush)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	___bdi_flush_stat(flush->bdi, flush->item);
+	local_irq_restore(flags);
+}
+
+void __bdi_flush_all(struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+	int i;
+
+	local_irq_save(flags);
+	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
+		___bdi_flush_stat(bdi, i);
+	local_irq_restore(flags);
+}
+
+void bdi_flush_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
+{
+	struct bdi_flush_struct flush = {
+		bdi,
+		item
+	};
+
+	on_each_cpu(__bdi_flush_stat, &flush, 0, 1);
+}
+EXPORT_SYMBOL(bdi_flush_stat);
+
+void bdi_flush_all(struct backing_dev_info *bdi)
+{
+	on_each_cpu(__bdi_flush_all, bdi, 0, 1);
+}
+EXPORT_SYMBOL(bdi_flush_all);
 #endif
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -345,6 +345,10 @@ static void balance_dirty_pages(struct a
 
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
+
+			if (bdi_thresh < NR_CPUS * 8 * ilog2(NR_CPUS))
+				bdi_flush_all(bdi);
+
 			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
 						bdi_stat(bdi, BDI_UNSTABLE);
 			if (bdi_nr_reclaimable + bdi_stat(bdi, BDI_WRITEBACK) <=





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
