Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4D56B284D
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:14:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l15-v6so2562944pff.1
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 22:14:26 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id o6-v6si3293926pls.480.2018.08.22.22.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Aug 2018 22:14:25 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH] mm: respect arch_dup_mmap() return value
Date: Wed, 22 Aug 2018 22:12:29 -0700
Message-ID: <20180823051229.211856-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nadav Amit <namit@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

Commit d70f2a14b72a4 ("include/linux/sched/mm.h: uninline
mmdrop_async(), etc") ignored the return value of arch_dup_mmap(). As a
result, on x86, a failure to duplicate the LDT (e.g., due to memory
allocation error), would leave the duplicated memory mapping in an
inconsistent state.

Fix by regarding the return value, as it was before the change.

Fixes: d70f2a14b72a4 ("include/linux/sched/mm.h: uninline mmdrop_async(), etc")
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 kernel/fork.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 1b27babc4c78..4527d1d331de 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -549,8 +549,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 			goto out;
 	}
 	/* a new mm has just been created */
-	arch_dup_mmap(oldmm, mm);
-	retval = 0;
+	retval = arch_dup_mmap(oldmm, mm);
 out:
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);
-- 
2.17.1
