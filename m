Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D5C8F6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 09:21:01 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id 65so194620021pff.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 06:21:01 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id vz3si48499214pab.93.2016.01.06.06.21.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 06:21:01 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id e65so186687812pfe.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 06:21:00 -0800 (PST)
From: Liang Chen <liangchen.linux@gmail.com>
Subject: [PATCH] mm: mempolicy: skip non-migratable VMAs when setting MPOL_MF_LAZY
Date: Wed,  6 Jan 2016 22:18:47 +0800
Message-Id: <1452089927-22039-1-git-send-email-liangchen.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@suse.de, akpm@linux-foundation.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, linux-kernel@vger.kernel.org, Liang Chen <liangchen.linux@gmail.com>, Gavin Guo <gavin.guo@canonical.com>

MPOL_MF_LAZY is not visible from userspace since 'commit a720094ded8c
("mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")'
, but it should still skip non-migratable VMAs.

Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
---
We have been evaluating the enablement of MPOL_MF_LAZY again, and found
this issue. And we decided to push this patch upstream no matter if we
finally determine to propose re-enablement of MPOL_MF_LAZY or not. Since
it can be a potential problem even if MPOL_MF_LAZY is not enabled this
time.

 mm/mempolicy.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 87a1779..436ff411 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -610,7 +610,8 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
 
 	if (flags & MPOL_MF_LAZY) {
 		/* Similar to task_numa_work, skip inaccessible VMAs */
-		if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
+		if (vma_migratable(vma) &&
+			vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
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
