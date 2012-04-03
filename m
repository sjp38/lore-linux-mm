Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id B288E6B004A
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 21:30:25 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id r24so6557991iaj.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 18:30:25 -0700 (PDT)
Date: Mon, 2 Apr 2012 18:30:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, thp: allow fallback when pte_alloc_one() fails for
 huge pmd
In-Reply-To: <alpine.DEB.2.00.1204021829260.25776@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1204021829490.25776@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1204021829260.25776@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

The transparent hugepages feature is careful to not invoke the oom killer
when a hugepage cannot be allocated.

pte_alloc_one() failing in __do_huge_pmd_anonymous_page(), however,
currently results in VM_FAULT_OOM which invokes the pagefault oom killer
to kill a memory-hogging task.

This is unnecessary since it's possible to drop the reference to the
hugepage and fallback to allocating a small page.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -640,11 +640,8 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
 	VM_BUG_ON(!PageCompound(page));
 	pgtable = pte_alloc_one(mm, haddr);
-	if (unlikely(!pgtable)) {
-		mem_cgroup_uncharge_page(page);
-		put_page(page);
+	if (unlikely(!pgtable))
 		return VM_FAULT_OOM;
-	}
 
 	clear_huge_page(page, haddr, HPAGE_PMD_NR);
 	__SetPageUptodate(page);
@@ -723,8 +720,14 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			put_page(page);
 			goto out;
 		}
+		if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd,
+							  page))) {
+			mem_cgroup_uncharge_page(page);
+			put_page(page);
+			goto out;
+		}
 
-		return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
+		return 0;
 	}
 out:
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
