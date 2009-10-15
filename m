Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 53A276B004D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 19:53:39 -0400 (EDT)
Date: Fri, 16 Oct 2009 00:53:36 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 7/9] swap_info: swap count continuations
In-Reply-To: <20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910160016160.11643@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150153560.3291@sister.anvils>
 <20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, hongshin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Oct 2009 01:56:01 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > This patch implements swap count continuations: when the count overflows,
> > a continuation page is allocated and linked to the original vmalloc'ed
> > map page, and this used to hold the continuation counts for that entry
> > and its neighbours.  These continuation pages are seldom referenced:
> > the common paths all work on the original swap_map, only referring to
> > a continuation page when the low "digit" of a count is incremented or
> > decremented through SWAP_MAP_MAX.
> 
> Hmm...maybe I don't understand the benefit of this style of data structure.

I can see that what I have there is not entirely transparent!

> 
> Do we need fine grain chain ? 
> Is  array of "unsigned long" counter is bad ?  (too big?)

I'll admit that that design just happens to be what first sprang
to my mind.  It was only later, while implementing it, that I
wondered, hey, wouldn't it be a lot simpler just to have an
extension array of full counts?

It seemed to me (I'm not certain) that the char arrays I was
implementing were better suited to (use less memory in) a "normal"
workload in which the basic swap_map counts might overflow (but
I wonder how normal is any workload in which they overflow).
Whereas the array of full counts would be better suited to an
"aberrant" workload in which a mischievous user is actually
trying to maximize those counts.  I decided to carry on with
the better solution for the (more) normal workload, the solution
less likely to gobble up more memory there than we've used before.

While I agree that the full count implementation would be simpler
and more obviously correct, I thought it was still going to involve
a linked list of pages (but "parallel" rather than "serial": each
of the pages assigned to one range of the base page).

Looking at what you propose below, maybe I'm not getting the details
right, but it looks as if you're having to do an order 2 or order 3
page allocation?  Attempted with GFP_ATOMIC?  I'd much rather stick
with order 0 pages, even if we do have to chain them to the base.

(Order 3 on 64-bit?  A side issue which deterred me from the full
count approach, was the argumentation we'd get into over how big a
full count needs to be.  I think, for so long as we have atomic_t
page count and page mapcount, an int is big enough for swap count.
But switching them to atomic_long_t may already be overdue.
Anyway, I liked how the char continuations avoided that issue.)

I'm reluctant to depart from what I have, now that it's tested;
but yes, we could perfectly well replace it by a different design,
it is very self-contained.  The demands on this code are unusually
simple: it only has to manage counting up and counting down;
so it is very easily tested.

(The part I found difficult was getting rid of the __GFP_ZERO
I was allocating with originally.)

Hugh

> 
> ==
> #define EXTENTION_OFFSET_INDEX(offset)	(((offset) & PAGE_MASK)
> #define EXTENTION_OFFSET_MASK		(~(PAGE_SIZE/sizeof(long) - 1))
> struct swapcount_extention_array {
> 	unsigned long *map[EXTEND_MAP_SIZE];
> };
> 	
> At adding continuation.
> 
> int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
> {
> 	struct page *page;
> 	unsigned long *newmap, *map;
> 	struct swapcount_extention_array *array;
> 
> 	newmap = __get_free_page(mask);
> 	si = swap_info_get(entry);
> 	array = kmalloc(sizeof(swapcount_extention_array);
> 
> 	....
> 	(If overflow)
> 	page = vmalloc_to_page(si->swap_map + offset);
> 	if (!PagePrivate(page)) {
> 		page->praivate = array;
> 	} else
> 		kfree(array);
> 
> 	index = EXTENTION_OFFSET_INDEX(offset);
> 	pos = EXTENTION_OFFSET_MASK(offset);
> 
> 	array = page->private;
> 	if (!array->map[index]) {
> 		array->map[index] = newmap;
> 	} else
> 		free_page(newmap);
> 	map = array->map[index];
> 	map[pos] += 1;
> 	mappage = vaddr_to_page(map);
> 	get_page(mappage); # increment page->count of array.
> ==
> 
> Hmm? maybe I just don't like chain...
> 
> Regards,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
