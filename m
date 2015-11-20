Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id AB58E6B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 17:26:41 -0500 (EST)
Received: by wmww144 with SMTP id w144so38428234wmw.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 14:26:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pj7si2424163wjb.131.2015.11.20.14.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 14:26:40 -0800 (PST)
Date: Fri, 20 Nov 2015 14:26:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] mm: hugetlb: fix hugepage memory leak caused by
 wrong reserve count
Message-Id: <20151120142638.c505927a43dc1ede32570db0@linux-foundation.org>
In-Reply-To: <050201d12369$167a0a10$436e1e30$@alibaba-inc.com>
References: <1448004017-23679-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<050201d12369$167a0a10$436e1e30$@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'David Rientjes' <rientjes@google.com>, 'Dave Hansen' <dave.hansen@intel.com>, 'Mel Gorman' <mgorman@suse.de>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>

On Fri, 20 Nov 2015 15:57:21 +0800 "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:

> > 
> > When dequeue_huge_page_vma() in alloc_huge_page() fails, we fall back to
> > alloc_buddy_huge_page() to directly create a hugepage from the buddy allocator.
> > In that case, however, if alloc_buddy_huge_page() succeeds we don't decrement
> > h->resv_huge_pages, which means that successful hugetlb_fault() returns without
> > releasing the reserve count. As a result, subsequent hugetlb_fault() might fail
> > despite that there are still free hugepages.
> > 
> > This patch simply adds decrementing code on that code path.
> > 
> > I reproduced this problem when testing v4.3 kernel in the following situation:
> > - the test machine/VM is a NUMA system,
> > - hugepage overcommiting is enabled,
> > - most of hugepages are allocated and there's only one free hugepage
> >   which is on node 0 (for example),
> > - another program, which calls set_mempolicy(MPOL_BIND) to bind itself to
> >   node 1, tries to allocate a hugepage,
> > - the allocation should fail but the reserve count is still hold.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: <stable@vger.kernel.org> [3.16+]
> > ---
> > - the reason why I set stable target to "3.16+" is that this patch can be
> >   applied easily/automatically on these versions. But this bug seems to be
> >   old one, so if you are interested in backporting to older kernels,
> >   please let me know.
> > ---
> >  mm/hugetlb.c |    5 ++++-
> >  1 files changed, 4 insertions(+), 1 deletions(-)
> > 
> > diff --git v4.3/mm/hugetlb.c v4.3_patched/mm/hugetlb.c
> > index 9cc7734..77c518c 100644
> > --- v4.3/mm/hugetlb.c
> > +++ v4.3_patched/mm/hugetlb.c
> > @@ -1790,7 +1790,10 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
> >  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> >  		if (!page)
> >  			goto out_uncharge_cgroup;
> > -
> > +		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
> > +			SetPagePrivate(page);
> > +			h->resv_huge_pages--;
> > +		}
> 
> I am wondering if this patch was prepared against the next tree.

It's against 4.3.

Here's the version I have, against current -linus:

--- a/mm/hugetlb.c~mm-hugetlb-fix-hugepage-memory-leak-caused-by-wrong-reserve-count
+++ a/mm/hugetlb.c
@@ -1886,7 +1886,10 @@ struct page *alloc_huge_page(struct vm_a
 		page = __alloc_buddy_huge_page_with_mpol(h, vma, addr);
 		if (!page)
 			goto out_uncharge_cgroup;
-
+		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
+			SetPagePrivate(page);
+			h->resv_huge_pages--;
+		}
 		spin_lock(&hugetlb_lock);
 		list_move(&page->lru, &h->hugepage_activelist);
 		/* Fall through */

It needs a careful re-review and, preferably, retest please.

Probably when Greg comes to merge this he'll hit problems and we'll
need to provide him with the against-4.3 patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
