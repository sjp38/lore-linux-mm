Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4BB6B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 15:31:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q6so52163wre.20
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 12:31:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k65sor501431wmb.15.2018.04.03.12.31.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 12:31:40 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] memcg, thp: do not invoke oom killer on thp charges
Date: Tue,  3 Apr 2018 21:31:29 +0200
Message-Id: <20180403193129.22146-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

David has noticed that THP memcg charge can trigger the oom killer
since 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and
madvised allocations"). We have used an explicit __GFP_NORETRY
previously which ruled the OOM killer automagically.

Memcg charge path should be semantically compliant with the allocation
path and that means that if we do not trigger the OOM killer for
costly orders which should do the same in the memcg charge path as
well.  Otherwise we are forcing callers to distinguish the two and use
different gfp masks which is both non-intuitive and bug prone. As soon
as we get a costly high order kmalloc user we even do not have any means
to tell the memcg specific gfp mask to prevent from OOM because the
charging is deep within guts of the slab allocator.

The unexpected memcg OOM on THP has already been fixed upstream by
9d3c3354bb85 ("mm, thp: do not cause memcg oom for thp") but this is
one-off fix rather than a generic solution. Teach mem_cgroup_oom to bail
out on costly order requests to fix the THP issue as well as any other
costly OOM eligible allocations to be added in future.

Also revert 9d3c3354bb85 because special gfp for THP is no longer
needed.

Fixes: 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations")
Reported-by: David Rientjes <rientjes@google.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi Andrew,
I have posted core of this patch here [1]. This version just reverts
2516035499b9 on top. I think that we should aim either the next merge
window or keep the patch in the mmotm for the 4.18 merge window. I do
not have a strong preference. 2516035499b9 acts as a stop gap fix for
the time being.

[1] http://lkml.kernel.org/r/20180321205928.22240-1-mhocko@kernel.org

 mm/huge_memory.c | 5 ++---
 mm/khugepaged.c  | 8 ++------
 mm/memcontrol.c  | 2 +-
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2297dd9cc7c3..0cc62405de9c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -555,8 +555,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
-	if (mem_cgroup_try_charge(page, vma->vm_mm, gfp | __GFP_NORETRY, &memcg,
-				  true)) {
+	if (mem_cgroup_try_charge(page, vma->vm_mm, gfp, &memcg, true)) {
 		put_page(page);
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -1317,7 +1316,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	}
 
 	if (unlikely(mem_cgroup_try_charge(new_page, vma->vm_mm,
-				huge_gfp | __GFP_NORETRY, &memcg, true))) {
+					huge_gfp, &memcg, true))) {
 		put_page(new_page);
 		split_huge_pmd(vma, vmf->pmd, vmf->address);
 		if (page)
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 214e614b62b0..b7e2268dfc9a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -960,9 +960,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	/* Do not oom kill for khugepaged charges */
-	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp | __GFP_NORETRY,
-					   &memcg, true))) {
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg, true))) {
 		result = SCAN_CGROUP_CHARGE_FAIL;
 		goto out_nolock;
 	}
@@ -1321,9 +1319,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		goto out;
 	}
 
-	/* Do not oom kill for khugepaged charges */
-	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp | __GFP_NORETRY,
-					   &memcg, true))) {
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg, true))) {
 		result = SCAN_CGROUP_CHARGE_FAIL;
 		goto out;
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d1a917b5b7b7..08accbcd1a18 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1493,7 +1493,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 
 static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
-	if (!current->memcg_may_oom)
+	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
 		return;
 	/*
 	 * We are in the middle of the charge context here, so we
-- 
2.16.3
