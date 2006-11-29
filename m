Date: Tue, 28 Nov 2006 18:49:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Slab: Remove kmem_cache_t
Message-ID: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch replaces all uses of kmem_cache_t with struct kmem_cache.

The patch was generated using the following script:

#!/bin/sh

#
# Replace one string by another in all the kernel sources.
#

set -e

for file in `find * -name "*.c" -o -name "*.h"|xargs grep -l $1`; do
	quilt add $file
	sed -e "1,\$s/$1/$2/g" $file >/tmp/$$
	mv /tmp/$$ $file
	quilt refresh
done


The script was run like this

	sh replace kmem_cache_t "struct kmem_cache"

and then include/linux/slab.h was edited to remove the definition of
kmem_cache_t.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/arch/sh/mm/pmb.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/sh/mm/pmb.c	2006-11-28 18:34:17.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/sh/mm/pmb.c	2006-11-28 18:34:17.000000000 -0800
@@ -30,7 +30,7 @@
 
 #define NR_PMB_ENTRIES	16
 
-static kmem_cache_t *pmb_cache;
+static struct kmem_cache *pmb_cache;
 static unsigned long pmb_map;
 
 static struct pmb_entry pmb_init_map[] = {
@@ -283,7 +283,7 @@
 	} while (pmbe);
 }
 
-static void pmb_cache_ctor(void *pmb, kmem_cache_t *cachep, unsigned long flags)
+static void pmb_cache_ctor(void *pmb, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct pmb_entry *pmbe = pmb;
 
@@ -297,7 +297,7 @@
 	spin_unlock_irq(&pmb_list_lock);
 }
 
-static void pmb_cache_dtor(void *pmb, kmem_cache_t *cachep, unsigned long flags)
+static void pmb_cache_dtor(void *pmb, struct kmem_cache *cachep, unsigned long flags)
 {
 	spin_lock_irq(&pmb_list_lock);
 	pmb_list_del(pmb);
Index: linux-2.6.19-rc6-mm1/arch/sh/kernel/cpu/sh4/sq.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/sh/kernel/cpu/sh4/sq.c	2006-11-28 18:34:17.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/sh/kernel/cpu/sh4/sq.c	2006-11-28 18:34:17.000000000 -0800
@@ -38,7 +38,7 @@
 
 static struct sq_mapping *sq_mapping_list;
 static DEFINE_SPINLOCK(sq_mapping_lock);
-static kmem_cache_t *sq_cache;
+static struct kmem_cache *sq_cache;
 static unsigned long *sq_bitmap;
 
 #define store_queue_barrier()			\
Index: linux-2.6.19-rc6-mm1/arch/arm/mach-s3c2410/dma.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/arm/mach-s3c2410/dma.c	2006-11-28 18:34:17.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/arm/mach-s3c2410/dma.c	2006-11-28 18:34:17.000000000 -0800
@@ -40,7 +40,7 @@
 
 /* io map for dma */
 static void __iomem *dma_base;
-static kmem_cache_t *dma_kmem;
+static struct kmem_cache *dma_kmem;
 
 struct s3c24xx_dma_selection dma_sel;
 
@@ -1271,7 +1271,7 @@
 
 /* kmem cache implementation */
 
-static void s3c2410_dma_cache_ctor(void *p, kmem_cache_t *c, unsigned long f)
+static void s3c2410_dma_cache_ctor(void *p, struct kmem_cache *c, unsigned long f)
 {
 	memset(p, 0, sizeof(struct s3c2410_dma_buf));
 }
Index: linux-2.6.19-rc6-mm1/arch/frv/mm/pgalloc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/frv/mm/pgalloc.c	2006-11-28 18:34:18.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/frv/mm/pgalloc.c	2006-11-28 18:34:18.000000000 -0800
@@ -18,7 +18,7 @@
 #include <asm/cacheflush.h>
 
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((aligned(PAGE_SIZE)));
-kmem_cache_t *pgd_cache;
+struct kmem_cache *pgd_cache;
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
@@ -100,7 +100,7 @@
 		set_page_private(next, (unsigned long) pprev);
 }
 
-void pgd_ctor(void *pgd, kmem_cache_t *cache, unsigned long unused)
+void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
 {
 	unsigned long flags;
 
@@ -120,7 +120,7 @@
 }
 
 /* never called when PTRS_PER_PMD > 1 */
-void pgd_dtor(void *pgd, kmem_cache_t *cache, unsigned long unused)
+void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
 {
 	unsigned long flags; /* can be called from interrupt context */
 
Index: linux-2.6.19-rc6-mm1/arch/i386/mm/init.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/i386/mm/init.c	2006-11-28 18:34:18.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/i386/mm/init.c	2006-11-28 18:34:18.000000000 -0800
@@ -699,8 +699,8 @@
 #endif
 #endif
 
-kmem_cache_t *pgd_cache;
-kmem_cache_t *pmd_cache;
+struct kmem_cache *pgd_cache;
+struct kmem_cache *pmd_cache;
 
 void __init pgtable_cache_init(void)
 {
Index: linux-2.6.19-rc6-mm1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/i386/mm/pgtable.c	2006-11-28 18:34:18.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/i386/mm/pgtable.c	2006-11-28 18:34:18.000000000 -0800
@@ -196,7 +196,7 @@
 	return pte;
 }
 
-void pmd_ctor(void *pmd, kmem_cache_t *cache, unsigned long flags)
+void pmd_ctor(void *pmd, struct kmem_cache *cache, unsigned long flags)
 {
 	memset(pmd, 0, PTRS_PER_PMD*sizeof(pmd_t));
 }
@@ -236,7 +236,7 @@
 		set_page_private(next, (unsigned long)pprev);
 }
 
-void pgd_ctor(void *pgd, kmem_cache_t *cache, unsigned long unused)
+void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
 {
 	unsigned long flags;
 
@@ -256,7 +256,7 @@
 }
 
 /* never called when PTRS_PER_PMD > 1 */
-void pgd_dtor(void *pgd, kmem_cache_t *cache, unsigned long unused)
+void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
 {
 	unsigned long flags; /* can be called from interrupt context */
 
Index: linux-2.6.19-rc6-mm1/arch/ia64/ia32/sys_ia32.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/ia64/ia32/sys_ia32.c	2006-11-28 18:34:18.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/ia64/ia32/sys_ia32.c	2006-11-28 18:34:18.000000000 -0800
@@ -254,7 +254,7 @@
 }
 
 /* SLAB cache for partial_page structures */
-kmem_cache_t *partial_page_cachep;
+struct kmem_cache *partial_page_cachep;
 
 /*
  * init partial_page_list.
Index: linux-2.6.19-rc6-mm1/arch/ia64/ia32/ia32_support.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/ia64/ia32/ia32_support.c	2006-11-28 18:34:19.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/ia64/ia32/ia32_support.c	2006-11-28 18:34:19.000000000 -0800
@@ -249,7 +249,7 @@
 
 #if PAGE_SHIFT > IA32_PAGE_SHIFT
 	{
-		extern kmem_cache_t *partial_page_cachep;
+		extern struct kmem_cache *partial_page_cachep;
 
 		partial_page_cachep = kmem_cache_create("partial_page_cache",
 							sizeof(struct partial_page), 0, 0,
Index: linux-2.6.19-rc6-mm1/arch/arm26/mm/memc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/arm26/mm/memc.c	2006-11-28 18:34:19.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/arm26/mm/memc.c	2006-11-28 18:34:19.000000000 -0800
@@ -24,7 +24,7 @@
 
 #define MEMC_TABLE_SIZE (256*sizeof(unsigned long))
 
-kmem_cache_t *pte_cache, *pgd_cache;
+struct kmem_cache *pte_cache, *pgd_cache;
 int page_nr;
 
 /*
@@ -162,12 +162,12 @@
 {
 }
 
-static void pte_cache_ctor(void *pte, kmem_cache_t *cache, unsigned long flags)
+static void pte_cache_ctor(void *pte, struct kmem_cache *cache, unsigned long flags)
 {
 	memzero(pte, sizeof(pte_t) * PTRS_PER_PTE);
 }
 
-static void pgd_cache_ctor(void *pgd, kmem_cache_t *cache, unsigned long flags)
+static void pgd_cache_ctor(void *pgd, struct kmem_cache *cache, unsigned long flags)
 {
 	memzero(pgd + MEMC_TABLE_SIZE, USER_PTRS_PER_PGD * sizeof(pgd_t));
 }
Index: linux-2.6.19-rc6-mm1/arch/sparc64/mm/tsb.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/sparc64/mm/tsb.c	2006-11-28 18:34:19.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/sparc64/mm/tsb.c	2006-11-28 18:34:19.000000000 -0800
@@ -239,7 +239,7 @@
 	}
 }
 
-static kmem_cache_t *tsb_caches[8] __read_mostly;
+static struct kmem_cache *tsb_caches[8] __read_mostly;
 
 static const char *tsb_cache_names[8] = {
 	"tsb_8KB",
Index: linux-2.6.19-rc6-mm1/arch/sparc64/mm/init.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/sparc64/mm/init.c	2006-11-28 18:34:20.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/sparc64/mm/init.c	2006-11-28 18:34:20.000000000 -0800
@@ -176,9 +176,9 @@
 
 int bigkernel = 0;
 
-kmem_cache_t *pgtable_cache __read_mostly;
+struct kmem_cache *pgtable_cache __read_mostly;
 
-static void zero_ctor(void *addr, kmem_cache_t *cache, unsigned long flags)
+static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
 {
 	clear_page(addr);
 }
Index: linux-2.6.19-rc6-mm1/arch/powerpc/mm/init_64.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/powerpc/mm/init_64.c	2006-11-28 18:34:20.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/powerpc/mm/init_64.c	2006-11-28 18:34:20.000000000 -0800
@@ -141,7 +141,7 @@
 }
 module_init(setup_kcore);
 
-static void zero_ctor(void *addr, kmem_cache_t *cache, unsigned long flags)
+static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
 {
 	memset(addr, 0, kmem_cache_size(cache));
 }
@@ -166,9 +166,9 @@
 /* Hugepages need one extra cache, initialized in hugetlbpage.c.  We
  * can't put into the tables above, because HPAGE_SHIFT is not compile
  * time constant. */
-kmem_cache_t *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)+1];
+struct kmem_cache *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)+1];
 #else
-kmem_cache_t *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)];
+struct kmem_cache *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)];
 #endif
 
 void pgtable_cache_init(void)
Index: linux-2.6.19-rc6-mm1/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/powerpc/mm/hugetlbpage.c	2006-11-28 18:34:20.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/powerpc/mm/hugetlbpage.c	2006-11-28 18:34:20.000000000 -0800
@@ -1047,7 +1047,7 @@
 	return err;
 }
 
-static void zero_ctor(void *addr, kmem_cache_t *cache, unsigned long flags)
+static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
 {
 	memset(addr, 0, kmem_cache_size(cache));
 }
Index: linux-2.6.19-rc6-mm1/arch/powerpc/platforms/cell/spufs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/powerpc/platforms/cell/spufs/inode.c	2006-11-28 18:34:21.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/powerpc/platforms/cell/spufs/inode.c	2006-11-28 18:34:21.000000000 -0800
@@ -40,7 +40,7 @@
 
 #include "spufs.h"
 
-static kmem_cache_t *spufs_inode_cache;
+static struct kmem_cache *spufs_inode_cache;
 char *isolated_loader;
 
 static struct inode *
@@ -65,7 +65,7 @@
 }
 
 static void
-spufs_init_once(void *p, kmem_cache_t * cachep, unsigned long flags)
+spufs_init_once(void *p, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct spufs_inode_info *ei = p;
 
Index: linux-2.6.19-rc6-mm1/arch/powerpc/kernel/rtas_flash.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/arch/powerpc/kernel/rtas_flash.c	2006-11-28 18:34:21.000000000 -0800
+++ linux-2.6.19-rc6-mm1/arch/powerpc/kernel/rtas_flash.c	2006-11-28 18:34:21.000000000 -0800
@@ -101,7 +101,7 @@
 static struct flash_block_list_header rtas_firmware_flash_list = {0, NULL};
 
 /* Use slab cache to guarantee 4k alignment */
-static kmem_cache_t *flash_block_cache = NULL;
+static struct kmem_cache *flash_block_cache = NULL;
 
 #define FLASH_BLOCK_LIST_VERSION (1UL)
 
@@ -286,7 +286,7 @@
 }
 
 /* constructor for flash_block_cache */
-void rtas_block_ctor(void *ptr, kmem_cache_t *cache, unsigned long flags)
+void rtas_block_ctor(void *ptr, struct kmem_cache *cache, unsigned long flags)
 {
 	memset(ptr, 0, RTAS_BLK_SIZE);
 }
Index: linux-2.6.19-rc6-mm1/block/ll_rw_blk.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/block/ll_rw_blk.c	2006-11-28 18:34:21.000000000 -0800
+++ linux-2.6.19-rc6-mm1/block/ll_rw_blk.c	2006-11-28 18:34:21.000000000 -0800
@@ -46,17 +46,17 @@
 /*
  * For the allocated request tables
  */
-static kmem_cache_t *request_cachep;
+static struct kmem_cache *request_cachep;
 
 /*
  * For queue allocation
  */
-static kmem_cache_t *requestq_cachep;
+static struct kmem_cache *requestq_cachep;
 
 /*
  * For io context allocations
  */
-static kmem_cache_t *iocontext_cachep;
+static struct kmem_cache *iocontext_cachep;
 
 /*
  * Controlling structure to kblockd
Index: linux-2.6.19-rc6-mm1/block/cfq-iosched.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/block/cfq-iosched.c	2006-11-28 18:34:22.000000000 -0800
+++ linux-2.6.19-rc6-mm1/block/cfq-iosched.c	2006-11-28 18:34:22.000000000 -0800
@@ -43,8 +43,8 @@
 #define RQ_CIC(rq)		((struct cfq_io_context*)(rq)->elevator_private)
 #define RQ_CFQQ(rq)		((rq)->elevator_private2)
 
-static kmem_cache_t *cfq_pool;
-static kmem_cache_t *cfq_ioc_pool;
+static struct kmem_cache *cfq_pool;
+static struct kmem_cache *cfq_ioc_pool;
 
 static DEFINE_PER_CPU(unsigned long, ioc_count);
 static struct completion *ioc_gone;
Index: linux-2.6.19-rc6-mm1/drivers/md/dm.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/md/dm.c	2006-11-28 18:34:22.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/md/dm.c	2006-11-28 18:34:22.000000000 -0800
@@ -124,8 +124,8 @@
 };
 
 #define MIN_IOS 256
-static kmem_cache_t *_io_cache;
-static kmem_cache_t *_tio_cache;
+static struct kmem_cache *_io_cache;
+static struct kmem_cache *_tio_cache;
 
 static int __init local_init(void)
 {
Index: linux-2.6.19-rc6-mm1/drivers/md/dm-crypt.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/md/dm-crypt.c	2006-11-28 18:34:23.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/md/dm-crypt.c	2006-11-28 18:34:23.000000000 -0800
@@ -102,7 +102,7 @@
 #define MIN_POOL_PAGES 32
 #define MIN_BIO_PAGES  8
 
-static kmem_cache_t *_crypt_io_pool;
+static struct kmem_cache *_crypt_io_pool;
 
 /*
  * Different IV generation algorithms:
Index: linux-2.6.19-rc6-mm1/drivers/md/raid5.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/md/raid5.c	2006-11-28 18:34:23.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/md/raid5.c	2006-11-28 18:34:23.000000000 -0800
@@ -350,7 +350,7 @@
 
 static int grow_stripes(raid5_conf_t *conf, int num)
 {
-	kmem_cache_t *sc;
+	struct kmem_cache *sc;
 	int devs = conf->raid_disks;
 
 	sprintf(conf->cache_name[0], "raid5/%s", mdname(conf->mddev));
@@ -399,7 +399,7 @@
 	LIST_HEAD(newstripes);
 	struct disk_info *ndisks;
 	int err = 0;
-	kmem_cache_t *sc;
+	struct kmem_cache *sc;
 	int i;
 
 	if (newsize <= conf->pool_size)
Index: linux-2.6.19-rc6-mm1/drivers/md/dm-snap.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/md/dm-snap.c	2006-11-28 18:34:23.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/md/dm-snap.c	2006-11-28 18:34:23.000000000 -0800
@@ -88,8 +88,8 @@
  * Hash table mapping origin volumes to lists of snapshots and
  * a lock to protect it
  */
-static kmem_cache_t *exception_cache;
-static kmem_cache_t *pending_cache;
+static struct kmem_cache *exception_cache;
+static struct kmem_cache *pending_cache;
 static mempool_t *pending_pool;
 
 /*
@@ -228,7 +228,7 @@
 	return 0;
 }
 
-static void exit_exception_table(struct exception_table *et, kmem_cache_t *mem)
+static void exit_exception_table(struct exception_table *et, struct kmem_cache *mem)
 {
 	struct list_head *slot;
 	struct exception *ex, *next;
Index: linux-2.6.19-rc6-mm1/drivers/md/dm-mpath.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/md/dm-mpath.c	2006-11-28 18:34:24.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/md/dm-mpath.c	2006-11-28 18:34:24.000000000 -0800
@@ -101,7 +101,7 @@
 
 #define MIN_IOS 256	/* Mempool size */
 
-static kmem_cache_t *_mpio_cache;
+static struct kmem_cache *_mpio_cache;
 
 struct workqueue_struct *kmultipathd;
 static void process_queued_ios(void *data);
