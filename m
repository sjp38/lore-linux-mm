Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 079346B0069
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 04:58:31 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so12034915wid.0
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 01:58:30 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id v10si31324938wjy.103.2014.11.18.01.58.29
        for <linux-mm@kvack.org>;
        Tue, 18 Nov 2014 01:58:29 -0800 (PST)
Date: Tue, 18 Nov 2014 11:58:11 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
Message-ID: <20141118095811.GA21774@node.dhcp.inet.fi>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
 <20141118084337.GA16714@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141118084337.GA16714@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Nov 18, 2014 at 08:43:00AM +0000, Naoya Horiguchi wrote:
> > @@ -1837,6 +1839,9 @@ static void __split_huge_page_refcount(struct page *page,
> >  	atomic_sub(tail_count, &page->_count);
> >  	BUG_ON(atomic_read(&page->_count) <= 0);
> >  
> > +	page->_mapcount = *compound_mapcount_ptr(page);
> 
> Is atomic_set() necessary?

Do you mean
	atomic_set(&page->_mapcount, atomic_read(compound_mapcount_ptr(page)));
?

I don't see why we would need this. Simple assignment should work just
fine. Or we have archs which will break?

> > @@ -6632,10 +6637,12 @@ static void dump_page_flags(unsigned long flags)
> >  void dump_page_badflags(struct page *page, const char *reason,
> >  		unsigned long badflags)
> >  {
> > -	printk(KERN_ALERT
> > -	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
> > +	pr_alert("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
> >  		page, atomic_read(&page->_count), page_mapcount(page),
> >  		page->mapping, page->index);
> > +	if (PageCompound(page))
> 
> > +		printk(" compound_mapcount: %d", compound_mapcount(page));
> > +	printk("\n");
> 
> These two printk() should be pr_alert(), too?

No. It will split the line into several messages in dmesg.

> > @@ -986,9 +986,30 @@ void page_add_anon_rmap(struct page *page,
> >  void do_page_add_anon_rmap(struct page *page,
> >  	struct vm_area_struct *vma, unsigned long address, int flags)
> >  {
> > -	int first = atomic_inc_and_test(&page->_mapcount);
> > +	bool compound = flags & RMAP_COMPOUND;
> > +	bool first;
> > +
> > +	VM_BUG_ON_PAGE(!PageLocked(compound_head(page)), page);
> > +
> > +	if (PageTransCompound(page)) {
> > +		struct page *head_page = compound_head(page);
> > +
> > +		if (compound) {
> > +			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > +			first = atomic_inc_and_test(compound_mapcount_ptr(page));
> 
> Is compound_mapcount_ptr() well-defined for tail pages?

The page is head page, otherwise VM_BUG_ON on the line above would trigger.

> > @@ -1032,10 +1052,19 @@ void page_add_new_anon_rmap(struct page *page,
> >  
> >  	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> >  	SetPageSwapBacked(page);
> > -	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
> >  	if (compound) {
> > +		atomic_t *compound_mapcount;
> > +
> >  		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > +		compound_mapcount = (atomic_t *)&page[1].mapping;
> 
> You can use compound_mapcount_ptr() here.

Right, thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
