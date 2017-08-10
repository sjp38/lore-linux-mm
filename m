Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 028566B02F3
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 15:17:49 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i19so7860859qte.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 12:17:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y66si6018515qkc.504.2017.08.10.12.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 12:17:48 -0700 (PDT)
Date: Thu, 10 Aug 2017 15:17:46 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170810191746.GB24674@redhat.com>
References: <20170810042849.GK21024@dastard>
 <20170810161159.GI31390@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810161159.GI31390@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 10, 2017 at 09:11:59AM -0700, Matthew Wilcox wrote:
> On Thu, Aug 10, 2017 at 02:28:49PM +1000, Dave Chinner wrote:
> > I've recently been looking into what is involved in sharing page
> > cache pages for shared extents in a filesystem. That is, create a
> > file, reflink it so there's two files but only one copy of the data
> > on disk, then read both files.  Right now, we get two copies of the
> > data in the page cache - one in each inode mapping tree.
> 
> Yep.  We had a brief discussion of this at LSFMM (as you know, since you
> commented on the discussion): https://lwn.net/Articles/717950/
> 
> > If we scale this up to a container host which is using reflink trees
> > it's shared root images, there might be hundreds of copies of the
> > same data held in cache (i.e. one page per container). Given that
> > the filesystem knows that the underlying data extent is shared when
> > we go to read it, it's relatively easy to add mechanisms to the
> > filesystem to return the same page for all attempts to read the
> > from a shared extent from all inodes that share it.
> 
> I agree the problem exists.  Should we try to fix this problem, or
> should we steer people towards solutions which don't have this problem?
> The solutions I've been seeing use COW block devices instead of COW
> filesystems, and DAX to share the common pages between the host and
> each guest.

Hi Matthew, 

This is in the context of clear containers? It would be good to have
a solution for those who are not launching virt guests.

overlayfs helps mitigate this page cache sharing issue but xfs reflink
and dm thin pool continue to face this issue.

Vivek

> 
> > This leads me to think about crazy schemes like allocating a
> > "referring struct page" that is allocated for every reference to a
> > shared cache page and chain them all to the real struct page sorta
> > like we do for compound pages. That would give us a unique struct
> > page for each mapping tree and solve many of the issues, but I'm not
> > sure how viable such a concept would be.
> 
> That's the solution I'd recommend looking into deeper.  We've also talked
> about creating referring struct pages to support block size > page size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
