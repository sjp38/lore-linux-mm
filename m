Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB576B000A
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 04:21:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n2-v6so8319492edr.5
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 01:21:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o16-v6si2444327edo.118.2018.07.10.01.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 01:21:07 -0700 (PDT)
Date: Tue, 10 Jul 2018 10:21:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2] mm/fs: put_user_page() proposal
Message-ID: <20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
 <20180709184937.7a70c3aa@roar.ozlabs.ibm.com>
 <20180709160806.xjt2l2pbmyiutbyi@quack2.suse.cz>
 <20180709171651.GE2662@bombadil.infradead.org>
 <20180709194740.rymbt2fzohbdmpye@quack2.suse.cz>
 <20180709200049.GA5335@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709200049.GA5335@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, john.hubbard@gmail.com, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon 09-07-18 13:00:49, Matthew Wilcox wrote:
> On Mon, Jul 09, 2018 at 09:47:40PM +0200, Jan Kara wrote:
> > On Mon 09-07-18 10:16:51, Matthew Wilcox wrote:
> > > > 2) What to do when some page is pinned but we need to do e.g.
> > > > clear_page_dirty_for_io(). After some more thinking I agree with you that
> > > > just blocking waiting for page to unpin will create deadlocks like:
> > > 
> > > Why are we trying to writeback a page that is pinned?  It's presumed to
> > > be continuously redirtied by its pinner.  We can't evict it.
> > 
> > So what should be a result of fsync(file), where some 'file' pages are
> > pinned e.g. by running direct IO? If we just skip those pages, we'll lie to
> > userspace that data was committed while it was not (and it's not only about
> > data that has landed in those pages via DMA, you can have first 1k of a page
> > modified by normal IO in parallel to DMA modifying second 1k chunk). If
> > fsync(2) returns error, it would be really unexpected by userspace and most
> > apps will just not handle that correctly. So what else can you do than
> > block?
> 
> I was thinking about writeback, and neglected the fsync case.

For memory cleaning writeback skipping is certainly the right thing to do
and that's what we plan to do.

> For fsync, we could copy the "current" contents of the page to a
> freshly-allocated page and write _that_ to disc?  As long as we redirty
> the real page after the pin is dropped, I think we're fine.

So for record, this technique is called "bouncing" in block layer
terminology and we do have a support for it there (see block/bounce.c). It
would need some tweaking (e.g. a bio flag to indicate that some page in a
bio needs bouncing if underlying storage requires stable pages) but that is
easy to do - we even had support for something similar some years back as
ext3 needed it to provide guarantee metadata buffer cannot be modified
while IO is running on it.

I was actually already considering using this some time ago but then
disregarded it as it seemed it won't buy us much compared to blocking /
skipping. But now seeing the troubles with blocking, using page bouncing
for situations where we cannot just skip page writeout looks indeed
appealing. Thanks for suggesting that!

As a side note I'm not 100% decided whether it is better to keep the
original page dirty all the time while it is pinned or not. I'm more
inclined to keeping it dirty all the time as it gives mm more accurate
information about the amount of really dirty pages, prevents reclaim of
filesystem's dirtiness / allocation tracking information (buffers or
whatever it has attached to the page), and generally avoids "surprising"
set_page_dirty() once page is unpinned (one less dirtying path for
filesystems to care about). OTOH it would make flusher threads always try
to writeback these pages only to skip them, fsync(2) would always write
them, etc...

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
