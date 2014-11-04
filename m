Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA3E6B0095
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 11:33:49 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id 29so8133217yhl.29
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 08:33:49 -0800 (PST)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id 3si1407183qak.110.2014.11.04.08.33.47
        for <linux-mm@kvack.org>;
        Tue, 04 Nov 2014 08:33:48 -0800 (PST)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id 17FDD100ED6
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 11:33:44 -0500 (EST)
Date: Tue, 4 Nov 2014 10:33:43 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [RFC PATCH 0/9] mm/zbud: support highmem pages
Message-ID: <20141104163343.GA20974@cerebellum.variantweb.net>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>

On Tue, Oct 14, 2014 at 08:59:19PM +0900, Heesub Shin wrote:
> zbud is a memory allocator for storing compressed data pages. It keeps
> two data objects of arbitrary size on a single page. This simple design
> provides very deterministic behavior on reclamation, which is one of
> reasons why zswap selected zbud as a default allocator over zsmalloc.
> 
> Unlike zsmalloc, however, zbud does not support highmem. This is
> problomatic especially on 32-bit machines having relatively small
> lowmem. Compressing anonymous pages from highmem and storing them into
> lowmem could eat up lowmem spaces.
> 
> This limitation is due to the fact that zbud manages its internal data
> structures on zbud_header which is kept in the head of zbud_page. For
> example, zbud_pages are tracked by several lists and have some status
> information, which are being referenced at any time by the kernel. Thus,
> zbud_pages should be allocated on a memory region directly mapped,
> lowmem.
> 
> After some digging out, I found that internal data structures of zbud
> can be kept in the struct page, the same way as zsmalloc does. So, this
> series moves out all fields in zbud_header to struct page. Though it
> alters quite a lot, it does not add any functional differences except
> highmem support. I am afraid that this kind of modification abusing
> several fields in struct page would be ok.

Hi Heesub,

Sorry for the very late reply.  The end of October was very busy for me.

A little history on zbud.  I didn't put the metadata in the struct
page, even though I knew that was an option since we had done it with
zsmalloc. At the time, Andrew Morton had concerns about memmap walkers
getting messed up with unexpected values in the struct page fields.  In
order to smooth zbud's acceptance, I decided to store the metadata
inline in the page itself.

Later, zsmalloc eventually got accepted, which basically gave the
impression that putting the metadata in the struct page was acceptable.

I have recently been looking at implementing compaction for zsmalloc,
but having the metadata in the struct page and having the handle
directly encode the PFN and offset of the data block prevents
transparent relocation of the data. zbud has a similar issue as it
currently encodes the page address in the handle returned to the user
(also the limitation that is preventing use of highmem pages).

I would like to implement compaction for zbud too and moving the
metadata into the struct page is going to work against that. In fact,
I'm looking at the option of converting the current zbud_header into a
per-allocation metadata structure, which would provide a layer of
indirection between zbud and the user, allowing for transparent
relocation and compaction.

However, I do like the part about letting zbud use highmem pages.

I have something in mind that would allow highmem pages _and_ move
toward something that would support compaction.  I'll see if I can put
it into code today.

Thanks,
Seth

> 
> Heesub Shin (9):
>   mm/zbud: tidy up a bit
>   mm/zbud: remove buddied list from zbud_pool
>   mm/zbud: remove lru from zbud_header
>   mm/zbud: remove first|last_chunks from zbud_header
>   mm/zbud: encode zbud handle using struct page
>   mm/zbud: remove list_head for buddied list from zbud_header
>   mm/zbud: drop zbud_header
>   mm/zbud: allow clients to use highmem pages
>   mm/zswap: use highmem pages for compressed pool
> 
>  mm/zbud.c  | 244 ++++++++++++++++++++++++++++++-------------------------------
>  mm/zswap.c |   4 +-
>  2 files changed, 121 insertions(+), 127 deletions(-)
> 
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
