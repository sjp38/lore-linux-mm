Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA8006B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:29:39 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so23258044pab.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:29:39 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id ok14si2916013pdb.2.2015.03.25.02.29.37
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 02:29:38 -0700 (PDT)
Date: Wed, 25 Mar 2015 20:29:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
Message-ID: <20150325092922.GH31342@dastard>
References: <55100B78.501@plexistor.com>
 <55100D10.6090902@plexistor.com>
 <20150323224047.GQ28621@dastard>
 <551100E3.9010007@plexistor.com>
 <20150325022221.GA31342@dastard>
 <55126D77.7040105@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55126D77.7040105@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On Wed, Mar 25, 2015 at 10:10:31AM +0200, Boaz Harrosh wrote:
> On 03/25/2015 04:22 AM, Dave Chinner wrote:
> > On Tue, Mar 24, 2015 at 08:14:59AM +0200, Boaz Harrosh wrote:
> <>
> > 
> > Then we have wider problem with DAX, then: sync doesn't work
> > properly. i.e. if we still has write mapped pages, then we haven't
> > flushed dirty cache lines on write-mapped files to the persistent
> > domain by the time sync completes.
> > 
> > So, this shouldn't be some special case that only the freeze code
> > takes into account - we need to make sure that sync (and therefore
> > freeze) flushes all dirty cache lines and marks all mappings
> > clean....
> > 
> 
> This is not how I understood it and how I read the code.
> 
> The sync does happen, .fsync of the FS is called on each
> file just as if the user called it. If this is broken it just
> needs to be fixed there at the .fsync vector. POSIX mandate
> persistence at .fsync so at the vfs layer we rely on that.

right now, the filesystems will see that there are no dirty pages
on the inode, and then just sync the inode metadata. They will do
nothing else as filesystems are not aware of CPU cachelines at all.

> So everything at this stage should be synced to real media.

Actually no. This is what intel are introducing new CPU instructions
for - so fsync can flush the cpu caches and commit them to th
persistence domain correctly.

> What does not happen is writeback. since dax does not have
> any writeback.

Which is precisely the problem we need to address - we don't need
writeback to a block device, but we do need the dirty CPU cachelines
flushed and the mappings cleaned.

> And because of that nothing turned the
> user mappings to read only. This is what I do here but
> instead of write-protecting I just unmap because it is
> easier for me to code it.

That doesn't mean it is the correct solution.

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
