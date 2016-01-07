Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8456E6B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 22:52:49 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id cy9so247663765pac.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 19:52:49 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id bx1si52514120pab.57.2016.01.06.19.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 19:52:48 -0800 (PST)
Received: by mail-pa0-x243.google.com with SMTP id pv5so20160483pac.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 19:52:48 -0800 (PST)
From: Liang Chen <liangchen.linux@gmail.com>
Subject: [PATCH V2] mm: mempolicy: skip non-migratable VMAs when setting MPOL_MF_LAZY
Date: Thu,  7 Jan 2016 11:52:38 +0800
Message-Id: <1452138758-30031-1-git-send-email-liangchen.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: mgorman@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, linux-kernel@vger.kernel.org, Liang Chen <liangchen.linux@gmail.com>, Gavin Guo <gavin.guo@canonical.com>

MPOL_MF_LAZY is not visible from userspace since 'commit a720094ded8c
("mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")'
, but it should still skip non-migratable VMAs such as VM_IO, VM_PFNMAP,
and VM_HUGETLB VMAs, and avoid useless overhead of minor faults.

Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
---
Changes since v2:
- Add more description into the changelog

We have been evaluating the enablement of MPOL_MF_LAZY again, and found
this issue. And we decided to push this patch upstream no matter if we
finally determine to propose re-enablement of MPOL_MF_LAZY or not. Since
it can be a potential problem even if MPOL_MF_LAZY is not enabled this
time.
---
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
