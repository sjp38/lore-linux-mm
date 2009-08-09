Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 098686B0055
	for <linux-mm@kvack.org>; Sun,  9 Aug 2009 05:37:21 -0400 (EDT)
From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH RT 9/6] [RFH] Build failure on 2.6.31-rc4-rt1 in mm/highmem.c
Date: Sun,  9 Aug 2009 11:36:40 +0200
Message-Id: <1249810600-21946-3-git-send-email-u.kleine-koenig@pengutronix.de>
In-Reply-To: <1249810600-21946-2-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20090807203939.GA19374@pengutronix.de>
 <1249810600-21946-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1249810600-21946-2-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, rt-users <linux-rt-users@vger.kernel.org>, Nicolas Pitre <nico@marvell.com>, MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The two commits

	b38cb5a (mm: remove kmap_lock)

and

	3297e76 (highmem: atomic highmem kmap page pinning)

conflict (without causing a text based conflict) because the latter
introduces a usage of kmap_lock.

The actual compiler output is (e.g. for ARCH=arm, stmp378x_defconfig):

	  CC      mm/highmem.o
	mm/highmem.c: In function 'pkmap_try_free':
	mm/highmem.c:116: warning: unused variable 'addr'
	mm/highmem.c: In function 'kmap_high_get':
	mm/highmem.c:372: error: 'kmap_lock' undeclared (first use in this function)
	mm/highmem.c:372: error: (Each undeclared identifier is reported only once
	mm/highmem.c:372: error: for each function it appears in.)
	mm/highmem.c:375: error: invalid operands to binary < (have 'atomic_t' and 'int')
	mm/highmem.c:376: error: wrong type argument to increment

The problems in lines 116 and 375f are resolved by the patch below, but
I don't know highmem enough to fix the remaining error.  Moreover I
don't have a machine that makes use of highmem.

Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
Cc: Nicolas Pitre <nico@marvell.com>
Cc: MinChan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Jens Axboe <jens.axboe@oracle.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/highmem.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 66e915a..4aa9eea 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -113,10 +113,10 @@ static int pkmap_try_free(int pos)
 	 */
 	if (!pte_none(pkmap_page_table[pos])) {
 		struct page *page = pte_page(pkmap_page_table[pos]);
-		unsigned long addr = PKMAP_ADDR(pos);
 		pte_t *ptep = &pkmap_page_table[pos];
 
-		VM_BUG_ON(addr != (unsigned long)page_address(page));
+		VM_BUG_ON((unsigned long)PKMAP_ADDR(pos) !=
+				(unsigned long)page_address(page));
 
 		if (!__set_page_address(page, NULL, pos))
 			BUG();
@@ -372,8 +372,8 @@ void *kmap_high_get(struct page *page)
 	lock_kmap_any(flags);
 	vaddr = (unsigned long)page_address(page);
 	if (vaddr) {
-		BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 1);
-		pkmap_count[PKMAP_NR(vaddr)]++;
+		BUG_ON(atomic_read(&pkmap_count[PKMAP_NR(vaddr)]) < 1);
+		atomic_add(1, pkmap_count[PKMAP_NR(vaddr)]);
 	}
 	unlock_kmap_any(flags);
 	return (void*) vaddr;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
