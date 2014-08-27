Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBEF6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:46:26 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so1473146pab.20
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:46:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xp1si2594700pbc.200.2014.08.27.14.46.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 14:46:24 -0700 (PDT)
Date: Wed, 27 Aug 2014 14:46:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Message-Id: <20140827144622.ed81195a1d94799bb57a3207@linux-foundation.org>
In-Reply-To: <20140827211250.GH3285@linux.intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
	<20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
	<20140827211250.GH3285@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 27 Aug 2014 17:12:50 -0400 Matthew Wilcox <willy@linux.intel.com> wrote:

> On Wed, Aug 27, 2014 at 01:06:13PM -0700, Andrew Morton wrote:
> > On Tue, 26 Aug 2014 23:45:20 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:
> > 
> > > One of the primary uses for NV-DIMMs is to expose them as a block device
> > > and use a filesystem to store files on the NV-DIMM.  While that works,
> > > it currently wastes memory and CPU time buffering the files in the page
> > > cache.  We have support in ext2 for bypassing the page cache, but it
> > > has some races which are unfixable in the current design.  This series
> > > of patches rewrite the underlying support, and add support for direct
> > > access to ext4.
> > 
> > Sat down to read all this but I'm finding it rather unwieldy - it's
> > just a great blob of code.  Is there some overall
> > what-it-does-and-how-it-does-it roadmap?
> 
> The overall goal is to map persistent memory / NV-DIMMs directly to
> userspace.  We have that functionality in the XIP code, but the way
> it's structured is unsuitable for filesystems like ext4 & XFS, and
> it has some pretty ugly races.

When thinking about looking at the patchset I wonder things like how
does mmap work, in what situations does a page get COWed, how do we
handle partial pages at EOF, etc.  I guess that's all part of the
filemap_xip legacy, the details of which I've totally forgotten.

> Patches 1 & 3 are simply bug-fixes.  They should go in regardless of
> the merits of anything else in this series.
> 
> Patch 2 changes the API for the direct_access block_device_operation so
> it can report more than a single page at a time.  As the series evolved,
> this work also included moving support for partitioning into the VFS
> where it belongs, handling various error cases in the VFS and so on.
> 
> Patch 4 is an optimisation.  It's poor form to make userspace take two
> faults for the same dereference.
> 
> Patch 5 gives us a VFS flag for the DAX property, which lets us get rid of
> the get_xip_mem() method later on.
> 
> Patch 6 is also prep work; Al Viro liked it enough that it's now in
> his tree.
> 
> The new DAX code is then dribbled in over patches 7-11, split up by
> functional area.  At each stage, the ext2-xip code is converted over to
> the new DAX code.
> 
> Patches 12-18 delete the remnants of the old XIP code, and fix the things
> in ext2 that Jan didn't like when he reviewed them for ext4 :-)
> 
> Patches 19 & 20 are the work to make ext4 use DAX.
> 
> Patch 21 is some final cleanup of references to the old XIP code, renaming
> it all to DAX.

hrm.

> > Some explanation of why one would use ext4 instead of, say,
> > suitably-modified ramfs/tmpfs/rd/etc?
> 
> ramfs and tmpfs really rely on the page cache.  They're not exactly
> built for permanence either.  brd also relies on the page cache, and
> there's a clear desire to use a filesystem instead of a block device
> for all the usual reasons of access permissions, grow/shrink, etc.
> 
> Some people might want to use XFS instead of ext4.  We're starting with
> ext4, but we've been keeping an eye on what other filesystems might want
> to use.  btrfs isn't going to use the DAX code, but some of the other
> pieces will probably come in handy.
> 
> There are also at least three people working on their own filesystems
> specially designed for persistent memory.  I wish them all the best
> ... but I'd like to get this infrastructure into place.

This is the sort of thing which first-timers (this one at least) like
to see in [0/n].

> > Performance testing results?
> 
> I haven't been running any performance tests.  What sort of performance
> tests would be interesting for you to see?

fs benchmarks?  `dd' would be a good start ;)

I assume (because I wasn't told!) that there are two objectives here:

1) reduce memory consumption by not maintaining pagecache and
2) reduce CPU cost by avoiding the double-copies.

These things are pretty easily quantified.  And really they must be
quantified as part of the developer testing, because if you find
they've worsened then holy cow, what went wrong.

> > Carsten Otte wrote filemap_xip.c and may be a useful reviewer of this
> > work.
> 
> I cc'd him on some earlier versions and didn't hear anything back.  It felt
> rude to keep plying him with 20+ patches every month.

OK.

> > All the patch subjects violate Documentation/SubmittingPatches
> > section 15 ;)
> 
> errr ... which bit?  I used git format-patch to create them.

None of the patch titles identify the subsystem(s) which they're
hitting.  eg, "Introduce IS_DAX(inode)" is an ext2 patch, but nobody
would know that from browsing the titles.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
