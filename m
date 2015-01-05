Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 07C266B007D
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 05:54:39 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so7629761wes.10
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 02:54:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ec2si15601607wib.90.2015.01.05.02.54.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 02:54:25 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/10] mm: numa: Avoid unnecessary TLB flushes when setting NUMA hinting entries
Date: Mon,  5 Jan 2015 10:54:11 +0000
Message-Id: <1420455251-13644-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1420455251-13644-1-git-send-email-mgorman@suse.de>
References: <1420455251-13644-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Mel Gorman <mgorman@suse.de>

If a PTE or PMD is already marked NUMA when scanning to mark entries
for NUMA hinting then it is not necessary to update the entry and
incur a TLB flush penalty. Avoid the avoidhead where possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 14 ++++++++------
 mm/mprotect.c    |  4 ++++
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8546654..f2bf521 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1524,12 +1524,14 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			return 0;
 		}
 
-		ret = 1;
-		entry = pmdp_get_and_clear_notify(mm, addr, pmd);
-		entry = pmd_modify(entry, newprot);
-		ret = HPAGE_PMD_NR;
-		set_pmd_at(mm, addr, pmd, entry);
-		BUG_ON(pmd_write(entry));
+		if (!prot_numa || !pmd_protnone(*pmd)) {
+			ret = 1;
+			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
+			entry = pmd_modify(entry, newprot);
+			ret = HPAGE_PMD_NR;
+			set_pmd_at(mm, addr, pmd, entry);
+			BUG_ON(pmd_write(entry));
+		}
 		spin_unlock(ptl);
 	}
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 33dfafb..109e7aa 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -86,6 +86,10 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				page = vm_normal_page(vma, addr, oldpte);
 				if (!page || PageKsm(page))
 					continue;
+
+				/* Avoid TLB flush if possible */
+				if (pte_protnone(oldpte))
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
