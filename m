Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 55A2E6B003D
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:10:02 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so7168007wgh.5
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:10:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k7si3520296wic.54.2013.12.11.14.10.01
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:10:01 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 09/11] arch/powerpc/mm/subpage-prot.c: use walk_page_vma() instead of walk_page_range()
Date: Wed, 11 Dec 2013 17:09:05 -0500
Message-Id: <1386799747-31069-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386799747-31069-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1386799747-31069-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

We don't have to use mm_walk->private to pass vma to the callback
function because of mm_walk->vma.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/powerpc/mm/subpage-prot.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git v3.13-rc3-mmots-2013-12-10-16-38.orig/arch/powerpc/mm/subpage-prot.c v3.13-rc3-mmots-2013-12-10-16-38/arch/powerpc/mm/subpage-prot.c
index a770df2dae70..cec0af0a935f 100644
--- v3.13-rc3-mmots-2013-12-10-16-38.orig/arch/powerpc/mm/subpage-prot.c
+++ v3.13-rc3-mmots-2013-12-10-16-38/arch/powerpc/mm/subpage-prot.c
@@ -134,7 +134,7 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, struct mm_walk *walk)
 {
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	split_huge_page_pmd(vma, addr, pmd);
 	return 0;
 }
@@ -163,9 +163,7 @@ static void subpage_mark_vma_nohuge(struct mm_struct *mm, unsigned long addr,
 		if (vma->vm_start >= (addr + len))
 			break;
 		vma->vm_flags |= VM_NOHUGEPAGE;
-		subpage_proto_walk.private = vma;
-		walk_page_range(vma->vm_start, vma->vm_end,
-				&subpage_proto_walk);
+		walk_page_vma(vma, &subpage_proto_walk);
 		vma = vma->vm_next;
 	}
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
