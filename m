Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 38C7A6B0082
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:20:00 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so11491661wiv.0
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:19:59 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bw20si6625782wib.86.2014.11.20.02.19.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 02:19:59 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/10] ppc64: Add paranoid warnings for unexpected DSISR_PROTFAULT
Date: Thu, 20 Nov 2014 10:19:44 +0000
Message-Id: <1416478790-27522-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1416478790-27522-1-git-send-email-mgorman@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

ppc64 should not be depending on DSISR_PROTFAULT and it's unexpected
if they are triggered. This patch adds warnings just in case they
are being accidentally depended upon.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/copro_fault.c |  8 ++++++--
 arch/powerpc/mm/fault.c       | 20 +++++++++-----------
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 5a236f0..0450d68 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -64,10 +64,14 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 		if (!(vma->vm_flags & VM_WRITE))
 			goto out_unlock;
 	} else {
-		if (dsisr & DSISR_PROTFAULT)
-			goto out_unlock;
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto out_unlock;
+		/*
+		 * protfault should only happen due to us
+		 * mapping a region readonly temporarily. PROT_NONE
+		 * is also covered by the VMA check above.
+		 */
+		WARN_ON_ONCE(dsisr & DSISR_PROTFAULT);
 	}
 
 	ret = 0;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 5007497..9d6e0b3 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -396,17 +396,6 @@ good_area:
 #endif /* CONFIG_8xx */
 
 	if (is_exec) {
-#ifdef CONFIG_PPC_STD_MMU
-		/* Protection fault on exec go straight to failure on
-		 * Hash based MMUs as they either don't support per-page
-		 * execute permission, or if they do, it's handled already
-		 * at the hash level. This test would probably have to
-		 * be removed if we change the way this works to make hash
-		 * processors use the same I/D cache coherency mechanism
-		 * as embedded.
-		 */
-#endif /* CONFIG_PPC_STD_MMU */
-
 		/*
 		 * Allow execution from readable areas if the MMU does not
 		 * provide separate controls over reading and executing.
@@ -421,6 +410,14 @@ good_area:
 		    (cpu_has_feature(CPU_FTR_NOEXECUTE) ||
 		     !(vma->vm_flags & (VM_READ | VM_WRITE))))
 			goto bad_area;
+#ifdef CONFIG_PPC_STD_MMU
+		/*
+		 * protfault should only happen due to us
+		 * mapping a region readonly temporarily. PROT_NONE
+		 * is also covered by the VMA check above.
+		 */
+		WARN_ON_ONCE(error_code & DSISR_PROTFAULT);
+#endif /* CONFIG_PPC_STD_MMU */
 	/* a write */
 	} else if (is_write) {
 		if (!(vma->vm_flags & VM_WRITE))
@@ -430,6 +427,7 @@ good_area:
 	} else {
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)))
 			goto bad_area;
+		WARN_ON_ONCE(error_code & DSISR_PROTFAULT);
 	}
 
 	/*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
