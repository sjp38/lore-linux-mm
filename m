Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA2506B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:08:49 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v77so42633022pgb.15
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 10:08:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m4si818495pln.696.2017.08.11.10.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 10:08:48 -0700 (PDT)
Date: Fri, 11 Aug 2017 10:08:47 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170811170847.GK31390@bombadil.infradead.org>
References: <20170810042849.GK21024@dastard>
 <20170810161159.GI31390@bombadil.infradead.org>
 <20170811042519.GS21024@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811042519.GS21024@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 11, 2017 at 02:25:19PM +1000, Dave Chinner wrote:
> On Thu, Aug 10, 2017 at 09:11:59AM -0700, Matthew Wilcox wrote:
> > On Thu, Aug 10, 2017 at 02:28:49PM +1000, Dave Chinner wrote:
> > > If we scale this up to a container host which is using reflink trees
> > > it's shared root images, there might be hundreds of copies of the
> > > same data held in cache (i.e. one page per container). Given that
> > > the filesystem knows that the underlying data extent is shared when
> > > we go to read it, it's relatively easy to add mechanisms to the
> > > filesystem to return the same page for all attempts to read the
> > > from a shared extent from all inodes that share it.
> > 
> > I agree the problem exists.  Should we try to fix this problem, or
> > should we steer people towards solutions which don't have this problem?
> > The solutions I've been seeing use COW block devices instead of COW
> > filesystems, and DAX to share the common pages between the host and
> > each guest.
> 
> That's one possible solution for people using hardware
> virutalisation, but not everyone is doing that. It also relies on
> block devices, which rules out a whole bunch of interesting stuff we
> can do with filesystems...

Assuming there's something fun we can do with filesystems that's
interesting to this type of user, what do you think to this:

Create a block device (maybe it's a loop device, maybe it's dm-raid0)
which supports DAX and uses the page cache to cache the physical pages
of the block device it's fronting.

Use XFS+reflink+DAX on top of this loop device.  Now there's only one
copy of each page in RAM.

We'd need to be able to shoot down all mapped pages when evicting pages
from the loop device's page cache, but we have the right data structures
in place for that; we just need to use them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
