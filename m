Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A6D726B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 14:03:34 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fl4so38957632pad.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 11:03:34 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id y70si21635074pfa.0.2016.02.12.11.03.33
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 11:03:33 -0800 (PST)
Date: Fri, 12 Feb 2016 12:03:20 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 0/2] DAX bdev fixes - move flushing calls to FS
Message-ID: <20160212190320.GA24857@linux.intel.com>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160211124304.GI21760@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160211124304.GI21760@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Thu, Feb 11, 2016 at 01:43:04PM +0100, Jan Kara wrote:
> On Wed 10-02-16 13:48:54, Ross Zwisler wrote:
> > 3) In filemap_write_and_wait() and filemap_write_and_wait_range(), continue
> > the writeback in the case that DAX is enabled but we only have a nonzero
> > mapping->nrpages.  As with 1) and 2), I believe this is necessary to
> > properly writeback metadata changes.  If this sounds wrong, please let me
> > know and I'll get more info.
> 
> And I'm surprised here as well. If there are dax_mapping() inodes that have
> pagecache pages, then we have issues with radix tree handling as well. So
> how come dax_mapping() inodes have pages attached? If it is about block
> device inodes, then I find it buggy, that S_DAX gets set for such inodes
> when filesystem is mounted on them because in such cases we are IMO asking
> for data corruption sooner rather than later...

I think I've figured this one out, at least partially.

For ext2 the issues I was seeing were due to the fact that directory inodes
have S_DAX set, but have dirty page cache pages.   In testing with
generic/002, I see two ext2 inodes with S_DAX trying to do a writeback while
they have dirty page cache pages.  The first has i_ino=2, which is the
EXT2_ROOT_INO.

The second inode changes from run to run, but for my last run was 155649.  The
test failed because that directory inode was found to be corrupt by fsck.ext2:

	*** fsck.ext2 output ***
	fsck from util-linux 2.26.2
	e2fsck 1.42.12 (29-Aug-2014)
	Pass 1: Checking inodes, blocks, and sizes
	Pass 2: Checking directory structure
	Directory inode 155649, block #0, offset 0: directory corrupted

If I change the code in ext2_writepages() so that it does the
mpage_writepages() even for DAX inodes, all my xfstests pass.  I'm not sure
this is the right fix, though - should it instead be that ext2 directory
inodes don't have S_DAX set?

A similar problem occurs with ext4, though I haven't yet tracked it down to an
inode type.  It could be that ext4 directory inodes have the same issue, and
Eric Sandeen suggested we might also have an issue with XATTRS attached to
inodes.

As with ext2, if I allow the normal writeback to occur in ext4_writepages()
even for DAX inodes, the issues go away, but I'm not sure whether or not this
is the correct fix.

As far as I can see, XFS does not have these issues - returning immediately
having done just the DAX writeback in xfs_vm_writepages() lets all my xfstests
pass.

For v4.5 should I send out an updated version of this series that does the
regular page writeback for ext2 & ext4, or should we work to clear S_DAX for
regular filesystem inodes that have dirty page cache data?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
