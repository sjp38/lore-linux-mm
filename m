Date: Thu, 11 Nov 2004 12:49:44 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: balance_pgdat(): where is total_scanned ever updated?
Message-ID: <20041111144944.GA16759@logos.cnet>
References: <200411061418_MC3-1-8E17-8B6C@compuserve.com> <20041106161114.1cbb512b.akpm@osdl.org> <20041109104220.GB6326@logos.cnet> <20041109113620.16b47e28.akpm@osdl.org> <20041109180223.GG7632@logos.cnet> <20041109134032.124b55fa.akpm@osdl.org> <20041109185221.GA8414@logos.cnet> <16786.5789.465433.655127@thebsh.namesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16786.5789.465433.655127@thebsh.namesys.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

switching to linux-mm

On Wed, Nov 10, 2004 at 04:24:45PM +0300, Nikita Danilov wrote:
> Marcelo Tosatti writes:
> 
> [...]
> 
>  > 
>  > Another related thing I noted this afternoon is that right now kswapd will
>  > always block on full queues:
>  > 
>  > static int may_write_to_queue(struct backing_dev_info *bdi)
>  > {
>  >         if (current_is_kswapd())
>  >                 return 1;
>  >         if (current_is_pdflush())       /* This is unlikely, but why not... */
>  >                 return 1;
>  >         if (!bdi_write_congested(bdi))
>  >                 return 1;
>  >         if (bdi == current->backing_dev_info)
>  >                 return 1;
>  >         return 0;
>  > }
>  > 
>  > We should make kswapd use the "bdi_write_congested" information and avoid
>  > blocking on full queues. It should improve performance on multi-device 
>  > systems with intense VM loads.
> 
> This will have following undesirable side effect: if
> may_write_to_queue() returns false, page is not paged out, instead it is
> thrown to the head of the inactive queue, thus destroying "LRU
> ordering", shrink_list() will dive deeper into inactive list, reclaiming
> hotter pages.
> It's OK to accidentially skip pageout in direct reclaim path, because
> 
>  - we hope most pageout is done by kswapd, and
> 
>  - we don't want __alloc_pages() to stall
> 
> but _something_ in the kernel should take a pain of actually writing
> pages out in LRU order.

I see - it breaks LRU ordering of pageout. 

>  > Maybe something along the lines 
>  > 
>  > "if the reclaim ratio is high, do not writepage"
>  > "if the reclaim ratio is below high, writepage but not block"
>  > "if the reclaim ratio is low, writepage and block"
> 
> If kswapd blocking is a concern, inactive list scanning should be
> decoupled from actual page-out (a la Solaris): kswapd queues pages to
> the yet another kernel thread that calls pageout().

Its just concern, no numbers to back that up.

But its pretty obvious that its behaviour is suboptimal when you 
think about multi-device systems. kswapd may block for example
in get_block() (there is a comment on top of pageout() about
that), which makes the situation even worse.

> I played with this idea (see
> http://nikita.w3.to/code/patches/2-6-10-rc1/async-writepage.txt note
> that async_writepage() has to be adjusted to work for kswapd), but while
> in some cases (large concurrent builds) it does provide a benefit, in
> other cases (heavy write through mmap) it makes throughput slightly
> worse.

Very sweet, I like it.

Why do you think the heavy write through mmap decreased throughput?

Would be nice if you had those numbers saved somewhere.

> Besides, this doesn't completely avoid the problem of destroying LRU
> ordering, as kswapd still proceeds further through inactive list while
> pages are sent out asynchronously.

Well pages are being sent out in order - which should do fine. o?

kswapd proceeds further through inactive list while pages are sent 
out asynchronously with the current design - pageout() writes,
 moves the pages (now under IO) to head of inactive list and 
continues.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
