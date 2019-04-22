Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96980C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 21:26:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15B6A20643
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 21:26:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15B6A20643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 892546B0003; Mon, 22 Apr 2019 17:26:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 843466B0006; Mon, 22 Apr 2019 17:26:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E2A16B0007; Mon, 22 Apr 2019 17:26:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 436886B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 17:26:34 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id c22so2624412qtk.10
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:26:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mnDf9tkg+MN5hzkgUIK8ikPN8J68N/iBqziyFFi86cY=;
        b=XYvrXK+E6o300shOV0qhtkqHP4zuKHFowmXSj01IQeP6KSHnxZ6z4XOLi3hqy/53vW
         EzU5y0QlyGLwdakb92Oe9Uw7n16Q8ZGmDX4qUokhgTcuaJgzDrLGqWsv4N6mg1IZsf7A
         7IryvIGLAYncalo9jXN/cJMK0MfQV2WiSkuCf/kpNbv7aY14w4KSlDMnmV4kP9VP4kjx
         KH5cQpSiUxnI7SX+RCagI990b8+CAVR358snr5r61XNVV6uzN5FOP95Zt9FQWKrxycw5
         NpVro1zzuAdO3DjCKDFhnGU6StbzL7S7F+dEcIap09ze81mYGNTkFrJvKf1abPunj3JZ
         aNYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU6dnKRFVYp1RSY7ankYc4XaI8/CYeEg5DUk/hSB8HE4vQkXByB
	OV+5j9kmXXebe3vsmFAWJxT8sFXKfgTPI7UFbw3tFeAMtgJjMNUJoZNP/hby9bppqHv7oeOs1Ty
	Bxyx4r/8r1M7A3pZMFuvvAfF1KpuzmIS2ZQ2TgsCqNsNJFNkAAITTtPps3o5SaVhR8A==
X-Received: by 2002:ac8:2565:: with SMTP id 34mr17866204qtn.37.1555968393963;
        Mon, 22 Apr 2019 14:26:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4xX5glRNErS2tyFikLUW6gEJa14X5c+mjAi/DqfqZlUD4FGXkoa87jOBu7HIruH+x9/dx
X-Received: by 2002:ac8:2565:: with SMTP id 34mr17866076qtn.37.1555968391674;
        Mon, 22 Apr 2019 14:26:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555968391; cv=none;
        d=google.com; s=arc-20160816;
        b=TS8SH6Lec+WWrOFkaLAmbdtKdvYwTy4ONXoqW6wS8hbtE3N2NcKa1lnF5sgeg2KLhs
         DVI2rink0t8K55w+fhE0q5gtTBTDzSGZTeW6s0MT+r5roWZF4n9wmHVsFkr4i5y8mwWV
         Qq/gwnjD0tZtwrXnTVGbiyrCdhzOGuaMmcBKiDp4X5ZZ2WipEN7BWhxxT7ny+7Hp12G0
         7++zlT689PHFjxcBTeiIisEFfUNmGfyViKNl2GgL7sZodPYQ5YAesyKjnNwCerTPeYmq
         yjsOT+H60WIQ6IrM9NoHooHVi6Tm1FtuCdzfOd+6uWBNybIl2r0WTmSBbnqk8+sQGn6C
         JHSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mnDf9tkg+MN5hzkgUIK8ikPN8J68N/iBqziyFFi86cY=;
        b=NKDDgIlMJnMf1Mfpro3qF847qfbqI7RTff1W7CUAGVh9VhETplxleM2pbJ6Smla4/r
         fxYtqOxH0hgENIz5kVE1/D31Pd+Sezmr+jU1UBa5JVHqLFm/ui7DH6WhoZot42+6t27A
         EF+UPMXVuuBQs5rPHtwCVsOxUibpDkMm4wIJkwGl9aP+o3TvysiuUBub7kjosPfvaP8c
         gzCBzm3URZ+IaIwJW2St1w9BGzDlrLOZG0uwi++HKMpwOVY2ZdlqFv35sHYePqt0LQkh
         5dJzW1HDib11KqUWlnUGTns3ivlZaL5zS4pMaoiJyMo+O1H6Vpb/0acoQRpHBvvOx8KE
         BHhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r10si1727189qta.271.2019.04.22.14.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 14:26:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B81CF3084266;
	Mon, 22 Apr 2019 21:26:29 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 46D4D5D6A6;
	Mon, 22 Apr 2019 21:26:25 +0000 (UTC)
