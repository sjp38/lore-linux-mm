Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: MAP_SHARED handling
Date: Thu, 5 Sep 2002 18:52:47 +0200
References: <3D7705C5.E41B5D5F@zip.com.au>
In-Reply-To: <3D7705C5.E41B5D5F@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17mzs8-00068y-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 05 September 2002 09:20, Andrew Morton wrote:
> One thing bugs me a little bit.
> 
> A program has a huge MAP_SHARED segment and dirties it.  The VM
> walks the LRU, propagating the pte dirtiness into the pageframe
> and *immediately* writes the page out:
> 
> 	switch (try_to_unmap(page))
> 	case SWAP_SUCCESS:
> 		break;
> 	}
> 
> 	if (PageDirty(page))
> 		vm_writeback(page->mapping);
> 
> This has a few small irritations.
> 
> - We'll be calling ->vm_writeback() once per page, and it'll only
>   discover a single dirty page on swapper_space.dirty_pages.
> 
>   This is a little CPU-inefficient.  Be nicer to build up a few
>   dirty pages on swapper_space before launching vm_writeback
>   against it.
> 
> - My dirty page accounting tells lies.  In /proc/meminfo, `Dirty'
>   is just a few tens of kilobytes, and `Writeback' is a meg or two.
> 
>   But in reality, there are a huge number of dirty pages - we just
>   don't know about them yet.
> 
>   And there's some benefit in making `Dirty' more accurate, because
>   that will cause balance_dirty_pages() to clamp down harder on
>   write(2) callers.
> 
> 
> So....  Could we do something like: if the try_to_unmap() call turned
> the page from !PageDirty to PageDirty, give it another go around the
> list?

Why not just ensure the page is scheduled for writing, sometime,
we don't care exactly when as long as it's relatively soon.  Just bump
the page's mapping to the hot end of your writeout list and let things
take their course.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
