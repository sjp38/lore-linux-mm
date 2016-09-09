Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8746B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 21:30:59 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 10so125832664ual.2
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 18:30:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q4si194118ywf.20.2016.09.08.18.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 18:30:58 -0700 (PDT)
Date: Thu, 8 Sep 2016 21:30:53 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] sched,numa,mm: revert to checking pmd/pte_write instead of
 VMA flags
Message-ID: <20160908213053.07c992a9@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, aarcange@redhat.com

Commit 4d9424669946 ("mm: convert p[te|md]_mknonnuma and remaining
page table manipulations") changed NUMA balancing from _PAGE_NUMA
to using PROT_NONE, and was quickly found to introduce a regression
with NUMA grouping.

It was followed up by these changesets:

53da3bc2ba9e ("mm: fix up numa read-only thread grouping logic")
bea66fbd11af ("mm: numa: group related processes based on VMA flags instead of page table flags")
b191f9b106ea ("mm: numa: preserve PTE write permissions across a NUMA hinting fault")

The first of those two changesets try alternate approaches to NUMA
grouping, which apparently do not work as well as looking at the PTE
write permissions.

The latter patch preserves the PTE write permissions across a NUMA
protection fault. However, it forgets to revert the condition for
whether or not to group tasks together back to what it was before
3.19, even though the information is now preserved in the page tables
once again.

This patch brings the NUMA grouping heuristic back to what it was
before changeset 4d9424669946, which the changelogs of subsequent
changesets suggest worked best.

We have all the information again. We should probably use it.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/huge_memory.c | 2 +-
 mm/memory.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2db2112aa31e..c8bde270f557 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1168,7 +1168,7 @@ int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 	}
 
 	/* See similar comment in do_numa_page for explanation */
-	if (!(vma->vm_flags & VM_WRITE))
+	if (!pmd_write(pmd))
 		flags |= TNF_NO_GROUP;
 
 	/*
diff --git a/mm/memory.c b/mm/memory.c
index 83be99d9d8a1..558c85270ae2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3398,7 +3398,7 @@ static int do_numa_page(struct fault_env *fe, pte_t pte)
 	 * pte_dirty has unpredictable behaviour between PTE scan updates,
 	 * background writeback, dirty balancing and application behaviour.
 	 */
-	if (!(vma->vm_flags & VM_WRITE))
+	if (!pte_write(pte))
 		flags |= TNF_NO_GROUP;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
