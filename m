Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71B906B0253
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 07:32:32 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k192so4686871lfb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 04:32:32 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id y8si26205765wjy.88.2016.06.06.04.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 04:32:30 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id k184so9320233wme.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 04:32:29 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/2] mm, tree wide: replace __GFP_REPEAT by __GFP_RETRY_HARD with more useful semantic
Date: Mon,  6 Jun 2016 13:32:15 +0200
Message-Id: <1465212736-14637-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
semantic. Let's rename it to __GFP_RETRY_HARD which tells the user that
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
  reclaim (one round of reclaim in this implementation). No OOM killer
  is invoked.
- GFP_KERNEL | __GFP_RETRY_HARD - overrides the default allocator behavior
  and all allocation requests try really hard, !costly are allowed to
  invoke OOM killer. The request will fail if no progress is expected.
- GFP_KERNEL | __GFP_NOFAIL - overrides the default allocator behavior
  and all allocation requests will loop endlessly until they
  succeed. This might be really dangerous especially for larger orders.

Existing users of __GFP_REPEAT are changed to __GFP_RETRY_HARD because
they already had their semantic. No new users are added.
__alloc_pages_slowpath is changed to bail out for __GFP_RETRY_HARD if
there is no progress and we have already passed the OOM point. This
means that all the reclaim opportunities have been exhausted and
retrying doesn't make much sense most probably.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/DMA-ISA-LPC.txt                |  2 +-
 arch/powerpc/include/asm/book3s/64/pgalloc.h |  2 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c          |  2 +-
 drivers/block/xen-blkfront.c                 |  2 +-
 drivers/mmc/host/wbsd.c                      |  2 +-
 drivers/s390/char/vmcp.c                     |  2 +-
 drivers/target/target_core_transport.c       |  2 +-
 drivers/vhost/net.c                          |  2 +-
 drivers/vhost/scsi.c                         |  2 +-
 drivers/vhost/vhost.c                        |  2 +-
 fs/btrfs/check-integrity.c                   |  2 +-
 fs/btrfs/raid56.c                            |  2 +-
 include/linux/gfp.h                          | 32 +++++++++++++++++++---------
 include/linux/slab.h                         |  3 ++-
 include/trace/events/mmflags.h               |  2 +-
 mm/huge_memory.c                             |  2 +-
 mm/hugetlb.c                                 |  4 ++--
 mm/internal.h                                |  2 +-
 mm/page_alloc.c                              | 19 ++++++++++++++---
 mm/sparse-vmemmap.c                          |  4 ++--
 mm/vmscan.c                                  |  8 +++----
 net/core/dev.c                               |  6 +++---
 net/core/skbuff.c                            |  2 +-
 net/sched/sch_fq.c                           |  2 +-
 tools/perf/builtin-kmem.c                    |  2 +-
 25 files changed, 69 insertions(+), 43 deletions(-)

diff --git a/Documentation/DMA-ISA-LPC.txt b/Documentation/DMA-ISA-LPC.txt
index b1a19835e907..5b594dfb1783 100644
--- a/Documentation/DMA-ISA-LPC.txt
+++ b/Documentation/DMA-ISA-LPC.txt
@@ -42,7 +42,7 @@ requirements you pass the flag GFP_DMA to kmalloc.
 
 Unfortunately the memory available for ISA DMA is scarce so unless you
 allocate the memory during boot-up it's a good idea to also pass
-__GFP_REPEAT and __GFP_NOWARN to make the allocater try a bit harder.
+__GFP_RETRY_HARD and __GFP_NOWARN to make the allocater try a bit harder.
 
 (This scarcity also means that you should allocate the buffer as
 early as possible and not release it until the driver is unloaded.)
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index d14fcf82c00c..be3b996915a9 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -56,7 +56,7 @@ static inline pgd_t *radix__pgd_alloc(struct mm_struct *mm)
 	return (pgd_t *)__get_free_page(PGALLOC_GFP);
 #else
 	struct page *page;
