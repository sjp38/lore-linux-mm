Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E52E56B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 07:01:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 10so9176708wml.4
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 04:01:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i22si19398696ede.98.2017.06.01.04.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 04:00:59 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v51AwoaK003784
	for <linux-mm@kvack.org>; Thu, 1 Jun 2017 07:00:57 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2atenssuap-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:00:57 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 1 Jun 2017 12:00:55 +0100
Date: Thu, 1 Jun 2017 14:00:48 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530145632.GL7969@dhcp22.suse.cz>
 <20170530160610.GC8412@redhat.com>
 <e371b76b-d091-72d0-16c3-5227820595f0@suse.cz>
 <20170531082414.GB27783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531082414.GB27783@dhcp22.suse.cz>
Message-Id: <20170601110048.GE30495@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, May 31, 2017 at 10:24:14AM +0200, Michal Hocko wrote:
> On Wed 31-05-17 08:30:08, Vlastimil Babka wrote:
> > On 05/30/2017 06:06 PM, Andrea Arcangeli wrote:
> > > 
> > > I'm not sure if it should be considered a bug, the prctl is intended
> > > to use normally by wrappers so it looks optimal as implemented this
> > > way: affecting future vmas only, which will all be created after
> > > execve executed by the wrapper.
> > > 
> > > What's the point of messing with the prctl so it mangles over the
> > > wrapper process own vmas before exec? Messing with those vmas is pure
> > > wasted CPUs for the wrapper use case which is what the prctl was
> > > created for.
> > > 
> > > Furthermore there would be the risk a program that uses the prctl not
> > > as a wrapper and then calls the prctl to clear VM_NOHUGEPAGE from
> > > def_flags assuming the current kABI. The program could assume those
> > > vmas that were instantiated before disabling the prctl are still with
> > > VM_NOHUGEPAGE set (they would not after the change you propose).
> > > 
> > > Adding a scan of all vmas to PR_SET_THP_DISABLE to clear VM_NOHUGEPAGE
> > > on existing vmas looks more complex too and less finegrined so
> > > probably more complex for userland to manage
> > 
> > I would expect the prctl wouldn't iterate all vma's, nor would it modify
> > def_flags anymore. It would just set a flag somewhere in mm struct that
> > would be considered in addition to the per-vma flags when deciding
> > whether to use THP.
> 
> Exactly. Something like the below (not even compile tested).
 
I did a quick go with the patch, compiles just fine :)
It worked for my simple examples, the THP is enabled/disabled as expected
and the vma->vm_flags are indeed unaffected.

> > We could consider whether MADV_HUGEPAGE should be
> > able to override the prctl or not.
> 
> This should be a master override to any per vma setting.

Here you've introduced a change to the current behaviour. Consider the
following sequence:

{
	prctl(PR_SET_THP_DISABLE);
	address = mmap(...);
	madvise(address, len, MADV_HUGEPAGE);
}

Currently, for the vma that backs the address
transparent_hugepage_enabled(vma) will return true, and after your patch it
will return false.
The new behaviour may be more correct, I just wanted to bring the change to
attention. 
 
> ---
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index a3762d49ba39..9da053ced864 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -92,6 +92,7 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>  	   (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
>  	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
>  	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
> +	 !test_bit(MMF_DISABLE_THP, &(__vma)->vm_mm->flags) &&		\
>  	 !is_vma_temporary_stack(__vma))
>  #define transparent_hugepage_use_zero_page()				\
>  	(transparent_hugepage_flags &					\
> diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
> index 5d9a400af509..f0d7335336cd 100644
> --- a/include/linux/khugepaged.h
> +++ b/include/linux/khugepaged.h
> @@ -48,7 +48,8 @@ static inline int khugepaged_enter(struct vm_area_struct *vma,
>  	if (!test_bit(MMF_VM_HUGEPAGE, &vma->vm_mm->flags))
>  		if ((khugepaged_always() ||
>  		     (khugepaged_req_madv() && (vm_flags & VM_HUGEPAGE))) &&
> -		    !(vm_flags & VM_NOHUGEPAGE))
> +		    !(vm_flags & VM_NOHUGEPAGE) &&
> +		    !test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>  			if (__khugepaged_enter(vma->vm_mm))
>  				return -ENOMEM;
>  	return 0;
> diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
> index 69eedcef8f03..2c07b244090a 100644
> --- a/include/linux/sched/coredump.h
> +++ b/include/linux/sched/coredump.h
> @@ -68,6 +68,7 @@ static inline int get_dumpable(struct mm_struct *mm)
>  #define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
>  #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
>  #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
> +#define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
> 
>  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 8a94b4eabcaa..e48f0636c7fd 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2266,7 +2266,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>  	case PR_GET_THP_DISABLE:
>  		if (arg2 || arg3 || arg4 || arg5)
>  			return -EINVAL;
> -		error = !!(me->mm->def_flags & VM_NOHUGEPAGE);
> +		error = !!test_bit(MMF_DISABLE_THP, &me->mm->flags);
>  		break;
>  	case PR_SET_THP_DISABLE:
>  		if (arg3 || arg4 || arg5)
> @@ -2274,9 +2274,9 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>  		if (down_write_killable(&me->mm->mmap_sem))
>  			return -EINTR;
>  		if (arg2)
> -			me->mm->def_flags |= VM_NOHUGEPAGE;
> +			set_bit(MMF_DISABLE_THP, &me->mm->flags);
>  		else
> -			me->mm->def_flags &= ~VM_NOHUGEPAGE;
> +			clear_bit(MMF_DISABLE_THP, &me->mm->flags);
>  		up_write(&me->mm->mmap_sem);
>  		break;
>  	case PR_MPX_ENABLE_MANAGEMENT:
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index ce29e5cc7809..57e31f4752b3 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -818,7 +818,8 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
>  static bool hugepage_vma_check(struct vm_area_struct *vma)
>  {
>  	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
> -	    (vma->vm_flags & VM_NOHUGEPAGE))
> +	    (vma->vm_flags & VM_NOHUGEPAGE) ||
> +	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>  		return false;
>  	if (shmem_file(vma->vm_file)) {
>  		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
> diff --git a/mm/shmem.c b/mm/shmem.c
> index e67d6ba4e98e..27fe1bbf813b 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1977,10 +1977,11 @@ static int shmem_fault(struct vm_fault *vmf)
>  	}
> 
>  	sgp = SGP_CACHE;
> -	if (vma->vm_flags & VM_HUGEPAGE)
> -		sgp = SGP_HUGE;
> -	else if (vma->vm_flags & VM_NOHUGEPAGE)
> +	
> +	if ((vma->vm_flags & VM_NOHUGEPAGE) || test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>  		sgp = SGP_NOHUGE;
> +	else if (vma->vm_flags & VM_HUGEPAGE)
> +		sgp = SGP_HUGE;
> 
>  	error = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, sgp,
>  				  gfp, vma, vmf, &ret);
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
