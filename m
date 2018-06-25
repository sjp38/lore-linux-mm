Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF396B026D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 13:15:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w9-v6so9703417wrl.13
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:15:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q77-v6sor2609549wmd.57.2018.06.25.10.15.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 10:15:24 -0700 (PDT)
From: Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v2] mm/memblock: add missing include <linux/bootmem.h>
Date: Mon, 25 Jun 2018 19:15:12 +0200
Message-Id: <20180625171513.31845-1-malat@debian.org>
In-Reply-To: <20180622210542.2025-1-malat@debian.org>
References: <20180622210542.2025-1-malat@debian.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Michal Hocko <mhocko@kernel.org>, Mathieu Malaterre <malat@debian.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Stefan Agner <stefan@agner.ch>, Joe Perches <joe@perches.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

It also adds #ifdef blockers to prevent compilation failure on mips/ia64
where CONFIG_NO_BOOTMEM=n. Because Makefile already does:

  obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o

The #ifdef has been simplified from:

  #if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)

to simply:

  #if defined(CONFIG_NO_BOOTMEM)

Suggested-by: Tony Luck <tony.luck@intel.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Mathieu Malaterre <malat@debian.org>
---
v2: Simplify #ifdef

 mm/memblock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index 03d48d8835ba..611a970ac902 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,6 +20,7 @@
 #include <linux/kmemleak.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
+#include <linux/bootmem.h>
 
 #include <asm/sections.h>
 #include <linux/io.h>
@@ -1224,6 +1225,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
+#if defined(CONFIG_NO_BOOTMEM)
 /**
  * memblock_virt_alloc_internal - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
@@ -1431,6 +1433,7 @@ void * __init memblock_virt_alloc_try_nid(
 	      (u64)max_addr);
 	return NULL;
 }
+#endif
 
 /**
  * __memblock_free_early - free boot memory block
-- 
2.11.0
