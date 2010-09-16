Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B55E56B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 02:34:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8G6YduB027826
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Sep 2010 15:34:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5617445DE4F
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:34:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A12045DE4E
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:34:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EEB331DB8015
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:34:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EC641DB8014
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 15:34:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] smaps: fix dirty pages accounting
In-Reply-To: <201009161135.00129.knikanth@suse.de>
References: <20100916125147.CA08.A69D9226@jp.fujitsu.com> <201009161135.00129.knikanth@suse.de>
Message-Id: <20100916153420.3BBD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 16 Sep 2010 15:34:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matt Mackall <mpm@selenic.com>, Richard Guenther <rguenther@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently, /proc/<pid>/smaps have wrong dirty pages accounting.
Shared_Dirty and Private_Dirty output only pte dirty pages and
ignore PG_dirty page flag. It is difference against documentation,
but also inconsistent against Referenced field. (Referenced checks
both pte and page flags)

This patch fixes it.

Test program:

 large-array.c
 ---------------------------------------------------
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>

 char array[1*1024*1024*1024L];

 int main(void)
 {
         memset(array, 1, sizeof(array));
         pause();

         return 0;
 }
 ---------------------------------------------------

Test case:
 1. run ./large-array
 2. cat /proc/`pidof large-array`/smaps
 3. swapoff -a
 4. cat /proc/`pidof large-array`/smaps again

Test result:
 <before patch>

00601000-40601000 rw-p 00000000 00:00 0
Size:            1048576 kB
Rss:             1048576 kB
Pss:             1048576 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:    218992 kB   <-- showed pages as clean incorrectly
Private_Dirty:    829584 kB
Referenced:       388364 kB
Swap:                  0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB

 <after patch>

00601000-40601000 rw-p 00000000 00:00 0
Size:            1048576 kB
Rss:             1048576 kB
Pss:             1048576 kB
Shared_Clean:          0 kB
Shared_Dirty:          0 kB
Private_Clean:         0 kB
Private_Dirty:   1048576 kB  <-- fixed
Referenced:       388480 kB
Swap:                  0 kB
KernelPageSize:        4 kB
MMUPageSize:           4 kB

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/task_mmu.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 439fc1f..7415f13 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -362,13 +362,13 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			mss->referenced += PAGE_SIZE;
 		mapcount = page_mapcount(page);
 		if (mapcount >= 2) {
-			if (pte_dirty(ptent))
+			if (pte_dirty(ptent) || PageDirty(page))
 				mss->shared_dirty += PAGE_SIZE;
 			else
 				mss->shared_clean += PAGE_SIZE;
 			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
 		} else {
-			if (pte_dirty(ptent))
+			if (pte_dirty(ptent) || PageDirty(page))
 				mss->private_dirty += PAGE_SIZE;
 			else
 				mss->private_clean += PAGE_SIZE;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
