Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66A886B02F2
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 05:26:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 70so81879517ita.22
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 02:26:14 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c80si7390850ioj.1.2017.04.25.02.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 02:26:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86/mm/64: Fix crash in remove_pagetable()
Date: Tue, 25 Apr 2017 12:25:57 +0300
Message-Id: <20170425092557.21852-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

remove_pagetable() does page walk using p*d_page_vaddr() plus cast.
It's not canonical approach -- we usually use p*d_offset() for that.

It works fine as long as all page table levels are present. We broke the
invariant by introducing folded p4d page table level.

As result, remove_pagetable() interprets PMD as PUD and it leads to
crash:

	BUG: unable to handle kernel paging request at ffff880300000000
	IP: memchr_inv+0x60/0x110
	PGD 317d067
	P4D 317d067
	PUD 3180067
	PMD 33f102067
	PTE 8000000300000060

Let's fix this by using p*d_offset() instead of p*d_page_vaddr() for
page walk.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Dan Williams <dan.j.williams@intel.com>
Fixes: f2a6a7050109 ("x86: Convert the rest of the code to support p4d_t")
---
 arch/x86/mm/init_64.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a242139df8fe..745e5e183169 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -962,7 +962,7 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 			continue;
 		}
 
-		pmd_base = (pmd_t *)pud_page_vaddr(*pud);
+		pmd_base = pmd_offset(pud, 0);
 		remove_pmd_table(pmd_base, addr, next, direct);
 		free_pmd_table(pmd_base, pud);
 	}
@@ -988,7 +988,7 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 
 		BUILD_BUG_ON(p4d_large(*p4d));
 
-		pud_base = (pud_t *)p4d_page_vaddr(*p4d);
+		pud_base = pud_offset(p4d, 0);
 		remove_pud_table(pud_base, addr, next, direct);
 		free_pud_table(pud_base, p4d);
 	}
@@ -1013,7 +1013,7 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 		if (!pgd_present(*pgd))
 			continue;
 
-		p4d = (p4d_t *)pgd_page_vaddr(*pgd);
+		p4d = p4d_offset(pgd, 0);
 		remove_p4d_table(p4d, addr, next, direct);
 	}
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
