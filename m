Date: Fri, 18 May 2001 12:53:54 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Running out of vmalloc space
Message-ID: <20010518125354.D8080@redhat.com>
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com> <3B045546.312BA42E@fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B045546.312BA42E@fc.hp.com>; from dp@fc.hp.com on Thu, May 17, 2001 at 04:48:38PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 17, 2001 at 04:48:38PM -0600, David Pinedo wrote:

> Unfortunately, yes. It has to be in the kernel's virtual address space,
> because the kernel graphics driver initiates DMAs to and from the
> graphics board, which can only be done from the kernel using locked down
> physical memory.

Why does it have to be virtually contiguous?  If you are using vmalloc
then you are necessarily using physically-discontiguous space.  If you
are doing DMA on that space then the kernel isn't accessing it
virtually at all, except perhaps to populate it, which can be done
trivially page by page without having the space virtually contiguous.

It is often a lot easier on the kernel programmer if the addresses
are virtually contiguous, but it is very rarely necessary.  It is
trivial to create an "offset_to_virt" helper function which translates
an offset within one of your pci regions to a virtual kernel address
by indexing a physical page location array which contains the list of
allocated pages.  The *only* thing which is measurably more difficult
without vmalloc is crossing page boundaries.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
