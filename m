Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C600D6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 00:21:20 -0400 (EDT)
Date: Tue, 20 Aug 2013 13:21:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 3/5] zsmalloc: move it under zram
Message-ID: <20130820042146.GR28062@bbox>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <1376459736-7384-4-git-send-email-minchan@kernel.org>
 <20130816220034.GD7265@variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130816220034.GD7265@variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

Hello Seth,

On Fri, Aug 16, 2013 at 05:00:34PM -0500, Seth Jennings wrote:
> On Wed, Aug 14, 2013 at 02:55:34PM +0900, Minchan Kim wrote:
> > This patch moves zsmalloc under zram directory because there
> > isn't any other user any more.
> > 
> > Before that, description will explain why we have needed custom
> > allocator.
> > 
> > Zsmalloc is a new slab-based memory allocator for storing
> > compressed pages.  It is designed for low fragmentation and
> > high allocation success rate on large object, but <= PAGE_SIZE
> > allocations.
> 
> One things zsmalloc will probably have to address before Andrew deems it
> worthy is the "memmap peekers" issue.  I had to make this change in zbud
> before Andrew would accept it and this is one of the reasons I have yet
> to implement zsmalloc support for zswap yet.
> 
> Basically, zsmalloc makes the assumption that once the kernel page
> allocator gives it a page for the pool, zsmalloc can stuff whatever
> metatdata it wants into the struct page.  The problem comes when some
> parts of the kernel do not obtain the struct page pointer via the
> allocator but via walking the memmap.  Those routines will make certain
> assumption about the state and structure of the data in the struct page,
> leading to issues.

All of memmap peekers should make such asummption based on pageflag
so if zsmalloc don't need touch flag field, it should be no problem.

In addition to that, SLUB allocator already have touched it so why not
for zsmalloc?

> 
> My solution for zbud was to move the metadata into the pool pages
> themselves, using the first block of each page for metadata regarding that
> page.
> 
> Andrew might also have something to say about the placement of
> zsmalloc.c.  IIRC, if it was going to be merged, he wanted it in mm/ if
> it was going to be messing around in the struct page.

NP.

Thanks for the review, Seth.

> 
> Seth
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
