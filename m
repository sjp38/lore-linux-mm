From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003132328.PAA31009@google.engr.sgi.com>
Subject: Re: [patch] first bit of vm balancing fixes for 2.3.52-1
Date: Mon, 13 Mar 2000 15:28:41 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10003131454560.1031-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 13, 2000 02:55:39 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> On Mon, 13 Mar 2000, Ben LaHaise wrote:
> >
> > This is the first little bit of a few vm balancing patches I've been
> > working on.  It does two main things: moves the lru_cache list into the
> > per-zone structure, and slightly reworks the kswapd wakeup logic so the
> > zone_wake_kswapd flag is cleared in free_pages_ok.  Moving the lru_cache
> > list into the zone structure means we can make much better progress when
> > trying to free a specific type of memory.  Moving the clearing of the
> > zone_wake_kswapd flag into the free_pages routine stops kswapd from
> > continuing to swap out ad nausium: my box will discard the entire page
> > cache when it hits low memory when doing a simple sequential read.  With
> > this patch in place it hovers around 3MB free as it should.
> 
> Looks sane to me.
> 
> 		Linus

I am not sure about the zone lru_cache, since any claims without extensive
performance testing is meaningless ... but it does look more cleaner
theoretically. 

About the zone_wake_kswapd clearing in free_pages, yes, it is the right
thing to do ... looking at 2.2, a similar thing was done (ie, nr_free_pages
was updated, which was a signal to the balancing code). Unfortunately, 
this leads to a classfree() call in both pagefree and pagealloc, but I guess
thats the cost of fixing the memory class bugs present in 2.2. 

I do have a problem though with the way the zone_wake_kswapd flag is
otherwise being manipulated in the patch. The rules by which low_on_memory,
zone_wake_kswapd and kswapd poking is done is in Documentation/vm/balance.
I think free_pages_ok also needs to clear the low_on_memory (its never
being cleared in your code). I think the code in the (free <= z->pages_high)
in __alloc_pages() should stay the way it is, unless you can come up for 
a logic for changing it.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
