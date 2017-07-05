Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D011680FBC
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 13:28:27 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j186so272699815pge.12
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 10:28:27 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id n65si17644591pfh.410.2017.07.05.10.28.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 10:28:26 -0700 (PDT)
From: Krzysztof Opasiak <k.opasiak@samsung.com>
Subject: [PATCH 4/4] mm: Use dedicated helper to access rlimit value
Date: Wed, 05 Jul 2017 19:28:11 +0200
Message-id: <20170705172811.8027-1-k.opasiak@samsung.com>
References: <CGME20170705172822epcas5p285c1e58690388b8cb4453d37e968911b@epcas5p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Krzysztof Opasiak <k.opasiak@samsung.com>

Use rlimit() helper instead of manually writing whole
chain from current task to rlim_cur

Signed-off-by: Krzysztof Opasiak <k.opasiak@samsung.com>
---
 mm/mmap.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index a5e3dcd75e79..8d268b3983c9 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2177,7 +2177,6 @@ static int acct_stack_growth(struct vm_area_struct *vma,
 			     unsigned long size, unsigned long grow)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct rlimit *rlim = current->signal->rlim;
 	unsigned long new_start;
 
 	/* address space limit tests */
@@ -2185,7 +2184,7 @@ static int acct_stack_growth(struct vm_area_struct *vma,
 		return -ENOMEM;
 
 	/* Stack limit test */
-	if (size > READ_ONCE(rlim[RLIMIT_STACK].rlim_cur))
+	if (size > rlimit(RLIMIT_STACK))
 		return -ENOMEM;
 
 	/* mlock limit tests */
@@ -2193,7 +2192,7 @@ static int acct_stack_growth(struct vm_area_struct *vma,
 		unsigned long locked;
 		unsigned long limit;
 		locked = mm->locked_vm + grow;
-		limit = READ_ONCE(rlim[RLIMIT_MEMLOCK].rlim_cur);
+		limit = rlimit(RLIMIT_MEMLOCK);
 		limit >>= PAGE_SHIFT;
 		if (locked > limit && !capable(CAP_IPC_LOCK))
 			return -ENOMEM;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
