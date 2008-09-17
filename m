Date: Wed, 17 Sep 2008 13:31:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mm] memcg: fix handling of shmem migration
Message-Id: <20080917133149.b012a1c2.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, xemul@openvz.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

PG_swapbacked flag of newpage should be set(if needed) before
mem_cgroup_prepare_migration, because mem_cgroup_charge_common
checks the flag and determines whether it sets PAGE_CGROUP_FLAG_FILE or not.

Before this patch, if migrating shmem/tmpfs pages, newpage would be
charged with PAGE_CGROUP_FLAG_FILE set, while oldpage has been charged
without the flag.

The problem here is mem_cgroup_move_lists doesn't clear(or set)
the PAGE_CGROUP_FLAG_FILE flag, so pc->flags of the newpage
remains PAGE_CGROUP_FLAG_FILE set even when the pc is moved to
another lru(anon) by mem_cgroup_move_lists. And this leads to
incorrect MEM_CGROUP_ZSTAT.
(In my test, I see an underflow of MEM_CGROUP_ZSTAT(active_file).
As a result, mem_cgroup_calc_reclaim returns very huge number and
causes soft lockup on page reclaim.)

I'm not sure if mem_cgroup_move_lists should handle PAGE_CGROUP_FLAG_FILE
or not(I suppose it should be used to move between active <-> inactive,
not anon <-> file), I moved SetPageSwapBacked(newpage) before
mem_cgroup_prepare_migration.


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/migrate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 577d481..7343463 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -586,8 +586,6 @@ static int move_to_new_page(struct page *newpage, struct page *page)
 	/* Prepare mapping for the new page.*/
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
-	if (PageSwapBacked(page))
-		SetPageSwapBacked(newpage);
 
 	mapping = page_mapping(page);
 	if (!mapping)
@@ -636,6 +634,8 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		goto move_newpage;
 	}
 
+	if (PageSwapBacked(page))
+		SetPageSwapBacked(newpage);
 	charge = mem_cgroup_prepare_migration(page, newpage);
 	if (charge == -ENOMEM) {
 		rc = -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