Date: Mon, 22 Apr 2019 17:26:23 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 22/31] mm: provide speculative fault infrastructure
Message-ID: <20190422212623.GM14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-23-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416134522.17540-23-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 22 Apr 2019 21:26:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:13PM +0200, Laurent Dufour wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> Provide infrastructure to do a speculative fault (not holding
> mmap_sem).
> 
> The not holding of mmap_sem means we can race against VMA
> change/removal and page-table destruction. We use the SRCU VMA freeing
> to keep the VMA around. We use the VMA seqcount to detect change
> (including umapping / page-table deletion) and we use gup_fast() style
> page-table walking to deal with page-table races.
> 
> Once we've obtained the page and are ready to update the PTE, we
> validate if the state we started the fault with is still valid, if
> not, we'll fail the fault with VM_FAULT_RETRY, otherwise we update the
> PTE and we're done.
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> 
> [Manage the newly introduced pte_spinlock() for speculative page
>  fault to fail if the VMA is touched in our back]
> [Rename vma_is_dead() to vma_has_changed() and declare it here]
> [Fetch p4d and pud]
> [Set vmd.sequence in __handle_mm_fault()]
> [Abort speculative path when handle_userfault() has to be called]
> [Add additional VMA's flags checks in handle_speculative_fault()]
> [Clear FAULT_FLAG_ALLOW_RETRY in handle_speculative_fault()]
> [Don't set vmf->pte and vmf->ptl if pte_map_lock() failed]
> [Remove warning comment about waiting for !seq&1 since we don't want
>  to wait]
> [Remove warning about no huge page support, mention it explictly]
> [Don't call do_fault() in the speculative path as __do_fault() calls
>  vma->vm_ops->fault() which may want to release mmap_sem]
> [Only vm_fault pointer argument for vma_has_changed()]
> [Fix check against huge page, calling pmd_trans_huge()]
> [Use READ_ONCE() when reading VMA's fields in the speculative path]
> [Explicitly check for __HAVE_ARCH_PTE_SPECIAL as we can't support for
>  processing done in vm_normal_page()]
> [Check that vma->anon_vma is already set when starting the speculative
>  path]
> [Check for memory policy as we can't support MPOL_INTERLEAVE case due to
>  the processing done in mpol_misplaced()]
> [Don't support VMA growing up or down]
> [Move check on vm_sequence just before calling handle_pte_fault()]
> [Don't build SPF services if !CONFIG_SPECULATIVE_PAGE_FAULT]
> [Add mem cgroup oom check]
> [Use READ_ONCE to access p*d entries]
> [Replace deprecated ACCESS_ONCE() by READ_ONCE() in vma_has_changed()]
> [Don't fetch pte again in handle_pte_fault() when running the speculative
>  path]
> [Check PMD against concurrent collapsing operation]
> [Try spin lock the pte during the speculative path to avoid deadlock with
>  other CPU's invalidating the TLB and requiring this CPU to catch the
>  inter processor's interrupt]
> [Move define of FAULT_FLAG_SPECULATIVE here]
> [Introduce __handle_speculative_fault() and add a check against
>  mm->mm_users in handle_speculative_fault() defined in mm.h]
> [Abort if vm_ops->fault is set instead of checking only vm_ops]
> [Use find_vma_rcu() and call put_vma() when we are done with the VMA]
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>


Few comments and questions for this one see below.


> ---
>  include/linux/hugetlb_inline.h |   2 +-
>  include/linux/mm.h             |  30 +++
>  include/linux/pagemap.h        |   4 +-
>  mm/internal.h                  |  15 ++
>  mm/memory.c                    | 344 ++++++++++++++++++++++++++++++++-
>  5 files changed, 389 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
> index 0660a03d37d9..9e25283d6fc9 100644
> --- a/include/linux/hugetlb_inline.h
> +++ b/include/linux/hugetlb_inline.h
> @@ -8,7 +8,7 @@
>  
>  static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
>  {
> -	return !!(vma->vm_flags & VM_HUGETLB);
> +	return !!(READ_ONCE(vma->vm_flags) & VM_HUGETLB);
>  }
>  
>  #else
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f761a9c65c74..ec609cbad25a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -381,6 +381,7 @@ extern pgprot_t protection_map[16];
>  #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
> +#define FAULT_FLAG_SPECULATIVE	0x200	/* Speculative fault, not holding mmap_sem */
>  
>  #define FAULT_FLAG_TRACE \
>  	{ FAULT_FLAG_WRITE,		"WRITE" }, \
> @@ -409,6 +410,10 @@ struct vm_fault {
>  	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
>  	pgoff_t pgoff;			/* Logical page offset based on vma */
>  	unsigned long address;		/* Faulting virtual address */
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	unsigned int sequence;
> +	pmd_t orig_pmd;			/* value of PMD at the time of fault */
> +#endif
>  	pmd_t *pmd;			/* Pointer to pmd entry matching
>  					 * the 'address' */
>  	pud_t *pud;			/* Pointer to pud entry matching
> @@ -1524,6 +1529,31 @@ int invalidate_inode_page(struct page *page);
>  #ifdef CONFIG_MMU
>  extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
>  			unsigned long address, unsigned int flags);
> +
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +extern vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
> +					     unsigned long address,
> +					     unsigned int flags);
> +static inline vm_fault_t handle_speculative_fault(struct mm_struct *mm,
> +						  unsigned long address,
> +						  unsigned int flags)
> +{
> +	/*
> +	 * Try speculative page fault for multithreaded user space task only.
> +	 */
> +	if (!(flags & FAULT_FLAG_USER) || atomic_read(&mm->mm_users) == 1)
> +		return VM_FAULT_RETRY;
> +	return __handle_speculative_fault(mm, address, flags);
> +}
> +#else
> +static inline vm_fault_t handle_speculative_fault(struct mm_struct *mm,
> +						  unsigned long address,
> +						  unsigned int flags)
> +{
> +	return VM_FAULT_RETRY;
> +}
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> +
>  extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>  			    unsigned long address, unsigned int fault_flags,
>  			    bool *unlocked);
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 2e8438a1216a..2fcfaa910007 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -457,8 +457,8 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>  	pgoff_t pgoff;
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		return linear_hugepage_index(vma, address);
> -	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
> -	pgoff += vma->vm_pgoff;
> +	pgoff = (address - READ_ONCE(vma->vm_start)) >> PAGE_SHIFT;
> +	pgoff += READ_ONCE(vma->vm_pgoff);
>  	return pgoff;
>  }
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index 1e368e4afe3c..ed91b199cb8c 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -58,6 +58,21 @@ static inline void put_vma(struct vm_area_struct *vma)
>  extern struct vm_area_struct *find_vma_rcu(struct mm_struct *mm,
>  					   unsigned long addr);
>  
> +
> +static inline bool vma_has_changed(struct vm_fault *vmf)
> +{
> +	int ret = RB_EMPTY_NODE(&vmf->vma->vm_rb);
> +	unsigned int seq = READ_ONCE(vmf->vma->vm_sequence.sequence);
> +
> +	/*
> +	 * Matches both the wmb in write_seqlock_{begin,end}() and
> +	 * the wmb in vma_rb_erase().
> +	 */
> +	smp_rmb();
> +
> +	return ret || seq != vmf->sequence;
> +}
> +
>  #else /* CONFIG_SPECULATIVE_PAGE_FAULT */
>  
>  static inline void get_vma(struct vm_area_struct *vma)
> diff --git a/mm/memory.c b/mm/memory.c
> index 46f877b6abea..6e6bf61c0e5c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -522,7 +522,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>  	if (page)
>  		dump_page(page, "bad pte");
>  	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
> -		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
> +		 (void *)addr, READ_ONCE(vma->vm_flags), vma->anon_vma,
> +		 mapping, index);
>  	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
>  		 vma->vm_file,
>  		 vma->vm_ops ? vma->vm_ops->fault : NULL,
> @@ -2082,6 +2083,118 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>  }
>  EXPORT_SYMBOL_GPL(apply_to_page_range);
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +static bool pte_spinlock(struct vm_fault *vmf)
> +{
> +	bool ret = false;
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	pmd_t pmdval;
> +#endif
> +
> +	/* Check if vma is still valid */
> +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
> +		vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> +		spin_lock(vmf->ptl);
> +		return true;
> +	}
> +
> +again:
> +	local_irq_disable();
> +	if (vma_has_changed(vmf))
> +		goto out;
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	/*
> +	 * We check if the pmd value is still the same to ensure that there
> +	 * is not a huge collapse operation in progress in our back.
> +	 */
> +	pmdval = READ_ONCE(*vmf->pmd);
> +	if (!pmd_same(pmdval, vmf->orig_pmd))
> +		goto out;
> +#endif
> +
> +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> +	if (unlikely(!spin_trylock(vmf->ptl))) {
> +		local_irq_enable();
> +		goto again;
> +	}

Do we want to constantly retry taking the spinlock ? Shouldn't it
be limited ? If we fail few times it is probably better to give
up on that speculative page fault.

So maybe putting everything within a for(i; i < MAX_TRY; ++i) loop
would be cleaner.


> +
> +	if (vma_has_changed(vmf)) {
> +		spin_unlock(vmf->ptl);
> +		goto out;
> +	}
> +
> +	ret = true;
> +out:
> +	local_irq_enable();
> +	return ret;
> +}
> +
> +static bool pte_map_lock(struct vm_fault *vmf)
> +{
> +	bool ret = false;
> +	pte_t *pte;
> +	spinlock_t *ptl;
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	pmd_t pmdval;
> +#endif
> +
> +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
> +		vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
> +					       vmf->address, &vmf->ptl);
> +		return true;
> +	}
> +
> +	/*
> +	 * The first vma_has_changed() guarantees the page-tables are still
> +	 * valid, having IRQs disabled ensures they stay around, hence the
> +	 * second vma_has_changed() to make sure they are still valid once
> +	 * we've got the lock. After that a concurrent zap_pte_range() will
> +	 * block on the PTL and thus we're safe.
> +	 */
> +again:
> +	local_irq_disable();
> +	if (vma_has_changed(vmf))
> +		goto out;
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	/*
> +	 * We check if the pmd value is still the same to ensure that there
> +	 * is not a huge collapse operation in progress in our back.
> +	 */
> +	pmdval = READ_ONCE(*vmf->pmd);
> +	if (!pmd_same(pmdval, vmf->orig_pmd))
> +		goto out;
> +#endif
> +
> +	/*
> +	 * Same as pte_offset_map_lock() except that we call
> +	 * spin_trylock() in place of spin_lock() to avoid race with
> +	 * unmap path which may have the lock and wait for this CPU
> +	 * to invalidate TLB but this CPU has irq disabled.
> +	 * Since we are in a speculative patch, accept it could fail
> +	 */
> +	ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> +	pte = pte_offset_map(vmf->pmd, vmf->address);
> +	if (unlikely(!spin_trylock(ptl))) {
> +		pte_unmap(pte);
> +		local_irq_enable();
> +		goto again;
> +	}

