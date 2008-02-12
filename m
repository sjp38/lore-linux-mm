Date: Tue, 12 Feb 2008 11:55:32 -0800
From: mark gross <mgross@linux.intel.com>
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
Message-ID: <20080212195532.GA29132@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20080211224105.GB24412@linux.intel.com> <20080211152716.65f5a753.randy.dunlap@oracle.com> <20080212160553.GD27490@linux.intel.com> <47B1CA9F.80004@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47B1CA9F.80004@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2008 at 08:34:39AM -0800, Randy Dunlap wrote:
> mark gross wrote:
>>  Index: linux-2.6.24-mm1/drivers/pci/intel-iommu.c
>> ===================================================================
>> --- linux-2.6.24-mm1.orig/drivers/pci/intel-iommu.c	2008-02-12 
>> 07:12:06.000000000 -0800
>> +++ linux-2.6.24-mm1/drivers/pci/intel-iommu.c	2008-02-12 
>> 07:47:04.000000000 -0800
>
>> @@ -1672,7 +1702,30 @@
>>  	for_each_drhd_unit(drhd) {
>>  		if (drhd->ignored)
>>  			continue;
>> -		iommu = alloc_iommu(drhd);
>> +		g_num_of_iommus++;
>> +	}
>> +
>> +	nlongs = BITS_TO_LONGS(g_num_of_iommus);
>> +	g_iommus_to_flush = kzalloc(nlongs * sizeof(unsigned long), GFP_KERNEL);
>> +	if (!g_iommus_to_flush) {
>> +		printk(KERN_ERR "Intel-IOMMU: \
>> +			Allocating bitmap array failed\n");
>
> I think that will make a string like below:
> Intel-IOMMU: 			Allocating bitmap array failed
>

you are right.

>> +		return -ENOMEM;
>> +	}
>> +		strict [Default Off]
>> +			With this option on every umap_signal opperation will
>
> 			                          unmap_single operation
>
>> +			result in a hardware IOTLB flush opperation as opposed

Signed-off-by: <mgross@linux.intel.com>


Index: linux-2.6.24-mm1/drivers/pci/intel-iommu.c
===================================================================
--- linux-2.6.24-mm1.orig/drivers/pci/intel-iommu.c	2008-02-12 07:12:06.000000000 -0800
+++ linux-2.6.24-mm1/drivers/pci/intel-iommu.c	2008-02-12 11:35:42.000000000 -0800
@@ -21,6 +21,7 @@
 
 #include <linux/init.h>
 #include <linux/bitmap.h>
+#include <linux/debugfs.h>
 #include <linux/slab.h>
 #include <linux/irq.h>
 #include <linux/interrupt.h>
@@ -30,6 +31,7 @@
 #include <linux/dmar.h>
 #include <linux/dma-mapping.h>
 #include <linux/mempool.h>
+#include <linux/timer.h>
 #include "iova.h"
 #include "intel-iommu.h"
 #include <asm/proto.h> /* force_iommu in this header in x86-64*/
@@ -50,11 +52,39 @@
 
 #define DOMAIN_MAX_ADDR(gaw) ((((u64)1) << gaw) - 1)
 
+
+static void flush_unmaps_timeout(unsigned long data);
+
+static struct timer_list unmap_timer =
+	TIMER_INITIALIZER(flush_unmaps_timeout, 0, 0);
+
+struct unmap_list {
+	struct list_head list;
+	struct dmar_domain *domain;
+	struct iova *iova;
+};
+
+static struct intel_iommu *g_iommus;
+/* bitmap for indexing intel_iommus */
+static unsigned long 	*g_iommus_to_flush;
+static int g_num_of_iommus;
+
+static DEFINE_SPINLOCK(async_umap_flush_lock);
+static LIST_HEAD(unmaps_to_do);
+
+static int timer_on;
+static long list_size;
+static int high_watermark;
+
+static struct dentry *intel_iommu_debug, *debug;
+
+
 static void domain_remove_dev_info(struct dmar_domain *domain);
 
 static int dmar_disabled;
 static int __initdata dmar_map_gfx = 1;
 static int dmar_forcedac;
+static int intel_iommu_strict;
 
 #define DUMMY_DEVICE_DOMAIN_INFO ((struct device_domain_info *)(-1))
 static DEFINE_SPINLOCK(device_domain_lock);
