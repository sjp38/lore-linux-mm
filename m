Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 808BF6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 03:58:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so6007248wmw.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 00:58:18 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id kd6si1985439wjc.113.2016.05.17.00.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 00:58:16 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r12so2533119wme.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 00:58:16 -0700 (PDT)
Date: Tue, 17 May 2016 09:58:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch added to
 -mm tree
Message-ID: <20160517075815.GC14453@dhcp22.suse.cz>
References: <57212c60.fUSE244UFwhXE+az%akpm@linux-foundation.org>
 <20160428151921.GL31489@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428151921.GL31489@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ebru.akagunduz@gmail.com, aarcange@redhat.com, aneesh.kumar@linux.vnet.ibm.com, boaz@plexistor.com, gorcunov@openvz.org, hannes@cmpxchg.org, hughd@google.com, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, riel@redhat.com, rientjes@google.com, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu 28-04-16 17:19:21, Michal Hocko wrote:
> On Wed 27-04-16 14:17:20, Andrew Morton wrote:
> [...]
> > @@ -2484,7 +2485,14 @@ static void collapse_huge_page(struct mm
> >  		goto out;
> >  	}
> >  
> > -	__collapse_huge_page_swapin(mm, vma, address, pmd);
> > +	swap = get_mm_counter(mm, MM_SWAPENTS);
> > +	curr_allocstall = sum_vm_event(ALLOCSTALL);
> > +	/*
> > +	 * When system under pressure, don't swapin readahead.
> > +	 * So that avoid unnecessary resource consuming.
> > +	 */
> > +	if (allocstall == curr_allocstall && swap != 0)
> > +		__collapse_huge_page_swapin(mm, vma, address, pmd);
> >  
> >  	anon_vma_lock_write(vma->anon_vma);
> >  
> 
> I have mentioned that before already but this seems like a rather weak
> heuristic. Don't we really rather teach __collapse_huge_page_swapin
> (resp. do_swap_page) do to an optimistic GFP_NOWAIT allocations and
> back off under the memory pressure?

I gave it a try and it doesn't seem really bad. Untested and I might
have missed something really obvious but what do you think about this
approach rather than relying on ALLOCSTALL which is really weak
heuristic:
---
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87f09dc986ab..1a4d4c807d92 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2389,7 +2389,8 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
 		swapped_in++;
 		ret = do_swap_page(mm, vma, _address, pte, pmd,
 				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
-				   pteval);
+				   pteval,
+				   GFP_HIGHUSER_MOVABLE | ~__GFP_DIRECT_RECLAIM);
 		if (ret & VM_FAULT_ERROR) {
 			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
 			return;
diff --git a/mm/memory.c b/mm/memory.c
index d79c6db41502..f897ec89bd79 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2490,7 +2490,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
  */
 int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+		unsigned int flags, pte_t orig_pte, gfp_t gfp_mask)
 {
 	spinlock_t *ptl;
 	struct page *page, *swapcache;
@@ -2519,8 +2519,7 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry);
 	if (!page) {
-		page = swapin_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vma, address);
+		page = swapin_readahead(entry, gfp_mask, vma, address);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
@@ -2573,7 +2572,7 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_page;
 	}
 
-	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg, false)) {
+	if (mem_cgroup_try_charge(page, mm, gfp_mask, &memcg, false)) {
 		ret = VM_FAULT_OOM;
 		goto out_page;
 	}
@@ -3349,7 +3348,7 @@ static int handle_pte_fault(struct mm_struct *mm,
 						flags, entry);
 		}
 		return do_swap_page(mm, vma, address,
-					pte, pmd, flags, entry);
+					pte, pmd, flags, entry, GFP_HIGHUSER_MOVABLE);
 	}
 
 	if (pte_protnone(entry))
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