Same comment as above shouldn't be limited to a maximum number of retry ?

> +
> +	if (vma_has_changed(vmf)) {
> +		pte_unmap_unlock(pte, ptl);
> +		goto out;
> +	}
> +
> +	vmf->pte = pte;
> +	vmf->ptl = ptl;
> +	ret = true;
> +out:
> +	local_irq_enable();
> +	return ret;
> +}
> +#else
>  static inline bool pte_spinlock(struct vm_fault *vmf)
>  {
>  	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> @@ -2095,6 +2208,7 @@ static inline bool pte_map_lock(struct vm_fault *vmf)
>  				       vmf->address, &vmf->ptl);
>  	return true;
>  }
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
>  
>  /*
>   * handle_pte_fault chooses page fault handler according to an entry which was
> @@ -2999,6 +3113,14 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
>  		ret = check_stable_address_space(vma->vm_mm);
>  		if (ret)
>  			goto unlock;
> +		/*
> +		 * Don't call the userfaultfd during the speculative path.
> +		 * We already checked for the VMA to not be managed through
> +		 * userfaultfd, but it may be set in our back once we have lock
> +		 * the pte. In such a case we can ignore it this time.
> +		 */
> +		if (vmf->flags & FAULT_FLAG_SPECULATIVE)
> +			goto setpte;

