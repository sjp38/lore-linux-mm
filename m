Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 075C36B0080
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:19:57 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so8169414wiw.7
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:19:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id er1si2676215wjd.152.2014.11.20.02.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 02:19:55 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/10] mm: numa: Do not dereference pmd outside of the lock during NUMA hinting fault
Date: Thu, 20 Nov 2014 10:19:41 +0000
Message-Id: <1416478790-27522-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1416478790-27522-1-git-send-email-mgorman@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

A transhuge NUMA hinting fault may find the page is migrating and should
wait until migration completes. The check is race-prone because the pmd
is deferenced outside of the page lock and while the race is tiny, it'll
be larger if the PMD is cleared while marking PMDs for hinting fault.
This patch closes the race.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h | 4 ----
 mm/huge_memory.c        | 3 ++-
 mm/migrate.c            | 6 ------
 3 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 01aad3e..a3edcdf 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -77,7 +77,6 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 #ifdef CONFIG_NUMA_BALANCING
 extern bool pmd_trans_migrating(pmd_t pmd);
-extern void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd);
 extern int migrate_misplaced_page(struct page *page,
 				  struct vm_area_struct *vma, int node);
 extern bool migrate_ratelimited(int node);
@@ -86,9 +85,6 @@ static inline bool pmd_trans_migrating(pmd_t pmd)
 {
 	return false;
 }
-static inline void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
-{
-}
 static inline int migrate_misplaced_page(struct page *page,
 					 struct vm_area_struct *vma, int node)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de98415..38fa6cc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1284,8 +1284,9 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * check_same as the page may no longer be mapped.
 	 */
 	if (unlikely(pmd_trans_migrating(*pmdp))) {
+		page = pmd_page(*pmdp);
 		spin_unlock(ptl);
-		wait_migrate_huge_page(vma->anon_vma, pmdp);
+		wait_on_page_locked(page);
 		goto out;
 	}
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 0143995..baaf80e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1698,12 +1698,6 @@ bool pmd_trans_migrating(pmd_t pmd)
 	return PageLocked(page);
 }
 
-void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
-{
-	struct page *page = pmd_page(*pmd);
-	wait_on_page_locked(page);
-}
-
 /*
  * Attempt to migrate a misplaced page to the specified destination
  * node. Caller is expected to have an elevated reference count on
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
