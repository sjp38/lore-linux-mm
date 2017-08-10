Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B74D6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:01:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i192so1089205pgc.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 02:01:39 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id e25si3889606pfk.338.2017.08.10.02.01.36
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 02:01:37 -0700 (PDT)
Date: Thu, 10 Aug 2017 19:01:33 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170810090133.GL21024@dastard>
References: <20170810042849.GK21024@dastard>
 <20170810055737.v6yexikxa5zxvntv@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810055737.v6yexikxa5zxvntv@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 10, 2017 at 08:57:37AM +0300, Kirill A. Shutemov wrote:
> On Thu, Aug 10, 2017 at 02:28:49PM +1000, Dave Chinner wrote:
> > Hi folks,
> > 
> > I've recently been looking into what is involved in sharing page
> > cache pages for shared extents in a filesystem. That is, create a
> > file, reflink it so there's two files but only one copy of the data
> > on disk, then read both files.  Right now, we get two copies of the
> > data in the page cache - one in each inode mapping tree.
> > 
> > If we scale this up to a container host which is using reflink trees
> > it's shared root images, there might be hundreds of copies of the
> > same data held in cache (i.e. one page per container). Given that
> > the filesystem knows that the underlying data extent is shared when
> > we go to read it, it's relatively easy to add mechanisms to the
> > filesystem to return the same page for all attempts to read the
> > from a shared extent from all inodes that share it.
> > 
> > However, the problem I'm getting stuck on is that the page cache
> > itself can't handle inserting a single page into multiple page cache
> > mapping trees. i.e. The page has a single pointer to the mapping
> > address space, and the mapping has a single pointer back to the
> > owner inode. As such, a cached page has a 1:1 mapping to it's host
> > inode and this structure seems to be assumed rather widely through
> > the code.
> 
> I think to solve the problem with page->mapping we need something similar
> to what we have for anon rmap[1]. In this case we would be able to keep
> the same page in page cache for multiple inodes.

Being unfamiliar with the anon rmap code, I'm struggling to see the
need for that much complexity here. The AVC abstraction solves a
scalability problem that, to me, doesn't exist for tracking multiple
mapping tree pointers for a page. i.e. I don't see where a list
traversal is necessary in the shared page -> mapping tree resolution
for page cache sharing.

I've been thinking of something simpler along the lines of a dynamic
struct page objects w/ special page flags as an object that allows
us to keep different mapping tree entries for the same physical
page. Seems like this would work for read-only sharing, but perhaps
I'm just blind and I'm missing something I shouldn't be?

> The long term benefit for this is that we might be able to unify a lot of
> code for anon and file code paths in mm, making anon memory a special case
> of file mapping.
> 
> The downside is that anon rmap is rather complicated. I have to re-read
> the article everytime I deal with anon rmap to remind myself how it works.

Yeah, that's a problem - if you have trouble with it, I've got no
hope.... :/

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
