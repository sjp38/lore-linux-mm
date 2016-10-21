Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 079356B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 01:01:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r16so43337682pfg.4
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 22:01:23 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id n9si768986pac.82.2016.10.20.22.01.21
        for <linux-mm@kvack.org>;
        Thu, 20 Oct 2016 22:01:22 -0700 (PDT)
Date: Fri, 21 Oct 2016 16:01:18 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161021050118.GR23194@dastard>
References: <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
 <20161017141245.GC27459@dhcp22.suse.cz>
 <20161017145539.GA26930@node.shutemov.name>
 <20161018142007.GL12092@dhcp22.suse.cz>
 <20161018143207.GA5833@node.shutemov.name>
 <20161018183023.GC27792@dhcp22.suse.cz>
 <alpine.LSU.2.11.1610191101250.10318@eggly.anvils>
 <20161020103946.GA3881@node.shutemov.name>
 <20161020224630.GO23194@dastard>
 <20161021020116.GD1075@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161021020116.GD1075@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 20, 2016 at 07:01:16PM -0700, Andi Kleen wrote:
> > Ugh, no, please don't use mount options for file specific behaviours
> > in filesystems like ext4 and XFS. This is exactly the sort of
> > behaviour that should either just work automatically (i.e. be
> > completely controlled by the filesystem) or only be applied to files
> 
> Can you explain what you mean? How would the file system control it?

There's no point in asking for huge pages when populating the page
cache if the file is:

	- significantly smaller than the huge page size
	- largely sparse
	- being randomly accessed in small chunks
	- badly fragmented and so takes hundreds of IO to read/write
	  a huge page
	- able to optimise delayed allocation to match huge page
	  sizes and alignments

These are all constraints the filesystem knows about, but the
application and user don't. None of these aspects can be optimised
sanely by a single threshold, especially when considering the
combination of access patterns vs file layout.

Further, we are moving the IO path to a model where we use extents
for mapping, not blocks.  We're optimising for the fact that modern
filesystems use extents and so massively reduce the number of block
mapping lookup calls we need to do for a given IO.

i.e. instead of doing "get page, map block to page" over and over
again until we've alked over the entire IO range, we're doing
"map extent for entire IO range" once, then iterating "get page"
until we've mapped the entire range.

Hence if we have a 2MB IO come in from userspace, and the iomap
returned is a covers that entire range, it's a no-brainer to ask the
page cache for a huge page instead of iterating 512 times to map all
the 4k pages needed.

> > specifically configured with persistent hints to reliably allocate
> > extents in a way that can be easily mapped to huge pages.
> 
> > e.g. on XFS you will need to apply extent size hints to get large
> > page sized/aligned extent allocation to occur, and so this
> 
> It sounds like you're confusing alignment in memory with alignment
> on disk here? I don't see why on disk alignment would be needed
> at all, unless we're talking about DAX here (which is out of 
> scope currently) Kirill's changes are all about making the memory
> access for cached data more efficient, it's not about disk layout
> optimizations.

No, I'm not confusing this with DAX. However, this automatic use
model for huge pages fits straight into DAX as well.  Same
mechanisms, same behaviours, slightly stricter alignment
characteristics. All stuff the filesystem already knows about.

Mount options are, quite frankly, a terrible mechanism for
specifying filesystem policy. Setting up DAX this way was a mistake,
and it's a mount option I plan to remove from XFS once we get nearer
to having DAX feature complete and stablised. We've already got
on-disk "use DAX for this file" flags in XFS, so we can easier and
cleanly support different methods of accessing PMEM from the same
filesystem.

As such, there is no way we should be considering different
interfaces and methods for configuring the /same functionality/ just
because DAX is enabled or not. It's the /same decision/ that needs
to be made, and the filesystem knows an awful lot more about whether
huge pages can be used efficiently at the time of access than just
about any other actor you can name....

> > persistent extent size hint should trigger the filesystem to use
> > large pages if supported, the hint is correctly sized and aligned,
> > and there are large pages available for allocation.
> 
> That would be ioctls and similar?

You can, but existing filesystem admin tools can already set up
allocation policies without the apps being aware that they even
exist. If you want to use huge page mappings with DAX you'll already
need to do this because of the physical alignment requirements of
DAX.

Further, such techniques are already used by many admins for things
like limiting fragmentation of sparse vm image files. So while you
may not know it, extent size hints and per-file inheritable
attributes are quire widely used already to manage filesystem
behaviour without users or applications even being aware that the
filesystem policies have been modified by the admin...

> That would imply that every application wanting to use large pages
> would need to be especially enabled. That would seem awfully limiting
> to me and needlessly deny benefits to most existing code.

No change to applications will be necessary (see above), though
there's no reason why couldn't directly use the VFS interfaces to
explicitly ask for such behaviour themselves....

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
