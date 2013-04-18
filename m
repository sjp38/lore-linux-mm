Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id EB1836B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 12:36:56 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <51701D5E.80802@sr71.net>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1365163198-29726-32-git-send-email-kirill.shutemov@linux.intel.com>
 <51631206.3060605@sr71.net>
 <20130417143842.1A76CE0085@blue.fi.intel.com>
 <516F1D3C.1060804@sr71.net>
 <20130418160920.4A00DE0085@blue.fi.intel.com>
 <51701D5E.80802@sr71.net>
Subject: Re: [PATCHv3, RFC 31/34] thp: initial implementation of
 do_huge_linear_fault()
Content-Transfer-Encoding: 7bit
Message-Id: <20130418163836.B73B2E0085@blue.fi.intel.com>
Date: Thu, 18 Apr 2013 19:38:36 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 04/18/2013 09:09 AM, Kirill A. Shutemov wrote:
> > Dave Hansen wrote:
> >> On 04/17/2013 07:38 AM, Kirill A. Shutemov wrote:
> >> Are you still sure you can't do _any_ better than a verbatim copy of 129
> >> lines?
> > 
> > It seems I was too lazy. Shame on me. :(
> > Here's consolidated version. Only build tested. Does it look better?
> 
> Yeah, it's definitely a step in the right direction.  There rae
> definitely some bugs in there like:
> 
> +	unsigned long haddr = address & PAGE_MASK;

It's not bug. It's bad name for the variable.
See, first 'if (try_huge_pages)'. I update it there for huge page case.

addr_aligned better?

> 
> I do think some of this refactoring stuff
> 
> > -				unlock_page(page);
> > -				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> > -				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
> > -				if (unlikely(tmp &
> > -					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
> > -					ret = tmp;
> > +			unlock_page(page);
> > +			vmf.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE;
> > +			tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
> > +			if (unlikely(tmp &
> > +					(VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
> > +				ret = tmp;
> > +				goto unwritable_page;
> > +			}
> 
> could probably be a separate patch and would make what's going on more
> clear, but it's passable the way it is.  When it is done this way it's
> hard sometimes reading the diff to realize if you are adding code or
> just moving it around.

Will do.

> 
> This stuff:
> 
> >  		if (set_page_dirty(dirty_page))
> > -			dirtied = 1;
> > +			dirtied = true;
> 
> needs to go in another patch for sure.

Ditto.

> One thing I *REALLY* like about doing patches this way is that things
> like this start to pop out:
> 
> > -	ret = vma->vm_ops->fault(vma, &vmf);
> > +	if (try_huge_pages) {
> > +		pgtable = pte_alloc_one(mm, haddr);
> > +		if (unlikely(!pgtable)) {
> > +			ret = VM_FAULT_OOM;
> > +			goto uncharge_out;
> > +		}
> > +		ret = vma->vm_ops->huge_fault(vma, &vmf);
> > +	} else
> > +		ret = vma->vm_ops->fault(vma, &vmf);
> 
> The ->fault is (or can be) essentially per filesystem, and we're going
> to be adding support per-filesystem.  any reason we can't just handle
> this inside the ->fault code and avoid adding huge_fault altogether?

will check. it's on my todo list already.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
