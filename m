Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id C463B6B0075
	for <linux-mm@kvack.org>; Mon,  4 May 2015 02:19:31 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so139818463wgy.2
        for <linux-mm@kvack.org>; Sun, 03 May 2015 23:19:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2si9933871wiz.73.2015.05.03.23.19.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 03 May 2015 23:19:13 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 08/15] xen: find unused contiguous memory area
Date: Mon,  4 May 2015 08:18:59 +0200
Message-Id: <1430720346-21063-9-git-send-email-jgross@suse.com>
In-Reply-To: <1430720346-21063-1-git-send-email-jgross@suse.com>
References: <1430720346-21063-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>

For being able to relocate pre-allocated data areas like initrd or
p2m list it is mandatory to find a contiguous memory area which is
not yet in use and doesn't conflict with the memory map we want to
be in effect.

In case such an area is found reserve it at once as this will be
required to be done in any case.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c   | 34 ++++++++++++++++++++++++++++++++++
 arch/x86/xen/xen-ops.h |  1 +
 2 files changed, 35 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 99ef82c..973d294 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -597,6 +597,40 @@ bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size)
 }
 
 /*
+ * Find a free area in physical memory not yet reserved and compliant with
+ * E820 map.
+ * Used to relocate pre-allocated areas like initrd or p2m list which are in
+ * conflict with the to be used E820 map.
+ * In case no area is found, return 0. Otherwise return the physical address
+ * of the area which is already reserved for convenience.
+ */
+phys_addr_t __init xen_find_free_area(phys_addr_t size)
+{
+	unsigned mapcnt;
+	phys_addr_t addr, start;
+	struct e820entry *entry = xen_e820_map;
+
+	for (mapcnt = 0; mapcnt < xen_e820_map_entries; mapcnt++, entry++) {
+		if (entry->type != E820_RAM || entry->size < size)
+			continue;
+		start = entry->addr;
+		for (addr = start; addr < start + size; addr += PAGE_SIZE) {
+			if (!memblock_is_reserved(addr))
+				continue;
+			start = addr + PAGE_SIZE;
+			if (start + size > entry->addr + entry->size)
+				break;
+		}
+		if (addr >= start + size) {
+			memblock_reserve(start, size);
+			return start;
+		}
+	}
+
+	return 0;
+}
+
+/*
  * Reserve Xen mfn_list.
  * See comment above "struct start_info" in <xen/interface/xen.h>
  * We tried to make the the memblock_reserve more selective so
diff --git a/arch/x86/xen/xen-ops.h b/arch/x86/xen/xen-ops.h
index c1385b8..3f1669c 100644
--- a/arch/x86/xen/xen-ops.h
+++ b/arch/x86/xen/xen-ops.h
@@ -43,6 +43,7 @@ bool __init xen_is_e820_reserved(phys_addr_t start, phys_addr_t size);
 unsigned long __ref xen_chk_extra_mem(unsigned long pfn);
 void __init xen_inv_extra_mem(void);
 void __init xen_remap_memory(void);
+phys_addr_t __init xen_find_free_area(phys_addr_t size);
 char * __init xen_memory_setup(void);
 char * xen_auto_xlated_memory_setup(void);
 void __init xen_arch_setup(void);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
