Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2E36B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 21:39:21 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id c10so57402690pfc.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 18:39:21 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id t75si24035696pfa.9.2016.02.12.18.39.19
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 18:39:20 -0800 (PST)
Date: Sat, 13 Feb 2016 13:38:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 0/2] DAX bdev fixes - move flushing calls to FS
Message-ID: <20160213023849.GD14668@dastard>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160211124304.GI21760@quack.suse.cz>
 <20160212190320.GA24857@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160212190320.GA24857@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Fri, Feb 12, 2016 at 12:03:20PM -0700, Ross Zwisler wrote:
> On Thu, Feb 11, 2016 at 01:43:04PM +0100, Jan Kara wrote:
> > On Wed 10-02-16 13:48:54, Ross Zwisler wrote:
> > > 3) In filemap_write_and_wait() and filemap_write_and_wait_range(), continue
> > > the writeback in the case that DAX is enabled but we only have a nonzero
> > > mapping->nrpages.  As with 1) and 2), I believe this is necessary to
> > > properly writeback metadata changes.  If this sounds wrong, please let me
> > > know and I'll get more info.
> > 
> > And I'm surprised here as well. If there are dax_mapping() inodes that have
> > pagecache pages, then we have issues with radix tree handling as well. So
> > how come dax_mapping() inodes have pages attached? If it is about block
> > device inodes, then I find it buggy, that S_DAX gets set for such inodes
> > when filesystem is mounted on them because in such cases we are IMO asking
> > for data corruption sooner rather than later...
> 
> I think I've figured this one out, at least partially.
> 
> For ext2 the issues I was seeing were due to the fact that directory inodes
> have S_DAX set, but have dirty page cache pages.   In testing with
> generic/002, I see two ext2 inodes with S_DAX trying to do a writeback while
> they have dirty page cache pages.  The first has i_ino=2, which is the
> EXT2_ROOT_INO.
....
> As far as I can see, XFS does not have these issues - returning immediately
> having done just the DAX writeback in xfs_vm_writepages() lets all my xfstests
> pass.

XFS will not have issues because it does not dirty directory inodes
at the VFS level, nor does it use the page cache for directory data.
However, looking at the code I think it does still set S_DAX on
directory inodes, which it shouldn't be doing.

I've got a couple of fixes I need to do in this area - hopefully
I'll get it done on Monday.

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
