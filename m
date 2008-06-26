Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5Q9TL8t018240
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:29:21 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5Q9TKvX221346
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:29:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5Q9TKI9014329
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:29:20 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 26 Jun 2008 14:59:18 +0530
Message-Id: <20080626092918.16841.74883.sendpatchset@balbir-laptop>
In-Reply-To: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
References: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
Subject: [5/5] memrlimit correct mremap and move_vma accounting
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


The memrlimit patches did not account for move_vma() since we account for
address space usage in do_mremap(). The code flow actually increments
total_vm twice (once in do_mremap() and once in move_vma()), the excess
is removed in remove_vma_list() via do_munmap(). Since we did not do the
duplicate accounting, the code was seeing the extra uncharge, causing
our accounting to break. This patch fixes the problem

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/mremap.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff -puN mm/mremap.c~memrlimit-fix-move-vma-accounting mm/mremap.c
--- linux-2.6.26-rc5/mm/mremap.c~memrlimit-fix-move-vma-accounting	2008-06-26 14:48:25.000000000 +0530
+++ linux-2.6.26-rc5-balbir/mm/mremap.c	2008-06-26 14:48:25.000000000 +0530
@@ -177,10 +177,15 @@ static unsigned long move_vma(struct vm_
 	if (mm->map_count >= sysctl_max_map_count - 3)
 		return -ENOMEM;
 
+	if (memrlimit_cgroup_charge_as(mm, new_len >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
 	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff);
-	if (!new_vma)
+	if (!new_vma) {
+		memrlimit_cgroup_uncharge_as(mm, new_len >> PAGE_SHIFT);
 		return -ENOMEM;
+	}
 
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len);
 	if (moved_len < old_len) {
@@ -386,6 +391,8 @@ unsigned long do_mremap(unsigned long ad
 		}
 	}
 
+	memrlimit_cgroup_uncharge_as(mm, (new_len - old_len) >> PAGE_SHIFT);
+
 	/*
 	 * We weren't able to just expand or shrink the area,
 	 * we need to create a new one and move it..
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
