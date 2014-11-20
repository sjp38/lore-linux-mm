Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id F327B6B0092
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:20:08 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so3255831wgh.17
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:20:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id aw9si2633459wjc.177.2014.11.20.02.20.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 02:20:08 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/10] mm: numa: Avoid unnecessary TLB flushes when setting NUMA hinting entries
Date: Thu, 20 Nov 2014 10:19:50 +0000
Message-Id: <1416478790-27522-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1416478790-27522-1-git-send-email-mgorman@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

If a PTE or PMD is already marked NUMA when scanning to mark entries
for NUMA hinting then it is not necessary to update the entry and
incur a TLB flush penalty. Avoid the avoidhead where possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 14 ++++++++------
 mm/mprotect.c    |  4 ++++
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6458229f..a7ea9b8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1524,12 +1524,14 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			return 0;
 		}
 
-		ret = 1;
-		entry = pmdp_get_and_clear(mm, addr, pmd);
-		entry = pmd_modify(entry, newprot);
-		ret = HPAGE_PMD_NR;
-		set_pmd_at(mm, addr, pmd, entry);
-		BUG_ON(pmd_write(entry));
+		if (!prot_numa || !pmd_protnone_numa(*pmd)) {
+			ret = 1;
+			entry = pmdp_get_and_clear(mm, addr, pmd);
+			entry = pmd_modify(entry, newprot);
+			ret = HPAGE_PMD_NR;
+			set_pmd_at(mm, addr, pmd, entry);
+			BUG_ON(pmd_write(entry));
+		}
 		spin_unlock(ptl);
 	}
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 33dfafb..eb890d0 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -86,6 +86,10 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				page = vm_normal_page(vma, addr, oldpte);
 				if (!page || PageKsm(page))
 					continue;
+
+				/* Avoid TLB flush if possible */
+				if (pte_protnone_numa(oldpte))
+					continue;
 			}
 
 			ptent = ptep_modify_prot_start(mm, addr, pte);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
