Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 331AC6B003D
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 17:46:07 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ma3so1986518pbc.32
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 14:46:06 -0700 (PDT)
Received: from psmtp.com ([74.125.245.198])
        by mx.google.com with SMTP id je1si53690pbb.30.2013.10.30.14.46.05
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:46:06 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 09/11] arch/powerpc/mm/subpage-prot.c: use walk_page_vma() instead of walk_page_range()
Date: Wed, 30 Oct 2013 17:44:57 -0400
Message-Id: <1383169499-25144-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

We don't have to use mm_walk->private to pass vma to the callback
function, because mm_walk->vma is automatically set to the valid one.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/powerpc/mm/subpage-prot.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git v3.12-rc7-mmots-2013-10-29-16-24.orig/arch/powerpc/mm/subpage-prot.c v3.12-rc7-mmots-2013-10-29-16-24/arch/powerpc/mm/subpage-prot.c
index a770df2d..cec0af0 100644
--- v3.12-rc7-mmots-2013-10-29-16-24.orig/arch/powerpc/mm/subpage-prot.c
+++ v3.12-rc7-mmots-2013-10-29-16-24/arch/powerpc/mm/subpage-prot.c
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
