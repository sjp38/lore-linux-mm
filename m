Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC2A36B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 12:12:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b83so11319799pfl.6
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:12:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q6si4153879pgn.509.2017.08.10.09.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 09:12:01 -0700 (PDT)
Date: Thu, 10 Aug 2017 09:11:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170810161159.GI31390@bombadil.infradead.org>
References: <20170810042849.GK21024@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810042849.GK21024@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 10, 2017 at 02:28:49PM +1000, Dave Chinner wrote:
> I've recently been looking into what is involved in sharing page
> cache pages for shared extents in a filesystem. That is, create a
> file, reflink it so there's two files but only one copy of the data
> on disk, then read both files.  Right now, we get two copies of the
> data in the page cache - one in each inode mapping tree.

Yep.  We had a brief discussion of this at LSFMM (as you know, since you
commented on the discussion): https://lwn.net/Articles/717950/

> If we scale this up to a container host which is using reflink trees
> it's shared root images, there might be hundreds of copies of the
> same data held in cache (i.e. one page per container). Given that
> the filesystem knows that the underlying data extent is shared when
> we go to read it, it's relatively easy to add mechanisms to the
> filesystem to return the same page for all attempts to read the
> from a shared extent from all inodes that share it.

I agree the problem exists.  Should we try to fix this problem, or
should we steer people towards solutions which don't have this problem?
The solutions I've been seeing use COW block devices instead of COW
filesystems, and DAX to share the common pages between the host and
each guest.

> This leads me to think about crazy schemes like allocating a
> "referring struct page" that is allocated for every reference to a
> shared cache page and chain them all to the real struct page sorta
> like we do for compound pages. That would give us a unique struct
> page for each mapping tree and solve many of the issues, but I'm not
> sure how viable such a concept would be.

That's the solution I'd recommend looking into deeper.  We've also talked
about creating referring struct pages to support block size > page size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
