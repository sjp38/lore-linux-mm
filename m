Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 00F086B0033
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 18:17:19 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so1299851pab.22
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:17:19 -0700 (PDT)
Date: Wed, 21 Aug 2013 15:17:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, thp: count thp_fault_fallback anytime thp fault
 fails
In-Reply-To: <20130821142817.8EB4BE0090@blue.fi.intel.com>
Message-ID: <alpine.DEB.2.02.1308211516580.6225@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1308201716510.25665@chino.kir.corp.google.com> <20130821142817.8EB4BE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently, thp_fault_fallback in vmstat only gets incremented if a
hugepage allocation fails.  If current's memcg hits its limit or the page
fault handler returns an error, it is incorrectly accounted as a
successful thp_fault_alloc.

Count thp_fault_fallback anytime the page fault handler falls back to
using regular pages and only count thp_fault_alloc when a hugepage has
actually been faulted.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -825,17 +825,19 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	count_vm_event(THP_FAULT_ALLOC);
 	if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
 		put_page(page);
+		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
 	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
 		mem_cgroup_uncharge_page(page);
 		put_page(page);
+		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
 
+	count_vm_event(THP_FAULT_ALLOC);
 	return 0;
 }
 
@@ -1148,7 +1150,6 @@ alloc:
 		new_page = NULL;
 
 	if (unlikely(!new_page)) {
-		count_vm_event(THP_FAULT_FALLBACK);
 		if (is_huge_zero_pmd(orig_pmd)) {
 			ret = do_huge_pmd_wp_zero_page_fallback(mm, vma,
 					address, pmd, orig_pmd, haddr);
@@ -1159,9 +1160,9 @@ alloc:
 				split_huge_page(page);
 			put_page(page);
 		}
+		count_vm_event(THP_FAULT_FALLBACK);
 		goto out;
 	}
-	count_vm_event(THP_FAULT_ALLOC);
 
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		put_page(new_page);
@@ -1169,10 +1170,13 @@ alloc:
 			split_huge_page(page);
 			put_page(page);
 		}
+		count_vm_event(THP_FAULT_FALLBACK);
 		ret |= VM_FAULT_OOM;
 		goto out;
 	}
 
+	count_vm_event(THP_FAULT_ALLOC);
+
 	if (is_huge_zero_pmd(orig_pmd))
 		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
