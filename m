From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16787.49024.823151.335663@gargle.gargle.HOWL>
Date: Thu, 11 Nov 2004 22:37:36 +0300
Subject: Re: balance_pgdat(): where is total_scanned ever updated?
In-Reply-To: <20041111144944.GA16759@logos.cnet>
References: <200411061418_MC3-1-8E17-8B6C@compuserve.com>
	<20041106161114.1cbb512b.akpm@osdl.org>
	<20041109104220.GB6326@logos.cnet>
	<20041109113620.16b47e28.akpm@osdl.org>
	<20041109180223.GG7632@logos.cnet>
	<20041109134032.124b55fa.akpm@osdl.org>
	<20041109185221.GA8414@logos.cnet>
	<16786.5789.465433.655127@thebsh.namesys.com>
	<20041111144944.GA16759@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti writes:
 > 

[...]

 > 
 > > I played with this idea (see
 > > http://nikita.w3.to/code/patches/2-6-10-rc1/async-writepage.txt note
 > > that async_writepage() has to be adjusted to work for kswapd), but while
 > > in some cases (large concurrent builds) it does provide a benefit, in
 > > other cases (heavy write through mmap) it makes throughput slightly
 > > worse.
 > 
 > Very sweet, I like it.

Additional advantage of async-writepage is that in this case one has
whole queue of dirty pages ready for page-out, so that some smarter
clustering can be implemented.

 > 
 > Why do you think the heavy write through mmap decreased throughput?

Because I thought I measured it, but see below :)

 > 
 > Would be nice if you had those numbers saved somewhere.

Second column is averaged number of microseconds it takes to dirty 1G
through mmap (big file larger than ram is mmapped in 1G chunks and one
byte at each its page is touched in a loop). Rows correspond to patches
from http://nikita.w3.to/code/patches/2-6-10-rc1/ applied one after
another.

2.6.10-rc1                      77370854.641026
skip-writepage                  72766988.375000
dont-rotate-active-list         71440066.068966
async-writepage                 75028707.083333 /* regression */
batch-mark_page_accessed        74183312.078947
page_referenced-move-dirty      72947326.125000
dont-unmap-on-pageout           72702028.843750
ignore-page_referenced          74188417.156250 /* regression */
cluster-pageout                 69449001.583333

Err... now that I pasted this, I recall that async-writepage patch
tested above does _not_ allow kswapd to do asynchronous page-out:

----------------------------------------------------------------------
/*
 * check whether writepage should be done asynchronously by kaiod.
 */
static int
async_writepage(struct page *page, int nr_dirty)
{
	/* goal of doing writepage asynchronously is to decrease latency of
	 * memory allocations involving direct reclaim, which is inapplicable
	 * to the kswapd */
	if (current_is_kswapd())
		return 0;
	/* limit number of pending async-writepage requests */
	else if (kaio_nr_requests > KAIO_THROTTLE)
		return 0;
	/* if we are under memory pressure---do pageout synchronously to
	 * throttle scanner. */
	else if (page_zone(page)->prev_priority != DEF_PRIORITY)
		return 0;
	/* if expected number of writepage requests submitted by this
	 * invocation of shrink_list() is small enough---do them
	 * asynchronously */
	else if (nr_dirty <= KAIO_CLUSTER_SIZE)
		return 1;
	else
		return 0;
}
----------------------------------------------------------------------

First if ... return 0; should be removed.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
