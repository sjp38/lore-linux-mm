Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9B76B0391
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 10:48:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v190so2565524wme.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:48:55 -0800 (PST)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id b83si14596396wmb.29.2017.03.07.07.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 07:48:52 -0800 (PST)
Received: by mail-wr0-f195.google.com with SMTP id l37so735700wrc.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:48:52 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by __GFP_RETRY_MAYFAIL with more useful semantic
Date: Tue,  7 Mar 2017 16:48:41 +0100
Message-Id: <20170307154843.32516-3-mhocko@kernel.org>
In-Reply-To: <20170307154843.32516-1-mhocko@kernel.org>
References: <20170307154843.32516-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT was designed to allow retry-but-eventually-fail semantic to
the page allocator. This has been true but only for allocations requests
larger than PAGE_ALLOC_COSTLY_ORDER. It has been always ignored for
smaller sizes. This is a bit unfortunate because there is no way to
express the same semantic for those requests and they are considered too
important to fail so they might end up looping in the page allocator for
ever, similarly to GFP_NOFAIL requests.

Now that the whole tree has been cleaned up and accidental or misled
usage of __GFP_REPEAT flag has been removed for !costly requests we can
give the original flag a better name and more importantly a more useful
semantic. Let's rename it to __GFP_RETRY_MAYFAIL which tells the user that
the allocator would try really hard but there is no promise of a
success. This will work independent of the order and overrides the
default allocator behavior. Page allocator users have several levels of
guarantee vs. cost options (take GFP_KERNEL as an example)
- GFP_KERNEL & ~__GFP_RECLAIM - optimistic allocation without _any_
  attempt to free memory at all. The most light weight mode which even
  doesn't kick the background reclaim. Should be used carefully because
  it might deplete the memory and the next user might hit the more
  aggressive reclaim
- GFP_KERNEL & ~__GFP_DIRECT_RECLAIM (or GFP_NOWAIT)- optimistic
  allocation without any attempt to free memory from the current context
  but can wake kswapd to reclaim memory if the zone is below the low
  watermark. Can be used from either atomic contexts or when the request
  is a performance optimization and there is another fallback for a slow
  path.
- (GFP_KERNEL|__GFP_HIGH) & ~__GFP_DIRECT_RECLAIM (aka GFP_ATOMIC) - non
  sleeping allocation with an expensive fallback so it can access some
  portion of memory reserves. Usually used from interrupt/bh context with
  an expensive slow path fallback.
- GFP_KERNEL - both background and direct reclaim are allowed and the
  _default_ page allocator behavior is used. That means that !costly
  allocation requests are basically nofail (unless the requesting task
  is killed by the OOM killer) and costly will fail early rather than
  cause disruptive reclaim.
- GFP_KERNEL | __GFP_NORETRY - overrides the default allocator behavior and
  all allocation requests fail early rather than cause disruptive
  reclaim (one round of reclaim in this implementation). The OOM killer
  is not invoked.
- GFP_KERNEL | __GFP_RETRY_MAYFAIL - overrides the default allocator behavior
  and all allocation requests try really hard. The request will fail if the
  reclaim cannot make any progress. The OOM killer won't be triggered.
- GFP_KERNEL | __GFP_NOFAIL - overrides the default allocator behavior
  and all allocation requests will loop endlessly until they
  succeed. This might be really dangerous especially for larger orders.

