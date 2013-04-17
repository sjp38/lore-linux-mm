Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id DAC7E6B009B
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:36:41 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <51631206.3060605@sr71.net>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1365163198-29726-32-git-send-email-kirill.shutemov@linux.intel.com>
 <51631206.3060605@sr71.net>
Subject: Re: [PATCHv3, RFC 31/34] thp: initial implementation of
 do_huge_linear_fault()
Content-Transfer-Encoding: 7bit
Message-Id: <20130417143842.1A76CE0085@blue.fi.intel.com>
Date: Wed, 17 Apr 2013 17:38:42 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 04/05/2013 04:59 AM, Kirill A. Shutemov wrote:
> > +int do_huge_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > +		unsigned long address, pmd_t *pmd, unsigned int flags)
> > +{
> > +	unsigned long haddr = address & HPAGE_PMD_MASK;
> > +	struct page *cow_page, *page, *dirty_page = NULL;
> > +	bool anon = false, fallback = false, page_mkwrite = false;
> > +	pgtable_t pgtable = NULL;
> > +	struct vm_fault vmf;
> > +	int ret;
> > +
> > +	/* Fallback if vm_pgoff and vm_start are not suitable */
> > +	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
> > +			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
> > +		return do_fallback(mm, vma, address, pmd, flags);
> > +
> > +	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
> > +		return do_fallback(mm, vma, address, pmd, flags);
> > +
> > +	if (unlikely(khugepaged_enter(vma)))
> > +		return VM_FAULT_OOM;
> > +
> > +	/*
> > +	 * If we do COW later, allocate page before taking lock_page()
> > +	 * on the file cache page. This will reduce lock holding time.
> > +	 */
> > +	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
> > +		if (unlikely(anon_vma_prepare(vma)))
> > +			return VM_FAULT_OOM;
> > +
> > +		cow_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
> > +				vma, haddr, numa_node_id(), 0);
> > +		if (!cow_page) {
> > +			count_vm_event(THP_FAULT_FALLBACK);
> > +			return do_fallback(mm, vma, address, pmd, flags);
> > +		}
> > +		count_vm_event(THP_FAULT_ALLOC);
> > +		if (mem_cgroup_newpage_charge(cow_page, mm, GFP_KERNEL)) {
> > +			page_cache_release(cow_page);
> > +			return do_fallback(mm, vma, address, pmd, flags);
> > +		}
> 
> Ugh.  This is essentially a copy-n-paste of code in __do_fault(),
> including the comments.  Is there no way to consolidate the code so that
> there's less duplication here?

I've looked into it once again and it seems there's not much space for
consolidation. Code structure looks very similar, but there are many
special cases for thp: fallback path, pte vs. pmd, etc. I don't see how we
can consolidate them in them in sane way.
I think copy is more maintainable :(

> Part of the reason we have so many bugs in hugetlbfs is that it's really
> a forked set of code that does things its own way.  I really hope we're
> not going down the road of creating another feature in the same way.
> 
> When you copy *this* much code (or any, really), you really need to talk
> about it in the patch description.  I was looking at other COW code, and
> just happened to stumble on to the __do_fault() code.

I will document it in commit message and in comments for both functions.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
