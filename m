Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C4C4A6B0072
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:30:29 -0400 (EDT)
Received: by pacyo7 with SMTP id yo7so26181103pac.2
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:30:29 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id b5si28594550pdn.44.2015.06.22.01.30.28
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 01:30:28 -0700 (PDT)
Subject: [PATCH v5 5/6] arch: introduce memremap_cache() and memremap_wt()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 Jun 2015 04:24:44 -0400
Message-ID: <20150622082444.35954.79583.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

Existing users of ioremap_cache() are mapping memory that is known in
advance to not have i/o side effects.  These users are forced to cast
away the __iomem annotation, or otherwise neglect to fix the sparse
errors thrown when dereferencing pointers to this memory.  Provide
memremap_*() as a non __iomem annotated ioremap_*().

The ARCH_HAS_MEMREMAP kconfig symbol is introduced for archs to assert
that it is safe to recast / reuse the return value from ioremap as a
normal pointer to memory.  In other words, archs that mandate specific
accessors for __iomem are not memremap() capable and drivers that care,
like pmem, can add a dependency to disable themselves on these archs.

Cc: Arnd Bergmann <arnd@arndb.de>
Acked-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arm/Kconfig                     |    1 +
 arch/arm64/Kconfig                   |    1 +
 arch/arm64/kernel/efi.c              |    4 ++-
 arch/arm64/kernel/smp_spin_table.c   |   10 ++++----
 arch/frv/Kconfig                     |    1 +
 arch/m68k/Kconfig                    |    1 +
 arch/metag/Kconfig                   |    1 +
 arch/mips/Kconfig                    |    1 +
 arch/powerpc/Kconfig                 |    1 +
 arch/x86/Kconfig                     |    1 +
 arch/x86/kernel/crash_dump_64.c      |    6 ++---
 arch/x86/kernel/kdebugfs.c           |    8 +++----
 arch/x86/kernel/ksysfs.c             |   28 ++++++++++++-----------
 arch/x86/mm/ioremap.c                |   10 +++-----
 arch/xtensa/Kconfig                  |    1 +
 drivers/acpi/apei/einj.c             |    8 +++----
 drivers/acpi/apei/erst.c             |    4 ++-
 drivers/block/Kconfig                |    1 +
 drivers/block/pmem.c                 |    7 +++---
 drivers/firmware/google/memconsole.c |    4 ++-
 include/linux/device.h               |    5 ++++
 include/linux/io.h                   |    4 +++
 kernel/resource.c                    |   41 +++++++++++++++++++++++++++++++++-
 lib/Kconfig                          |    5 +++-
 24 files changed, 107 insertions(+), 47 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 45df48ba0b12..397426f8ca37 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -3,6 +3,7 @@ config ARM
 	default y
 	select ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
 	select ARCH_HAS_ELF_RANDOMIZE
+	select ARCH_HAS_MEMREMAP
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAVE_CUSTOM_GPIO_H
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7796af4b1d6f..f07a9a5af61e 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -5,6 +5,7 @@ config ARM64
 	select ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_MEMREMAP
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_USE_CMPXCHG_LOCKREF
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
diff --git a/arch/frv/Kconfig b/arch/frv/Kconfig
index 34aa19352dc1..2373bf183527 100644
--- a/arch/frv/Kconfig
+++ b/arch/frv/Kconfig
@@ -14,6 +14,7 @@ config FRV
 	select OLD_SIGSUSPEND3
 	select OLD_SIGACTION
 	select HAVE_DEBUG_STACKOVERFLOW
+	select ARCH_HAS_MEMREMAP
 
 config ZONE_DMA
 	bool
diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 2dd8f63bfbbb..831b1be8c43d 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -23,6 +23,7 @@ config M68K
 	select MODULES_USE_ELF_RELA
 	select OLD_SIGSUSPEND3
 	select OLD_SIGACTION
+	select ARCH_HAS_MEMREMAP
 
 config RWSEM_GENERIC_SPINLOCK
 	bool
diff --git a/arch/metag/Kconfig b/arch/metag/Kconfig
index 0b389a81c43a..5669fe3eb807 100644
--- a/arch/metag/Kconfig
+++ b/arch/metag/Kconfig
@@ -24,6 +24,7 @@ config METAG
 	select HAVE_PERF_EVENTS
 	select HAVE_SYSCALL_TRACEPOINTS
 	select HAVE_UNDERSCORE_SYMBOL_PREFIX
+	select ARCH_HAS_MEMREMAP
 	select IRQ_DOMAIN
 	select MODULES_USE_ELF_RELA
 	select OF
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index f5016656494f..9ee35e615c0d 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -58,6 +58,7 @@ config MIPS
 	select SYSCTL_EXCEPTION_TRACE
 	select HAVE_VIRT_CPU_ACCOUNTING_GEN
 	select HAVE_IRQ_TIME_ACCOUNTING
+	select ARCH_HAS_MEMREMAP
 
 menu "Machine selection"
 
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 190cc48abc0c..73c1f8b1f022 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -153,6 +153,7 @@ config PPC
 	select NO_BOOTMEM
 	select HAVE_GENERIC_RCU_GUP
 	select HAVE_PERF_EVENTS_NMI if PPC64
+	select ARCH_HAS_MEMREMAP
 
 config GENERIC_CSUM
 	def_bool CPU_LITTLE_ENDIAN
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 228aa35d7e89..f16caf7eac27 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -27,6 +27,7 @@ config X86
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_MEMREMAP
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
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
index cc5ccc415cc0..7f087cb793fa 100644
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
+	memunmap((void *)((unsigned long)addr & PAGE_MASK));
 }
 
 static pte_t bm_pte[PAGE_SIZE/sizeof(pte_t)] __page_aligned_bss;
