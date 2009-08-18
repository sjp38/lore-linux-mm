Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 114506B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 11:34:31 -0400 (EDT)
Message-Id: <4A8AE6280200007800010539@vpn.id2.novell.com>
Date: Tue, 18 Aug 2009 16:34:32 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] replace various uses of num_physpages by
	 totalram_pages
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Sizing of memory allocations shouldn't depend on the number of physical
pages found in a system, as that generally includes (perhaps a huge
amount of) non-RAM pages. The amount of what actually is usable as
storage should instead be used as a basis here.

Some of the calculations (i.e. those not intending to use high memory)
should likely even use (totalram_pages - totalhigh_pages).

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Acked-by: Rusty Russell <rusty@rustcorp.com.au>

---
 arch/x86/kernel/microcode_core.c  |    4 ++--
 drivers/char/agp/backend.c        |    4 ++--
 drivers/parisc/ccio-dma.c         |    4 ++--
 drivers/parisc/sba_iommu.c        |    4 ++--
 drivers/xen/balloon.c             |    4 ----
 fs/ntfs/malloc.h                  |    2 +-
 include/linux/mm.h                |    1 +
 init/main.c                       |    4 ++--
 mm/slab.c                         |    2 +-
 mm/swap.c                         |    2 +-
 mm/vmalloc.c                      |    4 ++--
 net/core/sock.c                   |    4 ++--
 net/dccp/proto.c                  |    6 +++---
 net/decnet/dn_route.c             |    2 +-
 net/ipv4/route.c                  |    2 +-
 net/ipv4/tcp.c                    |    4 ++--
 net/netfilter/nf_conntrack_core.c |    4 ++--
 net/netfilter/x_tables.c          |    2 +-
 net/netfilter/xt_hashlimit.c      |    8 ++++----
 net/netlink/af_netlink.c          |    6 +++---
 net/sctp/protocol.c               |    6 +++---
 21 files changed, 38 insertions(+), 41 deletions(-)

