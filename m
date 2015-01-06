Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8996B012B
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:38 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id i50so73348qgf.11
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:38 -0800 (PST)
Received: from mail-qa0-x229.google.com (mail-qa0-x229.google.com. [2607:f8b0:400d:c00::229])
        by mx.google.com with ESMTPS id o43si14323399qge.107.2015.01.06.13.26.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:37 -0800 (PST)
Received: by mail-qa0-f41.google.com with SMTP id s7so242250qap.0
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:36 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 04/45] memcg, writeback: implement memcg_blkcg_ptr
Date: Tue,  6 Jan 2015 16:25:41 -0500
Message-Id: <1420579582-8516-5-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

One of the challenges in implementing cgroup writeback support is
determining the blkcg to attribute each page to.  we can add a
per-page pointer pointing to the blkcg of the dirtier similar to
page->mem_cgroup; however, this is quite a bit of overhead for
information which is mostly duplicate to the existing
page->mem_cgroup.

When a page is charged to a memcg, the page is attributed to the
memcg.  Writeback is tied to memory pressure which is determined by
memcg membership, so it makes an inherent sense to attribute writeback
of a page to the blkcg which corresponds to the page's memcg.

If we assume that memcg and blkcg are always enabled and disable
together, this can be trivially implemented by adding a pointer to the
corresponding blkcg to each memcg and using that whenever issuing
writeback IO; however, on the unified hierarchy, the controllers can
be enabled and disabled separately meaning that the corresponding
blkcg for a given memcg may change dynamically.  To accomodate this,
two reference counted colored pointers are used.  The active pointer
is used whenever dirtying a new page.  When the association changes,
the other pointer is updated to point to the new blkcg and becomes
active while the currently active one becomes inactive and drained.

This way, each page can point to the blkcg it's associated with using,
theoretically, just single bit selecting between the two blkcg
pointers of its memcg while still allowing dynamic change of the
corresponding blkcg for the memcg.

In practice, we end up having to use four bits - two separate
associations each of which occupying two bits.  Each association takes
two bits because we must always be able to fall back to the root memcg
due to, for example, memory allocation failure, and we two two
separate associations for dirtied and writeback phases and to prevent
pages being repeatedly redirtied while being written from indefinitely
delaying inactive pointer draining.  Refer to comments in
mm/memcontrol.c for more details.

