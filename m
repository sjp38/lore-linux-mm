Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B815C6B025E
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 10:22:40 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so42734413pab.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:22:40 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id k7si9196006pag.88.2016.08.12.07.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 07:22:39 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id vy10so1567487pac.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:22:39 -0700 (PDT)
From: Ronit Halder <ronit.crj@gmail.com>
Subject: [RFC 2/4] Functions for memory reservation and release
Date: Fri, 12 Aug 2016 19:51:59 +0530
Message-Id: <20160812142159.6101-1-ronit.crj@gmail.com>
In-Reply-To: <20160812141838.5973-1-ronit.crj@gmail.com>
References: <20160812141838.5973-1-ronit.crj@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, dyoung@redhat.com, jroedel@suse.de, krzysiek@podlesie.net, msalter@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, bhe@redhat.com, vgoyal@redhat.com, mnfhuang@gmail.com, kexec@lists.infradead.org, kirill.shutemov@linux.intel.com, mchehab@osg.samsung.com, aarcange@redhat.com, vdavydov@parallels.com, dan.j.williams@intel.com, jack@suse.cz, linux-mm@kvack.org, Ronit Halder <ronit.crj@gmail.com>

Functions reserve and release memory from CMA area(s).

Signed-off-by: Ronit Halder <ronit.crj@gmail.com>

---
 include/linux/kexec.h | 11 ++++++-
 kernel/kexec_core.c   | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 93 insertions(+), 1 deletion(-)

diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index d140b1e..9a1af44 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -307,7 +307,6 @@ extern size_t vmcoreinfo_max_size;
 
 /* flag to track if kexec reboot is in progress */
 extern bool kexec_in_progress;
-
 int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
 		unsigned long long *crash_size, unsigned long long *crash_base);
 int parse_crashkernel_high(char *cmdline, unsigned long long system_ram,
@@ -318,6 +317,16 @@ int crash_shrink_memory(unsigned long new_size);
 size_t crash_get_memory_size(void);
 void crash_free_reserved_phys_range(unsigned long begin, unsigned long end);
 
+#ifdef CONFIG_KEXEC_CMA
+#ifdef CONFIG_X86
+	extern struct cma *crashk_cma, *crashk_cma_low;
+	int crash_free_memory(unsigned int size);
+	int crash_alloc_memory(unsigned int size);
+	int crash_alloc_memory_low(void);
+	int crash_free_memory_low(void);
+	size_t crash_get_memory_size_low(void);
+#endif
+#endif
 int __weak arch_kexec_kernel_image_probe(struct kimage *image, void *buf,
 					 unsigned long buf_len);
 void * __weak arch_kexec_kernel_image_load(struct kimage *image);
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 11b64a6..0ef3385 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -39,6 +39,7 @@
 #include <linux/compiler.h>
 #include <linux/hugetlb.h>
 
+#include <linux/cma.h>
 #include <asm/page.h>
 #include <asm/sections.h>
 
@@ -46,7 +47,9 @@
 #include <crypto/sha.h>
 #include "kexec_internal.h"
 
+#define CRASH_ALIGN		(16 << 20)
 DEFINE_MUTEX(kexec_mutex);
+DEFINE_MUTEX(kexec_mutex_low);
 
 /* Per cpu memory for storing cpu states in case of system crash. */
 note_buf_t __percpu *crash_notes;
@@ -57,6 +60,7 @@ u32 vmcoreinfo_note[VMCOREINFO_NOTE_SIZE/4];
 size_t vmcoreinfo_size;
 size_t vmcoreinfo_max_size = sizeof(vmcoreinfo_data);
 
+static struct page *pages, *pages_low;
 /* Flag to indicate we are going to kexec a new kernel */
 bool kexec_in_progress = false;
 
@@ -946,6 +950,85 @@ unlock:
 	mutex_unlock(&kexec_mutex);
 	return ret;
 }
+#ifdef CONFIG_KEXEC_CMA
+#ifdef CONFIG_X86
+	size_t crash_get_memory_size_low(void)
+	{
+		size_t size = 0;
+
+		mutex_lock(&kexec_mutex_low);
+		if (crashk_low_res.end != crashk_low_res.start)
+			size = resource_size(&crashk_low_res);
+		mutex_unlock(&kexec_mutex_low);
+		return size;
+	}
+	int crash_free_memory(unsigned int size)
+	{
+		int ret;
+
+		if (!crashk_cma)
+			return 0;
+		ret = cma_release(crashk_cma, pages, size >> PAGE_SHIFT);
+
+		if (!ret) {
+			pr_info("Crash memory release failed");
+			return ret;
+		}
+		release_resource(&crashk_res);
+		return 0;
+	}
+
+	int crash_alloc_memory(unsigned int size)
+	{
+		if (!crashk_cma)
+			return 0;
+		pages = cma_alloc(crashk_cma, size >> PAGE_SHIFT, KEXEC_CRASH_MEM_ALIGN);
+
+		if (!pages) {
+			pr_info("Memory for crash kernel not allocated");
+			return -ENOMEM;
+		}
+
+		crashk_res.start = page_to_pfn(pages) << PAGE_SHIFT;
+		crashk_res.end = crashk_res.start + size - 1;
+		insert_resource(&iomem_resource, &crashk_res);
+		return 0;
+	}
+
+	int crash_free_memory_low(void)
+	{
+		int ret;
+
+		if (!crashk_cma_low)
+			return 0;
+		ret = cma_release(crashk_cma_low, pages_low, cma_get_size(crashk_cma_low) >> PAGE_SHIFT);
+
+		if (!ret) {
+			pr_info("Crash low memory release failed");
+			return ret;
+		}
+		release_resource(&crashk_low_res);
+		return 0;
+	}
+
+	int crash_alloc_memory_low(void)
+	{
+		if (!crashk_cma_low)
+			return 0;
+		pages = cma_alloc(crashk_cma_low, cma_get_size(crashk_cma_low) >> PAGE_SHIFT, KEXEC_CRASH_MEM_ALIGN);
+
+		if (!pages) {
+			pr_info("Low memory for crash kernel not allocated");
+			return -ENOMEM;
+		}
+
+		crashk_low_res.start = page_to_pfn(pages) << PAGE_SHIFT;
+		crashk_low_res.end = crashk_low_res.start + cma_get_size(crashk_cma_low) - 1;
+		insert_resource(&iomem_resource, &crashk_low_res);
+		return 0;
+	}
+#endif
+#endif
 
 static u32 *append_elf_note(u32 *buf, char *name, unsigned type, void *data,
 			    size_t data_len)
-- 
2.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
