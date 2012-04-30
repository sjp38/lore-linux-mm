Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id E58186B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 07:29:09 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so1941883lbj.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 04:29:07 -0700 (PDT)
Subject: [PATCH RFC 1/3] proc/smaps: carefully handle migration entries
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 30 Apr 2012 15:29:03 +0400
Message-ID: <20120430112903.14137.81692.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>

Currently smaps reports migration entries as "swap",
as result "swap" can appears in shared mapping.

This patch converts migration entries into pages and handles them as usual.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/proc/task_mmu.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b073971..acee5fd 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -402,18 +402,20 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 {
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = mss->vma;
-	struct page *page;
+	struct page *page = NULL;
 	int mapcount;
 
-	if (is_swap_pte(ptent)) {
-		mss->swap += ptent_size;
-		return;
-	}
+	if (pte_present(ptent)) {
+		page = vm_normal_page(vma, addr, ptent);
+	} else if (is_swap_pte(ptent)) {
+		swp_entry_t swpent = pte_to_swp_entry(ptent);
 
-	if (!pte_present(ptent))
-		return;
+		if (!non_swap_entry(swpent))
+			mss->swap += ptent_size;
+		else if (is_migration_entry(swpent))
+			page = migration_entry_to_page(swpent);
+	}
 
-	page = vm_normal_page(vma, addr, ptent);
 	if (!page)
 		return;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
