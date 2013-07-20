Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 173226B0031
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 11:25:11 -0400 (EDT)
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r6KFP93L015441
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:25:10 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r6KFP9qU026757
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:25:09 GMT
Received: from abhmt110.oracle.com (abhmt110.oracle.com [141.146.116.62])
	by userz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r6KFP8Ec020386
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:25:08 GMT
Message-ID: <51EAABD1.8050100@oracle.com>
Date: Sat, 20 Jul 2013 23:25:05 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Fwd: [PATCH 2/2] mm: zcache: core functions added
References: <1374331018-11045-3-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1374331018-11045-3-git-send-email-bob.liu@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


-------- Original Message --------
Subject: [PATCH 2/2] mm: zcache: core functions added
Date: Sat, 20 Jul 2013 22:36:58 +0800
From: Bob Liu <lliubbo@gmail.com>
CC: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com,
gregkh@linuxfoundation.org, ngupta@vflare.org, minchan@kernel.org,
  konrad.wilk@oracle.com, rcj@linux.vnet.ibm.com, mgorman@suse.de,
  riel@redhat.com, penberg@kernel.org, akpm@linux-foundation.org,
 Bob Liu <bob.liu@oracle.com>

This patch adds the cleancache backend for clean file pages compression.

Nitin Gupta have already done many works on this topic in 2010.
You can see his work from below links:
http://lwn.net/Articles/396467/
http://thread.gmane.org/gmane.linux.kernel.mm/50523
But at that time neither the allocation layer nor cleancache have been
merged
into upstream.

(Most of below comments are copyed from his patch.)
Frequently accessed filesystem data is stored in memory to reduce access to
(much) slower backing disks. Under memory pressure, these pages are
freed and
when needed again, they have to be read from disks again. When combined
working set of all running application exceeds amount of physical RAM,
we get
extereme slowdown as reading a page from disk can take time in order of
milliseconds.

Memory compression increases effective memory size and allows more pages to
stay in RAM. Since de/compressing memory pages is several orders of
magnitude
faster than disk I/O, this can provide signifant performance gains for many
workloads. Also, with multi-cores becoming common, benefits of reduced disk
I/O should easily outweigh the problem of increased CPU usage.

It is implemented as a "backend" for cleancache which provides
callbacks for events such as when a page is to be removed from the page
cache
and when it is required again. We use them to implement a 'second chance'
cache for these evicted page cache pages by compressing and storing them in
memory itself.

We use zbud memory allocator which is already merged and used by zswap
for the
same purpose.

A separate "pool" is created for each mount instance for a cleancache-aware
filesystem. Each incoming page is identified with <pool_id, inode_no, index>
where inode_no identifies file within the filesystem corresponding to
pool_id
and index is offset of the page within this inode. Within a pool, inodes are
maintained in an rb-tree and each of its nodes points to a separate
radix-tree
which maintains list of pages within that inode.

