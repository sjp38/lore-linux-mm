Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7B49F6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 07:42:50 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id 128so19494103wmz.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 04:42:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iw7si11831412wjb.105.2016.02.11.04.42.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 04:42:49 -0800 (PST)
Date: Thu, 11 Feb 2016 13:43:04 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 0/2] DAX bdev fixes - move flushing calls to FS
Message-ID: <20160211124304.GI21760@quack.suse.cz>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Wed 10-02-16 13:48:54, Ross Zwisler wrote:
> During testing of raw block devices + DAX I noticed that the struct
> block_device that we were using for DAX operations was incorrect.  For the
> fault handlers, etc. we can just get the correct bdev via get_block(),
> which is passed in as a function pointer, but for the *sync code and for
> sector zeroing we don't have access to get_block().  This is also an issue
> for XFS real-time devices, whenever we get those working.
> 
> Patch one of this series fixes the DAX sector zeroing code by explicitly
> passing in a valid struct block_device.
> 
> Patch two of this series fixes DAX *sync support by moving calls to
> dax_writeback_mapping_range() out of filemap_write_and_wait_range() and
> into the filesystem/block device ->writepages function so that it can
> supply us with a valid block device. This also fixes DAX code to properly
> flush caches in response to sync(2).
> 
> Thanks to Jan Kara for his initial draft of patch 2:
> https://lkml.org/lkml/2016/2/9/485
> 
> Here are the changes that I've made to that patch:
> 
> 1) For DAX mappings, only return after calling
> dax_writeback_mapping_range() if we encountered an error.  In the non-error
> case we still need to write back normal pages, else we lose metadata
> updates. 
> 
> 2) In dax_writeback_mapping_range(), move the new check for 
>         if (!mapping->nrexceptional || wbc->sync_mode != WB_SYNC_ALL)
> above the i_blkbits check.  In my testing I found cases where
> dax_writeback_mapping_range() was called for inodes with i_blkbits !=
> PAGE_SHIFT - I'm assuming these are internal metadata inodes?  They have no
> exceptional DAX entries to flush, so we have no work to do, but if we
> return error from the i_blkbits check we will fail the overall writeback
> operation.  Please let me know if it seems wrong for us to be seeing inodes
> set to use DAX but with i_blkbits != PAGE_SHIFT and I'll get more info.

So I'm wondering - how come S_DAX flag got set for inode where i_blkbis !=
PAGE_SHIFT? That would seem to be a bug? I specifically ordered the checks
like this to catch such issues.

> 3) In filemap_write_and_wait() and filemap_write_and_wait_range(), continue
> the writeback in the case that DAX is enabled but we only have a nonzero
> mapping->nrpages.  As with 1) and 2), I believe this is necessary to
> properly writeback metadata changes.  If this sounds wrong, please let me
> know and I'll get more info.

And I'm surprised here as well. If there are dax_mapping() inodes that have
pagecache pages, then we have issues with radix tree handling as well. So
how come dax_mapping() inodes have pages attached? If it is about block
device inodes, then I find it buggy, that S_DAX gets set for such inodes
when filesystem is mounted on them because in such cases we are IMO asking
for data corruption sooner rather than later...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
