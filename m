Date: Thu, 8 Dec 2005 13:42:39 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: allowed pages in the block later, was Re: [Ext2-devel] [PATCH] ext3: avoid sending down non-refcounted pages
Message-ID: <20051208134239.GA13376@infradead.org>
References: <20051208180900T.fujita.tomonori@lab.ntt.co.jp> <20051208101833.GM14509@schatzie.adilger.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051208101833.GM14509@schatzie.adilger.int>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, michaelc@cs.wisc.edu, hch@infradead.org, linux-fsdevel@vger.kernel.org, ext2-devel@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 08, 2005 at 03:18:33AM -0700, Andreas Dilger wrote:
> What happens on 1kB or 2kB block filesystems (i.e. b_size != PAGE_SIZE)?
> This will allocate a whole page for each block (which may be considerable
> overhead on e.g. a 64kB PAGE_SIZE ia64 or PPC system).

Yes.  How often do we trigger this codepath?

The problem we're trying to solve here is how do implement network block
devices (nbd, iscsi) efficiently.  The zero copy codepath in the networking
layer does need to grab additional references to pages.  So to use sendpage
we need a refcountable page.  pages used by the slab allocator are not
normally refcounted so try to do get_page/pub_page on them will break.

One way to work around that would be to detect kmalloced pages and use
a slowpath for that.  The major issues with that is that we don't have a
reliable way to detect if a given struct page comes from the slab allocator
or not.  The minor problem is that even with such an indicator it means
having a separate and lightly tested slowpath for this rare case.

All in all I think we should document that the block layer only accepts
properly refcounted pages, which is everything but kmalloced pages (even
vmalloc is totally fine)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