diff --git a/arch/xtensa/Kconfig b/arch/xtensa/Kconfig
index 87be10e8b57a..e601faf87cee 100644
--- a/arch/xtensa/Kconfig
+++ b/arch/xtensa/Kconfig
@@ -3,6 +3,7 @@ config ZONE_DMA
 
 config XTENSA
 	def_bool y
+	select ARCH_HAS_MEMREMAP
 	select ARCH_WANT_FRAME_POINTERS
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select ARCH_WANT_OPTIONAL_GPIOLIB
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
index 3670bbab57a3..6b95066da51d 100644
--- a/drivers/acpi/apei/erst.c
+++ b/drivers/acpi/apei/erst.c
@@ -77,7 +77,7 @@ static struct acpi_table_erst *erst_tab;
 static struct erst_erange {
 	u64 base;
 	u64 size;
-	void __iomem *vaddr;
+	void *vaddr;
 	u32 attr;
 } erst_erange;
 
@@ -1185,7 +1185,7 @@ static int __init erst_init(void)
 		goto err_unmap_reg;
 	}
 	rc = -ENOMEM;
-	erst_erange.vaddr = ioremap_cache(erst_erange.base,
+	erst_erange.vaddr = memremap_cache(erst_erange.base,
 					  erst_erange.size);
 	if (!erst_erange.vaddr)
 		goto err_release_erange;
diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index eb1fed5bd516..98418fc330ae 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -406,6 +406,7 @@ config BLK_DEV_RAM_DAX
 
 config BLK_DEV_PMEM
 	tristate "Persistent memory block device support"
+	depends on ARCH_HAS_MEMREMAP
 	help
 	  Saying Y here will allow you to use a contiguous range of reserved
 	  memory as one or more persistent block devices.
diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
index 095dfaadcaa5..b00b97314b57 100644
--- a/drivers/block/pmem.c
+++ b/drivers/block/pmem.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/slab.h>
+#include <linux/io.h>
 
 #define PMEM_MINORS		16
 
@@ -143,7 +144,7 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 	 * of the CPU caches in case of a crash.
 	 */
 	err = -ENOMEM;
-	pmem->virt_addr = ioremap_wt(pmem->phys_addr, pmem->size);
+	pmem->virt_addr = memremap_wt(pmem->phys_addr, pmem->size);
 	if (!pmem->virt_addr)
 		goto out_release_region;
 
@@ -179,7 +180,7 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 out_free_queue:
 	blk_cleanup_queue(pmem->pmem_queue);
 out_unmap:
-	iounmap(pmem->virt_addr);
+	memunmap(pmem->virt_addr);
 out_release_region:
 	release_mem_region(pmem->phys_addr, pmem->size);
 out_free_dev:
@@ -193,7 +194,7 @@ static void pmem_free(struct pmem_device *pmem)
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
index 8789a114f37c..21dc5de483f6 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -181,4 +181,8 @@ static inline int arch_phys_wc_index(int handle)
 #endif
 #endif
 
+extern void *memremap_cache(resource_size_t offset, size_t size);
+extern void *memremap_wt(resource_size_t offset, size_t size);
+extern void memunmap(void *addr);
+
 #endif /* _LINUX_IO_H */
diff --git a/kernel/resource.c b/kernel/resource.c
index 90552aab5f2d..2f8aca09da52 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -23,7 +23,7 @@
 #include <linux/pfn.h>
 #include <linux/mm.h>
 #include <linux/resource_ext.h>
-#include <asm/io.h>
+#include <linux/io.h>
 
 
 struct resource ioport_resource = {
@@ -528,6 +528,45 @@ int region_is_ram(resource_size_t start, unsigned long size)
 	return ret;
 }
 
+#ifdef CONFIG_ARCH_HAS_MEMREMAP
+/*
+ * memremap() is "ioremap" for cases where it is known that the resource
+ * being mapped does not have i/o side effects and the __iomem
+ * annotation is not applicable.
+ */
+static bool memremap_valid(resource_size_t offset, size_t size)
+{
+	if (region_is_ram(offset, size) != 0) {
+		WARN_ONCE(1, "memremap attempted on ram %pa size: %zu\n",
+				&offset, size);
+		return false;
+	}
+	return true;
+}
+
+void *memremap_cache(resource_size_t offset, size_t size)
+{
+	if (!memremap_valid(offset, size))
+		return NULL;
+	return (void __force *) ioremap_cache(offset, size);
+}
+EXPORT_SYMBOL(memremap_cache);
+
+void *memremap_wt(resource_size_t offset, size_t size)
+{
+	if (!memremap_valid(offset, size))
+		return NULL;
+	return (void __force *) ioremap_wt(offset, size);
+}
+EXPORT_SYMBOL(memremap_wt);
+
+void memunmap(void *addr)
+{
+	iounmap((void __iomem __force *) addr);
+}
+EXPORT_SYMBOL(memunmap);
+#endif /* CONFIG_ARCH_HAS_MEMREMAP */
+
 void __weak arch_remove_reservations(struct resource *avail)
 {
 }
diff --git a/lib/Kconfig b/lib/Kconfig
index 601965a948e8..bc7bc0278921 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -520,6 +520,9 @@ source "lib/fonts/Kconfig"
 #
 
 config ARCH_HAS_SG_CHAIN
-	def_bool n
+	bool
+
+config ARCH_HAS_MEMREMAP
+	bool
 
 endmenu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
