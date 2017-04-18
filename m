Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34F2A6B03A0
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:14:38 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id n64so3906353oia.8
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:14:38 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0050.outbound.protection.outlook.com. [104.47.41.50])
        by mx.google.com with ESMTPS id n9si140413oia.57.2017.04.18.14.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:14:37 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 03/32] x86, mpparse, x86/acpi, x86/PCI,
 SFI: Use memremap for RAM mappings
Date: Tue, 18 Apr 2017 16:14:31 -0500
Message-ID: <20170418211431.9689.54269.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211400.9689.10175.stgit@tlendack-t1.amdoffice.net>
References: <20170418211400.9689.10175.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

The ioremap() function is intended for mapping MMIO. For RAM, the
memremap() function can be used. Convert calls from ioremap() to
memremap() when re-mapping RAM.

This will be used later by SME to control how the encryption mask is
applied to memory mappings, with certain memory locations being mapped
decrypted vs encrypted.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/acpi/boot.c |    6 +++---
 arch/x86/kernel/kdebugfs.c  |   34 +++++++++++-----------------------
 arch/x86/kernel/ksysfs.c    |   28 ++++++++++++++--------------
 arch/x86/kernel/mpparse.c   |   10 +++++-----
 arch/x86/pci/common.c       |    4 ++--
 drivers/sfi/sfi_core.c      |   22 +++++++++++-----------
 6 files changed, 46 insertions(+), 58 deletions(-)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 6bb6806..850160a 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -115,7 +115,7 @@
 #define	ACPI_INVALID_GSI		INT_MIN
 
 /*
- * This is just a simple wrapper around early_ioremap(),
+ * This is just a simple wrapper around early_memremap(),
  * with sanity checks for phys == 0 and size == 0.
  */
 char *__init __acpi_map_table(unsigned long phys, unsigned long size)
@@ -124,7 +124,7 @@ char *__init __acpi_map_table(unsigned long phys, unsigned long size)
 	if (!phys || !size)
 		return NULL;
 
-	return early_ioremap(phys, size);
+	return early_memremap(phys, size);
 }
 
 void __init __acpi_unmap_table(char *map, unsigned long size)
@@ -132,7 +132,7 @@ void __init __acpi_unmap_table(char *map, unsigned long size)
 	if (!map || !size)
 		return;
 
-	early_iounmap(map, size);
+	early_memunmap(map, size);
 }
 
 #ifdef CONFIG_X86_LOCAL_APIC
