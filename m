Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 823FD6B0254
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 09:37:25 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so150932652wic.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 06:37:25 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id em7si29368978wib.117.2015.09.29.06.37.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Sep 2015 06:37:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 5060599351
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 13:37:23 +0000 (UTC)
Date: Tue, 29 Sep 2015 14:37:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 06/10] mm, page_alloc: Rename __GFP_WAIT to __GFP_RECLAIM
Message-ID: <20150929133721.GJ3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-7-git-send-email-mgorman@techsingularity.net>
 <20150928165523.a52facb27c7ff4c29d902b6c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150928165523.a52facb27c7ff4c29d902b6c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 28, 2015 at 04:55:23PM -0700, Andrew Morton wrote:
> > __GFP_WAIT was used to signal that the caller was in atomic context and
> > could not sleep.  Now it is possible to distinguish between true atomic
> > context and callers that are not willing to sleep. The latter should clear
> > __GFP_DIRECT_RECLAIM so kswapd will still wake. As clearing __GFP_WAIT
> > behaves differently, there is a risk that people will clear the wrong
> > flags. This patch renames __GFP_WAIT to __GFP_RECLAIM to clearly indicate
> > what it does -- setting it allows all reclaim activity, clearing them
> > prevents it.
> 
> We have quite a history of remote parts of the kernel using
> weird/wrong/inexplicable combinations of __GFP_ flags.  I tend to think
> that this is because we didn't adequately explain the interface.
> 
> And I don't think that gfp.h really improved much in this area as a
> result of this patchset.  Could you go through it some time and decide
> if we've adequately documented all this stuff?
> 

This? It's not fully build tested yet but any breakage should only
involve adding internal.h to some mm/ files.

---8<---
mm: page_alloc: Hide some GFP internals and document the bits and flag combinations

Andrew started the following

	We have quite a history of remote parts of the kernel using
	weird/wrong/inexplicable combinations of __GFP_ flags.	I tend
	to think that this is because we didn't adequately explain the
	interface.

	And I don't think that gfp.h really improved much in this area as
	a result of this patchset.  Could you go through it some time and
	decide if we've adequately documented all this stuff?

This patches first moves some GFP flag combinations that are part of the MM
internals to mm/internal.h. The rest of the patch documents the __GFP_FOO
bits under various headings and then documents the flag combinations. It
will not help callers that are brain damaged but the clarity might motivate
some fixes and avoid future mistakes.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/gfp.h | 252 +++++++++++++++++++++++++++++++++++-----------------
 mm/internal.h       |  19 ++++
 mm/shmem.c          |   2 +
 mm/vmalloc.c        |   2 +
 4 files changed, 193 insertions(+), 82 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 369227202ac2..67654f08a28b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -39,9 +39,7 @@ struct vm_area_struct;
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
- * GFP bitmasks..
- *
- * Zone modifiers (see linux/mmzone.h - low three bits)
+ * Physical address zone modifiers (see linux/mmzone.h - low four bits)
  *
  * Do not put any conditional on these. If necessary modify the definitions
  * without the underscores and use them consistently. The definitions here may
@@ -50,121 +48,209 @@ struct vm_area_struct;
 #define __GFP_DMA	((__force gfp_t)___GFP_DMA)
 #define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
 #define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
-#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* Page is movable */
+#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
 #define GFP_ZONEMASK	(__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
+
 /*
- * Action modifiers - doesn't change the zoning
+ * Page mobility and placement hints
  *
- * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
- * _might_ fail.  This depends upon the particular VM implementation.
+ * These flags provide hints about how mobile the page is. Pages with similar
+ * mobility are placed within the same pageblocks to minimise problems due
+ * to external fragmentation.
  *
- * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
- * cannot handle allocation failures. New users should be evaluated carefully
- * (and the flag should be used only when there is no reasonable failure policy)
- * but it is definitely preferable to use the flag rather than opencode endless
- * loop around allocator.
+ * __GFP_MOVABLE (also a zone modifier) indicates that the page can be
+ *   moved by page migration during memory compaction or can be reclaimed.
  *
- * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
- * return NULL when direct reclaim and memory compaction have failed to allow
- * the allocation to succeed.  The OOM killer is not called with the current
- * implementation.
+ * __GFP_RECLAIMABLE is used for slab allocations that specify
+ *   SLAB_RECLAIM_ACCOUNT and whose pages can be freed via shrinkers.
+ *
+ * __GFP_WRITE indicates the caller intends to dirty the page. Where possible,
+ *   these pages will be spread between local zones to avoid all the dirty
+ *   pages being in one zone (fair zone allocation policy).
  *
- * __GFP_MOVABLE: Flag that this page will be movable by the page migration
- * mechanism or reclaimed
+ * __GFP_HARDWALL enforces the cpuset memory allocation policy.
+ *
+ * __GFP_THISNODE forces the allocation to be satisified from the requested
+ *   node with no fallbacks or placement policy enforcements.
  */
