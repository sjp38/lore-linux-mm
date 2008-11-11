Date: Tue, 11 Nov 2008 21:38:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/4] rmap: add page_wrprotect() function,
Message-ID: <20081111203806.GE10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <20081111113948.f38b9e95.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081111113948.f38b9e95.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 11, 2008 at 11:39:48AM -0800, Andrew Morton wrote:
> > +static int page_wrprotect_one(struct page *page, struct vm_area_struct *vma,
> > +			      int *odirect_sync)
> > +{
> > +	struct mm_struct *mm = vma->vm_mm;
> > +	unsigned long address;
> > +	pte_t *pte;
> > +	spinlock_t *ptl;
> > +	int ret = 0;
> > +
> > +	address = vma_address(page, vma);
> > +	if (address == -EFAULT)
> > +		goto out;
> > +
> > +	pte = page_check_address(page, mm, address, &ptl, 0);
> > +	if (!pte)
> > +		goto out;
> > +
> > +	if (pte_write(*pte)) {
> > +		pte_t entry;
> > +
> > +		if (page_mapcount(page) != page_count(page)) {
> > +			*odirect_sync = 0;
> > +			goto out_unlock;
> > +		}
> > +		flush_cache_page(vma, address, pte_pfn(*pte));
> > +		entry = ptep_clear_flush_notify(vma, address, pte);
> > +		entry = pte_wrprotect(entry);
> > +		set_pte_at(mm, address, pte, entry);
> > +	}
> > +	ret = 1;
> > +
> > +out_unlock:
> > +	pte_unmap_unlock(pte, ptl);
> > +out:
> > +	return ret;
> > +}
> 
> OK.  I think.  We need to find a way of provoking Hugh to look at it.

Yes. Please focus on the page_mapcount != page_count, which is likely
missing from migrate.c too and in turn page migration currently breaks
O_DIRECT like fork() is buggy as well as discussed here:

http://marc.info/?l=linux-mm&m=122236799302540&w=2
http://marc.info/?l=linux-mm&m=122524107519182&w=2
http://marc.info/?l=linux-mm&m=122581116713932&w=2

The fix implemented in ksm currently handles older kernels (like
rhel/sles) not current mainline that does
get_user_pages_fast. get_user_pages_fast is unfixable yet (see my last
email to Nick above asking for a way to block gup_fast).

The fix proposed by Nick plus my additional fix, should stop the
corruption in fork the same way the above check fixes it for ksm. But
todate gup_fast remains unfixable.

> > +static int page_wrprotect_file(struct page *page, int *odirect_sync)
> > +{
> > +	struct address_space *mapping;
> > +	struct prio_tree_iter iter;
> > +	struct vm_area_struct *vma;
> > +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> > +	int ret = 0;
> > +
> > +	mapping = page_mapping(page);
> 
> What pins *mapping in memory?  Usually this is done by requiring that
> the caller has locked the page.  But no such precondition is documented
> here.

Looks buggy but we never call it from ksm 8). I guess Izik added it
for completeness when preparing for mainline submission. We've the
option to get rid of page_wrprotect_file entirely and only implement a
page_wrprotect_anon! Otherwise we can add a BUG_ON(!PageLocked(page))
before the above page_mapping to protect against truncate.

> > + * set all the ptes pointed to a page as read only,
> > + * odirect_sync is set to 0 in case we cannot protect against race with odirect
> > + * return the number of ptes that were set as read only
> > + * (ptes that were read only before this function was called are couned as well)
> > + */
> 
> But it isn't.

What isn't?

> I don't understand this odirect_sync thing.  What race?  Please expand
> this comment to make the function of odirect_sync more understandable.

I should have answered this one with the above 3 links.

> What do you think about making all this new code dependent upon some
> CONFIG_ switch which CONFIG_KVM can select?

I like that too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
