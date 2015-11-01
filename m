Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A764A82F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 18:30:05 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so4186744pab.0
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 15:30:05 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id ug9si17833234pab.185.2015.11.01.15.30.03
        for <linux-mm@kvack.org>;
        Sun, 01 Nov 2015 15:30:04 -0800 (PST)
Date: Mon, 2 Nov 2015 10:29:48 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 00/11] DAX fsynx/msync support
Message-ID: <20151101232948.GF10656@dastard>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
 <20151030035533.GU19199@dastard>
 <20151030183938.GC24643@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151030183938.GC24643@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Fri, Oct 30, 2015 at 12:39:38PM -0600, Ross Zwisler wrote:
> On Fri, Oct 30, 2015 at 02:55:33PM +1100, Dave Chinner wrote:
> > On Thu, Oct 29, 2015 at 02:12:04PM -0600, Ross Zwisler wrote:
> > > This patch series adds support for fsync/msync to DAX.
> > > 
> > > Patches 1 through 8 add various utilities that the DAX code will eventually
> > > need, and the DAX code itself is added by patch 9.  Patches 10 and 11 are
> > > filesystem changes that are needed after the DAX code is added, but these
> > > patches may change slightly as the filesystem fault handling for DAX is
> > > being modified ([1] and [2]).
> > > 
> > > I've marked this series as RFC because I'm still testing, but I wanted to
> > > get this out there so people would see the direction I was going and
> > > hopefully comment on any big red flags sooner rather than later.
> > > 
> > > I realize that we are getting pretty dang close to the v4.4 merge window,
> > > but I think that if we can get this reviewed and working it's a much better
> > > solution than the "big hammer" approach that blindly flushes entire PMEM
> > > namespaces [3].
> > 
> > We need the "big hammer" regardless of fsync. If REQ_FLUSH and
> > REQ_FUA don't do the right thing when it comes to ordering journal
> > writes against other IO operations, then the filesystems are not
> > crash safe. i.e. we need REQ_FLUSH/REQ_FUA to commit all outstanding
> > changes back to stable storage, just like they do for existing
> > storage....
> 
> I think that what I've got here (when it's fully working) will protect all the
> cases that we need.
> 
> AFAIK there are three ways that data can be written to a PMEM namespace:
> 
> 1) Through the PMEM driver via either pmem_make_request(), pmem_rw_page() or
> pmem_rw_bytes().  All of these paths sync the newly written data durably to
> media before the I/O completes so they shouldn't have any reliance on
> REQ_FUA/REQ_FLUSH.

I suspect that not all future pmem devices will use this
driver/interface/semantics.

Further, REQ_FLUSH/REQ_FUA are more than just "put the data on stable
storage" commands. They are also IO barriers that affect scheduling
of IOs in progress and in the request queues.  A REQ_FLUSH/REQ_FUA
IO cannot be dispatched before all prior IO has been dispatched and
drained from the request queue, and IO submitted after a queued
REQ_FLUSH/REQ_FUA cannot be scheduled ahead of the queued
REQ_FLUSH/REQ_FUA operation.

IOWs, REQ_FUA/REQ_FLUSH not only guarantee data is on stable
storage, they also guarantee the order of IO dispatch and
completion when concurrent IO is in progress.


> 2) Through the DAX I/O path, dax_io().  As with PMEM we flush the newly
> written data durably to media before the I/O operation completes, so this path
> shouldn't have any reliance on REQ_FUA/REQ_FLUSH.

That's fine, but that's not the problem we need solved ;)

> 3) Through mmaps set up by DAX.  This is the path we are trying to protect
> with the dirty page tracking and flushing in this patch set, and I think that
> this is the only path that has reliance on REQ_FLUSH.

Quite possibly this is the case for the current intel pmem driver,
but I don't look at the functionality from that perspective.

Dirty page tracking is needed to enable "data writeback", whether it
be CPU cachelines via pcommit() or dirty pages via submit_bio(). How
the pages get dirty is irrelevant - the fact is they are dirty and
we need to do /something/ to ensure they are correctly written back
to the storage layer.

REQ_FLUSH is needed to guarantee all data that has been written back
to the storage layer is persistent in that layer.  How a /driver/
manages that is up to the driver - the actual implementation is
irrelevant to the higher layers. i.e. what we are concerned about at
the filesystem level is that:

	a) "data writeback" is started correctly;
	b) the "data writeback" is completed; and
	c) volatile caches are completely flushed before we write
	   the metadata changes that reference that data to the
	   journal via FUA

e.g. we could have pmem, but we are using buffered IO (i.e. non-DAX)
and a hardware driver that doesn't flush CPU cachelines in the
physical IO path. This requires that driver to flush CPU cachelines
and place memory barriers in REQ_FLUSH operations, as well as after
writing the data in REQ_FUA operations.  Yes, this is different to
the way the intel pmem drivers work (i.e.  as noted in 1) above),
but it is /not wrong/ as long as REQ_FLUSH/REQ_FUA also flush dirty
cpu cachelines.

IOWs, the high level code we write that implements fsync
for DAX needs to be generic enough so that when something slightly
different comes along we don't have to throw everything away and
start again. I think your code will end up being generic enough to
handle this, but let's make sure we don't implement something that
can only work with pmem hardware/drivers that do all IO as fully
synchronous to the stable domain...

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
