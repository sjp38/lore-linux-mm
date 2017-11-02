Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD586B0260
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:38:50 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p1so3785010qtg.18
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:38:50 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id y190si1162487qkd.187.2017.11.02.05.38.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:38:49 -0700 (PDT)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] mm: try to free swap only for reading swap fault
Date: Thu, 2 Nov 2017 20:35:19 +0800
Message-ID: <1509626119-39916-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, mhocko@suse.com, dave.jiang@intel.com, aneesh.kumar@linux.vnet.ibm.com, minchan@kernel.org, mingo@kernel.org, jglisse@redhat.com, willy@linux.intel.com, hughd@google.com, zhouxianrong@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, fanghua3@huawei.com, hutj@huawei.com, won.ho.park@huawei.com

From: zhouxianrong <zhouxianrong@huawei.com>

the purpose of this patch is that when a reading swap fault
happens on a clean swap cache page whose swap count is equal
to one, then try_to_free_swap could remove this page from 
swap cache and mark this page dirty. so if later we reclaimed
this page then we could pageout this page due to this dirty.
so i want to allow this action only for writing swap fault.

i sampled the data of non-dirty anonymous pages which is no
need to pageout and total anonymous pages in shrink_page_list.

the results are:

        non-dirty anonymous pages     total anonymous pages
before  26343                         635218
after   36907                         634312

Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
---
 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index a728bed..5a944fe 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2999,7 +2999,7 @@ int do_swap_page(struct vm_fault *vmf)
 	}
 
 	swap_free(entry);
-	if (mem_cgroup_swap_full(page) ||
+	if (((vmf->flags & FAULT_FLAG_WRITE) && mem_cgroup_swap_full(page)) ||
 	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
