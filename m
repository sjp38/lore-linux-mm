Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 4/4] mm, notifier: Add a lockdep map for invalidate_range_start
Date: Mon, 10 Dec 2018 11:36:41 +0100
Message-Id: <20181210103641.31259-5-daniel.vetter@ffwll.ch>
In-Reply-To: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
References: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: Intel Graphics Development <intel-gfx@lists.freedesktop.org>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Daniel Vetter <daniel.vetter@intel.com>
List-ID: <linux-mm.kvack.org>

This is a similar idea to the fs_reclaim fake lockdep lock. It's
fairly easy to provoke a specific notifier to be run on a specific
range: Just prep it, and then munmap() it.

A bit harder, but still doable, is to provoke the mmu notifiers for
all the various callchains that might lead to them. But both at the
same time is really hard to reliable hit, especially when you want to
exercise paths like direct reclaim or compaction, where it's not
easy to control what exactly will be unmapped.

By introducing a lockdep map to tie them all together we allow lockdep
to see a lot more dependencies, without having to actually hit them
in a single challchain while testing.

Aside: Since I typed this to test i915 mmu notifiers I've only rolled
this out for the invaliate_range_start callback. If there's
interest, we should probably roll this out to all of them. But my
undestanding of core mm is seriously lacking, and I'm not clear on
whether we need a lockdep map for each callback, or whether some can
be shared.

v2: Use lock_map_acquire/release() like fs_reclaim, to avoid confusion
with this being a real mutex (Chris Wilson).

Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/mmu_notifier.h | 6 ++++++
 mm/mmu_notifier.c            | 7 +++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 9893a6432adf..19be442606c6 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -12,6 +12,10 @@ struct mmu_notifier_ops;
 
 #ifdef CONFIG_MMU_NOTIFIER
 
+#ifdef CONFIG_LOCKDEP
+extern struct lockdep_map __mmu_notifier_invalidate_range_start_map;
+#endif
+
 /*
  * The mmu notifier_mm structure is allocated and installed in
  * mm->mmu_notifier_mm inside the mm_take_all_locks() protected
@@ -267,8 +271,10 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
+	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
 	if (mm_has_notifiers(mm))
 		__mmu_notifier_invalidate_range_start(mm, start, end, true);
+	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
 }
 
 static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index a50ed7d1ecef..c91d58fe388b 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -23,6 +23,13 @@
 /* global SRCU for all MMs */
 DEFINE_STATIC_SRCU(srcu);
 
+#ifdef CONFIG_LOCKDEP
+struct lockdep_map __mmu_notifier_invalidate_range_start_map = {
+	.name = "mmu_notifier_invalidate_range_start"
+};
+EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start_map);
+#endif
+
 /*
  * This function allows mmu_notifier::release callback to delay a call to
  * a function that will free appropriate resources. The function must be
-- 
2.20.0.rc1