Tests were done on physical machine (not in a VM)
Only played with iozone for some simple tests.
Kernel booted with command line "single mem=1G zcache.enabled=1"
Kernel 3.10.0+ (with Seth's zswap patches)
CPU: Core-i5 4-Core
RAM: 1G
Boot into single mode
Swapoff -a to avoid I/O interference
Command for testing:
iozone -a -M -B -s 1G -y 4k -+u -R -b iozone.xls

Results:
Without zcache
                                                            random
random    bkwd   record   stride
              KB  reclen   write rewrite    read    reread    read
write    read  rewrite     read
         1048576       4   73070   36713    75187    74916    1292
674   26724    45514     8491
         1048576       8   68777   34407    71162    73407    2703
1233   27800    42417     5548
         1048576      16   70030   35156    71496    71186    4462
2181   31480    42040     8737
         1048576      32   68796   35442    72557    72734    6955
3615   40783    44627    10959
         1048576      64   76576   35247    68685    72279   11383
6615   49913    44620    14777
         1048576     128   77516   33878    72538    71231   17897
10896   64393    48613    35265
         1048576     256   73465   37450    22857    22854   22845
16655   61152    49170    40571
         1048576     512   68096   35303    22265    22398   36154
23952   58286    48594    39972
         1048576    1024   69442   36192    22206    22541   38927
29643   60695    50483    44120
         1048576    2048   69404   34891    22951    23286   40036
35984   62095    50704    43764
         1048576    4096   68871   35716    23147    23272   41587
37619   66809    47613    45229
         1048576    8192   66775   36409    22997    23070   39023
39674   69262    55548    49324
         1048576   16384   68728   34792    23829    24022   39922
42496   65714    44732    39104
Average:		   70734   35507    45529    45938   23760   19326   52700
47283    29682

With zcache
                                                            random
random    bkwd   record   stride
              KB  reclen   write rewrite    read    reread    read
write    read  rewrite     read
         1048576       4   80330   35970   120942   115559    1491
686   29923    47864    11177
         1048576       8   69553   36658   134402   105351    2978
1332   33291    45885     6331
         1048576      16   79538   36719   149905   155649    5970
2305   38136    42365    14070
         1048576      32   68326   37064   150126   151728   10462
4128   44693    44975    15607
         1048576      64   74450   35379   147918   130771   19199
7468   54065    43630    22104
         1048576     128   71655   36125   137384   139080   27495
11507   65742    47471    49833
         1048576     256   78867   36030    51814    42656   41578
17829   77058    44247    54368
         1048576     512   68671   35378    52359    44516   52296
25944   80121    47270    57271
         1048576    1024   69495   37064    53579    56057   60121
31833   83420    46752    65267
         1048576    2048   69014   35589    52216    49919   69441
37169   92552    45746    68838
         1048576    4096   67338   36194    56068    56855   71569
39895   98462    49440    72496
         1048576    8192   65153   35345    54983    58602   78402
43841   98809    47334    74803
         1048576   16384   63579   34842    50888    54429   68070
42518   87534    45665    64967
Average:                   71228   36027    93345    89321   39159
20497   67985    46050    44395
Chnage :                      1%      1%     105%      94%     65%
6%     29%      -3%      50%

You can see that reading side performance get improved a lot after using
zcache.
Because pages are cached by zcache, we only need to decompress them
instead of
reading from disk.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 mm/Kconfig  |   18 ++
 mm/Makefile |    1 +
 mm/zcache.c |  840
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 859 insertions(+)
 create mode 100644 mm/zcache.c

diff --git a/mm/Kconfig b/mm/Kconfig
index eec97f2..2b68103 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -507,3 +507,21 @@ config ZSWAP
 	  interactions don't cause any known issues on simple memory setups,
 	  they have not be fully explored on the large set of potential
 	  configurations and workloads that exist.
+
+config ZCACHE
+	bool "Compressed cache for swap and clean file pages (EXPERIMENTAL)"
+	depends on FRONTSWAP && CRYPTO && CLEANCACHE
+	select CRYPTO_LZO
+	select ZBUD
+	default n
+	help
+	  A compressed cache for swap and clean file pages.
+
+	  It can takes pages that are in the process of being swapped out and
+	  attempts to compress them into a dynamically allocated RAM-based
memory pool.
+	  This can result in a significant I/O reduction on swap device and,
+	  in the case where decompressing from RAM is faster that swap device
+	  reads, can also improve workload performance.
+
+	  Besides swap pages, zcache can also compress the clean file pages
into a memory pool.
+	  This can reduce the refaults of reading those file pages back from
disks.
diff --git a/mm/Makefile b/mm/Makefile
index f008033..a29232b 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,6 +33,7 @@ obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
 obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_ZSWAP)	+= zswap.o
