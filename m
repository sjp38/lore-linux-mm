Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 444166B0254
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 09:04:15 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id cy9so434836692pac.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:04:15 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id 20si39957452pfr.82.2016.01.18.06.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 06:04:14 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id uo6so420480223pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:04:14 -0800 (PST)
From: Liang Chen <liangchen.linux@gmail.com>
Subject: [PATCH] mm:mempolicy: skip VM_HUGETLB and VM_MIXEDMAP VMA for lazy mbind
Date: Mon, 18 Jan 2016 22:03:54 +0800
Message-Id: <1453125834-16546-1-git-send-email-liangchen.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org
Cc: riel@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Liang Chen <liangchen.linux@gmail.com>, Gavin Guo <gavin.guo@canonical.com>

VM_HUGETLB and VM_MIXEDMAP vma needs to be excluded to avoid compound
pages being marked for migration and unexpected COWs when handling
hugetlb fault.

Thanks to Naoya Horiguchi for reminding me on these checks.

Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
---
 mm/mempolicy.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 436ff411..415de70 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -610,8 +610,9 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 
 	if (flags & MPOL_MF_LAZY) {
 		/* Similar to task_numa_work, skip inaccessible VMAs */
-		if (vma_migratable(vma) &&
-			vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
+		if (vma_migratable(vma) && !is_vm_hugetlb_page(vma) &&
+			(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)) &&
+			!(vma->vm_flags & VM_MIXEDMAP))
 			change_prot_numa(vma, start, endvma);
 		return 1;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
