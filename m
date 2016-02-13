Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A5D416B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 23:59:25 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id q63so57814708pfb.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 20:59:25 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bp6si24778418pac.135.2016.02.12.20.59.24
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 20:59:24 -0800 (PST)
Date: Fri, 12 Feb 2016 21:59:12 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 0/2] DAX bdev fixes - move flushing calls to FS
Message-ID: <20160213045912.GA22595@linux.intel.com>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160211124304.GI21760@quack.suse.cz>
 <20160212190320.GA24857@linux.intel.com>
 <20160213023849.GD14668@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160213023849.GD14668@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Sat, Feb 13, 2016 at 01:38:49PM +1100, Dave Chinner wrote:
> On Fri, Feb 12, 2016 at 12:03:20PM -0700, Ross Zwisler wrote:
> > On Thu, Feb 11, 2016 at 01:43:04PM +0100, Jan Kara wrote:
> > > On Wed 10-02-16 13:48:54, Ross Zwisler wrote:
> > > > 3) In filemap_write_and_wait() and filemap_write_and_wait_range(), continue
> > > > the writeback in the case that DAX is enabled but we only have a nonzero
> > > > mapping->nrpages.  As with 1) and 2), I believe this is necessary to
> > > > properly writeback metadata changes.  If this sounds wrong, please let me
> > > > know and I'll get more info.
> > > 
> > > And I'm surprised here as well. If there are dax_mapping() inodes that have
> > > pagecache pages, then we have issues with radix tree handling as well. So
> > > how come dax_mapping() inodes have pages attached? If it is about block
> > > device inodes, then I find it buggy, that S_DAX gets set for such inodes
> > > when filesystem is mounted on them because in such cases we are IMO asking
> > > for data corruption sooner rather than later...
> > 
> > I think I've figured this one out, at least partially.
> > 
> > For ext2 the issues I was seeing were due to the fact that directory inodes
> > have S_DAX set, but have dirty page cache pages.   In testing with
> > generic/002, I see two ext2 inodes with S_DAX trying to do a writeback while
> > they have dirty page cache pages.  The first has i_ino=2, which is the
> > EXT2_ROOT_INO.
> ....
> > As far as I can see, XFS does not have these issues - returning immediately
> > having done just the DAX writeback in xfs_vm_writepages() lets all my xfstests
> > pass.
> 
> XFS will not have issues because it does not dirty directory inodes
> at the VFS level, nor does it use the page cache for directory data.
> However, looking at the code I think it does still set S_DAX on
> directory inodes, which it shouldn't be doing.
> 
> I've got a couple of fixes I need to do in this area - hopefully
> I'll get it done on Monday.

Cool.  I've got a quick patch that stops S_DAX from being set on everything
but regular inodes for ext2 and ext4.  This solved a lot of my xfstests
failures.

Even after that I'm seeing two last failures with ext4 - I'll keep working on
those.

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
