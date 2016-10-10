Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 377816B0038
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 18:05:52 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id q75so6858506itc.6
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 15:05:52 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o25si16169pgc.268.2016.10.10.15.05.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Oct 2016 15:05:51 -0700 (PDT)
Date: Mon, 10 Oct 2016 16:05:50 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 13/17] dax: dax_iomap_fault() needs to call iomap_end()
Message-ID: <20161010220550.GA22793@linux.intel.com>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475874544-24842-14-git-send-email-ross.zwisler@linux.intel.com>
 <20161010155004.GD19343@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161010155004.GD19343@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Oct 10, 2016 at 05:50:04PM +0200, Christoph Hellwig wrote:
> On Fri, Oct 07, 2016 at 03:09:00PM -0600, Ross Zwisler wrote:
> > Currently iomap_end() doesn't do anything for DAX page faults for both ext2
> > and XFS.  ext2_iomap_end() just checks for a write underrun, and
> > xfs_file_iomap_end() checks to see if it needs to finish a delayed
> > allocation.  However, in the future iomap_end() calls might be needed to
> > make sure we have balanced allocations, locks, etc.  So, add calls to
> > iomap_end() with appropriate error handling to dax_iomap_fault().
> 
> Is there a way to just have a single call to iomap_end at the end of
> the function, after which we just return a previosuly setup return
> value?
> 
> e.g.
> 
> out:
> 	if (ops->iomap_end) {
> 		error = ops->iomap_end(inode, pos, PAGE_SIZE,
> 				PAGE_SIZE, flags, &iomap);
> 	}
> 
> 	if (error == -ENOMEM)
> 		return VM_FAULT_OOM | major;
> 	if (error < 0 && error != -EBUSY)
> 		return VM_FAULT_SIGBUS | major;
> 	return ret;

Sure, will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