Index: linux-2.6.19-rc6-mm1/drivers/md/kcopyd.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/md/kcopyd.c	2006-11-28 18:34:24.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/md/kcopyd.c	2006-11-28 18:34:24.000000000 -0800
@@ -203,7 +203,7 @@
 /* FIXME: this should scale with the number of pages */
 #define MIN_JOBS 512
 
-static kmem_cache_t *_job_cache;
+static struct kmem_cache *_job_cache;
 static mempool_t *_job_pool;
 
 /*
Index: linux-2.6.19-rc6-mm1/drivers/pci/msi.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/pci/msi.c	2006-11-28 18:34:25.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/pci/msi.c	2006-11-28 18:34:25.000000000 -0800
@@ -26,7 +26,7 @@
 
 static DEFINE_SPINLOCK(msi_lock);
 static struct msi_desc* msi_desc[NR_IRQS] = { [0 ... NR_IRQS-1] = NULL };
-static kmem_cache_t* msi_cachep;
+static struct kmem_cache* msi_cachep;
 
 static int pci_msi_enable = 1;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/mon/mon_text.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/mon/mon_text.c	2006-11-28 18:34:25.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/mon/mon_text.c	2006-11-28 18:34:25.000000000 -0800
@@ -50,7 +50,7 @@
 
 #define SLAB_NAME_SZ  30
 struct mon_reader_text {
-	kmem_cache_t *e_slab;
+	struct kmem_cache *e_slab;
 	int nevents;
 	struct list_head e_list;
 	struct mon_reader r;	/* In C, parent class can be placed anywhere */
@@ -63,7 +63,7 @@
 	char slab_name[SLAB_NAME_SZ];
 };
 
-static void mon_text_ctor(void *, kmem_cache_t *, unsigned long);
+static void mon_text_ctor(void *, struct kmem_cache *, unsigned long);
 
 /*
  * mon_text_submit
@@ -450,7 +450,7 @@
 /*
  * Slab interface: constructor.
  */
-static void mon_text_ctor(void *mem, kmem_cache_t *slab, unsigned long sflags)
+static void mon_text_ctor(void *mem, struct kmem_cache *slab, unsigned long sflags)
 {
 	/*
 	 * Nothing to initialize. No, really!
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/uhci-hcd.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/uhci-hcd.c	2006-11-28 18:34:26.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/uhci-hcd.c	2006-11-28 18:34:26.000000000 -0800
@@ -81,7 +81,7 @@
 static char *errbuf;
 #define ERRBUF_LEN    (32 * 1024)
 
-static kmem_cache_t *uhci_up_cachep;	/* urb_priv */
+static struct kmem_cache *uhci_up_cachep;	/* urb_priv */
 
 static void suspend_rh(struct uhci_hcd *uhci, enum uhci_rh_state new_state);
 static void wakeup_rh(struct uhci_hcd *uhci);
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/hc_crisv10.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/hc_crisv10.c	2006-11-28 18:34:26.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/hc_crisv10.c	2006-11-28 18:34:26.000000000 -0800
@@ -275,13 +275,13 @@
 static int zout_buffer[4] __attribute__ ((aligned (4)));
 
 /* Cache for allocating new EP and SB descriptors. */
-static kmem_cache_t *usb_desc_cache;
+static struct kmem_cache *usb_desc_cache;
 
 /* Cache for the registers allocated in the top half. */
-static kmem_cache_t *top_half_reg_cache;
+static struct kmem_cache *top_half_reg_cache;
 
 /* Cache for the data allocated in the isoc descr top half. */
-static kmem_cache_t *isoc_compl_cache;
+static struct kmem_cache *isoc_compl_cache;
 
 static struct usb_bus *etrax_usb_bus;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/ehci.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/ehci.h	2006-11-28 18:34:27.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/ehci.h	2006-11-28 18:34:27.000000000 -0800
@@ -73,7 +73,7 @@
 	unsigned		periodic_sched;	/* periodic activity count */
 
 	char			poolname[20];	/* Shadow budget pool name */
-	kmem_cache_t		*budget_pool;	/* Pool for shadow budget */
+	struct kmem_cache		*budget_pool;	/* Pool for shadow budget */
 	struct ehci_shadow_budget **budget;	/* pointer to the shadow budget
 						   of bandwidth placeholders */
 
Index: linux-2.6.19-rc6-mm1/drivers/s390/scsi/zfcp_def.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/s390/scsi/zfcp_def.h	2006-11-28 18:34:27.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/s390/scsi/zfcp_def.h	2006-11-28 18:34:27.000000000 -0800
@@ -1055,9 +1055,9 @@
 	wwn_t                   init_wwpn;
 	fcp_lun_t               init_fcp_lun;
 	char 			*driver_version;
-	kmem_cache_t		*fsf_req_qtcb_cache;
-	kmem_cache_t		*sr_buffer_cache;
-	kmem_cache_t		*gid_pn_cache;
+	struct kmem_cache		*fsf_req_qtcb_cache;
+	struct kmem_cache		*sr_buffer_cache;
+	struct kmem_cache		*gid_pn_cache;
 };
 
 /**
Index: linux-2.6.19-rc6-mm1/drivers/s390/block/dasd_devmap.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/s390/block/dasd_devmap.c	2006-11-28 18:34:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/s390/block/dasd_devmap.c	2006-11-28 18:34:28.000000000 -0800
@@ -25,7 +25,7 @@
 
 #include "dasd_int.h"
 
-kmem_cache_t *dasd_page_cache;
+struct kmem_cache *dasd_page_cache;
 EXPORT_SYMBOL_GPL(dasd_page_cache);
 
 /*
Index: linux-2.6.19-rc6-mm1/drivers/s390/block/dasd_int.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/s390/block/dasd_int.h	2006-11-28 18:34:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/s390/block/dasd_int.h	2006-11-28 18:34:28.000000000 -0800
@@ -474,7 +474,7 @@
 extern unsigned int dasd_profile_level;
 extern struct block_device_operations dasd_device_operations;
 
-extern kmem_cache_t *dasd_page_cache;
+extern struct kmem_cache *dasd_page_cache;
 
 struct dasd_ccw_req *
 dasd_kmalloc_request(char *, int, int, struct dasd_device *);
Index: linux-2.6.19-rc6-mm1/drivers/scsi/qla2xxx/qla_os.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/qla2xxx/qla_os.c	2006-11-28 18:34:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/qla2xxx/qla_os.c	2006-11-28 18:34:29.000000000 -0800
@@ -24,7 +24,7 @@
 /*
  * SRB allocation cache
  */
-static kmem_cache_t *srb_cachep;
+static struct kmem_cache *srb_cachep;
 
 /*
  * Ioctl related information.
Index: linux-2.6.19-rc6-mm1/drivers/scsi/qla4xxx/ql4_os.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/qla4xxx/ql4_os.c	2006-11-28 18:34:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/qla4xxx/ql4_os.c	2006-11-28 18:34:29.000000000 -0800
@@ -19,7 +19,7 @@
 /*
  * SRB allocation cache
  */
-static kmem_cache_t *srb_cachep;
+static struct kmem_cache *srb_cachep;
 
 /*
  * Module parameter information and variables
Index: linux-2.6.19-rc6-mm1/drivers/scsi/scsi_lib.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/scsi_lib.c	2006-11-28 18:34:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/scsi_lib.c	2006-11-28 18:34:30.000000000 -0800
@@ -36,7 +36,7 @@
 struct scsi_host_sg_pool {
 	size_t		size;
 	char		*name; 
-	kmem_cache_t	*slab;
+	struct kmem_cache	*slab;
 	mempool_t	*pool;
 };
 
@@ -241,7 +241,7 @@
 	char sense[SCSI_SENSE_BUFFERSIZE];
 };
 
-static kmem_cache_t *scsi_io_context_cache;
+static struct kmem_cache *scsi_io_context_cache;
 
 static void scsi_end_async(struct request *req, int uptodate)
 {
Index: linux-2.6.19-rc6-mm1/drivers/scsi/libsas/sas_init.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/libsas/sas_init.c	2006-11-28 18:34:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/libsas/sas_init.c	2006-11-28 18:34:30.000000000 -0800
@@ -36,7 +36,7 @@
 
 #include "../scsi_sas_internal.h"
 
-kmem_cache_t *sas_task_cache;
+struct kmem_cache *sas_task_cache;
 
 /*------------ SAS addr hash -----------*/
 void sas_hash_addr(u8 *hashed, const u8 *sas_addr)
Index: linux-2.6.19-rc6-mm1/drivers/scsi/aic94xx/aic94xx.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/aic94xx/aic94xx.h	2006-11-28 18:34:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/aic94xx/aic94xx.h	2006-11-28 18:34:31.000000000 -0800
@@ -56,8 +56,8 @@
 /* 2*ITNL timeout + 1 second */
 #define AIC94XX_SCB_TIMEOUT  (5*HZ)
 
-extern kmem_cache_t *asd_dma_token_cache;
-extern kmem_cache_t *asd_ascb_cache;
+extern struct kmem_cache *asd_dma_token_cache;
+extern struct kmem_cache *asd_ascb_cache;
 extern char sas_addr_str[2*SAS_ADDR_SIZE + 1];
 
 static inline void asd_stringify_sas_addr(char *p, const u8 *sas_addr)
Index: linux-2.6.19-rc6-mm1/drivers/scsi/aic94xx/aic94xx_init.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/aic94xx/aic94xx_init.c	2006-11-28 18:34:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/aic94xx/aic94xx_init.c	2006-11-28 18:34:32.000000000 -0800
@@ -453,8 +453,8 @@
 	asd_ha->scb_pool = NULL;
 }
 
