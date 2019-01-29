Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9B29C282CF
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 633202177E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 633202177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 025878E0012; Mon, 28 Jan 2019 19:41:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1A9E8E0008; Mon, 28 Jan 2019 19:41:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E061B8E0012; Mon, 28 Jan 2019 19:41:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A29B88E0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:41:06 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p15so15387112pfk.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:41:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=5ojdOxUYVtZ95xBX5GOCrCT5kCgaS2LvmI/53rS/NiY=;
        b=hTYxLJu1Z2ps/0xuKlsM5CzjLQd3qJtO2WeyMjn/Nr+Pub4OfQTkW9b8Da2xZVlsFL
         eYQIMFEQpCN9Qf4B8cexauHtJpUuJSwm4SgPpsWOAA5tP85+IDlhcVvwHQo7QwdWogqn
         7f72DGK2YHSQE+Sa0vbtXgDCCDwlW+0616aVcVK3VAH864jxXXKWw6v2f2GSPLaASD03
         o6xz5zx5kLCDtstHg4Qi062sbCZhsDxTG9x1+BRbSJfUu3Lxl0hTnZAXvrqZmG/YoZVj
         LCoC9jvDbqOKhrXGk+scHTJxA3GD1hFcRFstKQtVekS47XoIXfQqLzhquiyDuPJniOpf
         JEkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdY2/QMfpSTvnsiL7YVmD7t5QIn9SZNOBticuY3BAPu127u4QNQ
	2f417m2dq2/u4l5lqAXDCwApnE4HuE/Duk0n8jnQvEJXz+QZGh718oS6z/ZW+GcLfukus80c5Ur
	H6WR8aGpAzfpdTdrKJLMZ5b+UH8zF3IG74fmOFzSJNZqcBRYIuzNSSZIfPReszWaN4w==
X-Received: by 2002:a62:3a04:: with SMTP id h4mr23852584pfa.119.1548722466300;
        Mon, 28 Jan 2019 16:41:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5/I3RVZXCSBx7qWx8Ok2zwGOIRFLCIgUGw4w+yVxKHm/8SSSoQ6stQhdz5bXxC8GgveTN8
X-Received: by 2002:a62:3a04:: with SMTP id h4mr23846787pfa.119.1548722353880;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=y9vDBT7ZN7MOXMEy2okpIxvz5Ctp6cW+F72q6e/qP/SungcEE28AcPBoTRQ8VwK4fV
         /H9KXeaNZVa18blLY1csdEa6gDkRDmFMawYj8Ywr2rFhAdY0GkPz1azcoOEH0qfZ9dsu
         jUYgX4o6OyOcUUXRy3vv3+LZDddp312rwbM2vINDCMSF3TzNLUPZtW3SEyJ8+/80otJK
         QJ6qBvQbWzXzNiQZiKc+SExOCvWGJUuYbTjPmREgbmjdzrjvb8gqLLVrHRdn/4VK1R7P
         J2W2JICzhQ+0UFqAhw0wdqd3yfW1fUH2BR5zlOAxlLB3bvqQdyGc4uSFZPxTRjv6b8nd
         Dfnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=5ojdOxUYVtZ95xBX5GOCrCT5kCgaS2LvmI/53rS/NiY=;
        b=BeWdUTKLfD5QQ7+xX1hmGafqN1fKWt4oMInI/rNnncEyzxUm1LluvsJOXdSH/rF6Yc
         KBlT3hSd5fxMY7BQlD7GqXrZfX18RogjO52H5U8ZocAFFZH0hJi/Q79d1PPWXB0Ddp+S
         v4JVys25WvqkDIsmXJ7sAHOiSzKt8aaTjWQiedmioCe6Lg/rxUIBb1rRMzu1pdU7oZr6
         8upN52+c7RIa/D68c+YeWNFnqt/ZOwHJj7GXCJmw0AMpWa61csrGLAGDnNduBztntqRE
         Fv6q3aR5Z6ccsf+iCQioLEAVlmGwRlUcinuMeqQIGrI+NnrlRAZX6Sskettwz5SH/AVQ
         afAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i9si7660357plb.35.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921929"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:12 -0800
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
Subject: [PATCH v2 15/20] vmalloc: New flags for safe vfree on special perms
Date: Mon, 28 Jan 2019 16:34:17 -0800
Message-Id: <20190129003422.9328-16-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This adds a new flags VM_HAS_SPECIAL_PERMS, for enabling vfree operations
to immediately clear executable TLB entries to freed pages, and handle
freeing memory with special permissions. It also takes care of resetting
the direct map permissions for the pages being unmapped. So this flag is
useful for any kind of memory with elevated permissions, or where there can
be related permissions changes on the directmap. Today this is RO+X and RO
memory.

Although this enables directly vfreeing RO memory now, RO memory cannot be
freed in an interrupt because the allocation itself is used as a node on
deferred free list. So when RO memory needs to be freed in an interrupt
the code doing the vfree needs to have its own work queue, as was the case
before the deferred vfree list handling was added. Today there is only one
case where this happens.

