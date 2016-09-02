Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4729F6B0038
	for <linux-mm@kvack.org>; Fri,  2 Sep 2016 08:50:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so14405784wmu.3
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 05:50:39 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id q9si11267043wjv.176.2016.09.02.05.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Sep 2016 05:50:37 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id v143so29717348wmv.0
        for <linux-mm@kvack.org>; Fri, 02 Sep 2016 05:50:37 -0700 (PDT)
Date: Fri, 2 Sep 2016 15:50:25 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: mm: use-after-free in collapse_huge_page
Message-ID: <20160902125025.GA5827@gmail.com>
References: <CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com>
 <20160829124233.GA40092@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160829124233.GA40092@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: dvyukov@google.com, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, vegard.nossum@oracle.com, levinsasha928@gmail.com, koct9i@gmail.com, ryabinin.a.a@gmail.com, gthelen@google.com, suleiman@google.com, hughd@google.com, rientjes@google.com, syzkaller@googlegroups.com, kcc@google.com, glider@google.com

>  
> @@ -898,13 +899,13 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
>  		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
>  		if (ret & VM_FAULT_RETRY) {
>  			down_read(&mm->mmap_sem);
> -			if (hugepage_vma_revalidate(mm, address)) {
> +			if (hugepage_vma_revalidate(mm, address, &vma)) {
>  				/* vma is no longer available, don't continue to swapin */
>  				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
>  				return false;
>  			}
>  			/* check if the pmd is still valid */
> -			if (mm_find_pmd(mm, address) != pmd)
> +			if (mm_find_pmd(mm, address) != pmd || vma != fe.vma)
>  				return false;
>  		}
>  		if (ret & VM_FAULT_ERROR) {
> @@ -923,7 +924,6 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
>  static void collapse_huge_page(struct mm_struct *mm,
>  				   unsigned long address,
>  				   struct page **hpage,
> -				   struct vm_area_struct *vma,
>  				   int node, int referenced)
>  {
>  	pmd_t *pmd, _pmd;
> @@ -933,6 +933,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	spinlock_t *pmd_ptl, *pte_ptl;
>  	int isolated = 0, result = 0;
>  	struct mem_cgroup *memcg;
> +	struct vm_area_struct *vma;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
I could not realize, why we need to remove vma parameter and recreate it here?
>  	unsigned long mmun_end;		/* For mmu_notifiers */
>  	gfp_t gfp;
> @@ -961,7 +962,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	}
>  
>  	down_read(&mm->mmap_sem);
And without fe.vma check, this patch seems work for me.

Andrea, I've just sent a fix patch for leaking mapped ptes.

Kind regards,
Ebru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