diff --git a/arch/x86/kernel/kdebugfs.c b/arch/x86/kernel/kdebugfs.c
index 38b6458..fd6f8fb 100644
--- a/arch/x86/kernel/kdebugfs.c
+++ b/arch/x86/kernel/kdebugfs.c
@@ -33,7 +33,6 @@ static ssize_t setup_data_read(struct file *file, char __user *user_buf,
 	struct setup_data_node *node = file->private_data;
 	unsigned long remain;
 	loff_t pos = *ppos;
-	struct page *pg;
 	void *p;
 	u64 pa;
 
@@ -47,18 +46,13 @@ static ssize_t setup_data_read(struct file *file, char __user *user_buf,
 		count = node->len - pos;
 
 	pa = node->paddr + sizeof(struct setup_data) + pos;
-	pg = pfn_to_page((pa + count - 1) >> PAGE_SHIFT);
-	if (PageHighMem(pg)) {
-		p = ioremap_cache(pa, count);
-		if (!p)
-			return -ENXIO;
-	} else
-		p = __va(pa);
+	p = memremap(pa, count, MEMREMAP_WB);
+	if (!p)
+		return -ENOMEM;
 
 	remain = copy_to_user(user_buf, p, count);
 
-	if (PageHighMem(pg))
-		iounmap(p);
+	memunmap(p);
 
 	if (remain)
 		return -EFAULT;
@@ -109,7 +103,6 @@ static int __init create_setup_data_nodes(struct dentry *parent)
 	struct setup_data *data;
 	int error;
 	struct dentry *d;
-	struct page *pg;
 	u64 pa_data;
 	int no = 0;
 
@@ -126,16 +119,12 @@ static int __init create_setup_data_nodes(struct dentry *parent)
 			goto err_dir;
 		}
 
-		pg = pfn_to_page((pa_data+sizeof(*data)-1) >> PAGE_SHIFT);
-		if (PageHighMem(pg)) {
-			data = ioremap_cache(pa_data, sizeof(*data));
-			if (!data) {
-				kfree(node);
-				error = -ENXIO;
-				goto err_dir;
-			}
-		} else
-			data = __va(pa_data);
+		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
+		if (!data) {
+			kfree(node);
+			error = -ENOMEM;
+			goto err_dir;
+		}
 
 		node->paddr = pa_data;
 		node->type = data->type;
@@ -143,8 +132,7 @@ static int __init create_setup_data_nodes(struct dentry *parent)
 		error = create_setup_data_node(d, no, node);
 		pa_data = data->next;
 
-		if (PageHighMem(pg))
-			iounmap(data);
+		memunmap(data);
 		if (error)
 			goto err_dir;
 		no++;
diff --git a/arch/x86/kernel/ksysfs.c b/arch/x86/kernel/ksysfs.c
index 4afc67f..ee51db9 100644
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
+		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
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
+		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
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
+	data = memremap(paddr, sizeof(*data), MEMREMAP_WB);
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
+	data = memremap(paddr, sizeof(*data), MEMREMAP_WB);
 	if (!data)
 		return -ENOMEM;
 
@@ -170,15 +170,15 @@ static ssize_t setup_data_data_read(struct file *fp,
 		goto out;
 
 	ret = count;
-	p = ioremap_cache(paddr + sizeof(*data), data->len);
+	p = memremap(paddr + sizeof(*data), data->len, MEMREMAP_WB);
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
+		data = memremap(pa_data, sizeof(*data), MEMREMAP_WB);
 		if (!data) {
 			ret = -ENOMEM;
 			goto out;
 		}
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 	}
 
 out:
diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
index 0d904d7..fd37f39 100644
--- a/arch/x86/kernel/mpparse.c
+++ b/arch/x86/kernel/mpparse.c
@@ -436,9 +436,9 @@ static unsigned long __init get_mpc_size(unsigned long physptr)
 	struct mpc_table *mpc;
 	unsigned long size;
 
-	mpc = early_ioremap(physptr, PAGE_SIZE);
+	mpc = early_memremap(physptr, PAGE_SIZE);
 	size = mpc->length;
-	early_iounmap(mpc, PAGE_SIZE);
+	early_memunmap(mpc, PAGE_SIZE);
 	apic_printk(APIC_VERBOSE, "  mpc: %lx-%lx\n", physptr, physptr + size);
 
 	return size;
@@ -450,7 +450,7 @@ static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
 	unsigned long size;
 
 	size = get_mpc_size(mpf->physptr);
-	mpc = early_ioremap(mpf->physptr, size);
+	mpc = early_memremap(mpf->physptr, size);
 	/*
 	 * Read the physical hardware table.  Anything here will
 	 * override the defaults.
@@ -461,10 +461,10 @@ static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
 #endif
 		pr_err("BIOS bug, MP table errors detected!...\n");
 		pr_cont("... disabling SMP support. (tell your hw vendor)\n");
-		early_iounmap(mpc, size);
+		early_memunmap(mpc, size);
 		return -1;
 	}
-	early_iounmap(mpc, size);
+	early_memunmap(mpc, size);
 
 	if (early)
 		return -1;
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index 190e718..08cf71c 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -691,7 +691,7 @@ int pcibios_add_device(struct pci_dev *dev)
 
 	pa_data = boot_params.hdr.setup_data;
 	while (pa_data) {
-		data = ioremap(pa_data, sizeof(*rom));
+		data = memremap(pa_data, sizeof(*rom), MEMREMAP_WB);
 		if (!data)
 			return -ENOMEM;
 
@@ -710,7 +710,7 @@ int pcibios_add_device(struct pci_dev *dev)
 			}
 		}
 		pa_data = data->next;
-		iounmap(data);
+		memunmap(data);
 	}
 	set_dma_domain_ops(dev);
 	set_dev_domain_options(dev);
diff --git a/drivers/sfi/sfi_core.c b/drivers/sfi/sfi_core.c
index 296db7a..d5ce534 100644
--- a/drivers/sfi/sfi_core.c
+++ b/drivers/sfi/sfi_core.c
@@ -86,13 +86,13 @@
 /*
  * FW creates and saves the SFI tables in memory. When these tables get
  * used, they may need to be mapped to virtual address space, and the mapping
- * can happen before or after the ioremap() is ready, so a flag is needed
+ * can happen before or after the memremap() is ready, so a flag is needed
  * to indicating this
  */
-static u32 sfi_use_ioremap __read_mostly;
+static u32 sfi_use_memremap __read_mostly;
 
 /*
- * sfi_un/map_memory calls early_ioremap/iounmap which is a __init function
+ * sfi_un/map_memory calls early_memremap/memunmap which is a __init function
  * and introduces section mismatch. So use __ref to make it calm.
  */
 static void __iomem * __ref sfi_map_memory(u64 phys, u32 size)
@@ -100,10 +100,10 @@ static void __iomem * __ref sfi_map_memory(u64 phys, u32 size)
 	if (!phys || !size)
 		return NULL;
 
-	if (sfi_use_ioremap)
-		return ioremap_cache(phys, size);
+	if (sfi_use_memremap)
+		return memremap(phys, size, MEMREMAP_WB);
 	else
-		return early_ioremap(phys, size);
+		return early_memremap(phys, size);
 }
 
 static void __ref sfi_unmap_memory(void __iomem *virt, u32 size)
@@ -111,10 +111,10 @@ static void __ref sfi_unmap_memory(void __iomem *virt, u32 size)
 	if (!virt || !size)
 		return;
 
-	if (sfi_use_ioremap)
-		iounmap(virt);
+	if (sfi_use_memremap)
+		memunmap(virt);
 	else
-		early_iounmap(virt, size);
+		early_memunmap(virt, size);
 }
 
 static void sfi_print_table_header(unsigned long long pa,
@@ -507,8 +507,8 @@ void __init sfi_init_late(void)
 	length = syst_va->header.len;
 	sfi_unmap_memory(syst_va, sizeof(struct sfi_table_simple));
 
-	/* Use ioremap now after it is ready */
-	sfi_use_ioremap = 1;
+	/* Use memremap now after it is ready */
+	sfi_use_memremap = 1;
 	syst_va = sfi_map_memory(syst_pa, length);
 
 	sfi_acpi_init();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
