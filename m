Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55E2A6B025F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:28:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so40803109wme.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:28:47 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id l135si8041937wmb.48.2016.06.03.05.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 05:28:46 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id a20so11685645wma.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:28:45 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH] mm, thp: fix locking inconsistency in collapse_huge_page
Date: Fri,  3 Jun 2016 15:28:04 +0300
Message-Id: <1464956884-4644-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <0c47a3a0-5530-b257-1c1f-28ed44ba97e6@suse.cz>
References: <0c47a3a0-5530-b257-1c1f-28ed44ba97e6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, mhocko@kernel.org, kirill.shutemov@linux.intel.com, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

After creating revalidate vma function, locking inconsistency occured
due to directing the code path to wrong label. This patch directs
to correct label and fix the inconsistency.

Related commit that caused inconsistency:
http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=da4360877094368f6dfe75bbe804b0f0a5d575b0

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
 mm/huge_memory.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 292cedd..8043d91 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2493,13 +2493,18 @@ static void collapse_huge_page(struct mm_struct *mm,
 	curr_allocstall = sum_vm_event(ALLOCSTALL);
 	down_read(&mm->mmap_sem);
 	result = hugepage_vma_revalidate(mm, vma, address);
-	if (result)
-		goto out;
+	if (result) {
+		mem_cgroup_cancel_charge(new_page, memcg, true);
+		up_read(&mm->mmap_sem);
+		goto out_nolock;
+	}
 
 	pmd = mm_find_pmd(mm, address);
 	if (!pmd) {
 		result = SCAN_PMD_NULL;
-		goto out;
+		mem_cgroup_cancel_charge(new_page, memcg, true);
+		up_read(&mm->mmap_sem);
+		goto out_nolock;
 	}
 
 	/*
@@ -2513,8 +2518,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 		 * label out. Continuing to collapse causes inconsistency.
 		 */
 		if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
+			mem_cgroup_cancel_charge(new_page, memcg, true);
 			up_read(&mm->mmap_sem);
-			goto out;
+			goto out_nolock;
 		}
 	}
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