+obj-$(CONFIG_ZCACHE)	+= zcache.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
diff --git a/mm/zcache.c b/mm/zcache.c
new file mode 100644
index 0000000..a2408e8
--- /dev/null
+++ b/mm/zcache.c
@@ -0,0 +1,840 @@
+/*
+ * zcache.c - zcache driver file
+ *
+ * The goal of zcache is implement a generic memory compression layer.
+ * It's a backend of both frontswap and cleancache.
+ *
+ * This file only implemented cleancache part currently.
+ * Concepts based on original zcache by Dan Magenheimer.
+ *
+ * Copyright (C) 2013  Bob Liu <bob.liu@oracle.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+*/
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/cpu.h>
+#include <linux/highmem.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/atomic.h>
+#include <linux/cleancache.h>
+#include <linux/rbtree.h>
+#include <linux/radix-tree.h>
+#include <linux/swap.h>
+#include <linux/crypto.h>
+#include <linux/mempool.h>
+#include <linux/zbud.h>
+
+#include <linux/mm_types.h>
+#include <linux/page-flags.h>
+#include <linux/swapops.h>
+#include <linux/writeback.h>
+#include <linux/pagemap.h>
+
+/* Enable/disable zcache (disabled by default) */
+static bool zcache_enabled __read_mostly;
+module_param_named(enabled, zcache_enabled, bool, 0);
+
+/* Enable/disable cleancache part of zcache */
+static bool zcache_nocleancache __read_mostly;
+module_param_named(nocleancache, zcache_nocleancache, bool, 0);
+
+/* Compressor to be used by zcache */
+#define ZCACHE_COMPRESSOR_DEFAULT "lzo"
+static char *zcache_compressor = ZCACHE_COMPRESSOR_DEFAULT;
+module_param_named(compressor, zcache_compressor, charp, 0);
+
+/* The maximum percentage of memory that the compressed pool can occupy */
+static unsigned int zcache_max_pool_percent = 10;
+module_param_named(max_pool_percent,
+			zcache_max_pool_percent, uint, 0644);
+
+/* zcache cleancache part statistics */
+static u64 zcache_cleancache_pool_pages;
+static u64 zcache_cleancache_pool_limit_hit;
+static u64 zcache_cleancache_written_back_pages;
+static u64 zcache_cleancache_dup_entry;
+static u64 zcache_cleancache_reclaim_fail;
+static u64 zcache_cleancache_zbud_alloc_fail;
+static atomic_t zcache_cleancache_stored_pages = ATOMIC_INIT(0);
+
+struct zcache_cleancache_meta {
+	int ra_index;
+	int length;	/* compressed page size */
+};
+
+#define MAX_ZCACHE_POOLS 32 /* arbitrary */
+
+/* Red-Black tree node. Maps inode to its page-tree */
+struct zcache_rb_entry {
+	int rb_index;
+	struct kref refcount;
+
+	struct radix_tree_root ra_root; /* maps inode index to page */
+	spinlock_t ra_lock;		/* protects radix tree */
+	struct rb_node rb_node;
+};
+
+/* One zcache pool per (cleancache aware) filesystem mount instance */
+struct zcache_pool {
+	struct rb_root rb_root;		/* maps inode number to page tree */
+	rwlock_t rb_lock;		/* protects inode_tree */
+	struct zbud_pool *pool;         /* zbud pool used */
+};
+
+/* Manage all zcache pools */
+struct _zcache {
+	struct zcache_pool *pools[MAX_ZCACHE_POOLS];
+	u32 num_pools;		/* current no. of zcache pools */
+	spinlock_t pool_lock;	/* protects pools[] and num_pools */
+};
+struct _zcache zcache;
+
+static struct kmem_cache *zcache_cleancache_entry_cache;
+
+/*********************************
+* compression functions
+**********************************/
+/* per-cpu compression transforms */
+static struct crypto_comp * __percpu *zcache_comp_pcpu_tfms;
+
+enum comp_op {
+	ZCACHE_COMPOP_COMPRESS,
+	ZCACHE_COMPOP_DECOMPRESS
+};
+
+static int zcache_comp_op(enum comp_op op, const u8 *src, unsigned int
slen,
+				u8 *dst, unsigned int *dlen)
+{
+	struct crypto_comp *tfm;
+	int ret;
+
+	tfm = *per_cpu_ptr(zcache_comp_pcpu_tfms, get_cpu());
+	switch (op) {
+	case ZCACHE_COMPOP_COMPRESS:
+		ret = crypto_comp_compress(tfm, src, slen, dst, dlen);
+		break;
+	case ZCACHE_COMPOP_DECOMPRESS:
+		ret = crypto_comp_decompress(tfm, src, slen, dst, dlen);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+
+	put_cpu();
+	return ret;
+}
+
+static int __init zcache_comp_init(void)
+{
+	if (!crypto_has_comp(zcache_compressor, 0, 0)) {
+		pr_info("%s compressor not available\n", zcache_compressor);
+		/* fall back to default compressor */
+		zcache_compressor = ZCACHE_COMPRESSOR_DEFAULT;
+		if (!crypto_has_comp(zcache_compressor, 0, 0))
+			/* can't even load the default compressor */
+			return -ENODEV;
+	}
+	pr_info("using %s compressor\n", zcache_compressor);
+
+	/* alloc percpu transforms */
+	zcache_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
+	if (!zcache_comp_pcpu_tfms)
+		return -ENOMEM;
+	return 0;
+}
+
+static void zcache_comp_exit(void)
+{
+	/* free percpu transforms */
+	if (zcache_comp_pcpu_tfms)
+		free_percpu(zcache_comp_pcpu_tfms);
+}
+
+/*********************************
+* per-cpu code
+**********************************/
+static DEFINE_PER_CPU(u8 *, zcache_dstmem);
+
+static int __zcache_cpu_notifier(unsigned long action, unsigned long cpu)
+{
+	struct crypto_comp *tfm;
+	u8 *dst;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+		tfm = crypto_alloc_comp(zcache_compressor, 0, 0);
+		if (IS_ERR(tfm)) {
+			pr_err("can't allocate compressor transform\n");
+			return NOTIFY_BAD;
+		}
+		*per_cpu_ptr(zcache_comp_pcpu_tfms, cpu) = tfm;
+		dst = kmalloc(PAGE_SIZE * 2, GFP_KERNEL);
+		if (!dst) {
+			pr_err("can't allocate compressor buffer\n");
+			crypto_free_comp(tfm);
+			*per_cpu_ptr(zcache_comp_pcpu_tfms, cpu) = NULL;
+			return NOTIFY_BAD;
+		}
+		per_cpu(zcache_dstmem, cpu) = dst;
+		break;
+	case CPU_DEAD:
+	case CPU_UP_CANCELED:
+		tfm = *per_cpu_ptr(zcache_comp_pcpu_tfms, cpu);
+		if (tfm) {
+			crypto_free_comp(tfm);
+			*per_cpu_ptr(zcache_comp_pcpu_tfms, cpu) = NULL;
+		}
+		dst = per_cpu(zcache_dstmem, cpu);
+		kfree(dst);
+		per_cpu(zcache_dstmem, cpu) = NULL;
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static int zcache_cpu_notifier(struct notifier_block *nb,
+				unsigned long action, void *pcpu)
+{
+	unsigned long cpu = (unsigned long)pcpu;
+	return __zcache_cpu_notifier(action, cpu);
+}
+
+static struct notifier_block zcache_cpu_notifier_block = {
+	.notifier_call = zcache_cpu_notifier
+};
+
+static int zcache_cpu_init(void)
+{
+	unsigned long cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu)
+		if (__zcache_cpu_notifier(CPU_UP_PREPARE, cpu) != NOTIFY_OK)
+			goto cleanup;
+	register_cpu_notifier(&zcache_cpu_notifier_block);
+	put_online_cpus();
+	return 0;
+
+cleanup:
+	for_each_online_cpu(cpu)
+		__zcache_cpu_notifier(CPU_UP_CANCELED, cpu);
+	put_online_cpus();
+	return -ENOMEM;
+}
+
+/*********************************
+* helpers
+**********************************/
+static bool zcache_is_full(void)
+{
+	return (totalram_pages * zcache_max_pool_percent / 100 <
+		zcache_cleancache_pool_pages);
+}
+
+static int zcache_cleancache_entry_cache_create(void)
+{
+	zcache_cleancache_entry_cache = KMEM_CACHE(zcache_rb_entry, 0);
+	return (zcache_cleancache_entry_cache == NULL);
+}
+static void zcache_cleancache_entry_cache_destory(void)
+{
+	kmem_cache_destroy(zcache_cleancache_entry_cache);
+}
+
+static struct zcache_rb_entry *zcache_find_rb_entry(struct rb_root *root,
+		int index, struct rb_node **rb_parent, struct rb_node ***rb_link)
+{
+	struct zcache_rb_entry *entry;
+	struct rb_node **__rb_link, *__rb_parent, *rb_prev;
+
+	__rb_link = &root->rb_node;
+	rb_prev = __rb_parent = NULL;
+
+	while (*__rb_link) {
+		__rb_parent = *__rb_link;
+		entry = rb_entry(__rb_parent, struct zcache_rb_entry, rb_node);
+		if (entry->rb_index > index)
+			__rb_link = &__rb_parent->rb_left;
+		else if (entry->rb_index < index) {
+			rb_prev = __rb_parent;
+			__rb_link = &__rb_parent->rb_right;
+		} else
+			return entry;
+	}
+
+	if (rb_parent)
+		*rb_parent = __rb_parent;
+	if (rb_link)
+		*rb_link = __rb_link;
+	return NULL;
+}
+
+static struct zcache_rb_entry *zcache_find_get_rb_entry(struct
zcache_pool *zpool,
+					int rb_index)
+{
+	unsigned long flags;
+	struct zcache_rb_entry *rb_entry;
+
+	read_lock_irqsave(&zpool->rb_lock, flags);
+	rb_entry = zcache_find_rb_entry(&zpool->rb_root, rb_index, 0, 0);
+	if (rb_entry)
+		kref_get(&rb_entry->refcount);
+	read_unlock_irqrestore(&zpool->rb_lock, flags);
+	return rb_entry;
+}
+
+/*
+ * kref_put callback for zcache rb_entry.
+ *
+ * The entry must have been isolated from rbtree already.
+ */
+static void zcache_rb_entry_release(struct kref *kref)
+{
+	struct zcache_rb_entry *rb_entry;
+
+	rb_entry = container_of(kref, struct zcache_rb_entry, refcount);
+	BUG_ON(rb_entry->ra_root.rnode);
+	kmem_cache_free(zcache_cleancache_entry_cache, rb_entry);
+}
+
+/*
+ * Called under zcache_rb_entry->ra_lock
+ */
+static int zcache_rb_entry_is_empty(struct zcache_rb_entry *rb_entry)
+{
+	return rb_entry->ra_root.rnode == NULL;
+}
+
+/* Remove rb_entry from rbtree */
+static void zcache_rb_entry_isolate(struct zcache_pool *zpool,
+		struct zcache_rb_entry *rb_entry, bool hold_rblock)
+{
+	unsigned long flags;
+
+	if (!hold_rblock)
+		write_lock_irqsave(&zpool->rb_lock, flags);
+	/*
+	 * Someone can get reference on this node before we could
+	 * acquire write lock above. We want to remove it from its
+	 * inode_tree when only the caller and corresponding inode_tree
+	 * holds a reference to it. This ensures that a racing zcache
+	 * put will not end up adding a page to an isolated node and
+	 * thereby losing that memory.
+	 *
+	 */
+	if (atomic_read(&rb_entry->refcount.refcount) == 2) {
+		rb_erase(&rb_entry->rb_node, &zpool->rb_root);
+		RB_CLEAR_NODE(&rb_entry->rb_node);
+		kref_put(&rb_entry->refcount, zcache_rb_entry_release);
+	}
+	if (!hold_rblock)
+		write_unlock_irqrestore(&zpool->rb_lock, flags);
+}
+
+
+static int zcache_store_handle(struct zcache_pool *zpool,
+		unsigned long handle, int rb_index, int ra_index)
+{
+	unsigned long flags;
+	struct zcache_rb_entry *rb_entry, *tmp;
+	struct rb_node **link = NULL, *parent = NULL;
+	int ret;
+	void *dup_handlep;
+
+	rb_entry = zcache_find_get_rb_entry(zpool, rb_index);
+	if (!rb_entry) {
+		/* alloc new rb_entry */
+		rb_entry = kmem_cache_alloc(zcache_cleancache_entry_cache, GFP_KERNEL);
+		if (!rb_entry)
+			return -ENOMEM;
+
+		INIT_RADIX_TREE(&rb_entry->ra_root, GFP_ATOMIC|__GFP_NOWARN);
+		spin_lock_init(&rb_entry->ra_lock);
+		rb_entry->rb_index = rb_index;
+		kref_init(&rb_entry->refcount);
+		RB_CLEAR_NODE(&rb_entry->rb_node);
+
+		/* add new entry to rb tree */
+		write_lock_irqsave(&zpool->rb_lock, flags);
+
+		tmp = zcache_find_rb_entry(&zpool->rb_root, rb_index, &parent, &link);
+		if (tmp) {
+			/* somebody else allocated new entry */
+			kmem_cache_free(zcache_cleancache_entry_cache, rb_entry);
+			rb_entry = tmp;
+		} else {
+			rb_link_node(&rb_entry->rb_node, parent, link);
+			rb_insert_color(&rb_entry->rb_node, &zpool->rb_root);
+		}
+
+		kref_get(&rb_entry->refcount);
+		write_unlock_irqrestore(&zpool->rb_lock, flags);
+	}
+
+	/* Succ get rb_entry and refcount after arrived here */
+	spin_lock_irqsave(&rb_entry->ra_lock, flags);
+	dup_handlep = radix_tree_delete(&rb_entry->ra_root, ra_index);
+	if (unlikely(dup_handlep)) {
+		WARN_ON("duplicated entry, will be replaced!\n");
+		zbud_free(zpool->pool, (unsigned long)dup_handlep);
+		atomic_dec(&zcache_cleancache_stored_pages);
+		zcache_cleancache_pool_pages = zbud_get_pool_size(zpool->pool);
+		zcache_cleancache_dup_entry++;
+	}
+	ret = radix_tree_insert(&rb_entry->ra_root, ra_index, (void *)handle);
+
+	if (unlikely(ret))
+		if (zcache_rb_entry_is_empty(rb_entry))
+			zcache_rb_entry_isolate(zpool, rb_entry, 0);
+	spin_unlock_irqrestore(&rb_entry->ra_lock, flags);
+
+	kref_put(&rb_entry->refcount, zcache_rb_entry_release);
+	return ret;
+}
+
+/* Load the handle, and delete it */
+static unsigned long *zcache_load_delete_handle(struct zcache_pool
*zpool, int rb_index,
+				int ra_index)
+{
+	struct zcache_rb_entry *rb_entry;
+	void *handlep = NULL;
+	unsigned long flags;
+
+	rb_entry = zcache_find_get_rb_entry(zpool, rb_index);
+	if (!rb_entry)
+		goto out;
+
+	BUG_ON(rb_entry->rb_index != rb_index);
+
+	spin_lock_irqsave(&rb_entry->ra_lock, flags);
+	handlep = radix_tree_delete(&rb_entry->ra_root, ra_index);
+	if (zcache_rb_entry_is_empty(rb_entry))
+		/* If no more nodes in the rb_entry->radix_tree,
+		 * rm rb_entry from the rbtree and drop the refcount
+		 */
+		zcache_rb_entry_isolate(zpool, rb_entry, 0);
+	spin_unlock_irqrestore(&rb_entry->ra_lock, flags);
+
+	/* After arrive here, rb_entry have dropped from rbtree */
+	kref_put(&rb_entry->refcount, zcache_rb_entry_release);
+out:
+	return handlep;
+}
+
+static void zcache_cleancache_store_page(int pool_id, struct
cleancache_filekey key,
+			pgoff_t index, struct page *page)
+{
+	unsigned int dlen = PAGE_SIZE, len;
+	unsigned long handle;
+	char *buf;
+	u8 *src, *dst;
+	struct zcache_cleancache_meta *zmeta;
+	int ret;
+
+	struct zcache_pool *zpool = zcache.pools[pool_id];
+
+	/* reclaim space if needed */
+	if (zcache_is_full()) {
+		/* Reclaim will be implemented in following version */
+		zcache_cleancache_pool_limit_hit++;
+		return;
+	}
+
+	/* compress */
+	dst = get_cpu_var(zcache_dstmem);
+	src = kmap_atomic(page);
+	ret = zcache_comp_op(ZCACHE_COMPOP_COMPRESS, src, PAGE_SIZE, dst, &dlen);
+	kunmap_atomic(src);
+	if (ret) {
+		pr_err("zcache_cleancache compress error ret %d\n", ret);
+		put_cpu_var(zcache_dstmem);
+		return;
+	}
+
+	/* store handle with meta data */
+	len = dlen + sizeof(struct zcache_cleancache_meta);
+	ret = zbud_alloc(zpool->pool, len, __GFP_NORETRY | __GFP_NOWARN, &handle);
+	if (ret) {
+		zcache_cleancache_zbud_alloc_fail++;
+		put_cpu_var(zcache_dstmem);
+		return;
+	}
+
+	zmeta = zbud_map(zpool->pool, handle);
+	zmeta->ra_index = index;
+	zmeta->length = dlen;
+	buf = (u8 *)(zmeta + 1);
+	memcpy(buf, dst, dlen);
+	zbud_unmap(zpool->pool, handle);
+	put_cpu_var(zcache_dstmem);
+
+	/* populate entry */
+	ret = zcache_store_handle(zpool, handle, key.u.ino, index);
+	if (ret) {
+		pr_err("%s: store handle error %d\n", __func__, ret);
+		zbud_free(zpool->pool, handle);
+	}
+
+	/* update stats */
+	atomic_inc(&zcache_cleancache_stored_pages);
+	zcache_cleancache_pool_pages = zbud_get_pool_size(zpool->pool);
+	return;
+}
+
+static int zcache_cleancache_load_page(int pool_id, struct
cleancache_filekey key,
+			pgoff_t index, struct page *page)
+{
+	struct zcache_pool *zpool = zcache.pools[pool_id];
+	u8 *src, *dst;
+	unsigned int dlen;
+	int ret;
+	unsigned long *handlep;
+	struct zcache_cleancache_meta *zmeta;
+
+	handlep = zcache_load_delete_handle(zpool, key.u.ino, index);
+	if (!handlep)
+		return -1;
+
+	zmeta = (struct zcache_cleancache_meta *)zbud_map(zpool->pool,
(unsigned long)handlep);
+	src = (u8 *)(zmeta + 1);
+
+	/* decompress */
+	dlen = PAGE_SIZE;
+	dst = kmap_atomic(page);
+	ret = zcache_comp_op(ZCACHE_COMPOP_DECOMPRESS, src, zmeta->length,
dst, &dlen);
+	kunmap_atomic(dst);
+	zbud_unmap(zpool->pool, (unsigned long)handlep);
+	zbud_free(zpool->pool, (unsigned long)handlep);
+
+	WARN_ON(ret);	/* decompress err, will fetch from real disk */
+	/* update stats */
+	atomic_dec(&zcache_cleancache_stored_pages);
+	zcache_cleancache_pool_pages = zbud_get_pool_size(zpool->pool);
+	return ret;
+}
+
+static void zcache_cleancache_flush_page(int pool_id, struct
cleancache_filekey key,
+			pgoff_t index)
+{
+	struct zcache_pool *zpool = zcache.pools[pool_id];
+	unsigned long *handlep = NULL;
+
+	handlep = zcache_load_delete_handle(zpool, key.u.ino, index);
+	if (handlep) {
+		zbud_free(zpool->pool, (unsigned long)handlep);
+		atomic_dec(&zcache_cleancache_stored_pages);
+		zcache_cleancache_pool_pages = zbud_get_pool_size(zpool->pool);
+	}
+}
+
+#define FREE_BATCH 16
+static void zcache_cleancache_flush_ratree(struct zcache_pool *zpool,
+				struct zcache_rb_entry *entry)
+{
+	int count, i;
+	unsigned long index = 0;
+
+	do {
+		struct zcache_cleancache_meta *handles[FREE_BATCH];
+
+		count = radix_tree_gang_lookup(&entry->ra_root,
+				(void **)handles, index, FREE_BATCH);
+
+		for (i = 0; i < count; i++) {
+			index = handles[i]->ra_index;
+			radix_tree_delete(&entry->ra_root, index);
+			zbud_free(zpool->pool, (unsigned long)handles[i]);
+			atomic_dec(&zcache_cleancache_stored_pages);
+			zcache_cleancache_pool_pages = zbud_get_pool_size(zpool->pool);
+		}
+
+		index++;
+	} while (count == FREE_BATCH);
+}
+
+static void zcache_cleancache_flush_inode(int pool_id,
+					struct cleancache_filekey key)
+{
+	struct zcache_rb_entry *rb_entry;
+	unsigned long flags1, flags2;
+	struct zcache_pool *zpool = zcache.pools[pool_id];
+
+	/* refuse new pages added in to the same inode */
+	write_lock_irqsave(&zpool->rb_lock, flags1);
+	rb_entry = zcache_find_rb_entry(&zpool->rb_root, key.u.ino, 0, 0);
+	if (!rb_entry) {
+		write_unlock_irqrestore(&zpool->rb_lock, flags1);
+		return;
+	}
+
+	kref_get(&rb_entry->refcount);
+
+	spin_lock_irqsave(&rb_entry->ra_lock, flags2);
+	zcache_cleancache_flush_ratree(zpool, rb_entry);
+	if (zcache_rb_entry_is_empty(rb_entry))
+		zcache_rb_entry_isolate(zpool, rb_entry, 1);
+	spin_unlock_irqrestore(&rb_entry->ra_lock, flags2);
+
+	write_unlock_irqrestore(&zpool->rb_lock, flags1);
+	kref_put(&rb_entry->refcount, zcache_rb_entry_release);
+}
+
+static void zcache_destroy_pool(struct zcache_pool *zpool);
+static void zcache_cleancache_flush_fs(int pool_id)
+{
+	struct zcache_rb_entry *entry = NULL;
+	struct rb_node *node;
+	unsigned long flags1, flags2;
+	struct zcache_pool *zpool = zcache.pools[pool_id];
+
+	if (!zpool)
+		return;
+
+	/* refuse new pages added in to the same inode */
+	write_lock_irqsave(&zpool->rb_lock, flags1);
+
+	node = rb_first(&zpool->rb_root);
+	while (node) {
+		entry = rb_entry(node, struct zcache_rb_entry, rb_node);
+		node = rb_next(node);
+		if (entry) {
+			kref_get(&entry->refcount);
+			spin_lock_irqsave(&entry->ra_lock, flags2);
+			zcache_cleancache_flush_ratree(zpool, entry);
+			if (zcache_rb_entry_is_empty(entry))
+				zcache_rb_entry_isolate(zpool, entry, 1);
+			spin_unlock_irqrestore(&entry->ra_lock, flags2);
+			kref_put(&entry->refcount, zcache_rb_entry_release);
+		}
+	}
+
+	write_unlock_irqrestore(&zpool->rb_lock, flags1);
+
+	zcache_destroy_pool(zpool);
+}
+
+static int zcache_cleancache_evict_entry(struct zbud_pool *pool,
+		unsigned long handle)
+{
+	return -1;
+}
+
+static struct zbud_ops zcache_cleancache_zbud_ops = {
+	.evict = zcache_cleancache_evict_entry
+};
+
+static void zcache_destroy_pool(struct zcache_pool *zpool)
+{
+	int i;
+
+	if (!zpool)
+		return;
+
+	spin_lock(&zcache.pool_lock);
+	zcache.num_pools--;
+	for (i = 0; i < MAX_ZCACHE_POOLS; i++)
+		if (zcache.pools[i] == zpool)
+			break;
+	zcache.pools[i] = NULL;
+	spin_unlock(&zcache.pool_lock);
+
+	if (!RB_EMPTY_ROOT(&zpool->rb_root)) {
+		WARN_ON("Memory leak detected. Freeing non-empty pool!\n");
+	}
+
+	zbud_destroy_pool(zpool->pool);
+	kfree(zpool);
+}
+
+/* return pool id */
+static int zcache_create_pool(void)
+{
+	int ret;
+	struct zcache_pool *zpool;
+
+	zpool = kzalloc(sizeof(*zpool), GFP_KERNEL);
+	if (!zpool) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	zpool->pool = zbud_create_pool(GFP_KERNEL, &zcache_cleancache_zbud_ops);
+	if (!zpool->pool) {
+		kfree(zpool);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	spin_lock(&zcache.pool_lock);
+	if (zcache.num_pools == MAX_ZCACHE_POOLS) {
+		pr_info("Cannot create new pool (limit: %u)\n",
+					MAX_ZCACHE_POOLS);
+		zbud_destroy_pool(zpool->pool);
+		kfree(zpool);
+		ret = -EPERM;
+		goto out_unlock;
+	}
+
+	rwlock_init(&zpool->rb_lock);
+	zpool->rb_root = RB_ROOT;
+
+	/* Add to pool list */
+	for (ret = 0; ret < MAX_ZCACHE_POOLS; ret++)
+		if (!zcache.pools[ret])
+			break;
+	zcache.pools[ret] = zpool;
+	zcache.num_pools++;
+	pr_info("New pool created id:%d\n", ret);
+
+out_unlock:
+	spin_unlock(&zcache.pool_lock);
+out:
+	return ret;
+}
+
+static int zcache_cleancache_init_fs(size_t pagesize)
+{
+	int ret;
+
+	if (pagesize != PAGE_SIZE) {
+		pr_info("Unsupported page size: %zu", pagesize);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = zcache_create_pool();
+	if (ret < 0) {
+		pr_info("Failed to create new pool\n");
+		ret = -ENOMEM;
+		goto out;
+	}
+
+out:
+	return ret;
+}
+
+static int zcache_cleancache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	/* shared pools are unsupported and map to private */
+	return zcache_cleancache_init_fs(pagesize);
+}
+
+static struct cleancache_ops zcache_cleancache_ops = {
+	.put_page = zcache_cleancache_store_page,
+	.get_page = zcache_cleancache_load_page,
+	.invalidate_page = zcache_cleancache_flush_page,
+	.invalidate_inode = zcache_cleancache_flush_inode,
+	.invalidate_fs = zcache_cleancache_flush_fs,
+	.init_shared_fs = zcache_cleancache_init_shared_fs,
+	.init_fs = zcache_cleancache_init_fs
+};
+
+/*********************************
+* debugfs functions
+**********************************/
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+
+static struct dentry *zcache_cleancache_debugfs_root;
+
+static int __init zcache_debugfs_init(void)
+{
+	if (!debugfs_initialized())
+		return -ENODEV;
+
+	if (!zcache_nocleancache) {
+		zcache_cleancache_debugfs_root =
debugfs_create_dir("zcache_cleancache", NULL);
+		if (!zcache_cleancache_debugfs_root)
+			return -ENOMEM;
+
+		debugfs_create_u64("pool_limit_hit", S_IRUGO,
+				zcache_cleancache_debugfs_root, &zcache_cleancache_pool_limit_hit);
+		debugfs_create_u64("reclaim_fail", S_IRUGO,
+				zcache_cleancache_debugfs_root, &zcache_cleancache_reclaim_fail);
+		debugfs_create_u64("reject_alloc_fail", S_IRUGO,
+				zcache_cleancache_debugfs_root, &zcache_cleancache_zbud_alloc_fail);
+		debugfs_create_u64("written_back_pages", S_IRUGO,
+				zcache_cleancache_debugfs_root, &zcache_cleancache_written_back_pages);
+		debugfs_create_u64("duplicate_entry", S_IRUGO,
+				zcache_cleancache_debugfs_root, &zcache_cleancache_dup_entry);
+		debugfs_create_u64("pool_pages", S_IRUGO,
+				zcache_cleancache_debugfs_root, &zcache_cleancache_pool_pages);
+		debugfs_create_atomic_t("stored_pages", S_IRUGO,
+				zcache_cleancache_debugfs_root, &zcache_cleancache_stored_pages);
+	}
+	return 0;
+}
+
+static void __exit zcache_debugfs_exit(void)
+{
+	debugfs_remove_recursive(zcache_cleancache_debugfs_root);
+}
+#else
+static int __init zcache_debugfs_init(void)
+{
+	return 0;
+}
+static void __exit zcache_debugfs_exit(void)
+{
+}
+#endif
+
+/*********************************
+* module init and exit
+**********************************/
+static int __init init_zcache(void)
+{
+	if (!zcache_enabled)
+		return 0;
+
+	pr_info("loading zcache..\n");
+	if (!zcache_nocleancache)
+		if (zcache_cleancache_entry_cache_create()) {
+			pr_err("entry cache creation failed\n");
+			goto error;
+		}
+
+	if (zcache_comp_init()) {
+		pr_err("compressor initialization failed\n");
+		goto compfail;
+	}
+	if (zcache_cpu_init()) {
+		pr_err("per-cpu initialization failed\n");
+		goto pcpufail;
+	}
+
+	spin_lock_init(&zcache.pool_lock);
+	if (!zcache_nocleancache)
+		cleancache_register_ops(&zcache_cleancache_ops);
+
+	if (zcache_debugfs_init())
+		pr_warn("debugfs initialization failed\n");
+	return 0;
+pcpufail:
+	zcache_comp_exit();
+compfail:
+	zcache_cleancache_entry_cache_destory();
+error:
+	return -ENOMEM;
+}
+/* must be late so crypto has time to come up */
+late_initcall(init_zcache);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Bob Liu <bob.liu@oracle.com>");
+MODULE_DESCRIPTION("Compressed cache for clean file pages");
-- 
1.7.10.4


-- 
Regards,
-Bob


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
