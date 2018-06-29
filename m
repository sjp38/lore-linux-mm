Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1466B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:35:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l17-v6so2224487edq.11
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 06:35:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u18-v6si3518821edm.16.2018.06.29.06.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 06:35:21 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5TDXxFV010802
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:35:19 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jwmymt84h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:35:19 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 29 Jun 2018 14:35:17 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] mm: make DEFERRED_STRUCT_PAGE_INIT explicitly depend on SPARSEMEM
Date: Fri, 29 Jun 2018 16:35:08 +0300
Message-Id: <1530279308-24988-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The deferred memory initialization relies on section definitions, e.g
PAGES_PER_SECTION, that are only available when CONFIG_SPARSEMEM=y on most
architectures.

Initially DEFERRED_STRUCT_PAGE_INIT depended on explicit
ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT configuration option, but since the
commit 2e3ca40f03bb13709df4 ("mm: relax deferred struct page requirements")
this requirement was relaxed and now it is possible to enable
DEFERRED_STRUCT_PAGE_INIT on architectures that support DISCONTINGMEM and
NO_BOOTMEM which causes build failures.

For instance, setting SMP=y and DEFERRED_STRUCT_PAGE_INIT=y on arc causes
the following build failure:

  CC      mm/page_alloc.o
mm/page_alloc.c: In function 'update_defer_init':
mm/page_alloc.c:321:14: error: 'PAGES_PER_SECTION'
undeclared (first use in this function); did you mean 'USEC_PER_SEC'?
      (pfn & (PAGES_PER_SECTION - 1)) == 0) {
              ^~~~~~~~~~~~~~~~~
              USEC_PER_SEC
mm/page_alloc.c:321:14: note: each undeclared
identifier is reported only once for each function it appears in
In file included from include/linux/cache.h:5:0,
                 from include/linux/printk.h:9,
                 from include/linux/kernel.h:14,
                 from
include/asm-generic/bug.h:18,
                 from
arch/arc/include/asm/bug.h:32,
                 from include/linux/bug.h:5,
                 from include/linux/mmdebug.h:5,
                 from include/linux/mm.h:9,
                 from mm/page_alloc.c:18:
mm/page_alloc.c: In function 'deferred_grow_zone':
mm/page_alloc.c:1624:52: error:
'PAGES_PER_SECTION' undeclared (first use in this function); did you mean
'USEC_PER_SEC'?
  unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
                                                    ^
include/uapi/linux/kernel.h:11:47: note: in
definition of macro '__ALIGN_KERNEL_MASK'
 #define __ALIGN_KERNEL_MASK(x, mask) (((x) + (mask)) & ~(mask))
                                               ^~~~
include/linux/kernel.h:58:22: note: in expansion
of macro '__ALIGN_KERNEL'
 #define ALIGN(x, a)  __ALIGN_KERNEL((x), (a))
                      ^~~~~~~~~~~~~~
mm/page_alloc.c:1624:34: note: in expansion of
macro 'ALIGN'
  unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
                                  ^~~~~
In file included from
include/asm-generic/bug.h:18:0,
                 from
arch/arc/include/asm/bug.h:32,
                 from include/linux/bug.h:5,
                 from include/linux/mmdebug.h:5,
                 from include/linux/mm.h:9,
                 from mm/page_alloc.c:18:
mm/page_alloc.c: In function
'free_area_init_node':
mm/page_alloc.c:6379:50: error:
'PAGES_PER_SECTION' undeclared (first use in this function); did you mean
'USEC_PER_SEC'?
  pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
                                                  ^
include/linux/kernel.h:812:22: note: in definition
of macro '__typecheck'
   (!!(sizeof((typeof(x) *)1 == (typeof(y) *)1)))
                      ^
include/linux/kernel.h:836:24: note: in expansion
of macro '__safe_cmp'
  __builtin_choose_expr(__safe_cmp(x, y), \
                        ^~~~~~~~~~
include/linux/kernel.h:904:27: note: in expansion
of macro '__careful_cmp'
 #define min_t(type, x, y) __careful_cmp((type)(x), (type)(y), <)
                           ^~~~~~~~~~~~~
mm/page_alloc.c:6379:29: note: in expansion of
macro 'min_t'
  pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
                             ^~~~~
include/linux/kernel.h:836:2: error: first
argument to '__builtin_choose_expr' not a constant
  __builtin_choose_expr(__safe_cmp(x, y), \
  ^
include/linux/kernel.h:904:27: note: in expansion
of macro '__careful_cmp'
 #define min_t(type, x, y) __careful_cmp((type)(x), (type)(y), <)
                           ^~~~~~~~~~~~~
mm/page_alloc.c:6379:29: note: in expansion of
macro 'min_t'
  pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
                             ^~~~~
scripts/Makefile.build:317: recipe for target
'mm/page_alloc.o' failed

Let's make the DEFERRED_STRUCT_PAGE_INIT explicitly depend on SPARSEMEM as
the systems that support DISCONTIGMEM do not seem to have that huge
amounts of memory that would make DEFERRED_STRUCT_PAGE_INIT relevant.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index ce95491..94af022 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -635,7 +635,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 	bool "Defer initialisation of struct pages to kthreads"
 	default n
 	depends on NO_BOOTMEM
-	depends on !FLATMEM
+	depends on SPARSEMEM
 	depends on !NEED_PER_CPU_KM
 	help
 	  Ordinarily all struct pages are initialised during early boot in a
-- 
2.7.4