-#define __GFP_ATOMIC	((__force gfp_t)___GFP_ATOMIC)  /* Caller cannot wait or reschedule */
-#define __GFP_HIGH	((__force gfp_t)___GFP_HIGH)	/* Should access emergency pools? */
-#define __GFP_IO	((__force gfp_t)___GFP_IO)	/* Can start physical IO? */
-#define __GFP_FS	((__force gfp_t)___GFP_FS)	/* Can call down to low-level FS? */
-#define __GFP_COLD	((__force gfp_t)___GFP_COLD)	/* Cache-cold page required */
-#define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)	/* Suppress page allocation failure warning */
-#define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
-#define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)	/* See above */
-#define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY) /* See above */
-#define __GFP_MEMALLOC	((__force gfp_t)___GFP_MEMALLOC)/* Allow access to emergency reserves */
-#define __GFP_COMP	((__force gfp_t)___GFP_COMP)	/* Add compound page metadata */
-#define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)	/* Return zeroed page on success */
-#define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves.
-							 * This takes precedence over the
-							 * __GFP_MEMALLOC flag if both are
-							 * set
-							 */
-#define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
-#define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
-#define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
-#define __GFP_NOACCOUNT	((__force gfp_t)___GFP_NOACCOUNT) /* Don't account to kmemcg */
-#define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
-
-#define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
-#define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
+#define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE)
+#define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)
+#define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL)
+#define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)
 
 /*
- * A caller that is willing to wait may enter direct reclaim and will
- * wake kswapd to reclaim pages in the background until the high
- * watermark is met. A caller may wish to clear __GFP_DIRECT_RECLAIM to
- * avoid unnecessary delays when a fallback option is available but
- * still allow kswapd to reclaim in the background. The kswapd flag
- * can be cleared when the reclaiming of pages would cause unnecessary
- * disruption.
+ * Watermark modifiers -- controls access to emergency reserves
+ *
+ * __GFP_HIGH indicates that the caller is high-priority and that granting
+ *   the request is necessary before the system can make forward progress.
+ *   For example, creating an IO context to clean pages.
+ *
+ * __GFP_ATOMIC indicates that the caller cannot reclaim or sleep and is
+ *   high priority. Users are typically interrupt handlers. This may be
+ *   used in conjunction with __GFP_HIGH
+ *
+ * __GFP_MEMALLOC allows access to all memory. This should only be used when
+ *   the caller guarantees the allocation will allow more memory to be freed
+ *   very shortly e.g. process exiting or swapping. Users either should
+ *   be the MM or co-ordinating closely with the VM (e.g. swap over NFS).
+ *
+ * __GFP_NOMEMALLOC is used to explicitly forbid access to emergency reserves.
+ *   This takes precedence over the __GFP_MEMALLOC flag if both are set.
+ *
+ * __GFP_NOACCOUNT ignores the accounting for kmemcg limit enforcement.
  */