Bit confuse by the comment above, if userfaultfd is set in the back
then shouldn't the speculative fault abort ? So wouldn't the following
be correct:

		if (userfaultfd_missing(vma)) {
			pte_unmap_unlock(vmf->pte, vmf->ptl);
			if (vmf->flags & FAULT_FLAG_SPECULATIVE)
				return VM_FAULT_RETRY;
			...


>  		/* Deliver the page fault to userland, check inside PT lock */
>  		if (userfaultfd_missing(vma)) {
>  			pte_unmap_unlock(vmf->pte, vmf->ptl);
> @@ -3041,7 +3163,8 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
>  		goto unlock_and_release;
>  
>  	/* Deliver the page fault to userland, check inside PT lock */
> -	if (userfaultfd_missing(vma)) {
> +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE) &&
> +	    userfaultfd_missing(vma)) {

Same comment as above but this also seems more wrong then above. What
i propose above would look more correct in both cases ie we still want
to check for userfaultfd but if we are in speculative fault then we
just want to abort the speculative fault.


>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
>  		mem_cgroup_cancel_charge(page, memcg, false);
>  		put_page(page);
> @@ -3836,6 +3959,15 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>  	pte_t entry;
>  
>  	if (unlikely(pmd_none(*vmf->pmd))) {
> +		/*
> +		 * In the case of the speculative page fault handler we abort
> +		 * the speculative path immediately as the pmd is probably
> +		 * in the way to be converted in a huge one. We will try
> +		 * again holding the mmap_sem (which implies that the collapse
> +		 * operation is done).
> +		 */
> +		if (vmf->flags & FAULT_FLAG_SPECULATIVE)
> +			return VM_FAULT_RETRY;
>  		/*
>  		 * Leave __pte_alloc() until later: because vm_ops->fault may
>  		 * want to allocate huge page, and if we expose page table
> @@ -3843,7 +3975,7 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>  		 * concurrent faults and from rmap lookups.
>  		 */
>  		vmf->pte = NULL;
> -	} else {
> +	} else if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
>  		/* See comment in pte_alloc_one_map() */
>  		if (pmd_devmap_trans_unstable(vmf->pmd))
>  			return 0;
> @@ -3852,6 +3984,9 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>  		 * pmd from under us anymore at this point because we hold the
>  		 * mmap_sem read mode and khugepaged takes it in write mode.
>  		 * So now it's safe to run pte_offset_map().
> +		 * This is not applicable to the speculative page fault handler
> +		 * but in that case, the pte is fetched earlier in
> +		 * handle_speculative_fault().
>  		 */
>  		vmf->pte = pte_offset_map(vmf->pmd, vmf->address);
>  		vmf->orig_pte = *vmf->pte;
> @@ -3874,6 +4009,8 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>  	if (!vmf->pte) {
>  		if (vma_is_anonymous(vmf->vma))
>  			return do_anonymous_page(vmf);
> +		else if (vmf->flags & FAULT_FLAG_SPECULATIVE)
> +			return VM_FAULT_RETRY;

Maybe a small comment about speculative page fault not applying to
file back vma.

>  		else
>  			return do_fault(vmf);
>  	}
> @@ -3971,6 +4108,9 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
>  	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
>  	if (!vmf.pmd)
>  		return VM_FAULT_OOM;
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	vmf.sequence = raw_read_seqcount(&vma->vm_sequence);
> +#endif
>  	if (pmd_none(*vmf.pmd) && __transparent_hugepage_enabled(vma)) {
>  		ret = create_huge_pmd(&vmf);
>  		if (!(ret & VM_FAULT_FALLBACK))
> @@ -4004,6 +4144,204 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
>  	return handle_pte_fault(&vmf);
>  }
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +/*
> + * Tries to handle the page fault in a speculative way, without grabbing the
> + * mmap_sem.
> + */
> +vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
> +				      unsigned long address,
> +				      unsigned int flags)
> +{
> +	struct vm_fault vmf = {
> +		.address = address,
> +	};
> +	pgd_t *pgd, pgdval;
> +	p4d_t *p4d, p4dval;
> +	pud_t pudval;
> +	int seq;
> +	vm_fault_t ret = VM_FAULT_RETRY;
> +	struct vm_area_struct *vma;
> +#ifdef CONFIG_NUMA
> +	struct mempolicy *pol;
> +#endif
> +
> +	/* Clear flags that may lead to release the mmap_sem to retry */
> +	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
> +	flags |= FAULT_FLAG_SPECULATIVE;
> +
> +	vma = find_vma_rcu(mm, address);
> +	if (!vma)
> +		return ret;
> +
> +	/* rmb <-> seqlock,vma_rb_erase() */
> +	seq = raw_read_seqcount(&vma->vm_sequence);
> +	if (seq & 1)
> +		goto out_put;

A comment explaining that odd sequence number means that we are racing
with a write_begin and write_end would be welcome above.

> +
> +	/*
> +	 * Can't call vm_ops service has we don't know what they would do
> +	 * with the VMA.
> +	 * This include huge page from hugetlbfs.
> +	 */
> +	if (vma->vm_ops && vma->vm_ops->fault)
> +		goto out_put;
> +
> +	/*
> +	 * __anon_vma_prepare() requires the mmap_sem to be held
> +	 * because vm_next and vm_prev must be safe. This can't be guaranteed
> +	 * in the speculative path.
> +	 */
> +	if (unlikely(!vma->anon_vma))
> +		goto out_put;

Maybe also remind people that once the vma->anon_vma is set then its
value will not change and thus we do not need to protect against such
thing (unlike vm_flags or other vma field below and above).

> +
> +	vmf.vma_flags = READ_ONCE(vma->vm_flags);
> +	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
> +
> +	/* Can't call userland page fault handler in the speculative path */
> +	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
> +		goto out_put;
> +
> +	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
> +		/*
> +		 * This could be detected by the check address against VMA's
> +		 * boundaries but we want to trace it as not supported instead
> +		 * of changed.
> +		 */
> +		goto out_put;
> +
> +	if (address < READ_ONCE(vma->vm_start)
> +	    || READ_ONCE(vma->vm_end) <= address)
> +		goto out_put;
> +
> +	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
> +				       flags & FAULT_FLAG_INSTRUCTION,
> +				       flags & FAULT_FLAG_REMOTE)) {
> +		ret = VM_FAULT_SIGSEGV;
> +		goto out_put;
> +	}
> +
> +	/* This is one is required to check that the VMA has write access set */
> +	if (flags & FAULT_FLAG_WRITE) {
> +		if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
> +			ret = VM_FAULT_SIGSEGV;
> +			goto out_put;
> +		}
> +	} else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
> +		ret = VM_FAULT_SIGSEGV;
> +		goto out_put;
> +	}
> +
> +#ifdef CONFIG_NUMA
> +	/*
> +	 * MPOL_INTERLEAVE implies additional checks in
> +	 * mpol_misplaced() which are not compatible with the
> +	 *speculative page fault processing.
> +	 */
> +	pol = __get_vma_policy(vma, address);
> +	if (!pol)
> +		pol = get_task_policy(current);
> +	if (pol && pol->mode == MPOL_INTERLEAVE)
> +		goto out_put;
> +#endif
> +
> +	/*
> +	 * Do a speculative lookup of the PTE entry.
> +	 */
> +	local_irq_disable();
> +	pgd = pgd_offset(mm, address);
> +	pgdval = READ_ONCE(*pgd);
> +	if (pgd_none(pgdval) || unlikely(pgd_bad(pgdval)))
> +		goto out_walk;
> +
> +	p4d = p4d_offset(pgd, address);
> +	p4dval = READ_ONCE(*p4d);
> +	if (p4d_none(p4dval) || unlikely(p4d_bad(p4dval)))
> +		goto out_walk;
> +
> +	vmf.pud = pud_offset(p4d, address);
> +	pudval = READ_ONCE(*vmf.pud);
> +	if (pud_none(pudval) || unlikely(pud_bad(pudval)))
> +		goto out_walk;
> +
> +	/* Huge pages at PUD level are not supported. */
> +	if (unlikely(pud_trans_huge(pudval)))
> +		goto out_walk;
> +
> +	vmf.pmd = pmd_offset(vmf.pud, address);
> +	vmf.orig_pmd = READ_ONCE(*vmf.pmd);
> +	/*
> +	 * pmd_none could mean that a hugepage collapse is in progress
> +	 * in our back as collapse_huge_page() mark it before
> +	 * invalidating the pte (which is done once the IPI is catched
> +	 * by all CPU and we have interrupt disabled).
> +	 * For this reason we cannot handle THP in a speculative way since we
> +	 * can't safely identify an in progress collapse operation done in our
> +	 * back on that PMD.
> +	 * Regarding the order of the following checks, see comment in
> +	 * pmd_devmap_trans_unstable()
> +	 */
> +	if (unlikely(pmd_devmap(vmf.orig_pmd) ||
> +		     pmd_none(vmf.orig_pmd) || pmd_trans_huge(vmf.orig_pmd) ||
> +		     is_swap_pmd(vmf.orig_pmd)))
> +		goto out_walk;
> +
> +	/*
> +	 * The above does not allocate/instantiate page-tables because doing so
> +	 * would lead to the possibility of instantiating page-tables after
> +	 * free_pgtables() -- and consequently leaking them.
> +	 *
> +	 * The result is that we take at least one !speculative fault per PMD
> +	 * in order to instantiate it.
> +	 */
> +
> +	vmf.pte = pte_offset_map(vmf.pmd, address);
> +	vmf.orig_pte = READ_ONCE(*vmf.pte);
> +	barrier(); /* See comment in handle_pte_fault() */
> +	if (pte_none(vmf.orig_pte)) {
> +		pte_unmap(vmf.pte);
> +		vmf.pte = NULL;
> +	}
> +
> +	vmf.vma = vma;
> +	vmf.pgoff = linear_page_index(vma, address);
> +	vmf.gfp_mask = __get_fault_gfp_mask(vma);
> +	vmf.sequence = seq;
> +	vmf.flags = flags;
> +
> +	local_irq_enable();
> +
> +	/*
> +	 * We need to re-validate the VMA after checking the bounds, otherwise
> +	 * we might have a false positive on the bounds.
> +	 */
> +	if (read_seqcount_retry(&vma->vm_sequence, seq))
> +		goto out_put;
> +
> +	mem_cgroup_enter_user_fault();
> +	ret = handle_pte_fault(&vmf);
> +	mem_cgroup_exit_user_fault();
> +
> +	put_vma(vma);
> +
> +	/*
> +	 * The task may have entered a memcg OOM situation but
> +	 * if the allocation error was handled gracefully (no
> +	 * VM_FAULT_OOM), there is no need to kill anything.
> +	 * Just clean up the OOM state peacefully.
> +	 */
> +	if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> +		mem_cgroup_oom_synchronize(false);
> +	return ret;
> +
> +out_walk:
> +	local_irq_enable();
> +out_put:
> +	put_vma(vma);
> +	return ret;
> +}
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> +
>  /*
>   * By the time we get here, we already hold the mm semaphore
>   *
> -- 
> 2.21.0
> 

