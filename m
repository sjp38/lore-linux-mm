Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 835006B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 11:03:00 -0400 (EDT)
Received: by wixw10 with SMTP id w10so42418845wix.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:03:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gc3si4092676wib.61.2015.03.18.08.02.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 08:02:59 -0700 (PDT)
Date: Wed, 18 Mar 2015 16:02:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, memcg: sync allocation and memcg charge gfp flags
 for THP
Message-ID: <20150318150257.GL17241@dhcp22.suse.cz>
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz>
 <55098D0A.8090605@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55098D0A.8090605@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 18-03-15 15:34:50, Vlastimil Babka wrote:
> On 03/16/2015 03:08 PM, Michal Hocko wrote:
> >memcg currently uses hardcoded GFP_TRANSHUGE gfp flags for all THP
> >charges. THP allocations, however, might be using different flags
> >depending on /sys/kernel/mm/transparent_hugepage/{,khugepaged/}defrag
> >and the current allocation context.
> >
> >The primary difference is that defrag configured to "madvise" value will
> >clear __GFP_WAIT flag from the core gfp mask to make the allocation
> >lighter for all mappings which are not backed by VM_HUGEPAGE vmas.
> >If memcg charge path ignores this fact we will get light allocation but
> >the a potential memcg reclaim would kill the whole point of the
> >configuration.
> >
> >Fix the mismatch by providing the same gfp mask used for the
> >allocation to the charge functions. This is quite easy for all
> >paths except for hugepaged kernel thread with !CONFIG_NUMA which is
> >doing a pre-allocation long before the allocated page is used in
> >collapse_huge_page via khugepaged_alloc_page. To prevent from cluttering
> >the whole code path from khugepaged_do_scan we simply return the current
> >flags as per khugepaged_defrag() value which might have changed since
> >the preallocation. If somebody changed the value of the knob we would
> >charge differently but this shouldn't happen often and it is definitely
> >not critical because it would only lead to a reduced success rate of
> >one-off THP promotion.
> >
> >Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

[...]
> >@@ -1080,6 +1080,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	unsigned long haddr;
> >  	unsigned long mmun_start;	/* For mmu_notifiers */
> >  	unsigned long mmun_end;		/* For mmu_notifiers */
> >+	gfp_t huge_gfp = GFP_TRANSHUGE;	/* for allocation and charge */
> 
> This value is actually never used. Is it here because the compiler emits a
> spurious non-initialized value warning otherwise? It should be easy for it
> to prove that setting new_page to something non-null implies initializing
> huge_gfp (in the hunk below), and NULL new_page means it doesn't reach the
> mem_cgroup_try_charge() call?

No, I haven't tried to workaround the compiler. It just made the code
more obvious to me. I can remove the initialization if you prefer, of
course.

> >  	ptl = pmd_lockptr(mm, pmd);
> >  	VM_BUG_ON_VMA(!vma->anon_vma, vma);
> >@@ -1106,10 +1107,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  alloc:
> >  	if (transparent_hugepage_enabled(vma) &&
> >  	    !transparent_hugepage_debug_cow()) {
> >-		gfp_t gfp;
> >-
> >-		gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
> >-		new_page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
> >+		huge_gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
> >+		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
> >  	} else
> >  		new_page = NULL;
> >
> >@@ -1131,7 +1130,7 @@ alloc:
> >  	}
> >
> >  	if (unlikely(mem_cgroup_try_charge(new_page, mm,
> >-					   GFP_TRANSHUGE, &memcg))) {
> >+					   huge_gfp, &memcg))) {
> >  		put_page(new_page);
> >  		if (page) {
> >  			split_huge_page(page);
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
