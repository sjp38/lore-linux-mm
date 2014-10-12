Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 040176B0071
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 00:51:54 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so4028872pab.20
        for <linux-mm@kvack.org>; Sat, 11 Oct 2014 21:51:54 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ov9si7510017pdb.7.2014.10.11.21.51.53
        for <linux-mm@kvack.org>;
        Sat, 11 Oct 2014 21:51:53 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v9 03/12] x86, mpx: add MPX specific mmap interface
Date: Sun, 12 Oct 2014 12:41:46 +0800
Message-Id: <1413088915-13428-4-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, Qiaowei Ren <qiaowei.ren@intel.com>

We have to do the allocation of bounds tables in kernel (See the patch
"on-demand kernel allocation of bounds tables"). Moreover, if we want
to track MPX VMAs we need to be able to stick new VM_MPX flag and a
specific vm_ops for MPX in the vma_area_struct.

But there are not suitable interfaces to do this in current kernel.
Existing interfaces, like do_mmap_pgoff(), could not stick specific
->vm_ops in the vma_area_struct when a VMA is created. So, this patch
adds MPX specific mmap interface to do the allocation of bounds tables.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/Kconfig           |    4 ++
 arch/x86/include/asm/mpx.h |   38 +++++++++++++++++++++
 arch/x86/mm/Makefile       |    2 +
 arch/x86/mm/mpx.c          |   79 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 123 insertions(+), 0 deletions(-)
 create mode 100644 arch/x86/include/asm/mpx.h
 create mode 100644 arch/x86/mm/mpx.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 4b663e1..e5bcc70 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -243,6 +243,10 @@ config HAVE_INTEL_TXT
 	def_bool y
 	depends on INTEL_IOMMU && ACPI
 
+config X86_INTEL_MPX
+	def_bool y
+	depends on CPU_SUP_INTEL
+
 config X86_32_SMP
 	def_bool y
 	depends on X86_32 && SMP
diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
new file mode 100644
index 0000000..5725ac4
--- /dev/null
+++ b/arch/x86/include/asm/mpx.h
@@ -0,0 +1,38 @@
+#ifndef _ASM_X86_MPX_H
+#define _ASM_X86_MPX_H
+
+#include <linux/types.h>
+#include <asm/ptrace.h>
+
+#ifdef CONFIG_X86_64
+
+/* upper 28 bits [47:20] of the virtual address in 64-bit used to
+ * index into bounds directory (BD).
+ */
+#define MPX_BD_ENTRY_OFFSET	28
+#define MPX_BD_ENTRY_SHIFT	3
+/* bits [19:3] of the virtual address in 64-bit used to index into
+ * bounds table (BT).
+ */
+#define MPX_BT_ENTRY_OFFSET	17
+#define MPX_BT_ENTRY_SHIFT	5
+#define MPX_IGN_BITS		3
+
+#else
+
+#define MPX_BD_ENTRY_OFFSET	20
+#define MPX_BD_ENTRY_SHIFT	2
+#define MPX_BT_ENTRY_OFFSET	10
+#define MPX_BT_ENTRY_SHIFT	4
+#define MPX_IGN_BITS		2
+
+#endif
+
+#define MPX_BD_SIZE_BYTES (1UL<<(MPX_BD_ENTRY_OFFSET+MPX_BD_ENTRY_SHIFT))
+#define MPX_BT_SIZE_BYTES (1UL<<(MPX_BT_ENTRY_OFFSET+MPX_BT_ENTRY_SHIFT))
+
+#define MPX_BNDSTA_ERROR_CODE	0x3
+
+unsigned long mpx_mmap(unsigned long len);
+
+#endif /* _ASM_X86_MPX_H */
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 6a19ad9..ecfdc46 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -30,3 +30,5 @@ obj-$(CONFIG_ACPI_NUMA)		+= srat.o
 obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
 
 obj-$(CONFIG_MEMTEST)		+= memtest.o
+
+obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
new file mode 100644
index 0000000..e1b28e6
--- /dev/null
+++ b/arch/x86/mm/mpx.c
@@ -0,0 +1,79 @@
+#include <linux/kernel.h>
+#include <linux/syscalls.h>
+#include <asm/mpx.h>
+#include <asm/mman.h>
+#include <linux/sched/sysctl.h>
+
+static const char *mpx_mapping_name(struct vm_area_struct *vma)
+{
+	return "[mpx]";
+}
+
+static struct vm_operations_struct mpx_vma_ops = {
+	.name = mpx_mapping_name,
+};
+
+/*
+ * this is really a simplified "vm_mmap". it only handles mpx
+ * related maps, including bounds table and bounds directory.
+ *
+ * here we can stick new vm_flag VM_MPX in the vma_area_struct
+ * when create a bounds table or bounds directory, in order to
+ * track MPX specific memory.
+ */
+unsigned long mpx_mmap(unsigned long len)
+{
+	unsigned long ret;
+	unsigned long addr, pgoff;
+	struct mm_struct *mm = current->mm;
+	vm_flags_t vm_flags;
+	struct vm_area_struct *vma;
+
+	/* Only bounds table and bounds directory can be allocated here */
+	if (len != MPX_BD_SIZE_BYTES && len != MPX_BT_SIZE_BYTES)
+		return -EINVAL;
+
+	down_write(&mm->mmap_sem);
+
+	/* Too many mappings? */
+	if (mm->map_count > sysctl_max_map_count) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* Obtain the address to map to. we verify (or select) it and ensure
+	 * that it represents a valid section of the address space.
+	 */
+	addr = get_unmapped_area(NULL, 0, len, 0, MAP_ANONYMOUS | MAP_PRIVATE);
+	if (addr & ~PAGE_MASK) {
+		ret = addr;
+		goto out;
+	}
+
+	vm_flags = VM_READ | VM_WRITE | VM_MPX |
+			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
+
+	/* Set pgoff according to addr for anon_vma */
+	pgoff = addr >> PAGE_SHIFT;
+
+	ret = mmap_region(NULL, addr, len, vm_flags, pgoff);
+	if (IS_ERR_VALUE(ret))
+		goto out;
+
+	vma = find_vma(mm, ret);
+	if (!vma) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	vma->vm_ops = &mpx_vma_ops;
+
+	if (vm_flags & VM_LOCKED) {
+		up_write(&mm->mmap_sem);
+		mm_populate(ret, len);
+		return ret;
+	}
+
+out:
+	up_write(&mm->mmap_sem);
+	return ret;
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
