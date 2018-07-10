Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 550A96B000A
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 03:51:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d5-v6so3515353edq.3
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 00:51:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10-v6si1456645edr.341.2018.07.10.00.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 00:51:56 -0700 (PDT)
Date: Tue, 10 Jul 2018 09:51:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/2] mm/fs: put_user_page() proposal
Message-ID: <20180710075154.lhaxaf6q35fnvdiq@quack2.suse.cz>
References: <20180709080554.21931-1-jhubbard@nvidia.com>
 <20180709184937.7a70c3aa@roar.ozlabs.ibm.com>
 <20180709160806.xjt2l2pbmyiutbyi@quack2.suse.cz>
 <20180709171651.GE2662@bombadil.infradead.org>
 <20180709194740.rymbt2fzohbdmpye@quack2.suse.cz>
 <20180709195657.GA29026@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709195657.GA29026@ziepe.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Nicholas Piggin <npiggin@gmail.com>, john.hubbard@gmail.com, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Mon 09-07-18 13:56:57, Jason Gunthorpe wrote:
> On Mon, Jul 09, 2018 at 09:47:40PM +0200, Jan Kara wrote:
> > On Mon 09-07-18 10:16:51, Matthew Wilcox wrote:
> > > On Mon, Jul 09, 2018 at 06:08:06PM +0200, Jan Kara wrote:
> > > > On Mon 09-07-18 18:49:37, Nicholas Piggin wrote:
> > > > > The problem with blocking in clear_page_dirty_for_io is that the fs is
> > > > > holding the page lock (or locks) and possibly others too. If you
> > > > > expect to have a bunch of long term references hanging around on the
> > > > > page, then there will be hangs and deadlocks everywhere. And if you do
> > > > > not have such log term references, then page lock (or some similar lock
> > > > > bit) for the duration of the DMA should be about enough?
> > > > 
> > > > There are two separate questions:
> > > > 
> > > > 1) How to identify pages pinned for DMA? We have no bit in struct page to
> > > > use and we cannot reuse page lock as that immediately creates lock
> > > > inversions e.g. in direct IO code (which could be fixed but then good luck
> > > > with auditing all the other GUP users). Matthew had an idea and John
> > > > implemented it based on removing page from LRU and using that space in
> > > > struct page. So we at least have a way to identify pages that are pinned
> > > > and can track their pin count.
> > > > 
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
> I think as a userspace I would expect the 'current content' to be
> flushed without waiting..

Yes but the problem is we cannot generally write out a page whose contents
is possibly changing (e.g. RAID5 checksums would then be wrong). But maybe
using bounce pages (and keeping original page still dirty) in such case would
be worth it - originally I thought using bounce pages would not bring us
much but now seeing problems with blocking in more detail maybe they are
worth the trouble after all...

> If you block fsync() then anyone using a RDMA MR with it will just
> dead lock. What happens if two processes open the same file and
> one makes a MR and the other calls fsync()? Sounds bad.

Yes, that's one of the reasons why we were discussing revoke mechanisms for
long term pins. But with bounce pages we could possibly avoid that (except
for cases like DAX + truncate where it's really unavoidable but there it's
a new functionality so mandating revoke and returning error otherwise is
fine I guess).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
