Date: Wed, 16 Jul 2008 10:50:25 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: madvise(2) MADV_SEQUENTIAL behavior
Message-ID: <20080716105025.2daf5db2@cuia.bos.redhat.com>
In-Reply-To: <1216210495.5232.47.camel@twins>
References: <1216163022.3443.156.camel@zenigma>
	<1216210495.5232.47.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Eric Rannaud <eric.rannaud@gmail.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jul 2008 14:14:55 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, 2008-07-15 at 23:03 +0000, Eric Rannaud wrote:
> > mm/madvise.c and madvise(2) say:
> > 
> >  *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
> >  *		once, so they can be aggressively read ahead, and
> >  *		can be freed soon after they are accessed.
> > 
> > 
> > But as the sample program at the end of this post shows, and as I
> > understand the code in mm/filemap.c, MADV_SEQUENTIAL will only increase
> > the amount of read ahead for the specified page range, but will not
> > influence the rate at which the pages just read will be freed from
> > memory.
> 
> Correct, various attempts have been made to actually implement this, but
> non made it through.
> 
> My last attempt was:
>   http://lkml.org/lkml/2007/7/21/219
> 
> Rik recently tried something else based on his split-lru series:
>   http://lkml.org/lkml/2008/7/15/465

M patch is not going to help with mmap, though.

I believe that for mmap MADV_SEQUENTIAL, we will have to do
an unmap-behind from the fault path.  Not every time, but
maybe once per megabyte, unmapping the megabyte behind us.

That way the normal page cache policies (use once, etc) can
take care of page eviction, which should help if the file
is also in use by another process.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
