Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4C82282F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 23:55:38 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so60662886pad.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 20:55:38 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id yn6si7544559pab.112.2015.10.29.20.55.36
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 20:55:37 -0700 (PDT)
Date: Fri, 30 Oct 2015 14:55:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 00/11] DAX fsynx/msync support
Message-ID: <20151030035533.GU19199@dastard>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Thu, Oct 29, 2015 at 02:12:04PM -0600, Ross Zwisler wrote:
> This patch series adds support for fsync/msync to DAX.
> 
> Patches 1 through 8 add various utilities that the DAX code will eventually
> need, and the DAX code itself is added by patch 9.  Patches 10 and 11 are
> filesystem changes that are needed after the DAX code is added, but these
> patches may change slightly as the filesystem fault handling for DAX is
> being modified ([1] and [2]).
> 
> I've marked this series as RFC because I'm still testing, but I wanted to
> get this out there so people would see the direction I was going and
> hopefully comment on any big red flags sooner rather than later.
> 
> I realize that we are getting pretty dang close to the v4.4 merge window,
> but I think that if we can get this reviewed and working it's a much better
> solution than the "big hammer" approach that blindly flushes entire PMEM
> namespaces [3].

We need the "big hammer" regardless of fsync. If REQ_FLUSH and
REQ_FUA don't do the right thing when it comes to ordering journal
writes against other IO operations, then the filesystems are not
crash safe. i.e. we need REQ_FLUSH/REQ_FUA to commit all outstanding
changes back to stable storage, just like they do for existing
storage....

> [1] http://oss.sgi.com/archives/xfs/2015-10/msg00523.html
> [2] http://marc.info/?l=linux-ext4&m=144550211312472&w=2
> [3] https://lists.01.org/pipermail/linux-nvdimm/2015-October/002614.html
> 
> Ross Zwisler (11):
>   pmem: add wb_cache_pmem() to the PMEM API
>   mm: add pmd_mkclean()
>   pmem: enable REQ_FLUSH handling
>   dax: support dirty DAX entries in radix tree
>   mm: add follow_pte_pmd()
>   mm: add pgoff_mkclean()
>   mm: add find_get_entries_tag()
>   fs: add get_block() to struct inode_operations

I don't think this is the right thing to do - it propagates the use
of bufferheads as a mapping structure into places where we do not
want bufferheads. We've recently added a similar block mapping
interface to the export operations structure for PNFS and that uses
a "struct iomap" which is far more suited to being an inode
operation this.

We have plans to move this to the inode operations for various
reasons. e.g: multipage write, adding interfaces that support proper
mapping of holes, etc:

https://www.redhat.com/archives/cluster-devel/2014-October/msg00167.html

So after many years of saying no to moving getblocks to the inode
operations it seems like the wrong thing to do now considering I
want to convert all the DAX code to use iomaps while only 2/3
filesystems are supported...

>   dax: add support for fsync/sync

Why put the dax_flush_mapping() in do_writepages()? Why not call it
directly from the filesystem ->fsync() implementations where a
getblocks callback could also be provided?

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
