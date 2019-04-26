Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98D7BC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F5E220C01
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qvNLDfV5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F5E220C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3EB46B0271; Sat, 27 Apr 2019 02:43:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EED2A6B0273; Sat, 27 Apr 2019 02:43:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5AC6B0274; Sat, 27 Apr 2019 02:43:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9527B6B0271
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:31 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id v5so3257884plo.4
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=71dbHy9m/CIhCtlniLjnIfT11ydtbrFJWfPgh/aDBts=;
        b=BlqKcFT59zfaHX9GuIRcXdnk43dVDeSFeO5GTOkSrnyM9yQwjWSM48Y4c1nzbzJsRa
         FuL09xzV4W5ezvw6nqtEN6abSQk3T+usYePNdbYQqIjxCkpxDgzhFQxLzf6wfawmQIlV
         7Rh4ivMc2/heWMbrJ5UrDTeOO/W0RlRe61v1wbO7Sxj36GPKNMOCsmThqpV5HFOiPacD
         kNkXXPFkboVh+qHqZm+gD+i5rjirqzJM0FVRX53Jad5gkBq/q66QNa2MHGn57SBakcxQ
         8TGY2R/AwSWB+9TCcLArguWVsu/FkWRdGJNNIU2fdImGFAM+mGBwZOqDShHsh9EKT+Hh
         X4wQ==
X-Gm-Message-State: APjAAAVvOmlPDBVMIFGb+ormVtOcfIINdzhkwLE5v+u70zTJpKSZ1vt5
	tQELOcWbaoaVsBhsOSI8w1Ud8t6hYQW6DdW1lTURSTI3JM3J533ZKduHu9gb672HDVvsYGnvjcM
	FAoRtBr2BsrQ9jYR+tx5SLlCJCpsNY0vuVktg7DhSNfN82Er5mJ4B1gRb3peogPo0HA==
X-Received: by 2002:a17:902:b181:: with SMTP id s1mr27791594plr.9.1556347411237;
        Fri, 26 Apr 2019 23:43:31 -0700 (PDT)
X-Received: by 2002:a17:902:b181:: with SMTP id s1mr27791508plr.9.1556347409586;
        Fri, 26 Apr 2019 23:43:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347409; cv=none;
        d=google.com; s=arc-20160816;
        b=RHtlZ8OLT2dPiym622/0aHhO+AK4D//Bw5bBPTyXQSStUro5rJk8rmT4VuhnTJ4DLP
         MIdDo+T3q4gbFmqx0OU3S6VrP8LRJ/en8I0rPI+sUacE6aJ1MIjtyMiPaMRgc1IkK3Gn
         57F5Aa2VXwTSztYGwTgz+UQwErVa05URHRgwWIS571TntvKhPLDX8qTpyg9/wNNc5RK8
         3Q3A0Z4ERePhEv777qbvu5veqn01owr4/plbA8pVulF/BQQW5TdrHSjtNlJptoYZLdqE
         0UpfZQH7GqCmrSSnkpSD/atZaW06ni2b7zH/PyjnLKsljRCy5dLYlPNHibiRydKECPJc
         Gh7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=71dbHy9m/CIhCtlniLjnIfT11ydtbrFJWfPgh/aDBts=;
        b=k4BLapIC+GqP8NKUYY90CLUg1gzH2vWFy+onjq71ZCqi3HBVEx04JBPrPRaYpQGz/f
         PYQ9OArydjvd3573BCuqDzoAzA9ce6DWlcJMwiHMXc9KDnCNfltGinEtBlJcYs7TA6A4
         lfcEYu/R5lVKE3Vjp0c2ab341YH+kgka6uSYb5zbTbRvumwcjb5M9LFzBNMWOCqY5bcj
         VVYzm0o/6c8cLKLLR3n838tCrB0texd0qN4gK+mT21DdeR9OV+N8fmEpY4Lw14Rg2WT+
         cH77L7l6TUhVGaYuVgqft6tBPNXa7Pyli7QVahxiZ/DDjBZVfFWHqCxB+aE/64Yoq8vU
         aluw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qvNLDfV5;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor30460757pfj.3.2019.04.26.23.43.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qvNLDfV5;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=71dbHy9m/CIhCtlniLjnIfT11ydtbrFJWfPgh/aDBts=;
        b=qvNLDfV5t6OCXjpXqE2h8qCP9bZ/sJ406eIEMibouYzKfppgqnMlAuCIygJ2OFcd9+
         MMTkVSXzO0aOctNe/CiP8Zw9kIpjzutOKkzuNHcJG3fCAdytpDd18QMDAb6Knim/ohRs
         tBDO6V0x85WHUL2w71XgQxWYSTrcZtRKjF0HFFS4Dzn7r6bnhd8gs0bFJ2ayDhn0qXIt
         XGqaYfEBSbyjlozxlv7tlJsqu8eyvkVV9qOY42YDUV4gMlVY70x2mouNblsQZ7uqnSpE
         5UOlPM0wci38r9uZAhlJb4I1NObgCcrLUdbvFFf4CBRT8+QPP08ffFZ0CF9w8nTK5/X2
         J8hg==
X-Google-Smtp-Source: APXvYqyURRPLLrg0ynk67t/jHVJBTNh21u6U/GXsGcvBn1nAU+eeDbHBRYN9HLkqe6vwNFju/6m6NQ==
X-Received: by 2002:a65:500d:: with SMTP id f13mr8345688pgo.250.1556347409072;
        Fri, 26 Apr 2019 23:43:29 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:28 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
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
Subject: [PATCH v6 17/24] vmalloc: Add flag for free of special permsissions
Date: Fri, 26 Apr 2019 16:22:56 -0700
Message-Id: <20190426232303.28381-18-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

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
 include/linux/vmalloc.h |  15 ++++++
 mm/vmalloc.c            | 113 +++++++++++++++++++++++++++++++++-------
 2 files changed, 109 insertions(+), 19 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..c6eebb839552 100644
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
@@ -142,6 +147,13 @@ extern int map_kernel_range_noflush(unsigned long start, unsigned long size,
 				    pgprot_t prot, struct page **pages);
 extern void unmap_kernel_range_noflush(unsigned long addr, unsigned long size);
 extern void unmap_kernel_range(unsigned long addr, unsigned long size);
+static inline void set_vm_flush_reset_perms(void *addr)
+{
+	struct vm_struct *vm = find_vm_area(addr);
+
+	if (vm)
+		vm->flags |= VM_FLUSH_RESET_PERMS;
+}
 #else
 static inline int
 map_kernel_range_noflush(unsigned long start, unsigned long size,
@@ -157,6 +169,9 @@ static inline void
 unmap_kernel_range(unsigned long addr, unsigned long size)
 {
 }
+static inline void set_vm_flush_reset_perms(void *addr)
+{
+}
 #endif
 
 /* Allocate/destroy a 'vmalloc' VM area. */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e86ba6e74b50..e5e9e1fcac01 100644
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
@@ -1059,24 +1060,9 @@ static void vb_free(const void *addr, unsigned long size)
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
@@ -1113,6 +1099,27 @@ void vm_unmap_aliases(void)
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
@@ -1505,6 +1512,72 @@ struct vm_struct *remove_vm_area(const void *addr)
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
@@ -1526,7 +1599,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	vm_remove_mappings(area, deallocate_pages);
+
 	if (deallocate_pages) {
 		int i;
 
@@ -1961,8 +2035,9 @@ EXPORT_SYMBOL(vzalloc_node);
  */
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

