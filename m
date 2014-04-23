Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A8AC26B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 16:13:12 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1098411pab.36
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 13:13:12 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id nj10si1217143pbc.476.2014.04.23.13.13.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 13:13:11 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so1094497pad.35
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 13:13:11 -0700 (PDT)
Date: Wed, 23 Apr 2014 13:11:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Dirty/Access bits vs. page content
In-Reply-To: <20140423184145.GH17824@quack.suse.cz>
Message-ID: <alpine.LSU.2.11.1404231247230.3173@eggly.anvils>
References: <1398057630.19682.38.camel@pasglop> <CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com> <53558507.9050703@zytor.com> <CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com> <53559F48.8040808@intel.com>
 <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com> <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com> <20140422075459.GD11182@twins.programming.kicks-ass.net> <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
 <alpine.LSU.2.11.1404221847120.1759@eggly.anvils> <20140423184145.GH17824@quack.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Wed, 23 Apr 2014, Jan Kara wrote:
> On Tue 22-04-14 20:08:59, Hugh Dickins wrote:
> > On Tue, 22 Apr 2014, Linus Torvalds wrote:
> > > On Tue, Apr 22, 2014 at 12:54 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > > That said, Dave Hansen did report a BUG_ON() in
> > > mpage_prepare_extent_to_map(). His line number was odd, but I assume
> > > it's this one:
> > > 
> > >         BUG_ON(PageWriteback(page));
> > > 
> > > which may be indicative of some oddity here wrt the dirty bit.
> > 
> > Whereas later mail from Dave showed it to be the
> > 	BUG_ON(!PagePrivate(page));
> > in page_buffers() from fs/ext4/inode.c mpage_prepare_extent_to_map().
> > But still presumably some kind of fallout from your patches.
> > 
> > Once upon a time there was a page_has_buffers() check in there,
> > but Honza decided that's nowadays unnecessary in f8bec37037ac
> > "ext4: dirty page has always buffers attached".  Cc'ed,
> > he may very well have some good ideas.
> > 
> > Reading that commit reminded me of how we actually don't expect that
> > set_page_dirty() in zap_pte_range() to do anything at all on the usual
> > mapping_cap_account_dirty()/page_mkwrite() filesystems, do we?  Or do we?
>   Yes, for shared file mappings we (as in filesystems implementing
> page_mkwrite() handler) expect a page is writeably mmapped iff the page is
> dirty. So in particular we don't expect set_page_dirty() in zap_pte_range()
> to do anything because if the pte has dirty bit set, we are tearing down a
> writeable mapping of the page and thus the page should be already dirty.
> 
> Now the devil is in synchronization of different places where transitions
> from/to writeably-mapped state happen. In the fault path (do_wp_page())
> where transition to writeably-mapped happens we hold page lock while
> calling set_page_dirty(). In the writeout path (clear_page_dirty_for_io())
> where we transition from writeably-mapped we hold the page lock as well
> while calling page_mkclean() and possibly set_page_dirty(). So these two
> places are nicely serialized. However zap_pte_range() doesn't hold page
> lock so it can race with the previous two places. Before Linus' patches we
> called set_page_dirty() under pte lock in zap_pte_range() and also before
> decrementing page->mapcount. So if zap_pte_range() raced with
> clear_page_dirty_for_io() we were guaranteed that by the time
> clear_page_dirty_for_io() returns, pte dirty bit is cleared and
> set_page_dirty() was called (either from clear_page_dirty_for_io() or from
> zap_pte_range()).
> 
> However with Linus' patches set_page_dirty() from zap_pte_range() gets
> called after decremeting page->mapcount so page_mkclean() won't event try
> to walk rmap. And even if page_mkclean() did walk the rmap, zap_pte_range()
> calls set_page_dirty() after dropping pte lock so it can get called long
> after page_mkclean() (and clear_page_dirty_for_io()) has returned.

Right, thanks a lot for fleshing that out.

> 
> Now I'm not sure how to fix Linus' patches. For all I care we could just
> rip out pte dirty bit handling for file mappings. However last time I
> suggested this you corrected me that tmpfs & ramfs need this. I assume this
> is still the case - however, given we unconditionally mark the page dirty
> for write faults, where exactly do we need this?

Good, Linus has already replied to you on this this: you appear to be
suggesting that there would be no issue, and Linus's patches would not
be needed at all, if only tmpfs and ramfs played by the others' rules.

But (sadly) I don't think that's so: just because zap_pte_range()'s
current "if (pte_dirty) set_page_dirty" does nothing on most filesystems,
does not imply that nothing needs to be done on most filesystems, now
that we're alert to the delayed TLB flushing issue.

Just to answer your (interesting but irrelevant!) question about tmpfs
and ramfs: their issue is with read faults which bring in a zeroed page,
with page and pte not marked dirty.  If userspace modifies that page, the
pte_dirty needs to be propagated through to PageDirty, to prevent page
reclaim from simply freeing the apparently clean page.

(To be honest, I haven't checked the ramfs case recently: perhaps its
pages are marked unevictable, and never even reach the code which might
free them.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
