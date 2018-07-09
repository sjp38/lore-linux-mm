Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2086B032E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 15:47:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a22-v6so7688696eds.13
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 12:47:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r11-v6si1227463edp.9.2018.07.09.12.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 12:47:49 -0700 (PDT)
Date: Mon, 9 Jul 2018 21:47:40 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2] mm/fs: put_user_page() proposal
Message-ID: <20180709194740.rymbt2fzohbdmpye@quack2.suse.cz>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
 <20180709184937.7a70c3aa@roar.ozlabs.ibm.com>
 <20180709160806.xjt2l2pbmyiutbyi@quack2.suse.cz>
 <20180709171651.GE2662@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709171651.GE2662@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, john.hubbard@gmail.com, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon 09-07-18 10:16:51, Matthew Wilcox wrote:
> On Mon, Jul 09, 2018 at 06:08:06PM +0200, Jan Kara wrote:
> > On Mon 09-07-18 18:49:37, Nicholas Piggin wrote:
> > > The problem with blocking in clear_page_dirty_for_io is that the fs is
> > > holding the page lock (or locks) and possibly others too. If you
> > > expect to have a bunch of long term references hanging around on the
> > > page, then there will be hangs and deadlocks everywhere. And if you do
> > > not have such log term references, then page lock (or some similar lock
> > > bit) for the duration of the DMA should be about enough?
> > 
> > There are two separate questions:
> > 
> > 1) How to identify pages pinned for DMA? We have no bit in struct page to
> > use and we cannot reuse page lock as that immediately creates lock
> > inversions e.g. in direct IO code (which could be fixed but then good luck
> > with auditing all the other GUP users). Matthew had an idea and John
> > implemented it based on removing page from LRU and using that space in
> > struct page. So we at least have a way to identify pages that are pinned
> > and can track their pin count.
> > 
> > 2) What to do when some page is pinned but we need to do e.g.
> > clear_page_dirty_for_io(). After some more thinking I agree with you that
> > just blocking waiting for page to unpin will create deadlocks like:
> 
> Why are we trying to writeback a page that is pinned?  It's presumed to
> be continuously redirtied by its pinner.  We can't evict it.

So what should be a result of fsync(file), where some 'file' pages are
pinned e.g. by running direct IO? If we just skip those pages, we'll lie to
userspace that data was committed while it was not (and it's not only about
data that has landed in those pages via DMA, you can have first 1k of a page
modified by normal IO in parallel to DMA modifying second 1k chunk). If
fsync(2) returns error, it would be really unexpected by userspace and most
apps will just not handle that correctly. So what else can you do than
block?

> > ext4_writepages()				ext4_direct_IO_write()
> > 						  __blockdev_direct_IO()
> > 						    iov_iter_get_pages()
> > 						      - pins page
> >   handle = ext4_journal_start_with_reserve(inode, ...)
> >     - starts transaction
> >   ...
> >     lock_page(page)
> >     mpage_submit_page()
> >       clear_page_dirty_for_io(page) -> blocks on pin
> 
> I don't think it should block.  It should fail.

See above...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
