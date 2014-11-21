Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id B0EE590001A
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 08:58:06 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so8925671wiv.7
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:58:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb7si13148678wid.47.2014.11.21.05.58.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 05:58:02 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/10] x86: mm: Restore original pte_special check
Date: Fri, 21 Nov 2014 13:57:46 +0000
Message-Id: <1416578268-19597-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1416578268-19597-1-git-send-email-mgorman@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

Commit b38af4721f59 ("x86,mm: fix pte_special versus pte_numa") adjusted
the pte_special check to take into account that a special pte had SPECIAL
and neither PRESENT nor PROTNONE. Now that NUMA hinting PTEs are no
longer modifying _PAGE_PRESENT it should be safe to restore the original
pte_special behaviour.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/include/asm/pgtable.h | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index cf428a7..0dd5be3 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -136,13 +136,7 @@ static inline int pte_exec(pte_t pte)
 
 static inline int pte_special(pte_t pte)
 {
-	/*
-	 * See CONFIG_NUMA_BALANCING pte_numa in include/asm-generic/pgtable.h.
-	 * On x86 we have _PAGE_BIT_NUMA == _PAGE_BIT_GLOBAL+1 ==
-	 * __PAGE_BIT_SOFTW1 == _PAGE_BIT_SPECIAL.
-	 */
-	return (pte_flags(pte) & _PAGE_SPECIAL) &&
-		(pte_flags(pte) & (_PAGE_PRESENT|_PAGE_PROTNONE));
+	return pte_flags(pte) & _PAGE_SPECIAL;
 }
 
 static inline unsigned long pte_pfn(pte_t pte)
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
