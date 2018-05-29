Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2536B0007
	for <linux-mm@kvack.org>; Tue, 29 May 2018 04:26:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z16-v6so3676982pge.21
        for <linux-mm@kvack.org>; Tue, 29 May 2018 01:26:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m26-v6sor8558403pgc.77.2018.05.29.01.26.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 01:26:54 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2] doc: document scope NOFS, NOIO APIs
Date: Tue, 29 May 2018 10:26:44 +0200
Message-Id: <20180529082644.26192-1-mhocko@kernel.org>
In-Reply-To: <20180524114341.1101-1-mhocko@kernel.org>
References: <20180524114341.1101-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Dave Chinner <david@fromorbit.com>, Randy Dunlap <rdunlap@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Although the api is documented in the source code Ted has pointed out
that there is no mention in the core-api Documentation and there are
people looking there to find answers how to use a specific API.

Changes since v1
- add kerneldoc for the api - suggested by Johnatan
- review feedback from Dave and Johnatan
- feedback from Dave about more general critical context rather than
  locking
- feedback from Mike
- typo fixed - Randy, Dave

Requested-by: "Theodore Y. Ts'o" <tytso@mit.edu>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 .../core-api/gfp_mask-from-fs-io.rst          | 61 +++++++++++++++++++
 Documentation/core-api/index.rst              |  1 +
 include/linux/sched/mm.h                      | 38 ++++++++++++
 3 files changed, 100 insertions(+)
 create mode 100644 Documentation/core-api/gfp_mask-from-fs-io.rst

diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
new file mode 100644
index 000000000000..2dc442b04a77
--- /dev/null
+++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
@@ -0,0 +1,61 @@
+=================================
+GFP masks used from FS/IO context
+=================================
+
+:Date: May, 2018
+:Author: Michal Hocko <mhocko@kernel.org>
+
+Introduction
+============
+
+Code paths in the filesystem and IO stacks must be careful when
+allocating memory to prevent recursion deadlocks caused by direct
+memory reclaim calling back into the FS or IO paths and blocking on
+already held resources (e.g. locks - most commonly those used for the
+transaction context).
+
+The traditional way to avoid this deadlock problem is to clear __GFP_FS
+respectively __GFP_IO (note the latter implies clearing the first as well) in
+the gfp mask when calling an allocator. GFP_NOFS respectively GFP_NOIO can be
+used as shortcut. It turned out though that above approach has led to
+abuses when the restricted gfp mask is used "just in case" without a
+deeper consideration which leads to problems because an excessive use
+of GFP_NOFS/GFP_NOIO can lead to memory over-reclaim or other memory
+reclaim issues.
+
+New API
+========
+
+Since 4.12 we do have a generic scope API for both NOFS and NOIO context
+``memalloc_nofs_save``, ``memalloc_nofs_restore`` respectively ``memalloc_noio_save``,
+``memalloc_noio_restore`` which allow to mark a scope to be a critical
+section from a filesystem or I/O point of view. Any allocation from that
+scope will inherently drop __GFP_FS respectively __GFP_IO from the given
+mask so no memory allocation can recurse back in the FS/IO.
+
+FS/IO code then simply calls the appropriate save function before
+any critical section with respect to the reclaim is started - e.g.
+lock shared with the reclaim context or when a transaction context
+nesting would be possible via reclaim. The restore function should be
+called when the critical section ends. All that ideally along with an
+explanation what is the reclaim context for easier maintenance.
+
+Please note that the proper pairing of save/restore functions
+allows nesting so it is safe to call ``memalloc_noio_save`` or
+``memalloc_noio_restore`` respectively from an existing NOIO or NOFS
+scope.
+
+What about __vmalloc(GFP_NOFS)
+==============================
+
+vmalloc doesn't support GFP_NOFS semantic because there are hardcoded
+GFP_KERNEL allocations deep inside the allocator which are quite non-trivial
+to fix up. That means that calling ``vmalloc`` with GFP_NOFS/GFP_NOIO is
+almost always a bug. The good news is that the NOFS/NOIO semantic can be
+achieved by the scope API.
+
+In the ideal world, upper layers should already mark dangerous contexts
+and so no special care is required and vmalloc should be called without
+any problems. Sometimes if the context is not really clear or there are
+layering violations then the recommended way around that is to wrap ``vmalloc``
+by the scope API with a comment explaining the problem.
diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index c670a8031786..8a5f48ef16f2 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -25,6 +25,7 @@ Core utilities
    genalloc
    errseq
    printk-formats
+   gfp_mask-from-fs-io
 
 Interfaces for kernel debugging
 ===============================
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index e1f8411e6b80..af5ba077bbc4 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -166,6 +166,17 @@ static inline void fs_reclaim_acquire(gfp_t gfp_mask) { }
 static inline void fs_reclaim_release(gfp_t gfp_mask) { }
 #endif
 
+/**
+ * memalloc_noio_save - Marks implicit GFP_NOIO allocation scope.
+ *
+ * This functions marks the beginning of the GFP_NOIO allocation scope.
+ * All further allocations will implicitly drop __GFP_IO flag and so
+ * they are safe for the IO critical section from the allocation recursion
+ * point of view. Use memalloc_noio_restore to end the scope with flags
+ * returned by this function.
+ *
+ * This function is safe to be used from any context.
+ */
 static inline unsigned int memalloc_noio_save(void)
 {
 	unsigned int flags = current->flags & PF_MEMALLOC_NOIO;
@@ -173,11 +184,30 @@ static inline unsigned int memalloc_noio_save(void)
 	return flags;
 }
 
+/**
+ * memalloc_noio_restore - Ends the implicit GFP_NOIO scope.
+ * @flags: Flags to restore.
+ *
+ * Ends the implicit GFP_NOIO scope started by memalloc_noio_save function.
+ * Always make sure that that the given flags is the return value from the
+ * pairing memalloc_noio_save call.
+ */
 static inline void memalloc_noio_restore(unsigned int flags)
 {
 	current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flags;
 }
 
+/**
+ * memalloc_nofs_save - Marks implicit GFP_NOFS allocation scope.
+ *
+ * This functions marks the beginning of the GFP_NOFS allocation scope.
+ * All further allocations will implicitly drop __GFP_FS flag and so
+ * they are safe for the FS critical section from the allocation recursion
+ * point of view. Use memalloc_nofs_restore to end the scope with flags
+ * returned by this function.
+ *
+ * This function is safe to be used from any context.
+ */
 static inline unsigned int memalloc_nofs_save(void)
 {
 	unsigned int flags = current->flags & PF_MEMALLOC_NOFS;
@@ -185,6 +215,14 @@ static inline unsigned int memalloc_nofs_save(void)
 	return flags;
 }
 
+/**
+ * memalloc_nofs_restore - Ends the implicit GFP_NOFS scope.
+ * @flags: Flags to restore.
+ *
+ * Ends the implicit GFP_NOFS scope started by memalloc_nofs_save function.
+ * Always make sure that that the given flags is the return value from the
+ * pairing memalloc_nofs_save call.
+ */
 static inline void memalloc_nofs_restore(unsigned int flags)
 {
 	current->flags = (current->flags & ~PF_MEMALLOC_NOFS) | flags;
-- 
2.17.0
