From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14200.44196.867290.619751@dukat.scot.redhat.com>
Date: Tue, 29 Jun 1999 12:23:16 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <199906282215.PAA56865@google.engr.sgi.com>
References: <Pine.BSO.4.10.9906281740270.24888-100000@funky.monkey.org>
	<199906282215.PAA56865@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 15:15:29 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

>> kswapd itself always uses a gfp_mask that includes GFP_IO, so nothing it
>> calls will ever wait.  the I/O it schedules is asynchronous, and when
>> complete, the buffer exit code in end_buffer_io_async will set the page
>> flags appropriately for shrink_mmap() to come by and steal it. also, the
>> buffer code will use pre-allocated buffers if gfp fails.
>> 

> Which is why you must gurantee that kswapd can always run, and keep
> as few blocking points as possible ...

Look, we're just going round in circles here.

kswapd *can* always run.

kswapd never ever waits in its memory allocation calls.  In
get_free_pages(), we special case PF_MEMALLOC processes (such as kswapd)
and completely avoid trying to free pages in that case: rather, we rely
on the free page thresholds preserving a last-chance set of free pages
which are _only_ usable by such processes.

kswapd can wait for IO, but the block device layers go to great lengths
to ensure that this can always proceed safely.  If the device layers
need an extra memory allocation to succeed, that again is protected by
PF_MEMALLOC.

kswapd never waits for long-term-held filesystem locks: that is what
kpiod is for.

This architecture is very robust.  Add an extra mmap semaphore lock to
the swapout path and you destroy it.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
