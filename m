Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 435DE6B004D
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 20:42:45 -0400 (EDT)
Received: by iajr24 with SMTP id r24so11210485iaj.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 17:42:44 -0700 (PDT)
Date: Mon, 16 Apr 2012 17:42:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm code for allowing reclaim of page previously swapped but now
 clean-in-memory?
In-Reply-To: <681c22d4-96fb-4e15-9029-cd90956399de@default>
Message-ID: <alpine.LSU.2.00.1204161647530.1852@eggly.anvils>
References: <681c22d4-96fb-4e15-9029-cd90956399de@default>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, riel@redhat.com

On Sun, 15 Apr 2012, Dan Magenheimer wrote:

> I'm looking for mm code/heuristics/flags where the following occurs:
> 
> This (anonymous) page was:
> - previously swapped to a swap device
> - then later read back in from the swap device
> 
> Now memory pressure has resulted in a need to reclaim memory so:
> - this page is discovered to still be clean, i.e. it
>    matches the page still on the swap device, so
> - the pageframe is thus an obvious candidate for reclaim

Only a good candidate for reclaim when the page has not been accessed
recently, but was read in some while ago - not much point in doing
swapin readahead if we throw all the pages away immediately.

> 
> I'd be grateful for any pointers/education...
> For example, is such a page always in the swapcache?

Yes, until either page or swap is about to be freed.

> Is it also in the page cache?

I don't know what you mean by that question: if you consider the
swapcache a part of the pagecache, then yes it is also in the pagecache;
if you don't, then no it is not.  I consider swapcache a part of pagecache,
but you may not.

> Is it always INactive since it was read but never written?

No, it may be inactive or it may be active, that depends on activity ;)

> What flags are set/unset?

PageSwapCache PageUptodate !PageDirty: I think that's right but check.
PageAnon PageSwapBacked too, but probably irrelevant to your interest.
wait_on_page_writeback() to not interfere with PageWriteback pages.

Perhaps one of its mappings has pte_dirty not yet transferred to PageDirty,
and the page no longer represents what's on swap: nowadays we tend to free
the swap and remove page from swapcache before getting to that case,
but I expect there may be some ways.

> What function or code snippet identifies such a page

Perhaps you want shrink_page_list() in mm/vmscan.c: that's dealing with
many other cases too, but it is where __remove_mapping() gets applied
to the PageSwapCache !PageDirty page.

(I expect you know it well, but don't forget how page_mapping(page)
artificially points to swapper_space when PageSwapCache bit is set.)

And one of the places where we do the opposite: notice vm_swap_full()
(actually half full) and try_to_free_swap() rather than freeing page.

I think that opposite behaviour will become even more popular: keeping
stray isolated little blocks of swap allocated is bad for disk seeking
and bad for flash efficiency.

> and does this code need to be protected by the swaplock or pagelock or ???

You always (I dread saying "always", perhaps you'll find some exception)
need pagelock to add or delete a page from swapcache.  You also need
swapper_space.tree_lock to do the actual deed.  swap_lock for altering
the swap_map: changing the count or cached bit.

pagelock is the lock that gets relied upon all over, to protect a page
you're working on from disappearing unexpectedly from swapcache.
Even when you lookup_swap_cache(), it can be gone from swapcache
before you lock_page(), either by swapoff or by reuse_swap_page
or by some other route.

Hugh

> (Sorry if any of these are stupid questions...)
> 
> Purpose: I'm looking into zcache (and future KVM/memcg tmem backend)
> changes to exploit a "writethrough" and/or "lazy writeback" cacheing
> model for pages put into zcache via frontswap, as discussed with Andrea
> and one or two others at LSF12/MM.  Either model provides more
> flexibility for zcache to more effectively manage persistent pages.
> 
> Thanks!
> Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
