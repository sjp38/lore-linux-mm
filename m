Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7E1B6B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 17:10:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h11so10308114pfn.0
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 14:10:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a7-v6sor42668pll.106.2018.03.19.14.10.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 14:10:08 -0700 (PDT)
Date: Mon, 19 Mar 2018 14:10:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: do not cause memcg oom for thp
Message-ID: <alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and
madvised allocations") changed the page allocator to no longer detect thp
allocations based on __GFP_NORETRY.

It did not, however, modify the mem cgroup try_charge() path to avoid oom
kill for either khugepaged collapsing or thp faulting.  It is never
expected to oom kill a process to allocate a hugepage for thp; reclaim is
governed by the thp defrag mode and MADV_HUGEPAGE, but allocations (and
charging) should fallback instead of oom killing processes.

Fixes: 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations")
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c | 5 +++--
 mm/khugepaged.c  | 8 ++++++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -555,7 +555,8 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
-	if (mem_cgroup_try_charge(page, vma->vm_mm, gfp, &memcg, true)) {
+	if (mem_cgroup_try_charge(page, vma->vm_mm, gfp | __GFP_NORETRY, &memcg,
+				  true)) {
 		put_page(page);
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -1316,7 +1317,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	}
 
 	if (unlikely(mem_cgroup_try_charge(new_page, vma->vm_mm,
-					huge_gfp, &memcg, true))) {
+				huge_gfp | __GFP_NORETRY, &memcg, true))) {
 		put_page(new_page);
 		split_huge_pmd(vma, vmf->pmd, vmf->address);
 		if (page)
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -960,7 +960,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg, true))) {
+	/* Do not oom kill for khugepaged charges */
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp | __GFP_NORETRY,
+					   &memcg, true))) {
 		result = SCAN_CGROUP_CHARGE_FAIL;
 		goto out_nolock;
 	}
@@ -1319,7 +1321,9 @@ static void collapse_shmem(struct mm_struct *mm,
 		goto out;
 	}
 
-	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg, true))) {
+	/* Do not oom kill for khugepaged charges */
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp | __GFP_NORETRY,
+					   &memcg, true))) {
 		result = SCAN_CGROUP_CHARGE_FAIL;
 		goto out;
 	}
