Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B78A6B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 17:50:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f66so525258oib.1
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 14:50:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor887800otf.316.2017.10.31.14.50.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 14:50:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031151907.GB26128@quack2.suse.cz>
References: <20171024152415.22864-1-jack@suse.cz> <20171024152415.22864-18-jack@suse.cz>
 <20171024222322.GX3666@dastard> <20171026154804.GF31161@quack2.suse.cz>
 <20171026211611.GC3666@dastard> <20171027100834.GH31161@quack2.suse.cz> <20171031151907.GB26128@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 14:50:01 -0700
Message-ID: <CAPcyv4gBVyZ8KhB2s1M0BdhC1=HAean6Mb6oV7zsJBx0-t3bhw@mail.gmail.com>
Subject: Re: [PATCH 17/17] xfs: support for synchronous DAX faults
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4 <linux-ext4@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>

On Tue, Oct 31, 2017 at 8:19 AM, Jan Kara <jack@suse.cz> wrote:
> On Fri 27-10-17 12:08:34, Jan Kara wrote:
>> On Fri 27-10-17 08:16:11, Dave Chinner wrote:
>> > On Thu, Oct 26, 2017 at 05:48:04PM +0200, Jan Kara wrote:
>> > > > > diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
>> > > > > index f179bdf1644d..b43be199fbdf 100644
>> > > > > --- a/fs/xfs/xfs_iomap.c
>> > > > > +++ b/fs/xfs/xfs_iomap.c
>> > > > > @@ -33,6 +33,7 @@
>> > > > >  #include "xfs_error.h"
>> > > > >  #include "xfs_trans.h"
>> > > > >  #include "xfs_trans_space.h"
>> > > > > +#include "xfs_inode_item.h"
>> > > > >  #include "xfs_iomap.h"
>> > > > >  #include "xfs_trace.h"
>> > > > >  #include "xfs_icache.h"
>> > > > > @@ -1086,6 +1087,10 @@ xfs_file_iomap_begin(
>> > > > >               trace_xfs_iomap_found(ip, offset, length, 0, &imap);
>> > > > >       }
>> > > > >
>> > > > > +     if ((flags & IOMAP_WRITE) && xfs_ipincount(ip) &&
>> > > > > +         (ip->i_itemp->ili_fsync_fields & ~XFS_ILOG_TIMESTAMP))
>> > > > > +             iomap->flags |= IOMAP_F_DIRTY;
>> > > >
>> > > > This is the very definition of an inode that is "fdatasync dirty".
>> > > >
>> > > > Hmmmm, shouldn't this also be set for read faults, too?
>> > >
>> > > No, read faults don't need to set IOMAP_F_DIRTY since user cannot write any
>> > > data to the page which he'd then like to be persistent. The only reason why
>> > > I thought it could be useful for a while was that it would be nice to make
>> > > MAP_SYNC mapping provide the guarantee that data you see now is the data
>> > > you'll see after a crash
>> >
>> > Isn't that the entire point of MAP_SYNC? i.e. That when we return
>> > from a page fault, the app knows that the data and it's underlying
>> > extent is on persistent storage?
>> >
>> > > but we cannot provide that guarantee for RO
>> > > mapping anyway if someone else has the page mapped as well. So I just
>> > > decided not to return IOMAP_F_DIRTY for read faults.
>> >
>> > If there are multiple MAP_SYNC mappings to the inode, I would have
>> > expected that they all sync all of the data/metadata on every page
>> > fault, regardless of who dirtied the inode. An RO mapping doesn't
>>
>> Well, they all do sync regardless of who dirtied the inode on every *write*
>> fault.
>>
>> > mean the data/metadata on the inode can't change, it just means it
>> > can't change through that mapping.  Running fsync() to guarantee the
>> > persistence of that data/metadata doesn't actually changing any
>> > data....
>> >
>> > IOWs, if read faults don't guarantee the mapped range has stable
>> > extents on a MAP_SYNC mapping, then I think MAP_SYNC is broken
>> > because it's not giving consistent guarantees to userspace. Yes, it
>> > works fine when only one MAP_SYNC mapping is modifying the inode,
>> > but the moment we have concurrent operations on the inode that
>> > aren't MAP_SYNC or O_SYNC this goes out the window....
>>
>> MAP_SYNC as I've implemented it provides guarantees only for data the
>> process has actually written. I agree with that and it was a conscious
>> decision. In my opinion that covers most usecases, provides reasonably
>> simple semantics (i.e., if you write data through MAP_SYNC mapping, you can
>> persist it just using CPU instructions), and reasonable performance.
>>
>> Now you seem to suggest the semantics should be: "Data you have read from or
>> written to a MAP_SYNC mapping can be persisted using CPU instructions." And
>> from implementation POV we can do that rather easily (just rip out the
>> IOMAP_WRITE checks). But I'm unsure whether this additional guarantee would
>> be useful enough to justify the slowdown of read faults? I was not able to
>> come up with a good usecase and so I've decided for current semantics. What
>> do other people think?
>
> Nobody commented on this for couple of days so how do we proceed? I would
> prefer to go just with a guarantee for data written and we can always make
> the guarantee stronger (i.e. apply it also for read data) when some user
> comes with a good usecase?

I think it is easier to strengthen the guarantee than loosen it later
especially since it is not yet clear that we have a use case for the
stronger semantic. At least the initial motivation for MAP_SYNC was
for writers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
