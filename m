Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 49BD06B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:11:45 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so8076660pdi.19
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:11:44 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so8066046pdj.4
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:11:42 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:11:38 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCH 01/12] mm, thp, tmpfs: add function to alloc huge page for
 tmpfs
Message-ID: <20131015001138.GB3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

Add function to alloc huge page for tmpfs when needed.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8297623..a857ba8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -949,6 +949,28 @@ static struct page *shmem_alloc_page(gfp_t gfp,
 
 	return page;
 }
+
+static struct page *shmem_alloc_hugepage(gfp_t gfp,
+			struct shmem_inode_info *info, pgoff_t index)
+{
+	struct vm_area_struct pvma;
+	struct page *page;
+
+	/* Create a pseudo vma that just contains the policy */
+	pvma.vm_start = 0;
+	pvma.vm_pgoff = index;
+	pvma.vm_ops = NULL;
+	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+	pvma.vm_flags = VM_HUGEPAGE;
+
+	page = alloc_hugepage_vma(transparent_hugepage_defrag(&pvma), &pvma,
+					0, numa_node_id(), gfp);
+
+	/* Drop reference taken by mpol_shared_policy_lookup() */
+	mpol_cond_put(pvma.vm_policy);
+
+	return page;
+}
 #else /* !CONFIG_NUMA */
 #ifdef CONFIG_TMPFS
 static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
@@ -967,6 +989,13 @@ static inline struct page *shmem_alloc_page(gfp_t gfp,
 {
 	return alloc_page(gfp);
 }
+
+static inline struct page *shmem_alloc_hugepage(gfp_t gfp,
+			struct shmem_inode_info *info, pgoff_t index)
+{
+	BUG();
+	return NULL;
+}
 #endif /* CONFIG_NUMA */
 
 #if !defined(CONFIG_NUMA) || !defined(CONFIG_TMPFS)
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
