Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E20D46B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 19:42:38 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 4so43927056pfd.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 16:42:38 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id u7si9115173pfa.128.2016.03.04.16.42.38
        for <linux-mm@kvack.org>;
        Fri, 04 Mar 2016 16:42:38 -0800 (PST)
Subject: [PATCH] mm: ZONE_DEVICE depends on SPARSEMEM_VMEMMAP
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 04 Mar 2016 16:42:14 -0800
Message-ID: <20160305004214.12356.32017.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

The primary use case for devm_memremap_pages() is to allocate an
memmap array from persistent memory.  That capabilty requires
vmem_altmap which requires SPARSEMEM_VMEMMAP.

Also, without SPARSEMEM_VMEMMAP the addition of ZONE_DEVICE expands
ZONES_WIDTH and triggers the:

"Unfortunate NUMA and NUMA Balancing config, growing page-frame for
last_cpupid."

...warning in mm/memory.c.  SPARSEMEM_VMEMMAP=n && ZONE_DEVICE=y is not
a configuration we should worry about supporting.

Reported-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 664fa2416909..b95322ba542b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -654,6 +654,7 @@ config ZONE_DEVICE
 	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
+	depends on SPARSEMEM_VMEMMAP
 	depends on X86_64 #arch_add_memory() comprehends device memory
 
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
