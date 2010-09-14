Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 31BCC6B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:13:41 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: [PATCH v2] After swapout/swapin private dirty mappings are reported clean in smaps
Date: Tue, 14 Sep 2010 22:44:59 +0530
References: <201009141640.55650.knikanth@suse.de> <alpine.LNX.2.00.1009141330030.28912@zhemvz.fhfr.qr> <201009142242.29245.knikanth@suse.de>
In-Reply-To: <201009142242.29245.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201009142244.59080.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Richard Guenther <rguenther@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

/proc/$pid/smaps broken: After swapout/swapin private dirty mappings become
clean.

When a page with private file mapping becomes dirty, the vma will be in both
i_mmap tree and anon_vma list. The /proc/$pid/smaps will account these pages
as dirty and backed by the file.

But when those dirty pages gets swapped out, and when they are read back from
swap, they would be marked as clean, as it should be, as they are part of swap
cache now.

But the /proc/$pid/smaps would report the vma as a mapping of a file and it is
clean. The pages are actually in same state i.e., dirty with respect to file
still, but which was once reported as dirty is now being reported as clean to
user-space.

This confuses tools like gdb which uses this information. Those tools think
that those pages were never modified and it creates problem when they create
dumps.

The file mapping of the vma also cannot be broken as pages never read earlier,
will still have to come from the file. Just that those dirty pages have become
clean anonymous pages.

So instead when a file backed vma has anonymous pages report them as dirty
pages. As those pages are dirty with respect to the backing file.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

---

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 439fc1f..06fc468 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -368,7 +368,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 				mss->shared_clean += PAGE_SIZE;
 			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
 		} else {
-			if (pte_dirty(ptent))
+			/*
+			 * File-backed pages, now anonymous are dirty
+			 * with respect to the file.
+			 */
+			if (pte_dirty(ptent) || (vma->vm_file && PageAnon(page)))
 				mss->private_dirty += PAGE_SIZE;
 			else
 				mss->private_clean += PAGE_SIZE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