Existing users of __GFP_REPEAT are changed to __GFP_RETRY_MAYFAIL because
they already had their semantic. No new users are added.
__alloc_pages_slowpath is changed to bail out for __GFP_RETRY_MAYFAIL if
there is no progress and we have already passed the OOM point. This
means that all the reclaim opportunities have been exhausted except the
most disruptive one (the OOM killer) and a user defined fallback
behavior is more sensible than keep retrying in the page allocator.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/DMA-ISA-LPC.txt                |  2 +-
 arch/powerpc/include/asm/book3s/64/pgalloc.h |  2 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c          |  2 +-
 drivers/mmc/host/wbsd.c                      |  2 +-
 drivers/s390/char/vmcp.c                     |  2 +-
 drivers/target/target_core_transport.c       |  2 +-
 drivers/vhost/net.c                          |  2 +-
 drivers/vhost/scsi.c                         |  2 +-
 drivers/vhost/vsock.c                        |  2 +-
 fs/btrfs/check-integrity.c                   |  2 +-
 fs/btrfs/raid56.c                            |  2 +-
 include/linux/gfp.h                          | 32 +++++++++++++++++++---------
 include/linux/slab.h                         |  3 ++-
 include/trace/events/mmflags.h               |  2 +-
 mm/hugetlb.c                                 |  4 ++--
 mm/internal.h                                |  2 +-
 mm/page_alloc.c                              | 14 +++++++++---
 mm/sparse-vmemmap.c                          |  4 ++--
 mm/util.c                                    |  6 +++---
 mm/vmalloc.c                                 |  2 +-
 mm/vmscan.c                                  |  8 +++----
 net/core/dev.c                               |  6 +++---
 net/core/skbuff.c                            |  2 +-
 net/sched/sch_fq.c                           |  2 +-
 tools/perf/builtin-kmem.c                    |  2 +-
 25 files changed, 66 insertions(+), 45 deletions(-)

diff --git a/Documentation/DMA-ISA-LPC.txt b/Documentation/DMA-ISA-LPC.txt
index c41331398752..7a065ac4a9d1 100644
--- a/Documentation/DMA-ISA-LPC.txt
+++ b/Documentation/DMA-ISA-LPC.txt
@@ -42,7 +42,7 @@ requirements you pass the flag GFP_DMA to kmalloc.
 
 Unfortunately the memory available for ISA DMA is scarce so unless you
 allocate the memory during boot-up it's a good idea to also pass
-__GFP_REPEAT and __GFP_NOWARN to make the allocator try a bit harder.
+__GFP_RETRY_MAYFAIL and __GFP_NOWARN to make the allocator try a bit harder.
 
 (This scarcity also means that you should allocate the buffer as
 early as possible and not release it until the driver is unloaded.)
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index cd5e7aa8cc34..1b835aa5b4d1 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -56,7 +56,7 @@ static inline pgd_t *radix__pgd_alloc(struct mm_struct *mm)
 	return (pgd_t *)__get_free_page(PGALLOC_GFP);
 #else
 	struct page *page;
-	page = alloc_pages(PGALLOC_GFP | __GFP_REPEAT, 4);
+	page = alloc_pages(PGALLOC_GFP | __GFP_RETRY_MAYFAIL, 4);
 	if (!page)
 		return NULL;
 	return (pgd_t *) page_address(page);
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 8c68145ba1bd..8ad2c309f14a 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -93,7 +93,7 @@ int kvmppc_allocate_hpt(struct kvm_hpt_info *info, u32 order)
 	}
 
 	if (!hpt)
-		hpt = __get_free_pages(GFP_KERNEL|__GFP_ZERO|__GFP_REPEAT
+		hpt = __get_free_pages(GFP_KERNEL|__GFP_ZERO|__GFP_RETRY_MAYFAIL
 				       |__GFP_NOWARN, order - PAGE_SHIFT);
 
 	if (!hpt)
diff --git a/drivers/mmc/host/wbsd.c b/drivers/mmc/host/wbsd.c
index bd04e8bae010..b58fa5b5b972 100644
--- a/drivers/mmc/host/wbsd.c
+++ b/drivers/mmc/host/wbsd.c
@@ -1386,7 +1386,7 @@ static void wbsd_request_dma(struct wbsd_host *host, int dma)
 	 * order for ISA to be able to DMA to it.
 	 */
 	host->dma_buffer = kmalloc(WBSD_DMA_SIZE,
-		GFP_NOIO | GFP_DMA | __GFP_REPEAT | __GFP_NOWARN);
+		GFP_NOIO | GFP_DMA | __GFP_RETRY_MAYFAIL | __GFP_NOWARN);
 	if (!host->dma_buffer)
 		goto free;
 
