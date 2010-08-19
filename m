Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9536B01FF
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:30:27 -0400 (EDT)
Message-Id: <20100819202753.845273979@chello.nl>
Date: Thu, 19 Aug 2010 22:13:22 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 5/6] mm: Fix up KM_type argument removal fallout
References: <20100819201317.673172547@chello.nl>
Content-Disposition: inline; filename=kmap-5.patch
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Manual fixups of the previous patch

(i386 all{mod,yes}config driven}

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/include/asm/pgtable.h       |    8 +++---
 arch/arm/lib/uaccess_with_memcpy.c   |    1 
 arch/arm/mm/highmem.c                |    8 ++----
 arch/frv/mm/highmem.c                |    7 +++--
 arch/mips/mm/highmem.c               |   22 ++++++++++--------
 arch/mn10300/include/asm/highmem.h   |    4 ++-
 arch/powerpc/include/asm/highmem.h   |    2 -
 arch/powerpc/mm/highmem.c            |    3 +-
 arch/sparc/mm/highmem.c              |    3 +-
 arch/x86/include/asm/pgtable_32.h    |   12 +++-------
 arch/x86/kernel/cpu/perf_event.c     |    5 +---
 arch/x86/mm/highmem_32.c             |    7 +++--
 arch/x86/mm/iomap_32.c               |    5 ++--
 drivers/block/drbd/drbd_bitmap.c     |   24 ++++++++++----------
 drivers/gpu/drm/i915/i915_gem.c      |    3 --
 drivers/gpu/drm/i915/intel_overlay.c |    3 --
 drivers/net/e1000/e1000_main.c       |    6 +----
 drivers/net/e1000e/netdev.c          |    6 +----
 drivers/scsi/cxgb3i/cxgb3i_pdu.c     |    3 --
 drivers/scsi/fcoe/fcoe.c             |    3 --
 drivers/scsi/libfc/fc_libfc.c        |    8 ++----
 drivers/scsi/libfc/fc_libfc.h        |    3 --
 drivers/staging/hv/netvsc_drv.c      |    3 --
 drivers/staging/hv/storvsc_drv.c     |   11 ++++-----
 fs/aio.c                             |    8 +++---
 fs/btrfs/ctree.c                     |   42 +++++++++++------------------------
 fs/btrfs/extent_io.c                 |   14 +++++------
 fs/btrfs/extent_io.h                 |    6 ++---
 include/crypto/scatterwalk.h         |   16 +------------
 include/linux/highmem.h              |   12 +++++-----
 include/linux/io-mapping.h           |   11 ++++-----
 lib/swiotlb.c                        |    3 --
 net/rds/ib_recv.c                    |    3 --
 net/rds/iw_recv.c                    |    3 --
 net/rds/rds.h                        |    2 -
 net/rds/recv.c                       |    2 -
 net/rds/tcp_recv.c                   |    6 +----
 net/sunrpc/xprtrdma/rpc_rdma.c       |    6 +----
 38 files changed, 126 insertions(+), 168 deletions(-)

Index: linux-2.6/arch/arm/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/highmem.c
+++ linux-2.6/arch/arm/mm/highmem.c
@@ -38,7 +38,7 @@ EXPORT_SYMBOL(kunmap);
 
 void *kmap_atomic(struct page *page)
 {
-	unsigned int idx;
+	unsigned int idx, type;
 	unsigned long vaddr;
 	void *kmap;
 
@@ -46,8 +46,6 @@ void *kmap_atomic(struct page *page)
 	if (!PageHighMem(page))
 		return page_address(page);
 
-	debug_kmap_atomic(type);
-
 #ifdef CONFIG_DEBUG_HIGHMEM
 	/*
 	 * There is no cache coherency issue when non VIVT, so force the
@@ -87,7 +85,7 @@ EXPORT_SYMBOL(kmap_atomic);
 void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	unsigned int idx;
+	unsigned int idx, type;
 
 	if (kvaddr >= (void *)FIXADDR_START) {
 		type = kmap_atomic_idx_pop();
@@ -112,7 +110,7 @@ EXPORT_SYMBOL(kunmap_atomic_notypecheck)
 
 void *kmap_atomic_pfn(unsigned long pfn)
 {
-	unsigned int idx;
+	unsigned int idx, type;
 	unsigned long vaddr;
 
 	pagefault_disable();
Index: linux-2.6/arch/mips/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/highmem.c
+++ linux-2.6/arch/mips/mm/highmem.c
@@ -45,6 +45,7 @@ void *__kmap_atomic(struct page *page)
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int type;
 
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	pagefault_disable();
@@ -67,7 +68,7 @@ EXPORT_SYMBOL(__kmap_atomic);
 void __kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	unsigned int idx;
+	unsigned int type;
 
 	if (vaddr < FIXADDR_START) { // FIXME
 		pagefault_enable();
@@ -76,16 +77,18 @@ void __kunmap_atomic_notypecheck(void *k
 
 	type = kmap_atomic_idx_pop();
 #ifdef CONFIG_DEBUG_HIGHMEM
-	idx = type + KM_TYPE_NR * smp_processor_id();
+	{
+		unsigned int idx = type + KM_TYPE_NR * smp_processor_id();
 
-	BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx));
+		BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx));
 
-	/*
-	 * force other mappings to Oops if they'll try to access
-	 * this pte without first remap it
-	 */
-	pte_clear(&init_mm, vaddr, kmap_pte-idx);
-	local_flush_tlb_one(vaddr);
+		/*
+		 * force other mappings to Oops if they'll try to access
+		 * this pte without first remap it
+		 */
+		pte_clear(&init_mm, vaddr, kmap_pte-idx);
+		local_flush_tlb_one(vaddr);
+	}
 #endif
 	pagefault_enable();
 }
@@ -99,6 +102,7 @@ void *kmap_atomic_pfn(unsigned long pfn)
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int type;
 
 	pagefault_disable();
 
