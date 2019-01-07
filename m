Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEA888E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 14:37:23 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r16so644424pgr.15
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 11:37:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z5si15486182pgj.177.2019.01.07.11.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 11:37:22 -0800 (PST)
Date: Mon, 7 Jan 2019 11:37:18 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] drop_caches: Allow unmapping pages
Message-ID: <20190107193718.GB6310@bombadil.infradead.org>
References: <20190107130239.3417-1-vincent.whitchurch@axis.com>
 <20190107141545.GX6310@bombadil.infradead.org>
 <67dac226-00ca-dd0a-800e-0867e12d3ad5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <67dac226-00ca-dd0a-800e-0867e12d3ad5@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Vincent Whitchurch <vincent.whitchurch@axis.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mcgrof@kernel.org, keescook@chromium.org, corbet@lwn.net, linux-doc@vger.kernel.org, Vincent Whitchurch <rabinv@axis.com>

On Mon, Jan 07, 2019 at 11:25:16AM -0800, Dave Hansen wrote:
> On 1/7/19 6:15 AM, Matthew Wilcox wrote:
> > You're going to get data corruption doing this.  try_to_unmap_one()
> > does:
> > 
> >          /* Move the dirty bit to the page. Now the pte is gone. */
> >          if (pte_dirty(pteval))
> >                  set_page_dirty(page);
> > 
> > so PageDirty() can be false above, but made true by calling
> > try_to_unmap().
> 
> I don't think that PageDirty() check is _required_ for correctness.  You
> can always safely try_to_unmap() no matter the state of the PTE.  We
> can't lock out the hardware from setting the Dirty bit, ever.
> 
> It's also just fine to unmap PageDirty() pages, as long as when the PTE
> is created, we move the dirty bit from the PTE into the 'struct page'
> (which try_to_unmap() does, as you noticed).

Right, but the very next thing the patch does is call
invalidate_complete_page(), which calls __remove_mapping() which ... oh,
re-checks PageDirty() and refuses to drop the page.  So this isn't the
data corruptor that I had thought it was.

> > I also think the way you've done this is expedient at the cost of
> > efficiency and layering violations.  I think you should first tear
> > down the mappings of userspace processes (which will reclaim a lot
> > of pages allocated to page tables), then you won't need to touch the
> > invalidate_inode_pages paths at all.
> 
> By "tear down the mappings", do you mean something analogous to munmap()
> where the VMA goes away?  Or madvise(MADV_DONTNEED) where the PTE is
> destroyed but the VMA remains?
> 
> Last time I checked, we only did free_pgtables() when tearing down VMAs,
> but not for pure unmappings like reclaim or MADV_DONTNEED.  I've thought
> it might be fun to make a shrinker that scanned page tables looking for
> zero'd pages, but I've never run into a system where empty page table
> pages were actually causing a noticeable problem.

A few hours ago when I thought this patch had the ordering of checking
PageDirty() the wrong way round, I had the madvise analogy in mind so
that the PTEs would get destroyed and the dirty information transferred
to the struct page first before trying to drop pages.