-	page = alloc_pages(PGALLOC_GFP | __GFP_REPEAT, 4);
+	page = alloc_pages(PGALLOC_GFP | __GFP_RETRY_HARD, 4);
 	if (!page)
 		return NULL;
 	return (pgd_t *) page_address(page);
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 05f09ae82587..204484fbda51 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -72,7 +72,7 @@ long kvmppc_alloc_hpt(struct kvm *kvm, u32 *htab_orderp)
 	/* Lastly try successively smaller sizes from the page allocator */
 	/* Only do this if userspace didn't specify a size via ioctl */
 	while (!hpt && order > PPC_MIN_HPT_ORDER && !htab_orderp) {
-		hpt = __get_free_pages(GFP_KERNEL|__GFP_ZERO|__GFP_REPEAT|
+		hpt = __get_free_pages(GFP_KERNEL|__GFP_ZERO|__GFP_RETRY_HARD|
 				       __GFP_NOWARN, order - PAGE_SHIFT);
 		if (!hpt)
 			--order;
diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index ca13df854639..2633e1c32a45 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -2029,7 +2029,7 @@ static int blkif_recover(struct blkfront_info *info)
 		rinfo = &info->rinfo[r_index];
 		/* Stage 1: Make a safe copy of the shadow state. */
 		copy = kmemdup(rinfo->shadow, sizeof(rinfo->shadow),
-			       GFP_NOIO | __GFP_REPEAT | __GFP_HIGH);
+			       GFP_NOIO | __GFP_RETRY_HARD | __GFP_HIGH);
 		if (!copy)
 			return -ENOMEM;
 
diff --git a/drivers/mmc/host/wbsd.c b/drivers/mmc/host/wbsd.c
index c3fd16d997ca..cb71a383c4ec 100644
--- a/drivers/mmc/host/wbsd.c
+++ b/drivers/mmc/host/wbsd.c
@@ -1386,7 +1386,7 @@ static void wbsd_request_dma(struct wbsd_host *host, int dma)
 	 * order for ISA to be able to DMA to it.
 	 */
 	host->dma_buffer = kmalloc(WBSD_DMA_SIZE,
-		GFP_NOIO | GFP_DMA | __GFP_REPEAT | __GFP_NOWARN);
+		GFP_NOIO | GFP_DMA | __GFP_RETRY_HARD | __GFP_NOWARN);
 	if (!host->dma_buffer)
 		goto free;
 
