Date: Mon, 28 Jun 1999 17:50:02 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <199906282138.OAA36935@google.engr.sgi.com>
Message-ID: <Pine.BSO.4.10.9906281740270.24888-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Kanoj Sarcar wrote:
> > well, except that kswapd itself doesn't free any memory.  it simply copies
> > data from memory to disk.  shrink_mmap() actually does the freeing, and
> > can do this with minimal locking, and from within regular application
> > processes.  when a process calls shrink_mmap(), it will cause some pages
> > to be made available to GFP.
> 
> The page is not really free for reallocation, unless kswapd can
> push out the contents to disk, right? Which means, kswapd should
> have as minimal sleep/memallocation points as possible ...

kswapd itself always uses a gfp_mask that includes GFP_IO, so nothing it
calls will ever wait.  the I/O it schedules is asynchronous, and when
complete, the buffer exit code in end_buffer_io_async will set the page
flags appropriately for shrink_mmap() to come by and steal it. also, the
buffer code will use pre-allocated buffers if gfp fails.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
