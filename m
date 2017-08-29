Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A5F2F6B02F3
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 17:52:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y15so8576138pgc.9
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 14:52:02 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id a102si3085728pli.375.2017.08.29.14.52.00
        for <linux-mm@kvack.org>;
        Tue, 29 Aug 2017 14:52:01 -0700 (PDT)
Date: Wed, 30 Aug 2017 07:51:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab
 cache
Message-ID: <20170829215157.GC10621@dastard>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
 <20170829081453.GA10196@infradead.org>
 <20170829123126.GB10621@dastard>
 <20170829124536.GA26339@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829124536.GA26339@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Tue, Aug 29, 2017 at 05:45:36AM -0700, Christoph Hellwig wrote:
> On Tue, Aug 29, 2017 at 10:31:26PM +1000, Dave Chinner wrote:
> > Probably should.  I've already been looking at killing the inline
> > extents array to simplify the management of the extent list (much
> > simpler to index by rbtree when we don't have direct/indirect
> > structures), so killing the inline data would get rid of the other
> > part of the union the inline data sits in.
> 
> That's exactly where I came form with my extent list work.  Although
> the rbtree performance was horrible due to the memory overhead and
> I've switched to a modified b+tree at the moment..

Right, I've looked at btrees, too, but it's more complex than just
using an rbtree. I originally looked at using Peter Z's old
RCU-aware btree code, but it doesn't hold data in the tree leaves.
So that needed significant modification to make work without a
memory alloc per extent and that didn't work with original aim of
RCU-safe extent lookups.  I also looked at that "generic" btree
stuff that came from logfs, and after a little while ran away
screaming. So if we are going to use a b+tree, it sounds like you
are probably going the right way.

As it is, I've been looking at using interval tree - I have kinda
working code - which basically leaves the page based extent arrays
intact but adds an rbnode/interval state header to the start of each
page to track the offsets within the node and propagate them back up
to the root for fast offset based extent lookups. With a lookaside
cache on the root, it should behave and perform almost identically
to the current indirect array and should have very little extra
overhead....

The sticking point, IMO, is the extent array index based lookups in
all the bmbt code.  I've been looking at converting all that to use
offset based lookups and a cursor w/ lookup/inc/dec/insert/delete
ioperations wrapping xfs_iext_lookup_ext() and friends. This means
the modifications are pretty much identical to the on-disk extent
btree, so they can be abstracted out into a single extent update
interface for both trees.  Have you planned/done any cleanup/changes
with this code?

> > OTOH, if we're going to have to dynamically allocate the memory for
> > the extent/inline data for the data fork, it may just be easier to
> > make the entire data fork a dynamic allocation (like the attr fork).
> 
> I though about this a bit, but it turned out that we basically
> always need the data anyway, so I don't think it's going to buy
> us much unless we shrink the inode enough so that they better fit
> into a page.

True. Keep it mind for when we've shrunk the inode by another
100 bytes...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
