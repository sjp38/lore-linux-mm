Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4148E00E4
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 19:12:11 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so11711993plr.8
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:12:11 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u7si14323549pfu.270.2018.12.11.16.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 16:12:10 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 4/4] x86/vmalloc: Add TLB efficient x86 arch_vunmap
Date: Tue, 11 Dec 2018 16:03:54 -0800
Message-Id: <20181212000354.31955-5-rick.p.edgecombe@intel.com>
In-Reply-To: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, namit@vmware.com, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com
Cc: kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This adds a more efficient x86 architecture specific implementation of
arch_vunmap, that can free any type of special permission memory with only 1 TLB
flush.

In order to enable this, _set_pages_p and _set_pages_np are made non-static and
renamed set_pages_p_noflush and set_pages_np_noflush to better communicate
their different (non-flushing) behavior from the rest of the set_pages_*
functions.

The method for doing this with only 1 TLB flush was suggested by Andy
Lutomirski.

Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/set_memory.h |  2 +
 arch/x86/mm/Makefile              |  3 +-
 arch/x86/mm/pageattr.c            | 11 +++--
 arch/x86/mm/vmalloc.c             | 71 +++++++++++++++++++++++++++++++
 4 files changed, 80 insertions(+), 7 deletions(-)
 create mode 100644 arch/x86/mm/vmalloc.c

diff --git a/arch/x86/include/asm/set_memory.h b/arch/x86/include/asm/set_memory.h
index 07a25753e85c..70ee81e8914b 100644
--- a/arch/x86/include/asm/set_memory.h
+++ b/arch/x86/include/asm/set_memory.h
@@ -84,6 +84,8 @@ int set_pages_x(struct page *page, int numpages);
 int set_pages_nx(struct page *page, int numpages);
 int set_pages_ro(struct page *page, int numpages);
 int set_pages_rw(struct page *page, int numpages);
+int set_pages_np_noflush(struct page *page, int numpages);
+int set_pages_p_noflush(struct page *page, int numpages);
 
 extern int kernel_set_to_readonly;
 void set_kernel_text_rw(void);
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd6e52f..189681f863a6 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -13,7 +13,8 @@ CFLAGS_REMOVE_mem_encrypt_identity.o	= -pg
 endif
 
 obj-y	:=  init.o init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
-	    pat.o pgtable.o physaddr.o setup_nx.o tlb.o cpu_entry_area.o
+	    pat.o pgtable.o physaddr.o setup_nx.o tlb.o cpu_entry_area.o \
+	    vmalloc.o
 
 # Make sure __phys_addr has no stackprotector
 nostackp := $(call cc-option, -fno-stack-protector)
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index db7a10082238..db0a4dfb5a7f 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -2248,9 +2248,7 @@ int set_pages_rw(struct page *page, int numpages)
 	return set_memory_rw(addr, numpages);
 }
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-
-static int __set_pages_p(struct page *page, int numpages)
+int set_pages_p_noflush(struct page *page, int numpages)
 {
 	unsigned long tempaddr = (unsigned long) page_address(page);
 	struct cpa_data cpa = { .vaddr = &tempaddr,
@@ -2269,7 +2267,7 @@ static int __set_pages_p(struct page *page, int numpages)
 	return __change_page_attr_set_clr(&cpa, 0);
 }
 
-static int __set_pages_np(struct page *page, int numpages)
+int set_pages_np_noflush(struct page *page, int numpages)
 {
 	unsigned long tempaddr = (unsigned long) page_address(page);
 	struct cpa_data cpa = { .vaddr = &tempaddr,
@@ -2288,6 +2286,7 @@ static int __set_pages_np(struct page *page, int numpages)
 	return __change_page_attr_set_clr(&cpa, 0);
 }
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
 void __kernel_map_pages(struct page *page, int numpages, int enable)
 {
 	if (PageHighMem(page))
@@ -2303,9 +2302,9 @@ void __kernel_map_pages(struct page *page, int numpages, int enable)
 	 * and hence no memory allocations during large page split.
 	 */
 	if (enable)
-		__set_pages_p(page, numpages);
+		set_pages_p_noflush(page, numpages);
 	else
-		__set_pages_np(page, numpages);
+		set_pages_np_noflush(page, numpages);
 
 	/*
 	 * We should perform an IPI and flush all tlbs,
diff --git a/arch/x86/mm/vmalloc.c b/arch/x86/mm/vmalloc.c
new file mode 100644
index 000000000000..be9ea42c3dfe
--- /dev/null
+++ b/arch/x86/mm/vmalloc.c
@@ -0,0 +1,71 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * vmalloc.c: x86 arch version of vmalloc.c
+ *
+ * (C) Copyright 2018 Intel Corporation
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#include <linux/mm.h>
+#include <linux/set_memory.h>
+#include <linux/vmalloc.h>
+
+static void set_area_direct_np(struct vm_struct *area)
+{
+	int i;
+
+	for (i = 0; i < area->nr_pages; i++)
+		set_pages_np_noflush(area->pages[i], 1);
+}
+
+static void set_area_direct_prw(struct vm_struct *area)
+{
+	int i;
+
+	for (i = 0; i < area->nr_pages; i++)
+		set_pages_p_noflush(area->pages[i], 1);
+}
+
+void arch_vunmap(struct vm_struct *area, int deallocate_pages)
+{
+	int immediate = area->flags & VM_IMMEDIATE_UNMAP;
+	int special = area->flags & VM_HAS_SPECIAL_PERMS;
+
+	/* Unmap from vmalloc area */
+	remove_vm_area(area->addr);
+
+	/* If no need to reset directmap perms, just check if need to flush */
+	if (!(deallocate_pages || special)) {
+		if (immediate)
+			vm_unmap_aliases();
+		return;
+	}
+
+	/* From here we need to make sure to reset the direct map perms */
+
+	/*
+	 * If the area being freed does not have any extra capabilities, we can
+	 * just reset the directmap to RW before freeing.
+	 */
+	if (!immediate) {
+		set_area_direct_prw(area);
+		vm_unmap_aliases();
+		return;
+	}
+
+	/*
+	 * If the vm being freed has security sensitive capabilities such as
+	 * executable we need to make sure there is no W window on the directmap
+	 * before removing the X in the TLB. So we set not present first so we
+	 * can flush without any other CPU picking up the mapping. Then we reset
+	 * RW+P without a flush, since NP prevented it from being cached by
+	 * other cpus.
+	 */
+	set_area_direct_np(area);
+	vm_unmap_aliases();
+	set_area_direct_prw(area);
+}
-- 
2.17.1
