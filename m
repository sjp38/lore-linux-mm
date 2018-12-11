Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8BB18E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:21:53 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so7194698edq.4
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:21:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t22si732551edr.225.2018.12.11.08.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 08:21:52 -0800 (PST)
Date: Tue, 11 Dec 2018 17:21:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memcg: fix reclaim deadlock with writeback
Message-ID: <20181211162149.GL1286@dhcp22.suse.cz>
References: <20181211132645.31053-1-mhocko@kernel.org>
 <20181211151542.2rjti4glj75honje@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211151542.2rjti4glj75honje@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Liu Bo <bo.liu@linux.alibaba.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 11-12-18 18:15:42, Kirill A. Shutemov wrote:
> On Tue, Dec 11, 2018 at 02:26:45PM +0100, Michal Hocko wrote:
[...]
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2993,6 +2993,17 @@ static vm_fault_t __do_fault(struct vm_fault *vmf)
> >  	struct vm_area_struct *vma = vmf->vma;
> >  	vm_fault_t ret;
> >  
> > +	/*
> > +	 * Preallocate pte before we take page_lock because this might lead to
> > +	 * deadlocks for memcg reclaim which waits for pages under writeback.
> > +	 */
> > +	if (pmd_none(*vmf->pmd) && !vmf->prealloc_pte) {
> > +		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm>mm, vmf->address);
> > +		if (!vmf->prealloc_pte)
> > +			return VM_FAULT_OOM;
> > +		smp_wmb(); /* See comment in __pte_alloc() */
> > +	}
> > +
> >  	ret = vma->vm_ops->fault(vmf);
> >  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
> >  			    VM_FAULT_DONE_COW)))
> 
> Sorry, but I don't think it fixes anything. Just hides it a level deeper.
> 
> The trick with ->prealloc_pte works for faultaround because we can rely on
> ->map_pages() to not sleep and we know how it will setup page table entry.
> Basically, core controls most of the path.
> 
> It's not the case with ->fault(). It is free to sleep and allocate
> whatever it wants.

Yeah, but if the fault callback wants to allocate then it has to
consider the usual allocation restrictions. e.g. NOFS if the allocation
itself can trip over fs locks.

> For instance, DAX page fault will setup page table entry on its own and
> return VM_FAULT_NOPAGE. It uses vmf_insert_mixed() to setup the page table
> and ignores your pre-allocated page table.

Does this happen with a page locked and with __GFP_ACCOUNT allocation. I
am not familiar with that code but I do not see it from a quick look.
 
> But it's just an example. The problem is that ->fault() is not bounded on
> what it can do, unlike ->map_pages().

That is a fair point but the primary issue here is that the generic #PF
code breaks the underlying assumption and performs
__GFP_ACCOUNT|GFP_KERNEL allocation from within a fs owned locked page.
-- 
Michal Hocko
SUSE Labs
