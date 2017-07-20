Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8F56B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 11:59:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 123so38168867pgj.4
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 08:59:26 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u190si1833156pgd.513.2017.07.20.08.59.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 08:59:24 -0700 (PDT)
Date: Thu, 20 Jul 2017 09:59:22 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 1/5] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170720155922.GA21186@linux.intel.com>
References: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
 <20170628220152.28161-2-ross.zwisler@linux.intel.com>
 <20170720152616.GB6664@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170720152616.GB6664@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Jul 20, 2017 at 11:26:16AM -0400, Vivek Goyal wrote:
> On Wed, Jun 28, 2017 at 04:01:48PM -0600, Ross Zwisler wrote:
> > To be able to use the common 4k zero page in DAX we need to have our PTE
> > fault path look more like our PMD fault path where a PTE entry can be
> > marked as dirty and writeable as it is first inserted, rather than waiting
> > for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> > 
> > Right now we can rely on having a dax_pfn_mkwrite() call because we can
> > distinguish between these two cases in do_wp_page():
> > 
> > 	case 1: 4k zero page => writable DAX storage
> > 	case 2: read-only DAX storage => writeable DAX storage
> > 
> > This distinction is made by via vm_normal_page().  vm_normal_page() returns
> > false for the common 4k zero page, though, just as it does for DAX ptes.
> > Instead of special casing the DAX + 4k zero page case, we will simplify our
> > DAX PTE page fault sequence so that it matches our DAX PMD sequence, and
> > get rid of dax_pfn_mkwrite() completely.
> > 
> > This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
> > and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
> > will do the work that was previously done by wp_page_reuse() as part of the
> > dax_pfn_mkwrite() call path.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  include/linux/mm.h |  2 ++
> >  mm/memory.c        | 57 +++++++++++++++++++++++++++++++++++++++++++++++++-----
> >  2 files changed, 54 insertions(+), 5 deletions(-)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 6f543a4..096052f 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2293,6 +2293,8 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> >  			unsigned long pfn, pgprot_t pgprot);
> >  int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
> >  			pfn_t pfn);
> > +int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
> > +			pfn_t pfn);
> >  int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
> >  
> >  
> > diff --git a/mm/memory.c b/mm/memory.c
> > index bb11c47..de4aa71 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1646,7 +1646,7 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
> >  EXPORT_SYMBOL(vm_insert_page);
> >  
> >  static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> > -			pfn_t pfn, pgprot_t prot)
> > +			pfn_t pfn, pgprot_t prot, bool mkwrite)
> >  {
> >  	struct mm_struct *mm = vma->vm_mm;
> >  	int retval;
> > @@ -1658,14 +1658,26 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> >  	if (!pte)
> >  		goto out;
> >  	retval = -EBUSY;
> > -	if (!pte_none(*pte))
> > -		goto out_unlock;
> > +	if (!pte_none(*pte)) {
> > +		if (mkwrite) {
> > +			entry = *pte;
> > +			goto out_mkwrite;
> > +		} else
> > +			goto out_unlock;
> > +	}
> >  
> >  	/* Ok, finally just insert the thing.. */
> >  	if (pfn_t_devmap(pfn))
> >  		entry = pte_mkdevmap(pfn_t_pte(pfn, prot));
> >  	else
> >  		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
> > +
> > +out_mkwrite:
> > +	if (mkwrite) {
> > +		entry = pte_mkyoung(entry);
> > +		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> > +	}
> > +
> >  	set_pte_at(mm, addr, pte, entry);
> >  	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
> >  
> > @@ -1736,7 +1748,8 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> >  
> >  	track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV));
> >  
> > -	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
> > +	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
> > +			false);
> >  
> >  	return ret;
> >  }
> > @@ -1772,10 +1785,44 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
> >  		page = pfn_to_page(pfn_t_to_pfn(pfn));
> >  		return insert_page(vma, addr, page, pgprot);
> >  	}
> > -	return insert_pfn(vma, addr, pfn, pgprot);
> > +	return insert_pfn(vma, addr, pfn, pgprot, false);
> >  }
> >  EXPORT_SYMBOL(vm_insert_mixed);
> >  
> > +int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
> > +			pfn_t pfn)
> > +{
> > +	pgprot_t pgprot = vma->vm_page_prot;
> > +
> > +	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
> > +
> > +	if (addr < vma->vm_start || addr >= vma->vm_end)
> > +		return -EFAULT;
> > +
> > +	track_pfn_insert(vma, &pgprot, pfn);
> > +
> > +	/*
> > +	 * If we don't have pte special, then we have to use the pfn_valid()
> > +	 * based VM_MIXEDMAP scheme (see vm_normal_page), and thus we *must*
> > +	 * refcount the page if pfn_valid is true (hence insert_page rather
> > +	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
> > +	 * without pte special, it would there be refcounted as a normal page.
> > +	 */
> > +	if (!HAVE_PTE_SPECIAL && !pfn_t_devmap(pfn) && pfn_t_valid(pfn)) {
> > +		struct page *page;
> > +
> > +		/*
> > +		 * At this point we are committed to insert_page()
> > +		 * regardless of whether the caller specified flags that
> > +		 * result in pfn_t_has_page() == false.
> > +		 */
> > +		page = pfn_to_page(pfn_t_to_pfn(pfn));
> > +		return insert_page(vma, addr, page, pgprot);
> > +	}
> > +	return insert_pfn(vma, addr, pfn, pgprot, true);
> > +}
> > +EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
> 
> Hi Ross,
> 
> vm_insert_mixed_mkwrite() is same as vm_insert_mixed() except this sets
> write parameter to inser_pfn() true. Will it make sense to just add
> mkwrite parameter to vm_insert_mixed() and not add a new helper function.
> (like insert_pfn()).
> 
> Vivek

Yep, this is how my initial implementation worked:

https://lkml.org/lkml/2017/6/7/907

vm_insert_mixed_mkwrite() was the new version that took an extra parameter,
and vm_insert_mixed() stuck around as a wrapper that supplied a default value
for the new parameter, so existing call sites didn't need to change and didn't
need to worry about the new parameter, but so that we didn't duplicate any
code.

I changed this to the way that it currently works based on Dan's feedback in
that same mail thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
