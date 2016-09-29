Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C55B6B025E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 19:44:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j69so13797310itb.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 16:44:07 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id t62si1044708itd.21.2016.09.29.16.43.50
        for <linux-mm@kvack.org>;
        Thu, 29 Sep 2016 16:43:51 -0700 (PDT)
Date: Fri, 30 Sep 2016 09:43:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 00/12] re-enable DAX PMD support
Message-ID: <20160929234345.GG27872@dastard>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Sep 29, 2016 at 04:49:18PM -0600, Ross Zwisler wrote:
> DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> locking.  This series allows DAX PMDs to participate in the DAX radix tree
> based locking scheme so that they can be re-enabled.
> 
> Ted, can you please take the ext2 + ext4 patches through your tree?  Dave,
> can you please take the rest through the XFS tree?

That will make merging this difficult, because later patches in the
series are dependent on the ext2/ext4 patches early in the series.
I'd much prefer they all go through the one tree to avoid issues
like this.

> 
> Changes since v3:
>  - Corrected dax iomap code namespace for functions defined in fs/dax.c.
>    (Dave Chinner)
>  - Added leading "dax" namespace to new static functions in fs/dax.c.
>    (Dave Chinner)
>  - Made all DAX PMD code in fs/dax.c conditionally compiled based on
>    CONFIG_FS_DAX_PMD.  Otherwise a stub in include/linux/dax.h that just
>    returns VM_FAULT_FALLBACK will be used.  (Dave Chinner)
>  - Removed dynamic debugging messages from DAX PMD fault path.  Debugging
>    tracepoints will be added later to both the PTE and PMD paths via a
>    later patch set. (Dave Chinner)
>  - Added a comment to ext2_dax_vm_ops explaining why we don't support DAX
>    PMD faults in ext2. (Dave Chinner)
> 
> This was built upon xfs/for-next with PMD performance fixes from Toshi Kani
> and Dan Williams.  Dan's patch has already been merged for v4.8, and
> Toshi's patches are currently queued in Andrew Morton's mm tree for v4.9
> inclusion.

the xfs/for-next branch is not a stable branch - it can rebase at
any time just like linux-next can. The topic branches that I merge
into the for-next branch, OTOH, are usually stable. i.e. The topic
branch you should be basing this on is "iomap-4.9-dax".

And then you'll also see that there are already ext2 patches in this
topic branch to convert it to iomap for DAX. So I'm quite happy to
take the ext2/4 patches in this series in the same way.

The patches from Dan and Toshi: is you patch series dependent on
them? Do I need to take them as well?

Finally: none of the patches in your tree have reviewed-by tags.
That says to me that none of this code has been reviewed yet.
Reviewed-by tags are non-negotiable requirement for anything going
through my trees. I don't have time right now to review this code,
so you're going to need to chase up other reviewers before merging.

And, really, this is getting very late in the cycle to be merging
new code - we're less than one working day away from the merge
window opening and we've missed the last linux-next build. I'd
suggest that we'd might be best served by slipping this to the PMD
support code to the next cycle when there's no time pressure for
review and we can get a decent linux-next soak on the code.

> This tree has passed xfstests for ext2, ext4 and XFS both with and without DAX,
> and has passed targeted testing where I inserted, removed and flushed DAX PTEs
> and PMDs in every combination I could think of.
> 
> Previously reported performance numbers:
> 
>   [global]
>   bs=4k
>   size=2G
>   directory=/mnt/pmem0
>   ioengine=mmap
>   [randrw]
>   rw=randrw
> 
> Here are the performance results with XFS using only pte faults:
>    READ: io=1022.7MB, aggrb=557610KB/s, minb=557610KB/s, maxb=557610KB/s, mint=1878msec, maxt=1878msec
>   WRITE: io=1025.4MB, aggrb=559084KB/s, minb=559084KB/s, maxb=559084KB/s, mint=1878msec, maxt=1878msec
> 
> Here are performance numbers for that same test using PMD faults:
>    READ: io=1022.7MB, aggrb=1406.7MB/s, minb=1406.7MB/s, maxb=1406.7MB/s, mint=727msec, maxt=727msec
>   WRITE: io=1025.4MB, aggrb=1410.4MB/s, minb=1410.4MB/s, maxb=1410.4MB/s, mint=727msec, maxt=727msec

The numbers look good - how much of that is from lower filesystem
allocation overhead and how much of it is from fewer page faults?
You can probably determine this by creating the test file with
write() to ensure it is fully allocated and so all the filesystem
is doing on both the read and write paths is mapping allocated
regions....

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
