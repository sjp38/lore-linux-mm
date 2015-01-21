Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id A97516B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 19:48:35 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id w7so13491593qcr.10
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 16:48:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 8si2590554qaq.29.2015.01.20.16.48.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jan 2015 16:48:34 -0800 (PST)
Date: Tue, 20 Jan 2015 16:48:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4] mm/thp: Allocate transparent hugepages on local node
Message-Id: <20150120164832.abe2e47b760e1a8d7bb6055b@linux-foundation.org>
In-Reply-To: <1421753671-16793-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1421753671-16793-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 20 Jan 2015 17:04:31 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> This make sure that we try to allocate hugepages from local node if
> allowed by mempolicy. If we can't, we fallback to small page allocation
> based on mempolicy. This is based on the observation that allocating pages
> on local node is more beneficial than allocating hugepages on remote
> node.
> 
> With this patch applied we may find transparent huge page allocation
> failures if the current node doesn't have enough freee hugepages.
> Before this patch such failures result in us retrying the allocation on
> other nodes in the numa node mask.
> 
>  
>  /**
> + * alloc_hugepage_vma: Allocate a hugepage for a VMA
> + * @gfp:
> + *   %GFP_USER	  user allocation.
> + *   %GFP_KERNEL  kernel allocations,
> + *   %GFP_HIGHMEM highmem/user allocations,
> + *   %GFP_FS	  allocation should not call back into a file system.
> + *   %GFP_ATOMIC  don't sleep.
> + *
> + * @vma:   Pointer to VMA or NULL if not available.
> + * @addr:  Virtual Address of the allocation. Must be inside the VMA.
> + * @order: Order of the hugepage for gfp allocation.
> + *
> + * This functions allocate a huge page from the kernel page pool and applies
> + * a NUMA policy associated with the VMA or the current process.
> + * For policy other than %MPOL_INTERLEAVE, we make sure we allocate hugepage
> + * only from the current node if the current node is part of the node mask.
> + * If we can't allocate a hugepage we fail the allocation and don' try to fallback
> + * to other nodes in the node mask. If the current node is not part of node mask
> + * or if the NUMA policy is MPOL_INTERLEAVE we use the allocator that can
> + * fallback to nodes in the policy node mask.
> + *
> + * When VMA is not NULL caller must hold down_read on the mmap_sem of the
> + * mm_struct of the VMA to prevent it from going away. Should be used for
> + * all allocations for pages that will be mapped into
> + * user space. Returns NULL when no page can be allocated.
> + *
> + * Should be called with the mm_sem of the vma hold.

That's a pretty cruddy sentence, isn't it?  Copied from
alloc_pages_vma().  "vma->vm_mm->mmap_sem" would be better.

And it should tell us whether mmap_sem required a down_read or a
down_write.  What purpose is it serving?

> + *
> + */
> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
> +				unsigned long addr, int order)

This pointlessly bloats the kernel if CONFIG_TRANSPARENT_HUGEPAGE=n?



--- a/mm/mempolicy.c~mm-thp-allocate-transparent-hugepages-on-local-node-fix
+++ a/mm/mempolicy.c
@@ -2030,6 +2030,7 @@ retry_cpuset:
 	return page;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /**
  * alloc_hugepage_vma: Allocate a hugepage for a VMA
  * @gfp:
@@ -2057,7 +2058,7 @@ retry_cpuset:
  * all allocations for pages that will be mapped into
  * user space. Returns NULL when no page can be allocated.
  *
- * Should be called with the mm_sem of the vma hold.
+ * Should be called with vma->vm_mm->mmap_sem held.
  *
  */
 struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
@@ -2099,6 +2100,7 @@ alloc_with_fallback:
 	 */
 	return alloc_pages_vma(gfp, order, vma, addr, node);
 }
+#endif
 
 /**
  * 	alloc_pages_current - Allocate pages.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
