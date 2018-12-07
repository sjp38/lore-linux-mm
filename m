Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11E6A8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 13:54:53 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id h10so3315518plk.12
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 10:54:53 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id q14si3379152pgq.197.2018.12.07.10.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 10:54:51 -0800 (PST)
Date: Fri, 7 Dec 2018 10:51:04 -0800
From: Liu Bo <bo.liu@linux.alibaba.com>
Subject: Re: [PATCH RFC] Ext4: fix deadlock on dirty pages between fault and
 writeback
Message-ID: <20181207185102.2chvdfqwav5z6b7j@US-160370MP2.local>
Reply-To: bo.liu@linux.alibaba.com
References: <20181127114249.GH16301@quack2.suse.cz>
 <20181128201122.r4sec265cnlxgj2x@US-160370MP2.local>
 <20181129085238.GD31087@quack2.suse.cz>
 <20181129120253.GR6311@dastard>
 <20181129130002.GM31087@quack2.suse.cz>
 <20181129204019.GS6311@dastard>
 <20181205170656.GJ30615@quack2.suse.cz>
 <20181207052051.GB6311@dastard>
 <20181207071615.GO1286@dhcp22.suse.cz>
 <20181207112036.GA1286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181207112036.GA1286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 07, 2018 at 12:20:36PM +0100, Michal Hocko wrote:
> On Fri 07-12-18 08:16:15, Michal Hocko wrote:
> [...]
> > Memcg v1 indeed doesn't have any dirty IO throttling and this is a
> > poor's man workaround. We still do not have that AFAIK and I do not know
> > of an elegant way around that. Fortunatelly we shouldn't have that many
> > GFP_KERNEL | __GFP_ACCOUNT allocations under page lock and we can work
> > around this specific one quite easily. I haven't tested this yet but the
> > following should work
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 4ad2d293ddc2..59c98eeb0260 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2993,6 +2993,16 @@ static vm_fault_t __do_fault(struct vm_fault *vmf)
> >  	struct vm_area_struct *vma = vmf->vma;
> >  	vm_fault_t ret;
> >  
> > +	/*
> > +	 * Preallocate pte before we take page_lock because this might lead to
> > +	 * deadlocks for memcg reclaim which waits for pages under writeback.
> > +	 */
> > +	if (!vmf->prealloc_pte) {
> > +		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm>mm, vmf->address);
> > +		if (!vmf->prealloc_pte)
> > +			return VM_FAULT_OOM;
> > +	}
> > +
> >  	ret = vma->vm_ops->fault(vmf);
> >  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
> >  			    VM_FAULT_DONE_COW)))
> 
> This is too eager to allocate pte even when it is not really needed.
> Jack has also pointed out that I am missing a write barrier. So here we
> go with an updated patch. This is essentially what fault around code
> does.
> 

Makes sense to me, unfortunately we don't have a local reproducer to verify it
and we've disabled CONFIG_MEMCG_KMEM to workaround the problem.  Given the stack
I put, the patch should address the deadlock at least.

thanks,
-liubo

> diff --git a/mm/memory.c b/mm/memory.c
> index 4ad2d293ddc2..1a73d2d4659e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2993,6 +2993,17 @@ static vm_fault_t __do_fault(struct vm_fault *vmf)
>  	struct vm_area_struct *vma = vmf->vma;
>  	vm_fault_t ret;
>  
> +	/*
> +	 * Preallocate pte before we take page_lock because this might lead to
> +	 * deadlocks for memcg reclaim which waits for pages under writeback.
> +	 */
> +	if (pmd_none(*vmf->pmd) && !vmf->prealloc_pte) {
> +		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm>mm, vmf->address);
> +		if (!vmf->prealloc_pte)
> +			return VM_FAULT_OOM;
> +		smp_wmb(); /* See comment in __pte_alloc() */
> +	}
> +
>  	ret = vma->vm_ops->fault(vmf);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
>  			    VM_FAULT_DONE_COW)))
> -- 
> Michal Hocko
> SUSE Labs
