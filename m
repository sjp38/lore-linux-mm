Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7286B0388
	for <linux-mm@kvack.org>; Sat, 25 Feb 2017 12:13:45 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t184so96263201pgt.1
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 09:13:45 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b1si10572869pfa.254.2017.02.25.09.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Feb 2017 09:13:44 -0800 (PST)
Subject: [PATCH 1/2] x86, mm: fix gup_pte_range() vs DAX mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 25 Feb 2017 09:08:33 -0800
Message-ID: <148804251312.36605.12665024794196605053.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148804250784.36605.12832323062093584440.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: x86@kernel.org, Xiong Zhou <xzhou@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, torvalds@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>

gup_pte_range() fails to check pte_allows_gup() before translating a DAX
pte entry, pte_devmap(), to a page. This allows writes to read-only
mappings, and bypasses the DAX cacheline dirty tracking due to missed
'mkwrite' faults. The gup_huge_pmd() path and the gup_huge_pud() path
correctly check pte_allows_gup() before checking for _devmap() entries.

Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
Cc: <x86@kernel.org>
Cc: <stable@vger.kernel.org>
Cc: Xiong Zhou <xzhou@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Reported-by: Dave Hansen <dave.hansen@linux.intel.com>
Reported-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/gup.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 0d4fb3ebbbac..1680768d392c 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -120,6 +120,11 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 			return 0;
 		}
 
+		if (!pte_allows_gup(pte_val(pte), write)) {
+			pte_unmap(ptep);
+			return 0;
+		}
+
 		if (pte_devmap(pte)) {
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
@@ -127,8 +132,7 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 				pte_unmap(ptep);
 				return 0;
 			}
-		} else if (!pte_allows_gup(pte_val(pte), write) ||
-			   pte_special(pte)) {
+		} else if (pte_special(pte)) {
 			pte_unmap(ptep);
 			return 0;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
