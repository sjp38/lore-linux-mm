Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A22648D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 17:21:38 -0400 (EDT)
Date: Fri, 1 Apr 2011 23:21:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp+memcg-numa: fix BUG at include/linux/mm.h:370!
Message-ID: <20110401212132.GQ12265@random.random>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
 <20110314155232.GB10696@random.random>
 <alpine.LSU.2.00.1103140910570.2601@sister.anvils>
 <AANLkTikvt+o+UaksmvM5C7FWt7hTMJyaPiUGhQ+6OKBg@mail.gmail.com>
 <20110314171730.GF10696@random.random>
 <20110314195823.GC2140@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110314195823.GC2140@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>

On Mon, Mar 14, 2011 at 08:58:23PM +0100, Johannes Weiner wrote:
> We don't care about the vma.  It's all about assigning the physical
> page to the memcg that mm->owner belongs to.
> 
> It would be the first callsite not holding the mmap_sem, but that is
> only because all existing sites are fault handlers that don't drop the
> lock for other reasons.

I was afraid it'd be the first callsite this is why I wasn't excited
to push it in 2.6.38, but Linus's right and we should micro-optimize
it for 2.6.39.

> I am not aware of anything that would rely on the lock in there, or
> would not deserve to break if it did.

Thanks for double checking.

What about this? (only problem is the thp-vmstat patch in -mm then
reject, maybe I should rediff it against -mm instead, as you wish)

===
Subject: thp: optimize memcg charge in khugepaged

From: Andrea Arcangeli <aarcange@redhat.com>

We don't need to hold the mmmap_sem through mem_cgroup_newpage_charge(), the
mmap_sem is only hold for keeping the vma stable and we don't need the vma
stable anymore after we return from alloc_hugepage_vma().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0a619e0..c61d9ad 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1762,12 +1762,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 #ifndef CONFIG_NUMA
+	up_read(&mm->mmap_sem);
 	VM_BUG_ON(!*hpage);
 	new_page = *hpage;
-	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
-		up_read(&mm->mmap_sem);
-		return;
-	}
 #else
 	VM_BUG_ON(*hpage);
 	/*
@@ -1782,20 +1779,20 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	new_page = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
 				      node, __GFP_OTHER_NODE);
+	/* after allocating the hugepage upgrade to mmap_sem write mode */
+	up_read(&mm->mmap_sem);
 	if (unlikely(!new_page)) {
-		up_read(&mm->mmap_sem);
 		*hpage = ERR_PTR(-ENOMEM);
 		return;
 	}
+#endif
+
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
-		up_read(&mm->mmap_sem);
+#ifdef CONFIG_NUMA
 		put_page(new_page);
+#endif
 		return;
 	}
-#endif
-
-	/* after allocating the hugepage upgrade to mmap_sem write mode */
-	up_read(&mm->mmap_sem);
 
 	/*
 	 * Prevent all access to pagetables with the exception of

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
