Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BD2646B004D
	for <linux-mm@kvack.org>; Thu, 23 May 2013 13:08:22 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id l18so2176292wgh.13
        for <linux-mm@kvack.org>; Thu, 23 May 2013 10:08:21 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 07/11] ARM64: mm: Make PAGE_NONE pages read only and no-execute.
Date: Thu, 23 May 2013 18:07:54 +0100
Message-Id: <1369328878-11706-8-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org, Steve Capper <steve.capper@linaro.org>

If we consider the following code sequence:

	my_pte = pte_modify(entry, myprot);
	x = pte_write(my_pte);
	y = pte_exec(my_pte);

If myprot comes from a PROT_NONE page, then x and y will both be
true which is undesireable behaviour.

This patch sets the no-execute and read-only bits for PAGE_NONE
such that the code above will return false for both x and y.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm64/include/asm/pgtable.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index e333a24..77b09d6 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -66,7 +66,7 @@ extern pgprot_t pgprot_default;
 
 #define _MOD_PROT(p, b)		__pgprot_modify(p, 0, b)
 
-#define PAGE_NONE		__pgprot_modify(pgprot_default, PTE_TYPE_MASK, PTE_PROT_NONE)
+#define PAGE_NONE		__pgprot_modify(pgprot_default, PTE_TYPE_MASK, PTE_PROT_NONE | PTE_RDONLY | PTE_PXN | PTE_UXN)
 #define PAGE_SHARED		_MOD_PROT(pgprot_default, PTE_USER | PTE_NG | PTE_PXN | PTE_UXN)
 #define PAGE_SHARED_EXEC	_MOD_PROT(pgprot_default, PTE_USER | PTE_NG | PTE_PXN)
 #define PAGE_COPY		_MOD_PROT(pgprot_default, PTE_USER | PTE_NG | PTE_PXN | PTE_UXN | PTE_RDONLY)
@@ -76,7 +76,7 @@ extern pgprot_t pgprot_default;
 #define PAGE_KERNEL		_MOD_PROT(pgprot_default, PTE_PXN | PTE_UXN | PTE_DIRTY)
 #define PAGE_KERNEL_EXEC	_MOD_PROT(pgprot_default, PTE_UXN | PTE_DIRTY)
 
-#define __PAGE_NONE		__pgprot(((_PAGE_DEFAULT) & ~PTE_TYPE_MASK) | PTE_PROT_NONE)
+#define __PAGE_NONE		__pgprot(((_PAGE_DEFAULT) & ~PTE_TYPE_MASK) | PTE_PROT_NONE | PTE_RDONLY | PTE_PXN | PTE_UXN)
 #define __PAGE_SHARED		__pgprot(_PAGE_DEFAULT | PTE_USER | PTE_NG | PTE_PXN | PTE_UXN)
 #define __PAGE_SHARED_EXEC	__pgprot(_PAGE_DEFAULT | PTE_USER | PTE_NG | PTE_PXN)
 #define __PAGE_COPY		__pgprot(_PAGE_DEFAULT | PTE_USER | PTE_NG | PTE_PXN | PTE_UXN | PTE_RDONLY)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