The page to blkcg association established by this patch will be used
as the basis of cgroup writeback support.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c           |  32 ++++
 include/linux/backing-dev.h |   1 +
 include/linux/memcontrol.h  |  56 ++++++
 mm/filemap.c                |   1 +
 mm/memcontrol.c             | 438 +++++++++++++++++++++++++++++++++++++++++++-
 mm/page-writeback.c         |   6 +-
 mm/truncate.c               |   1 +
 7 files changed, 532 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 97c92b3..138a5ea 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -106,6 +106,36 @@ out_unlock:
 	spin_unlock_bh(&wb->work_lock);
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+/**
+ * init_cgwb_dirty_page_context - init cgwb part of dirty_context
+ * @dctx: dirty_context being initialized
+ *
+ * @dctx is being initialized by init_dirty_page_context().  Initialize
+ * cgroup writeback part of it.
+ */
+static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
+{
+	/* cgroup writeback requires support from both the bdi and filesystem */
+	if (!mapping_cgwb_enabled(dctx->mapping))
+		goto force_root;
+
+	page_blkcg_attach_dirty(dctx->page);
+	return;
+
+force_root:
+	page_blkcg_force_root_dirty(dctx->page);
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
+{
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 /**
  * init_dirty_page_context - init dirty_context for page dirtying
  * @dctx: dirty_context to initialize
@@ -129,6 +159,8 @@ void init_dirty_page_context(struct dirty_context *dctx, struct page *page,
 	dctx->mapping = page_mapping(page);
 
 	BUG_ON(dctx->mapping != mapping);
+
+	init_cgwb_dirty_page_context(dctx);
 }
 EXPORT_SYMBOL_GPL(init_dirty_page_context);
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 68c2fd7..7a20cff 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -12,6 +12,7 @@
 #include <linux/fs.h>
 #include <linux/sched.h>
 #include <linux/writeback.h>
+#include <linux/memcontrol.h>
 
 #include <linux/backing-dev-defs.h>
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 04d3c20..27dad0b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -23,6 +23,8 @@
 #include <linux/vm_event_item.h>
 #include <linux/hardirq.h>
 #include <linux/jump_label.h>
+#include <linux/percpu-refcount.h>
+#include <linux/blk-cgroup.h>
 
 struct mem_cgroup;
 struct page;
@@ -536,5 +538,59 @@ static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 }
 #endif /* CONFIG_MEMCG_KMEM */
+
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+struct cgroup_subsys_state *page_blkcg_dirty(struct page *page);
+struct cgroup_subsys_state *page_blkcg_wb(struct page *page);
+struct cgroup_subsys_state *page_blkcg_attach_dirty(struct page *page);
+struct cgroup_subsys_state *page_blkcg_attach_wb(struct page *page);
+void page_blkcg_detach_dirty(struct page *page);
+void page_blkcg_detach_wb(struct page *page);
+void page_blkcg_force_root_dirty(struct page *page);
+void page_blkcg_force_root_wb(struct page *page);
+
+#else /* CONFIG_CGROUP_WRITEBACK */
+
+static inline struct cgroup_subsys_state *page_blkcg_dirty(struct page *page)
+{
+	return blkcg_root_css;
+}
+
+static inline struct cgroup_subsys_state *page_blkcg_wb(struct page *page)
+{
+	return blkcg_root_css;
+}
+
+static inline struct cgroup_subsys_state *
+page_blkcg_attach_dirty(struct page *page)
+{
+	return blkcg_root_css;
+}
+
+static inline struct cgroup_subsys_state *
+page_blkcg_attach_wb(struct page *page)
+{
+	return blkcg_root_css;
+}
+
+static inline void page_blkcg_detach_dirty(struct page *page)
+{
+}
+
+static inline void page_blkcg_detach_wb(struct page *page)
+{
+}
+
+static inline void page_blkcg_force_root_dirty(struct page *page)
+{
+}
+
+static inline void page_blkcg_force_root_wb(struct page *page)
+{
+}
+
+#endif /* CONFIG_CGROUP_WRITEBACK */
+
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/mm/filemap.c b/mm/filemap.c
index fdb4288..98a6675 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -212,6 +212,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_wb_stat(&mapping->backing_dev_info->wb, WB_RECLAIMABLE);
+		page_blkcg_detach_dirty(page);
 	}
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3ab3f04..aa0812b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -56,6 +56,7 @@
 #include <linux/oom.h>
 #include <linux/lockdep.h>
 #include <linux/file.h>
+#include <linux/blkdev.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -94,7 +95,23 @@ static int really_do_swap_account __initdata;
  * are cleared together with it.
  */
 enum page_cgflags {
+#ifdef CONFIG_CGROUP_WRITEBACK
+	/*
+	 * Flags to associate a page with blkcgs.  There are two
+	 * associations - one for dirtying, the other for writeback.  If
+	 * VALID is clear, the root blkcg is used.  If not, the COLOR bit
+	 * indexes page_memcg(page)->blkcg_ptr[].  The COLOR bits must
+	 * immediately follow the corresponding VALID bits.  See
+	 * memcg_blkcg_ptr implementation for more info.
+	 */
+	PCG_BLKCG_DIRTY_VALID	= 1UL << 0,
+	PCG_BLKCG_DIRTY_COLOR	= 1UL << 1,
+	PCG_BLKCG_WB_VALID	= 1UL << 2,
+	PCG_BLKCG_WB_COLOR	= 1UL << 3,
+	PCG_FLAGS_BITS		= 4,
+#else
 	PCG_FLAGS_BITS		= 0,
+#endif
 	PCG_FLAGS_MASK		= ((1UL << PCG_FLAGS_BITS) - 1),
 };
 
@@ -294,6 +311,15 @@ struct mem_cgroup_event {
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+struct memcg_blkcg_ptr {
+	struct cgroup_subsys_state	*css;
+	struct percpu_ref		ref;
+	struct mem_cgroup		*memcg;
+	struct work_struct		release_work;
+};
+#endif
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -385,6 +411,11 @@ struct mem_cgroup {
 	atomic_t	numainfo_updating;
 #endif
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+	int				blkcg_color;
+	struct memcg_blkcg_ptr		blkcg_ptr[2];
+#endif
+
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
@@ -3418,6 +3449,397 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+/*
+ * memcg_blkcg_ptr implementation.
+ *
+ * A charged page is associated with a memcg.  When the page gets dirtied
+ * and written back, we want to associate the dirtying and writeback to the
+ * matching blkcg so that the writeback IOs can be attributed to the
+ * originating cgroup and controlled accordingly.
+ *
+ * As adding another per-page pointer to track blkcg is undesirable and the
+ * matching effective blkcg for a given memcg is mostly static, it makes
+ * sense to track a page's associated blkcg through its associated memcg.
+ *
+ * If the relationship between memcg and blkcg were static, this would be
+ * trivial - a single pointer, e.g. page_memcg(page)->blkcg_css, would
+ * suffice; however, the corresponding blkcg may change as controllers are
+ * enabled and disabled.  To accommodate this, pointer coloring is used.
+ *
+ * There are two reference counted pointers and one of the two is the
+ * active one.  When a new page needs to be associated with its blkcg, the
+ * reference count for the active color pointer is incremented and the
+ * blkcg it points to is used.  The page only needs to record the one bit
+ * color to determine the associated blkcg.  If the corresponding blkcg
+ * changes, the other pointer is updated to point to the new blkcg and the
+ * active color is flipped.  The now inactive color pointer is maintained
+ * until all referencing pages are drained.
+ *
+ * Note that this two pointer scheme can only accommodate single on-going
+ * blkcg change.  If the matching effective blkcg changes again while the
+ * inactive pointer is still being drained from the previous round, the new
+ * update is delayed until the draining is complete.
+ *
+ * A page needs to be associated with its blkcg while it's dirty and being
+ * written back.  The page may be re-dirtied repeatedly while being written
+ * back, which can prevent blkcg pointer draining from making progress as
+ * the reference the page holds may never be put.  To break this possible
+ * live-lock, a page uses two separate pointer colors for dirtying and
+ * writeback where the latter inherits the former on writeback start.
+ * Splitting the writeback association from the dirty one ensures that the
+ * current color is guaranteed to drain after a single writeback cycle as
+ * new dirtying can always take on the current active color.
+ */
+
+static DEFINE_MUTEX(memcg_blkcg_ptr_mutex);
+static DECLARE_WAIT_QUEUE_HEAD(memcg_blkcg_ptr_waitq);
+
+/**
+ * memcg_blkcg_ptr_update_locked - update the memcg blkcg ptr
+ * @memcg: target mem_cgroup
+ *
+ * This function is called when the matching effective blkcg of @memcg may
+ * have changed.  If different from the currently active pointer and the
+ * inactive one is free, this function updates the inactive pointer to
+ * point to the corresponding blkcg, flips the active color and starts
+ * draining the previous one.
+ *
+ * This function should be called under memcg_blkcg_ptr_mutex.
+ */
+static void memcg_blkcg_ptr_update_locked(struct mem_cgroup *memcg)
+{
+	int cur_color = memcg->blkcg_color;
+	int next_color = !cur_color;
+	struct memcg_blkcg_ptr *cur_ptr = &memcg->blkcg_ptr[cur_color];
+	struct memcg_blkcg_ptr *next_ptr = &memcg->blkcg_ptr[next_color];
+	struct cgroup_subsys_state *blkcg_css;
+
+	lockdep_assert_held(&memcg_blkcg_ptr_mutex);
+
+	/*
+	 * Negative cur_color indicates that @memcg is defunct and no more
+	 * pointer update can happen till the previous one is complete.
+	 */
+	if (cur_color < 0 || next_ptr->css)
+		return;
+
+	/* acquire current matching blkcg and see whether update is needed */
+	blkcg_css = cgroup_get_e_css(memcg->css.cgroup, &blkio_cgrp_subsys);
+	if (blkcg_css == cur_ptr->css) {
+		css_put(blkcg_css);
+		return;
+	}
+
+	/* init the next ptr, flip the color and start draining the prev */
+	next_ptr->css = blkcg_css;
+	percpu_ref_reinit(&next_ptr->ref);
+	memcg->blkcg_color = next_color;
+
+	if (cur_ptr->css)
+		percpu_ref_kill(&cur_ptr->ref);
+}
+
+static void memcg_blkcg_ptr_update(struct mem_cgroup *memcg)
+{
+	mutex_lock(&memcg_blkcg_ptr_mutex);
+	memcg_blkcg_ptr_update_locked(memcg);
+	mutex_unlock(&memcg_blkcg_ptr_mutex);
+}
+
+static void memcg_blkcg_ref_release_workfn(struct work_struct *work)
+{
+	struct memcg_blkcg_ptr *ptr =
+		container_of(work, struct memcg_blkcg_ptr, release_work);
+	struct mem_cgroup *memcg = ptr->memcg;
+
+	/* @ptr just finished draining, put the blkcg it was pointing to */
+	css_put(ptr->css);
+
+	/*
+	 * Mark @ptr free and try updating as previous update attempts may
+	 * have been delayed because @ptr was occupied.
+	 */
+	mutex_lock(&memcg_blkcg_ptr_mutex);
+	ptr->css = NULL;
+	memcg_blkcg_ptr_update_locked(memcg);
+	mutex_unlock(&memcg_blkcg_ptr_mutex);
+
+	wake_up_all(&memcg_blkcg_ptr_waitq);
+}
+
+static void memcg_blkcg_ref_release(struct percpu_ref *ref)
+{
+	struct memcg_blkcg_ptr *ptr =
+		container_of(ref, struct memcg_blkcg_ptr, ref);
+
+	schedule_work(&ptr->release_work);
+}
+
+static int memcg_blkcg_ptr_init(struct mem_cgroup *memcg)
+{
+	int i, ret;
+
+	/*
+	 * The first ptr_update always flips the color.  Let's init w/ 1 so
+	 * that we start with 0 after the initial ptr_update.
+	 */
+	memcg->blkcg_color = 1;
+
+	for (i = 0; i < ARRAY_SIZE(memcg->blkcg_ptr); i++) {
+		struct memcg_blkcg_ptr *ptr = &memcg->blkcg_ptr[i];
+
+		/* start dead, ptr_update will reinit the next ptr */
+		ret = percpu_ref_init(&ptr->ref, memcg_blkcg_ref_release,
+				      PERCPU_REF_INIT_DEAD, GFP_KERNEL);
+		if (ret) {
+			while (--i >= 0)
+				percpu_ref_exit(&memcg->blkcg_ptr[i].ref);
+			return ret;
+		}
+
+		ptr->memcg = memcg;
+		INIT_WORK(&ptr->release_work, memcg_blkcg_ref_release_workfn);
+	}
+
+	return 0;
+}
+
+static void memcg_blkcg_ptr_exit(struct mem_cgroup *memcg)
+{
+	int i;
+
+	mutex_lock(&memcg_blkcg_ptr_mutex);
+
+	/* disable further ptr_update */
+	memcg->blkcg_color = -1;
+
+	for (i = 0; i < ARRAY_SIZE(memcg->blkcg_ptr); i++) {
+		struct memcg_blkcg_ptr *ptr = &memcg->blkcg_ptr[i];
+
+		/* force start draining and wait for its completion */
+		if (!percpu_ref_is_dying(&ptr->ref))
+			percpu_ref_kill(&ptr->ref);
+		if (ptr->css) {
+			mutex_unlock(&memcg_blkcg_ptr_mutex);
+			wait_event(memcg_blkcg_ptr_waitq, !ptr->css);
+			mutex_lock(&memcg_blkcg_ptr_mutex);
+		}
+		percpu_ref_exit(&ptr->ref);
+	}
+
+	mutex_unlock(&memcg_blkcg_ptr_mutex);
+}
+
+static __always_inline struct cgroup_subsys_state *
+page_blkcg(struct page *page, unsigned int valid_flag, unsigned int color_flag)
+{
+	struct mem_cgroup *memcg = page_memcg(page);
+	unsigned long memcg_v = page->mem_cgroup;
+	int color;
+
+	if (!(memcg_v & valid_flag))
+		return blkcg_root_css;
+
+	color = (bool)(memcg_v & color_flag);
+	return memcg->blkcg_ptr[color].css;
+}
+
+/**
+ * page_blkcg_dirty - the blkcg a page is associated with for dirtying
+ * @page: page in question
+ */
+struct cgroup_subsys_state *page_blkcg_dirty(struct page *page)
+{
+	return page_blkcg(page, PCG_BLKCG_DIRTY_VALID, PCG_BLKCG_DIRTY_COLOR);
+}
+
+/**
+ * page_blkcg_writeback - the blkcg a page is associated with for writeback
+ * @page: page in question
+ */
+struct cgroup_subsys_state *page_blkcg_wb(struct page *page)
+{
+	return page_blkcg(page, PCG_BLKCG_WB_VALID, PCG_BLKCG_WB_COLOR);
+}
+
+static __always_inline void page_cgflags_update(struct page *page,
+						unsigned long cgflags_mask,
+						unsigned long cgflags_target)
+{
+	unsigned long memcg_v = page->mem_cgroup;
+
+	WARN_ON_ONCE(!memcg_v);
+
+	/* dirty the cacheline only when necessary */
+	if ((memcg_v & cgflags_mask) != cgflags_target)
+		page->mem_cgroup = (memcg_v & ~cgflags_mask) | cgflags_target;
+}
+
+/**
+ * page_blkcg_attach_dirty - associate a page with its dirtying blkcg
+ * @page: target page
+ *
+ * This function is to be called when @page is being newly dirtied and
+ * makes the active corresponding blkcg of its memcg its dirty blkcg.  This
+ * blkcg can be retrieved using page_blkcg_dirty().
+ */
+struct cgroup_subsys_state *page_blkcg_attach_dirty(struct page *page)
+{
+	struct mem_cgroup *memcg = page_memcg(page);
+	struct memcg_blkcg_ptr *ptr;
+	int color;
+
+	while (true) {
+		color = memcg->blkcg_color;
+		ptr = &memcg->blkcg_ptr[color];
+		if (ptr->css == blkcg_root_css)
+			goto root_css;
+		if (likely(percpu_ref_tryget(&ptr->ref)))
+			break;
+		cpu_relax();
+	}
+
+	page_cgflags_update(page, PCG_BLKCG_DIRTY_VALID | PCG_BLKCG_DIRTY_COLOR,
+			    PCG_BLKCG_DIRTY_VALID |
+			    (color ? PCG_BLKCG_DIRTY_COLOR : 0));
+	return ptr->css;
+root_css:
+	page_cgflags_update(page, PCG_BLKCG_DIRTY_VALID, 0);
+	return blkcg_root_css;
+}
+
+/**
+ * page_blkcg_attach_wb - associate a page with its writeback blkcg
+ * @page: target page
+ *
+ * This function is to be called when @page is about to be written back and
+ * makes its dirty blkcg its writeback blkcg.  This blkcg can be retrieved
+ * using page_blkcg_wb().
+ */
+struct cgroup_subsys_state *page_blkcg_attach_wb(struct page *page)
+{
+	unsigned long memcg_v = page->mem_cgroup;
+	struct mem_cgroup *memcg = page_memcg(page);
+	struct memcg_blkcg_ptr *ptr;
+	int color;
+
+	if (!(memcg_v & PCG_BLKCG_DIRTY_VALID))
+		goto root_css;
+
+	/*
+	 * Inherit @page's dirty color.  @page's dirty color is already
+	 * detached at this point, and, if the associated memcg's active
+	 * color has flipped, the page may already have been redirtied with
+	 * a different color or the blkcg_ptr released.
+	 *
+	 * If @page has been redirtied to a different blkcg before
+	 * writeback starts on the previous dirty state, the writeback is
+	 * attributed to the new blkcg.  The race window isn't huge and
+	 * charging to the new blkcg isn't strictly wrong as @page got
+	 * redirtied to the new blkcg after all.
+	 *
+	 * If @page's dirty blkcg_ptr already got released, we fall back to
+	 * the root blkcg.  This can only happen if blkcg_ptr's reference
+	 * count reached zero since the put of @page's dirty reference
+	 * making it highly unlikely to happen to more than few pages.
+	 *
+	 * We may attach some pages to the wrong blkcg across memcg-blkcg
+	 * correspondence change but such changes are rare to begin with
+	 * and the number of pages we may misattribute is pretty limited.
+	 */
+	color = (bool)(memcg_v & PCG_BLKCG_DIRTY_COLOR);
+	ptr = &memcg->blkcg_ptr[color];
+	if (unlikely(!percpu_ref_tryget(&ptr->ref)))
+		goto root_css;
+
+	page_cgflags_update(page, PCG_BLKCG_WB_VALID | PCG_BLKCG_WB_COLOR,
+			    PCG_BLKCG_WB_VALID |
+			    (color ? PCG_BLKCG_WB_COLOR : 0));
+	return ptr->css;
+root_css:
+	page_cgflags_update(page, PCG_BLKCG_WB_VALID, 0);
+	return blkcg_root_css;
+}
+
+static __always_inline void
+page_blkcg_detach(struct page *page, unsigned valid_flag, unsigned color_flag)
+{
+	unsigned long memcg_v = page->mem_cgroup;
+	struct mem_cgroup *memcg = page_memcg(page);
+	int color;
+
+	if (!(memcg_v & valid_flag))
+		return;
+
+	color = (bool)(memcg_v & color_flag);
+	percpu_ref_put(&memcg->blkcg_ptr[color].ref);
+}
+
+/**
+ * page_blkcg_detach_dirty - disassociate a page from its dirty blkcg
+ * @page: target page
+ *
+ * Put @page's current dirty blkcg association.  This function must be
+ * called before @page's dirtiness is cleared.
+ */
+void page_blkcg_detach_dirty(struct page *page)
+{
+	page_blkcg_detach(page, PCG_BLKCG_DIRTY_VALID, PCG_BLKCG_DIRTY_COLOR);
+}
+
+/**
+ * page_blkcg_detach_wb - disassociate a page from its writeback blkcg
+ * @page: target page
+ *
+ * Put @page's current writeback blkcg association.  This funtion must be
+ * called before @page's writeback is complete.
+ */
+void page_blkcg_detach_wb(struct page *page)
+{
+	page_blkcg_detach(page, PCG_BLKCG_WB_VALID, PCG_BLKCG_WB_COLOR);
+}
+
+/**
+ * page_blkcg_force_root_dirty - force a page's dirty blkcg to be the root one
+ * @page: target page
+ *
+ * The caller must ensure that @page doesn't have dirty blkcg attached.
+ */
+void page_blkcg_force_root_dirty(struct page *page)
+{
+	page_cgflags_update(page, PCG_BLKCG_DIRTY_VALID, 0);
+}
+
+/**
+ * page_blkcg_force_root_wb - force a page's writeback blkcg to be the root one
+ * @page: target page
+ *
+ * The caller must ensure that @page doesn't have writeback blkcg attached.
+ */
+void page_blkcg_force_root_wb(struct page *page)
+{
+	page_cgflags_update(page, PCG_BLKCG_WB_VALID, 0);
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static void memcg_blkcg_ptr_update(struct mem_cgroup *memcg)
+{
+}
+
+static int memcg_blkcg_ptr_init(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
+static void memcg_blkcg_ptr_exit(struct mem_cgroup *memcg)
+{
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 /*
  * The user of this function is...
  * RES_LIMIT.
@@ -4560,6 +4982,10 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		if (alloc_mem_cgroup_per_zone_info(memcg, node))
 			goto free_out;
 
+	error = memcg_blkcg_ptr_init(memcg);
+	if (error)
+		goto free_out;
+
 	/* root ? */
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
@@ -4599,7 +5025,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		return -ENOSPC;
 
 	if (!parent)
-		return 0;
+		goto done;
 
 	mutex_lock(&memcg_create_mutex);
 
@@ -4642,7 +5068,8 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	 * reading the memcg members.
 	 */
 	smp_store_release(&memcg->initialized, 1);
-
+done:
+	memcg_blkcg_ptr_update(memcg);
 	return 0;
 }
 
@@ -4671,6 +5098,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	memcg_destroy_kmem(memcg);
+	memcg_blkcg_ptr_exit(memcg);
 	__mem_cgroup_free(memcg);
 }
 
@@ -4697,6 +5125,11 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 }
 
+static void mem_cgroup_css_e_css_changed(struct cgroup_subsys_state *css)
+{
+	memcg_blkcg_ptr_update(mem_cgroup_from_css(css));
+}
+
 #ifdef CONFIG_MMU
 /* Handlers for move charge at task migration. */
 static int mem_cgroup_do_precharge(unsigned long count)
@@ -5288,6 +5721,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.css_offline = mem_cgroup_css_offline,
 	.css_free = mem_cgroup_css_free,
 	.css_reset = mem_cgroup_css_reset,
+	.css_e_css_changed = mem_cgroup_css_e_css_changed,
 	.can_attach = mem_cgroup_can_attach,
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0e35ff4..72a0edf 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2303,6 +2303,7 @@ int clear_page_dirty_for_io(struct page *page)
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_wb_stat(&mapping->backing_dev_info->wb,
 				    WB_RECLAIMABLE);
+			page_blkcg_detach_dirty(page);
 			return 1;
 		}
 		return 0;
@@ -2330,6 +2331,7 @@ int test_clear_page_writeback(struct page *page)
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi)) {
 				__dec_wb_stat(&bdi->wb, WB_WRITEBACK);
+				page_blkcg_detach_wb(page);
 				__wb_writeout_inc(&bdi->wb);
 			}
 		}
@@ -2363,8 +2365,10 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-			if (bdi_cap_account_writeback(bdi))
+			if (bdi_cap_account_writeback(bdi)) {
 				__inc_wb_stat(&bdi->wb, WB_WRITEBACK);
+				page_blkcg_attach_wb(page);
+			}
 		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
diff --git a/mm/truncate.c b/mm/truncate.c
index 3fcd662..caae624 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -116,6 +116,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 				    WB_RECLAIMABLE);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
+			page_blkcg_detach_dirty(page);
 		}
 	}
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
