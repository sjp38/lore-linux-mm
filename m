Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAD01C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84AE520818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84AE520818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BA018E00D3; Thu, 21 Feb 2019 18:51:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 390958E00CD; Thu, 21 Feb 2019 18:51:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25F578E00D3; Thu, 21 Feb 2019 18:51:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C14578E00CD
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:09 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 11so309909pgd.19
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=oSQbwij47yA17Mv3fSz7kQf6by0ffGswaqjnStQPtTI=;
        b=SZwkOlYtHR5V/N3VVmG5DOkuzdnmb1t7W6XqNa/JL06hadtOdS03deJQiCCOWG0WTa
         z5YuQhjpMh5ESTN+2LKA7OP2feDirJ9TYnkqx4XoYVgVhDXIxspmSDUJ8iB11r/Jc4Tg
         yoFevHEXsYH1MMYajkLQ3jro0Ih6RNfimf1RVIxGr/nf8Mkym//w1O1dD2OOG29DKBHk
         cP4LLTg+27vDpmfw5PL0kEbmOH92Lp+dm1wEQFitEvW1ZDjkolOh2xVqLEfDVr4NdTYg
         PS5hGTilL5W+eJ0mIQSV2GfPad1RlvvEtO9eSeBVCW/oTAH32lPlCabQZdx4XRcNUTWr
         bSuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubxo0oL8Ebj8MpVp4NRyhdwdw6UL1kdV6cXVHWfaQiGW8C6Sxh/
	PAiMWDRzcAgRxdSR1+Lb3N9/BZZPnRs9K3hiXrcIpfNayZ/GKRH/u6w4m1FsgsVCmdOvIoUnFNZ
	ip+WdJW9lwB18gbrNa4pAff7k1gya8x8K43XlFE/xmZKw0GpUCNrZ4PsdtdnvZbXO2Q==
X-Received: by 2002:a17:902:684:: with SMTP id 4mr1167453plh.3.1550793069419;
        Thu, 21 Feb 2019 15:51:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZGb41Wec+8dVE1L1VxzuUM3ONecKG5YsTixouxNQH/LXEXG6lTX+GlPv+t1nX2lkyitbK
X-Received: by 2002:a17:902:684:: with SMTP id 4mr1167387plh.3.1550793068274;
        Thu, 21 Feb 2019 15:51:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793068; cv=none;
        d=google.com; s=arc-20160816;
        b=rc1U0U86n9gW/i7hHOh8ReKquvCedEARpQQALOpScm8JGNWcIs6QlfFmz5zruc101W
         hl4zJ1hkwtloa4GFASMEyiOdKXsUBD5iMlrHhYtnlnuTgEvPoazjE+tz7TLQulS/7DOJ
         JFtrzVwmteTE+5ZNX4ehTLjlyqznyVi18gV4lu+DYW8Y0uyyKOwrJ59pIaJlM2Ugt7dB
         VaA3MyUg0jcYt0eIvvScrp9ooPZG6Ajs6AGRsc/iLQ0HuTy4e4frxP3RAcp7C/8xkbKc
         ofmPi/D85IhykTwIwa1EdzLEVVXLoJVr6Uwx5Ym52zrsFjRxmEX0FOWEL0fHUNJZMAMF
         xgMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=oSQbwij47yA17Mv3fSz7kQf6by0ffGswaqjnStQPtTI=;
        b=H7guowkBPrAZDBXY/P7Gun5GXBtltAuwXtWFa19teQQkKAuH7Y/6VWof9Ibdnb/o7P
         ji33AoASQDh1oPKRihjvwVizFQX8JmJj5n2i3FB4fnq4rXR8sYwkkA1uBrwI/1FtXCjc
         Y9On/QJ6RRhoUuDh1ee9mxng932sAtiKB8ASQWOwVKPcja48UpIsLcWLZ7piO1AZiguu
         lRehOpYEPJrOiD+Blh+T9dz9s0oeYwoYaqpzMHDXl+DWKuNRxFyFvL08BK+PydHCePd6
         IIOwLfaj0geegnonhaktZCYTD8/7tpeI3b/TPIpOL6wuG0xjzj4xVmpY2k0fludnku2Q
         Eyiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:08 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:07 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394938"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:06 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 15/20] vmalloc: Add flag for free of special permsissions
