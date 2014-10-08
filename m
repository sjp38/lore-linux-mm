Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 46E586B0069
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 11:58:05 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so7098641pdb.31
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 08:58:05 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id j14si324416pdl.60.2014.10.08.08.58.03
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 08:58:03 -0700 (PDT)
Date: Wed, 8 Oct 2014 11:57:58 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v1 2/7] mm: Prepare for DAX huge pages
Message-ID: <20141008155758.GK5098@wil.cx>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
 <1412774729-23956-3-git-send-email-matthew.r.wilcox@intel.com>
 <20141008152124.GA7288@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008152124.GA7288@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Wed, Oct 08, 2014 at 06:21:24PM +0300, Kirill A. Shutemov wrote:
> On Wed, Oct 08, 2014 at 09:25:24AM -0400, Matthew Wilcox wrote:
> > From: Matthew Wilcox <willy@linux.intel.com>
> > 
> > DAX wants to use the 'special' bit to mark PMD entries that are not backed
> > by struct page, just as for PTEs. 
> 
> Hm. I don't see where you use PMD without special set.

Right ... I don't currently insert PMDs that point to huge pages of DRAM,
only to huge pages of PMEM.

> > @@ -1104,9 +1103,20 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> >  		goto out_unlock;
> >  
> > -	page = pmd_page(orig_pmd);
> > -	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
> > -	if (page_mapcount(page) == 1) {
> > +	if (pmd_special(orig_pmd)) {
> > +		/* VM_MIXEDMAP !pfn_valid() case */
> > +		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) !=
> > +				     (VM_WRITE|VM_SHARED)) {
> > +			pmdp_clear_flush(vma, haddr, pmd);
> > +			ret = VM_FAULT_FALLBACK;
> 
> No private THP pages with THP? Why?
> It should be trivial: we already have a code path for !page case for zero
> page and it shouldn't be too hard to modify do_dax_pmd_fault() to support
> COW.
> 
> I remeber I've mentioned that you don't think it's reasonable to allocate
> 2M page on COW, but that's what we do for anon memory...

I agree that it shouldn't be too hard, but I have no evidence that it'll
be a performance win to COW 2MB pages for MAP_PRIVATE.  I'd rather be
cautious for now and we can explore COWing 2MB chunks in a future patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
