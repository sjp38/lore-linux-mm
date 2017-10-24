Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2496B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 19:57:26 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p54so18419969qtc.5
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 16:57:26 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i39si1225505qtb.445.2017.10.24.16.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 16:57:25 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH] Hugetlb pages rss accounting is incorrect in /proc/<pid>/smaps
Date: Tue, 24 Oct 2017 16:56:08 -0700
Message-Id: <1508889368-14489-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, minchan@kernel.org, rientjes@google.com, dancol@google.com, prakash.sangappa@oracle.com

Resident set size(Rss) accounting of hugetlb pages is not done
currently in /proc/<pid>/smaps. The pmap command reads rss from
this file and so it shows Rss to be 0 in pmap -x output for
hugetlb mapped vmas. This patch fixes it.

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
---
 fs/proc/task_mmu.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 5589b4b..c7e1048 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -724,6 +724,7 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
 			mss->shared_hugetlb += huge_page_size(hstate_vma(vma));
 		else
 			mss->private_hugetlb += huge_page_size(hstate_vma(vma));
+		mss->resident += huge_page_size(hstate_vma(vma));
 	}
 	return 0;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
