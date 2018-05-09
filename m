Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D79086B0569
	for <linux-mm@kvack.org>; Wed,  9 May 2018 15:18:48 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y124so6931552qkc.8
        for <linux-mm@kvack.org>; Wed, 09 May 2018 12:18:48 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g10-v6si658769qvj.17.2018.05.09.12.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 12:18:47 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH] mm: allow deferred page init for vmemmap only
Date: Wed,  9 May 2018 15:17:13 -0400
Message-Id: <20180509191713.23794-1-pasha.tatashin@oracle.com>
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

Since FLATMEM is already disallowed for deferred struct pages, it makes
sense to allow deferred struct pages only on systems with
SPARSEMEM_VMEMMAP.

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
