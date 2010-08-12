Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A59A6B02AA
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 04:02:25 -0400 (EDT)
Date: Thu, 12 Aug 2010 17:00:48 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/4] correct locking functions of hugepage migration routine
Message-ID: <20100812080048.GF6112@spritzera.linux.bs1.fc.nec.co.jp>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
 <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

For the migration of PAGE_SIZE pages, we can choose to continue to do
migration with "force" switch even if the old page has page lock held.
But for hugepage, I/O of subpages are not necessarily completed
in ascending order, which can cause race.
So we make migration fail then for safety.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 7f9a37c..43347e1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -820,11 +820,14 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 
 	rc = -EAGAIN;
 
-	if (!trylock_page(hpage)) {
-		if (!force)
-			goto out;
-		lock_page(hpage);
-	}
+	/*
+	 * If some subpages are locked, it can cause race condition.
+	 * So then we return from migration and try again.
+	 */
+	if (!trylock_huge_page(hpage))
+		goto out;
+
+	wait_on_huge_page_writeback(hpage);
 
 	if (PageAnon(hpage)) {
 		rcu_read_lock();
@@ -855,7 +858,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	if (rcu_locked)
 		rcu_read_unlock();
 out:
-	unlock_page(hpage);
+	unlock_huge_page(hpage);
 
 	if (rc != -EAGAIN)
 		put_page(hpage);
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