diff --git a/drivers/s390/char/vmcp.c b/drivers/s390/char/vmcp.c
index 2a67b496a9e2..d5ecf3007ac6 100644
--- a/drivers/s390/char/vmcp.c
+++ b/drivers/s390/char/vmcp.c
@@ -98,7 +98,7 @@ vmcp_write(struct file *file, const char __user *buff, size_t count,
 	}
 	if (!session->response)
 		session->response = (char *)__get_free_pages(GFP_KERNEL
-						| __GFP_REPEAT | GFP_DMA,
+						| __GFP_RETRY_HARD | GFP_DMA,
 						get_order(session->bufsize));
 	if (!session->response) {
 		mutex_unlock(&session->mutex);
diff --git a/drivers/target/target_core_transport.c b/drivers/target/target_core_transport.c
index 5ab3967dda43..6102177b2c7b 100644
--- a/drivers/target/target_core_transport.c
+++ b/drivers/target/target_core_transport.c
@@ -251,7 +251,7 @@ int transport_alloc_session_tags(struct se_session *se_sess,
 	int rc;
 
 	se_sess->sess_cmd_map = kzalloc(tag_num * tag_size,
-					GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+					GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 	if (!se_sess->sess_cmd_map) {
 		se_sess->sess_cmd_map = vzalloc(tag_num * tag_size);
 		if (!se_sess->sess_cmd_map) {
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f744eeb3e2b4..820a4715eb38 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -747,7 +747,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	struct vhost_virtqueue **vqs;
 	int i;
 
-	n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 	if (!n) {
 		n = vmalloc(sizeof *n);
 		if (!n)
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 9d6320e8ff3e..7150b45e092f 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1405,7 +1405,7 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
 	struct vhost_virtqueue **vqs;
 	int r = -ENOMEM, i;
 
-	vs = kzalloc(sizeof(*vs), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	vs = kzalloc(sizeof(*vs), GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 	if (!vs) {
 		vs = vzalloc(sizeof(*vs));
 		if (!vs)
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 669fef1e2bb6..a4b0f18a69ab 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -707,7 +707,7 @@ static int vhost_memory_reg_sort_cmp(const void *p1, const void *p2)
 
 static void *vhost_kvzalloc(unsigned long size)
 {
-	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 
 	if (!n)
 		n = vzalloc(size);
diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index b677a6ea6001..f8658fbbfa60 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -3049,7 +3049,7 @@ int btrfsic_mount(struct btrfs_root *root,
 		       root->sectorsize, PAGE_SIZE);
 		return -1;
 	}
-	state = kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	state = kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 	if (!state) {
 		state = vzalloc(sizeof(*state));
 		if (!state) {
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index f8b6d411a034..db2bba5cb90a 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -218,7 +218,7 @@ int btrfs_alloc_stripe_hash_table(struct btrfs_fs_info *info)
 	 * of a failing mount.
 	 */
 	table_size = sizeof(*table) + sizeof(*h) * num_entries;
-	table = kzalloc(table_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	table = kzalloc(table_size, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 	if (!table) {
 		table = vzalloc(table_size);
 		if (!table)
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index c29e9d347bc6..9961086eac2e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -25,7 +25,7 @@ struct vm_area_struct;
 #define ___GFP_FS		0x80u
 #define ___GFP_COLD		0x100u
 #define ___GFP_NOWARN		0x200u
-#define ___GFP_REPEAT		0x400u
+#define ___GFP_RETRY_HARD		0x400u
 #define ___GFP_NOFAIL		0x800u
 #define ___GFP_NORETRY		0x1000u
 #define ___GFP_MEMALLOC		0x2000u
@@ -132,26 +132,38 @@ struct vm_area_struct;
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
+ * __GFP_RETRY_HARD: Try hard to allocate the memory, but the allocation attempt
+ *   _might_ fail. All viable forms of memory reclaim are tried before the fail
+ *   including the OOM killer for !costly allocations. This can be used to override
+ *   non-failing default behavior for !costly requests as well as fortify costly
+ *   requests.
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
+#define __GFP_RETRY_HARD	((__force gfp_t)___GFP_RETRY_HARD)
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
 #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index aeb3e6d00a66..cacd437fdbf4 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -457,7 +457,8 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
  *
  * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
  *
- * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
+ * %__GFP_RETRY_HARD - Try really hard to succeed the allocation but fail
+ *   eventually.
  *
  * There are other flags available as well, but these are not intended
  * for general use, and so are not documented here. For a full list of
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 43cedbf0c759..c5f488767860 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -30,7 +30,7 @@
 	{(unsigned long)__GFP_FS,		"__GFP_FS"},		\
 	{(unsigned long)__GFP_COLD,		"__GFP_COLD"},		\
 	{(unsigned long)__GFP_NOWARN,		"__GFP_NOWARN"},	\
-	{(unsigned long)__GFP_REPEAT,		"__GFP_REPEAT"},	\
+	{(unsigned long)__GFP_RETRY_HARD,	"__GFP_RETRY_HARD"},	\
 	{(unsigned long)__GFP_NOFAIL,		"__GFP_NOFAIL"},	\
 	{(unsigned long)__GFP_NORETRY,		"__GFP_NORETRY"},	\
 	{(unsigned long)__GFP_COMP,		"__GFP_COMP"},		\
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index acd374e200cf..69872951f653 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -378,7 +378,7 @@ static ssize_t single_flag_store(struct kobject *kobj,
 
 /*
  * Currently defrag only disables __GFP_NOWAIT for allocation. A blind
- * __GFP_REPEAT is too aggressive, it's never worth swapping tons of
+ * __GFP_RETRY_HARD is too aggressive, it's never worth swapping tons of
  * memory just to allocate one more hugepage.
  */
 static ssize_t defrag_show(struct kobject *kobj,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e197cd7080e6..62306b5a302a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1363,7 +1363,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 
 	page = __alloc_pages_node(nid,
 		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
-						__GFP_REPEAT|__GFP_NOWARN,
+						__GFP_RETRY_HARD|__GFP_NOWARN,
 		huge_page_order(h));
 	if (page) {
 		prep_new_huge_page(h, page, nid);
@@ -1480,7 +1480,7 @@ static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
 		struct vm_area_struct *vma, unsigned long addr, int nid)
 {
 	int order = huge_page_order(h);
-	gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
+	gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_RETRY_HARD|__GFP_NOWARN;
 	unsigned int cpuset_mems_cookie;
 
 	/*
diff --git a/mm/internal.h b/mm/internal.h
index 420bbe300bcd..083c87c539b6 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -23,7 +23,7 @@
  * hints such as HIGHMEM usage.
  */
 #define GFP_RECLAIM_MASK (__GFP_RECLAIM|__GFP_HIGH|__GFP_IO|__GFP_FS|\
-			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
+			__GFP_NOWARN|__GFP_RETRY_HARD|__GFP_NOFAIL|\
 			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
 
 /* The GFP flags allowed during early boot */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 180f5afc5a1f..faa3d4a27850 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3262,7 +3262,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 		return compaction_zonelist_suitable(ac, order, alloc_flags);
 
 	/*
-	 * !costly requests are much more important than __GFP_REPEAT
+	 * !costly requests are much more important than __GFP_RETRY_HARD
 	 * costly ones because they are de facto nofail and invoke OOM
 	 * killer to move on while costly can fail and users are ready
 	 * to cope with that. 1/4 retries is rather arbitrary but we
@@ -3550,6 +3550,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
+	bool passed_oom = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3680,9 +3681,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/*
 	 * Do not retry costly high order allocations unless they are
-	 * __GFP_REPEAT
+	 * __GFP_RETRY_HARD
 	 */
-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_HARD))
 		goto noretry;
 
 	/*
@@ -3711,6 +3712,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				compaction_retries))
 		goto retry;
 
+	/*
+	 * We have already exhausted all our reclaim opportunities including
+	 * the OOM killer without any success so it is time to admit defeat.
+	 * We do not care about the order because we want all orders to behave
+	 * consistently including !costly ones. costly are handled in
+	 * __alloc_pages_may_oom and will bail out even before the first OOM
+	 * killer invocation
+	 */
+	if (passed_oom && (gfp_mask & __GFP_RETRY_HARD))
+		goto nopage;
+
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
 	if (page)
@@ -3719,6 +3731,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
+		passed_oom = true;
 		goto retry;
 	}
 
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 68885dcbaf40..261facd8e1c8 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -56,11 +56,11 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 
 		if (node_state(node, N_HIGH_MEMORY))
 			page = alloc_pages_node(
-				node, GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
+				node, GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_HARD,
 				get_order(size));
 		else
 			page = alloc_pages(
-				GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
+				GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_HARD,
 				get_order(size));
 		if (page)
 			return page_address(page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 93ba33789ac6..ff21efe06430 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2319,18 +2319,18 @@ static inline bool should_continue_reclaim(struct zone *zone,
 		return false;
 
 	/* Consider stopping depending on scan and reclaim activity */
-	if (sc->gfp_mask & __GFP_REPEAT) {
+	if (sc->gfp_mask & __GFP_RETRY_HARD) {
 		/*
-		 * For __GFP_REPEAT allocations, stop reclaiming if the
+		 * For __GFP_RETRY_HARD allocations, stop reclaiming if the
 		 * full LRU list has been scanned and we are still failing
 		 * to reclaim pages. This full LRU scan is potentially
-		 * expensive but a __GFP_REPEAT caller really wants to succeed
+		 * expensive but a __GFP_RETRY_HARD caller really wants to succeed
 		 */
 		if (!nr_reclaimed && !nr_scanned)
 			return false;
 	} else {
 		/*
-		 * For non-__GFP_REPEAT allocations which can presumably
+		 * For non-__GFP_RETRY_HARD allocations which can presumably
 		 * fail without consequence, stop if we failed to reclaim
 		 * any pages from the last SWAP_CLUSTER_MAX number of
 		 * pages that were scanned. This will return to the
diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff431d570..8a916dd1d833 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6897,7 +6897,7 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 
 	BUG_ON(count < 1);
 
-	rx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	rx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 	if (!rx) {
 		rx = vzalloc(sz);
 		if (!rx)
@@ -6939,7 +6939,7 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	if (count < 1 || count > 0xffff)
 		return -EINVAL;
 
-	tx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	tx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 	if (!tx) {
 		tx = vzalloc(sz);
 		if (!tx)
@@ -7477,7 +7477,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	/* ensure 32-byte alignment of whole construct */
 	alloc_size += NETDEV_ALIGN - 1;
 
-	p = kzalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	p = kzalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
 	if (!p)
 		p = vzalloc(alloc_size);
 	if (!p)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e7ec6d3ad5f0..c4c667a7b39b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4621,7 +4621,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
 
 	gfp_head = gfp_mask;
 	if (gfp_head & __GFP_DIRECT_RECLAIM)
-		gfp_head |= __GFP_REPEAT;
+		gfp_head |= __GFP_RETRY_HARD;
 
 	*errcode = -ENOBUFS;
 	skb = alloc_skb(header_len, gfp_head);
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 3c6a47d66a04..7ed2224df628 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -599,7 +599,7 @@ static void *fq_alloc_node(size_t sz, int node)
 {
 	void *ptr;
 
-	ptr = kmalloc_node(sz, GFP_KERNEL | __GFP_REPEAT | __GFP_NOWARN, node);
+	ptr = kmalloc_node(sz, GFP_KERNEL | __GFP_RETRY_HARD | __GFP_NOWARN, node);
 	if (!ptr)
 		ptr = vmalloc_node(sz, node);
 	return ptr;
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 58adfee230de..a63f8f4e6a6a 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -627,7 +627,7 @@ static const struct {
 	{ "__GFP_FS",			"F" },
 	{ "__GFP_COLD",			"CO" },
 	{ "__GFP_NOWARN",		"NWR" },
-	{ "__GFP_REPEAT",		"R" },
+	{ "__GFP_RETRY_HARD",		"R" },
 	{ "__GFP_NOFAIL",		"NF" },
 	{ "__GFP_NORETRY",		"NR" },
 	{ "__GFP_COMP",			"C" },
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