Index: linux-2.6/arch/x86/include/asm/pgtable_32.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/pgtable_32.h
+++ linux-2.6/arch/x86/include/asm/pgtable_32.h
@@ -49,17 +49,13 @@ extern void set_pmd_pfn(unsigned long, u
 #endif
 
 #if defined(CONFIG_HIGHPTE)
-#define __KM_PTE			\
-	(in_nmi() ? KM_NMI_PTE : 	\
-	 in_irq() ? KM_IRQ_PTE :	\
-	 KM_PTE0)
-#define pte_offset_map(dir, address)					\
-	((pte_t *)kmap_atomic(pmd_page(*(dir)), __KM_PTE) +		\
+#define pte_offset_map(dir, address)				\
+	((pte_t *)kmap_atomic(pmd_page(*(dir))) +		\
 	 pte_index((address)))
-#define pte_offset_map_nested(dir, address)				\
+#define pte_offset_map_nested(dir, address)			\
 	((pte_t *)kmap_atomic(pmd_page(*(dir))) +		\
 	 pte_index((address)))
-#define pte_unmap(pte) kunmap_atomic((pte), __KM_PTE)
+#define pte_unmap(pte) kunmap_atomic((pte))
 #define pte_unmap_nested(pte) kunmap_atomic((pte))
 #else
 #define pte_offset_map(dir, address)					\
Index: linux-2.6/arch/x86/mm/iomap_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/iomap_32.c
+++ linux-2.6/arch/x86/mm/iomap_32.c
@@ -59,6 +59,7 @@ void *kmap_atomic_prot_pfn(unsigned long
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int type;
 
 	pagefault_disable();
 
@@ -86,7 +87,7 @@ iomap_atomic_prot_pfn(unsigned long pfn,
 	if (!pat_enabled && pgprot_val(prot) == pgprot_val(PAGE_KERNEL_WC))
 		prot = PAGE_KERNEL_UC_MINUS;
 
-	return kmap_atomic_prot_pfn(pfn, type, prot);
+	return kmap_atomic_prot_pfn(pfn, prot);
 }
 EXPORT_SYMBOL_GPL(iomap_atomic_prot_pfn);
 
@@ -94,10 +95,10 @@ void
 iounmap_atomic(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx;
 
 	if (vaddr >= __fix_to_virt(FIX_KMAP_END) &&
 	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
+		unsigned int idx, type;
 
 		type = kmap_atomic_idx_pop();
 		idx = type + KM_TYPE_NR * smp_processor_id();
Index: linux-2.6/arch/mn10300/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/mn10300/include/asm/highmem.h
+++ linux-2.6/arch/mn10300/include/asm/highmem.h
@@ -72,8 +72,8 @@ static inline void kunmap(struct page *p
  */
 static inline unsigned long kmap_atomic(struct page *page)
 {
-	enum fixed_addresses idx;
 	unsigned long vaddr;
+	unsigned int idx, type;
 
 	pagefault_disable();
 	if (page < highmem_start_page)
@@ -94,6 +94,8 @@ static inline unsigned long kmap_atomic(
 
 static inline void kunmap_atomic_notypecheck(unsigned long vaddr)
 {
+	unsigned int type;
+
 	if (vaddr < FIXADDR_START) { /* FIXME */
 		pagefault_enable();
 		return;
Index: linux-2.6/drivers/staging/hv/netvsc_drv.c
===================================================================
--- linux-2.6.orig/drivers/staging/hv/netvsc_drv.c
+++ linux-2.6/drivers/staging/hv/netvsc_drv.c
@@ -274,8 +274,7 @@ static int netvsc_recv_callback(struct h
 	 * hv_netvsc_packet cannot be deallocated
 	 */
 	for (i = 0; i < packet->PageBufferCount; i++) {
-		data = kmap_atomic(pfn_to_page(packet->PageBuffers[i].Pfn),
-					       KM_IRQ1);
+		data = kmap_atomic(pfn_to_page(packet->PageBuffers[i].Pfn));
 		data = (void *)(unsigned long)data +
 				packet->PageBuffers[i].Offset;
 
Index: linux-2.6/drivers/staging/hv/storvsc_drv.c
===================================================================
--- linux-2.6.orig/drivers/staging/hv/storvsc_drv.c
+++ linux-2.6/drivers/staging/hv/storvsc_drv.c
@@ -488,8 +488,8 @@ static unsigned int copy_to_bounce_buffe
 	local_irq_save(flags);
 
 	for (i = 0; i < orig_sgl_count; i++) {
-		src_addr = (unsigned long)kmap_atomic(sg_page((&orig_sgl[i])),
-				KM_IRQ0) + orig_sgl[i].offset;
+		src_addr = (unsigned long)kmap_atomic(sg_page((&orig_sgl[i])))
+			+ orig_sgl[i].offset;
 		src = src_addr;
 		srclen = orig_sgl[i].length;
 
@@ -550,8 +550,8 @@ static unsigned int copy_from_bounce_buf
 	local_irq_save(flags);
 
 	for (i = 0; i < orig_sgl_count; i++) {
-		dest_addr = (unsigned long)kmap_atomic(sg_page((&orig_sgl[i])),
-					KM_IRQ0) + orig_sgl[i].offset;
+		dest_addr = (unsigned long)kmap_atomic(sg_page((&orig_sgl[i])))
+			+ orig_sgl[i].offset;
 		dest = dest_addr;
 		destlen = orig_sgl[i].length;
 		/* ASSERT(orig_sgl[i].offset + orig_sgl[i].length <= PAGE_SIZE); */
@@ -585,8 +585,7 @@ static unsigned int copy_from_bounce_buf
 			}
 		}
 
-		kunmap_atomic((void *)(dest_addr - orig_sgl[i].offset),
-			      KM_IRQ0);
+		kunmap_atomic((void *)(dest_addr - orig_sgl[i].offset));
 	}
 
 	local_irq_restore(flags);
Index: linux-2.6/net/sunrpc/xprtrdma/rpc_rdma.c
===================================================================
--- linux-2.6.orig/net/sunrpc/xprtrdma/rpc_rdma.c
+++ linux-2.6/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -336,8 +336,7 @@ rpcrdma_inline_pullup(struct rpc_rqst *r
 			curlen = copy_len;
 		dprintk("RPC:       %s: page %d destp 0x%p len %d curlen %d\n",
 			__func__, i, destp, copy_len, curlen);
-		srcp = kmap_atomic(rqst->rq_snd_buf.pages[i],
-					KM_SKB_SUNRPC_DATA);
+		srcp = kmap_atomic(rqst->rq_snd_buf.pages[i]);
 		if (i == 0)
 			memcpy(destp, srcp+rqst->rq_snd_buf.page_base, curlen);
 		else
@@ -637,8 +636,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rq
 			dprintk("RPC:       %s: page %d"
 				" srcp 0x%p len %d curlen %d\n",
 				__func__, i, srcp, copy_len, curlen);
-			destp = kmap_atomic(rqst->rq_rcv_buf.pages[i],
-						KM_SKB_SUNRPC_DATA);
+			destp = kmap_atomic(rqst->rq_rcv_buf.pages[i]);
 			if (i == 0)
 				memcpy(destp + rqst->rq_rcv_buf.page_base,
 						srcp, curlen);
Index: linux-2.6/arch/x86/kernel/cpu/perf_event.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/cpu/perf_event.c
+++ linux-2.6/arch/x86/kernel/cpu/perf_event.c
@@ -49,7 +49,6 @@ static unsigned long
 copy_from_user_nmi(void *to, const void __user *from, unsigned long n)
 {
 	unsigned long offset, addr = (unsigned long)from;
-	int type = in_nmi() ? KM_NMI : KM_IRQ0;
 	unsigned long size, len = 0;
 	struct page *page;
 	void *map;
@@ -63,9 +62,9 @@ copy_from_user_nmi(void *to, const void 
 		offset = addr & (PAGE_SIZE - 1);
 		size = min(PAGE_SIZE - offset, n - len);
 
-		map = kmap_atomic(page, type);
+		map = kmap_atomic(page);
 		memcpy(to, map+offset, size);
-		kunmap_atomic(map, type);
+		kunmap_atomic(map);
 		put_page(page);
 
 		len  += size;
Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -3725,11 +3725,9 @@ static bool e1000_clean_jumbo_rx_irq(str
 				if (length <= copybreak &&
 				    skb_tailroom(skb) >= length) {
 					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page,
-					                    KM_SKB_DATA_SOFTIRQ);
+					vaddr = kmap_atomic(buffer_info->page);
 					memcpy(skb_tail_pointer(skb), vaddr, length);
-					kunmap_atomic(vaddr,
-					              KM_SKB_DATA_SOFTIRQ);
+					kunmap_atomic(vaddr);
 					/* re-use the page, so don't erase
 					 * buffer_info->page */
 					skb_put(skb, length);
Index: linux-2.6/include/crypto/scatterwalk.h
===================================================================
--- linux-2.6.orig/include/crypto/scatterwalk.h
+++ linux-2.6/include/crypto/scatterwalk.h
@@ -25,26 +25,14 @@
 #include <linux/scatterlist.h>
 #include <linux/sched.h>
 
-static inline enum km_type crypto_kmap_type(int out)
-{
-	enum km_type type;
-
-	if (in_softirq())
-		type = out * (KM_SOFTIRQ1 - KM_SOFTIRQ0) + KM_SOFTIRQ0;
-	else
-		type = out * (KM_USER1 - KM_USER0) + KM_USER0;
-
-	return type;
-}
-
 static inline void *crypto_kmap(struct page *page, int out)
 {
-	return kmap_atomic(page, crypto_kmap_type(out));
+	return kmap_atomic(page);
 }
 
 static inline void crypto_kunmap(void *vaddr, int out)
 {
-	kunmap_atomic(vaddr, crypto_kmap_type(out));
+	kunmap_atomic(vaddr);
 }
 
 static inline void crypto_yield(u32 flags)
Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -74,19 +74,19 @@ static inline void kunmap(struct page *p
 {
 }
 
-static inline void *kmap_atomic(struct page *page, enum km_type idx)
+static inline void *kmap_atomic(struct page *page)
 {
 	pagefault_disable();
 	return page_address(page);
 }
-#define kmap_atomic_prot(page, idx, prot)	kmap_atomic(page, idx)
+#define kmap_atomic_prot(page, prot)	kmap_atomic(page)
 
-static inline void kunmap_atomic_notypecheck(void *addr, enum km_type idx)
+static inline void kunmap_atomic_notypecheck(void *addr)
 {
 	pagefault_enable();
 }
 
-#define kmap_atomic_pfn(pfn, idx)	kmap_atomic(pfn_to_page(pfn), (idx))
+#define kmap_atomic_pfn(pfn)		kmap_atomic(pfn_to_page(pfn))
 #define kmap_atomic_to_page(ptr)	virt_to_page(ptr)
 
 #define kmap_flush_unused()	do {} while(0)
@@ -96,9 +96,9 @@ static inline void kunmap_atomic_notypec
 
 /* Prevent people trying to call kunmap_atomic() as if it were kunmap() */
 /* kunmap_atomic() should get the return value of kmap_atomic, not the page. */
-#define kunmap_atomic(addr, idx) do { \
+#define kunmap_atomic(addr) do { \
 		BUILD_BUG_ON(__same_type((addr), struct page *)); \
-		kunmap_atomic_notypecheck((addr), (idx)); \
+		kunmap_atomic_notypecheck(addr); \
 	} while (0)
 
 /* when CONFIG_HIGHMEM is not set these will be plain clear/copy_page */
Index: linux-2.6/arch/frv/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/highmem.c
+++ linux-2.6/arch/frv/mm/highmem.c
@@ -40,6 +40,7 @@ struct page *kmap_atomic_to_page(void *p
 void *kmap_atomic(struct page *page)
 {
 	unsigned long paddr;
+	int type;
 
 	pagefault_disable();
 	type = kmap_atomic_idx_push();
@@ -65,9 +66,9 @@ void *kmap_atomic(struct page *page)
 }
 EXPORT_SYMBOL(kmap_atomic);
 
-void kunmap_atomic(void *kvaddr)
+void kunmap_atomic_notypecheck(void *kvaddr)
 {
-	type = kmap_atomic_idx_pop();
+	int type = kmap_atomic_idx_pop();
 	switch (type) {
         case 0:		__kunmap_atomic_primary(4, 6);	break;
         case 1:		__kunmap_atomic_primary(5, 7);	break;
@@ -84,5 +85,5 @@ void kunmap_atomic(void *kvaddr)
 	}
 	pagefault_enable();
 }
-EXPORT_SYMBOL(kunmap_atomic);
+EXPORT_SYMBOL(kunmap_atomic_notypecheck);
 
Index: linux-2.6/fs/btrfs/extent_io.c
===================================================================
--- linux-2.6.orig/fs/btrfs/extent_io.c
+++ linux-2.6/fs/btrfs/extent_io.c
@@ -3504,7 +3504,7 @@ void read_extent_buffer(struct extent_bu
 int map_private_extent_buffer(struct extent_buffer *eb, unsigned long start,
 			       unsigned long min_len, char **token, char **map,
 			       unsigned long *map_start,
-			       unsigned long *map_len, int km)
+			       unsigned long *map_len)
 {
 	size_t offset = start & (PAGE_CACHE_SIZE - 1);
 	char *kaddr;
@@ -3533,7 +3533,7 @@ int map_private_extent_buffer(struct ext
 	}
 
 	p = extent_buffer_page(eb, i);
-	kaddr = kmap_atomic(p, km);
+	kaddr = kmap_atomic(p);
 	*token = kaddr;
 	*map = kaddr + offset;
 	*map_len = PAGE_CACHE_SIZE - offset;
@@ -3544,17 +3544,17 @@ int map_extent_buffer(struct extent_buff
 		      unsigned long min_len,
 		      char **token, char **map,
 		      unsigned long *map_start,
-		      unsigned long *map_len, int km)
+		      unsigned long *map_len)
 {
 	int err;
 	int save = 0;
 	if (eb->map_token) {
-		unmap_extent_buffer(eb, eb->map_token, km);
+		unmap_extent_buffer(eb, eb->map_token);
 		eb->map_token = NULL;
 		save = 1;
 	}
 	err = map_private_extent_buffer(eb, start, min_len, token, map,
-				       map_start, map_len, km);
+				       map_start, map_len);
 	if (!err && save) {
 		eb->map_token = *token;
 		eb->kaddr = *map;
@@ -3564,9 +3564,9 @@ int map_extent_buffer(struct extent_buff
 	return err;
 }
 
-void unmap_extent_buffer(struct extent_buffer *eb, char *token, int km)
+void unmap_extent_buffer(struct extent_buffer *eb, char *token)
 {
-	kunmap_atomic(token, km);
+	kunmap_atomic(token);
 }
 
 int memcmp_extent_buffer(struct extent_buffer *eb, const void *ptrv,
Index: linux-2.6/fs/btrfs/extent_io.h
===================================================================
--- linux-2.6.orig/fs/btrfs/extent_io.h
+++ linux-2.6/fs/btrfs/extent_io.h
@@ -297,12 +297,12 @@ int extent_buffer_uptodate(struct extent
 int map_extent_buffer(struct extent_buffer *eb, unsigned long offset,
 		      unsigned long min_len, char **token, char **map,
 		      unsigned long *map_start,
-		      unsigned long *map_len, int km);
+		      unsigned long *map_len);
 int map_private_extent_buffer(struct extent_buffer *eb, unsigned long offset,
 		      unsigned long min_len, char **token, char **map,
 		      unsigned long *map_start,
-		      unsigned long *map_len, int km);
-void unmap_extent_buffer(struct extent_buffer *eb, char *token, int km);
+		      unsigned long *map_len);
+void unmap_extent_buffer(struct extent_buffer *eb, char *token);
 int release_extent_buffer_tail_pages(struct extent_buffer *eb);
 int extent_range_uptodate(struct extent_io_tree *tree,
 			  u64 start, u64 end);
Index: linux-2.6/fs/btrfs/ctree.c
===================================================================
--- linux-2.6.orig/fs/btrfs/ctree.c
+++ linux-2.6/fs/btrfs/ctree.c
@@ -642,8 +642,7 @@ int btrfs_realloc_node(struct btrfs_tran
 					btrfs_node_key_ptr_offset(i),
 					sizeof(struct btrfs_key_ptr),
 					&parent->map_token, &parent->kaddr,
-					&parent->map_start, &parent->map_len,
-					KM_USER1);
+					&parent->map_start, &parent->map_len);
 		}
 		btrfs_node_key(parent, &disk_key, i);
 		if (!progress_passed && comp_keys(&disk_key, progress) < 0)
@@ -668,8 +667,7 @@ int btrfs_realloc_node(struct btrfs_tran
 			continue;
 		}
 		if (parent->map_token) {
-			unmap_extent_buffer(parent, parent->map_token,
-					    KM_USER1);
+			unmap_extent_buffer(parent, parent->map_token);
 			parent->map_token = NULL;
 		}
 
@@ -711,8 +709,7 @@ int btrfs_realloc_node(struct btrfs_tran
 		free_extent_buffer(cur);
 	}
 	if (parent->map_token) {
-		unmap_extent_buffer(parent, parent->map_token,
-				    KM_USER1);
+		unmap_extent_buffer(parent, parent->map_token);
 		parent->map_token = NULL;
 	}
 	return err;
@@ -2359,8 +2356,7 @@ static noinline int __push_leaf_right(st
 			map_extent_buffer(left, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&left->map_token, &left->kaddr,
-					&left->map_start, &left->map_len,
-					KM_USER1);
+					&left->map_start, &left->map_len);
 		}
 
 		this_item_size = btrfs_item_size(left, item);
@@ -2422,8 +2418,7 @@ static noinline int __push_leaf_right(st
 			map_extent_buffer(right, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&right->map_token, &right->kaddr,
-					&right->map_start, &right->map_len,
-					KM_USER1);
+					&right->map_start, &right->map_len);
 		}
 		push_space -= btrfs_item_size(right, item);
 		btrfs_set_item_offset(right, item, push_space);
@@ -2573,8 +2568,7 @@ static noinline int __push_leaf_left(str
 			map_extent_buffer(right, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&right->map_token, &right->kaddr,
-					&right->map_start, &right->map_len,
-					KM_USER1);
+					&right->map_start, &right->map_len);
 		}
 
 		if (!empty && push_items > 0) {
@@ -2636,8 +2630,7 @@ static noinline int __push_leaf_left(str
 			map_extent_buffer(left, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&left->map_token, &left->kaddr,
-					&left->map_start, &left->map_len,
-					KM_USER1);
+					&left->map_start, &left->map_len);
 		}
 
 		ioff = btrfs_item_offset(left, item);
@@ -2680,8 +2673,7 @@ static noinline int __push_leaf_left(str
 			map_extent_buffer(right, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&right->map_token, &right->kaddr,
-					&right->map_start, &right->map_len,
-					KM_USER1);
+					&right->map_start, &right->map_len);
 		}
 
 		push_space = push_space - btrfs_item_size(right, item);
@@ -2832,8 +2824,7 @@ static noinline int copy_for_split(struc
 			map_extent_buffer(right, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&right->map_token, &right->kaddr,
-					&right->map_start, &right->map_len,
-					KM_USER1);
+					&right->map_start, &right->map_len);
 		}
 
 		ioff = btrfs_item_offset(right, item);
@@ -3370,8 +3361,7 @@ int btrfs_truncate_item(struct btrfs_tra
 			map_extent_buffer(leaf, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&leaf->map_token, &leaf->kaddr,
-					&leaf->map_start, &leaf->map_len,
-					KM_USER1);
+					&leaf->map_start, &leaf->map_len);
 		}
 
 		ioff = btrfs_item_offset(leaf, item);
@@ -3487,8 +3477,7 @@ int btrfs_extend_item(struct btrfs_trans
 			map_extent_buffer(leaf, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&leaf->map_token, &leaf->kaddr,
-					&leaf->map_start, &leaf->map_len,
-					KM_USER1);
+					&leaf->map_start, &leaf->map_len);
 		}
 		ioff = btrfs_item_offset(leaf, item);
 		btrfs_set_item_offset(leaf, item, ioff - data_size);
@@ -3610,8 +3599,7 @@ int btrfs_insert_some_items(struct btrfs
 				map_extent_buffer(leaf, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&leaf->map_token, &leaf->kaddr,
-					&leaf->map_start, &leaf->map_len,
-					KM_USER1);
+					&leaf->map_start, &leaf->map_len);
 			}
 
 			ioff = btrfs_item_offset(leaf, item);
@@ -3725,8 +3713,7 @@ setup_items_for_insert(struct btrfs_tran
 				map_extent_buffer(leaf, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&leaf->map_token, &leaf->kaddr,
-					&leaf->map_start, &leaf->map_len,
-					KM_USER1);
+					&leaf->map_start, &leaf->map_len);
 			}
 
 			ioff = btrfs_item_offset(leaf, item);
@@ -3954,8 +3941,7 @@ int btrfs_del_items(struct btrfs_trans_h
 				map_extent_buffer(leaf, (unsigned long)item,
 					sizeof(struct btrfs_item),
 					&leaf->map_token, &leaf->kaddr,
-					&leaf->map_start, &leaf->map_len,
-					KM_USER1);
+					&leaf->map_start, &leaf->map_len);
 			}
 			ioff = btrfs_item_offset(leaf, item);
 			btrfs_set_item_offset(leaf, item, ioff + dsize);
Index: linux-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/netdev.c
+++ linux-2.6/drivers/net/e1000e/netdev.c
@@ -1360,12 +1360,10 @@ static bool e1000_clean_jumbo_rx_irq(str
 				if (length <= copybreak &&
 				    skb_tailroom(skb) >= length) {
 					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page,
-					                   KM_SKB_DATA_SOFTIRQ);
+					vaddr = kmap_atomic(buffer_info->page);
 					memcpy(skb_tail_pointer(skb), vaddr,
 					       length);
-					kunmap_atomic(vaddr,
-					              KM_SKB_DATA_SOFTIRQ);
+					kunmap_atomic(vaddr);
 					/* re-use the page, so don't erase
 					 * buffer_info->page */
 					skb_put(skb, length);
Index: linux-2.6/drivers/scsi/cxgb3i/cxgb3i_pdu.c
===================================================================
--- linux-2.6.orig/drivers/scsi/cxgb3i/cxgb3i_pdu.c
+++ linux-2.6/drivers/scsi/cxgb3i/cxgb3i_pdu.c
@@ -320,8 +320,7 @@ int cxgb3i_conn_init_pdu(struct iscsi_ta
 
 			/* data fits in the skb's headroom */
 			for (i = 0; i < tdata->nr_frags; i++, frag++) {
-				char *src = kmap_atomic(frag->page,
-							KM_SOFTIRQ0);
+				char *src = kmap_atomic(frag->page);
 
 				memcpy(dst, src+frag->page_offset, frag->size);
 				dst += frag->size;
Index: linux-2.6/fs/aio.c
===================================================================
--- linux-2.6.orig/fs/aio.c
+++ linux-2.6/fs/aio.c
@@ -192,19 +192,19 @@ static int aio_setup_ring(struct kioctx 
 #define AIO_EVENTS_FIRST_PAGE	((PAGE_SIZE - sizeof(struct aio_ring)) / sizeof(struct io_event))
 #define AIO_EVENTS_OFFSET	(AIO_EVENTS_PER_PAGE - AIO_EVENTS_FIRST_PAGE)
 
-#define aio_ring_event(info, nr, km) ({					\
+#define aio_ring_event(info, nr) ({					\
 	unsigned pos = (nr) + AIO_EVENTS_OFFSET;			\
 	struct io_event *__event;					\
 	__event = kmap_atomic(						\
-			(info)->ring_pages[pos / AIO_EVENTS_PER_PAGE], km); \
+			(info)->ring_pages[pos / AIO_EVENTS_PER_PAGE]); \
 	__event += pos % AIO_EVENTS_PER_PAGE;				\
 	__event;							\
 })
 
-#define put_aio_ring_event(event, km) do {	\
+#define put_aio_ring_event(event) do {	\
 	struct io_event *__event = (event);	\
 	(void)__event;				\
-	kunmap_atomic((void *)((unsigned long)__event & PAGE_MASK), km); \
+	kunmap_atomic((void *)((unsigned long)__event & PAGE_MASK)); \
 } while(0)
 
 static void ctx_rcu_free(struct rcu_head *head)
Index: linux-2.6/lib/swiotlb.c
===================================================================
--- linux-2.6.orig/lib/swiotlb.c
+++ linux-2.6/lib/swiotlb.c
@@ -343,8 +343,7 @@ void swiotlb_bounce(phys_addr_t phys, ch
 			sz = min_t(size_t, PAGE_SIZE - offset, size);
 
 			local_irq_save(flags);
-			buffer = kmap_atomic(pfn_to_page(pfn),
-					     KM_BOUNCE_READ);
+			buffer = kmap_atomic(pfn_to_page(pfn));
 			if (dir == DMA_TO_DEVICE)
 				memcpy(dma_addr, buffer + offset, sz);
 			else
Index: linux-2.6/net/rds/rds.h
===================================================================
--- linux-2.6.orig/net/rds/rds.h
+++ linux-2.6/net/rds/rds.h
@@ -617,7 +617,7 @@ void rds_inc_init(struct rds_incoming *i
 void rds_inc_addref(struct rds_incoming *inc);
 void rds_inc_put(struct rds_incoming *inc);
 void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
-		       struct rds_incoming *inc, gfp_t gfp, enum km_type km);
+		       struct rds_incoming *inc, gfp_t gfp);
 int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		size_t size, int msg_flags);
 void rds_clear_recv_queue(struct rds_sock *rs);
Index: linux-2.6/net/rds/recv.c
===================================================================
--- linux-2.6.orig/net/rds/recv.c
+++ linux-2.6/net/rds/recv.c
@@ -156,7 +156,7 @@ static void rds_recv_incoming_exthdrs(st
  * tell us which roles the addrs in the conn are playing for this message.
  */
 void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
-		       struct rds_incoming *inc, gfp_t gfp, enum km_type km)
+		       struct rds_incoming *inc, gfp_t gfp)
 {
 	struct rds_sock *rs = NULL;
 	struct sock *sk;
Index: linux-2.6/drivers/scsi/fcoe/fcoe.c
===================================================================
--- linux-2.6.orig/drivers/scsi/fcoe/fcoe.c
+++ linux-2.6/drivers/scsi/fcoe/fcoe.c
@@ -1456,8 +1456,7 @@ u32 fcoe_fc_crc(struct fc_frame *fp)
 		len = frag->size;
 		while (len > 0) {
 			clen = min(len, PAGE_SIZE - (off & ~PAGE_MASK));
-			data = kmap_atomic(frag->page + (off >> PAGE_SHIFT),
-					   KM_SKB_DATA_SOFTIRQ);
+			data = kmap_atomic(frag->page + (off >> PAGE_SHIFT));
 			crc = crc32(crc, data + (off & ~PAGE_MASK), clen);
 			kunmap_atomic(data);
 			off += clen;
Index: linux-2.6/drivers/scsi/libfc/fc_libfc.c
===================================================================
--- linux-2.6.orig/drivers/scsi/libfc/fc_libfc.c
+++ linux-2.6/drivers/scsi/libfc/fc_libfc.c
@@ -89,8 +89,7 @@ module_exit(libfc_exit);
  */
 u32 fc_copy_buffer_to_sglist(void *buf, size_t len,
 			     struct scatterlist *sg,
-			     u32 *nents, size_t *offset,
-			     enum km_type km_type, u32 *crc)
+			     u32 *nents, size_t *offset, u32 *crc)
 {
 	size_t remaining = len;
 	u32 copy_len = 0;
@@ -120,12 +119,11 @@ u32 fc_copy_buffer_to_sglist(void *buf, 
 		off = *offset + sg->offset;
 		sg_bytes = min(sg_bytes,
 			       (size_t)(PAGE_SIZE - (off & ~PAGE_MASK)));
-		page_addr = kmap_atomic(sg_page(sg) + (off >> PAGE_SHIFT),
-					km_type);
+		page_addr = kmap_atomic(sg_page(sg) + (off >> PAGE_SHIFT));
 		if (crc)
 			*crc = crc32(*crc, buf, sg_bytes);
 		memcpy((char *)page_addr + (off & ~PAGE_MASK), buf, sg_bytes);
-		kunmap_atomic(page_addr, km_type);
+		kunmap_atomic(page_addr);
 		buf += sg_bytes;
 		*offset += sg_bytes;
 		remaining -= sg_bytes;
Index: linux-2.6/drivers/scsi/libfc/fc_libfc.h
===================================================================
--- linux-2.6.orig/drivers/scsi/libfc/fc_libfc.h
+++ linux-2.6/drivers/scsi/libfc/fc_libfc.h
@@ -106,7 +106,6 @@ const char *fc_els_resp_type(struct fc_f
  */
 u32 fc_copy_buffer_to_sglist(void *buf, size_t len,
 			     struct scatterlist *sg,
-			     u32 *nents, size_t *offset,
-			     enum km_type km_type, u32 *crc);
+			     u32 *nents, size_t *offset, u32 *crc);
 
 #endif /* _FC_LIBFC_H_ */
Index: linux-2.6/net/rds/ib_recv.c
===================================================================
--- linux-2.6.orig/net/rds/ib_recv.c
+++ linux-2.6/net/rds/ib_recv.c
@@ -795,8 +795,7 @@ static void rds_ib_process_recv(struct r
 			rds_ib_cong_recv(conn, ibinc);
 		else {
 			rds_recv_incoming(conn, conn->c_faddr, conn->c_laddr,
-					  &ibinc->ii_inc, GFP_ATOMIC,
-					  KM_SOFTIRQ0);
+					  &ibinc->ii_inc, GFP_ATOMIC);
 			state->ack_next = be64_to_cpu(hdr->h_sequence);
 			state->ack_next_valid = 1;
 		}
Index: linux-2.6/net/rds/iw_recv.c
===================================================================
--- linux-2.6.orig/net/rds/iw_recv.c
+++ linux-2.6/net/rds/iw_recv.c
@@ -754,8 +754,7 @@ static void rds_iw_process_recv(struct r
 			rds_iw_cong_recv(conn, iwinc);
 		else {
 			rds_recv_incoming(conn, conn->c_faddr, conn->c_laddr,
-					  &iwinc->ii_inc, GFP_ATOMIC,
-					  KM_SOFTIRQ0);
+					  &iwinc->ii_inc, GFP_ATOMIC);
 			state->ack_next = be64_to_cpu(hdr->h_sequence);
 			state->ack_next_valid = 1;
 		}
Index: linux-2.6/net/rds/tcp_recv.c
===================================================================
--- linux-2.6.orig/net/rds/tcp_recv.c
+++ linux-2.6/net/rds/tcp_recv.c
@@ -169,7 +169,6 @@ static void rds_tcp_cong_recv(struct rds
 struct rds_tcp_desc_arg {
 	struct rds_connection *conn;
 	gfp_t gfp;
-	enum km_type km;
 };
 
 static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
@@ -255,7 +254,7 @@ static int rds_tcp_data_recv(read_descri
 			else
 				rds_recv_incoming(conn, conn->c_faddr,
 						  conn->c_laddr, &tinc->ti_inc,
-						  arg->gfp, arg->km);
+						  arg->gfp);
 
 			tc->t_tinc_hdr_rem = sizeof(struct rds_header);
 			tc->t_tinc_data_rem = 0;
@@ -272,7 +271,7 @@ out:
 }
 
 /* the caller has to hold the sock lock */
-int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp, enum km_type km)
+int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp)
 {
 	struct rds_tcp_connection *tc = conn->c_transport_data;
 	struct socket *sock = tc->t_sock;
@@ -282,7 +281,6 @@ int rds_tcp_read_sock(struct rds_connect
 	/* It's like glib in the kernel! */
 	arg.conn = conn;
 	arg.gfp = gfp;
-	arg.km = km;
 	desc.arg.data = &arg;
 	desc.error = 0;
 	desc.count = 1; /* give more than one skb per call */
Index: linux-2.6/arch/x86/mm/highmem_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/highmem_32.c
+++ linux-2.6/arch/x86/mm/highmem_32.c
@@ -31,6 +31,7 @@ void *kmap_atomic_prot(struct page *page
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int type;
 
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	pagefault_disable();
@@ -49,16 +50,16 @@ void *kmap_atomic_prot(struct page *page
 
 void *kmap_atomic(struct page *page)
 {
-	return kmap_atomic_prot(page, type, kmap_prot);
+	return kmap_atomic_prot(page, kmap_prot);
 }
 
 void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx;
 
 	if (vaddr >= __fix_to_virt(FIX_KMAP_END) &&
 	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
+		unsigned int idx, type;
 
 		type = kmap_atomic_idx_pop();
 		idx = type + KM_TYPE_NR * smp_processor_id();
@@ -91,7 +92,7 @@ void kunmap_atomic_notypecheck(void *kva
  */
 void *kmap_atomic_pfn(unsigned long pfn)
 {
-	return kmap_atomic_prot_pfn(pfn, type, kmap_prot);
+	return kmap_atomic_prot_pfn(pfn, kmap_prot);
 }
 EXPORT_SYMBOL_GPL(kmap_atomic_pfn); /* temporarily in use by i915 GEM until vmap */
 
Index: linux-2.6/drivers/block/drbd/drbd_bitmap.c
===================================================================
--- linux-2.6.orig/drivers/block/drbd/drbd_bitmap.c
+++ linux-2.6/drivers/block/drbd/drbd_bitmap.c
@@ -85,7 +85,7 @@ struct drbd_bitmap {
 #define BM_P_VMALLOCED  2
 
 static int __bm_change_bits_to(struct drbd_conf *mdev, const unsigned long s,
-			       unsigned long e, int val, const enum km_type km);
+			       unsigned long e, int val);
 
 static int bm_is_locked(struct drbd_bitmap *b)
 {
@@ -155,7 +155,7 @@ void drbd_bm_unlock(struct drbd_conf *md
 }
 
 /* word offset to long pointer */
-static unsigned long *__bm_map_paddr(struct drbd_bitmap *b, unsigned long offset, const enum km_type km)
+static unsigned long *__bm_map_paddr(struct drbd_bitmap *b, unsigned long offset)
 {
 	struct page *page;
 	unsigned long page_nr;
@@ -165,7 +165,7 @@ static unsigned long *__bm_map_paddr(str
 	BUG_ON(page_nr >= b->bm_number_of_pages);
 	page = b->bm_pages[page_nr];
 
-	return (unsigned long *) kmap_atomic(page, km);
+	return (unsigned long *) kmap_atomic(page);
 }
 
 static unsigned long * bm_map_paddr(struct drbd_bitmap *b, unsigned long offset)
@@ -173,9 +173,9 @@ static unsigned long * bm_map_paddr(stru
 	return __bm_map_paddr(b, offset);
 }
 
-static void __bm_unmap(unsigned long *p_addr, const enum km_type km)
+static void __bm_unmap(unsigned long *p_addr)
 {
-	kunmap_atomic(p_addr, km);
+	kunmap_atomic(p_addr);
 };
 
 static void bm_unmap(unsigned long *p_addr)
@@ -934,7 +934,7 @@ int drbd_bm_write_sect(struct drbd_conf 
  */
 #define BPP_MASK ((1UL << (PAGE_SHIFT+3)) - 1)
 static unsigned long __bm_find_next(struct drbd_conf *mdev, unsigned long bm_fo,
-	const int find_zero_bit, const enum km_type km)
+	const int find_zero_bit)
 {
 	struct drbd_bitmap *b = mdev->bitmap;
 	unsigned long i = -1UL;
@@ -948,14 +948,14 @@ static unsigned long __bm_find_next(stru
 			unsigned long offset;
 			bit_offset = bm_fo & ~BPP_MASK; /* bit offset of the page */
 			offset = bit_offset >> LN2_BPL;    /* word offset of the page */
-			p_addr = __bm_map_paddr(b, offset, km);
+			p_addr = __bm_map_paddr(b, offset);
 
 			if (find_zero_bit)
 				i = find_next_zero_bit(p_addr, PAGE_SIZE*8, bm_fo & BPP_MASK);
 			else
 				i = find_next_bit(p_addr, PAGE_SIZE*8, bm_fo & BPP_MASK);
 
-			__bm_unmap(p_addr, km);
+			__bm_unmap(p_addr);
 			if (i < PAGE_SIZE*8) {
 				i = bit_offset + i;
 				if (i >= b->bm_bits)
@@ -1023,7 +1023,7 @@ unsigned long _drbd_bm_find_next_zero(st
  * expected to be called for only a few bits (e - s about BITS_PER_LONG).
  * Must hold bitmap lock already. */
 static int __bm_change_bits_to(struct drbd_conf *mdev, const unsigned long s,
-	unsigned long e, int val, const enum km_type km)
+	unsigned long e, int val)
 {
 	struct drbd_bitmap *b = mdev->bitmap;
 	unsigned long *p_addr = NULL;
@@ -1041,8 +1041,8 @@ static int __bm_change_bits_to(struct dr
 		unsigned long page_nr = offset >> (PAGE_SHIFT - LN2_BPL + 3);
 		if (page_nr != last_page_nr) {
 			if (p_addr)
-				__bm_unmap(p_addr, km);
-			p_addr = __bm_map_paddr(b, offset, km);
+				__bm_unmap(p_addr);
+			p_addr = __bm_map_paddr(b, offset);
 			last_page_nr = page_nr;
 		}
 		if (val)
@@ -1051,7 +1051,7 @@ static int __bm_change_bits_to(struct dr
 			c -= (0 != __test_and_clear_bit(bitnr & BPP_MASK, p_addr));
 	}
 	if (p_addr)
-		__bm_unmap(p_addr, km);
+		__bm_unmap(p_addr);
 	b->bm_set += c;
 	return c;
 }
Index: linux-2.6/include/linux/io-mapping.h
===================================================================
--- linux-2.6.orig/include/linux/io-mapping.h
+++ linux-2.6/include/linux/io-mapping.h
@@ -81,8 +81,7 @@ io_mapping_free(struct io_mapping *mappi
 /* Atomic map/unmap */
 static inline void *
 io_mapping_map_atomic_wc(struct io_mapping *mapping,
-			 unsigned long offset,
-			 int slot)
+			 unsigned long offset)
 {
 	resource_size_t phys_addr;
 	unsigned long pfn;
@@ -90,13 +89,13 @@ io_mapping_map_atomic_wc(struct io_mappi
 	BUG_ON(offset >= mapping->size);
 	phys_addr = mapping->base + offset;
 	pfn = (unsigned long) (phys_addr >> PAGE_SHIFT);
-	return iomap_atomic_prot_pfn(pfn, slot, mapping->prot);
+	return iomap_atomic_prot_pfn(pfn, mapping->prot);
 }
 
 static inline void
-io_mapping_unmap_atomic(void *vaddr, int slot)
+io_mapping_unmap_atomic(void *vaddr)
 {
-	iounmap_atomic(vaddr, slot);
+	iounmap_atomic(vaddr);
 }
 
 static inline void *
@@ -144,7 +143,7 @@ io_mapping_map_atomic_wc(struct io_mappi
 }
 
 static inline void
-io_mapping_unmap_atomic(void *vaddr, int slot)
+io_mapping_unmap_atomic(void *vaddr)
 {
 }
 
Index: linux-2.6/drivers/gpu/drm/i915/i915_gem.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/i915/i915_gem.c
+++ linux-2.6/drivers/gpu/drm/i915/i915_gem.c
@@ -3487,8 +3487,7 @@ i915_gem_object_pin_and_relocate(struct 
 		reloc_offset = obj_priv->gtt_offset + reloc->offset;
 		reloc_page = io_mapping_map_atomic_wc(dev_priv->mm.gtt_mapping,
 						      (reloc_offset &
-						       ~(PAGE_SIZE - 1)),
-						      KM_USER0);
+						       ~(PAGE_SIZE - 1)));
 		reloc_entry = (uint32_t __iomem *)(reloc_page +
 						   (reloc_offset & (PAGE_SIZE - 1)));
 		reloc_val = target_obj_priv->gtt_offset + reloc->delta;
Index: linux-2.6/arch/arm/lib/uaccess_with_memcpy.c
===================================================================
--- linux-2.6.orig/arch/arm/lib/uaccess_with_memcpy.c
+++ linux-2.6/arch/arm/lib/uaccess_with_memcpy.c
@@ -17,6 +17,7 @@
 #include <linux/sched.h>
 #include <linux/hardirq.h> /* for in_atomic() */
 #include <linux/gfp.h>
+#include <linux/highmem.h>
 #include <asm/current.h>
 #include <asm/page.h>
 
Index: linux-2.6/drivers/gpu/drm/i915/intel_overlay.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/i915/intel_overlay.c
+++ linux-2.6/drivers/gpu/drm/i915/intel_overlay.c
@@ -185,8 +185,7 @@ static struct overlay_registers *intel_o
 
 	if (OVERLAY_NONPHYSICAL(overlay->dev)) {
 		regs = io_mapping_map_atomic_wc(dev_priv->mm.gtt_mapping,
-						overlay->reg_bo->gtt_offset,
-						KM_USER0);
+						overlay->reg_bo->gtt_offset);
 
 		if (!regs) {
 			DRM_ERROR("failed to map overlay regs in GTT\n");
Index: linux-2.6/arch/arm/include/asm/pgtable.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/pgtable.h
+++ linux-2.6/arch/arm/include/asm/pgtable.h
@@ -269,11 +269,11 @@ extern struct page *empty_zero_page;
 #define pte_unmap_nested(pte)		__pte_unmap(pte)
 
 #ifndef CONFIG_HIGHPTE
-#define __pte_map(dir,km)	pmd_page_vaddr(*(dir))
-#define __pte_unmap(pte,km)	do { } while (0)
+#define __pte_map(dir)		pmd_page_vaddr(*(dir))
+#define __pte_unmap(pte)	do { } while (0)
 #else
-#define __pte_map(dir,km)	((pte_t *)kmap_atomic(pmd_page(*(dir)), km) + PTRS_PER_PTE)
-#define __pte_unmap(pte,km)	kunmap_atomic((pte - PTRS_PER_PTE), km)
+#define __pte_map(dir)		((pte_t *)kmap_atomic(pmd_page(*(dir))) + PTRS_PER_PTE)
+#define __pte_unmap(pte)	kunmap_atomic((pte - PTRS_PER_PTE))
 #endif
 
 #define set_pte_ext(ptep,pte,ext) cpu_set_pte_ext(ptep,pte,ext)
Index: linux-2.6/arch/powerpc/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/highmem.h
+++ linux-2.6/arch/powerpc/include/asm/highmem.h
@@ -82,7 +82,7 @@ static inline void kunmap(struct page *p
 
 static inline void *kmap_atomic(struct page *page)
 {
-	return kmap_atomic_prot(page, type, kmap_prot);
+	return kmap_atomic_prot(page, kmap_prot);
 }
 
 static inline struct page *kmap_atomic_to_page(void *ptr)
Index: linux-2.6/arch/powerpc/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/highmem.c
+++ linux-2.6/arch/powerpc/mm/highmem.c
@@ -31,7 +31,7 @@
  */
 void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 {
-	unsigned int idx;
+	unsigned int idx, type;
 	unsigned long vaddr;
 
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
@@ -55,6 +55,7 @@ EXPORT_SYMBOL(kmap_atomic_prot);
 void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
+	unsigned int type;
 
 	if (vaddr < __fix_to_virt(FIX_KMAP_END)) {
 		pagefault_enable();
Index: linux-2.6/arch/sparc/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/highmem.c
+++ linux-2.6/arch/sparc/mm/highmem.c
@@ -31,7 +31,7 @@
 
 void *kmap_atomic(struct page *page)
 {
-	unsigned long idx;
+	unsigned long idx, type;
 	unsigned long vaddr;
 
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
@@ -68,6 +68,7 @@ EXPORT_SYMBOL(kmap_atomic);
 void kunmap_atomic_notypecheck(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
+	unsigned long type;
 
 	if (vaddr < FIXADDR_START) { // FIXME
 		pagefault_enable();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
