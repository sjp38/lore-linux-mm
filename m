Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EEC556B006A
	for <linux-mm@kvack.org>; Mon,  4 May 2009 05:55:32 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: introduce follow_pfn()
Date: Mon,  4 May 2009 11:54:34 +0200
Message-Id: <1241430874-12667-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <20090501181449.GA8912@cmpxchg.org>
References: <20090501181449.GA8912@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Analoguous to follow_phys(), add a helper that looks up the PFN
instead.  It also only allows IO mappings or PFN mappings.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm.h |    2 ++
 mm/memory.c        |   19 +++++++++++++++++++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bff1f0d..1cca8b6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -794,6 +794,8 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
+int follow_pfn(struct vm_area_struct *vma, unsigned long address,
+	unsigned long *pfn);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags, unsigned long *prot, resource_size_t *phys);
 int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index aee167d..05fc8e5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3046,6 +3046,25 @@ out:
 	return -EINVAL;
 }
 
+int follow_pfn(struct vm_area_struct *vma, unsigned long address,
+	unsigned long *pfn)
+{
+	int ret = -EINVAL;
+	spinlock_t *ptl;
+	pte_t *ptep;
+
+	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP)))
+		return ret;
+
+	ret = follow_pte(vma->vm_mm, address, &ptep, &ptl);
+	if (ret)
+		return ret;
+	*pfn = pte_pfn(*ptep);
+	pte_unmap_unlock(ptep, ptl);
+	return 0;
+}
+EXPORT_SYMBOL(follow_pfn);
+
 #ifdef CONFIG_HAVE_IOREMAP_PROT
 int follow_phys(struct vm_area_struct *vma,
 		unsigned long address, unsigned int flags,
-- 
1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