diff --git a/drivers/s390/char/vmcp.c b/drivers/s390/char/vmcp.c
index 65f5a794f26d..98749fa817da 100644
--- a/drivers/s390/char/vmcp.c
+++ b/drivers/s390/char/vmcp.c
@@ -98,7 +98,7 @@ vmcp_write(struct file *file, const char __user *buff, size_t count,
 	}
 	if (!session->response)
 		session->response = (char *)__get_free_pages(GFP_KERNEL
-						| __GFP_REPEAT | GFP_DMA,
+						| __GFP_RETRY_MAYFAIL | GFP_DMA,
 						get_order(session->bufsize));
 	if (!session->response) {
 		mutex_unlock(&session->mutex);
diff --git a/drivers/target/target_core_transport.c b/drivers/target/target_core_transport.c
index 434d9d693989..e585d301c665 100644
--- a/drivers/target/target_core_transport.c
+++ b/drivers/target/target_core_transport.c
@@ -251,7 +251,7 @@ int transport_alloc_session_tags(struct se_session *se_sess,
 	int rc;
 
 	se_sess->sess_cmd_map = kzalloc(tag_num * tag_size,
-					GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+					GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MAYFAIL);
 	if (!se_sess->sess_cmd_map) {
 		se_sess->sess_cmd_map = vzalloc(tag_num * tag_size);
 		if (!se_sess->sess_cmd_map) {
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f61f852d6cfd..7d2c4ce6d8d1 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -817,7 +817,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	struct vhost_virtqueue **vqs;
 	int i;
 
-	n = kvmalloc(sizeof *n, GFP_KERNEL | __GFP_REPEAT);
+	n = kvmalloc(sizeof *n, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
 	if (!n)
 		return -ENOMEM;
 	vqs = kmalloc(VHOST_NET_VQ_MAX * sizeof(*vqs), GFP_KERNEL);
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index fd6c8b66f06f..ff02a942c4d5 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1404,7 +1404,7 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
 	struct vhost_virtqueue **vqs;
 	int r = -ENOMEM, i;
 
-	vs = kzalloc(sizeof(*vs), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	vs = kzalloc(sizeof(*vs), GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MAYFAIL);
 	if (!vs) {
 		vs = vzalloc(sizeof(*vs));
 		if (!vs)
diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index d403c647ba56..5b76242d73e3 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -460,7 +460,7 @@ static int vhost_vsock_dev_open(struct inode *inode, struct file *file)
 	/* This struct is large and allocation could fail, fall back to vmalloc
 	 * if there is no other way.
 	 */
-	vsock = kvmalloc(sizeof(*vsock), GFP_KERNEL | __GFP_REPEAT);
+	vsock = kvmalloc(sizeof(*vsock), GFP_KERNEL | __GFP_RETRY_MAYFAIL);
 	if (!vsock)
 		return -ENOMEM;
 
diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index ab14c2e635ca..e334ed2b7e64 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -2923,7 +2923,7 @@ int btrfsic_mount(struct btrfs_fs_info *fs_info,
 		       fs_info->sectorsize, PAGE_SIZE);
 		return -1;
 	}
-	state = kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	state = kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MAYFAIL);
 	if (!state) {
 		state = vzalloc(sizeof(*state));
 		if (!state) {
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index 1571bf26dc07..94af3db1d0e4 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -218,7 +218,7 @@ int btrfs_alloc_stripe_hash_table(struct btrfs_fs_info *info)
 	 * of a failing mount.
 	 */
 	table_size = sizeof(*table) + sizeof(*h) * num_entries;
-	table = kzalloc(table_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	table = kzalloc(table_size, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MAYFAIL);
 	if (!table) {
 		table = vzalloc(table_size);
 		if (!table)
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 2bfcfd33e476..60af7937c6f2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -25,7 +25,7 @@ struct vm_area_struct;
 #define ___GFP_FS		0x80u
 #define ___GFP_COLD		0x100u
 #define ___GFP_NOWARN		0x200u
-#define ___GFP_REPEAT		0x400u
+#define ___GFP_RETRY_MAYFAIL		0x400u
 #define ___GFP_NOFAIL		0x800u
 #define ___GFP_NORETRY		0x1000u
 #define ___GFP_MEMALLOC		0x2000u
@@ -136,26 +136,38 @@ struct vm_area_struct;
  *
  * __GFP_RECLAIM is shorthand to allow/forbid both direct and kswapd reclaim.
  *
- * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
- *   _might_ fail.  This depends upon the particular VM implementation.
+ * The default allocator behavior depends on the request size. We have a concept
+ * of so called costly allocations (with order > PAGE_ALLOC_COSTLY_ORDER).
+ * !costly allocations are too essential to fail so they are implicitly
+ * non-failing (with some exceptions like OOM victims might fail) by default while
+ * costly requests try to be not disruptive and back off even without invoking
+ * the OOM killer. The following three modifiers might be used to override some of
+ * these implicit rules
+ *
+ * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
+ *   return NULL when direct reclaim and memory compaction have failed to allow
+ *   the allocation to succeed.  The OOM killer is not called with the current
+ *   implementation. This is a default mode for costly allocations.
+ *
+ * __GFP_RETRY_MAYFAIL: Try hard to allocate the memory, but the allocation attempt
+ *   _might_ fail. All viable forms of memory reclaim are tried before the fail.
+ *   The OOM killer is excluded because this would be too disruptive. This can be
+ *   used to override non-failing default behavior for !costly requests as well as
+ *   fortify costly requests.
  *
  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
  *   cannot handle allocation failures. New users should be evaluated carefully
  *   (and the flag should be used only when there is no reasonable failure
  *   policy) but it is definitely preferable to use the flag rather than
- *   opencode endless loop around allocator.
- *
- * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
- *   return NULL when direct reclaim and memory compaction have failed to allow
- *   the allocation to succeed.  The OOM killer is not called with the current
- *   implementation.
+ *   opencode endless loop around allocator. Using this flag for costly allocations
+ *   is _highly_ discouraged.
  */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)
 #define __GFP_FS	((__force gfp_t)___GFP_FS)
 #define __GFP_DIRECT_RECLAIM	((__force gfp_t)___GFP_DIRECT_RECLAIM) /* Caller can reclaim */
 #define __GFP_KSWAPD_RECLAIM	((__force gfp_t)___GFP_KSWAPD_RECLAIM) /* kswapd can wake */
 #define __GFP_RECLAIM ((__force gfp_t)(___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM))
-#define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)
+#define __GFP_RETRY_MAYFAIL	((__force gfp_t)___GFP_RETRY_MAYFAIL)
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
 #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3c37a8c51921..064901ac3e37 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -469,7 +469,8 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
  *
  * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
  *
- * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
+ * %__GFP_RETRY_MAYFAIL - Try really hard to succeed the allocation but fail
+ *   eventually.
  *
  * There are other flags available as well, but these are not intended
  * for general use, and so are not documented here. For a full list of
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 304ff94363b2..418142a4efce 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -34,7 +34,7 @@
 	{(unsigned long)__GFP_FS,		"__GFP_FS"},		\
 	{(unsigned long)__GFP_COLD,		"__GFP_COLD"},		\
 	{(unsigned long)__GFP_NOWARN,		"__GFP_NOWARN"},	\
-	{(unsigned long)__GFP_REPEAT,		"__GFP_REPEAT"},	\
+	{(unsigned long)__GFP_RETRY_MAYFAIL,	"__GFP_RETRY_MAYFAIL"},	\
 	{(unsigned long)__GFP_NOFAIL,		"__GFP_NOFAIL"},	\
 	{(unsigned long)__GFP_NORETRY,		"__GFP_NORETRY"},	\
 	{(unsigned long)__GFP_COMP,		"__GFP_COMP"},		\
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a7aa811b7d14..dc598bfe4ce9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1369,7 +1369,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 
 	page = __alloc_pages_node(nid,
 		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
-						__GFP_REPEAT|__GFP_NOWARN,
+						__GFP_RETRY_MAYFAIL|__GFP_NOWARN,
 		huge_page_order(h));
 	if (page) {
 		prep_new_huge_page(h, page, nid);
@@ -1510,7 +1510,7 @@ static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
 		struct vm_area_struct *vma, unsigned long addr, int nid)
 {
 	int order = huge_page_order(h);
-	gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
+	gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;
 	unsigned int cpuset_mems_cookie;
 
 	/*
diff --git a/mm/internal.h b/mm/internal.h
index 823a7a89099b..8e6d347f70fb 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -23,7 +23,7 @@
  * hints such as HIGHMEM usage.
  */
 #define GFP_RECLAIM_MASK (__GFP_RECLAIM|__GFP_HIGH|__GFP_IO|__GFP_FS|\
-			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
+			__GFP_NOWARN|__GFP_RETRY_MAYFAIL|__GFP_NOFAIL|\
 			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
 			__GFP_ATOMIC)
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5238b87aec91..bfe4a9bad0f8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3181,6 +3181,14 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	/* The OOM killer will not help higher order allocs */
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		goto out;
+	/*
+	 * We have already exhausted all our reclaim opportunities without any
+	 * success so it is time to admit defeat. We will skip the OOM killer
+	 * because it is very likely that the caller has a more reasonable
+	 * fallback than shooting a random task.
+	 */
+	if (gfp_mask & __GFP_RETRY_MAYFAIL)
+		goto out;
 	/* The OOM killer does not needlessly kill tasks for lowmem */
 	if (ac->high_zoneidx < ZONE_NORMAL)
 		goto out;
@@ -3309,7 +3317,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	}
 
 	/*
-	 * !costly requests are much more important than __GFP_REPEAT
+	 * !costly requests are much more important than __GFP_RETRY_MAYFAIL
 	 * costly ones because they are de facto nofail and invoke OOM
 	 * killer to move on while costly can fail and users are ready
 	 * to cope with that. 1/4 retries is rather arbitrary but we
@@ -3776,9 +3784,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/*
 	 * Do not retry costly high order allocations unless they are
-	 * __GFP_REPEAT
+	 * __GFP_RETRY_MAYFAIL
 	 */
-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MAYFAIL))
 		goto nopage;
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 574c67b663fe..b21ba0dfe102 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -56,11 +56,11 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 
 		if (node_state(node, N_HIGH_MEMORY))
 			page = alloc_pages_node(
-				node, GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
+				node, GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
 				get_order(size));
 		else
 			page = alloc_pages(
-				GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
+				GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
 				get_order(size));
 		if (page)
 			return page_address(page);
diff --git a/mm/util.c b/mm/util.c
index 6ed3e49bf1e5..885a78d1941b 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -339,7 +339,7 @@ EXPORT_SYMBOL(vm_mmap);
  * Uses kmalloc to get the memory but if the allocation fails then falls back
  * to the vmalloc allocator. Use kvfree for freeing the memory.
  *
- * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_REPEAT
+ * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_RETRY_MAYFAIL
  * is supported only for large (>32kB) allocations, and it should be used only if
  * kmalloc is preferable to the vmalloc fallback, due to visible performance drawbacks.
  *
@@ -364,11 +364,11 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 		kmalloc_flags |= __GFP_NOWARN;
 
 		/*
-		 * We have to override __GFP_REPEAT by __GFP_NORETRY for !costly
+		 * We have to override __GFP_RETRY_MAYFAIL by __GFP_NORETRY for !costly
 		 * requests because there is no other way to tell the allocator
 		 * that we want to fail rather than retry endlessly.
 		 */
-		if (!(kmalloc_flags & __GFP_REPEAT) ||
+		if (!(kmalloc_flags & __GFP_RETRY_MAYFAIL) ||
 				(size <= PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
 			kmalloc_flags |= __GFP_NORETRY;
 	}
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 32979d945766..c2fa2e1b79fc 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1747,7 +1747,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
  *	allocator with @gfp_mask flags.  Map them into contiguous
  *	kernel virtual space, using a pagetable protection of @prot.
  *
- *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_REPEAT
+ *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_RETRY_MAYFAIL
  *	and __GFP_NOFAIL are not supported
  *
  *	Any use of gfp flags outside of GFP_KERNEL should be consulted
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4e0a828781e5..8f547176e02c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2435,18 +2435,18 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 		return false;
 
 	/* Consider stopping depending on scan and reclaim activity */
-	if (sc->gfp_mask & __GFP_REPEAT) {
+	if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
 		/*
-		 * For __GFP_REPEAT allocations, stop reclaiming if the
+		 * For __GFP_RETRY_MAYFAIL allocations, stop reclaiming if the
 		 * full LRU list has been scanned and we are still failing
 		 * to reclaim pages. This full LRU scan is potentially
-		 * expensive but a __GFP_REPEAT caller really wants to succeed
+		 * expensive but a __GFP_RETRY_MAYFAIL caller really wants to succeed
 		 */
 		if (!nr_reclaimed && !nr_scanned)
 			return false;
 	} else {
 		/*
-		 * For non-__GFP_REPEAT allocations which can presumably
+		 * For non-__GFP_RETRY_MAYFAIL allocations which can presumably
 		 * fail without consequence, stop if we failed to reclaim
 		 * any pages from the last SWAP_CLUSTER_MAX number of
 		 * pages that were scanned. This will return to the
diff --git a/net/core/dev.c b/net/core/dev.c
index d947308ee255..3e659ac9e0ed 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7121,7 +7121,7 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 
 	BUG_ON(count < 1);
 
-	rx = kvzalloc(sz, GFP_KERNEL | __GFP_REPEAT);
+	rx = kvzalloc(sz, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
 	if (!rx)
 		return -ENOMEM;
 
@@ -7161,7 +7161,7 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	if (count < 1 || count > 0xffff)
 		return -EINVAL;
 
-	tx = kvzalloc(sz, GFP_KERNEL | __GFP_REPEAT);
+	tx = kvzalloc(sz, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
 	if (!tx)
 		return -ENOMEM;
 
@@ -7698,7 +7698,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	/* ensure 32-byte alignment of whole construct */
 	alloc_size += NETDEV_ALIGN - 1;
 
-	p = kvzalloc(alloc_size, GFP_KERNEL | __GFP_REPEAT);
+	p = kvzalloc(alloc_size, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
 	if (!p)
 		return NULL;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9ccba86fa23d..26af038e27f0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4653,7 +4653,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
 
 	gfp_head = gfp_mask;
 	if (gfp_head & __GFP_DIRECT_RECLAIM)
-		gfp_head |= __GFP_REPEAT;
+		gfp_head |= __GFP_RETRY_MAYFAIL;
 
 	*errcode = -ENOBUFS;
 	skb = alloc_skb(header_len, gfp_head);
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 594f77d89f6c..daebe062a2dd 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -640,7 +640,7 @@ static int fq_resize(struct Qdisc *sch, u32 log)
 		return 0;
 
 	/* If XPS was setup, we can allocate memory on right NUMA node */
-	array = kvmalloc_node(sizeof(struct rb_root) << log, GFP_KERNEL | __GFP_REPEAT,
+	array = kvmalloc_node(sizeof(struct rb_root) << log, GFP_KERNEL | __GFP_RETRY_MAYFAIL,
 			      netdev_queue_numa_node_read(sch->dev_queue));
 	if (!array)
 		return -ENOMEM;
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 6da8d083e4e5..01ca903fcdb9 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -638,7 +638,7 @@ static const struct {
 	{ "__GFP_FS",			"F" },
 	{ "__GFP_COLD",			"CO" },
 	{ "__GFP_NOWARN",		"NWR" },
-	{ "__GFP_REPEAT",		"R" },
+	{ "__GFP_RETRY_MAYFAIL",	"R" },
 	{ "__GFP_NOFAIL",		"NF" },
 	{ "__GFP_NORETRY",		"NR" },
 	{ "__GFP_COMP",			"C" },
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
