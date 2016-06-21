Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF3ED828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:04:53 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id t7so50063542vkf.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:04:53 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v35si54480621qtb.4.2016.06.21.08.04.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 08:04:52 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm/huge_memory: fix the memory leak due to the race
Date: Tue, 21 Jun 2016 22:57:09 +0800
Message-ID: <1466521029-17049-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

with great pressure, I run some test cases. As a result, I found
that the THP is not freed, it is detected by check_mm().

BUG: Bad rss-counter state mm:ffff8827edb70000 idx:1 val:512

Consider the following race :

	CPU0                               CPU1
  __handle_mm_fault()
        wp_huge_pmd()
   	    do_huge_pmd_wp_page()
		pmdp_huge_clear_flush_notify()
                (pmd_none = true)
					exit_mmap()
					   unmap_vmas()
					     zap_pmd_range()
						pmd_none_or_trans_huge_or_clear_bad()
						   (result in memory leak)
                set_pmd_at()

because of CPU0 have allocated huge page before pmdp_huge_clear_notify,
and it make the pmd entry to be null. Therefore, The memory leak can occur.

The patch fix the scenario that the pmd entry can lead to be null.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e10a4fe..95c7dfe 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1340,7 +1340,7 @@ alloc:
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+		pmdp_invalidate(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(new_page, vma);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
