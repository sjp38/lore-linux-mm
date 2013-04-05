From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH, RFC 00/16] Transparent huge page cache
Date: Fri, 5 Apr 2013 09:42:08 +0800
Message-ID: <16612.7521697947$1365126175@news.gmane.org>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LNX.2.00.1301282041280.27186@eggly.anvils>
 <5107cb52e07b1_376199eb7059997@blue.mail>
 <alpine.LNX.2.00.1301301619040.24861@eggly.anvils>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UNvfz-0008Nr-VN
	for glkm-linux-mm-2@m.gmane.org; Fri, 05 Apr 2013 03:42:48 +0200
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 1E94D6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 21:42:20 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 07:07:02 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 919791258023
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:13:31 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r351g7bY262456
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 07:12:07 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r351g9q0030087
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 12:42:10 +1100
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1301301619040.24861@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jan 30, 2013 at 06:12:05PM -0800, Hugh Dickins wrote:
>On Tue, 29 Jan 2013, Kirill A. Shutemov wrote:
>> Hugh Dickins wrote:
>> > On Mon, 28 Jan 2013, Kirill A. Shutemov wrote:
>> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> > > 
>> > > Here's first steps towards huge pages in page cache.
>> > > 
>> > > The intend of the work is get code ready to enable transparent huge page
>> > > cache for the most simple fs -- ramfs.
>> > > 
>> > > It's not yet near feature-complete. It only provides basic infrastructure.
>> > > At the moment we can read, write and truncate file on ramfs with huge pages in
>> > > page cache. The most interesting part, mmap(), is not yet there. For now
>> > > we split huge page on mmap() attempt.
>> > > 
>> > > I can't say that I see whole picture. I'm not sure if I understand locking
>> > > model around split_huge_page(). Probably, not.
>> > > Andrea, could you check if it looks correct?
>> > > 
>> > > Next steps (not necessary in this order):
>> > >  - mmap();
>> > >  - migration (?);
>> > >  - collapse;
>> > >  - stats, knobs, etc.;
>> > >  - tmpfs/shmem enabling;
>> > >  - ...
>> > > 
>> > > Kirill A. Shutemov (16):
>> > >   block: implement add_bdi_stat()
>> > >   mm: implement zero_huge_user_segment and friends
>> > >   mm: drop actor argument of do_generic_file_read()
>> > >   radix-tree: implement preload for multiple contiguous elements
>> > >   thp, mm: basic defines for transparent huge page cache
>> > >   thp, mm: rewrite add_to_page_cache_locked() to support huge pages
>> > >   thp, mm: rewrite delete_from_page_cache() to support huge pages
>> > >   thp, mm: locking tail page is a bug
>> > >   thp, mm: handle tail pages in page_cache_get_speculative()
>> > >   thp, mm: implement grab_cache_huge_page_write_begin()
>> > >   thp, mm: naive support of thp in generic read/write routines
>> > >   thp, libfs: initial support of thp in
>> > >     simple_read/write_begin/write_end
>> > >   thp: handle file pages in split_huge_page()
>> > >   thp, mm: truncate support for transparent huge page cache
>> > >   thp, mm: split huge page on mmap file page
>> > >   ramfs: enable transparent huge page cache
>> > > 
>> > >  fs/libfs.c                  |   54 +++++++++---
>> > >  fs/ramfs/inode.c            |    6 +-
>> > >  include/linux/backing-dev.h |   10 +++
>> > >  include/linux/huge_mm.h     |    8 ++
>> > >  include/linux/mm.h          |   15 ++++
>> > >  include/linux/pagemap.h     |   14 ++-
>> > >  include/linux/radix-tree.h  |    3 +
>> > >  lib/radix-tree.c            |   32 +++++--
>> > >  mm/filemap.c                |  204 +++++++++++++++++++++++++++++++++++--------
>> > >  mm/huge_memory.c            |   62 +++++++++++--
>> > >  mm/memory.c                 |   22 +++++
>> > >  mm/truncate.c               |   12 +++
>> > >  12 files changed, 375 insertions(+), 67 deletions(-)
>> > 
>> > Interesting.
>> > 
>> > I was starting to think about Transparent Huge Pagecache a few
>> > months ago, but then got washed away by incoming waves as usual.
>> > 
>> > Certainly I don't have a line of code to show for it; but my first
>> > impression of your patches is that we have very different ideas of
>> > where to start.
>
>A second impression confirms that we have very different ideas of
>where to start.  I don't want to be dismissive, and please don't let
>me discourage you, but I just don't find what you have very interesting.
>
>I'm sure you'll agree that the interesting part, and the difficult part,
>comes with mmap(); and there's no point whatever to THPages without mmap()
>(of course, I'm including exec and brk and shm when I say mmap there).
>
>(There may be performance benefits in working with larger page cache
>size, which Christoph Lameter explored a few years back, but that's a
>different topic: I think 2MB - if I may be x86_64-centric - would not be
>the unit of choice for that, unless SSD erase block were to dominate.)
>
>I'm interested to get to the point of prototyping something that does
>support mmap() of THPageCache: I'm pretty sure that I'd then soon learn
>a lot about my misconceptions, and have to rework for a while (or give
>up!); but I don't see much point in posting anything without that.
>I don't know if we have 5 or 50 places which "know" that a THPage
>must be Anon: some I'll spot in advance, some I sadly won't.
>
>It's not clear to me that the infrastructural changes you make in this
>series will be needed or not, if I pursue my approach: some perhaps as
>optimizations on top of the poorly performing base that may emerge from
>going about it my way.  But for me it's too soon to think about those.
>
>Something I notice that we do agree upon: the radix_tree holding the
>4k subpages, at least for now.  When I first started thinking towards
>THPageCache, I was fascinated by how we could manage the hugepages in
>the radix_tree, cutting out unnecessary levels etc; but after a while
>I realized that although there's probably nice scope for cleverness
>there (significantly constrained by RCU expectations), it would only
>be about optimization.  Let's be simple and stupid about radix_tree
>for now, the problems that need to be worked out lie elsewhere.
>
>> > 
>> > Perhaps that's good complementarity, or perhaps I'll disagree with
>> > your approach.  I'll be taking a look at yours in the coming days,
>> > and trying to summon back up my own ideas to summarize them for you.
>> 
>> Yeah, it would be nice to see alternative design ideas. Looking forward.
>> 
>> > Perhaps I was naive to imagine it, but I did intend to start out
>> > generically, independent of filesystem; but content to narrow down
>> > on tmpfs alone where it gets hard to support the others (writeback
>> > springs to mind).  khugepaged would be migrating little pages into
>> > huge pages, where it saw that the mmaps of the file would benefit
>> > (and for testing I would hack mmap alignment choice to favour it).
>> 
>> I don't think all fs at once would fly, but it's wonderful, if I'm
>> wrong :)
>
>You are imagining the filesystem putting huge pages into its cache.
>Whereas I'm imagining khugepaged looking around at mmaped file areas,
>seeing which would benefit from huge pagecache (let's assume offset 0
>belongs on hugepage boundary - maybe one day someone will want to tune
>some files or parts differently, but that's low priority), migrating 4k
>pages over to 2MB page (wouldn't have to be done all in one pass), then
>finally slotting in the pmds for that.
>
>But going this way, I expect we'd have to split at page_mkwrite():
>we probably don't want a single touch to dirty 2MB at a time,
>unless tmpfs or ramfs.
>
>> 
>> > I had arrived at a conviction that the first thing to change was
>> > the way that tail pages of a THP are refcounted, that it had been a
>> > mistake to use the compound page method of holding the THP together.
>> > But I'll have to enter a trance now to recall the arguments ;)
>> 
>> THP refcounting looks reasonable for me, if take split_huge_page() in
>> account.
>
>I'm not claiming that the THP refcounting is wrong in what it's doing
>at present; but that I suspect we'll want to rework it for THPageCache.
>
>Something I take for granted, I think you do too but I'm not certain:
>a file with transparent huge pages in its page cache can also have small
>pages in other extents of its page cache; and can be mapped hugely (2MB
>extents) into one address space at the same time as individual 4k pages
>from those extents are mapped into another (or the same) address space.
>
>One can certainly imagine sacrificing that principle, splitting whenever
>there's such a "conflict"; but it then becomes uninteresting to me, too
>much like hugetlbfs.  Splitting an anonymous hugepage in all address
>spaces that hold it when one of them needs it split, that has been a
>pragmatic strategy: it's not a common case for forks to diverge like
>that; but files are expected to be more widely shared.
>
>At present THP is using compound pages, with mapcount of tail pages
>reused to track their contribution to head page count; but I think we
>shall want to be able to use the mapcount, and the count, of TH tail
>pages for their original purpose if huge mappings can coexist with tiny.
>Not fully thought out, but that's my feeling.
>
>The use of compound pages, in particular the redirection of tail page
>count to head page count, was important in hugetlbfs: a get_user_pages
>reference on a subpage must prevent the containing hugepage from being
>freed, because hugetlbfs has its own separate pool of hugepages to
>which freeing returns them.
>
>But for transparent huge pages?  It should not matter so much if the
>subpages are freed independently.  So I'd like to devise another glue
>to hold them together more loosely (for prototyping I can certainly
>pretend we have infinite pageflag and pagefield space if that helps):
>I may find in practice that they're forever falling apart, and I run
>crying back to compound pages; but at present I'm hoping not.
>
>This mail might suggest that I'm about to start coding: I wish that
>were true, but in reality there's always a lot of unrelated things
>I have to look at, which dilute my focus.  So if I've said anything
>that sparks ideas for you, go with them.

It seems that it's a good idea, Hugh. I will start coding this. ;-)

Regards,
Wanpeng Li 

>
>Hugh
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
