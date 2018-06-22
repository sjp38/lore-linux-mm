Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB2456B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 17:06:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p9-v6so5075444wrm.22
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 14:06:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10-v6sor4351296wri.22.2018.06.22.14.06.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 14:06:01 -0700 (PDT)
From: Mathieu Malaterre <malat@debian.org>
Subject: [PATCH] mm/memblock: add missing include <linux/bootmem.h> and #ifdef
Date: Fri, 22 Jun 2018 23:05:41 +0200
Message-Id: <20180622210542.2025-1-malat@debian.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Stefan Agner <stefan@agner.ch>, Joe Perches <joe@perches.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 26f09e9b3a06 ("mm/memblock: add memblock memory allocation apis")
introduced two new function definitions:

  memblock_virt_alloc_try_nid_nopanic()
  memblock_virt_alloc_try_nid()

Commit ea1f5f3712af ("mm: define memblock_virt_alloc_try_nid_raw")
introduced the following function definition:

  memblock_virt_alloc_try_nid_raw()

This commit adds an include of header file <linux/bootmem.h> to provide
the missing function prototypes. Silence the following gcc warning
(W=1):

  mm/memblock.c:1334:15: warning: no previous prototype for `memblock_virt_alloc_try_nid_raw' [-Wmissing-prototypes]
  mm/memblock.c:1371:15: warning: no previous prototype for `memblock_virt_alloc_try_nid_nopanic' [-Wmissing-prototypes]
  mm/memblock.c:1407:15: warning: no previous prototype for `memblock_virt_alloc_try_nid' [-Wmissing-prototypes]

As seen in commit 6cc22dc08a24 ("revert "mm/memblock: add missing include
<linux/bootmem.h>"") #ifdef blockers were missing which lead to compilation
failure on mips/ia64 where CONFIG_NO_BOOTMEM=n.

Suggested-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Mathieu Malaterre <malat@debian.org>
---
 mm/memblock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index 4c98672bc3e2..f4b6766d7907 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,6 +20,7 @@
 #include <linux/kmemleak.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
+#include <linux/bootmem.h>
 
 #include <asm/sections.h>
 #include <linux/io.h>
@@ -1226,6 +1227,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
+#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
 /**
  * memblock_virt_alloc_internal - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
@@ -1433,6 +1435,7 @@ void * __init memblock_virt_alloc_try_nid(
 	      (u64)max_addr);
 	return NULL;
 }
+#endif
 
 /**
  * __memblock_free_early - free boot memory block
-- 
2.11.0
