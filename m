Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5027D6B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 17:51:38 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so5021723pbb.28
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:51:37 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id sw1si8432417pab.344.2014.01.10.14.51.36
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 14:51:36 -0800 (PST)
Date: Fri, 10 Jan 2014 17:51:16 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Memory management -- THP, hugetlb,
 scalability
Message-ID: <20140110225116.GA5722@linux.intel.com>
References: <20140103122509.GA18786@node.dhcp.inet.fi>
 <20140108151321.GI27046@suse.de>
 <20140110174204.GA5228@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110174204.GA5228@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 10, 2014 at 07:42:04PM +0200, Kirill A. Shutemov wrote:
> On Wed, Jan 08, 2014 at 03:13:21PM +0000, Mel Gorman wrote:
> > I think transparent huge pagecache is likely to crop up for more than one
> > reason. There is the TLB issue and the motivation that i-TLB pressure is
> > a problem in some specialised cases. Whatever the merits of that case,
> > transparent hugepage cache has been raised as a potential solution for
> > some VM scalability problems. I recognise that dealing with large numbers
> > of struct pages is now a problem on larger machines (although I have not
> > seen quantified data on the problem nor do I have access to a machine large
> > enough to measure it myself) but I'm wary of transparent hugepage cache
> > being treated as a primary solution for VM scalability problems. Lacking
> > performance data I have no suggestions on what these alternative solutions
> > might look like.

Something I'd like to see discussed (but don't have the MM chops to
lead a discussion on myself) is the PAGE_CACHE_SIZE vs PAGE_SIZE split.
This needs to be either fixed or removed, IMO.  It's been in the tree
since before git history began (ie before 2005), it imposes a reasonably
large cognitive burden on programmers ("what kind of page size do I want
here?"), it's not intuitively obvious (to a non-mm person) which page
size is which, and it's never actually bought us anything because it's
always been the same!

Also, it bitrots.  Look at this:

        pgoff_t pgoff = (((address & PAGE_MASK)
                        - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
        vmf.pgoff = pgoff;
        pgoff_t offset = vmf->pgoff;
        size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
        if (offset >= size)
                return VM_FAULT_SIGBUS;

That's spread over three functions, but that goes to illustrate my point;
getting this stuff right is Hard; core mm developers get it wrong, we
don't have the right types to document whether a variable is in PAGE_SIZE
or PAGE_CACHE_SIZE units, and we're not getting any benefit from it today.

> Sibling topic is THP for XIP (see Matthew's patchset). Guys want to manage
> persistent memory in 2M chunks where it's possible. And THP (but without
> struct page in this case) is the obvious solution.

Not just 2MB, we also want 1GB pages for some special cases.  It looks
doable (XFS can allocate aligned 1GB blocks).  I've written some
supporting code that will at least get us to the point where we can
insert a 1GB page.  I haven't been able to test anything yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
