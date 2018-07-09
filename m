Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE446B0304
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 13:17:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id ba8-v6so10522203plb.4
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 10:17:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f3-v6si14328017plr.214.2018.07.09.10.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Jul 2018 10:16:59 -0700 (PDT)
Date: Mon, 9 Jul 2018 10:16:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] mm/fs: put_user_page() proposal
Message-ID: <20180709171651.GE2662@bombadil.infradead.org>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
 <20180709184937.7a70c3aa@roar.ozlabs.ibm.com>
 <20180709160806.xjt2l2pbmyiutbyi@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709160806.xjt2l2pbmyiutbyi@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Nicholas Piggin <npiggin@gmail.com>, john.hubbard@gmail.com, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon, Jul 09, 2018 at 06:08:06PM +0200, Jan Kara wrote:
> On Mon 09-07-18 18:49:37, Nicholas Piggin wrote:
> > The problem with blocking in clear_page_dirty_for_io is that the fs is
> > holding the page lock (or locks) and possibly others too. If you
> > expect to have a bunch of long term references hanging around on the
> > page, then there will be hangs and deadlocks everywhere. And if you do
> > not have such log term references, then page lock (or some similar lock
> > bit) for the duration of the DMA should be about enough?
> 
> There are two separate questions:
> 
> 1) How to identify pages pinned for DMA? We have no bit in struct page to
> use and we cannot reuse page lock as that immediately creates lock
> inversions e.g. in direct IO code (which could be fixed but then good luck
> with auditing all the other GUP users). Matthew had an idea and John
> implemented it based on removing page from LRU and using that space in
> struct page. So we at least have a way to identify pages that are pinned
> and can track their pin count.
> 
> 2) What to do when some page is pinned but we need to do e.g.
> clear_page_dirty_for_io(). After some more thinking I agree with you that
> just blocking waiting for page to unpin will create deadlocks like:

Why are we trying to writeback a page that is pinned?  It's presumed to
be continuously redirtied by its pinner.  We can't evict it.

> ext4_writepages()				ext4_direct_IO_write()
> 						  __blockdev_direct_IO()
> 						    iov_iter_get_pages()
> 						      - pins page
>   handle = ext4_journal_start_with_reserve(inode, ...)
>     - starts transaction
>   ...
>     lock_page(page)
>     mpage_submit_page()
>       clear_page_dirty_for_io(page) -> blocks on pin

I don't think it should block.  It should fail.
