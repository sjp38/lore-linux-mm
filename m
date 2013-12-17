From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH] mm/mempolicy: fix !vma in new_vma_page()
Date: Tue, 17 Dec 2013 14:44:17 +0800
Message-ID: <1387262658-29067-1-git-send-email-liwanp@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@codemonkey.org.uk>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, dan.carpenter@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>
List-Id: linux-mm.kvack.org

BUG_ON(!vma) assumption is introduced by commit 0bf598d8 (mbind: add BUG_ON(!vma) 
in new_vma_page()), however, even if address = __vma_address(page, vma); and 
vma->start < address < vma->end; page_address_in_vma() may still return -EFAULT 
because of many other conditions in it. As a result the while loop in new_vma_page() 
may end with vma=NULL. This patch revert the commit and also fix the potential 
dereference NULL pointer by Dan. http://marc.info/?l=linux-mm&m=137689530323257&w=2

kernel BUG at mm/mempolicy.c:1204!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
CPU: 3 PID: 7056 Comm: trinity-child3 Not tainted 3.13.0-rc3+ #2
task: ffff8801ca5295d0 ti: ffff88005ab20000 task.ti: ffff88005ab20000
RIP: 0010:[<ffffffff8119f200>]  [<ffffffff8119f200>] new_vma_page+0x70/0x90
RSP: 0000:ffff88005ab21db0  EFLAGS: 00010246
RAX: fffffffffffffff2 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000008040075 RSI: ffff8801c3d74600 RDI: ffffea00079a8b80
RBP: ffff88005ab21dc8 R08: 0000000000000004 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: fffffffffffffff2
R13: ffffea00079a8b80 R14: 0000000000400000 R15: 0000000000400000

FS:  00007ff49c6f4740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ff49c68f994 CR3: 000000005a205000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Stack:
 ffffea00079a8b80 ffffea00079a8bc0 ffffea00079a8ba0 ffff88005ab21e50
 ffffffff811adc7a 0000000000000000 ffff8801ca5295d0 0000000464e224f8
 0000000000000000 0000000000000002 0000000000000000 ffff88020ce75c00
Call Trace:
 [<ffffffff811adc7a>] migrate_pages+0x12a/0x850
 [<ffffffff8119f190>] ? alloc_pages_vma+0x1b0/0x1b0
 [<ffffffff8119fa13>] SYSC_mbind+0x513/0x6a0
 [<ffffffff810aa7de>] ? lock_release_holdtime.part.29+0xee/0x170
 [<ffffffff8119fbae>] SyS_mbind+0xe/0x10
 [<ffffffff817626a9>] ia32_do_call+0x13/0x13
Code: 85 c0 75 2f 4c 89 e1 48 89 da 31 f6 bf da 00 02 00 65 44 8b 04 25 08 f7 1c 00 e8 ec fd ff ff 5b 41 5c 41 5d 5d c3 0f 1f 44 00 00 <0f> 0b 66 0f 1f 44 00
+00 4c 89 e6 48 89 df ba 01 00 00 00 e8 48
RIP  [<ffffffff8119f200>] new_vma_page+0x70/0x90
 RSP <ffff88005ab21db0>

Reported-by: Dave Jones <davej@redhat.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/mempolicy.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index eca4a31..7247c38 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1197,14 +1197,16 @@ static struct page *new_vma_page(struct page *page, unsigned long private, int *
 			break;
 		vma = vma->vm_next;
 	}
+
+	if (PageHuge(page)) {
+		if (vma)
+			return alloc_huge_page_noerr(vma, address, 1);
+		else
+			return NULL;
+	}
 	/*
-	 * queue_pages_range() confirms that @page belongs to some vma,
-	 * so vma shouldn't be NULL.
+	 * if !vma, alloc_page_vma() will use task or system default policy
 	 */
-	BUG_ON(!vma);
-
-	if (PageHuge(page))
-		return alloc_huge_page_noerr(vma, address, 1);
 	return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 }
 #else
-- 
1.7.5.4
