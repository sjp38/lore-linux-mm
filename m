Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD1E26B02F8
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:08:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f8-v6so1650130eds.6
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 09:08:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7-v6si3409916eda.85.2018.07.09.09.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 09:08:07 -0700 (PDT)
Date: Mon, 9 Jul 2018 18:08:06 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2] mm/fs: put_user_page() proposal
Message-ID: <20180709160806.xjt2l2pbmyiutbyi@quack2.suse.cz>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
 <20180709184937.7a70c3aa@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709184937.7a70c3aa@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon 09-07-18 18:49:37, Nicholas Piggin wrote:
> On Mon,  9 Jul 2018 01:05:52 -0700
> john.hubbard@gmail.com wrote:
> 
> > From: John Hubbard <jhubbard@nvidia.com>
> > 
> > Hi,
> > 
> > With respect to tracking get_user_pages*() pages with page->dma_pinned*
> > fields [1], I spent a few days retrofitting most of the get_user_pages*()
> > call sites, by adding calls to a new put_user_page() function, in place
> > of put_page(), where appropriate. This will work, but it's a large effort.
> > 
> > Design note: I didn't see anything that hinted at a way to fix this
> > problem, without actually changing all of the get_user_pages*() call sites,
> > so I think it's reasonable to start with that.
> > 
> > Anyway, it's still incomplete, but because this is a large, tree-wide
> > change (that will take some time and testing), I'd like to propose a plan,
> > before spamming zillions of people with put_user_page() conversion patches.
> > So I picked out the first two patches to show where this is going.
> > 
> > Proposed steps:
> > 
> > Step 1:
> > 
> > Start with the patches here, then continue with...dozens more.
> > This will eventually convert all of the call sites to use put_user_page().
> > This is easy in some places, but complex in others, such as:
> > 
> >     -- drivers/gpu/drm/amd
> >     -- bio
> >     -- fuse
> >     -- cifs
> >     -- anything from:
> >            git grep  iov_iter_get_pages | cut -f1 -d ':' | sort | uniq
> > 
> > The easy ones can be grouped into a single patchset, perhaps, and the
> > complex ones probably each need a patchset, in order to get the in-depth
> > review they'll need.
> > 
> > Furthermore, some of these areas I hope to attract some help on, once
> > this starts going.
> > 
> > Step 2:
> > 
> > In parallel, tidy up the core patchset that was discussed in [1], (version
> > 2 has already been reviewed, so I know what to do), and get it perfected
> > and reviewed. Don't apply it until step 1 is all done, though.
> > 
> > Step 3:
> > 
> > Activate refcounting of dma-pinned pages (essentially, patch #5, which is
> > [1]), but don't use it yet. Place a few WARN_ON_ONCE calls to start
> > mopping up any missed call sites.
> > 
> > Step 4:
> > 
> > After some soak time, actually connect it up (patch #6 of [1]) and start
> > taking action based on the new page->dma_pinned* fields.
> 
> You can use my decade old patch!
> 
> https://lkml.org/lkml/2009/2/17/113

The problem has a longer history than I thought ;)

> The problem with blocking in clear_page_dirty_for_io is that the fs is
> holding the page lock (or locks) and possibly others too. If you
> expect to have a bunch of long term references hanging around on the
> page, then there will be hangs and deadlocks everywhere. And if you do
> not have such log term references, then page lock (or some similar lock
> bit) for the duration of the DMA should be about enough?

There are two separate questions:

1) How to identify pages pinned for DMA? We have no bit in struct page to
use and we cannot reuse page lock as that immediately creates lock
inversions e.g. in direct IO code (which could be fixed but then good luck
with auditing all the other GUP users). Matthew had an idea and John
implemented it based on removing page from LRU and using that space in
struct page. So we at least have a way to identify pages that are pinned
and can track their pin count.

2) What to do when some page is pinned but we need to do e.g.
clear_page_dirty_for_io(). After some more thinking I agree with you that
just blocking waiting for page to unpin will create deadlocks like:

ext4_writepages()				ext4_direct_IO_write()
						  __blockdev_direct_IO()
						    iov_iter_get_pages()
						      - pins page
  handle = ext4_journal_start_with_reserve(inode, ...)
    - starts transaction
  ...
    lock_page(page)
    mpage_submit_page()
      clear_page_dirty_for_io(page) -> blocks on pin

						    ext4_dio_get_block_unwritten_sync()
						      - called to allocate
						        blocks for DIO
						    ext4_journal_start()
						      - may block and wait
						        for transaction
						        started by
							ext4_writepages() to
							finish

> I think it has to be more fundamental to the filesystem. Filesystem
> would get callbacks to register such long term dirtying on its files.
> Then it can do locking, resource allocation, -ENOTSUPP, etc.

Well, direct IO would not classify as long term dirtying I guess but still
regardless of how we identify pinned pages, just waiting in
clear_page_dirty_for_io() is going to cause deadlocks. So I agree with you
that the solution (but even for short term GUP users) will need filesystem
changes. I don't see a need for fs callbacks on pin time (as I don't see
much fs-specific work to do there) but we will probably need to provide a
way to wait for outstanding pins & preventing new ones for given mapping
range while writeback / unmapping is running.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
