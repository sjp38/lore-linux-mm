Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A71B6B05F5
	for <linux-mm@kvack.org>; Thu, 10 May 2018 07:54:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a9-v6so726910pgt.6
        for <linux-mm@kvack.org>; Thu, 10 May 2018 04:54:35 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x12-v6si543343pgv.556.2018.05.10.04.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 04:54:33 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2] mm: allow deferred page init for vmemmap only
Date: Thu, 10 May 2018 07:53:56 -0400
Message-Id: <20180510115356.31164-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mhocko@suse.com, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, rostedt@goodmis.org, fengguang.wu@intel.com, dennisszhou@gmail.com

It is unsafe to do virtual to physical translations before mm_init() is
called if struct page is needed in order to determine the memory section
number (see SECTION_IN_PAGE_FLAGS). This is because only in mm_init() we
initialize struct pages for all the allocated memory when deferred struct
pages are used.

My recent fix exposed this problem, because it greatly reduced number of
pages that are initialized before mm_init(), but the problem existed even
before my fix, as Fengguang Wu found.

Below is a more detailed explanation of the problem.

We initialize struct pages in four places:

1. Early in boot a small set of struct pages is initialized to fill
the first section, and lower zones.
2. During mm_init() we initialize "struct pages" for all the memory
that is allocated, i.e reserved in memblock.
3. Using on-demand logic when pages are allocated after mm_init call (when
memblock is finished)
4. After smp_init() when the rest free deferred pages are initialized.

The problem occurs if we try to do va to phys translation of a memory
between steps 1 and 2. Because we have not yet initialized struct pages for
all the reserved pages, it is inherently unsafe to do va to phys if the
translation itself requires access of "struct page" as in case of this
combination: CONFIG_SPARSE && !CONFIG_SPARSE_VMEMMAP

Here is a sample path, where translation is required, that occurs before
mm_init():

start_kernel()
 trap_init()
  setup_cpu_entry_areas()
   setup_cpu_entry_area(cpu)
    get_cpu_gdt_paddr(cpu)
     per_cpu_ptr_to_phys(addr)
      pcpu_addr_to_page(addr)
       virt_to_page(addr)
        pfn_to_page(__pa(addr) >> PAGE_SHIFT)

The problems are discussed in these threads:
http://lkml.kernel.org/r/20180418135300.inazvpxjxowogyge@wfg-t540p.sh.intel.com
http://lkml.kernel.org/r/20180419013128.iurzouiqxvcnpbvz@wfg-t540p.sh.intel.com
http://lkml.kernel.org/r/20180426202619.2768-1-pasha.tatashin@oracle.com

Fixes: 3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index d5004d82a1d6..1cd32d67ca30 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -635,7 +635,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 	bool "Defer initialisation of struct pages to kthreads"
 	default n
 	depends on NO_BOOTMEM
-	depends on !FLATMEM
+	depends on SPARSEMEM_VMEMMAP
 	help
 	  Ordinarily all struct pages are initialised during early boot in a
 	  single thread. On very large machines this can take a considerable
-- 
2.17.0
