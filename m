Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 7F64E6B0005
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 11:18:42 -0500 (EST)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 2/2] arm: Set the page table freeing ceiling to TASK_SIZE
Date: Mon, 18 Feb 2013 16:18:31 +0000
Message-Id: <1361204311-14127-3-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1361204311-14127-1-git-send-email-catalin.marinas@arm.com>
References: <1361204311-14127-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

ARM processors with LPAE enabled use 3 levels of page tables, with an
entry in the top level (pgd) covering 1GB of virtual space. Because of
the branch relocation limitations on ARM, the loadable modules are
mapped 16MB below PAGE_OFFSET, making the corresponding 1GB pgd shared
between kernel modules and user space.

If free_pgtables() is called with the default ceiling 0,
free_pgd_range() (and subsequently called functions) also frees the page
table shared between user space and kernel modules (which is normally
handled by the ARM-specific pgd_free() function). This patch changes
defines the ARM USER_PGTABLES_CEILING to TASK_SIZE.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/arm/include/asm/pgtable.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index c094749..8f06ee5 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -61,6 +61,13 @@ extern void __pgd_error(const char *file, int line, pgd_t);
 #define FIRST_USER_ADDRESS	PAGE_SIZE
 
 /*
+ * Use TASK_SIZE as the ceiling argument for free_pgtables() and
+ * free_pgd_range() to avoid freeing the modules pmd when LPAE is enabled (pmd
+ * page shared between user and kernel).
+ */
+#define USER_PGTABLES_CEILING	TASK_SIZE
+
+/*
  * The pgprot_* and protection_map entries will be fixed up in runtime
  * to include the cachable and bufferable bits based on memory policy,
  * as well as any architecture dependent bits like global/ASID and SMP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
