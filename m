Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 324B86B006E
	for <linux-mm@kvack.org>; Sat, 30 May 2015 15:02:17 -0400 (EDT)
Received: by pacux9 with SMTP id ux9so40135183pac.3
        for <linux-mm@kvack.org>; Sat, 30 May 2015 12:02:16 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id pm11si14020774pdb.55.2015.05.30.12.02.15
        for <linux-mm@kvack.org>;
        Sat, 30 May 2015 12:02:15 -0700 (PDT)
Subject: [PATCH v2 3/4] arch: introduce memremap()
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 30 May 2015 14:59:35 -0400
Message-ID: <20150530185935.32590.95416.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, hmh@hmh.eng.br, tj@kernel.org, hch@lst.de

Many existing users of ioremap_cache() and some select ioremap_nocache()
users are mapping memory that is known in advance to not have i/o side
effects.  These users are forced to cast away the __iomem annotation, or
otherwise neglect to fix the sparse errors thrown when dereferencing
pointers to this memory.  Provide memremap() as a non __iomem annotated
ioremep().

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arm64/kernel/efi.c              |    4 ++--
 arch/arm64/kernel/smp_spin_table.c   |   10 +++++----
 arch/x86/kernel/crash_dump_64.c      |    6 +++---
 arch/x86/kernel/kdebugfs.c           |    8 ++++----
 arch/x86/kernel/ksysfs.c             |   28 +++++++++++++-------------
 arch/x86/mm/ioremap.c                |   10 ++++-----
 drivers/acpi/apei/einj.c             |    8 ++++----
 drivers/acpi/apei/erst.c             |   14 +++++++------
 drivers/block/pmem.c                 |    6 +++---
 drivers/firmware/google/memconsole.c |    4 ++--
 include/linux/device.h               |    5 +++++
 include/linux/io.h                   |   36 ++++++++++++++++++++++++++++++++++
 12 files changed, 89 insertions(+), 50 deletions(-)

diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
index ab21e0d58278..b672ef33f08b 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -289,7 +289,7 @@ static int __init arm64_enable_runtime_services(void)
 	pr_info("Remapping and enabling EFI services.\n");
 
 	mapsize = memmap.map_end - memmap.map;
