Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24AD56B0038
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 19:05:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id bv10so364935035pad.2
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 16:05:09 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f5si34126962pfe.26.2016.10.03.16.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 16:05:08 -0700 (PDT)
Date: Mon, 3 Oct 2016 17:05:06 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 00/12] re-enable DAX PMD support
Message-ID: <20161003230506.GA15947@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160929234345.GG27872@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929234345.GG27872@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Fri, Sep 30, 2016 at 09:43:45AM +1000, Dave Chinner wrote:
> On Thu, Sep 29, 2016 at 04:49:18PM -0600, Ross Zwisler wrote:
> > DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> > locking.  This series allows DAX PMDs to participate in the DAX radix tree
> > based locking scheme so that they can be re-enabled.
> > 
> > Ted, can you please take the ext2 + ext4 patches through your tree?  Dave,
> > can you please take the rest through the XFS tree?
> 
> That will make merging this difficult, because later patches in the
> series are dependent on the ext2/ext4 patches early in the series.
> I'd much prefer they all go through the one tree to avoid issues
> like this.

I think that at least some of the ext2 patches at least will be merged in v4.9
through Ted's tree because they are just bugfixes.  For whatever is left I'm
happy to have it merged to v4.10 through the XFS tree, thank you.

> > 
> > Changes since v3:
> >  - Corrected dax iomap code namespace for functions defined in fs/dax.c.
> >    (Dave Chinner)
> >  - Added leading "dax" namespace to new static functions in fs/dax.c.
> >    (Dave Chinner)
> >  - Made all DAX PMD code in fs/dax.c conditionally compiled based on
> >    CONFIG_FS_DAX_PMD.  Otherwise a stub in include/linux/dax.h that just
> >    returns VM_FAULT_FALLBACK will be used.  (Dave Chinner)
> >  - Removed dynamic debugging messages from DAX PMD fault path.  Debugging
> >    tracepoints will be added later to both the PTE and PMD paths via a
> >    later patch set. (Dave Chinner)
> >  - Added a comment to ext2_dax_vm_ops explaining why we don't support DAX
> >    PMD faults in ext2. (Dave Chinner)
> > 
> > This was built upon xfs/for-next with PMD performance fixes from Toshi Kani
> > and Dan Williams.  Dan's patch has already been merged for v4.8, and
> > Toshi's patches are currently queued in Andrew Morton's mm tree for v4.9
> > inclusion.
> 
> the xfs/for-next branch is not a stable branch - it can rebase at
> any time just like linux-next can. The topic branches that I merge
> into the for-next branch, OTOH, are usually stable. i.e. The topic
> branch you should be basing this on is "iomap-4.9-dax".

Thanks, I didn't realize that.  I'll rebase onto iomap-4.9-dax, then on a
v4.9-rc when things become more stable.

> And then you'll also see that there are already ext2 patches in this
> topic branch to convert it to iomap for DAX. So I'm quite happy to
> take the ext2/4 patches in this series in the same way.
> 
> The patches from Dan and Toshi: is you patch series dependent on
> them? Do I need to take them as well?

Nope, Dan and Toshi's patches are just performance fixes, and should be merged
through other trees for v4.9.

> > Previously reported performance numbers:
> > 
> >   [global]
> >   bs=4k
> >   size=2G
> >   directory=/mnt/pmem0
> >   ioengine=mmap
> >   [randrw]
> >   rw=randrw
> > 
> > Here are the performance results with XFS using only pte faults:
> >    READ: io=1022.7MB, aggrb=557610KB/s, minb=557610KB/s, maxb=557610KB/s, mint=1878msec, maxt=1878msec
> >   WRITE: io=1025.4MB, aggrb=559084KB/s, minb=559084KB/s, maxb=559084KB/s, mint=1878msec, maxt=1878msec
> > 
> > Here are performance numbers for that same test using PMD faults:
> >    READ: io=1022.7MB, aggrb=1406.7MB/s, minb=1406.7MB/s, maxb=1406.7MB/s, mint=727msec, maxt=727msec
> >   WRITE: io=1025.4MB, aggrb=1410.4MB/s, minb=1410.4MB/s, maxb=1410.4MB/s, mint=727msec, maxt=727msec
> 
> The numbers look good - how much of that is from lower filesystem
> allocation overhead and how much of it is from fewer page faults?
> You can probably determine this by creating the test file with
> write() to ensure it is fully allocated and so all the filesystem
> is doing on both the read and write paths is mapping allocated
> regions....

Perhaps I'm doing something wrong, but I think that the first time I run the
test I get all allocating writes because that's when the file is first
created.  The file stays around between runs, though, so every run thereafter
should already have a fully allocated file, so the only overhead difference
should be page faults?  Does this sound correct?

If that's true, the performance gain seems to be almost entirely due to fewer
page faults.  For both the 4k case and the 2M case there isn't a noticeable
performance difference between the unallocated vs fully allocated cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
