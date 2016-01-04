Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 88CD96B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 15:30:45 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id f206so4670071wmf.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 12:30:45 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id b6si446930wma.49.2016.01.04.12.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 12:30:44 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id f206so357104wmf.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 12:30:44 -0800 (PST)
Date: Mon, 4 Jan 2016 22:30:42 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/8] mm: Add optional support for PUD-sized transparent
 hugepages
Message-ID: <20160104203041.GB13515@node.shutemov.name>
References: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
 <1450974037-24775-2-git-send-email-matthew.r.wilcox@intel.com>
 <20151228100551.GA4589@node.shutemov.name>
 <20160102170638.GL2457@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160102170638.GL2457@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Sat, Jan 02, 2016 at 12:06:38PM -0500, Matthew Wilcox wrote:
> On Mon, Dec 28, 2015 at 12:05:51PM +0200, Kirill A. Shutemov wrote:
> > On Thu, Dec 24, 2015 at 11:20:30AM -0500, Matthew Wilcox wrote:
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index 4bf3811..e14634f 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -1958,6 +1977,17 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
> > >  	return ptl;
> > >  }
> > >  
> > > +/*
> > > + * No scalability reason to split PUD locks yet, but follow the same pattern
> > > + * as the PMD locks to make it easier if we have to.
> > > + */
> > 
> > I don't think it makes any good unless you convert all other places where
> > we use page_table_lock to protect pud table (like __pud_alloc()) to the
> > same API.
> > I think this would deserve separate patch.
> 
> Sure, a separate patch to convert existing users of the PTL.  But I
> don't think it does any harm to introduce the PUD version of the PMD API.
> Maybe with a comment indicating that tere is significant work to be done
> in converting existing users to this API?

I think that's fine with the fat comment around pud_lock() definition.
 
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 416b129..7328df0 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -1220,9 +1220,27 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
> > >  	pud = pud_offset(pgd, addr);
> > >  	do {
> > >  		next = pud_addr_end(addr, end);
> > > +		if (pud_trans_huge(*pud) || pud_devmap(*pud)) {
> > > +			if (next - addr != HPAGE_PUD_SIZE) {
> > > +#ifdef CONFIG_DEBUG_VM
> > 
> > IS_ENABLED(CONFIG_DEBUG_VM) ?
> > 
> > > +				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
> > > +					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
> > > +						__func__, addr, end,
> > > +						vma->vm_start,
> > > +						vma->vm_end);
> > 
> > dump_vma(), I guess.
> 
> These two issues are copy-and-paste from the existing PMD code.  I'm happy
> to update the PMD code to the new-and-improved way of doing things;
> I'm just not keen to have the PMD and PUD code diverge unnecessarily.

Yes, please update PMD too. It looks ugly. VM_BUG_ON_VMA() is probably
right way to deal with this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