For architectures with set_alias_ implementations this whole operation
can be done with one TLB flush when centralized like this. For others with
directmap permissions, currently only arm64, a backup method using
set_memory functions is used to reset the directmap. When arm64 adds
set_alias_ functions, this backup can be removed.

When the TLB is flushed to both remove TLB entries for the vmalloc range
mapping and the direct map permissions, the lazy purge operation could be
done to try to save a TLB flush later. However today vm_unmap_aliases
could flush a TLB range that does not include the directmap. So a helper
is added with extra parameters that can allow both the vmalloc address and
the direct mapping to be flushed during this operation. The behavior of the
normal vm_unmap_aliases function is unchanged.

Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Suggested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |  13 +++++
 mm/vmalloc.c            | 122 +++++++++++++++++++++++++++++++++-------
 2 files changed, 116 insertions(+), 19 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..9f643f917360 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,6 +21,11 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+/*
+ * Memory with VM_HAS_SPECIAL_PERMS cannot be freed in an interrupt or with
+ * vfree_atomic.
+ */
+#define VM_HAS_SPECIAL_PERMS	0x00000200      /* Reset directmap and flush TLB on unmap */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -135,6 +140,14 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 extern struct vm_struct *remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
 
+static inline void set_vm_special(void *addr)
+{
+	struct vm_struct *vm = find_vm_area(addr);
+
+	if (vm)
+		vm->flags |= VM_HAS_SPECIAL_PERMS;
+}
+
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page **pages);
 #ifdef CONFIG_MMU
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 871e41c55e23..d459b5b9649b 100644
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
@@ -1055,24 +1056,11 @@ static void vb_free(const void *addr, unsigned long size)
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
+static void _vm_unmap_aliases(unsigned long start, unsigned long end,
+				int must_flush)
 {
-	unsigned long start = ULONG_MAX, end = 0;
 	int cpu;
-	int flush = 0;
+	int flush = must_flush;
 
 	if (unlikely(!vmap_initialized))
 		return;
@@ -1109,6 +1097,27 @@ void vm_unmap_aliases(void)
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
+	int must_flush = 0;
+
+	_vm_unmap_aliases(start, end, must_flush);
+}
 EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 
 /**
@@ -1494,6 +1503,79 @@ struct vm_struct *remove_vm_area(const void *addr)
 	return NULL;
 }
 
+static inline void set_area_alias(const struct vm_struct *area,
+			int (*set_alias)(struct page *page))
+{
+	int i;
+
+	for (i = 0; i < area->nr_pages; i++) {
+		unsigned long addr =
+			(unsigned long)page_address(area->pages[i]);
+
+		if (addr)
+			set_alias(area->pages[i]);
+	}
+}
+
+/* This handles removing and resetting vm mappings related to the vm_struct. */
+static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
+{
+	unsigned long addr = (unsigned long)area->addr;
+	unsigned long start = ULONG_MAX, end = 0;
+	int special = area->flags & VM_HAS_SPECIAL_PERMS;
+	int i;
+
+	/*
+	 * The below block can be removed when all architectures that have
+	 * direct map permissions also have set_alias_ implementations. This is
+	 * to do resetting on the directmap for any special permissions (today
+	 * only X), without leaving a RW+X window.
+	 */
+	if (special && !IS_ENABLED(CONFIG_ARCH_HAS_SET_ALIAS)) {
+		set_memory_nx(addr, area->nr_pages);
+		set_memory_rw(addr, area->nr_pages);
+	}
+
+	remove_vm_area(area->addr);
+
+	/* If this is not special memory, we can skip the below. */
+	if (!special)
+		return;
+
+	/*
+	 * If we are not deallocating pages, we can just do the flush of the VM
+	 * area and return.
+	 */
+	if (!deallocate_pages) {
+		vm_unmap_aliases();
+		return;
+	}
+
+	/*
+	 * If we are here, we need to flush the vm mapping and reset the direct
+	 * map.
+	 * First find the start and end range of the direct mappings to make
+	 * sure the vm_unmap_aliases flush includes the direct map.
+	 */
+	for (i = 0; i < area->nr_pages; i++) {
+		unsigned long addr =
+			(unsigned long)page_address(area->pages[i]);
+		if (addr) {
+			start = min(addr, start);
+			end = max(addr, end);
+		}
+	}
+
+	/*
+	 * First we set direct map to something not valid so that it won't be
+	 * cached if there are any accesses after the TLB flush, then we flush
+	 * the TLB, and reset the directmap permissions to the default.
+	 */
+	set_area_alias(area, set_alias_nv_noflush);
+	_vm_unmap_aliases(start, end, 1);
+	set_area_alias(area, set_alias_default_noflush);
+}
+
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
@@ -1515,7 +1597,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	vm_remove_mappings(area, deallocate_pages);
+
 	if (deallocate_pages) {
 		int i;
 
@@ -1925,8 +2008,9 @@ EXPORT_SYMBOL(vzalloc_node);
 
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
-			      NUMA_NO_NODE, __builtin_return_address(0));
+	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
+			GFP_KERNEL, PAGE_KERNEL_EXEC, VM_HAS_SPECIAL_PERMS,
+			NUMA_NO_NODE, __builtin_return_address(0));
 }
 
 #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
-- 
2.17.1

