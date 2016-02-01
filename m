Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 55A716B0009
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 17:28:37 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id x125so91400199pfb.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 14:28:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uf7si26747500pac.150.2016.02.01.14.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 14:28:36 -0800 (PST)
Date: Mon, 1 Feb 2016 14:28:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mempolicy: do not try to queue pages from
 !vma_migratable()
Message-Id: <20160201142835.d70538761c6d74bd989b6f8b@linux-foundation.org>
In-Reply-To: <1454333169-121369-3-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454333169-121369-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1454333169-121369-3-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon,  1 Feb 2016 16:26:09 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Maybe I miss some point, but I don't see a reason why we try to queue
> pages from non migratable VMAs.
> 
> The only case when we can queue pages from such VMA is MPOL_MF_STRICT
> plus MPOL_MF_MOVE or MPOL_MF_MOVE_ALL for VMA which has pages on LRU,
> but gfp mask is not sutable for migaration (see mapping_gfp_mask() check
> in vma_migratable()). That's looks like a bug to me.
> 
> Let's filter out non-migratable vma at start of queue_pages_test_walk()
> and go to queue_pages_pte_range() only if MPOL_MF_MOVE or
> MPOL_MF_MOVE_ALL flag is set.

Conflicts with
http://ozlabs.org/~akpm/mmots/broken-out/mm-mempolicy-skip-vm_hugetlb-and-vm_mixedmap-vma-for-lazy-mbind.patch.
I resolved it thusly, please review:

--- a/mm/mempolicy.c~mempolicy-do-not-try-to-queue-pages-from-vma_migratable
+++ a/mm/mempolicy.c
@@ -548,8 +548,7 @@ retry:
 			goto retry;
 		}
 
-		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-			migrate_page_add(page, qp->pagelist, flags);
+		migrate_page_add(page, qp->pagelist, flags);
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
@@ -625,7 +624,7 @@ static int queue_pages_test_walk(unsigne
 	unsigned long endvma = vma->vm_end;
 	unsigned long flags = qp->flags;
 
-	if (vma->vm_flags & VM_PFNMAP)
+	if (!vma_migratable(vma))
 		return 1;
 
 	if (endvma > end)
@@ -644,17 +643,15 @@ static int queue_pages_test_walk(unsigne
 
 	if (flags & MPOL_MF_LAZY) {
 		/* Similar to task_numa_work, skip inaccessible VMAs */
-		if (vma_migratable(vma) && !is_vm_hugetlb_page(vma) &&
+		if (!is_vm_hugetlb_page(vma) &&
 			(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)) &&
 			!(vma->vm_flags & VM_MIXEDMAP))
 			change_prot_numa(vma, start, endvma);
 		return 1;
 	}
 
-	if ((flags & MPOL_MF_STRICT) ||
-	    ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
-	     vma_migratable(vma)))
-		/* queue pages from current vma */
+	/* queue pages from current vma */
+	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 		return 0;
 	return 1;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
