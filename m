Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79F8F6B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 15:25:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so85559683pfk.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 12:25:23 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id yt2si13005089pab.224.2016.10.13.12.25.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 12:25:22 -0700 (PDT)
Date: Thu, 13 Oct 2016 13:25:20 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v6 15/17] dax: add struct iomap based DAX PMD support
Message-ID: <20161013192520.GB26922@linux.intel.com>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
 <20161012225022.15507-16-ross.zwisler@linux.intel.com>
 <20161013154224.GB30680@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013154224.GB30680@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Oct 13, 2016 at 05:42:24PM +0200, Jan Kara wrote:
> On Wed 12-10-16 16:50:20, Ross Zwisler wrote:
> > DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> > locking.  This patch allows DAX PMDs to participate in the DAX radix tree
> > based locking scheme so that they can be re-enabled using the new struct
> > iomap based fault handlers.
> > 
> > There are currently three types of DAX 4k entries: 4k zero pages, 4k DAX
> > mappings that have an associated block allocation, and 4k DAX empty
> > entries.  The empty entries exist to provide locking for the duration of a
> > given page fault.
> > 
> > This patch adds three equivalent 2MiB DAX entries: Huge Zero Page (HZP)
> > entries, PMD DAX entries that have associated block allocations, and 2 MiB
> > DAX empty entries.
> > 
> > Unlike the 4k case where we insert a struct page* into the radix tree for
> > 4k zero pages, for HZP we insert a DAX exceptional entry with the new
> > RADIX_DAX_HZP flag set.  This is because we use a single 2 MiB zero page in
> > every 2MiB hole mapping, and it doesn't make sense to have that same struct
> > page* with multiple entries in multiple trees.  This would cause contention
> > on the single page lock for the one Huge Zero Page, and it would break the
> > page->index and page->mapping associations that are assumed to be valid in
> > many other places in the kernel.
> > 
> > One difficult use case is when one thread is trying to use 4k entries in
> > radix tree for a given offset, and another thread is using 2 MiB entries
> > for that same offset.  The current code handles this by making the 2 MiB
> > user fall back to 4k entries for most cases.  This was done because it is
> > the simplest solution, and because the use of 2MiB pages is already
> > opportunistic.
> > 
> > If we were to try to upgrade from 4k pages to 2MiB pages for a given range,
> > we run into the problem of how we lock out 4k page faults for the entire
> > 2MiB range while we clean out the radix tree so we can insert the 2MiB
> > entry.  We can solve this problem if we need to, but I think that the cases
> > where both 2MiB entries and 4K entries are being used for the same range
> > will be rare enough and the gain small enough that it probably won't be
> > worth the complexity.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> Just one small bug below. Feel free to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> after fixing that.

Fixed, thank you for the catch and the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
