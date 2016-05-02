Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF2E66B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 12:00:46 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so41861290lfd.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:00:46 -0700 (PDT)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id o82si19283265lfg.22.2016.05.02.09.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 09:00:45 -0700 (PDT)
Received: by mail-lf0-x22c.google.com with SMTP id j8so60768224lfd.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 09:00:45 -0700 (PDT)
Date: Mon, 2 May 2016 19:00:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160502160042.GC24419@node.shutemov.name>
References: <20160428102051.17d1c728@t450s.home>
 <20160428181726.GA2847@node.shutemov.name>
 <20160428125808.29ad59e5@t450s.home>
 <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502152307.GA12310@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502152307.GA12310@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 05:23:07PM +0200, Andrea Arcangeli wrote:
> On Mon, May 02, 2016 at 01:41:19PM +0300, Kirill A. Shutemov wrote:
> > I don't think this would work correctly. Let's check one of callers:
> > 
> > static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > 		unsigned long address, pte_t *page_table, pmd_t *pmd,
> > 		spinlock_t *ptl, pte_t orig_pte)
> > 	__releases(ptl)
> > {
> > ...
> > 		if (reuse_swap_page(old_page)) {
> > 			/*
> > 			 * The page is all ours.  Move it to our anon_vma so
> > 			 * the rmap code will not search our parent or siblings.
> > 			 * Protected against the rmap code by the page lock.
> > 			 */
> > 			page_move_anon_rmap(old_page, vma, address);
> > 			unlock_page(old_page);
> > 			return wp_page_reuse(mm, vma, address, page_table, ptl,
> > 					     orig_pte, old_page, 0, 0);
> > 		}
> > 
> > The first thing to notice is that old_page can be a tail page here
> > therefore page_move_anon_rmap() should be able to handle this after you
> > patch, which it doesn't.
> 
> Agreed, that's an implementation error and easy to fix.
> 
> > But I think there's a bigger problem.
> > 
> > Consider the following situation: after split_huge_pmd() we have
> > pte-mapped THP, fork() comes and now the pages is shared between two
> > processes. Child process munmap()s one half of the THP page, parent
> > munmap()s the other half.
> > 
> > IIUC, afther that page_trans_huge_mapcount() would give us 1 as all 4k
> > subpages have mapcount exactly one. Fault in the child would trigger
> > do_wp_page() and reuse_swap_page() returns true, which would lead to
> > page_move_anon_rmap() tranferring the whole compound page to child's
> > anon_vma. That's not correct.
> > 
> > We should at least avoid page_move_anon_rmap() for compound pages there.
> 
> So (compound_head() missing aside) the calculation I was doing is
> correct with regard to taking over the page and marking the pagetable
> read-write instead of triggering a COW and breaking the pinning, but
> it's not right only in terms of calling page_move_anon_rmap? The child
> or parent would then lose visibility on its ptes if the compound page
> is moved to the local vma->anon_vma.
> 
> The fix should be just to change page_trans_huge_mapcount() to return
> two refcounts, one "hard" for the pinning, and one "soft" for the rmap
> which will be the same as total_mapcount. The runtime cost will remain
> the same, so a fix can be easy for this one too.

Sounds correct, but code is going to be ugly :-/

> > Other thing I would like to discuss is if there's a problem on vfio side.
> > To me it looks like vfio expects guarantee from get_user_pages() which it
> > doesn't provide: obtaining pin on the page doesn't guarantee that the page
> > is going to remain mapped into userspace until the pin is gone.
> > 
> > Even with THP COW regressing fixed, vfio would stay fragile: any
> > MADV_DONTNEED/fork()/mremap()/whatever what would make vfio expectation
> > broken.
> 
> vfio must run as root, it will take care of not doing such things, it
> just needs a way to prevent the page to be moved so it can DMA into it
> and mlock is not enough. This clearly has to be caused by a
> get_user_pages(write=0) or by a serialized fork/exec() while a
> longstanding page pin is being held (and to be safe fork/exec had to
> be serialized in a way that the parent process wouldn't write to the
> pinned page until after exec has run in the child, or it's already
> racy no matter what kernel).
> 
> I agree it's somewhat fragile, the problem here is that the THP
> refcounting change made it even weaker than it already was.

I didn't say we shouldn't fix the problem on THP side. But the attitude
"get_user_pages() would magically freeze page tables" worries me.

> Ideally the MMU notifier invalidate should be used instead of pinning
> the page, that would make it 100% robust and it wouldn't even pin the
> page at all.
> 
> However we can't send an MMU notifier invalidate to an IOMMU because
> next time the IOMMU non-present physical address is used it would kill
> the app. Some new IOMMU can raise an exception synchronously that we
> could use to implement a IOMMU secondary MMU page fault to make the
> MMU notifier model work with IOMMUs too, but that's not feasible with
> most IOMMU out there that raises an unrecoverable asynchronous
> exception instead and can't implement a proper "IOMMU page
> fault". Furthermore the speed of the invalidate may not be optimal
> with IOMMUs which would then be an added cost to pay for swapping and
> memory migration.
> 
> This is anyway a regression of the previous guarantees a pin would
> provide, if we want to bring back the old semantics of a page pin, I
> think fixing both places like I attempted to do (modulo two
> implementation bugs) is better than fixing only the THP case.

Agreed. I just didn't see the two-refcounts solution.

> If instead leave things as is, and we weaken the semantics of a page
> pin, the alternative to deal with the even weakened semantics inside
> the vfio code, is to use get_user_pages with write=1 forced and then
> it'll probably work also with current upstream (unless it's fork/exec,
> but I don't think it is, MADV_DONTFORK would be recommended anyway for
> usages like this with vfio if fork can ever run and there are threads
> in the parent, even O_DIRECT generates data corruption without
> MADV_DONTFORK in such conditions for similar reasons).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
