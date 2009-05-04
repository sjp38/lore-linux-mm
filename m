Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 734D46B009A
	for <linux-mm@kvack.org>; Mon,  4 May 2009 09:15:48 -0400 (EDT)
Date: Mon, 4 May 2009 15:13:59 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3 v2] mm: introduce follow_pfn()
Message-ID: <20090504131359.GA17887@cmpxchg.org>
References: <20090501181449.GA8912@cmpxchg.org> <1241430874-12667-3-git-send-email-hannes@cmpxchg.org> <20090504110841.GA19646@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090504110841.GA19646@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Analoguous to follow_phys(), add a helper that looks up the PFN at a
user virtual address in an IO mapping or a raw PFN mapping.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm.h |    2 ++
 mm/memory.c        |   29 +++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

On Mon, May 04, 2009 at 07:08:41AM -0400, Christoph Hellwig wrote:
> On Mon, May 04, 2009 at 11:54:34AM +0200, Johannes Weiner wrote:
> > Analoguous to follow_phys(), add a helper that looks up the PFN
> > instead.  It also only allows IO mappings or PFN mappings.
> 
> A kerneldoc describing what it does and the limitations would be
> extremly helpful.

Agreed.  How is this?

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
index c047950..f86aee1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3046,6 +3046,35 @@ out:
 	return -EINVAL;
 }
 
+/**
+ * follow_pfn - look up PFN at a user virtual address
+ * @vma: memory mapping
+ * @address: user virtual address
+ * @pfn: location to store found PFN
+ *
+ * Only IO mappings and raw PFN mappings are allowed.
+ *
+ * Returns zero and the pfn at @pfn on success, -ve otherwise.
+ */
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
