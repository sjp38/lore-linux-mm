Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 4EDEC6B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 18:00:42 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Fri, 16 Aug 2013 23:00:41 +0100
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 9603FC9006E
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 18:00:36 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7GM0bBo156464
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 18:00:37 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7GM0aVg015202
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 19:00:37 -0300
Date: Fri, 16 Aug 2013 17:00:34 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 3/5] zsmalloc: move it under zram
Message-ID: <20130816220034.GD7265@variantweb.net>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <1376459736-7384-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376459736-7384-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

On Wed, Aug 14, 2013 at 02:55:34PM +0900, Minchan Kim wrote:
> This patch moves zsmalloc under zram directory because there
> isn't any other user any more.
> 
> Before that, description will explain why we have needed custom
> allocator.
> 
> Zsmalloc is a new slab-based memory allocator for storing
> compressed pages.  It is designed for low fragmentation and
> high allocation success rate on large object, but <= PAGE_SIZE
> allocations.

One things zsmalloc will probably have to address before Andrew deems it
worthy is the "memmap peekers" issue.  I had to make this change in zbud
before Andrew would accept it and this is one of the reasons I have yet
to implement zsmalloc support for zswap yet.

Basically, zsmalloc makes the assumption that once the kernel page
allocator gives it a page for the pool, zsmalloc can stuff whatever
metatdata it wants into the struct page.  The problem comes when some
parts of the kernel do not obtain the struct page pointer via the
allocator but via walking the memmap.  Those routines will make certain
assumption about the state and structure of the data in the struct page,
leading to issues.

My solution for zbud was to move the metadata into the pool pages
themselves, using the first block of each page for metadata regarding that
page.

Andrew might also have something to say about the placement of
zsmalloc.c.  IIRC, if it was going to be merged, he wanted it in mm/ if
it was going to be messing around in the struct page.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