-kmem_cache_t *asd_dma_token_cache;
-kmem_cache_t *asd_ascb_cache;
+struct kmem_cache *asd_dma_token_cache;
+struct kmem_cache *asd_ascb_cache;
 
 static int asd_create_global_caches(void)
 {
Index: linux-2.6.19-rc6-mm1/drivers/scsi/aic94xx/aic94xx_hwi.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/aic94xx/aic94xx_hwi.c	2006-11-28 18:34:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/aic94xx/aic94xx_hwi.c	2006-11-28 18:34:32.000000000 -0800
@@ -1047,7 +1047,7 @@
 static inline struct asd_ascb *asd_ascb_alloc(struct asd_ha_struct *asd_ha,
 					      gfp_t gfp_flags)
 {
-	extern kmem_cache_t *asd_ascb_cache;
+	extern struct kmem_cache *asd_ascb_cache;
 	struct asd_seq_data *seq = &asd_ha->seq;
 	struct asd_ascb *ascb;
 	unsigned long flags;
Index: linux-2.6.19-rc6-mm1/drivers/scsi/scsi.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/scsi.c	2006-11-28 18:34:33.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/scsi.c	2006-11-28 18:34:33.000000000 -0800
@@ -136,7 +136,7 @@
 EXPORT_SYMBOL(scsi_device_type);
 
 struct scsi_host_cmd_pool {
-	kmem_cache_t	*slab;
+	struct kmem_cache	*slab;
 	unsigned int	users;
 	char		*name;
 	unsigned int	slab_flags;
Index: linux-2.6.19-rc6-mm1/drivers/scsi/scsi_tgt_lib.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/scsi/scsi_tgt_lib.c	2006-11-28 18:34:34.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/scsi/scsi_tgt_lib.c	2006-11-28 18:34:34.000000000 -0800
@@ -33,7 +33,7 @@
 #include "scsi_tgt_priv.h"
 
 static struct workqueue_struct *scsi_tgtd;
-static kmem_cache_t *scsi_tgt_cmd_cache;
+static struct kmem_cache *scsi_tgt_cmd_cache;
 
 /*
  * TODO: this struct will be killed when the block layer supports large bios
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/amso1100/c2.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/amso1100/c2.h	2006-11-28 18:34:34.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/amso1100/c2.h	2006-11-28 18:34:34.000000000 -0800
@@ -302,7 +302,7 @@
 	unsigned long pa;	/* PA device memory */
 	void **qptr_array;
 
-	kmem_cache_t *host_msg_cache;
+	struct kmem_cache *host_msg_cache;
 
 	struct list_head cca_link;		/* adapter list */
 	struct list_head eh_wakeup_list;	/* event wakeup list */
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/ulp/iser/iscsi_iser.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/ulp/iser/iscsi_iser.h	2006-11-28 18:34:35.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/ulp/iser/iscsi_iser.h	2006-11-28 18:34:35.000000000 -0800
@@ -283,7 +283,7 @@
 	struct mutex      connlist_mutex;
 	struct list_head  connlist;		/* all iSER IB connections */
 
-	kmem_cache_t *desc_cache;
+	struct kmem_cache *desc_cache;
 };
 
 extern struct iser_global ig;
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/core/mad.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/core/mad.c	2006-11-28 18:34:36.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/core/mad.c	2006-11-28 18:34:36.000000000 -0800
@@ -46,7 +46,7 @@
 MODULE_AUTHOR("Hal Rosenstock");
 MODULE_AUTHOR("Sean Hefty");
 
-static kmem_cache_t *ib_mad_cache;
+static struct kmem_cache *ib_mad_cache;
 
 static struct list_head ib_mad_port_list;
 static u32 ib_mad_client_id = 0;
Index: linux-2.6.19-rc6-mm1/drivers/block/aoe/aoeblk.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/block/aoe/aoeblk.c	2006-11-28 18:34:36.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/block/aoe/aoeblk.c	2006-11-28 18:34:36.000000000 -0800
@@ -12,7 +12,7 @@
 #include <linux/netdevice.h>
 #include "aoe.h"
 
-static kmem_cache_t *buf_pool_cache;
+static struct kmem_cache *buf_pool_cache;
 
 static ssize_t aoedisk_show_state(struct gendisk * disk, char *page)
 {
Index: linux-2.6.19-rc6-mm1/drivers/message/i2o/i2o_block.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/message/i2o/i2o_block.h	2006-11-28 18:34:37.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/message/i2o/i2o_block.h	2006-11-28 18:34:37.000000000 -0800
@@ -64,7 +64,7 @@
 
 /* I2O Block OSM mempool struct */
 struct i2o_block_mempool {
-	kmem_cache_t *slab;
+	struct kmem_cache *slab;
 	mempool_t *pool;
 };
 
Index: linux-2.6.19-rc6-mm1/drivers/ieee1394/eth1394.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/ieee1394/eth1394.c	2006-11-28 18:34:38.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/ieee1394/eth1394.c	2006-11-28 18:34:38.000000000 -0800
@@ -133,7 +133,7 @@
 #define ETH1394_DRIVER_NAME "eth1394"
 static const char driver_name[] = ETH1394_DRIVER_NAME;
 
-static kmem_cache_t *packet_task_cache;
+static struct kmem_cache *packet_task_cache;
 
 static struct hpsb_highlevel eth1394_highlevel;
 
Index: linux-2.6.19-rc6-mm1/fs/afs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/afs/super.c	2006-11-28 18:34:39.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/afs/super.c	2006-11-28 18:34:39.000000000 -0800
@@ -35,7 +35,7 @@
 	struct afs_volume	*volume;
 };
 
-static void afs_i_init_once(void *foo, kmem_cache_t *cachep,
+static void afs_i_init_once(void *foo, struct kmem_cache *cachep,
 			    unsigned long flags);
 
 static int afs_get_sb(struct file_system_type *fs_type,
@@ -65,7 +65,7 @@
 	.put_super	= afs_put_super,
 };
 
-static kmem_cache_t *afs_inode_cachep;
+static struct kmem_cache *afs_inode_cachep;
 static atomic_t afs_count_active_inodes;
 
 /*****************************************************************************/
@@ -384,7 +384,7 @@
 /*
  * initialise an inode cache slab element prior to any use
  */
-static void afs_i_init_once(void *_vnode, kmem_cache_t *cachep,
+static void afs_i_init_once(void *_vnode, struct kmem_cache *cachep,
 			    unsigned long flags)
 {
 	struct afs_vnode *vnode = (struct afs_vnode *) _vnode;
Index: linux-2.6.19-rc6-mm1/fs/bfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/bfs/inode.c	2006-11-28 18:34:39.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/bfs/inode.c	2006-11-28 18:34:39.000000000 -0800
@@ -228,7 +228,7 @@
 	unlock_kernel();
 }
 
-static kmem_cache_t * bfs_inode_cachep;
+static struct kmem_cache * bfs_inode_cachep;
 
 static struct inode *bfs_alloc_inode(struct super_block *sb)
 {
@@ -244,7 +244,7 @@
 	kmem_cache_free(bfs_inode_cachep, BFS_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct bfs_inode_info *bi = foo;
 
Index: linux-2.6.19-rc6-mm1/fs/dlm/lowcomms-tcp.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/dlm/lowcomms-tcp.c	2006-11-28 18:34:40.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/dlm/lowcomms-tcp.c	2006-11-28 18:34:40.000000000 -0800
@@ -128,7 +128,7 @@
 /* An array of pointers to connections, indexed by NODEID */
 static struct connection **connections;
 static struct semaphore connections_lock;
-static kmem_cache_t *con_cache;
+static struct kmem_cache *con_cache;
 static int conn_array_size;
 static atomic_t accepting;
 
Index: linux-2.6.19-rc6-mm1/fs/dlm/memory.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/dlm/memory.c	2006-11-28 18:34:41.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/dlm/memory.c	2006-11-28 18:34:41.000000000 -0800
@@ -15,7 +15,7 @@
 #include "config.h"
 #include "memory.h"
 
-static kmem_cache_t *lkb_cache;
+static struct kmem_cache *lkb_cache;
 
 
 int dlm_memory_init(void)
Index: linux-2.6.19-rc6-mm1/fs/efs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/efs/super.c	2006-11-28 18:34:42.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/efs/super.c	2006-11-28 18:34:42.000000000 -0800
@@ -52,7 +52,7 @@
 };
 
 
-static kmem_cache_t * efs_inode_cachep;
+static struct kmem_cache * efs_inode_cachep;
 
 static struct inode *efs_alloc_inode(struct super_block *sb)
 {
@@ -68,7 +68,7 @@
 	kmem_cache_free(efs_inode_cachep, INODE_INFO(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct efs_inode_info *ei = (struct efs_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/fat/cache.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fat/cache.c	2006-11-28 18:34:42.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fat/cache.c	2006-11-28 18:34:42.000000000 -0800
@@ -34,9 +34,9 @@
 	return FAT_MAX_CACHE;
 }
 
-static kmem_cache_t *fat_cache_cachep;
+static struct kmem_cache *fat_cache_cachep;
 
-static void init_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct fat_cache *cache = (struct fat_cache *)foo;
 
Index: linux-2.6.19-rc6-mm1/fs/fat/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fat/inode.c	2006-11-28 18:34:43.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fat/inode.c	2006-11-28 18:34:43.000000000 -0800
@@ -477,7 +477,7 @@
 	kfree(sbi);
 }
 
-static kmem_cache_t *fat_inode_cachep;
+static struct kmem_cache *fat_inode_cachep;
 
 static struct inode *fat_alloc_inode(struct super_block *sb)
 {
@@ -493,7 +493,7 @@
 	kmem_cache_free(fat_inode_cachep, MSDOS_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct msdos_inode_info *ei = (struct msdos_inode_info *)foo;
 
Index: linux-2.6.19-rc6-mm1/fs/hfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/hfs/super.c	2006-11-28 18:34:44.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/hfs/super.c	2006-11-28 18:34:44.000000000 -0800
@@ -24,7 +24,7 @@
 #include "hfs_fs.h"
 #include "btree.h"
 
-static kmem_cache_t *hfs_inode_cachep;
+static struct kmem_cache *hfs_inode_cachep;
 
 MODULE_LICENSE("GPL");
 
@@ -430,7 +430,7 @@
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void hfs_init_once(void *p, kmem_cache_t *cachep, unsigned long flags)
+static void hfs_init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct hfs_inode_info *i = p;
 
Index: linux-2.6.19-rc6-mm1/fs/jbd/revoke.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jbd/revoke.c	2006-11-28 18:34:45.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jbd/revoke.c	2006-11-28 18:34:45.000000000 -0800
@@ -70,8 +70,8 @@
 #include <linux/init.h>
 #endif
 
-static kmem_cache_t *revoke_record_cache;
-static kmem_cache_t *revoke_table_cache;
+static struct kmem_cache *revoke_record_cache;
+static struct kmem_cache *revoke_table_cache;
 
 /* Each revoke record represents one single revoked block.  During
    journal replay, this involves recording the transaction ID of the
Index: linux-2.6.19-rc6-mm1/fs/jbd/journal.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jbd/journal.c	2006-11-28 18:34:46.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jbd/journal.c	2006-11-28 18:34:46.000000000 -0800
@@ -1630,7 +1630,7 @@
 #define JBD_MAX_SLABS 5
 #define JBD_SLAB_INDEX(size)  (size >> 11)
 
-static kmem_cache_t *jbd_slab[JBD_MAX_SLABS];
+static struct kmem_cache *jbd_slab[JBD_MAX_SLABS];
 static const char *jbd_slab_names[JBD_MAX_SLABS] = {
 	"jbd_1k", "jbd_2k", "jbd_4k", NULL, "jbd_8k"
 };
@@ -1693,7 +1693,7 @@
 /*
  * Journal_head storage management
  */
-static kmem_cache_t *journal_head_cache;
+static struct kmem_cache *journal_head_cache;
 #ifdef CONFIG_JBD_DEBUG
 static atomic_t nr_journal_heads = ATOMIC_INIT(0);
 #endif
@@ -2004,7 +2004,7 @@
 
 #endif
 
-kmem_cache_t *jbd_handle_cache;
+struct kmem_cache *jbd_handle_cache;
 
 static int __init journal_init_handle_cache(void)
 {
Index: linux-2.6.19-rc6-mm1/fs/jfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jfs/super.c	2006-11-28 18:34:46.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jfs/super.c	2006-11-28 18:34:46.000000000 -0800
@@ -44,7 +44,7 @@
 MODULE_AUTHOR("Steve Best/Dave Kleikamp/Barry Arndt, IBM");
 MODULE_LICENSE("GPL");
 
-static kmem_cache_t * jfs_inode_cachep;
+static struct kmem_cache * jfs_inode_cachep;
 
 static struct super_operations jfs_super_operations;
 static struct export_operations jfs_export_operations;
@@ -748,7 +748,7 @@
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void init_once(void *foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct jfs_inode_info *jfs_ip = (struct jfs_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/jfs/jfs_metapage.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jfs/jfs_metapage.c	2006-11-28 18:34:47.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jfs/jfs_metapage.c	2006-11-28 18:34:47.000000000 -0800
@@ -74,7 +74,7 @@
 }
 
 #define METAPOOL_MIN_PAGES 32
-static kmem_cache_t *metapage_cache;
+static struct kmem_cache *metapage_cache;
 static mempool_t *metapage_mempool;
 
 #define MPS_PER_PAGE (PAGE_CACHE_SIZE >> L2PSIZE)
@@ -180,7 +180,7 @@
 
 #endif
 
-static void init_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct metapage *mp = (struct metapage *)foo;
 
Index: linux-2.6.19-rc6-mm1/fs/nfs/direct.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/direct.c	2006-11-28 18:34:48.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/direct.c	2006-11-28 18:34:48.000000000 -0800
@@ -58,7 +58,7 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
-static kmem_cache_t *nfs_direct_cachep;
+static struct kmem_cache *nfs_direct_cachep;
 
 /*
  * This represents a set of asynchronous requests that we're waiting on
Index: linux-2.6.19-rc6-mm1/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/pagelist.c	2006-11-28 18:34:49.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/pagelist.c	2006-11-28 18:34:49.000000000 -0800
@@ -19,7 +19,7 @@
 #include <linux/nfs_mount.h>
 
 
-static kmem_cache_t *nfs_page_cachep;
+static struct kmem_cache *nfs_page_cachep;
 
 static inline struct nfs_page *
 nfs_page_alloc(void)
Index: linux-2.6.19-rc6-mm1/fs/nfs/read.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/read.c	2006-11-28 18:34:50.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/read.c	2006-11-28 18:34:50.000000000 -0800
@@ -38,7 +38,7 @@
 static const struct rpc_call_ops nfs_read_partial_ops;
 static const struct rpc_call_ops nfs_read_full_ops;
 
-static kmem_cache_t *nfs_rdata_cachep;
+static struct kmem_cache *nfs_rdata_cachep;
 static mempool_t *nfs_rdata_mempool;
 
 #define MIN_POOL_READ	(32)
Index: linux-2.6.19-rc6-mm1/fs/nfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/inode.c	2006-11-28 18:34:51.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/inode.c	2006-11-28 18:34:51.000000000 -0800
@@ -54,7 +54,7 @@
 
 static void nfs_zap_acl_cache(struct inode *);
 
-static kmem_cache_t * nfs_inode_cachep;
+static struct kmem_cache * nfs_inode_cachep;
 
 int nfs_write_inode(struct inode *inode, int sync)
 {
@@ -1101,7 +1101,7 @@
 #endif
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct nfs_inode *nfsi = (struct nfs_inode *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/nfs/write.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/write.c	2006-11-28 18:34:52.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/write.c	2006-11-28 18:34:52.000000000 -0800
@@ -85,7 +85,7 @@
 static const struct rpc_call_ops nfs_write_full_ops;
 static const struct rpc_call_ops nfs_commit_ops;
 
-static kmem_cache_t *nfs_wdata_cachep;
+static struct kmem_cache *nfs_wdata_cachep;
 static mempool_t *nfs_wdata_mempool;
 static mempool_t *nfs_commit_mempool;
 
Index: linux-2.6.19-rc6-mm1/fs/udf/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/udf/super.c	2006-11-28 18:34:52.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/udf/super.c	2006-11-28 18:34:52.000000000 -0800
@@ -107,7 +107,7 @@
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static kmem_cache_t * udf_inode_cachep;
+static struct kmem_cache * udf_inode_cachep;
 
 static struct inode *udf_alloc_inode(struct super_block *sb)
 {
@@ -130,7 +130,7 @@
 	kmem_cache_free(udf_inode_cachep, UDF_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct udf_inode_info *ei = (struct udf_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/ufs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ufs/super.c	2006-11-28 18:34:53.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ufs/super.c	2006-11-28 18:34:53.000000000 -0800
@@ -1204,7 +1204,7 @@
 	return 0;
 }
 
-static kmem_cache_t * ufs_inode_cachep;
+static struct kmem_cache * ufs_inode_cachep;
 
 static struct inode *ufs_alloc_inode(struct super_block *sb)
 {
@@ -1221,7 +1221,7 @@
 	kmem_cache_free(ufs_inode_cachep, UFS_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct ufs_inode_info *ei = (struct ufs_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/main.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/main.c	2006-11-28 18:34:54.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/main.c	2006-11-28 18:34:54.000000000 -0800
@@ -547,7 +547,7 @@
 }
 
 static struct ecryptfs_cache_info {
-	kmem_cache_t **cache;
+	struct kmem_cache **cache;
 	const char *name;
 	size_t size;
 	void (*ctor)(void*, struct kmem_cache *, unsigned long);
Index: linux-2.6.19-rc6-mm1/fs/adfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/adfs/super.c	2006-11-28 18:34:55.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/adfs/super.c	2006-11-28 18:34:55.000000000 -0800
@@ -212,7 +212,7 @@
 	return 0;
 }
 
-static kmem_cache_t *adfs_inode_cachep;
+static struct kmem_cache *adfs_inode_cachep;
 
 static struct inode *adfs_alloc_inode(struct super_block *sb)
 {
@@ -228,7 +228,7 @@
 	kmem_cache_free(adfs_inode_cachep, ADFS_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct adfs_inode_info *ei = (struct adfs_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/affs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/affs/super.c	2006-11-28 18:34:56.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/affs/super.c	2006-11-28 18:34:56.000000000 -0800
@@ -66,7 +66,7 @@
 	pr_debug("AFFS: write_super() at %lu, clean=%d\n", get_seconds(), clean);
 }
 
-static kmem_cache_t * affs_inode_cachep;
+static struct kmem_cache * affs_inode_cachep;
 
 static struct inode *affs_alloc_inode(struct super_block *sb)
 {
@@ -83,7 +83,7 @@
 	kmem_cache_free(affs_inode_cachep, AFFS_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct affs_inode_info *ei = (struct affs_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/befs/linuxvfs.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/befs/linuxvfs.c	2006-11-28 18:34:57.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/befs/linuxvfs.c	2006-11-28 18:34:57.000000000 -0800
@@ -61,7 +61,7 @@
 };
 
 /* slab cache for befs_inode_info objects */
-static kmem_cache_t *befs_inode_cachep;
+static struct kmem_cache *befs_inode_cachep;
 
 static const struct file_operations befs_dir_operations = {
 	.read		= generic_read_dir,
@@ -289,7 +289,7 @@
         kmem_cache_free(befs_inode_cachep, BEFS_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
         struct befs_inode_info *bi = (struct befs_inode_info *) foo;
 	
Index: linux-2.6.19-rc6-mm1/fs/cifs/cifsfs.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/cifs/cifsfs.c	2006-11-28 18:34:58.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/cifs/cifsfs.c	2006-11-28 18:34:58.000000000 -0800
@@ -82,7 +82,7 @@
 extern mempool_t *cifs_req_poolp;
 extern mempool_t *cifs_mid_poolp;
 
-extern kmem_cache_t *cifs_oplock_cachep;
+extern struct kmem_cache *cifs_oplock_cachep;
 
 static int
 cifs_read_super(struct super_block *sb, void *data,
@@ -233,11 +233,11 @@
 		return generic_permission(inode, mask, NULL);
 }
 
-static kmem_cache_t *cifs_inode_cachep;
-static kmem_cache_t *cifs_req_cachep;
-static kmem_cache_t *cifs_mid_cachep;
-kmem_cache_t *cifs_oplock_cachep;
-static kmem_cache_t *cifs_sm_req_cachep;
+static struct kmem_cache *cifs_inode_cachep;
+static struct kmem_cache *cifs_req_cachep;
+static struct kmem_cache *cifs_mid_cachep;
+struct kmem_cache *cifs_oplock_cachep;
+static struct kmem_cache *cifs_sm_req_cachep;
 mempool_t *cifs_sm_req_poolp;
 mempool_t *cifs_req_poolp;
 mempool_t *cifs_mid_poolp;
@@ -669,7 +669,7 @@
 };
 
 static void
-cifs_init_once(void *inode, kmem_cache_t * cachep, unsigned long flags)
+cifs_init_once(void *inode, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct cifsInodeInfo *cifsi = inode;
 
Index: linux-2.6.19-rc6-mm1/fs/cifs/transport.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/cifs/transport.c	2006-11-28 18:34:59.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/cifs/transport.c	2006-11-28 18:34:59.000000000 -0800
@@ -34,7 +34,7 @@
 #include "cifs_debug.h"
   
 extern mempool_t *cifs_mid_poolp;
-extern kmem_cache_t *cifs_oplock_cachep;
+extern struct kmem_cache *cifs_oplock_cachep;
 
 static struct mid_q_entry *
 AllocMidQEntry(const struct smb_hdr *smb_buffer, struct cifsSesInfo *ses)
Index: linux-2.6.19-rc6-mm1/fs/coda/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/coda/inode.c	2006-11-28 18:35:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/coda/inode.c	2006-11-28 18:35:00.000000000 -0800
@@ -38,7 +38,7 @@
 static void coda_put_super(struct super_block *);
 static int coda_statfs(struct dentry *dentry, struct kstatfs *buf);
 
-static kmem_cache_t * coda_inode_cachep;
+static struct kmem_cache * coda_inode_cachep;
 
 static struct inode *coda_alloc_inode(struct super_block *sb)
 {
@@ -58,7 +58,7 @@
 	kmem_cache_free(coda_inode_cachep, ITOC(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct coda_inode_info *ei = (struct coda_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/ext2/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ext2/super.c	2006-11-28 18:35:01.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ext2/super.c	2006-11-28 18:35:01.000000000 -0800
@@ -135,7 +135,7 @@
 	return;
 }
 
-static kmem_cache_t * ext2_inode_cachep;
+static struct kmem_cache * ext2_inode_cachep;
 
 static struct inode *ext2_alloc_inode(struct super_block *sb)
 {
@@ -156,7 +156,7 @@
 	kmem_cache_free(ext2_inode_cachep, EXT2_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct ext2_inode_info *ei = (struct ext2_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/ext3/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ext3/super.c	2006-11-28 18:35:03.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ext3/super.c	2006-11-28 18:35:03.000000000 -0800
@@ -436,7 +436,7 @@
 	return;
 }
 
-static kmem_cache_t *ext3_inode_cachep;
+static struct kmem_cache *ext3_inode_cachep;
 
 /*
  * Called inside transaction, so use GFP_NOFS
@@ -462,7 +462,7 @@
 	kmem_cache_free(ext3_inode_cachep, EXT3_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct ext3_inode_info *ei = (struct ext3_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/ext4/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ext4/super.c	2006-11-28 18:35:04.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ext4/super.c	2006-11-28 18:35:04.000000000 -0800
@@ -486,7 +486,7 @@
 	return;
 }
 
-static kmem_cache_t *ext4_inode_cachep;
+static struct kmem_cache *ext4_inode_cachep;
 
 /*
  * Called inside transaction, so use GFP_NOFS
@@ -513,7 +513,7 @@
 	kmem_cache_free(ext4_inode_cachep, EXT4_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct ext4_inode_info *ei = (struct ext4_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/gfs2/main.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/gfs2/main.c	2006-11-28 18:35:05.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/gfs2/main.c	2006-11-28 18:35:05.000000000 -0800
@@ -25,7 +25,7 @@
 #include "util.h"
 #include "glock.h"
 
-static void gfs2_init_inode_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
+static void gfs2_init_inode_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct gfs2_inode *ip = foo;
 	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
@@ -37,7 +37,7 @@
 	}
 }
 
-static void gfs2_init_glock_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
+static void gfs2_init_glock_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct gfs2_glock *gl = foo;
 	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
Index: linux-2.6.19-rc6-mm1/fs/gfs2/util.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/gfs2/util.c	2006-11-28 18:35:06.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/gfs2/util.c	2006-11-28 18:35:06.000000000 -0800
@@ -23,9 +23,9 @@
 #include "lm.h"
 #include "util.h"
 
-kmem_cache_t *gfs2_glock_cachep __read_mostly;
-kmem_cache_t *gfs2_inode_cachep __read_mostly;
-kmem_cache_t *gfs2_bufdata_cachep __read_mostly;
+struct kmem_cache *gfs2_glock_cachep __read_mostly;
+struct kmem_cache *gfs2_inode_cachep __read_mostly;
+struct kmem_cache *gfs2_bufdata_cachep __read_mostly;
 
 void gfs2_assert_i(struct gfs2_sbd *sdp)
 {
Index: linux-2.6.19-rc6-mm1/fs/gfs2/util.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/gfs2/util.h	2006-11-28 18:35:07.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/gfs2/util.h	2006-11-28 18:35:07.000000000 -0800
@@ -144,9 +144,9 @@
 gfs2_io_error_bh_i((sdp), (bh), __FUNCTION__, __FILE__, __LINE__);
 
 
-extern kmem_cache_t *gfs2_glock_cachep;
-extern kmem_cache_t *gfs2_inode_cachep;
-extern kmem_cache_t *gfs2_bufdata_cachep;
+extern struct kmem_cache *gfs2_glock_cachep;
+extern struct kmem_cache *gfs2_inode_cachep;
+extern struct kmem_cache *gfs2_bufdata_cachep;
 
 static inline unsigned int gfs2_tune_get_i(struct gfs2_tune *gt,
 					   unsigned int *p)
Index: linux-2.6.19-rc6-mm1/fs/fuse/dev.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fuse/dev.c	2006-11-28 18:35:08.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fuse/dev.c	2006-11-28 18:35:08.000000000 -0800
@@ -19,7 +19,7 @@
 
 MODULE_ALIAS_MISCDEV(FUSE_MINOR);
 
-static kmem_cache_t *fuse_req_cachep;
+static struct kmem_cache *fuse_req_cachep;
 
 static struct fuse_conn *fuse_get_conn(struct file *file)
 {
Index: linux-2.6.19-rc6-mm1/fs/fuse/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fuse/inode.c	2006-11-28 18:35:09.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fuse/inode.c	2006-11-28 18:35:09.000000000 -0800
@@ -22,7 +22,7 @@
 MODULE_DESCRIPTION("Filesystem in Userspace");
 MODULE_LICENSE("GPL");
 
-static kmem_cache_t *fuse_inode_cachep;
+static struct kmem_cache *fuse_inode_cachep;
 struct list_head fuse_conn_list;
 DEFINE_MUTEX(fuse_mutex);
 
@@ -678,7 +678,7 @@
 static decl_subsys(fuse, NULL, NULL);
 static decl_subsys(connections, NULL, NULL);
 
-static void fuse_inode_init_once(void *foo, kmem_cache_t *cachep,
+static void fuse_inode_init_once(void *foo, struct kmem_cache *cachep,
 				 unsigned long flags)
 {
 	struct inode * inode = foo;
Index: linux-2.6.19-rc6-mm1/fs/hpfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/hpfs/super.c	2006-11-28 18:35:10.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/hpfs/super.c	2006-11-28 18:35:10.000000000 -0800
@@ -155,7 +155,7 @@
 	return 0;
 }
 
-static kmem_cache_t * hpfs_inode_cachep;
+static struct kmem_cache * hpfs_inode_cachep;
 
 static struct inode *hpfs_alloc_inode(struct super_block *sb)
 {
@@ -172,7 +172,7 @@
 	kmem_cache_free(hpfs_inode_cachep, hpfs_i(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct hpfs_inode_info *ei = (struct hpfs_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/jbd2/revoke.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jbd2/revoke.c	2006-11-28 18:35:11.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jbd2/revoke.c	2006-11-28 18:35:11.000000000 -0800
@@ -70,8 +70,8 @@
 #include <linux/init.h>
 #endif
 
-static kmem_cache_t *jbd2_revoke_record_cache;
-static kmem_cache_t *jbd2_revoke_table_cache;
+static struct kmem_cache *jbd2_revoke_record_cache;
+static struct kmem_cache *jbd2_revoke_table_cache;
 
 /* Each revoke record represents one single revoked block.  During
    journal replay, this involves recording the transaction ID of the
Index: linux-2.6.19-rc6-mm1/fs/jbd2/journal.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jbd2/journal.c	2006-11-28 18:35:12.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jbd2/journal.c	2006-11-28 18:35:12.000000000 -0800
@@ -1641,7 +1641,7 @@
 #define JBD_MAX_SLABS 5
 #define JBD_SLAB_INDEX(size)  (size >> 11)
 
-static kmem_cache_t *jbd_slab[JBD_MAX_SLABS];
+static struct kmem_cache *jbd_slab[JBD_MAX_SLABS];
 static const char *jbd_slab_names[JBD_MAX_SLABS] = {
 	"jbd2_1k", "jbd2_2k", "jbd2_4k", NULL, "jbd2_8k"
 };
@@ -1704,7 +1704,7 @@
 /*
  * Journal_head storage management
  */
-static kmem_cache_t *jbd2_journal_head_cache;
+static struct kmem_cache *jbd2_journal_head_cache;
 #ifdef CONFIG_JBD_DEBUG
 static atomic_t nr_journal_heads = ATOMIC_INIT(0);
 #endif
@@ -2007,7 +2007,7 @@
 
 #endif
 
-kmem_cache_t *jbd2_handle_cache;
+struct kmem_cache *jbd2_handle_cache;
 
 static int __init journal_init_handle_cache(void)
 {
Index: linux-2.6.19-rc6-mm1/fs/jffs/jffs_fm.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jffs/jffs_fm.c	2006-11-28 18:35:13.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jffs/jffs_fm.c	2006-11-28 18:35:13.000000000 -0800
@@ -29,8 +29,8 @@
 static struct jffs_fm *jffs_alloc_fm(void);
 static void jffs_free_fm(struct jffs_fm *n);
 
-extern kmem_cache_t     *fm_cache;
-extern kmem_cache_t     *node_cache;
+extern struct kmem_cache     *fm_cache;
+extern struct kmem_cache     *node_cache;
 
 #if CONFIG_JFFS_FS_VERBOSE > 0
 void
Index: linux-2.6.19-rc6-mm1/fs/jffs/inode-v23.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jffs/inode-v23.c	2006-11-28 18:35:15.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jffs/inode-v23.c	2006-11-28 18:35:15.000000000 -0800
@@ -61,8 +61,8 @@
 static struct inode_operations jffs_dir_inode_operations;
 static const struct address_space_operations jffs_address_operations;
 
-kmem_cache_t     *node_cache = NULL;
-kmem_cache_t     *fm_cache = NULL;
+struct kmem_cache     *node_cache = NULL;
+struct kmem_cache     *fm_cache = NULL;
 
 /* Called by the VFS at mount time to initialize the whole file system.  */
 static int jffs_fill_super(struct super_block *sb, void *data, int silent)
Index: linux-2.6.19-rc6-mm1/fs/nfsd/nfs4state.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfsd/nfs4state.c	2006-11-28 18:35:16.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfsd/nfs4state.c	2006-11-28 18:35:16.000000000 -0800
@@ -84,10 +84,10 @@
  */
 static DEFINE_MUTEX(client_mutex);
 
-static kmem_cache_t *stateowner_slab = NULL;
-static kmem_cache_t *file_slab = NULL;
-static kmem_cache_t *stateid_slab = NULL;
-static kmem_cache_t *deleg_slab = NULL;
+static struct kmem_cache *stateowner_slab = NULL;
+static struct kmem_cache *file_slab = NULL;
+static struct kmem_cache *stateid_slab = NULL;
+static struct kmem_cache *deleg_slab = NULL;
 
 void
 nfs4_lock_state(void)
@@ -1003,7 +1003,7 @@
 }
 
 static void
-nfsd4_free_slab(kmem_cache_t **slab)
+nfsd4_free_slab(struct kmem_cache **slab)
 {
 	if (*slab == NULL)
 		return;
Index: linux-2.6.19-rc6-mm1/fs/proc/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/proc/inode.c	2006-11-28 18:35:17.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/proc/inode.c	2006-11-28 18:35:17.000000000 -0800
@@ -81,7 +81,7 @@
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
 }
 
-static kmem_cache_t * proc_inode_cachep;
+static struct kmem_cache * proc_inode_cachep;
 
 static struct inode *proc_alloc_inode(struct super_block *sb)
 {
@@ -105,7 +105,7 @@
 	kmem_cache_free(proc_inode_cachep, PROC_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct proc_inode *ei = (struct proc_inode *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/qnx4/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/qnx4/inode.c	2006-11-28 18:35:18.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/qnx4/inode.c	2006-11-28 18:35:18.000000000 -0800
@@ -515,7 +515,7 @@
 	brelse(bh);
 }
 
-static kmem_cache_t *qnx4_inode_cachep;
+static struct kmem_cache *qnx4_inode_cachep;
 
 static struct inode *qnx4_alloc_inode(struct super_block *sb)
 {
@@ -531,7 +531,7 @@
 	kmem_cache_free(qnx4_inode_cachep, qnx4_i(inode));
 }
 
-static void init_once(void *foo, kmem_cache_t * cachep,
+static void init_once(void *foo, struct kmem_cache * cachep,
 		      unsigned long flags)
 {
 	struct qnx4_inode_info *ei = (struct qnx4_inode_info *) foo;
Index: linux-2.6.19-rc6-mm1/fs/sysv/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/sysv/inode.c	2006-11-28 18:35:19.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/sysv/inode.c	2006-11-28 18:35:19.000000000 -0800
@@ -301,7 +301,7 @@
 	unlock_kernel();
 }
 
-static kmem_cache_t *sysv_inode_cachep;
+static struct kmem_cache *sysv_inode_cachep;
 
 static struct inode *sysv_alloc_inode(struct super_block *sb)
 {
@@ -318,7 +318,7 @@
 	kmem_cache_free(sysv_inode_cachep, SYSV_I(inode));
 }
 
-static void init_once(void *p, kmem_cache_t *cachep, unsigned long flags)
+static void init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct sysv_inode_info *si = (struct sysv_inode_info *)p;
 
Index: linux-2.6.19-rc6-mm1/fs/reiserfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiserfs/super.c	2006-11-28 18:35:20.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiserfs/super.c	2006-11-28 18:35:20.000000000 -0800
@@ -490,7 +490,7 @@
 	return;
 }
 
-static kmem_cache_t *reiserfs_inode_cachep;
+static struct kmem_cache *reiserfs_inode_cachep;
 
 static struct inode *reiserfs_alloc_inode(struct super_block *sb)
 {
@@ -507,7 +507,7 @@
 	kmem_cache_free(reiserfs_inode_cachep, REISERFS_I(inode));
 }
 
-static void init_once(void *foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct reiserfs_inode_info *ei = (struct reiserfs_inode_info *)foo;
 
Index: linux-2.6.19-rc6-mm1/fs/reiser4/jnode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiser4/jnode.c	2006-11-28 18:35:22.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiser4/jnode.c	2006-11-28 18:35:22.000000000 -0800
@@ -123,7 +123,7 @@
 #include <linux/fs.h>		/* for struct address_space  */
 #include <linux/writeback.h>	/* for inode_lock */
 
-static kmem_cache_t *_jnode_slab = NULL;
+static struct kmem_cache *_jnode_slab = NULL;
 
 static void jnode_set_type(jnode * node, jnode_type type);
 static int jdelete(jnode * node);
Index: linux-2.6.19-rc6-mm1/fs/reiser4/txnmgr.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiser4/txnmgr.c	2006-11-28 18:35:23.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiser4/txnmgr.c	2006-11-28 18:35:23.000000000 -0800
@@ -90,7 +90,7 @@
    For actually implementing these out-of-system-call-scopped transcrashes, the
    reiser4_context has a "txn_handle *trans" pointer that may be set to an open
    transcrash.  Currently there are no dynamically-allocated transcrashes, but there is a
-   "kmem_cache_t *_txnh_slab" created for that purpose in this file.
+   "struct kmem_cache *_txnh_slab" created for that purpose in this file.
 */
 
 /* Extending the other system call interfaces for future transaction features:
@@ -279,9 +279,9 @@
 
 /* FIXME: In theory, we should be using the slab cache init & destructor
    methods instead of, e.g., jnode_init, etc. */
-static kmem_cache_t *_atom_slab = NULL;
+static struct kmem_cache *_atom_slab = NULL;
 /* this is for user-visible, cross system-call transactions. */
-static kmem_cache_t *_txnh_slab = NULL;
+static struct kmem_cache *_txnh_slab = NULL;
 
 /**
  * init_txnmgr_static - create transaction manager slab caches
Index: linux-2.6.19-rc6-mm1/fs/reiser4/flush_queue.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiser4/flush_queue.c	2006-11-28 18:35:24.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiser4/flush_queue.c	2006-11-28 18:35:24.000000000 -0800
@@ -107,7 +107,7 @@
 }
 
 /* slab for flush queues */
-static kmem_cache_t *fq_slab;
+static struct kmem_cache *fq_slab;
 
 /**
  * reiser4_init_fqs - create flush queue cache
Index: linux-2.6.19-rc6-mm1/fs/reiser4/znode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiser4/znode.c	2006-11-28 18:35:25.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiser4/znode.c	2006-11-28 18:35:25.000000000 -0800
@@ -196,7 +196,7 @@
 #undef KMALLOC
 
 /* slab for znodes */
-static kmem_cache_t *znode_cache;
+static struct kmem_cache *znode_cache;
 
 int znode_shift_order;
 
Index: linux-2.6.19-rc6-mm1/fs/reiser4/super.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiser4/super.h	2006-11-28 18:35:26.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiser4/super.h	2006-11-28 18:35:26.000000000 -0800
@@ -444,7 +444,7 @@
 void print_fs_info(const char *prefix, const struct super_block *);
 #endif
 
-extern void destroy_reiser4_cache(kmem_cache_t **);
+extern void destroy_reiser4_cache(struct kmem_cache **);
 
 extern struct super_operations reiser4_super_operations;
 extern struct export_operations reiser4_export_operations;
Index: linux-2.6.19-rc6-mm1/fs/reiser4/plugin/plugin_set.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiser4/plugin/plugin_set.c	2006-11-28 18:35:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiser4/plugin/plugin_set.c	2006-11-28 18:35:28.000000000 -0800
@@ -31,7 +31,7 @@
 #include <linux/stddef.h>
 
 /* slab for plugin sets */
-static kmem_cache_t *plugin_set_slab;
+static struct kmem_cache *plugin_set_slab;
 
 static spinlock_t plugin_set_lock[8] __cacheline_aligned_in_smp = {
 	[0 ... 7] = SPIN_LOCK_UNLOCKED
Index: linux-2.6.19-rc6-mm1/fs/reiser4/fsdata.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiser4/fsdata.c	2006-11-28 18:35:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiser4/fsdata.c	2006-11-28 18:35:29.000000000 -0800
@@ -7,7 +7,7 @@
 #include <linux/slab.h>
 
 /* cache or dir_cursors */
-static kmem_cache_t *d_cursor_cache;
+static struct kmem_cache *d_cursor_cache;
 static struct shrinker *d_cursor_shrinker;
 
 /* list of unused cursors */
@@ -597,7 +597,7 @@
 }
 
 /* slab for reiser4_dentry_fsdata */
-static kmem_cache_t *dentry_fsdata_cache;
+static struct kmem_cache *dentry_fsdata_cache;
 
 /**
  * reiser4_init_dentry_fsdata - create cache of dentry_fsdata
@@ -664,7 +664,7 @@
 }
 
 /* slab for reiser4_file_fsdata */
-static kmem_cache_t *file_fsdata_cache;
+static struct kmem_cache *file_fsdata_cache;
 
 /**
  * reiser4_init_file_fsdata - create cache of reiser4_file_fsdata
Index: linux-2.6.19-rc6-mm1/fs/reiser4/super_ops.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/reiser4/super_ops.c	2006-11-28 18:35:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/reiser4/super_ops.c	2006-11-28 18:35:30.000000000 -0800
@@ -14,7 +14,7 @@
 #include <linux/debugfs.h>
 
 /* slab cache for inodes */
-static kmem_cache_t *inode_cache;
+static struct kmem_cache *inode_cache;
 
 static struct dentry *reiser4_debugfs_root = NULL;
 
@@ -27,7 +27,7 @@
  * Initialization function to be called when new page is allocated by reiser4
  * inode cache. It is set on inode cache creation.
  */
-static void init_once(void *obj, kmem_cache_t *cache, unsigned long flags)
+static void init_once(void *obj, struct kmem_cache *cache, unsigned long flags)
 {
 	reiser4_inode_object *info;
 
@@ -595,7 +595,7 @@
 	.next = NULL
 };
 
-void destroy_reiser4_cache(kmem_cache_t **cachep)
+void destroy_reiser4_cache(struct kmem_cache **cachep)
 {
 	BUG_ON(*cachep == NULL);
 	kmem_cache_destroy(*cachep);
Index: linux-2.6.19-rc6-mm1/fs/block_dev.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/block_dev.c	2006-11-28 18:35:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/block_dev.c	2006-11-28 18:35:32.000000000 -0800
@@ -237,7 +237,7 @@
  */
 
 static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(bdev_lock);
-static kmem_cache_t * bdev_cachep __read_mostly;
+static struct kmem_cache * bdev_cachep __read_mostly;
 
 static struct inode *bdev_alloc_inode(struct super_block *sb)
 {
@@ -255,7 +255,7 @@
 	kmem_cache_free(bdev_cachep, bdi);
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct bdev_inode *ei = (struct bdev_inode *) foo;
 	struct block_device *bdev = &ei->bdev;
Index: linux-2.6.19-rc6-mm1/fs/aio.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/aio.c	2006-11-28 18:35:33.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/aio.c	2006-11-28 18:35:33.000000000 -0800
@@ -47,8 +47,8 @@
 unsigned long aio_max_nr = 0x10000; /* system wide maximum number of aio requests */
 /*----end sysctl variables---*/
 
-static kmem_cache_t	*kiocb_cachep;
-static kmem_cache_t	*kioctx_cachep;
+static struct kmem_cache	*kiocb_cachep;
+static struct kmem_cache	*kioctx_cachep;
 
 static struct workqueue_struct *aio_wq;
 
Index: linux-2.6.19-rc6-mm1/fs/bio.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/bio.c	2006-11-28 18:35:34.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/bio.c	2006-11-28 18:35:34.000000000 -0800
@@ -30,7 +30,7 @@
 
 #define BIO_POOL_SIZE 256
 
-static kmem_cache_t *bio_slab __read_mostly;
+static struct kmem_cache *bio_slab __read_mostly;
 
 #define BIOVEC_NR_POOLS 6
 
@@ -44,7 +44,7 @@
 struct biovec_slab {
 	int nr_vecs;
 	char *name; 
-	kmem_cache_t *slab;
+	struct kmem_cache *slab;
 };
 
 /*
Index: linux-2.6.19-rc6-mm1/fs/jffs2/malloc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jffs2/malloc.c	2006-11-28 18:35:36.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jffs2/malloc.c	2006-11-28 18:35:36.000000000 -0800
@@ -19,16 +19,16 @@
 
 /* These are initialised to NULL in the kernel startup code.
    If you're porting to other operating systems, beware */
-static kmem_cache_t *full_dnode_slab;
-static kmem_cache_t *raw_dirent_slab;
-static kmem_cache_t *raw_inode_slab;
-static kmem_cache_t *tmp_dnode_info_slab;
-static kmem_cache_t *raw_node_ref_slab;
-static kmem_cache_t *node_frag_slab;
-static kmem_cache_t *inode_cache_slab;
+static struct kmem_cache *full_dnode_slab;
+static struct kmem_cache *raw_dirent_slab;
+static struct kmem_cache *raw_inode_slab;
+static struct kmem_cache *tmp_dnode_info_slab;
+static struct kmem_cache *raw_node_ref_slab;
+static struct kmem_cache *node_frag_slab;
+static struct kmem_cache *inode_cache_slab;
 #ifdef CONFIG_JFFS2_FS_XATTR
-static kmem_cache_t *xattr_datum_cache;
-static kmem_cache_t *xattr_ref_cache;
+static struct kmem_cache *xattr_datum_cache;
+static struct kmem_cache *xattr_ref_cache;
 #endif
 
 int __init jffs2_create_slab_caches(void)
Index: linux-2.6.19-rc6-mm1/fs/jffs2/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/jffs2/super.c	2006-11-28 18:35:37.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/jffs2/super.c	2006-11-28 18:35:37.000000000 -0800
@@ -28,7 +28,7 @@
 
 static void jffs2_put_super(struct super_block *);
 
-static kmem_cache_t *jffs2_inode_cachep;
+static struct kmem_cache *jffs2_inode_cachep;
 
 static struct inode *jffs2_alloc_inode(struct super_block *sb)
 {
@@ -44,7 +44,7 @@
 	kmem_cache_free(jffs2_inode_cachep, JFFS2_INODE_INFO(inode));
 }
 
-static void jffs2_i_init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void jffs2_i_init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct jffs2_inode_info *ei = (struct jffs2_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/isofs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/isofs/inode.c	2006-11-28 18:35:39.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/isofs/inode.c	2006-11-28 18:35:39.000000000 -0800
@@ -57,7 +57,7 @@
 static void isofs_read_inode(struct inode *);
 static int isofs_statfs (struct dentry *, struct kstatfs *);
 
-static kmem_cache_t *isofs_inode_cachep;
+static struct kmem_cache *isofs_inode_cachep;
 
 static struct inode *isofs_alloc_inode(struct super_block *sb)
 {
@@ -73,7 +73,7 @@
 	kmem_cache_free(isofs_inode_cachep, ISOFS_I(inode));
 }
 
-static void init_once(void *foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct iso_inode_info *ei = foo;
 
Index: linux-2.6.19-rc6-mm1/fs/minix/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/minix/inode.c	2006-11-28 18:35:40.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/minix/inode.c	2006-11-28 18:35:40.000000000 -0800
@@ -51,7 +51,7 @@
 	return;
 }
 
-static kmem_cache_t * minix_inode_cachep;
+static struct kmem_cache * minix_inode_cachep;
 
 static struct inode *minix_alloc_inode(struct super_block *sb)
 {
@@ -67,7 +67,7 @@
 	kmem_cache_free(minix_inode_cachep, minix_i(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct minix_inode_info *ei = (struct minix_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/ncpfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ncpfs/inode.c	2006-11-28 18:35:42.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ncpfs/inode.c	2006-11-28 18:35:42.000000000 -0800
@@ -40,7 +40,7 @@
 static void ncp_put_super(struct super_block *);
 static int  ncp_statfs(struct dentry *, struct kstatfs *);
 
-static kmem_cache_t * ncp_inode_cachep;
+static struct kmem_cache * ncp_inode_cachep;
 
 static struct inode *ncp_alloc_inode(struct super_block *sb)
 {
@@ -56,7 +56,7 @@
 	kmem_cache_free(ncp_inode_cachep, NCP_FINFO(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct ncp_inode_info *ei = (struct ncp_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/ocfs2/dlm/dlmfs.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ocfs2/dlm/dlmfs.c	2006-11-28 18:35:43.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ocfs2/dlm/dlmfs.c	2006-11-28 18:35:43.000000000 -0800
@@ -66,7 +66,7 @@
 static struct inode_operations dlmfs_dir_inode_operations;
 static struct inode_operations dlmfs_root_inode_operations;
 static struct inode_operations dlmfs_file_inode_operations;
-static kmem_cache_t *dlmfs_inode_cache;
+static struct kmem_cache *dlmfs_inode_cache;
 
 struct workqueue_struct *user_dlm_worker;
 
@@ -257,7 +257,7 @@
 }
 
 static void dlmfs_init_once(void *foo,
-			    kmem_cache_t *cachep,
+			    struct kmem_cache *cachep,
 			    unsigned long flags)
 {
 	struct dlmfs_inode_private *ip =
Index: linux-2.6.19-rc6-mm1/fs/ocfs2/dlm/dlmmaster.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ocfs2/dlm/dlmmaster.c	2006-11-28 18:35:44.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ocfs2/dlm/dlmmaster.c	2006-11-28 18:35:44.000000000 -0800
@@ -221,7 +221,7 @@
 #endif  /*  0  */
 
 
-static kmem_cache_t *dlm_mle_cache = NULL;
+static struct kmem_cache *dlm_mle_cache = NULL;
 
 
 static void dlm_mle_release(struct kref *kref);
Index: linux-2.6.19-rc6-mm1/fs/ocfs2/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ocfs2/super.c	2006-11-28 18:35:46.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ocfs2/super.c	2006-11-28 18:35:46.000000000 -0800
@@ -68,7 +68,7 @@
 
 #include "buffer_head_io.h"
 
-static kmem_cache_t *ocfs2_inode_cachep = NULL;
+static struct kmem_cache *ocfs2_inode_cachep = NULL;
 
 /* OCFS2 needs to schedule several differnt types of work which
  * require cluster locking, disk I/O, recovery waits, etc. Since these
@@ -914,7 +914,7 @@
 }
 
 static void ocfs2_inode_init_once(void *data,
-				  kmem_cache_t *cachep,
+				  struct kmem_cache *cachep,
 				  unsigned long flags)
 {
 	struct ocfs2_inode_info *oi = data;
Index: linux-2.6.19-rc6-mm1/fs/ocfs2/uptodate.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ocfs2/uptodate.c	2006-11-28 18:35:47.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ocfs2/uptodate.c	2006-11-28 18:35:47.000000000 -0800
@@ -69,7 +69,7 @@
 	sector_t	c_block;
 };
 
-static kmem_cache_t *ocfs2_uptodate_cachep = NULL;
+static struct kmem_cache *ocfs2_uptodate_cachep = NULL;
 
 void ocfs2_metadata_cache_init(struct inode *inode)
 {
Index: linux-2.6.19-rc6-mm1/fs/ocfs2/extent_map.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ocfs2/extent_map.c	2006-11-28 18:35:49.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ocfs2/extent_map.c	2006-11-28 18:35:49.000000000 -0800
@@ -61,7 +61,7 @@
 	struct ocfs2_extent_map_entry *right_ent;
 };
 
-static kmem_cache_t *ocfs2_em_ent_cachep = NULL;
+static struct kmem_cache *ocfs2_em_ent_cachep = NULL;
 
 
 static struct ocfs2_extent_map_entry *
Index: linux-2.6.19-rc6-mm1/fs/ocfs2/inode.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ocfs2/inode.h	2006-11-28 18:35:50.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ocfs2/inode.h	2006-11-28 18:35:50.000000000 -0800
@@ -106,7 +106,7 @@
 #define INODE_JOURNAL(i) (OCFS2_I(i)->ip_flags & OCFS2_INODE_JOURNAL)
 #define SET_INODE_JOURNAL(i) (OCFS2_I(i)->ip_flags |= OCFS2_INODE_JOURNAL)
 
-extern kmem_cache_t *ocfs2_inode_cache;
+extern struct kmem_cache *ocfs2_inode_cache;
 
 extern const struct address_space_operations ocfs2_aops;
 
Index: linux-2.6.19-rc6-mm1/fs/romfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/romfs/inode.c	2006-11-28 18:35:52.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/romfs/inode.c	2006-11-28 18:35:52.000000000 -0800
@@ -550,7 +550,7 @@
 	}
 }
 
-static kmem_cache_t * romfs_inode_cachep;
+static struct kmem_cache * romfs_inode_cachep;
 
 static struct inode *romfs_alloc_inode(struct super_block *sb)
 {
@@ -566,7 +566,7 @@
 	kmem_cache_free(romfs_inode_cachep, ROMFS_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct romfs_inode_info *ei = (struct romfs_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/smbfs/request.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/smbfs/request.c	2006-11-28 18:35:53.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/smbfs/request.c	2006-11-28 18:35:53.000000000 -0800
@@ -25,7 +25,7 @@
 #define ROUND_UP(x) (((x)+3) & ~3)
 
 /* cache for request structures */
-static kmem_cache_t *req_cachep;
+static struct kmem_cache *req_cachep;
 
 static int smb_request_send_req(struct smb_request *req);
 
Index: linux-2.6.19-rc6-mm1/fs/smbfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/smbfs/inode.c	2006-11-28 18:35:55.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/smbfs/inode.c	2006-11-28 18:35:55.000000000 -0800
@@ -50,7 +50,7 @@
 static int  smb_statfs(struct dentry *, struct kstatfs *);
 static int  smb_show_options(struct seq_file *, struct vfsmount *);
 
-static kmem_cache_t *smb_inode_cachep;
+static struct kmem_cache *smb_inode_cachep;
 
 static struct inode *smb_alloc_inode(struct super_block *sb)
 {
@@ -66,7 +66,7 @@
 	kmem_cache_free(smb_inode_cachep, SMB_I(inode));
 }
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct smb_inode_info *ei = (struct smb_inode_info *) foo;
 	unsigned long flagmask = SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR;
Index: linux-2.6.19-rc6-mm1/fs/sysfs/mount.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/sysfs/mount.c	2006-11-28 18:35:56.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/sysfs/mount.c	2006-11-28 18:35:56.000000000 -0800
@@ -16,7 +16,7 @@
 
 struct vfsmount *sysfs_mount;
 struct super_block * sysfs_sb = NULL;
-kmem_cache_t *sysfs_dir_cachep;
+struct kmem_cache *sysfs_dir_cachep;
 
 static struct super_operations sysfs_ops = {
 	.statfs		= simple_statfs,
Index: linux-2.6.19-rc6-mm1/fs/sysfs/sysfs.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/sysfs/sysfs.h	2006-11-28 18:35:58.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/sysfs/sysfs.h	2006-11-28 18:35:58.000000000 -0800
@@ -1,6 +1,6 @@
 
 extern struct vfsmount * sysfs_mount;
-extern kmem_cache_t *sysfs_dir_cachep;
+extern struct kmem_cache *sysfs_dir_cachep;
 
 extern struct inode * sysfs_new_inode(mode_t mode, struct sysfs_dirent *);
 extern int sysfs_create(struct dentry *, int mode, int (*init)(struct inode *));
Index: linux-2.6.19-rc6-mm1/fs/dcache.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/dcache.c	2006-11-28 18:35:59.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/dcache.c	2006-11-28 18:35:59.000000000 -0800
@@ -43,7 +43,7 @@
 
 EXPORT_SYMBOL(dcache_lock);
 
-static kmem_cache_t *dentry_cache __read_mostly;
+static struct kmem_cache *dentry_cache __read_mostly;
 
 #define DNAME_INLINE_LEN (sizeof(struct dentry)-offsetof(struct dentry,d_iname))
 
@@ -2082,10 +2082,10 @@
 }
 
 /* SLAB cache for __getname() consumers */
-kmem_cache_t *names_cachep __read_mostly;
+struct kmem_cache *names_cachep __read_mostly;
 
 /* SLAB cache for file structures */
-kmem_cache_t *filp_cachep __read_mostly;
+struct kmem_cache *filp_cachep __read_mostly;
 
 EXPORT_SYMBOL(d_genocide);
 
Index: linux-2.6.19-rc6-mm1/fs/dquot.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/dquot.c	2006-11-28 18:36:01.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/dquot.c	2006-11-28 18:36:01.000000000 -0800
@@ -131,7 +131,7 @@
 static struct quota_module_name module_names[] = INIT_QUOTA_MODULE_NAMES;
 
 /* SLAB cache for dquot structures */
-static kmem_cache_t *dquot_cachep;
+static struct kmem_cache *dquot_cachep;
 
 int register_quota_format(struct quota_format_type *fmt)
 {
Index: linux-2.6.19-rc6-mm1/fs/fcntl.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/fcntl.c	2006-11-28 18:36:02.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/fcntl.c	2006-11-28 18:36:02.000000000 -0800
@@ -552,7 +552,7 @@
 }
 
 static DEFINE_RWLOCK(fasync_lock);
-static kmem_cache_t *fasync_cache __read_mostly;
+static struct kmem_cache *fasync_cache __read_mostly;
 
 /*
  * fasync_helper() is used by some character device drivers (mainly mice)
Index: linux-2.6.19-rc6-mm1/fs/locks.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/locks.c	2006-11-28 18:36:04.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/locks.c	2006-11-28 18:36:04.000000000 -0800
@@ -142,7 +142,7 @@
 static LIST_HEAD(file_lock_list);
 static LIST_HEAD(blocked_list);
 
-static kmem_cache_t *filelock_cache __read_mostly;
+static struct kmem_cache *filelock_cache __read_mostly;
 
 /* Allocate an empty lock structure. */
 static struct file_lock *locks_alloc_lock(void)
@@ -199,7 +199,7 @@
  * Initialises the fields of the file lock which are invariant for
  * free file_locks.
  */
-static void init_once(void *foo, kmem_cache_t *cache, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache *cache, unsigned long flags)
 {
 	struct file_lock *lock = (struct file_lock *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/eventpoll.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/eventpoll.c	2006-11-28 18:36:06.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/eventpoll.c	2006-11-28 18:36:06.000000000 -0800
@@ -283,10 +283,10 @@
 static struct poll_safewake psw;
 
 /* Slab cache used to allocate "struct epitem" */
-static kmem_cache_t *epi_cache __read_mostly;
+static struct kmem_cache *epi_cache __read_mostly;
 
 /* Slab cache used to allocate "struct eppoll_entry" */
-static kmem_cache_t *pwq_cache __read_mostly;
+static struct kmem_cache *pwq_cache __read_mostly;
 
 /* Virtual fs used to allocate inodes for eventpoll files */
 static struct vfsmount *eventpoll_mnt __read_mostly;
Index: linux-2.6.19-rc6-mm1/fs/mbcache.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/mbcache.c	2006-11-28 18:36:07.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/mbcache.c	2006-11-28 18:36:07.000000000 -0800
@@ -85,7 +85,7 @@
 #ifndef MB_CACHE_INDEXES_COUNT
 	int				c_indexes_count;
 #endif
-	kmem_cache_t			*c_entry_cache;
+	struct kmem_cache			*c_entry_cache;
 	struct list_head		*c_block_hash;
 	struct list_head		*c_indexes_hash[0];
 };
Index: linux-2.6.19-rc6-mm1/fs/configfs/mount.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/configfs/mount.c	2006-11-28 18:36:09.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/configfs/mount.c	2006-11-28 18:36:09.000000000 -0800
@@ -38,7 +38,7 @@
 
 struct vfsmount * configfs_mount = NULL;
 struct super_block * configfs_sb = NULL;
-kmem_cache_t *configfs_dir_cachep;
+struct kmem_cache *configfs_dir_cachep;
 static int configfs_mnt_count = 0;
 
 static struct super_operations configfs_ops = {
Index: linux-2.6.19-rc6-mm1/fs/configfs/configfs_internal.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/configfs/configfs_internal.h	2006-11-28 18:36:11.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/configfs/configfs_internal.h	2006-11-28 18:36:11.000000000 -0800
@@ -49,7 +49,7 @@
 #define CONFIGFS_NOT_PINNED	(CONFIGFS_ITEM_ATTR)
 
 extern struct vfsmount * configfs_mount;
-extern kmem_cache_t *configfs_dir_cachep;
+extern struct kmem_cache *configfs_dir_cachep;
 
 extern int configfs_is_root(struct config_item *item);
 
Index: linux-2.6.19-rc6-mm1/fs/dnotify.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/dnotify.c	2006-11-28 18:36:12.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/dnotify.c	2006-11-28 18:36:12.000000000 -0800
@@ -23,7 +23,7 @@
 
 int dir_notify_enable __read_mostly = 1;
 
-static kmem_cache_t *dn_cache __read_mostly;
+static struct kmem_cache *dn_cache __read_mostly;
 
 static void redo_inode_mask(struct inode *inode)
 {
Index: linux-2.6.19-rc6-mm1/fs/freevxfs/vxfs_inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/freevxfs/vxfs_inode.c	2006-11-28 18:36:14.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/freevxfs/vxfs_inode.c	2006-11-28 18:36:14.000000000 -0800
@@ -46,7 +46,7 @@
 
 extern struct inode_operations vxfs_immed_symlink_iops;
 
-kmem_cache_t		*vxfs_inode_cachep;
+struct kmem_cache		*vxfs_inode_cachep;
 
 
 #ifdef DIAGNOSTIC
Index: linux-2.6.19-rc6-mm1/fs/buffer.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/buffer.c	2006-11-28 18:36:15.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/buffer.c	2006-11-28 18:36:15.000000000 -0800
@@ -2930,7 +2930,7 @@
 /*
  * Buffer-head allocation
  */
-static kmem_cache_t *bh_cachep;
+static struct kmem_cache *bh_cachep;
 
 /*
  * Once the number of bh's in the machine exceeds this level, we start
@@ -2983,7 +2983,7 @@
 EXPORT_SYMBOL(free_buffer_head);
 
 static void
-init_buffer_head(void *data, kmem_cache_t *cachep, unsigned long flags)
+init_buffer_head(void *data, struct kmem_cache *cachep, unsigned long flags)
 {
 	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
 			    SLAB_CTOR_CONSTRUCTOR) {
Index: linux-2.6.19-rc6-mm1/fs/hfsplus/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/hfsplus/super.c	2006-11-28 18:36:17.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/hfsplus/super.c	2006-11-28 18:36:17.000000000 -0800
@@ -434,7 +434,7 @@
 MODULE_DESCRIPTION("Extended Macintosh Filesystem");
 MODULE_LICENSE("GPL");
 
-static kmem_cache_t *hfsplus_inode_cachep;
+static struct kmem_cache *hfsplus_inode_cachep;
 
 static struct inode *hfsplus_alloc_inode(struct super_block *sb)
 {
@@ -467,7 +467,7 @@
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void hfsplus_init_once(void *p, kmem_cache_t *cachep, unsigned long flags)
+static void hfsplus_init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct hfsplus_inode_info *i = p;
 
Index: linux-2.6.19-rc6-mm1/fs/namespace.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/namespace.c	2006-11-28 18:36:19.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/namespace.c	2006-11-28 18:36:19.000000000 -0800
@@ -36,7 +36,7 @@
 
 static struct list_head *mount_hashtable __read_mostly;
 static int hash_mask __read_mostly, hash_bits __read_mostly;
-static kmem_cache_t *mnt_cache __read_mostly;
+static struct kmem_cache *mnt_cache __read_mostly;
 static struct rw_semaphore namespace_sem;
 
 /* /sys/fs */
Index: linux-2.6.19-rc6-mm1/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/hugetlbfs/inode.c	2006-11-28 18:36:20.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/hugetlbfs/inode.c	2006-11-28 18:36:20.000000000 -0800
@@ -513,7 +513,7 @@
 }
 
 
-static kmem_cache_t *hugetlbfs_inode_cachep;
+static struct kmem_cache *hugetlbfs_inode_cachep;
 
 static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 {
@@ -545,7 +545,7 @@
 };
 
 
-static void init_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct hugetlbfs_inode_info *ei = (struct hugetlbfs_inode_info *)foo;
 
Index: linux-2.6.19-rc6-mm1/fs/dcookies.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/dcookies.c	2006-11-28 18:36:22.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/dcookies.c	2006-11-28 18:36:22.000000000 -0800
@@ -37,7 +37,7 @@
 
 static LIST_HEAD(dcookie_users);
 static DEFINE_MUTEX(dcookie_mutex);
-static kmem_cache_t *dcookie_cache __read_mostly;
+static struct kmem_cache *dcookie_cache __read_mostly;
 static struct list_head *dcookie_hashtable __read_mostly;
 static size_t hash_size __read_mostly;
 
Index: linux-2.6.19-rc6-mm1/fs/inotify_user.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/inotify_user.c	2006-11-28 18:36:24.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/inotify_user.c	2006-11-28 18:36:24.000000000 -0800
@@ -34,8 +34,8 @@
 
 #include <asm/ioctls.h>
 
-static kmem_cache_t *watch_cachep __read_mostly;
-static kmem_cache_t *event_cachep __read_mostly;
+static struct kmem_cache *watch_cachep __read_mostly;
+static struct kmem_cache *event_cachep __read_mostly;
 
 static struct vfsmount *inotify_mnt __read_mostly;
 
Index: linux-2.6.19-rc6-mm1/fs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/inode.c	2006-11-28 18:36:25.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/inode.c	2006-11-28 18:36:25.000000000 -0800
@@ -98,7 +98,7 @@
  */
 struct inodes_stat_t inodes_stat;
 
-static kmem_cache_t * inode_cachep __read_mostly;
+static struct kmem_cache * inode_cachep __read_mostly;
 
 static struct inode *alloc_inode(struct super_block *sb)
 {
@@ -216,7 +216,7 @@
 
 EXPORT_SYMBOL(inode_init_once);
 
-static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct inode * inode = (struct inode *) foo;
 
Index: linux-2.6.19-rc6-mm1/fs/openpromfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/openpromfs/inode.c	2006-11-28 18:36:27.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/openpromfs/inode.c	2006-11-28 18:36:27.000000000 -0800
@@ -330,7 +330,7 @@
 	return 0;
 }
 
-static kmem_cache_t *op_inode_cachep;
+static struct kmem_cache *op_inode_cachep;
 
 static struct inode *openprom_alloc_inode(struct super_block *sb)
 {
@@ -415,7 +415,7 @@
 	.kill_sb	= kill_anon_super,
 };
 
-static void op_inode_init_once(void *data, kmem_cache_t * cachep, unsigned long flags)
+static void op_inode_init_once(void *data, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct op_inode_info *oi = (struct op_inode_info *) data;
 
Index: linux-2.6.19-rc6-mm1/include/net/dst.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/net/dst.h	2006-11-28 18:36:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/net/dst.h	2006-11-28 18:36:29.000000000 -0800
@@ -98,7 +98,7 @@
 	int			entry_size;
 
 	atomic_t		entries;
-	kmem_cache_t 		*kmem_cachep;
+	struct kmem_cache 		*kmem_cachep;
 };
 
 #ifdef __KERNEL__
Index: linux-2.6.19-rc6-mm1/include/net/timewait_sock.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/net/timewait_sock.h	2006-11-28 18:36:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/net/timewait_sock.h	2006-11-28 18:36:30.000000000 -0800
@@ -15,7 +15,7 @@
 #include <net/sock.h>
 
 struct timewait_sock_ops {
-	kmem_cache_t	*twsk_slab;
+	struct kmem_cache	*twsk_slab;
 	unsigned int	twsk_obj_size;
 	int		(*twsk_unique)(struct sock *sk,
 				       struct sock *sktw, void *twp);
Index: linux-2.6.19-rc6-mm1/include/net/inet_hashtables.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/net/inet_hashtables.h	2006-11-28 18:36:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/net/inet_hashtables.h	2006-11-28 18:36:32.000000000 -0800
@@ -125,7 +125,7 @@
 	rwlock_t			lhash_lock ____cacheline_aligned;
 	atomic_t			lhash_users;
 	wait_queue_head_t		lhash_wait;
-	kmem_cache_t			*bind_bucket_cachep;
+	struct kmem_cache			*bind_bucket_cachep;
 };
 
 static inline struct inet_ehash_bucket *inet_ehash_bucket(
@@ -136,10 +136,10 @@
 }
 
 extern struct inet_bind_bucket *
-		    inet_bind_bucket_create(kmem_cache_t *cachep,
+		    inet_bind_bucket_create(struct kmem_cache *cachep,
 					    struct inet_bind_hashbucket *head,
 					    const unsigned short snum);
-extern void inet_bind_bucket_destroy(kmem_cache_t *cachep,
+extern void inet_bind_bucket_destroy(struct kmem_cache *cachep,
 				     struct inet_bind_bucket *tb);
 
 static inline int inet_bhashfn(const __u16 lport, const int bhash_size)
Index: linux-2.6.19-rc6-mm1/include/net/sock.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/net/sock.h	2006-11-28 18:36:34.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/net/sock.h	2006-11-28 18:36:34.000000000 -0800
@@ -587,7 +587,7 @@
 	int			*sysctl_rmem;
 	int			max_header;
 
-	kmem_cache_t		*slab;
+	struct kmem_cache		*slab;
 	unsigned int		obj_size;
 
 	atomic_t		*orphan_count;
Index: linux-2.6.19-rc6-mm1/include/net/neighbour.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/net/neighbour.h	2006-11-28 18:36:35.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/net/neighbour.h	2006-11-28 18:36:35.000000000 -0800
@@ -160,7 +160,7 @@
 	atomic_t		entries;
 	rwlock_t		lock;
 	unsigned long		last_rand;
-	kmem_cache_t		*kmem_cachep;
+	struct kmem_cache		*kmem_cachep;
 	struct neigh_statistics	*stats;
 	struct neighbour	**hash_buckets;
 	unsigned int		hash_mask;
Index: linux-2.6.19-rc6-mm1/include/net/request_sock.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/net/request_sock.h	2006-11-28 18:36:37.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/net/request_sock.h	2006-11-28 18:36:37.000000000 -0800
@@ -29,7 +29,7 @@
 struct request_sock_ops {
 	int		family;
 	int		obj_size;
-	kmem_cache_t	*slab;
+	struct kmem_cache	*slab;
 	int		(*rtx_syn_ack)(struct sock *sk,
 				       struct request_sock *req,
 				       struct dst_entry *dst);
Index: linux-2.6.19-rc6-mm1/include/acpi/platform/aclinux.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/acpi/platform/aclinux.h	2006-11-28 18:36:39.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/acpi/platform/aclinux.h	2006-11-28 18:36:39.000000000 -0800
@@ -64,7 +64,7 @@
 /* Host-dependent types and defines */
 
 #define ACPI_MACHINE_WIDTH          BITS_PER_LONG
-#define acpi_cache_t                        kmem_cache_t
+#define acpi_cache_t                        struct kmem_cache
 #define acpi_spinlock                   spinlock_t *
 #define ACPI_EXPORT_SYMBOL(symbol)  EXPORT_SYMBOL(symbol);
 #define strtoul                     simple_strtoul
Index: linux-2.6.19-rc6-mm1/include/scsi/libsas.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/scsi/libsas.h	2006-11-28 18:36:41.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/scsi/libsas.h	2006-11-28 18:36:41.000000000 -0800
@@ -548,7 +548,7 @@
 
 static inline struct sas_task *sas_alloc_task(gfp_t flags)
 {
-	extern kmem_cache_t *sas_task_cache;
+	extern struct kmem_cache *sas_task_cache;
 	struct sas_task *task = kmem_cache_alloc(sas_task_cache, flags);
 
 	if (task) {
@@ -566,7 +566,7 @@
 static inline void sas_free_task(struct sas_task *task)
 {
 	if (task) {
-		extern kmem_cache_t *sas_task_cache;
+		extern struct kmem_cache *sas_task_cache;
 		BUG_ON(!list_empty(&task->list));
 		kmem_cache_free(sas_task_cache, task);
 	}
Index: linux-2.6.19-rc6-mm1/include/linux/raid/raid5.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/raid/raid5.h	2006-11-28 18:36:43.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/raid/raid5.h	2006-11-28 18:36:43.000000000 -0800
@@ -238,7 +238,7 @@
 	 */
 	int			active_name;
 	char			cache_name[2][20];
-	kmem_cache_t		*slab_cache; /* for allocating stripes */
+	struct kmem_cache		*slab_cache; /* for allocating stripes */
 
 	int			seq_flush, seq_write;
 	int			quiesce;
Index: linux-2.6.19-rc6-mm1/include/linux/delayacct.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/delayacct.h	2006-11-28 18:36:44.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/delayacct.h	2006-11-28 18:36:44.000000000 -0800
@@ -30,7 +30,7 @@
 #ifdef CONFIG_TASK_DELAY_ACCT
 
 extern int delayacct_on;	/* Delay accounting turned on/off */
-extern kmem_cache_t *delayacct_cache;
+extern struct kmem_cache *delayacct_cache;
 extern void delayacct_init(void);
 extern void __delayacct_tsk_init(struct task_struct *);
 extern void __delayacct_tsk_exit(struct task_struct *);
Index: linux-2.6.19-rc6-mm1/include/linux/i2o.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/i2o.h	2006-11-28 18:36:46.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/i2o.h	2006-11-28 18:36:46.000000000 -0800
@@ -490,7 +490,7 @@
  */
 struct i2o_pool {
 	char *name;
-	kmem_cache_t *slab;
+	struct kmem_cache *slab;
 	mempool_t *mempool;
 };
 
Index: linux-2.6.19-rc6-mm1/include/linux/jbd.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/jbd.h	2006-11-28 18:36:48.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/jbd.h	2006-11-28 18:36:48.000000000 -0800
@@ -948,7 +948,7 @@
 /*
  * handle management
  */
-extern kmem_cache_t *jbd_handle_cache;
+extern struct kmem_cache *jbd_handle_cache;
 
 static inline handle_t *jbd_alloc_handle(gfp_t gfp_flags)
 {
Index: linux-2.6.19-rc6-mm1/include/linux/skbuff.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/skbuff.h	2006-11-28 18:36:50.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/skbuff.h	2006-11-28 18:36:50.000000000 -0800
@@ -347,7 +347,7 @@
 	return __alloc_skb(size, priority, 1, -1);
 }
 
-extern struct sk_buff *alloc_skb_from_cache(kmem_cache_t *cp,
+extern struct sk_buff *alloc_skb_from_cache(struct kmem_cache *cp,
 					    unsigned int size,
 					    gfp_t priority);
 extern void	       kfree_skbmem(struct sk_buff *skb);
Index: linux-2.6.19-rc6-mm1/include/linux/jbd2.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/jbd2.h	2006-11-28 18:36:52.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/jbd2.h	2006-11-28 18:36:52.000000000 -0800
@@ -957,7 +957,7 @@
 /*
  * handle management
  */
-extern kmem_cache_t *jbd2_handle_cache;
+extern struct kmem_cache *jbd2_handle_cache;
 
 static inline handle_t *jbd_alloc_handle(gfp_t gfp_flags)
 {
Index: linux-2.6.19-rc6-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/rmap.h	2006-11-28 18:36:54.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/rmap.h	2006-11-28 18:36:54.000000000 -0800
@@ -30,7 +30,7 @@
 
 #ifdef CONFIG_MMU
 
-extern kmem_cache_t *anon_vma_cachep;
+extern struct kmem_cache *anon_vma_cachep;
 
 static inline struct anon_vma *anon_vma_alloc(void)
 {
Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-28 18:36:55.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-28 18:40:17.000000000 -0800
@@ -9,9 +9,6 @@
 
 #if	defined(__KERNEL__)
 
-/* kmem_cache_t exists for legacy reasons and is not used by code in mm */
-typedef struct kmem_cache kmem_cache_t;
-
 #include	<linux/gfp.h>
 #include	<linux/init.h>
 #include	<linux/types.h>
Index: linux-2.6.19-rc6-mm1/include/linux/taskstats_kern.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/taskstats_kern.h	2006-11-28 18:37:00.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/taskstats_kern.h	2006-11-28 18:37:00.000000000 -0800
@@ -12,7 +12,7 @@
 #include <net/genetlink.h>
 
 #ifdef CONFIG_TASKSTATS
-extern kmem_cache_t *taskstats_cache;
+extern struct kmem_cache *taskstats_cache;
 extern struct mutex taskstats_exit_mutex;
 
 static inline void taskstats_tgid_init(struct signal_struct *sig)
Index: linux-2.6.19-rc6-mm1/include/asm-powerpc/pgalloc.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/asm-powerpc/pgalloc.h	2006-11-28 18:37:02.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/asm-powerpc/pgalloc.h	2006-11-28 18:37:02.000000000 -0800
@@ -11,7 +11,7 @@
 #include <linux/cpumask.h>
 #include <linux/percpu.h>
 
-extern kmem_cache_t *pgtable_cache[];
+extern struct kmem_cache *pgtable_cache[];
 
 #ifdef CONFIG_PPC_64K_PAGES
 #define PTE_CACHE_NUM	0
Index: linux-2.6.19-rc6-mm1/include/asm-arm26/pgalloc.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/asm-arm26/pgalloc.h	2006-11-28 18:37:04.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/asm-arm26/pgalloc.h	2006-11-28 18:37:04.000000000 -0800
@@ -15,7 +15,7 @@
 #include <asm/tlbflush.h>
 #include <linux/slab.h>
 
-extern kmem_cache_t *pte_cache;
+extern struct kmem_cache *pte_cache;
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr){
 	return kmem_cache_alloc(pte_cache, GFP_KERNEL);
Index: linux-2.6.19-rc6-mm1/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/asm-i386/pgtable.h	2006-11-28 18:37:06.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/asm-i386/pgtable.h	2006-11-28 18:37:06.000000000 -0800
@@ -35,14 +35,14 @@
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
 extern unsigned long empty_zero_page[1024];
 extern pgd_t swapper_pg_dir[1024];
-extern kmem_cache_t *pgd_cache;
-extern kmem_cache_t *pmd_cache;
+extern struct kmem_cache *pgd_cache;
+extern struct kmem_cache *pmd_cache;
 extern spinlock_t pgd_lock;
 extern struct page *pgd_list;
 
-void pmd_ctor(void *, kmem_cache_t *, unsigned long);
-void pgd_ctor(void *, kmem_cache_t *, unsigned long);
-void pgd_dtor(void *, kmem_cache_t *, unsigned long);
+void pmd_ctor(void *, struct kmem_cache *, unsigned long);
+void pgd_ctor(void *, struct kmem_cache *, unsigned long);
+void pgd_dtor(void *, struct kmem_cache *, unsigned long);
 void pgtable_cache_init(void);
 void paging_init(void);
 
Index: linux-2.6.19-rc6-mm1/include/asm-sparc64/pgalloc.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/asm-sparc64/pgalloc.h	2006-11-28 18:37:08.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/asm-sparc64/pgalloc.h	2006-11-28 18:37:08.000000000 -0800
@@ -13,7 +13,7 @@
 #include <asm/page.h>
 
 /* Page table allocation/freeing. */
-extern kmem_cache_t *pgtable_cache;
+extern struct kmem_cache *pgtable_cache;
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
Index: linux-2.6.19-rc6-mm1/ipc/mqueue.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/ipc/mqueue.c	2006-11-28 18:37:10.000000000 -0800
+++ linux-2.6.19-rc6-mm1/ipc/mqueue.c	2006-11-28 18:37:10.000000000 -0800
@@ -90,7 +90,7 @@
 static void remove_notification(struct mqueue_inode_info *info);
 
 static spinlock_t mq_lock;
-static kmem_cache_t *mqueue_inode_cachep;
+static struct kmem_cache *mqueue_inode_cachep;
 static struct vfsmount *mqueue_mnt;
 
 static unsigned int queues_count;
@@ -211,7 +211,7 @@
 	return get_sb_single(fs_type, flags, data, mqueue_fill_super, mnt);
 }
 
-static void init_once(void *foo, kmem_cache_t * cachep, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct mqueue_inode_info *p = (struct mqueue_inode_info *) foo;
 
Index: linux-2.6.19-rc6-mm1/kernel/delayacct.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/delayacct.c	2006-11-28 18:37:12.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/delayacct.c	2006-11-28 18:37:12.000000000 -0800
@@ -20,7 +20,7 @@
 #include <linux/delayacct.h>
 
 int delayacct_on __read_mostly = 1;	/* Delay accounting turned on/off */
-kmem_cache_t *delayacct_cache;
+struct kmem_cache *delayacct_cache;
 
 static int __init delayacct_setup_disable(char *str)
 {
Index: linux-2.6.19-rc6-mm1/kernel/taskstats.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/taskstats.c	2006-11-28 18:37:14.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/taskstats.c	2006-11-28 18:37:14.000000000 -0800
@@ -34,7 +34,7 @@
 
 static DEFINE_PER_CPU(__u32, taskstats_seqnum) = { 0 };
 static int family_registered;
-kmem_cache_t *taskstats_cache;
+struct kmem_cache *taskstats_cache;
 
 static struct genl_family family = {
 	.id		= GENL_ID_GENERATE,
Index: linux-2.6.19-rc6-mm1/kernel/pid.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/pid.c	2006-11-28 18:37:16.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/pid.c	2006-11-28 18:37:16.000000000 -0800
@@ -31,7 +31,7 @@
 #define pid_hashfn(nr) hash_long((unsigned long)nr, pidhash_shift)
 static struct hlist_head *pid_hash;
 static int pidhash_shift;
-static kmem_cache_t *pid_cachep;
+static struct kmem_cache *pid_cachep;
 
 int pid_max = PID_MAX_DEFAULT;
 
Index: linux-2.6.19-rc6-mm1/kernel/signal.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/signal.c	2006-11-28 18:37:18.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/signal.c	2006-11-28 18:37:18.000000000 -0800
@@ -38,7 +38,7 @@
  * SLAB caches for signal bits.
  */
 
-static kmem_cache_t *sigqueue_cachep;
+static struct kmem_cache *sigqueue_cachep;
 
 /*
  * In POSIX a signal is sent either to a specific thread (Linux task)
Index: linux-2.6.19-rc6-mm1/kernel/posix-timers.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/posix-timers.c	2006-11-28 18:37:20.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/posix-timers.c	2006-11-28 18:37:20.000000000 -0800
@@ -70,7 +70,7 @@
 /*
  * Lets keep our timers in a slab cache :-)
  */
-static kmem_cache_t *posix_timers_cache;
+static struct kmem_cache *posix_timers_cache;
 static struct idr posix_timers_id;
 static DEFINE_SPINLOCK(idr_lock);
 
Index: linux-2.6.19-rc6-mm1/kernel/fork.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/fork.c	2006-11-28 18:37:21.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/fork.c	2006-11-28 18:37:21.000000000 -0800
@@ -83,26 +83,26 @@
 #ifndef __HAVE_ARCH_TASK_STRUCT_ALLOCATOR
 # define alloc_task_struct()	kmem_cache_alloc(task_struct_cachep, GFP_KERNEL)
 # define free_task_struct(tsk)	kmem_cache_free(task_struct_cachep, (tsk))
-static kmem_cache_t *task_struct_cachep;
+static struct kmem_cache *task_struct_cachep;
 #endif
 
 /* SLAB cache for signal_struct structures (tsk->signal) */
-static kmem_cache_t *signal_cachep;
+static struct kmem_cache *signal_cachep;
 
 /* SLAB cache for sighand_struct structures (tsk->sighand) */
-kmem_cache_t *sighand_cachep;
+struct kmem_cache *sighand_cachep;
 
 /* SLAB cache for files_struct structures (tsk->files) */
-kmem_cache_t *files_cachep;
+struct kmem_cache *files_cachep;
 
 /* SLAB cache for fs_struct structures (tsk->fs) */
-kmem_cache_t *fs_cachep;
+struct kmem_cache *fs_cachep;
 
 /* SLAB cache for vm_area_struct structures */
-kmem_cache_t *vm_area_cachep;
+struct kmem_cache *vm_area_cachep;
 
 /* SLAB cache for mm_struct structures (tsk->mm) */
-static kmem_cache_t *mm_cachep;
+static struct kmem_cache *mm_cachep;
 
 void free_task(struct task_struct *tsk)
 {
@@ -1417,7 +1417,7 @@
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
 
-static void sighand_ctor(void *data, kmem_cache_t *cachep, unsigned long flags)
+static void sighand_ctor(void *data, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct sighand_struct *sighand = data;
 
Index: linux-2.6.19-rc6-mm1/kernel/kevent/kevent_poll.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/kevent/kevent_poll.c	2006-11-28 18:37:23.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/kevent/kevent_poll.c	2006-11-28 18:37:23.000000000 -0800
@@ -24,8 +24,8 @@
 #include <linux/poll.h>
 #include <linux/fs.h>
 
-static kmem_cache_t *kevent_poll_container_cache;
-static kmem_cache_t *kevent_poll_priv_cache;
+static struct kmem_cache *kevent_poll_container_cache;
+static struct kmem_cache *kevent_poll_priv_cache;
 
 struct kevent_poll_ctl
 {
Index: linux-2.6.19-rc6-mm1/kernel/kevent/kevent_user.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/kevent/kevent_user.c	2006-11-28 18:37:26.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/kevent/kevent_user.c	2006-11-28 18:37:26.000000000 -0800
@@ -33,7 +33,7 @@
 #include <asm/io.h>
 
 static const char kevent_name[] = "kevent";
-static kmem_cache_t *kevent_cache __read_mostly;
+static struct kmem_cache *kevent_cache __read_mostly;
 
 /*
  * kevents are pollable, return POLLIN and POLLRDNORM
Index: linux-2.6.19-rc6-mm1/kernel/user.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/kernel/user.c	2006-11-28 18:37:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/kernel/user.c	2006-11-28 18:37:28.000000000 -0800
@@ -26,7 +26,7 @@
 #define __uidhashfn(uid)	(((uid >> UIDHASH_BITS) + uid) & UIDHASH_MASK)
 #define uidhashentry(uid)	(uidhash_table + __uidhashfn((uid)))
 
-static kmem_cache_t *uid_cachep;
+static struct kmem_cache *uid_cachep;
 static struct list_head uidhash_table[UIDHASH_SZ];
 
 /*
Index: linux-2.6.19-rc6-mm1/lib/idr.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/lib/idr.c	2006-11-28 18:37:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/lib/idr.c	2006-11-28 18:37:30.000000000 -0800
@@ -33,7 +33,7 @@
 #include <linux/string.h>
 #include <linux/idr.h>
 
-static kmem_cache_t *idr_layer_cache;
+static struct kmem_cache *idr_layer_cache;
 
 static struct idr_layer *alloc_layer(struct idr *idp)
 {
@@ -445,7 +445,7 @@
 }
 EXPORT_SYMBOL(idr_replace);
 
-static void idr_cache_ctor(void * idr_layer, kmem_cache_t *idr_layer_cache,
+static void idr_cache_ctor(void * idr_layer, struct kmem_cache *idr_layer_cache,
 		unsigned long flags)
 {
 	memset(idr_layer, 0, sizeof(struct idr_layer));
Index: linux-2.6.19-rc6-mm1/lib/radix-tree.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/lib/radix-tree.c	2006-11-28 18:37:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/lib/radix-tree.c	2006-11-28 18:37:32.000000000 -0800
@@ -67,7 +67,7 @@
 /*
  * Radix tree node cache.
  */
-static kmem_cache_t *radix_tree_node_cachep;
+static struct kmem_cache *radix_tree_node_cachep;
 
 /*
  * Per-cpu pool of preloaded nodes
@@ -1067,7 +1067,7 @@
 EXPORT_SYMBOL(radix_tree_tagged);
 
 static void
-radix_tree_node_ctor(void *node, kmem_cache_t *cachep, unsigned long flags)
+radix_tree_node_ctor(void *node, struct kmem_cache *cachep, unsigned long flags)
 {
 	memset(node, 0, sizeof(struct radix_tree_node));
 }
Index: linux-2.6.19-rc6-mm1/mm/slab.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/slab.c	2006-11-28 18:37:34.000000000 -0800
+++ linux-2.6.19-rc6-mm1/mm/slab.c	2006-11-28 18:37:34.000000000 -0800
@@ -4409,7 +4409,7 @@
 	return obj_size(virt_to_cache(objp));
 }
 
-void kmem_set_shrinker(kmem_cache_t *cachep, struct shrinker *shrinker)
+void kmem_set_shrinker(struct kmem_cache *cachep, struct shrinker *shrinker)
 {
 	cachep->shrinker = shrinker;
 }
Index: linux-2.6.19-rc6-mm1/net/dccp/ccids/lib/loss_interval.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/dccp/ccids/lib/loss_interval.h	2006-11-28 18:37:36.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/dccp/ccids/lib/loss_interval.h	2006-11-28 18:37:36.000000000 -0800
@@ -20,7 +20,7 @@
 #define DCCP_LI_HIST_IVAL_F_LENGTH  8
 
 struct dccp_li_hist {
-	kmem_cache_t *dccplih_slab;
+	struct kmem_cache *dccplih_slab;
 };
 
 extern struct dccp_li_hist *dccp_li_hist_new(const char *name);
Index: linux-2.6.19-rc6-mm1/net/dccp/ccids/lib/packet_history.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/dccp/ccids/lib/packet_history.h	2006-11-28 18:37:38.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/dccp/ccids/lib/packet_history.h	2006-11-28 18:37:38.000000000 -0800
@@ -68,14 +68,14 @@
 };
 
 struct dccp_tx_hist {
-	kmem_cache_t *dccptxh_slab;
+	struct kmem_cache *dccptxh_slab;
 };
 
 extern struct dccp_tx_hist *dccp_tx_hist_new(const char *name);
 extern void dccp_tx_hist_delete(struct dccp_tx_hist *hist);
 
 struct dccp_rx_hist {
-	kmem_cache_t *dccprxh_slab;
+	struct kmem_cache *dccprxh_slab;
 };
 
 extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
Index: linux-2.6.19-rc6-mm1/net/dccp/ccid.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/dccp/ccid.c	2006-11-28 18:37:41.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/dccp/ccid.c	2006-11-28 18:37:41.000000000 -0800
@@ -55,9 +55,9 @@
 #define ccids_read_unlock() do { } while(0)
 #endif
 
-static kmem_cache_t *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
+static struct kmem_cache *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
 {
-	kmem_cache_t *slab;
+	struct kmem_cache *slab;
 	char slab_name_fmt[32], *slab_name;
 	va_list args;
 
@@ -75,7 +75,7 @@
 	return slab;
 }
 
-static void ccid_kmem_cache_destroy(kmem_cache_t *slab)
+static void ccid_kmem_cache_destroy(struct kmem_cache *slab)
 {
 	if (slab != NULL) {
 		const char *name = kmem_cache_name(slab);
Index: linux-2.6.19-rc6-mm1/net/dccp/ccid.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/dccp/ccid.h	2006-11-28 18:37:43.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/dccp/ccid.h	2006-11-28 18:37:43.000000000 -0800
@@ -27,9 +27,9 @@
 	unsigned char	ccid_id;
 	const char	*ccid_name;
 	struct module	*ccid_owner;
-	kmem_cache_t	*ccid_hc_rx_slab;
+	struct kmem_cache	*ccid_hc_rx_slab;
 	__u32		ccid_hc_rx_obj_size;
-	kmem_cache_t	*ccid_hc_tx_slab;
+	struct kmem_cache	*ccid_hc_tx_slab;
 	__u32		ccid_hc_tx_obj_size;
 	int		(*ccid_hc_rx_init)(struct ccid *ccid, struct sock *sk);
 	int		(*ccid_hc_tx_init)(struct ccid *ccid, struct sock *sk);
Index: linux-2.6.19-rc6-mm1/net/dccp/ackvec.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/dccp/ackvec.c	2006-11-28 18:37:45.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/dccp/ackvec.c	2006-11-28 18:37:45.000000000 -0800
@@ -21,8 +21,8 @@
 
 #include <net/sock.h>
 
-static kmem_cache_t *dccp_ackvec_slab;
-static kmem_cache_t *dccp_ackvec_record_slab;
+static struct kmem_cache *dccp_ackvec_slab;
+static struct kmem_cache *dccp_ackvec_record_slab;
 
 static struct dccp_ackvec_record *dccp_ackvec_record_new(void)
 {
Index: linux-2.6.19-rc6-mm1/net/core/skbuff.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/core/skbuff.c	2006-11-28 18:37:47.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/core/skbuff.c	2006-11-28 18:37:47.000000000 -0800
@@ -67,8 +67,8 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>
 
-static kmem_cache_t *skbuff_head_cache __read_mostly;
-static kmem_cache_t *skbuff_fclone_cache __read_mostly;
+static struct kmem_cache *skbuff_head_cache __read_mostly;
+static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 
 /*
  *	Keep out-of-line to prevent kernel bloat.
@@ -164,7 +164,7 @@
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 			    int fclone, int node)
 {
-	kmem_cache_t *cache;
+	struct kmem_cache *cache;
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	u8 *data;
@@ -231,7 +231,7 @@
  *	Buffers may only be allocated from interrupts using a @gfp_mask of
  *	%GFP_ATOMIC.
  */
-struct sk_buff *alloc_skb_from_cache(kmem_cache_t *cp,
+struct sk_buff *alloc_skb_from_cache(struct kmem_cache *cp,
 				     unsigned int size,
 				     gfp_t gfp_mask)
 {
Index: linux-2.6.19-rc6-mm1/net/core/flow.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/core/flow.c	2006-11-28 18:37:49.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/core/flow.c	2006-11-28 18:37:49.000000000 -0800
@@ -44,7 +44,7 @@
 
 #define flow_table(cpu) (per_cpu(flow_tables, cpu))
 
-static kmem_cache_t *flow_cachep __read_mostly;
+static struct kmem_cache *flow_cachep __read_mostly;
 
 static int flow_lwm, flow_hwm;
 
Index: linux-2.6.19-rc6-mm1/net/core/sock.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/core/sock.c	2006-11-28 18:37:52.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/core/sock.c	2006-11-28 18:37:52.000000000 -0800
@@ -827,7 +827,7 @@
 		      struct proto *prot, int zero_it)
 {
 	struct sock *sk = NULL;
-	kmem_cache_t *slab = prot->slab;
+	struct kmem_cache *slab = prot->slab;
 
 	if (slab != NULL)
 		sk = kmem_cache_alloc(slab, priority);
Index: linux-2.6.19-rc6-mm1/net/ipv4/ipvs/ip_vs_conn.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/ipvs/ip_vs_conn.c	2006-11-28 18:37:54.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/ipvs/ip_vs_conn.c	2006-11-28 18:37:54.000000000 -0800
@@ -44,7 +44,7 @@
 static struct list_head *ip_vs_conn_tab;
 
 /*  SLAB cache for IPVS connections */
-static kmem_cache_t *ip_vs_conn_cachep __read_mostly;
+static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
 
 /*  counter for current IPVS connections */
 static atomic_t ip_vs_conn_count = ATOMIC_INIT(0);
Index: linux-2.6.19-rc6-mm1/net/ipv4/inetpeer.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/inetpeer.c	2006-11-28 18:37:56.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/inetpeer.c	2006-11-28 18:37:56.000000000 -0800
@@ -73,7 +73,7 @@
 /* Exported for inet_getid inline function.  */
 DEFINE_SPINLOCK(inet_peer_idlock);
 
-static kmem_cache_t *peer_cachep __read_mostly;
+static struct kmem_cache *peer_cachep __read_mostly;
 
 #define node_height(x) x->avl_height
 static struct inet_peer peer_fake_node = {
Index: linux-2.6.19-rc6-mm1/net/ipv4/netfilter/ip_conntrack_core.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/netfilter/ip_conntrack_core.c	2006-11-28 18:37:58.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/netfilter/ip_conntrack_core.c	2006-11-28 18:37:58.000000000 -0800
@@ -68,8 +68,8 @@
 unsigned int ip_conntrack_htable_size __read_mostly = 0;
 int ip_conntrack_max __read_mostly;
 struct list_head *ip_conntrack_hash __read_mostly;
-static kmem_cache_t *ip_conntrack_cachep __read_mostly;
-static kmem_cache_t *ip_conntrack_expect_cachep __read_mostly;
+static struct kmem_cache *ip_conntrack_cachep __read_mostly;
+static struct kmem_cache *ip_conntrack_expect_cachep __read_mostly;
 struct ip_conntrack ip_conntrack_untracked;
 unsigned int ip_ct_log_invalid __read_mostly;
 static LIST_HEAD(unconfirmed);
Index: linux-2.6.19-rc6-mm1/net/ipv4/netfilter/ipt_hashlimit.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/netfilter/ipt_hashlimit.c	2006-11-28 18:38:01.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/netfilter/ipt_hashlimit.c	2006-11-28 18:38:01.000000000 -0800
@@ -93,7 +93,7 @@
 static DEFINE_SPINLOCK(hashlimit_lock);	/* protects htables list */
 static DEFINE_MUTEX(hlimit_mutex);	/* additional checkentry protection */
 static HLIST_HEAD(hashlimit_htables);
-static kmem_cache_t *hashlimit_cachep __read_mostly;
+static struct kmem_cache *hashlimit_cachep __read_mostly;
 
 static inline int dst_cmp(const struct dsthash_ent *ent, struct dsthash_dst *b)
 {
Index: linux-2.6.19-rc6-mm1/net/ipv4/inet_hashtables.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/inet_hashtables.c	2006-11-28 18:38:03.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/inet_hashtables.c	2006-11-28 18:38:03.000000000 -0800
@@ -27,7 +27,7 @@
  * Allocate and initialize a new local port bind bucket.
  * The bindhash mutex for snum's hash chain must be held here.
  */
-struct inet_bind_bucket *inet_bind_bucket_create(kmem_cache_t *cachep,
+struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 						 struct inet_bind_hashbucket *head,
 						 const unsigned short snum)
 {
@@ -45,7 +45,7 @@
 /*
  * Caller must hold hashbucket lock for this tb with local BH disabled
  */
-void inet_bind_bucket_destroy(kmem_cache_t *cachep, struct inet_bind_bucket *tb)
+void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket *tb)
 {
 	if (hlist_empty(&tb->owners)) {
 		__hlist_del(&tb->node);
Index: linux-2.6.19-rc6-mm1/net/ipv4/ipmr.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/ipmr.c	2006-11-28 18:38:05.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/ipmr.c	2006-11-28 18:38:05.000000000 -0800
@@ -105,7 +105,7 @@
    In this case data path is free of exclusive locks at all.
  */
 
-static kmem_cache_t *mrt_cachep __read_mostly;
+static struct kmem_cache *mrt_cachep __read_mostly;
 
 static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local);
 static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert);
Index: linux-2.6.19-rc6-mm1/net/ipv4/fib_hash.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/fib_hash.c	2006-11-28 18:38:07.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/fib_hash.c	2006-11-28 18:38:07.000000000 -0800
@@ -45,8 +45,8 @@
 
 #include "fib_lookup.h"
 
-static kmem_cache_t *fn_hash_kmem __read_mostly;
-static kmem_cache_t *fn_alias_kmem __read_mostly;
+static struct kmem_cache *fn_hash_kmem __read_mostly;
+static struct kmem_cache *fn_alias_kmem __read_mostly;
 
 struct fib_node {
 	struct hlist_node	fn_hash;
Index: linux-2.6.19-rc6-mm1/net/ipv4/fib_trie.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/fib_trie.c	2006-11-28 18:38:10.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/fib_trie.c	2006-11-28 18:38:10.000000000 -0800
@@ -172,7 +172,7 @@
 static struct tnode *halve(struct trie *t, struct tnode *tn);
 static void tnode_free(struct tnode *tn);
 
-static kmem_cache_t *fn_alias_kmem __read_mostly;
+static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct trie *trie_local = NULL, *trie_main = NULL;
 
 
Index: linux-2.6.19-rc6-mm1/net/ipv6/ip6_fib.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv6/ip6_fib.c	2006-11-28 18:38:12.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv6/ip6_fib.c	2006-11-28 18:38:12.000000000 -0800
@@ -50,7 +50,7 @@
 
 struct rt6_statistics	rt6_stats;
 
-static kmem_cache_t * fib6_node_kmem __read_mostly;
+static struct kmem_cache * fib6_node_kmem __read_mostly;
 
 enum fib_walk_state_t
 {
Index: linux-2.6.19-rc6-mm1/net/ipv6/xfrm6_tunnel.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv6/xfrm6_tunnel.c	2006-11-28 18:38:14.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv6/xfrm6_tunnel.c	2006-11-28 18:38:14.000000000 -0800
@@ -50,7 +50,7 @@
 #define XFRM6_TUNNEL_SPI_MIN	1
 #define XFRM6_TUNNEL_SPI_MAX	0xffffffff
 
-static kmem_cache_t *xfrm6_tunnel_spi_kmem __read_mostly;
+static struct kmem_cache *xfrm6_tunnel_spi_kmem __read_mostly;
 
 #define XFRM6_TUNNEL_SPI_BYADDR_HSIZE 256
 #define XFRM6_TUNNEL_SPI_BYSPI_HSIZE 256
Index: linux-2.6.19-rc6-mm1/net/sctp/protocol.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/sctp/protocol.c	2006-11-28 18:38:17.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/sctp/protocol.c	2006-11-28 18:38:17.000000000 -0800
@@ -79,8 +79,8 @@
 static struct sctp_af *sctp_af_v4_specific;
 static struct sctp_af *sctp_af_v6_specific;
 
-kmem_cache_t *sctp_chunk_cachep __read_mostly;
-kmem_cache_t *sctp_bucket_cachep __read_mostly;
+struct kmem_cache *sctp_chunk_cachep __read_mostly;
+struct kmem_cache *sctp_bucket_cachep __read_mostly;
 
 /* Return the address of the control sock. */
 struct sock *sctp_get_ctl_sock(void)
Index: linux-2.6.19-rc6-mm1/net/sctp/sm_make_chunk.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/sctp/sm_make_chunk.c	2006-11-28 18:38:19.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/sctp/sm_make_chunk.c	2006-11-28 18:38:19.000000000 -0800
@@ -65,7 +65,7 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
-extern kmem_cache_t *sctp_chunk_cachep;
+extern struct kmem_cache *sctp_chunk_cachep;
 
 SCTP_STATIC
 struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
Index: linux-2.6.19-rc6-mm1/net/sctp/socket.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/sctp/socket.c	2006-11-28 18:38:21.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/sctp/socket.c	2006-11-28 18:38:21.000000000 -0800
@@ -107,7 +107,7 @@
 			      struct sctp_association *, sctp_socket_type_t);
 static char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;
 
-extern kmem_cache_t *sctp_bucket_cachep;
+extern struct kmem_cache *sctp_bucket_cachep;
 
 /* Get the sndbuf space available at the time on the association.  */
 static inline int sctp_wspace(struct sctp_association *asoc)
Index: linux-2.6.19-rc6-mm1/net/tipc/handler.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/tipc/handler.c	2006-11-28 18:38:23.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/tipc/handler.c	2006-11-28 18:38:23.000000000 -0800
@@ -42,7 +42,7 @@
 	unsigned long data;
 };
 
-static kmem_cache_t *tipc_queue_item_cache;
+static struct kmem_cache *tipc_queue_item_cache;
 static struct list_head signal_queue_head;
 static DEFINE_SPINLOCK(qitem_lock);
 static int handler_enabled = 0;
Index: linux-2.6.19-rc6-mm1/net/xfrm/xfrm_input.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/xfrm/xfrm_input.c	2006-11-28 18:38:26.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/xfrm/xfrm_input.c	2006-11-28 18:38:26.000000000 -0800
@@ -12,7 +12,7 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 
-static kmem_cache_t *secpath_cachep __read_mostly;
+static struct kmem_cache *secpath_cachep __read_mostly;
 
 void __secpath_destroy(struct sec_path *sp)
 {
Index: linux-2.6.19-rc6-mm1/net/xfrm/xfrm_policy.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/xfrm/xfrm_policy.c	2006-11-28 18:38:28.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/xfrm/xfrm_policy.c	2006-11-28 18:38:28.000000000 -0800
@@ -39,7 +39,7 @@
 static DEFINE_RWLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
 
-static kmem_cache_t *xfrm_dst_cache __read_mostly;
+static struct kmem_cache *xfrm_dst_cache __read_mostly;
 
 static struct work_struct xfrm_policy_gc_work;
 static HLIST_HEAD(xfrm_policy_gc_list);
Index: linux-2.6.19-rc6-mm1/net/netfilter/nf_conntrack_core.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/netfilter/nf_conntrack_core.c	2006-11-28 18:38:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/netfilter/nf_conntrack_core.c	2006-11-28 18:38:30.000000000 -0800
@@ -79,7 +79,7 @@
 unsigned int nf_conntrack_htable_size __read_mostly = 0;
 int nf_conntrack_max __read_mostly;
 struct list_head *nf_conntrack_hash __read_mostly;
-static kmem_cache_t *nf_conntrack_expect_cachep __read_mostly;
+static struct kmem_cache *nf_conntrack_expect_cachep __read_mostly;
 struct nf_conn nf_conntrack_untracked;
 unsigned int nf_ct_log_invalid __read_mostly;
 static LIST_HEAD(unconfirmed);
@@ -171,7 +171,7 @@
 	size_t size;
 
 	/* slab cache pointer */
-	kmem_cache_t *cachep;
+	struct kmem_cache *cachep;
 
 	/* allocated slab cache + modules which uses this slab cache */
 	int use;
@@ -289,7 +289,7 @@
 {
 	int ret = 0;
 	char *cache_name;
-	kmem_cache_t *cachep;
+	struct kmem_cache *cachep;
 
 	DEBUGP("nf_conntrack_register_cache: features=0x%x, name=%s, size=%d\n",
 	       features, name, size);
@@ -367,7 +367,7 @@
 /* FIXME: In the current, only nf_conntrack_cleanup() can call this function. */
 void nf_conntrack_unregister_cache(u_int32_t features)
 {
-	kmem_cache_t *cachep;
+	struct kmem_cache *cachep;
 	char *name;
 
 	/*
Index: linux-2.6.19-rc6-mm1/net/bridge/br_fdb.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/bridge/br_fdb.c	2006-11-28 18:38:33.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/bridge/br_fdb.c	2006-11-28 18:38:33.000000000 -0800
@@ -23,7 +23,7 @@
 #include <asm/atomic.h>
 #include "br_private.h"
 
-static kmem_cache_t *br_fdb_cache __read_mostly;
+static struct kmem_cache *br_fdb_cache __read_mostly;
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		      const unsigned char *addr);
 
Index: linux-2.6.19-rc6-mm1/net/decnet/dn_table.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/decnet/dn_table.c	2006-11-28 18:38:36.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/decnet/dn_table.c	2006-11-28 18:38:36.000000000 -0800
@@ -79,7 +79,7 @@
 static struct hlist_head dn_fib_table_hash[DN_FIB_TABLE_HASHSZ];
 static DEFINE_RWLOCK(dn_fib_tables_lock);
 
-static kmem_cache_t *dn_hash_kmem __read_mostly;
+static struct kmem_cache *dn_hash_kmem __read_mostly;
 static int dn_fib_hash_zombies;
 
 static inline dn_fib_idx_t dn_hash(dn_fib_key_t key, struct dn_zone *dz)
Index: linux-2.6.19-rc6-mm1/net/sunrpc/sched.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/sunrpc/sched.c	2006-11-28 18:38:39.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/sunrpc/sched.c	2006-11-28 18:38:39.000000000 -0800
@@ -34,8 +34,8 @@
 #define RPC_BUFFER_MAXSIZE	(2048)
 #define RPC_BUFFER_POOLSIZE	(8)
 #define RPC_TASK_POOLSIZE	(8)
-static kmem_cache_t	*rpc_task_slabp __read_mostly;
-static kmem_cache_t	*rpc_buffer_slabp __read_mostly;
+static struct kmem_cache	*rpc_task_slabp __read_mostly;
+static struct kmem_cache	*rpc_buffer_slabp __read_mostly;
 static mempool_t	*rpc_task_mempool __read_mostly;
 static mempool_t	*rpc_buffer_mempool __read_mostly;
 
Index: linux-2.6.19-rc6-mm1/net/sunrpc/rpc_pipe.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/sunrpc/rpc_pipe.c	2006-11-28 18:38:41.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/sunrpc/rpc_pipe.c	2006-11-28 18:38:41.000000000 -0800
@@ -33,7 +33,7 @@
 static struct file_system_type rpc_pipe_fs_type;
 
 
-static kmem_cache_t *rpc_inode_cachep __read_mostly;
+static struct kmem_cache *rpc_inode_cachep __read_mostly;
 
 #define RPC_UPCALL_TIMEOUT (30*HZ)
 
@@ -823,7 +823,7 @@
 };
 
 static void
-init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
 {
 	struct rpc_inode *rpci = (struct rpc_inode *) foo;
 
Index: linux-2.6.19-rc6-mm1/net/socket.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/socket.c	2006-11-28 18:38:44.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/socket.c	2006-11-28 18:38:44.000000000 -0800
@@ -231,7 +231,7 @@
 
 #define SOCKFS_MAGIC 0x534F434B
 
-static kmem_cache_t *sock_inode_cachep __read_mostly;
+static struct kmem_cache *sock_inode_cachep __read_mostly;
 
 static struct inode *sock_alloc_inode(struct super_block *sb)
 {
@@ -258,7 +258,7 @@
 			container_of(inode, struct socket_alloc, vfs_inode));
 }
 
-static void init_once(void *foo, kmem_cache_t *cachep, unsigned long flags)
+static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
 {
 	struct socket_alloc *ei = (struct socket_alloc *)foo;
 
Index: linux-2.6.19-rc6-mm1/security/keys/key.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/security/keys/key.c	2006-11-28 18:38:46.000000000 -0800
+++ linux-2.6.19-rc6-mm1/security/keys/key.c	2006-11-28 18:38:46.000000000 -0800
@@ -20,7 +20,7 @@
 #include <linux/err.h>
 #include "internal.h"
 
-static kmem_cache_t	*key_jar;
+static struct kmem_cache	*key_jar;
 struct rb_root		key_serial_tree; /* tree of keys indexed by serial */
 DEFINE_SPINLOCK(key_serial_lock);
 
Index: linux-2.6.19-rc6-mm1/security/selinux/ss/avtab.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/security/selinux/ss/avtab.c	2006-11-28 18:38:49.000000000 -0800
+++ linux-2.6.19-rc6-mm1/security/selinux/ss/avtab.c	2006-11-28 18:38:49.000000000 -0800
@@ -28,7 +28,7 @@
  (keyp->source_type << 9)) & \
  AVTAB_HASH_MASK)
 
-static kmem_cache_t *avtab_node_cachep;
+static struct kmem_cache *avtab_node_cachep;
 
 static struct avtab_node*
 avtab_insert_node(struct avtab *h, int hvalue,
Index: linux-2.6.19-rc6-mm1/security/selinux/avc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/security/selinux/avc.c	2006-11-28 18:38:51.000000000 -0800
+++ linux-2.6.19-rc6-mm1/security/selinux/avc.c	2006-11-28 18:38:51.000000000 -0800
@@ -124,7 +124,7 @@
 
 static struct avc_cache avc_cache;
 static struct avc_callback_node *avc_callbacks;
-static kmem_cache_t *avc_node_cachep;
+static struct kmem_cache *avc_node_cachep;
 
 static inline int avc_hash(u32 ssid, u32 tsid, u16 tclass)
 {
Index: linux-2.6.19-rc6-mm1/security/selinux/hooks.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/security/selinux/hooks.c	2006-11-28 18:38:54.000000000 -0800
+++ linux-2.6.19-rc6-mm1/security/selinux/hooks.c	2006-11-28 18:38:54.000000000 -0800
@@ -124,7 +124,7 @@
 static LIST_HEAD(superblock_security_head);
 static DEFINE_SPINLOCK(sb_security_lock);
 
-static kmem_cache_t *sel_inode_cache;
+static struct kmem_cache *sel_inode_cache;
 
 /* Return security context for a given sid or just the context 
    length if the buffer is null or length is 0 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