Date: Thu, 21 Feb 2019 15:44:46 -0800
Message-Id: <20190221234451.17632-16-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a new flag VM_FLUSH_RESET_PERMS, for enabling vfree operations to
immediately clear executable TLB entries before freeing pages, and handle
resetting permissions on the directmap. This flag is useful for any kind
of memory with elevated permissions, or where there can be related
permissions changes on the directmap. Today this is RO+X and RO memory.

Although this enables directly vfreeing non-writeable memory now,
non-writable memory cannot be freed in an interrupt because the allocation
itself is used as a node on deferred free list. So when RO memory needs to
be freed in an interrupt the code doing the vfree needs to have its own
work queue, as was the case before the deferred vfree list was added to
vmalloc.

For architectures with set_direct_map_ implementations this whole operation
can be done with one TLB flush when centralized like this. For others with
directmap permissions, currently only arm64, a backup method using
set_memory functions is used to reset the directmap. When arm64 adds
set_direct_map_ functions, this backup can be removed.

When the TLB is flushed to both remove TLB entries for the vmalloc range
mapping and the direct map permissions, the lazy purge operation could be
done to try to save a TLB flush later. However today vm_unmap_aliases
could flush a TLB range that does not include the directmap. So a helper
is added with extra parameters that can allow both the vmalloc address and
the direct mapping to be flushed during this operation. The behavior of the
normal vm_unmap_aliases function is unchanged.

Cc: Borislav Petkov <bp@alien8.de>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Suggested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |  13 +++++
 mm/vmalloc.c            | 113 +++++++++++++++++++++++++++++++++-------
 2 files changed, 107 insertions(+), 19 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..345bb9d2f578 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,6 +21,11 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+/*
+ * Memory with VM_FLUSH_RESET_PERMS cannot be freed in an interrupt or with
+ * vfree_atomic().
+ */
+#define VM_FLUSH_RESET_PERMS	0x00000100      /* Reset direct map and flush TLB on unmap */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -135,6 +140,14 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 extern struct vm_struct *remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
 
+static inline void set_vm_flush_reset_perms(void *addr)
+{
+	struct vm_struct *vm = find_vm_area(addr);
+
+	if (vm)
+		vm->flags |= VM_FLUSH_RESET_PERMS;
+}
+
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page **pages);
 #ifdef CONFIG_MMU
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 871e41c55e23..0e341581832e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/set_memory.h>
 #include <linux/debugobjects.h>
 #include <linux/kallsyms.h>
 #include <linux/list.h>
@@ -1055,24 +1056,9 @@ static void vb_free(const void *addr, unsigned long size)
 		spin_unlock(&vb->lock);
 }
 
-/**
- * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
- *
- * The vmap/vmalloc layer lazily flushes kernel virtual mappings primarily
- * to amortize TLB flushing overheads. What this means is that any page you
- * have now, may, in a former life, have been mapped into kernel virtual
- * address by the vmap layer and so there might be some CPUs with TLB entries
- * still referencing that page (additional to the regular 1:1 kernel mapping).
- *
- * vm_unmap_aliases flushes all such lazy mappings. After it returns, we can
- * be sure that none of the pages we have control over will have any aliases
- * from the vmap layer.
- */
-void vm_unmap_aliases(void)
+static void _vm_unmap_aliases(unsigned long start, unsigned long end, int flush)
 {
-	unsigned long start = ULONG_MAX, end = 0;
 	int cpu;
-	int flush = 0;
 
 	if (unlikely(!vmap_initialized))
 		return;
@@ -1109,6 +1095,27 @@ void vm_unmap_aliases(void)
 		flush_tlb_kernel_range(start, end);
 	mutex_unlock(&vmap_purge_lock);
 }
