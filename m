Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E753B6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:13:31 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so1330453pab.12
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:13:31 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bb1si2536161pbb.173.2014.08.27.14.13.26
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 14:13:26 -0700 (PDT)
Date: Wed, 27 Aug 2014 17:12:50 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Message-ID: <20140827211250.GH3285@linux.intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 27, 2014 at 01:06:13PM -0700, Andrew Morton wrote:
> On Tue, 26 Aug 2014 23:45:20 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:
> 
> > One of the primary uses for NV-DIMMs is to expose them as a block device
> > and use a filesystem to store files on the NV-DIMM.  While that works,
> > it currently wastes memory and CPU time buffering the files in the page
> > cache.  We have support in ext2 for bypassing the page cache, but it
> > has some races which are unfixable in the current design.  This series
> > of patches rewrite the underlying support, and add support for direct
> > access to ext4.
> 
> Sat down to read all this but I'm finding it rather unwieldy - it's
> just a great blob of code.  Is there some overall
> what-it-does-and-how-it-does-it roadmap?

The overall goal is to map persistent memory / NV-DIMMs directly to
userspace.  We have that functionality in the XIP code, but the way
it's structured is unsuitable for filesystems like ext4 & XFS, and
it has some pretty ugly races.

Patches 1 & 3 are simply bug-fixes.  They should go in regardless of
the merits of anything else in this series.

Patch 2 changes the API for the direct_access block_device_operation so
it can report more than a single page at a time.  As the series evolved,
this work also included moving support for partitioning into the VFS
where it belongs, handling various error cases in the VFS and so on.

Patch 4 is an optimisation.  It's poor form to make userspace take two
faults for the same dereference.

Patch 5 gives us a VFS flag for the DAX property, which lets us get rid of
the get_xip_mem() method later on.

Patch 6 is also prep work; Al Viro liked it enough that it's now in
his tree.

The new DAX code is then dribbled in over patches 7-11, split up by
functional area.  At each stage, the ext2-xip code is converted over to
the new DAX code.

Patches 12-18 delete the remnants of the old XIP code, and fix the things
in ext2 that Jan didn't like when he reviewed them for ext4 :-)

Patches 19 & 20 are the work to make ext4 use DAX.

Patch 21 is some final cleanup of references to the old XIP code, renaming
it all to DAX.

> Some explanation of why one would use ext4 instead of, say,
> suitably-modified ramfs/tmpfs/rd/etc?

ramfs and tmpfs really rely on the page cache.  They're not exactly
built for permanence either.  brd also relies on the page cache, and
there's a clear desire to use a filesystem instead of a block device
for all the usual reasons of access permissions, grow/shrink, etc.

Some people might want to use XFS instead of ext4.  We're starting with
ext4, but we've been keeping an eye on what other filesystems might want
to use.  btrfs isn't going to use the DAX code, but some of the other
pieces will probably come in handy.

There are also at least three people working on their own filesystems
specially designed for persistent memory.  I wish them all the best
... but I'd like to get this infrastructure into place.

> Performance testing results?

I haven't been running any performance tests.  What sort of performance
tests would be interesting for you to see?

> Carsten Otte wrote filemap_xip.c and may be a useful reviewer of this
> work.

I cc'd him on some earlier versions and didn't hear anything back.  It felt
rude to keep plying him with 20+ patches every month.

> All the patch subjects violate Documentation/SubmittingPatches
> section 15 ;)

errr ... which bit?  I used git format-patch to create them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
