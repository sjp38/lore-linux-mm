Message-ID: <3D3C6A88.D6798722@zip.com.au>
Date: Mon, 22 Jul 2002 13:26:48 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: alloc_pages_bulk
References: <1615040000.1027363248@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Bill Irwin <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
>                 min += z->pages_min;
>                 if (z->free_pages > min) {
> -                       page = rmqueue(z, order);
> +                       page = rmqueue(z, order, count, pages);

This won't compile because your rmqueue() no longer returns a
page pointer.  Minor point, but the weightier question is:
what to do when you fix it up?  If the attempt to allocate N
pages would cause a watermark to be crossed then should we

a) ignore it, and just return the N pages anyway?

   Has a risk that a zillion CPUs could all hit the same code
   at the same time and would exhaust the page reserves.

   That's not very worrying, really.

b) Stop allocating pages when we hit the watermark and return
   a partial result to the caller

c) Stop allocating pages at the watermark, run off and do
   some page reclaim and start allocating pages again.

   This implies that we should be releasing more than one
   page into current->local_pages.

   Probably we should be doing this anyway - just queue _all_ the
   liberated pages onto local_pages, then satisfy the request from that
   pool, then gang-free the remainder.  That's a straight-line speedup
   and lock-banging optimisation against the existing code.

d) Look at pages_min versus count before allocating any pages.  If
   the allocation of `count' pagess would cause ->free_pages to fall
   below min, then go run some reclaim _first_, and then go grab a
   number of pages.  That number is min(count, nr_pages_we_just_reclaimed).
   So the caller may see a partial result.

I think d), yes?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
