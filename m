Date: Wed, 28 Jun 2000 18:44:28 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kmap_kiobuf()
Message-ID: <20000628184428.B2392@redhat.com>
References: <11270.962206915@cygnus.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <11270.962206915@cygnus.co.uk>; from dwmw2@infradead.org on Wed, Jun 28, 2000 at 04:41:55PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, sct@redhat.com, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 28, 2000 at 04:41:55PM +0100, David Woodhouse wrote:

> I think it would be useful to provide a function which can be used to 
> obtain a virtually-contiguous VM mapping of the pages of an iobuf.

Why?  This is not as straightforward as it seems, so I'm curious as
to the intended use.

> Currently, to access the pages of an iobuf, you have to kmap() each page
> individually. For various purposes, it would be useful to be able to kmap the
> whole iobuf contiguously, so that you can guarantee that:
> 
> 	page_address(iobuf->maplist[n]) + PAGE_SIZE 
> 		== page_address(iobuf->maplist[n+1])

For any moderately large sized kiobuf, that just means that we risk
running out of kmaps.  You need to treat kmaps as a scarce resource;
on PAE36-configured machines we only have 512 of them right now.

For user-space access, the current kiobuf patches already have mmap()
support for kiobufs so that getting a user-contiguous mapping of
kiobufs is already done.  That doesn't have the kmap problem, though,
since we can map things into user page tables without pinning them in
kernel memory.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
