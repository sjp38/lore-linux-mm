Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9C26B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:20:32 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 79so15380861pgf.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:20:32 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a1si3882383pgn.162.2017.03.24.12.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:20:31 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v2 5/5] mm: teach platforms not to zero struct pages memory
Date: Fri, 24 Mar 2017 15:19:52 -0400
Message-Id: <1490383192-981017-6-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1490383192-981017-1-git-send-email-pasha.tatashin@oracle.com>
References: <1490383192-981017-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org

If we are using deferred struct page initialization feature, most of
"struct page"es are getting initialized after other CPUs are started, and
hence we are benefiting from doing this job in parallel. However, we are
still zeroing all the memory that is allocated for "struct pages" using the
boot CPU.  This patch solves this problem, by deferring zeroing "struct
pages" to only when they are initialized.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 arch/powerpc/mm/init_64.c |    2 +-
 arch/s390/mm/vmem.c       |    2 +-
 arch/sparc/mm/init_64.c   |    2 +-
 arch/x86/mm/init_64.c     |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index eb4c270..24faf2d 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -181,7 +181,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 		if (vmemmap_populated(start, page_size))
 			continue;
 
-		p = vmemmap_alloc_block(page_size, node, true);
+		p = vmemmap_alloc_block(page_size, node, VMEMMAP_ZERO);
 		if (!p)
 			return -ENOMEM;
 
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 9c75214..ffe9ba1 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -252,7 +252,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 				void *new_page;
 
 				new_page = vmemmap_alloc_block(PMD_SIZE, node,
-							       true);
+							       VMEMMAP_ZERO);
 				if (!new_page)
 					goto out;
 				pmd_val(*pm_dir) = __pa(new_page) | sgt_prot;
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index d91e462..280834e 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2542,7 +2542,7 @@ int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
 		pte = pmd_val(*pmd);
 		if (!(pte & _PAGE_VALID)) {
 			void *block = vmemmap_alloc_block(PMD_SIZE, node,
-							  true);
+							  VMEMMAP_ZERO);
 
 			if (!block)
 				return -ENOMEM;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 46101b6..9d8c72c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1177,7 +1177,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 			void *p;
 
 			p = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap,
-						      true);
+						      VMEMMAP_ZERO);
 			if (p) {
 				pte_t entry;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
