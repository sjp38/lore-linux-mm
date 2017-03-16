Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DFDEC6B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:27:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g2so96791229pge.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:27:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m188si4004009pfc.145.2017.03.16.08.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:27:41 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/7] mm/gup: Make pages referenced during generic get_user_pages_fast()
Date: Thu, 16 Mar 2017 18:26:52 +0300
Message-Id: <20170316152655.37789-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
References: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>

This is preparation patch for transition of x86 to generic GUP_fast()
implementation.

Unlike generic GUP_fast(), x86 version makes all pages it touches
referenced. It seems required for GRU and EPT.

See commit 8ee53820edfd ("thp: mmu_notifier_test_young").

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/gup.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index ed2259dc4606..f0cfe225c08f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1238,6 +1238,8 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		}
 
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+
+		SetPageReferenced(page);
 		pages[*nr] = page;
 		(*nr)++;
 
@@ -1299,6 +1301,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		return 0;
 	}
 
+	SetPageReferenced(head);
 	return 1;
 }
 
@@ -1334,6 +1337,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		return 0;
 	}
 
+	SetPageReferenced(head);
 	return 1;
 }
 
@@ -1370,6 +1374,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 		return 0;
 	}
 
+	SetPageReferenced(head);
 	return 1;
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