-#define __GFP_RECLAIM ((__force gfp_t)(___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM))
+#define __GFP_ATOMIC	((__force gfp_t)___GFP_ATOMIC)
+#define __GFP_HIGH	((__force gfp_t)___GFP_HIGH)
+#define __GFP_MEMALLOC	((__force gfp_t)___GFP_MEMALLOC)
+#define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC)
+#define __GFP_NOACCOUNT	((__force gfp_t)___GFP_NOACCOUNT)
+
+/*
+ * Reclaim modifiers
+ *
+ * __GFP_IO can start physical IO.
+ *
+ * __GFP_FS can call down to the low-level FS. Avoids the allocator
+ *   recursing into the filesystem which might already be holding locks.
+ *
+ * __GFP_DIRECT_RECLAIM indicates that the caller may enter direct reclaim.
+ *   This flag can be cleared to avoid unnecessary delays when a fallback
+ *   option is available.
+ *
+ * __GFP_KSWAPD_RECLAIM indicates that the caller wants kswapd when the low
+ *   watermark is reached and have it reclaim pages until the high watermark
+ *   is reached. A caller may wish to clear this flag when fallback options
+ *   are available and the reclaim is likely to disrupt the system. The
+ *   canonical example is THP allocation where a fallback is cheap but
+ *   reclaim/compaction may cause indirect stalls.
+ *
+ * __GFP_RECLAIM is shorthand to allow/forbid both direct and kswapd reclaim.
+ *
+ * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
+ *   _might_ fail.  This depends upon the particular VM implementation.
+ *
+ * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
+ *   cannot handle allocation failures. New users should be evaluated carefully
+ *   (and the flag should be used only when there is no reasonable failure
+ *   policy) but it is definitely preferable to use the flag rather than
+ *   opencode endless loop around allocator.
+ *
+ * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
+ *   return NULL when direct reclaim and memory compaction have failed to allow
+ *   the allocation to succeed.  The OOM killer is not called with the current
+ *   implementation.
+ */
+#define __GFP_IO	((__force gfp_t)___GFP_IO)
+#define __GFP_FS	((__force gfp_t)___GFP_FS)
 #define __GFP_DIRECT_RECLAIM	((__force gfp_t)___GFP_DIRECT_RECLAIM) /* Caller can reclaim */
 #define __GFP_KSWAPD_RECLAIM	((__force gfp_t)___GFP_KSWAPD_RECLAIM) /* kswapd can wake */
+#define __GFP_RECLAIM ((__force gfp_t)(___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM))
+#define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)
+#define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
+#define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
 
 /*
- * This may seem redundant, but it's a way of annotating false positives vs.
- * allocations that simply cannot be supported (e.g. page tables).
+ * Action modifiers
+ * 
+ * __GFP_COLD indicates that the caller does not expect to be used in the near
+ *   future. Where possible, a cache-cold page will be returned.
+ *
+ * __GFP_NOWARN suppresses allocation failure reports.
+ *
+ * __GFP_COMP address compound page metadata.
+ *
+ * __GFP_ZERO returns a zeroed page on success.
+ *
+ * __GFP_NOTRACK avoids tracking with kmemcheck.
+ *
+ * __GFP_NOTRACK_FALSE_POSITIVE is an alias of __GFP_NOTRACK. It's a means of
+ *   distinguishing in the source between false positives and allocations that
+ *   cannot be supported (e.g. page tables).
+ *
+ * __GFP_OTHER_NODE is for allocations that are on a remote node but that
+ *   should not be accounted for as a remote allocation in vmstat. A
+ *   typical user would be khugepaged collapsing a huge page on a remote
+ *   node.
  */
+#define __GFP_COLD	((__force gfp_t)___GFP_COLD)
+#define __GFP_NOWARN	((__force gfp_t)___GFP_NOWARN)
+#define __GFP_COMP	((__force gfp_t)___GFP_COMP)
+#define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)
+#define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
+#define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE)
 
-#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
+/* Room for N __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 26
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /*
- * GFP_ATOMIC callers can not sleep, need the allocation to succeed.
- * A lower watermark is applied to allow access to "atomic reserves"
+ * Useful GFP flag combinations that are commonly used. It is recommended
+ * that subsystems start with one of these combinations and then set/clear
+ * __GFP_FOO flags as necessary.
+ *
+ * GFP_ATOMIC users can not sleep and need the allocation to succeed. A lower
+ *   watermark is applied to allow access to "atomic reserves"
+ *
+ * GFP_KERNEL is typical for kernel-internal allocations. The caller requires
+ *   ZONE_NORMAL or a lower zone for direct access but can direct reclaim.
+ *
+ * GFP_NOWAIT is for kernel allocations that should not stall for direct
+ *   reclaim, start physical IO or use any filesystem callback.
+ *
+ * GFP_NOIO will use direct reclaim to discard clean pages or slab pages
+ *   that do not require the starting of any physical IO.
+ *
+ * GFP_NOFS will use direct reclaim but will not use any filesystem interfaces.
+ *
+ * GFP_USER is for userspace allocations that also need to be directly
+ *   accessibly by the kernel or hardware. It is typically used by hardware
+ *   for buffers that are mapped to userspace (e.g. graphics) that hardware
+ *   still must DMA to. cpuset limits are enforced for these allocations.
+ *
+ * GFP_HIGHUSER is for userspace allocations that may be mapped to userspace,
+ *   do not need to be directly accessible by the kernel but that cannot
+ *   move once in use. An example may be a hardware allocation that maps
+ *   data directly into userspace but has no addressing limitations.
+ *
+ * GFP_DMA exists for historical reasons and should be avoided where possible.
+ *   The flags indicates that the caller requires that the lowest zone be
+ *   used (ZONE_DMA or 16M on x86-64). Ideally, this would be removed but
+ *   it would require careful auditing as some users really require it and
+ *   others use the flag to avoid lowmem reserves in ZONE_DMA and treat the
+ *   lowest zone as a type of emergency reserve.
+ *
+ * GFP_DMA32 is similar to GFP_DMA except that the caller requires a 32-bit
+ *   address.
+ *
+ * GFP_HIGHUSER_MOVABLE is for userspace allocations that the kernel does not
+ *   need direct access to but can use kmap() when access is required. They
+ *   are expected to be movable via page reclaim or page migration. Typically,
+ *   pages on the LRU would also be allocated with GFP_HIGHUSER_MOVABLE.
+ *
+ * GFP_TRANSHUGE is used for THP allocations. They are compound allocations
+ *   that will fail quickly if memory is not available and will not wake
+ *   kswapd on failure.
  */
 #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
