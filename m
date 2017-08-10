Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD9A6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:28:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z3so82614831pfk.4
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 21:28:54 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id m13si1051556pli.586.2017.08.09.21.28.52
        for <linux-mm@kvack.org>;
        Wed, 09 Aug 2017 21:28:53 -0700 (PDT)
Date: Thu, 10 Aug 2017 14:28:49 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: How can we share page cache pages for reflinked files?
Message-ID: <20170810042849.GK21024@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org

Hi folks,

I've recently been looking into what is involved in sharing page
cache pages for shared extents in a filesystem. That is, create a
file, reflink it so there's two files but only one copy of the data
on disk, then read both files.  Right now, we get two copies of the
data in the page cache - one in each inode mapping tree.

If we scale this up to a container host which is using reflink trees
it's shared root images, there might be hundreds of copies of the
same data held in cache (i.e. one page per container). Given that
the filesystem knows that the underlying data extent is shared when
we go to read it, it's relatively easy to add mechanisms to the
filesystem to return the same page for all attempts to read the
from a shared extent from all inodes that share it.

However, the problem I'm getting stuck on is that the page cache
itself can't handle inserting a single page into multiple page cache
mapping trees. i.e. The page has a single pointer to the mapping
address space, and the mapping has a single pointer back to the
owner inode. As such, a cached page has a 1:1 mapping to it's host
inode and this structure seems to be assumed rather widely through
the code.

The problem is somewhat limited by the fact that only clean,
read-only pages would be shared, and the attempt to write/dirty
a shared page in a mapping would trigger a COW operation in the
filesystem which would invalidate that inode's shared page and
replace it with a new, inode-private page that could be written to.
This still requires us to be able to find the right inode from the
shared page context to run the COW operation. Luckily, the IO path
already has an inode pointer, and the page fault path provides us
with the inode via file_inode(vmf->vma->vm_file) so we don't
actually need page->mapping->host in these paths.

Along these lines I've thought about using a "shared mapping" that
is associated with the filesystem rather than a specific inode (like
a bdev mapping), but that's no good because if page->mapping !=
inode->i_mapping the page is consider to have been invalidated and
should be considered invalid.

Further - a page has a single, fixed index into the mapping tree
(i.e. page->index), so this prevents arbitrary page sharing across
inodes (the "deduplication triggered shared extent" case). And we
can't really get rid of the page index, because that's how the page
finds itself in a mapping tree.

This leads me to think about crazy schemes like allocating a
"referring struct page" that is allocated for every reference to a
shared cache page and chain them all to the real struct page sorta
like we do for compound pages. That would give us a unique struct
page for each mapping tree and solve many of the issues, but I'm not
sure how viable such a concept would be.

I'm sure there's more issues than I've outlined here, but I haven't
gone deeper than this because I've got to solve the one to many
problem first.  I don't know if anyone has looked at this in any
detail, so I don't know what ideas, patches, crazy schemes, etc
might already exist out there. Right now I'm just looking for
information to narrow down what I need to look at - finding what
rabbit holes have already been explored and what dragons are already
known about would help an awful lot right now.

Anyone?

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