--- linux-2.6.31-rc6/arch/x86/kernel/microcode_core.c	2009-08-18 =
15:31:16.000000000 +0200
+++ 2.6.31-rc6-use-totalram_pages/arch/x86/kernel/microcode_core.c	=
2009-08-17 15:21:19.000000000 +0200
@@ -210,8 +210,8 @@ static ssize_t microcode_write(struct fi
 {
 	ssize_t ret =3D -EINVAL;
=20
-	if ((len >> PAGE_SHIFT) > num_physpages) {
-		pr_err("microcode: too much data (max %ld pages)\n", =
num_physpages);
+	if ((len >> PAGE_SHIFT) > totalram_pages) {
+		pr_err("microcode: too much data (max %ld pages)\n", =
totalram_pages);
 		return ret;
 	}
=20
--- linux-2.6.31-rc6/drivers/char/agp/backend.c	2009-08-18 15:31:17.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/drivers/char/agp/backend.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -114,9 +114,9 @@ static int agp_find_max(void)
 	long memory, index, result;
=20
 #if PAGE_SHIFT < 20
-	memory =3D num_physpages >> (20 - PAGE_SHIFT);
+	memory =3D totalram_pages >> (20 - PAGE_SHIFT);
 #else
-	memory =3D num_physpages << (PAGE_SHIFT - 20);
+	memory =3D totalram_pages << (PAGE_SHIFT - 20);
 #endif
 	index =3D 1;
=20
--- linux-2.6.31-rc6/drivers/parisc/ccio-dma.c	2009-08-18 15:31:36.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/drivers/parisc/ccio-dma.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -1266,7 +1266,7 @@ ccio_ioc_init(struct ioc *ioc)
 	** Hot-Plug/Removal of PCI cards. (aka PCI OLARD).
 	*/
=20
-	iova_space_size =3D (u32) (num_physpages / count_parisc_driver(&cci=
o_driver));
+	iova_space_size =3D (u32) (totalram_pages / count_parisc_driver(&cc=
io_driver));
=20
 	/* limit IOVA space size to 1MB-1GB */
=20
@@ -1305,7 +1305,7 @@ ccio_ioc_init(struct ioc *ioc)
=20
 	DBG_INIT("%s() hpa 0x%p mem %luMB IOV %dMB (%d bits)\n",
 			__func__, ioc->ioc_regs,
-			(unsigned long) num_physpages >> (20 - PAGE_SHIFT),=

+			(unsigned long) totalram_pages >> (20 - PAGE_SHIFT)=
,
 			iova_space_size>>20,
 			iov_order + PAGE_SHIFT);
=20
--- linux-2.6.31-rc6/drivers/parisc/sba_iommu.c	2009-08-18 15:31:36.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/drivers/parisc/sba_iommu.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -1390,7 +1390,7 @@ sba_ioc_init(struct parisc_device *sba,=20
 	** for DMA hints - ergo only 30 bits max.
 	*/
=20
-	iova_space_size =3D (u32) (num_physpages/global_ioc_cnt);
+	iova_space_size =3D (u32) (totalram_pages/global_ioc_cnt);
=20
 	/* limit IOVA space size to 1MB-1GB */
 	if (iova_space_size < (1 << (20 - PAGE_SHIFT))) {
@@ -1415,7 +1415,7 @@ sba_ioc_init(struct parisc_device *sba,=20
 	DBG_INIT("%s() hpa 0x%lx mem %ldMB IOV %dMB (%d bits)\n",
 			__func__,
 			ioc->ioc_hpa,
-			(unsigned long) num_physpages >> (20 - PAGE_SHIFT),=

+			(unsigned long) totalram_pages >> (20 - PAGE_SHIFT)=
,
 			iova_space_size>>20,
 			iov_order + PAGE_SHIFT);
=20
--- linux-2.6.31-rc6/drivers/xen/balloon.c	2009-06-10 05:05:27.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/drivers/xen/balloon.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -96,11 +96,7 @@ static struct balloon_stats balloon_stat
 /* We increase/decrease in batches which fit in a page */
 static unsigned long frame_list[PAGE_SIZE / sizeof(unsigned long)];
=20
-/* VM /proc information for memory */
-extern unsigned long totalram_pages;
-
 #ifdef CONFIG_HIGHMEM
-extern unsigned long totalhigh_pages;
 #define inc_totalhigh_pages() (totalhigh_pages++)
 #define dec_totalhigh_pages() (totalhigh_pages--)
 #else
--- linux-2.6.31-rc6/fs/ntfs/malloc.h	2008-04-17 04:49:44.000000000 =
+0200
+++ 2.6.31-rc6-use-totalram_pages/fs/ntfs/malloc.h	2009-08-17 =
15:21:19.000000000 +0200
@@ -47,7 +47,7 @@ static inline void *__ntfs_malloc(unsign
 		return kmalloc(PAGE_SIZE, gfp_mask & ~__GFP_HIGHMEM);
 		/* return (void *)__get_free_page(gfp_mask); */
 	}
-	if (likely(size >> PAGE_SHIFT < num_physpages))
+	if (likely((size >> PAGE_SHIFT) < totalram_pages))
 		return __vmalloc(size, gfp_mask, PAGE_KERNEL);
 	return NULL;
 }
--- linux-2.6.31-rc6/include/linux/mm.h	2009-08-18 15:31:55.000000000 =
+0200
+++ 2.6.31-rc6-use-totalram_pages/include/linux/mm.h	2009-08-17 =
15:21:19.000000000 +0200
@@ -25,6 +25,7 @@ extern unsigned long max_mapnr;
 #endif
=20
 extern unsigned long num_physpages;
+extern unsigned long totalram_pages;
 extern void * high_memory;
 extern int page_cluster;
=20
--- linux-2.6.31-rc6/init/main.c	2009-08-18 15:31:56.000000000 =
+0200
+++ 2.6.31-rc6-use-totalram_pages/init/main.c	2009-08-17 15:21:19.0000000=
00 +0200
@@ -691,12 +691,12 @@ asmlinkage void __init start_kernel(void
 #endif
 	thread_info_cache_init();
 	cred_init();
-	fork_init(num_physpages);
+	fork_init(totalram_pages);
 	proc_caches_init();
 	buffer_init();
 	key_init();
 	security_init();
-	vfs_caches_init(num_physpages);
+	vfs_caches_init(totalram_pages);
 	radix_tree_init();
 	signals_init();
 	/* rootfs populating might need page-writeback */
--- linux-2.6.31-rc6/mm/slab.c	2009-08-18 15:31:56.000000000 +0200
+++ 2.6.31-rc6-use-totalram_pages/mm/slab.c	2009-08-17 15:21:19.0000000=
00 +0200
@@ -1384,7 +1384,7 @@ void __init kmem_cache_init(void)
 	 * Fragmentation resistance on low memory - only use bigger
 	 * page orders on machines with more than 32MB of memory.
 	 */
-	if (num_physpages > (32 << 20) >> PAGE_SHIFT)
+	if (totalram_pages > (32 << 20) >> PAGE_SHIFT)
 		slab_break_gfp_order =3D BREAK_GFP_ORDER_HI;
=20
 	/* Bootstrap is tricky, because several objects are allocated
--- linux-2.6.31-rc6/mm/swap.c	2009-06-10 05:05:27.000000000 +0200
+++ 2.6.31-rc6-use-totalram_pages/mm/swap.c	2009-08-17 15:21:19.0000000=
00 +0200
@@ -496,7 +496,7 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
  */
 void __init swap_setup(void)
 {
-	unsigned long megs =3D num_physpages >> (20 - PAGE_SHIFT);
+	unsigned long megs =3D totalram_pages >> (20 - PAGE_SHIFT);
=20
 #ifdef CONFIG_SWAP
 	bdi_init(swapper_space.backing_dev_info);
--- linux-2.6.31-rc6/mm/vmalloc.c	2009-08-18 15:31:56.000000000 =
+0200
+++ 2.6.31-rc6-use-totalram_pages/mm/vmalloc.c	2009-08-17 15:21:19.0000000=
00 +0200
@@ -1368,7 +1368,7 @@ void *vmap(struct page **pages, unsigned
=20
 	might_sleep();
=20
-	if (count > num_physpages)
+	if (count > totalram_pages)
 		return NULL;
=20
 	area =3D get_vm_area_caller((count << PAGE_SHIFT), flags,
@@ -1475,7 +1475,7 @@ static void *__vmalloc_node(unsigned lon
 	unsigned long real_size =3D size;
=20
 	size =3D PAGE_ALIGN(size);
-	if (!size || (size >> PAGE_SHIFT) > num_physpages)
+	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
 		return NULL;
=20
 	area =3D __get_vm_area_node(size, VM_ALLOC, VMALLOC_START, =
VMALLOC_END,
--- linux-2.6.31-rc6/net/core/sock.c	2009-08-18 15:31:57.000000000 =
+0200
+++ 2.6.31-rc6-use-totalram_pages/net/core/sock.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -1195,12 +1195,12 @@ EXPORT_SYMBOL_GPL(sk_setup_caps);
=20
 void __init sk_init(void)
 {
-	if (num_physpages <=3D 4096) {
+	if (totalram_pages <=3D 4096) {
 		sysctl_wmem_max =3D 32767;
 		sysctl_rmem_max =3D 32767;
 		sysctl_wmem_default =3D 32767;
 		sysctl_rmem_default =3D 32767;
-	} else if (num_physpages >=3D 131072) {
+	} else if (totalram_pages >=3D 131072) {
 		sysctl_wmem_max =3D 131071;
 		sysctl_rmem_max =3D 131071;
 	}
--- linux-2.6.31-rc6/net/dccp/proto.c	2009-08-18 15:31:57.000000000 =
+0200
+++ 2.6.31-rc6-use-totalram_pages/net/dccp/proto.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -1049,10 +1049,10 @@ static int __init dccp_init(void)
 	 *
 	 * The methodology is similar to that of the buffer cache.
 	 */
-	if (num_physpages >=3D (128 * 1024))
-		goal =3D num_physpages >> (21 - PAGE_SHIFT);
+	if (totalram_pages >=3D (128 * 1024))
+		goal =3D totalram_pages >> (21 - PAGE_SHIFT);
 	else
-		goal =3D num_physpages >> (23 - PAGE_SHIFT);
+		goal =3D totalram_pages >> (23 - PAGE_SHIFT);
=20
 	if (thash_entries)
 		goal =3D (thash_entries *
--- linux-2.6.31-rc6/net/decnet/dn_route.c	2009-08-18 15:31:57.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/net/decnet/dn_route.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -1750,7 +1750,7 @@ void __init dn_route_init(void)
 	dn_route_timer.expires =3D jiffies + decnet_dst_gc_interval * HZ;
 	add_timer(&dn_route_timer);
=20
-	goal =3D num_physpages >> (26 - PAGE_SHIFT);
+	goal =3D totalram_pages >> (26 - PAGE_SHIFT);
=20
 	for(order =3D 0; (1UL << order) < goal; order++)
 		/* NOTHING */;
--- linux-2.6.31-rc6/net/ipv4/route.c	2009-08-18 15:31:59.000000000 =
+0200
+++ 2.6.31-rc6-use-totalram_pages/net/ipv4/route.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -3412,7 +3412,7 @@ int __init ip_rt_init(void)
 		alloc_large_system_hash("IP route cache",
 					sizeof(struct rt_hash_bucket),
 					rhash_entries,
-					(num_physpages >=3D 128 * 1024) ?
+					(totalram_pages >=3D 128 * 1024) ?
 					15 : 17,
 					0,
 					&rt_hash_log,
--- linux-2.6.31-rc6/net/ipv4/tcp.c	2009-08-18 15:31:59.000000000 =
+0200
+++ 2.6.31-rc6-use-totalram_pages/net/ipv4/tcp.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -2862,7 +2862,7 @@ void __init tcp_init(void)
 		alloc_large_system_hash("TCP established",
 					sizeof(struct inet_ehash_bucket),
 					thash_entries,
-					(num_physpages >=3D 128 * 1024) ?
+					(totalram_pages >=3D 128 * 1024) ?
 					13 : 15,
 					0,
 					&tcp_hashinfo.ehash_size,
@@ -2879,7 +2879,7 @@ void __init tcp_init(void)
 		alloc_large_system_hash("TCP bind",
 					sizeof(struct inet_bind_hashbucket)=
,
 					tcp_hashinfo.ehash_size,
-					(num_physpages >=3D 128 * 1024) ?
+					(totalram_pages >=3D 128 * 1024) ?
 					13 : 15,
 					0,
 					&tcp_hashinfo.bhash_size,
--- linux-2.6.31-rc6/net/netfilter/nf_conntrack_core.c	2009-08-18 =
15:32:01.000000000 +0200
+++ 2.6.31-rc6-use-totalram_pages/net/netfilter/nf_conntrack_core.c	=
2009-08-17 15:21:19.000000000 +0200
@@ -1245,9 +1245,9 @@ static int nf_conntrack_init_init_net(vo
 	 * machine has 512 buckets. >=3D 1GB machines have 16384 buckets. =
*/
 	if (!nf_conntrack_htable_size) {
 		nf_conntrack_htable_size
-			=3D (((num_physpages << PAGE_SHIFT) / 16384)
+			=3D (((totalram_pages << PAGE_SHIFT) / 16384)
 			   / sizeof(struct hlist_head));
-		if (num_physpages > (1024 * 1024 * 1024 / PAGE_SIZE))
+		if (totalram_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
 			nf_conntrack_htable_size =3D 16384;
 		if (nf_conntrack_htable_size < 32)
 			nf_conntrack_htable_size =3D 32;
--- linux-2.6.31-rc6/net/netfilter/x_tables.c	2009-08-18 15:32:01.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/net/netfilter/x_tables.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -617,7 +617,7 @@ struct xt_table_info *xt_alloc_table_inf
 	int cpu;
=20
 	/* Pedantry: prevent them from hitting BUG() in vmalloc.c --RR */
-	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > num_physpages)
+	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > totalram_pages)
 		return NULL;
=20
 	newinfo =3D kzalloc(XT_TABLE_INFO_SZ, GFP_KERNEL);
--- linux-2.6.31-rc6/net/netfilter/xt_hashlimit.c	2009-06-10 =
05:05:27.000000000 +0200
+++ 2.6.31-rc6-use-totalram_pages/net/netfilter/xt_hashlimit.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -194,9 +194,9 @@ static int htable_create_v0(struct xt_ha
 	if (minfo->cfg.size)
 		size =3D minfo->cfg.size;
 	else {
-		size =3D ((num_physpages << PAGE_SHIFT) / 16384) /
+		size =3D ((totalram_pages << PAGE_SHIFT) / 16384) /
 		       sizeof(struct list_head);
-		if (num_physpages > (1024 * 1024 * 1024 / PAGE_SIZE))
+		if (totalram_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
 			size =3D 8192;
 		if (size < 16)
 			size =3D 16;
@@ -266,9 +266,9 @@ static int htable_create(struct xt_hashl
 	if (minfo->cfg.size) {
 		size =3D minfo->cfg.size;
 	} else {
-		size =3D (num_physpages << PAGE_SHIFT) / 16384 /
+		size =3D (totalram_pages << PAGE_SHIFT) / 16384 /
 		       sizeof(struct list_head);
-		if (num_physpages > 1024 * 1024 * 1024 / PAGE_SIZE)
+		if (totalram_pages > 1024 * 1024 * 1024 / PAGE_SIZE)
 			size =3D 8192;
 		if (size < 16)
 			size =3D 16;
--- linux-2.6.31-rc6/net/netlink/af_netlink.c	2009-08-18 15:32:01.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/net/netlink/af_netlink.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -2026,10 +2026,10 @@ static int __init netlink_proto_init(voi
 	if (!nl_table)
 		goto panic;
=20
-	if (num_physpages >=3D (128 * 1024))
-		limit =3D num_physpages >> (21 - PAGE_SHIFT);
+	if (totalram_pages >=3D (128 * 1024))
+		limit =3D totalram_pages >> (21 - PAGE_SHIFT);
 	else
-		limit =3D num_physpages >> (23 - PAGE_SHIFT);
+		limit =3D totalram_pages >> (23 - PAGE_SHIFT);
=20
 	order =3D get_bitmask_order(limit) - 1 + PAGE_SHIFT;
 	limit =3D (1UL << order) / sizeof(struct hlist_head);
--- linux-2.6.31-rc6/net/sctp/protocol.c	2009-08-18 15:32:01.0000000=
00 +0200
+++ 2.6.31-rc6-use-totalram_pages/net/sctp/protocol.c	2009-08-17 =
15:21:19.000000000 +0200
@@ -1185,10 +1185,10 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Size and allocate the association hash table.
 	 * The methodology is similar to that of the tcp hash tables.
 	 */
-	if (num_physpages >=3D (128 * 1024))
-		goal =3D num_physpages >> (22 - PAGE_SHIFT);
+	if (totalram_pages >=3D (128 * 1024))
+		goal =3D totalram_pages >> (22 - PAGE_SHIFT);
 	else
-		goal =3D num_physpages >> (24 - PAGE_SHIFT);
+		goal =3D totalram_pages >> (24 - PAGE_SHIFT);
=20
 	for (order =3D 0; (1UL << order) < goal; order++)
 		;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
