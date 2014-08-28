Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7EB6B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 11:46:54 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id rd3so3067170pab.10
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 08:46:53 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fa1si7541164pab.14.2014.08.28.08.46.50
        for <linux-mm@kvack.org>;
        Thu, 28 Aug 2014 08:46:51 -0700 (PDT)
Date: Thu, 28 Aug 2014 11:45:27 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Message-ID: <20140828154527.GJ3285@linux.intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
 <20140827211250.GH3285@linux.intel.com>
 <20140827144622.ed81195a1d94799bb57a3207@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827144622.ed81195a1d94799bb57a3207@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 27, 2014 at 02:46:22PM -0700, Andrew Morton wrote:
> > > Sat down to read all this but I'm finding it rather unwieldy - it's
> > > just a great blob of code.  Is there some overall
> > > what-it-does-and-how-it-does-it roadmap?
> > 
> > The overall goal is to map persistent memory / NV-DIMMs directly to
> > userspace.  We have that functionality in the XIP code, but the way
> > it's structured is unsuitable for filesystems like ext4 & XFS, and
> > it has some pretty ugly races.
> 
> When thinking about looking at the patchset I wonder things like how
> does mmap work, in what situations does a page get COWed, how do we
> handle partial pages at EOF, etc.  I guess that's all part of the
> filemap_xip legacy, the details of which I've totally forgotten.

mmap works by installing a PTE that points to the storage.  This implies
that the NV-DIMM has to be the kind that always has everything mapped
(there are other types that require commands to be sent to move windows
around that point into the storage ... DAX is not for these types
of DIMMs).

We use a VM_MIXEDMAP vma.  The PTEs pointing to PFNs will just get
copied across on fork.  Read-faults on holes are covered by a read-only
page cache page.  On a write to a hole, any page cache page covering it
will be unmapped and evicted from the page cache.  The mapping for the
faulting task will be replaced with a mapping to the newly established
block, but other mappings will take a fresh fault on their next reference.

Partial pages are mmapable, just as they are with page-cache based
files.  You can even store beyond EOF, just as with page-cache files.
Those stores are, of course, going to end up on persistence, but they
might well end up being zeroed if the file is extended ... again, this
is no different to page-cache based files.

> > > Performance testing results?
> > 
> > I haven't been running any performance tests.  What sort of performance
> > tests would be interesting for you to see?
> 
> fs benchmarks?  `dd' would be a good start ;)
> 
> I assume (because I wasn't told!) that there are two objectives here:
> 
> 1) reduce memory consumption by not maintaining pagecache and
> 2) reduce CPU cost by avoiding the double-copies.
> 
> These things are pretty easily quantified.  And really they must be
> quantified as part of the developer testing, because if you find
> they've worsened then holy cow, what went wrong.

It's really a functionality argument; the users we anticipate for NV-DIMMs
really want to directly map them into memory and do a lot of work through
loads and stores with the kernel not being involved at all, so we don't
actually have any performance targets for things like read/write.
That said, when running xfstests and comparing results between ext4
with and without DAX, I do see many of the tests completing quicker
with DAX than without (others "run for thirty seconds" so there's no
time difference between with/without).

> None of the patch titles identify the subsystem(s) which they're
> hitting.  eg, "Introduce IS_DAX(inode)" is an ext2 patch, but nobody
> would know that from browsing the titles.

I actually see that one as being a VFS patch ... ext2 changing is just
a side-effect.  I can re-split that patch if desired.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
