Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9635D6B025F
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:06:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so63713056pfa.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:06:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id w6si5441185pac.26.2016.06.15.13.06.54
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:06:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 03/37] mm, thp: fix locking inconsistency in collapse_huge_page
Date: Wed, 15 Jun 2016 23:06:08 +0300
Message-Id: <1466021202-61880-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Rik van Riel <riel@redhat.com>

From: Ebru Akagunduz <ebru.akagunduz@gmail.com>

After creating revalidate vma function, locking inconsistency occured
due to directing the code path to wrong label. This patch directs
to correct label and fix the inconsistency.

Related commit that caused inconsistency:
http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=da4360877094368f6dfe75bbe804b0f0a5d575b0

Link: http://lkml.kernel.org/r/1464956884-4644-1-git-send-email-ebru.akagunduz@gmail.com
Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/huge_memory.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7bb30e853335..1777b806de96 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2487,13 +2487,18 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	down_read(&mm->mmap_sem);
 	result = hugepage_vma_revalidate(mm, address);
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
@@ -2502,8 +2507,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * label out. Continuing to collapse causes inconsistency.
 	 */
 	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
+		mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
-		goto out;
+		goto out_nolock;
 	}
 
 	up_read(&mm->mmap_sem);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
