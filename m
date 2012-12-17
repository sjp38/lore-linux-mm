Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 76EED6B0083
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:16:19 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/2] Revert "x86, mm: Make spurious_fault check explicitly check the PRESENT bit"
Date: Mon, 17 Dec 2012 19:00:23 +0100
Message-Id: <1355767224-13298-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
References: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

This reverts commit 660a293ea9be709b893d371fbc0328fcca33c33a.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/mm/fault.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 8e13ecb..4d18eb5 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -944,14 +944,8 @@ spurious_fault(unsigned long error_code, unsigned long address)
 	if (pmd_large(*pmd))
 		return spurious_fault_check(error_code, (pte_t *) pmd);
 
-	/*
-	 * Note: don't use pte_present() here, since it returns true
-	 * if the _PAGE_PROTNONE bit is set.  However, this aliases the
-	 * _PAGE_GLOBAL bit, which for kernel pages give false positives
-	 * when CONFIG_DEBUG_PAGEALLOC is used.
-	 */
 	pte = pte_offset_kernel(pmd, address);
-	if (!(pte_flags(*pte) & _PAGE_PRESENT))
+	if (!pte_present(*pte))
 		return 0;
 
 	ret = spurious_fault_check(error_code, pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