@@ -73,9 +103,13 @@
 			printk(KERN_INFO
 				"Intel-IOMMU: disable GFX device mapping\n");
 		} else if (!strncmp(str, "forcedac", 8)) {
-			printk (KERN_INFO
+			printk(KERN_INFO
 				"Intel-IOMMU: Forcing DAC for PCI devices\n");
 			dmar_forcedac = 1;
+		} else if (!strncmp(str, "strict", 8)) {
+			printk(KERN_INFO
+				"Intel-IOMMU: disable batched IOTLB flush\n");
+			intel_iommu_strict = 1;
 		}
 
 		str += strcspn(str, ",");
@@ -965,17 +999,13 @@
 		set_bit(0, iommu->domain_ids);
 	return 0;
 }
-
-static struct intel_iommu *alloc_iommu(struct dmar_drhd_unit *drhd)
+static struct intel_iommu *alloc_iommu(struct intel_iommu *iommu,
+					struct dmar_drhd_unit *drhd)
 {
-	struct intel_iommu *iommu;
 	int ret;
 	int map_size;
 	u32 ver;
 
-	iommu = kzalloc(sizeof(*iommu), GFP_KERNEL);
-	if (!iommu)
-		return NULL;
 	iommu->reg = ioremap(drhd->reg_base_addr, PAGE_SIZE_4K);
 	if (!iommu->reg) {
 		printk(KERN_ERR "IOMMU: can't map the region\n");
@@ -1396,7 +1426,7 @@
 	int index;
 
 	while (dev) {
-		for (index = 0; index < cnt; index ++)
+		for (index = 0; index < cnt; index++)
 			if (dev == devices[index])
 				return 1;
 
@@ -1661,7 +1691,7 @@
 	struct dmar_rmrr_unit *rmrr;
 	struct pci_dev *pdev;
 	struct intel_iommu *iommu;
-	int ret, unit = 0;
+	int nlongs, i, ret, unit = 0;
 
 	/*
 	 * for each drhd
@@ -1672,7 +1702,30 @@
 	for_each_drhd_unit(drhd) {
 		if (drhd->ignored)
 			continue;
-		iommu = alloc_iommu(drhd);
+		g_num_of_iommus++;
+	}
+
+	nlongs = BITS_TO_LONGS(g_num_of_iommus);
+	g_iommus_to_flush = kzalloc(nlongs * sizeof(unsigned long), GFP_KERNEL);
+	if (!g_iommus_to_flush) {
+		printk(KERN_ERR "Intel-IOMMU: "
+			"Allocating bitmap array failed\n");
+		return -ENOMEM;
+	}
+
+	g_iommus = kzalloc(g_num_of_iommus * sizeof(*iommu), GFP_KERNEL);
+	if (!g_iommus) {
+		kfree(g_iommus_to_flush);
+		ret = -ENOMEM;
+		goto error;
+	}
+
+	i = 0;
+	for_each_drhd_unit(drhd) {
+		if (drhd->ignored)
+			continue;
+		iommu = alloc_iommu(&g_iommus[i], drhd);
+		i++;
 		if (!iommu) {
 			ret = -ENOMEM;
 			goto error;
@@ -1705,7 +1758,6 @@
 	 * endfor
 	 */
 	for_each_rmrr_units(rmrr) {
-		int i;
 		for (i = 0; i < rmrr->devices_cnt; i++) {
 			pdev = rmrr->devices[i];
 			/* some BIOS lists non-exist devices in DMAR table */
@@ -1909,6 +1961,54 @@
 	return 0;
 }
 
+static void flush_unmaps(void)
+{
+	struct iova *node, *n;
+	unsigned long flags;
+	int i;
+
+	spin_lock_irqsave(&async_umap_flush_lock, flags);
+	timer_on = 0;
+
+	/*just flush them all*/
+	for (i = 0; i < g_num_of_iommus; i++) {
+		if (test_and_clear_bit(i, g_iommus_to_flush))
+			iommu_flush_iotlb_global(&g_iommus[i], 0);
+	}
+
+	list_for_each_entry_safe(node, n, &unmaps_to_do, list) {
+		/* free iova */
+		list_del(&node->list);
+		__free_iova(&((struct dmar_domain *)node->dmar)->iovad, node);
+
+	}
+	list_size = 0;
+	spin_unlock_irqrestore(&async_umap_flush_lock, flags);
+}
+
+static void flush_unmaps_timeout(unsigned long data)
+{
+	flush_unmaps();
+}
+
+static void add_unmap(struct dmar_domain *dom, struct iova *iova)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&async_umap_flush_lock, flags);
+	iova->dmar = dom;
+	list_add(&iova->list, &unmaps_to_do);
+	set_bit((dom->iommu - g_iommus), g_iommus_to_flush);
+
+	if (!timer_on) {
+		unmap_timer.expires = jiffies + msecs_to_jiffies(10);
+		mod_timer(&unmap_timer, unmap_timer.expires);
+		timer_on = 1;
+	}
+	list_size++;
+	spin_unlock_irqrestore(&async_umap_flush_lock, flags);
+}
+
 static void intel_unmap_single(struct device *dev, dma_addr_t dev_addr,
 	size_t size, int dir)
 {
@@ -1936,13 +2036,21 @@
 	dma_pte_clear_range(domain, start_addr, start_addr + size);
 	/* free page tables */
 	dma_pte_free_pagetable(domain, start_addr, start_addr + size);
-
-	if (iommu_flush_iotlb_psi(domain->iommu, domain->id, start_addr,
-			size >> PAGE_SHIFT_4K, 0))
-		iommu_flush_write_buffer(domain->iommu);
-
-	/* free iova */
-	__free_iova(&domain->iovad, iova);
+	if (intel_iommu_strict) {
+		if (iommu_flush_iotlb_psi(domain->iommu,
+			domain->id, start_addr, size >> PAGE_SHIFT_4K, 0))
+			iommu_flush_write_buffer(domain->iommu);
+		/* free iova */
+		__free_iova(&domain->iovad, iova);
+	} else {
+		add_unmap(domain, iova);
+		/*
+		 * queue up the release of the unmap to save the 1/6th of the
+		 * cpu used up by the iotlb flush operation...
+		 */
+		if (list_size > high_watermark)
+			flush_unmaps();
+	}
 }
 
 static void * intel_alloc_coherent(struct device *hwdev, size_t size,
@@ -2266,6 +2374,10 @@
 	if (dmar_table_init())
 		return 	-ENODEV;
 
+	high_watermark = 250;
+	intel_iommu_debug = debugfs_create_dir("intel_iommu", NULL);
+	debug = debugfs_create_u32("high_watermark", S_IWUGO | S_IRUGO,
+					intel_iommu_debug, &high_watermark);
 	iommu_init_mempool();
 	dmar_init_reserved_ranges();
 
@@ -2281,6 +2393,7 @@
 	printk(KERN_INFO
 	"PCI-DMA: Intel(R) Virtualization Technology for Directed I/O\n");
 
+	init_timer(&unmap_timer);
 	force_iommu = 1;
 	dma_ops = &intel_dma_ops;
 	return 0;
Index: linux-2.6.24-mm1/drivers/pci/iova.h
===================================================================
--- linux-2.6.24-mm1.orig/drivers/pci/iova.h	2008-02-12 07:12:06.000000000 -0800
+++ linux-2.6.24-mm1/drivers/pci/iova.h	2008-02-12 07:39:53.000000000 -0800
@@ -23,6 +23,8 @@
 	struct rb_node	node;
 	unsigned long	pfn_hi; /* IOMMU dish out addr hi */
 	unsigned long	pfn_lo; /* IOMMU dish out addr lo */
+	struct list_head list;
+	void *dmar;
 };
 
 /* holds all the iova translations for a domain */
Index: linux-2.6.24-mm1/Documentation/kernel-parameters.txt
===================================================================
--- linux-2.6.24-mm1.orig/Documentation/kernel-parameters.txt	2008-02-12 07:12:06.000000000 -0800
+++ linux-2.6.24-mm1/Documentation/kernel-parameters.txt	2008-02-12 11:36:07.000000000 -0800
@@ -822,6 +822,10 @@
 			than 32 bit addressing. The default is to look
 			for translation below 32 bit and if not available
 			then look in the higher range.
+		strict [Default Off]
+			With this option on every umap_signle operation will
+			result in a hardware IOTLB flush operation as opposed
+			to batching them for performance.
 
 	io_delay=	[X86-32,X86-64] I/O delay method
 		0x80

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
