Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D6BCA6B0069
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 15:43:43 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x13so12124877wgg.6
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 12:43:43 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.234])
        by mx.google.com with ESMTP id ct5si1177299wjb.7.2014.10.08.12.43.42
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 12:43:42 -0700 (PDT)
Date: Wed, 8 Oct 2014 22:43:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1 2/7] mm: Prepare for DAX huge pages
Message-ID: <20141008194335.GA9232@node.dhcp.inet.fi>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
 <1412774729-23956-3-git-send-email-matthew.r.wilcox@intel.com>
 <20141008152124.GA7288@node.dhcp.inet.fi>
 <20141008155758.GK5098@wil.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008155758.GK5098@wil.cx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 08, 2014 at 11:57:58AM -0400, Matthew Wilcox wrote:
> On Wed, Oct 08, 2014 at 06:21:24PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Oct 08, 2014 at 09:25:24AM -0400, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <willy@linux.intel.com>
> > > 
> > > DAX wants to use the 'special' bit to mark PMD entries that are not backed
> > > by struct page, just as for PTEs. 
> > 
> > Hm. I don't see where you use PMD without special set.
> 
> Right ... I don't currently insert PMDs that point to huge pages of DRAM,
> only to huge pages of PMEM.

Looks like you don't need pmd_{mk,}special() then. It seems you have all
inforamtion you need -- vma -- to find out what's going on. Right?

PMD bits is not something we can assigning to a feature without a need.

> > > @@ -1104,9 +1103,20 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> > >  		goto out_unlock;
> > >  
> > > -	page = pmd_page(orig_pmd);
> > > -	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
> > > -	if (page_mapcount(page) == 1) {
> > > +	if (pmd_special(orig_pmd)) {
> > > +		/* VM_MIXEDMAP !pfn_valid() case */
> > > +		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) !=
> > > +				     (VM_WRITE|VM_SHARED)) {
> > > +			pmdp_clear_flush(vma, haddr, pmd);
> > > +			ret = VM_FAULT_FALLBACK;
> > 
> > No private THP pages with THP? Why?
> > It should be trivial: we already have a code path for !page case for zero
> > page and it shouldn't be too hard to modify do_dax_pmd_fault() to support
> > COW.
> > 
> > I remeber I've mentioned that you don't think it's reasonable to allocate
> > 2M page on COW, but that's what we do for anon memory...
> 
> I agree that it shouldn't be too hard, but I have no evidence that it'll
> be a performance win to COW 2MB pages for MAP_PRIVATE.  I'd rather be
> cautious for now and we can explore COWing 2MB chunks in a future patch.

I would rather make it other way around: use the same apporoach as for
anon memory until data shows it's doesn't make any good. Then consider
switching COW for *both* anon and file THP to fallback path.
This way we will get consistent behaviour for both types of mappings.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
