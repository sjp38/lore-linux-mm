Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 057746B4682
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 19:34:08 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id u20so13239699pfa.1
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:34:08 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id s5si5346864pfi.134.2018.11.27.16.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 16:34:07 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Date: Tue, 27 Nov 2018 16:07:53 -0800
Message-Id: <20181128000754.18056-2-rick.p.edgecombe@intel.com>
In-Reply-To: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com
Cc: kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Since vfree will lazily flush the TLB, but not lazily free the underlying pages,
it often leaves stale TLB entries to freed pages that could get re-used. This is
undesirable for cases where the memory being freed has special permissions such
as executable.

Having callers flush the TLB after calling vfree still leaves a window where
the pages are freed, but the TLB entry remains. Also the entire operation can be
deferred if the vfree is called from an interrupt and so a TLB flush after
calling vfree would miss the entire operation. So in order to support this use
case, a new flag VM_IMMEDIATE_UNMAP is added, that will cause the free operation
to take place like this:
        1. Unmap
        2. Flush TLB/Unmap aliases
        3. Free pages
In the deferred case these steps are all done by the work queue.

This implementation derives from two sketches from Dave Hansen and
Andy Lutomirski.

Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Suggested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |  1 +
 mm/vmalloc.c            | 13 +++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..cca6b6b83cf0 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,6 +21,7 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+#define VM_IMMEDIATE_UNMAP	0x00000200	/* flush before releasing pages */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 97d4b25d0373..68766651b5a7 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1516,6 +1516,14 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
 	remove_vm_area(addr);
+
+	/*
+	 * Need to flush the TLB before freeing pages in the case of this flag.
+	 * As long as that's happening, unmap aliases.
+	 */
+	if (area->flags & VM_IMMEDIATE_UNMAP)
+		vm_unmap_aliases();
+
 	if (deallocate_pages) {
 		int i;
 
@@ -1925,8 +1933,9 @@ EXPORT_SYMBOL(vzalloc_node);
 
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
-			      NUMA_NO_NODE, __builtin_return_address(0));
+	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
+			GFP_KERNEL, PAGE_KERNEL_EXEC, VM_IMMEDIATE_UNMAP,
+			NUMA_NO_NODE, __builtin_return_address(0));
 }
 
 #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
-- 
2.17.1