+
+/**
+ * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
+ *
+ * The vmap/vmalloc layer lazily flushes kernel virtual mappings primarily
+ * to amortize TLB flushing overheads. What this means is that any page you
+ * have now, may, in a former life, have been mapped into kernel virtual
+ * address by the vmap layer and so there might be some CPUs with TLB entries
+ * still referencing that page (additional to the regular 1:1 kernel mapping).
+ *
+ * vm_unmap_aliases flushes all such lazy mappings. After it returns, we can
+ * be sure that none of the pages we have control over will have any aliases
+ * from the vmap layer.
+ */
+void vm_unmap_aliases(void)
+{
+	unsigned long start = ULONG_MAX, end = 0;
+	int flush = 0;
+
+	_vm_unmap_aliases(start, end, flush);
+}
 EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 
 /**
@@ -1494,6 +1501,72 @@ struct vm_struct *remove_vm_area(const void *addr)
 	return NULL;
 }
 
+static inline void set_area_direct_map(const struct vm_struct *area,
+				       int (*set_direct_map)(struct page *page))
+{
+	int i;
+
+	for (i = 0; i < area->nr_pages; i++)
+		if (page_address(area->pages[i]))
+			set_direct_map(area->pages[i]);
+}
+
+/* Handle removing and resetting vm mappings related to the vm_struct. */
+static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
+{
+	unsigned long addr = (unsigned long)area->addr;
+	unsigned long start = ULONG_MAX, end = 0;
+	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
+	int i;
+
+	/*
+	 * The below block can be removed when all architectures that have
+	 * direct map permissions also have set_direct_map_() implementations.
+	 * This is concerned with resetting the direct map any an vm alias with
+	 * execute permissions, without leaving a RW+X window.
+	 */
+	if (flush_reset && !IS_ENABLED(CONFIG_ARCH_HAS_SET_DIRECT_MAP)) {
+		set_memory_nx(addr, area->nr_pages);
+		set_memory_rw(addr, area->nr_pages);
+	}
+
+	remove_vm_area(area->addr);
+
+	/* If this is not VM_FLUSH_RESET_PERMS memory, no need for the below. */
+	if (!flush_reset)
+		return;
+
+	/*
+	 * If not deallocating pages, just do the flush of the VM area and
+	 * return.
+	 */
+	if (!deallocate_pages) {
+		vm_unmap_aliases();
+		return;
+	}
+
+	/*
+	 * If execution gets here, flush the vm mapping and reset the direct
+	 * map. Find the start and end range of the direct mappings to make sure
+	 * the vm_unmap_aliases() flush includes the direct map.
+	 */
+	for (i = 0; i < area->nr_pages; i++) {
+		if (page_address(area->pages[i])) {
+			start = min(addr, start);
+			end = max(addr, end);
+		}
+	}
+
+	/*
+	 * Set direct map to something invalid so that it won't be cached if
+	 * there are any accesses after the TLB flush, then flush the TLB and
+	 * reset the direct map permissions to the default.
+	 */
+	set_area_direct_map(area, set_direct_map_invalid_noflush);
+	_vm_unmap_aliases(start, end, 1);
+	set_area_direct_map(area, set_direct_map_default_noflush);
+}
+
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
@@ -1515,7 +1588,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	vm_remove_mappings(area, deallocate_pages);
+
 	if (deallocate_pages) {
 		int i;
 
@@ -1925,8 +1999,9 @@ EXPORT_SYMBOL(vzalloc_node);
 
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
-			      NUMA_NO_NODE, __builtin_return_address(0));
+	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
+			GFP_KERNEL, PAGE_KERNEL_EXEC, VM_FLUSH_RESET_PERMS,
+			NUMA_NO_NODE, __builtin_return_address(0));
 }
 
 #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
-- 
2.17.1

