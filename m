Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 86E6D6B0039
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:34 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 06/39] thp, mm: avoid PageUnevictable on active/inactive lru lists
Date: Sun, 12 May 2013 04:23:03 +0300
Message-Id: <1368321816-17719-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

active/inactive lru lists can contain unevicable pages (i.e. ramfs pages
that have been placed on the LRU lists when first allocated), but these
pages must not have PageUnevictable set - otherwise shrink_active_list
goes crazy:

kernel BUG at /home/space/kas/git/public/linux-next/mm/vmscan.c:1122!
invalid opcode: 0000 [#1] SMP
CPU 0
Pid: 293, comm: kswapd0 Not tainted 3.8.0-rc6-next-20130202+ #531
RIP: 0010:[<ffffffff81110478>]  [<ffffffff81110478>] isolate_lru_pages.isra.61+0x138/0x260
RSP: 0000:ffff8800796d9b28  EFLAGS: 00010082
RAX: 00000000ffffffea RBX: 0000000000000012 RCX: 0000000000000001
RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffea0001de8040
RBP: ffff8800796d9b88 R08: ffff8800796d9df0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000012
R13: ffffea0001de8060 R14: ffffffff818818e8 R15: ffff8800796d9bf8
FS:  0000000000000000(0000) GS:ffff88007a200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f1bfc108000 CR3: 000000000180b000 CR4: 00000000000406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kswapd0 (pid: 293, threadinfo ffff8800796d8000, task ffff880079e0a6e0)
Stack:
 ffff8800796d9b48 ffffffff81881880 ffff8800796d9df0 ffff8800796d9be0
 0000000000000002 000000000000001f ffff8800796d9b88 ffffffff818818c8
 ffffffff81881480 ffff8800796d9dc0 0000000000000002 000000000000001f
Call Trace:
 [<ffffffff81111e98>] shrink_inactive_list+0x108/0x4a0
 [<ffffffff8109ce3d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff8107b8bf>] ? local_clock+0x4f/0x60
 [<ffffffff8110ff5d>] ? shrink_slab+0x1fd/0x4c0
 [<ffffffff811125a1>] shrink_zone+0x371/0x610
 [<ffffffff8110ff75>] ? shrink_slab+0x215/0x4c0
 [<ffffffff81112dfc>] kswapd+0x5bc/0xb60
 [<ffffffff81112840>] ? shrink_zone+0x610/0x610
 [<ffffffff81066676>] kthread+0xd6/0xe0
 [<ffffffff810665a0>] ? __kthread_bind+0x40/0x40
 [<ffffffff814fed6c>] ret_from_fork+0x7c/0xb0
 [<ffffffff810665a0>] ? __kthread_bind+0x40/0x40
Code: 1f 40 00 49 8b 45 08 49 8b 75 00 48 89 46 08 48 89 30 49 8b 06 4c 89 68 08 49 89 45 00 4d 89 75 08 4d 89 2e eb 9c 0f 1f 44 00 00 <0f> 0b 66 0f 1f 44 00 00 31 db 45 31 e4 eb 9b 0f 0b 0f 0b 65 48
RIP  [<ffffffff81110478>] isolate_lru_pages.isra.61+0x138/0x260
 RSP <ffff8800796d9b28>

For lru_add_page_tail(), it means we should not set PageUnevictable()
for tail pages unless we're sure that it will go to LRU_UNEVICTABLE.
Let's just copy PG_active and PG_unevictable from head page in
__split_huge_page_refcount(), it will simplify lru_add_page_tail().

This will fix one more bug in lru_add_page_tail():
if page_evictable(page_tail) is false and PageLRU(page) is true, page_tail
will go to the same lru as page, but nobody cares to sync page_tail
active/inactive state with page. So we can end up with inactive page on
active lru.
The patch will fix it as well since we copy PG_active from head page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |    4 +++-
 mm/swap.c        |   20 ++------------------
 2 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 03a89a2..b39fa01 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1612,7 +1612,9 @@ static void __split_huge_page_refcount(struct page *page,
 				     ((1L << PG_referenced) |
 				      (1L << PG_swapbacked) |
 				      (1L << PG_mlocked) |
-				      (1L << PG_uptodate)));
+				      (1L << PG_uptodate) |
+				      (1L << PG_active) |
+				      (1L << PG_unevictable)));
 		page_tail->flags |= (1L << PG_dirty);
 
 		/* clear PageTail before overwriting first_page */
diff --git a/mm/swap.c b/mm/swap.c
index acd40bf..9b0a64b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -739,8 +739,6 @@ EXPORT_SYMBOL(__pagevec_release);
 void lru_add_page_tail(struct page *page, struct page *page_tail,
 		       struct lruvec *lruvec, struct list_head *list)
 {
-	int uninitialized_var(active);
-	enum lru_list lru;
 	const int file = 0;
 
 	VM_BUG_ON(!PageHead(page));
@@ -752,20 +750,6 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	if (!list)
 		SetPageLRU(page_tail);
 
-	if (page_evictable(page_tail)) {
-		if (PageActive(page)) {
-			SetPageActive(page_tail);
-			active = 1;
-			lru = LRU_ACTIVE_ANON;
-		} else {
-			active = 0;
-			lru = LRU_INACTIVE_ANON;
-		}
-	} else {
-		SetPageUnevictable(page_tail);
-		lru = LRU_UNEVICTABLE;
-	}
-
 	if (likely(PageLRU(page)))
 		list_add_tail(&page_tail->lru, &page->lru);
 	else if (list) {
@@ -781,13 +765,13 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 		 * Use the standard add function to put page_tail on the list,
 		 * but then correct its position so they all end up in order.
 		 */
-		add_page_to_lru_list(page_tail, lruvec, lru);
+		add_page_to_lru_list(page_tail, lruvec, page_lru(page_tail));
 		list_head = page_tail->lru.prev;
 		list_move_tail(&page_tail->lru, list_head);
 	}
 
 	if (!PageUnevictable(page))
-		update_page_reclaim_stat(lruvec, file, active);
+		update_page_reclaim_stat(lruvec, file, PageActive(page_tail));
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
