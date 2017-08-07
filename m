Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 70A8B6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 16:39:45 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k126so6749475qke.8
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 13:39:45 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z13si8125102qtg.278.2017.08.07.13.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 13:39:44 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v6 12/15] mm: explicitly zero pagetable memory
Date: Mon,  7 Aug 2017 16:38:46 -0400
Message-Id: <1502138329-123460-13-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

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
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
