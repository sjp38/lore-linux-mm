Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id B362A6B0005
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 00:03:44 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id w4so27850dam.32
        for <linux-mm@kvack.org>; Mon, 28 Jan 2013 21:03:43 -0800 (PST)
Date: Mon, 28 Jan 2013 21:03:41 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH, RFC 00/16] Transparent huge page cache
In-Reply-To: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LNX.2.00.1301282041280.27186@eggly.anvils>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 28 Jan 2013, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Here's first steps towards huge pages in page cache.
> 
> The intend of the work is get code ready to enable transparent huge page
> cache for the most simple fs -- ramfs.
> 
> It's not yet near feature-complete. It only provides basic infrastructure.
> At the moment we can read, write and truncate file on ramfs with huge pages in
> page cache. The most interesting part, mmap(), is not yet there. For now
> we split huge page on mmap() attempt.
> 
> I can't say that I see whole picture. I'm not sure if I understand locking
> model around split_huge_page(). Probably, not.
> Andrea, could you check if it looks correct?
> 
> Next steps (not necessary in this order):
>  - mmap();
>  - migration (?);
>  - collapse;
>  - stats, knobs, etc.;
>  - tmpfs/shmem enabling;
>  - ...
> 
> Kirill A. Shutemov (16):
>   block: implement add_bdi_stat()
>   mm: implement zero_huge_user_segment and friends
>   mm: drop actor argument of do_generic_file_read()
>   radix-tree: implement preload for multiple contiguous elements
>   thp, mm: basic defines for transparent huge page cache
>   thp, mm: rewrite add_to_page_cache_locked() to support huge pages
>   thp, mm: rewrite delete_from_page_cache() to support huge pages
>   thp, mm: locking tail page is a bug
>   thp, mm: handle tail pages in page_cache_get_speculative()
>   thp, mm: implement grab_cache_huge_page_write_begin()
>   thp, mm: naive support of thp in generic read/write routines
>   thp, libfs: initial support of thp in
>     simple_read/write_begin/write_end
>   thp: handle file pages in split_huge_page()
>   thp, mm: truncate support for transparent huge page cache
>   thp, mm: split huge page on mmap file page
>   ramfs: enable transparent huge page cache
> 
>  fs/libfs.c                  |   54 +++++++++---
>  fs/ramfs/inode.c            |    6 +-
>  include/linux/backing-dev.h |   10 +++
>  include/linux/huge_mm.h     |    8 ++
>  include/linux/mm.h          |   15 ++++
>  include/linux/pagemap.h     |   14 ++-
>  include/linux/radix-tree.h  |    3 +
>  lib/radix-tree.c            |   32 +++++--
>  mm/filemap.c                |  204 +++++++++++++++++++++++++++++++++++--------
>  mm/huge_memory.c            |   62 +++++++++++--
>  mm/memory.c                 |   22 +++++
>  mm/truncate.c               |   12 +++
>  12 files changed, 375 insertions(+), 67 deletions(-)

Interesting.

I was starting to think about Transparent Huge Pagecache a few
months ago, but then got washed away by incoming waves as usual.

Certainly I don't have a line of code to show for it; but my first
impression of your patches is that we have very different ideas of
where to start.

Perhaps that's good complementarity, or perhaps I'll disagree with
your approach.  I'll be taking a look at yours in the coming days,
and trying to summon back up my own ideas to summarize them for you.

Perhaps I was naive to imagine it, but I did intend to start out
generically, independent of filesystem; but content to narrow down
on tmpfs alone where it gets hard to support the others (writeback
springs to mind).  khugepaged would be migrating little pages into
huge pages, where it saw that the mmaps of the file would benefit
(and for testing I would hack mmap alignment choice to favour it).

I had arrived at a conviction that the first thing to change was
the way that tail pages of a THP are refcounted, that it had been a
mistake to use the compound page method of holding the THP together.
But I'll have to enter a trance now to recall the arguments ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