+#define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
 #define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
 #define GFP_NOIO	(__GFP_RECLAIM)
 #define GFP_NOFS	(__GFP_RECLAIM | __GFP_IO)
-#define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
 #define GFP_TEMPORARY	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | \
 			 __GFP_RECLAIMABLE)
 #define GFP_USER	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
+#define GFP_DMA		__GFP_DMA
+#define GFP_DMA32	__GFP_DMA32
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
 #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
 			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
 			 ~__GFP_KSWAPD_RECLAIM)
 
-/* This mask makes up all the page movable related flags */
+/* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
 #define GFP_MOVABLE_SHIFT 3
-
-/* Control page allocator reclaim behavior */
-#define GFP_RECLAIM_MASK (__GFP_RECLAIM|__GFP_HIGH|__GFP_IO|__GFP_FS|\
-			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
-			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
-
-/* Control slab gfp mask during early boot */
-#define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_RECLAIM|__GFP_IO|__GFP_FS))
-
-/* Control allocation constraints */
-#define GFP_CONSTRAINT_MASK (__GFP_HARDWALL|__GFP_THISNODE)
-
-/* Do not use these with a slab allocator */
-#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
-
-/* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
-   platforms, used as appropriate on others */
-
-#define GFP_DMA		__GFP_DMA
-
-/* 4GB DMA on some platforms */
-#define GFP_DMA32	__GFP_DMA32
-
-/* Convert GFP flags to their corresponding migrate type */
 static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 {
 	VM_WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
@@ -177,6 +263,8 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 	/* Group based on mobility */
 	return (gfp_flags & GFP_MOVABLE_MASK) >> GFP_MOVABLE_SHIFT;
 }
+#undef GFP_MOVABLE_MASK
+#undef GFP_MOVABLE_SHIFT
 
 static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 {
diff --git a/mm/internal.h b/mm/internal.h
index 83fb0bfffc13..f99f0ff6935d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -14,6 +14,25 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 
+/*
+ * The set of flags that only affect watermark checking and reclaim
+ * behaviour. This is used by the MM to obey the caller constraints
+ * about IO, FS and watermark checking while ignoring placement
+ * hints such as HIGHMEM usage.
+ */
+#define GFP_RECLAIM_MASK (__GFP_RECLAIM|__GFP_HIGH|__GFP_IO|__GFP_FS|\
+			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
+			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
+
+/* The GFP flags allowed during early boot */
+#define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_RECLAIM|__GFP_IO|__GFP_FS))
+
+/* Control allocation cpuset and node placement constraints */
+#define GFP_CONSTRAINT_MASK (__GFP_HARDWALL|__GFP_THISNODE)
+
+/* Do not use these with a slab allocator */
+#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 48ce82926d93..469b639018b0 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -73,6 +73,8 @@ static struct vfsmount *shm_mnt;
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 
+#include "internal.h"
+
 #define BLOCKS_PER_PAGE  (PAGE_CACHE_SIZE/512)
 #define VM_ACCT(size)    (PAGE_CACHE_ALIGN(size) >> PAGE_SHIFT)
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9ad4dcb0631c..af6d519aa21b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -35,6 +35,8 @@
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
+#include "internal.h"
+
 struct vfree_deferred {
 	struct llist_head list;
 	struct work_struct wq;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
