From: lord@sgi.com
Message-Id: <200006281554.KAA19007@jen.americas.sgi.com>
Subject: Re: kmap_kiobuf() 
In-reply-to: Your message of "Wed, 28 Jun 2000 16:41:55 BST
Date: Wed, 28 Jun 2000 10:54:40 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, sct@redhat.com, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

> I think it would be useful to provide a function which can be used to 
> obtain a virtually-contiguous VM mapping of the pages of an iobuf.
> 
> Currently, to access the pages of an iobuf, you have to kmap() each page
> individually. For various purposes, it would be useful to be able to kmap the
> whole iobuf contiguously, so that you can guarantee that:
> 
> 	page_address(iobuf->maplist[n]) + PAGE_SIZE 
> 		== page_address(iobuf->maplist[n+1])
> 
>     (for n such that n < iobuf->nr_pages, obviously. Don't be so pedantic.)
> 
> Rather than taking a kiobuf as an argument, the new function might as well 
> be more generic:
> 
> unsigned long kremap_pages(struct page **maplist, int nr_pages);
> void kunmap_pages(struct page **maplist, int nr_pages);
> 
> I had a quick look at the code for kmap() and vmalloc() and decided that 
> even if I attempted to do it myself, I'd probably bugger it up and a MM 
> hacker would have to fix it anyway. So I'm not going to bother.
> 
> T'would be useful if someone else could find the time to do so, though.
> 
> 
> --
> dwmw2
> 
> 


The XFS port currently has exactly this beast, there is an extension
to let us pass an existing set of pages into the vmalloc_area_pages
function. It uses the existing pages instead of allocating new ones.
We needed something to let us map groups of pages into a single byte array.


I always knew it would go down like a ton of bricks, because of the TLB
flushing costs. As soon as you have a multi-cpu box this operation gets
expensive, the code could be changed to do lazy tlb flushes on unmapping
the pages, but you still have the cost every time you set a mapping up.

Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
