Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4526B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 17:29:33 -0400 (EDT)
Date: Wed, 29 Apr 2009 14:28:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
Message-Id: <20090429142825.6dcf233d.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: mel@csn.ul.ie, andi@firstfloor.org, davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Apr 2009 22:09:48 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> On an x86_64 with 4GB ram, tcp_init()'s call to alloc_large_system_hash(),
> to allocate tcp_hashinfo.ehash, is now triggering an mmotm WARN_ON_ONCE on
> order >= MAX_ORDER - it's hoping for order 11.  alloc_large_system_hash()
> had better make its own check on the order.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> Should probably follow
> page-allocator-do-not-sanity-check-order-in-the-fast-path-fix.patch
> 
> Cc'ed DaveM and netdev, just in case they're surprised it was asking for
> so much, or disappointed it's not getting as much as it was asking for.
> 
>  mm/page_alloc.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> --- 2.6.30-rc3-mm1/mm/page_alloc.c	2009-04-29 21:01:08.000000000 +0100
> +++ mmotm/mm/page_alloc.c	2009-04-29 21:12:04.000000000 +0100
> @@ -4765,7 +4765,10 @@ void *__init alloc_large_system_hash(con
>  			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
>  		else {
>  			unsigned long order = get_order(size);
> -			table = (void*) __get_free_pages(GFP_ATOMIC, order);
> +
> +			if (order < MAX_ORDER)
> +				table = (void *)__get_free_pages(GFP_ATOMIC,
> +								order);
>  			/*
>  			 * If bucketsize is not a power-of-two, we may free
>  			 * some pages at the end of hash table.

yes, the code is a bit odd:

:	do {
: 		size = bucketsize << log2qty;
: 		if (flags & HASH_EARLY)
: 			table = alloc_bootmem_nopanic(size);
: 		else if (hashdist)
: 			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
: 		else {
: 			unsigned long order = get_order(size);
: 			table = (void*) __get_free_pages(GFP_ATOMIC, order);
: 			/*
: 			 * If bucketsize is not a power-of-two, we may free
: 			 * some pages at the end of hash table.
: 			 */
: 			if (table) {
: 				unsigned long alloc_end = (unsigned long)table +
: 						(PAGE_SIZE << order);
: 				unsigned long used = (unsigned long)table +
: 						PAGE_ALIGN(size);
: 				split_page(virt_to_page(table), order);
: 				while (used < alloc_end) {
: 					free_page(used);
: 					used += PAGE_SIZE;
: 				}
: 			}
: 		}
: 	} while (!table && size > PAGE_SIZE && --log2qty);

In the case where it does the __vmalloc(), the order-11 allocation will
succeed.  But in the other cases, the allocation attempt will need to
be shrunk and we end up with a smaller hash table.  Is that sensible?

If we want to regularise all three cases, doing

	size = min(size, MAX_ORDER);

before starting the loop would be suitable, although the huge
__get_free_pages() might still fail.  (But it will then warn, won't it?
 And nobody is reporting that).

I was a bit iffy about adding the warning in the first place, let it go
through due to its potential to lead us to code which isn't doing what
it thinks it's doing, or is being generally peculiar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
