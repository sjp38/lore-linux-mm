Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E65CB6B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 11:26:00 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH bugfix] proc/pagemap: correctly report non-present ptes and holes between vmas
Date: Mon, 30 Apr 2012 11:25:42 -0400
Message-Id: <1335799542-8159-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120428162229.15658.56316.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khlebnikov@openvz.org
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@linux.intel.com, xemul@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi,

On Sat, Apr 28, 2012 at 08:22:30PM +0400, Konstantin Khlebnikov wrote:
> This patch resets current pagemap-entry if current pte isn't present,
> or if current vma is over. Otherwise pagemap reports last entry again and again.
> 
> non-present pte reporting was broken in commit v3.3-3738-g092b50b
> ("pagemap: introduce data structure for pagemap entry")
> 
> reporting for holes was broken in commit v3.3-3734-g5aaabe8
> ("pagemap: avoid splitting thp when reading /proc/pid/pagemap")
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Reported-by: Pavel Emelyanov <xemul@parallels.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andi Kleen <ak@linux.intel.com>

Thanks for your efforts.
I confirmed that this patch fixes the problem on v3.4-rc4.
But originally (before the commits you pointed to above) initializing
pagemap entries (originally labelled with confusing 'pfn') were done
in for-loop in pagemap_pte_range(), so I think it's better to get it
back to things like that.

How about the following?
---
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2b9a760..538f8d8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -779,13 +779,14 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
-	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
+	pagemap_entry_t pme;
 
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
 	if (pmd_trans_huge_lock(pmd, vma) == 1) {
 		for (; addr != end; addr += PAGE_SIZE) {
 			unsigned long offset;
+			pme = make_pme(PM_NOT_PRESENT);
 
 			offset = (addr & ~PAGEMAP_WALK_MASK) >>
 					PAGE_SHIFT;
@@ -801,6 +802,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	if (pmd_trans_unstable(pmd))
 		return 0;
 	for (; addr != end; addr += PAGE_SIZE) {
+		pme = make_pme(PM_NOT_PRESENT);
 
 		/* check to see if we've left 'vma' behind
 		 * and need a new, higher one */
@@ -842,10 +844,10 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 {
 	struct pagemapread *pm = walk->private;
 	int err = 0;
-	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
 
 	for (; addr != end; addr += PAGE_SIZE) {
 		int offset = (addr & ~hmask) >> PAGE_SHIFT;
+		pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
 		huge_pte_to_pagemap_entry(&pme, *pte, offset);
 		err = add_to_pagemap(addr, &pme, pm);
 		if (err)

---
Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
