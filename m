Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6BB3F6B007B
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:24 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 05/30] thp, mm: avoid PageUnevictable on active/inactive lru lists
Date: Thu, 14 Mar 2013 19:50:10 +0200
Message-Id: <1363283435-7666-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
The tail page will go LRU_UNEVICTABLE if head page is not on LRU or if
it's marked PageUnevictable() too.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/swap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 92a9be5..31584d0 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -762,7 +762,8 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 			lru = LRU_INACTIVE_ANON;
 		}
 	} else {
-		SetPageUnevictable(page_tail);
+		if (!PageLRU(page) || PageUnevictable(page))
+			SetPageUnevictable(page_tail);
 		lru = LRU_UNEVICTABLE;
 	}
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
