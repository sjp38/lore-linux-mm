Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96B1C6B0006
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 16:00:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w11-v6so6256635pfk.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 13:00:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c11-v6si14722718plo.271.2018.07.09.13.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Jul 2018 13:00:57 -0700 (PDT)
Date: Mon, 9 Jul 2018 13:00:49 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] mm/fs: put_user_page() proposal
Message-ID: <20180709200049.GA5335@bombadil.infradead.org>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
 <20180709184937.7a70c3aa@roar.ozlabs.ibm.com>
 <20180709160806.xjt2l2pbmyiutbyi@quack2.suse.cz>
 <20180709171651.GE2662@bombadil.infradead.org>
 <20180709194740.rymbt2fzohbdmpye@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709194740.rymbt2fzohbdmpye@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Nicholas Piggin <npiggin@gmail.com>, john.hubbard@gmail.com, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon, Jul 09, 2018 at 09:47:40PM +0200, Jan Kara wrote:
> On Mon 09-07-18 10:16:51, Matthew Wilcox wrote:
> > > 2) What to do when some page is pinned but we need to do e.g.
> > > clear_page_dirty_for_io(). After some more thinking I agree with you that
> > > just blocking waiting for page to unpin will create deadlocks like:
> > 
> > Why are we trying to writeback a page that is pinned?  It's presumed to
> > be continuously redirtied by its pinner.  We can't evict it.
> 
> So what should be a result of fsync(file), where some 'file' pages are
> pinned e.g. by running direct IO? If we just skip those pages, we'll lie to
> userspace that data was committed while it was not (and it's not only about
> data that has landed in those pages via DMA, you can have first 1k of a page
> modified by normal IO in parallel to DMA modifying second 1k chunk). If
> fsync(2) returns error, it would be really unexpected by userspace and most
> apps will just not handle that correctly. So what else can you do than
> block?

I was thinking about writeback, and neglected the fsync case.  For fsync,
we could copy the "current" contents of the page to a freshly-allocated
page and write _that_ to disc?  As long as we redirty the real page after
the pin is dropped, I think we're fine.
