Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 949976B06C6
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 17:25:11 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id t78so24170821ita.14
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 14:25:11 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m81si10628118ioa.188.2017.08.03.14.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 14:25:03 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v5 12/15] mm: explicitly zero pagetable memory
Date: Thu,  3 Aug 2017 17:23:50 -0400
Message-Id: <1501795433-982645-13-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com>
References: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org

Soon vmemmap_alloc_block() will no longer zero the block, so zero memory
at its call sites for everything except struct pages.  Struct page memory
is zero'd by struct page initialization.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 mm/sparse-vmemmap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index c50b1a14d55e..d40c721ab19f 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -191,6 +191,7 @@ pmd_t * __meminit vmemmap_pmd_populate(pud_t *pud, unsigned long addr, int node)
 		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
+		memset(p, 0, PAGE_SIZE);
 		pmd_populate_kernel(&init_mm, pmd, p);
 	}
 	return pmd;
@@ -203,6 +204,7 @@ pud_t * __meminit vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node)
 		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
+		memset(p, 0, PAGE_SIZE);
 		pud_populate(&init_mm, pud, p);
 	}
 	return pud;
@@ -215,6 +217,7 @@ p4d_t * __meminit vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node)
 		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
+		memset(p, 0, PAGE_SIZE);
 		p4d_populate(&init_mm, p4d, p);
 	}
 	return p4d;
@@ -227,6 +230,7 @@ pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node)
 		void *p = vmemmap_alloc_block(PAGE_SIZE, node);
 		if (!p)
 			return NULL;
+		memset(p, 0, PAGE_SIZE);
 		pgd_populate(&init_mm, pgd, p);
 	}
 	return pgd;
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
