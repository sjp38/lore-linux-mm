Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 625FB6B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 07:05:08 -0400 (EDT)
Received: by lbcao8 with SMTP id ao8so65159032lbc.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 04:05:07 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id p11si17828400wjw.192.2015.09.14.04.05.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 04:05:06 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so135555188wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 04:05:06 -0700 (PDT)
Date: Mon, 14 Sep 2015 14:05:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv10 37/36, RFC] thp: allow mlocked THP again
Message-ID: <20150914110504.GB8293@node.dhcp.inet.fi>
References: <1441293202-137314-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1441293388-137552-1-git-send-email-kirill.shutemov@linux.intel.com>
 <55F2D586.3040204@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55F2D586.3040204@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Sep 11, 2015 at 03:22:14PM +0200, Vlastimil Babka wrote:
> On 09/03/2015 05:16 PM, Kirill A. Shutemov wrote:
> >This patch brings back mlocked THP. Instead of forbidding mlocked pages
> >altogether, we just avoid mlocking PTE-mapped THPs and munlock THPs on
> >split_huge_pmd().
> >
> >This means PTE-mapped THPs will be on normal lru lists and will be
> >split under memory pressure by vmscan. After the split vmscan will
> >detect unevictable small pages and mlock them.
> 
> Yeah that sounds like a compromise that should work.
> 
> >This way we can void leaking mlocked pages into non-VM_LOCKED VMAs.
> 
>                  avoid
> 
> But mlocked page in non-mlocked VMA's is a normal thing for shared pages
> when only one of the sharing mm's did mlock(), right? So this description
> doesn't explain the whole issue. I admit I forgot the exact details already
> :(

Right. I'm as always bad on documentation.

Before THP refcounting rework, THP was not allowed to cross VMA boundary.
So, if we have THP and we split it, PG_mlocked can be safely transfered to
small pages.

With new THP refcounting and naive approach to mlocking we can end up with
this scenario:
 1. we have a mlocked THP, which belong to one VM_LOCKED VMA.
 2. the process does munlock() on the *part* of the THP:
      - the VMA is split into two, one of them VM_LOCKED;
      - huge PMD split into PTE table;
      - THP is still mlocked;
 3. split_huge_page():
      - it transfers PG_mlocked to *all* small pages regrardless if it
	blong to any VM_LOCKED VMA.

We probably could munlock() all small pages on split_huge_page(), but I
think we have accounting issue already on step two.

> >Not-Yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >---
> >
> >I'm not yet 100% certain that this approch is correct. Review would be appriciated.
> >More testing is required.
> >
> >---
> >  mm/gup.c         |  6 ++++--
> >  mm/huge_memory.c | 33 +++++++++++++++++++++++-------
> >  mm/memory.c      |  3 +--
> >  mm/mlock.c       | 61 +++++++++++++++++++++++++++++++++++++-------------------
> >  4 files changed, 71 insertions(+), 32 deletions(-)
> >
> >diff --git a/mm/gup.c b/mm/gup.c
> >index 70d65e4015a4..e95b0cb6ed81 100644
> >--- a/mm/gup.c
> >+++ b/mm/gup.c
> >@@ -143,6 +143,10 @@ retry:
> >  		mark_page_accessed(page);
> >  	}
> >  	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
> >+		/* Do not mlock pte-mapped THP */
> >+		if (PageTransCompound(page))
> >+			goto out;
> >+
> >  		/*
> >  		 * The preliminary mapping check is mainly to avoid the
> >  		 * pointless overhead of lock_page on the ZERO_PAGE
> >@@ -920,8 +924,6 @@ long populate_vma_page_range(struct vm_area_struct *vma,
> >  	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
> >  	if (vma->vm_flags & VM_LOCKONFAULT)
> >  		gup_flags &= ~FOLL_POPULATE;
> >-	if (vma->vm_flags & VM_LOCKED)
> >-		gup_flags |= FOLL_SPLIT;
> >  	/*
> >  	 * We want to touch writable mappings with a write fault in order
> >  	 * to break COW, except for shared mappings because these don't COW
> >diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> >index 2cc99f9096a8..d714de02473b 100644
> >--- a/mm/huge_memory.c
> >+++ b/mm/huge_memory.c
> >@@ -846,8 +846,6 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >
> >  	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
> >  		return VM_FAULT_FALLBACK;
> >-	if (vma->vm_flags & VM_LOCKED)
> >-		return VM_FAULT_FALLBACK;
> >  	if (unlikely(anon_vma_prepare(vma)))
> >  		return VM_FAULT_OOM;
> >  	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
> >@@ -1316,7 +1314,16 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
> >  			update_mmu_cache_pmd(vma, addr, pmd);
> >  	}
> >  	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
> >-		if (page->mapping && trylock_page(page)) {
> >+		/*
> >+		 * We don't mlock() pte-mapped THPs. This way we can avoid
> >+		 * leaking mlocked pages into non-VM_LOCKED VMAs.
> >+		 * In most cases the pmd is the only mapping of the page: we
> >+		 * break COW for the mlock(). The only scenario when we have
> 
> I don't understand what's meant by "we break COW for the mlock()"?

mm/gup.c:

 880 long populate_vma_page_range(struct vm_area_struct *vma,                   
 881                 unsigned long start, unsigned long end, int *nonblocking)  
.....
 894         /*                                                                 
 895          * We want to touch writable mappings with a write fault in order  
 896          * to break COW, except for shared mappings because these don't COW
 897          * and we would not want to dirty them for nothing.                
 898          */                                                                
 899         if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)          
 900                 gup_flags |= FOLL_WRITE;                                   


> >+		 * the page shared here is if we mlocking read-only mapping
> >+		 * shared over fork(). We skip mlocking such pages.
> 
> Why do we skip them? There's no PTE mapping involved, just multiple PMD
> mappings? Why are those a problem?

We don't have a way to protect against parallel split_huge_pmd(). :(

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
