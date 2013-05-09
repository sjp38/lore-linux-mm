Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CCCDD6B0062
	for <linux-mm@kvack.org>; Wed,  8 May 2013 20:19:26 -0400 (EDT)
Subject: [PATCH] COMPACTION: bugfix of improper cache flush in MIGRATION code.
From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Date: Wed, 8 May 2013 17:18:21 -0700
Message-ID: <20130509001821.15951.98705.stgit@linux-yegoshin>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Page 'new' during MIGRATION can't be flushed by flush_cache_page().
Using flush_cache_page(vma, addr, pfn) is justified only if
page is already placed in process page table, and that is done right
after flush_cache_page(). But without it the arch function has
no knowledge of process PTE and does nothing.

Besides that, flush_cache_page() flushes an application cache,
kernel has a different page virtual address and dirtied it.

Replace it with flush_dcache_page(new) which is a proper usage.

Old page is flushed in try_to_unmap_one() before MIGRATION.

This bug takes place in Sead3 board with M14Kc MIPS CPU without
cache aliasing (but Harvard arch - separate I and D cache)
in tight memory environment (128MB) each 1-3days on SOAK test.
It fails in cc1 during kernel build (SIGILL, SIGBUS, SIGSEG) if
CONFIG_COMPACTION is switched ON.

Author: Leonid Yegoshin <yegoshin@mips.com>
Signed-off-by: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
---
 mm/migrate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 2fd8b4a..4c6250a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -165,7 +165,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		pte = arch_make_huge_pte(pte, vma, new, 0);
 	}
 #endif
-	flush_cache_page(vma, addr, pte_pfn(pte));
+	flush_dcache_page(new);
 	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageHuge(new)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
