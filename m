Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98EE66B0005
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 20:09:20 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a2so49770707lfe.0
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 17:09:20 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id m18si232758wmc.95.2016.07.09.17.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 17:09:19 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id k123so12205460wme.2
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 17:09:19 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v3 1/2] mm, thp: fix comment inconsistency for swapin readahead functions
Date: Sun, 10 Jul 2016 03:09:05 +0300
Message-Id: <1468109345-32258-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1468109224-29912-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1468109224-29912-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, hillf.zj@alibaba-inc.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

After fixing swapin issues, comment lines stayed as in old version.
This patch updates the comments.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
---
Changes in v2:
 - Newly created in this version.

Changes in v3:
 - Replace Reported-by with Cc (Hillf Danton)
 - Remove RFC tag (Hillf Danton)
 - After khugepaged extracted from huge_memory.c,
   changes moved to khugepaged.c

 mm/khugepaged.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 93d5f87..5661484 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -891,9 +891,10 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
 			down_read(&mm->mmap_sem);
-			/* vma is no longer available, don't continue to swapin */
-			if (hugepage_vma_revalidate(mm, address))
+			if (hugepage_vma_revalidate(mm, address)) {
+				/* vma is no longer available, don't continue to swapin */
 				return false;
+			}
 			/* check if the pmd is still valid */
 			if (mm_find_pmd(mm, address) != pmd)
 				return false;
@@ -969,7 +970,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	/*
 	 * __collapse_huge_page_swapin always returns with mmap_sem locked.
-	 * If it fails, release mmap_sem and jump directly out.
+	 * If it fails, we release mmap_sem and jump out_nolock.
 	 * Continuing to collapse causes inconsistency.
 	 */
 	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