-	memmap.map = (__force void *)ioremap_cache((phys_addr_t)memmap.phys_map,
+	memmap.map = memremap_cache((phys_addr_t)memmap.phys_map,
 						   mapsize);
 	if (!memmap.map) {
 		pr_err("Failed to remap EFI memory map\n");
@@ -298,7 +298,7 @@ static int __init arm64_enable_runtime_services(void)
 	memmap.map_end = memmap.map + mapsize;
 	efi.memmap = &memmap;
 
-	efi.systab = (__force void *)ioremap_cache(efi_system_table,
+	efi.systab = memremap_cache(efi_system_table,
 						   sizeof(efi_system_table_t));
 	if (!efi.systab) {
 		pr_err("Failed to remap EFI System Table\n");
diff --git a/arch/arm64/kernel/smp_spin_table.c b/arch/arm64/kernel/smp_spin_table.c
index 14944e5b28da..893c8586e20f 100644
--- a/arch/arm64/kernel/smp_spin_table.c
+++ b/arch/arm64/kernel/smp_spin_table.c
@@ -67,18 +67,18 @@ static int smp_spin_table_cpu_init(struct device_node *dn, unsigned int cpu)
 
 static int smp_spin_table_cpu_prepare(unsigned int cpu)
 {
-	__le64 __iomem *release_addr;
+	__le64 *release_addr;
 
 	if (!cpu_release_addr[cpu])
 		return -ENODEV;
 
 	/*
 	 * The cpu-release-addr may or may not be inside the linear mapping.
-	 * As ioremap_cache will either give us a new mapping or reuse the
+	 * As memremap_cache will either give us a new mapping or reuse the
 	 * existing linear mapping, we can use it to cover both cases. In
 	 * either case the memory will be MT_NORMAL.
 	 */
-	release_addr = ioremap_cache(cpu_release_addr[cpu],
+	release_addr = memremap_cache(cpu_release_addr[cpu],
 				     sizeof(*release_addr));
 	if (!release_addr)
 		return -ENOMEM;
@@ -91,7 +91,7 @@ static int smp_spin_table_cpu_prepare(unsigned int cpu)
 	 * the boot protocol.
 	 */
 	writeq_relaxed(__pa(secondary_holding_pen), release_addr);
-	__flush_dcache_area((__force void *)release_addr,
+	__flush_dcache_area(release_addr,
 			    sizeof(*release_addr));
 
 	/*
@@ -99,7 +99,7 @@ static int smp_spin_table_cpu_prepare(unsigned int cpu)
 	 */
 	sev();
 
-	iounmap(release_addr);
+	memunmap(release_addr);
 
 	return 0;
 }
diff --git a/arch/x86/kernel/crash_dump_64.c b/arch/x86/kernel/crash_dump_64.c
index afa64adb75ee..8e04011665fd 100644
--- a/arch/x86/kernel/crash_dump_64.c
+++ b/arch/x86/kernel/crash_dump_64.c
@@ -31,19 +31,19 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 	if (!csize)
 		return 0;
 
-	vaddr = ioremap_cache(pfn << PAGE_SHIFT, PAGE_SIZE);
+	vaddr = memremap_cache(pfn << PAGE_SHIFT, PAGE_SIZE);
 	if (!vaddr)
 		return -ENOMEM;
 
 	if (userbuf) {
 		if (copy_to_user(buf, vaddr + offset, csize)) {
-			iounmap(vaddr);
+			memunmap(vaddr);
 			return -EFAULT;
 		}
 	} else
 		memcpy(buf, vaddr + offset, csize);
 
 	set_iounmap_nonlazy();
-	iounmap(vaddr);
+	memunmap(vaddr);
 	return csize;
 }
diff --git a/arch/x86/kernel/kdebugfs.c b/arch/x86/kernel/kdebugfs.c
index dc1404bf8e4b..731b10e2814f 100644
--- a/arch/x86/kernel/kdebugfs.c
+++ b/arch/x86/kernel/kdebugfs.c
@@ -49,7 +49,7 @@ static ssize_t setup_data_read(struct file *file, char __user *user_buf,
 	pa = node->paddr + sizeof(struct setup_data) + pos;
 	pg = pfn_to_page((pa + count - 1) >> PAGE_SHIFT);
 	if (PageHighMem(pg)) {
-		p = ioremap_cache(pa, count);
+		p = memremap_cache(pa, count);
 		if (!p)
 			return -ENXIO;
 	} else
@@ -58,7 +58,7 @@ static ssize_t setup_data_read(struct file *file, char __user *user_buf,
 	remain = copy_to_user(user_buf, p, count);
 
 	if (PageHighMem(pg))
-		iounmap(p);
+		memunmap(p);
 
 	if (remain)
 		return -EFAULT;
@@ -128,7 +128,7 @@ static int __init create_setup_data_nodes(struct dentry *parent)
 
 		pg = pfn_to_page((pa_data+sizeof(*data)-1) >> PAGE_SHIFT);
 		if (PageHighMem(pg)) {
-			data = ioremap_cache(pa_data, sizeof(*data));
+			data = memremap_cache(pa_data, sizeof(*data));
 			if (!data) {
 				kfree(node);
 				error = -ENXIO;
@@ -144,7 +144,7 @@ static int __init create_setup_data_nodes(struct dentry *parent)
 		pa_data = data->next;
 
 		if (PageHighMem(pg))
-			iounmap(data);
+			memunmap(data);
 		if (error)
 			goto err_dir;
 		no++;
diff --git a/arch/x86/kernel/ksysfs.c b/arch/x86/kernel/ksysfs.c
index c2bedaea11f7..2fbc62886eae 100644
--- a/arch/x86/kernel/ksysfs.c
+++ b/arch/x86/kernel/ksysfs.c
@@ -16,8 +16,8 @@
 #include <linux/stat.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
+#include <linux/io.h>
 
-#include <asm/io.h>
 #include <asm/setup.h>
 
 static ssize_t version_show(struct kobject *kobj,
@@ -79,12 +79,12 @@ static int get_setup_data_paddr(int nr, u64 *paddr)
 			*paddr = pa_data;
 			return 0;
 		}
-		data = ioremap_cache(pa_data, sizeof(*data));
+		data = memremap_cache(pa_data, sizeof(*data));
 		if (!data)
 			return -ENOMEM;
 
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 		i++;
 	}
 	return -EINVAL;
@@ -97,17 +97,17 @@ static int __init get_setup_data_size(int nr, size_t *size)
 	u64 pa_data = boot_params.hdr.setup_data;
 
 	while (pa_data) {
-		data = ioremap_cache(pa_data, sizeof(*data));
+		data = memremap_cache(pa_data, sizeof(*data));
 		if (!data)
 			return -ENOMEM;
 		if (nr == i) {
 			*size = data->len;
-			iounmap(data);
+			memunmap(data);
 			return 0;
 		}
 
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 		i++;
 	}
 	return -EINVAL;
@@ -127,12 +127,12 @@ static ssize_t type_show(struct kobject *kobj,
 	ret = get_setup_data_paddr(nr, &paddr);
 	if (ret)
 		return ret;
-	data = ioremap_cache(paddr, sizeof(*data));
+	data = memremap_cache(paddr, sizeof(*data));
 	if (!data)
 		return -ENOMEM;
 
 	ret = sprintf(buf, "0x%x\n", data->type);
-	iounmap(data);
+	memunmap(data);
 	return ret;
 }
 
@@ -154,7 +154,7 @@ static ssize_t setup_data_data_read(struct file *fp,
 	ret = get_setup_data_paddr(nr, &paddr);
 	if (ret)
 		return ret;
-	data = ioremap_cache(paddr, sizeof(*data));
+	data = memremap_cache(paddr, sizeof(*data));
 	if (!data)
 		return -ENOMEM;
 
@@ -170,15 +170,15 @@ static ssize_t setup_data_data_read(struct file *fp,
 		goto out;
 
 	ret = count;
-	p = ioremap_cache(paddr + sizeof(*data), data->len);
+	p = memremap_cache(paddr + sizeof(*data), data->len);
 	if (!p) {
 		ret = -ENOMEM;
 		goto out;
 	}
 	memcpy(buf, p + off, count);
-	iounmap(p);
+	memunmap(p);
 out:
-	iounmap(data);
+	memunmap(data);
 	return ret;
 }
 
@@ -250,13 +250,13 @@ static int __init get_setup_data_total_num(u64 pa_data, int *nr)
 	*nr = 0;
 	while (pa_data) {
 		*nr += 1;
-		data = ioremap_cache(pa_data, sizeof(*data));
+		data = memremap_cache(pa_data, sizeof(*data));
 		if (!data) {
 			ret = -ENOMEM;
 			goto out;
 		}
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 	}
 
 out:
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index cc5ccc415cc0..f48c137560df 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -414,12 +414,10 @@ void *xlate_dev_mem_ptr(phys_addr_t phys)
 	if (page_is_ram(start >> PAGE_SHIFT))
 		return __va(phys);
 
-	vaddr = ioremap_cache(start, PAGE_SIZE);
-	/* Only add the offset on success and return NULL if the ioremap() failed: */
+	vaddr = memremap_cache(start, PAGE_SIZE);
 	if (vaddr)
-		vaddr += offset;
-
-	return vaddr;
+		return vaddr + offset;
+	return NULL;
 }
 
 void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
@@ -427,7 +425,7 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
 	if (page_is_ram(phys >> PAGE_SHIFT))
 		return;
 
-	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
+	memunmap((void *) ((unsigned long)addr & PAGE_MASK));
 }
 
 static pte_t bm_pte[PAGE_SIZE/sizeof(pte_t)] __page_aligned_bss;
diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
index a095d4f858da..2ec9006cfb6c 100644
--- a/drivers/acpi/apei/einj.c
+++ b/drivers/acpi/apei/einj.c
@@ -318,7 +318,7 @@ static int __einj_error_trigger(u64 trigger_paddr, u32 type,
 			    sizeof(*trigger_tab) - 1);
 		goto out;
 	}
-	trigger_tab = ioremap_cache(trigger_paddr, sizeof(*trigger_tab));
+	trigger_tab = memremap_cache(trigger_paddr, sizeof(*trigger_tab));
 	if (!trigger_tab) {
 		pr_err(EINJ_PFX "Failed to map trigger table!\n");
 		goto out_rel_header;
@@ -346,8 +346,8 @@ static int __einj_error_trigger(u64 trigger_paddr, u32 type,
 		       (unsigned long long)trigger_paddr + table_size - 1);
 		goto out_rel_header;
 	}
-	iounmap(trigger_tab);
-	trigger_tab = ioremap_cache(trigger_paddr, table_size);
+	memunmap(trigger_tab);
+	trigger_tab = memremap_cache(trigger_paddr, table_size);
 	if (!trigger_tab) {
 		pr_err(EINJ_PFX "Failed to map trigger table!\n");
 		goto out_rel_entry;
@@ -409,7 +409,7 @@ out_rel_header:
 	release_mem_region(trigger_paddr, sizeof(*trigger_tab));
 out:
 	if (trigger_tab)
-		iounmap(trigger_tab);
+		memunmap(trigger_tab);
 
 	return rc;
 }
diff --git a/drivers/acpi/apei/erst.c b/drivers/acpi/apei/erst.c
index ed65e9c4b5b0..4f8b62404db5 100644
--- a/drivers/acpi/apei/erst.c
+++ b/drivers/acpi/apei/erst.c
@@ -76,7 +76,7 @@ static struct acpi_table_erst *erst_tab;
 static struct erst_erange {
 	u64 base;
 	u64 size;
-	void __iomem *vaddr;
+	void *vaddr;
 	u32 attr;
 } erst_erange;
 
@@ -279,19 +279,19 @@ static int erst_exec_move_data(struct apei_exec_context *ctx,
 	if (rc)
 		return rc;
 
-	src = ioremap(ctx->src_base + offset, ctx->var2);
+	src = memremap(ctx->src_base + offset, ctx->var2);
 	if (!src)
 		return -ENOMEM;
-	dst = ioremap(ctx->dst_base + offset, ctx->var2);
+	dst = memremap(ctx->dst_base + offset, ctx->var2);
 	if (!dst) {
-		iounmap(src);
+		memunmap(src);
 		return -ENOMEM;
 	}
 
 	memmove(dst, src, ctx->var2);
 
-	iounmap(src);
-	iounmap(dst);
+	memunmap(src);
+	memunmap(dst);
 
 	return 0;
 }
@@ -1184,7 +1184,7 @@ static int __init erst_init(void)
 		goto err_unmap_reg;
 	}
 	rc = -ENOMEM;
-	erst_erange.vaddr = ioremap_cache(erst_erange.base,
+	erst_erange.vaddr = memremap_cache(erst_erange.base,
 					  erst_erange.size);
 	if (!erst_erange.vaddr)
 		goto err_release_erange;
diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
index 095dfaadcaa5..799acff6bd7c 100644
--- a/drivers/block/pmem.c
+++ b/drivers/block/pmem.c
@@ -143,7 +143,7 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 	 * of the CPU caches in case of a crash.
 	 */
 	err = -ENOMEM;
-	pmem->virt_addr = ioremap_wt(pmem->phys_addr, pmem->size);
+	pmem->virt_addr = memremap_wt(pmem->phys_addr, pmem->size);
 	if (!pmem->virt_addr)
 		goto out_release_region;
 
@@ -179,7 +179,7 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 out_free_queue:
 	blk_cleanup_queue(pmem->pmem_queue);
 out_unmap:
-	iounmap(pmem->virt_addr);
+	memunmap(pmem->virt_addr);
 out_release_region:
 	release_mem_region(pmem->phys_addr, pmem->size);
 out_free_dev:
@@ -193,7 +193,7 @@ static void pmem_free(struct pmem_device *pmem)
 	del_gendisk(pmem->pmem_disk);
 	put_disk(pmem->pmem_disk);
 	blk_cleanup_queue(pmem->pmem_queue);
-	iounmap(pmem->virt_addr);
+	memunmap(pmem->virt_addr);
 	release_mem_region(pmem->phys_addr, pmem->size);
 	kfree(pmem);
 }
diff --git a/drivers/firmware/google/memconsole.c b/drivers/firmware/google/memconsole.c
index 2f569aaed4c7..877433dc8297 100644
--- a/drivers/firmware/google/memconsole.c
+++ b/drivers/firmware/google/memconsole.c
@@ -52,14 +52,14 @@ static ssize_t memconsole_read(struct file *filp, struct kobject *kobp,
 	char *memconsole;
 	ssize_t ret;
 
-	memconsole = ioremap_cache(memconsole_baseaddr, memconsole_length);
+	memconsole = memremap_cache(memconsole_baseaddr, memconsole_length);
 	if (!memconsole) {
 		pr_err("memconsole: ioremap_cache failed\n");
 		return -ENOMEM;
 	}
 	ret = memory_read_from_buffer(buf, count, &pos, memconsole,
 				      memconsole_length);
-	iounmap(memconsole);
+	memunmap(memconsole);
 	return ret;
 }
 
diff --git a/include/linux/device.h b/include/linux/device.h
index 6558af90c8fe..518f49c5d596 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -638,6 +638,11 @@ extern void devm_free_pages(struct device *dev, unsigned long addr);
 
 void __iomem *devm_ioremap_resource(struct device *dev, struct resource *res);
 
+static inline void *devm_memremap_resource(struct device *dev, struct resource *res)
+{
+	return (void __force *) devm_ioremap_resource(dev, res);
+}
+
 /* allows to add/remove a custom action to devres stack */
 int devm_add_action(struct device *dev, void (*action)(void *), void *data);
 void devm_remove_action(struct device *dev, void (*action)(void *), void *data);
diff --git a/include/linux/io.h b/include/linux/io.h
index 1c9ad4c6d485..86c636ce4c43 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -122,4 +122,40 @@ static inline int arch_phys_wc_index(int handle)
 #endif
 #endif
 
+/*
+ * memremap() is "ioremap" for cases where it is known that the resource
+ * being mapped does not have i/o side effects and the __iomem
+ * annotation is not applicable.
+ */
+
+static inline void *memremap(resource_size_t offset, size_t size)
+{
+	return (void __force *) ioremap(offset, size);
+}
+
+static inline void *memremap_nocache(resource_size_t offset, size_t size)
+{
+	return (void __force *) ioremap_nocache(offset, size);
+}
+
+static inline void *memremap_cache(resource_size_t offset, size_t size)
+{
+	return (void __force *) ioremap_cache(offset, size);
+}
+
+static inline void *memremap_wc(resource_size_t offset, size_t size)
+{
+	return (void __force *) ioremap_wc(offset, size);
+}
+
+static inline void *memremap_wt(resource_size_t offset, size_t size)
+{
+	return (void __force *) ioremap_wt(offset, size);
+}
+
+static inline void memunmap(void *addr)
+{
+	return iounmap((void __iomem __force *) addr);
+}
+
 #endif /* _LINUX_IO_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
