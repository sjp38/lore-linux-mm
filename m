Message-ID: <3D6D3F88.5E7A1972@zip.com.au>
Date: Wed, 28 Aug 2002 14:24:24 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: slablru for 2.5.32-mm1
References: <200208261809.45568.tomlins@cam.org> <3D6AC0BB.FE65D5F7@zip.com.au> <200208281306.58776.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> Hi Andrew
> 
> Here is slablru for 32-mm1.  This is based on a version ported to 31ish-mm1.  It should be
> stable.  Its been booted as UP (32-mm1) and SMP on UP  (31ish-mm1 only) and works as expected.

Cool.  But the diff adds tons of stuff which is already added by -mm1.
I suspect you diffed against 2.5.31 base?

> A typical test cycle involved:
> find / -name "*" > /dev/null
> edit a large tif with the gimp
> run dbench a few times with the dbench dir on tmpfs (trying to use gimp too)
> run dbench a few times from a reiserfs dir (trying to use gimp too)
> use the box for news/mail, atp-get update/upgrade etc, wait a few hours and repeat
> 
> 31ish-mm1 survived a day of this, 32-mm1 is sending this message after one cycle.
> 
> Andrew, what do you thing about adding slablru to your experimental dir?

No probs.
 
> There is also a version for virgin 2.5.32, anyone wanting it should email me - one big
> patch is eats enough bandwidth.
> 
> One interesting change in this version.  We only add the first page of a slab to the lru.  The
> reference bit setting logic for slabs has been modified to set the bit on the first page.
> Pagevec created a little bit of a problem for slablru.  How do we know the order of the
> slab page when its being freed?   My solution is to use 3 bits in page->flags and save the
> order there.  Then free_pages_ok was modified to take the order from page->flags.  This
> was implement in a minimal fashion.  Think Wli is working on a more elaborate version of
> this - fleshed out, it could be used to support large pages in the vm.

hm.  What happened to the idea of walking mem_map[], looking for continuation
pages? (This would need to be done via pfn_to_page(), I guess).
 
> Second topic.
> 
> I have also included an optimisation for vmscan.  I found that the current code would reduce
> the inactive list to almost nothing when applications create large numbers of active pages very
> quickly run (ie. gimp loading and editing large 20m+ tiffs).  This reduces the problem.   Always
> allowing nr_pages to be scanned caused the active list to be reduced to almost nothing when
> something like gimp exited and we had another task adding lots to the inactive list.  This
> is fixed here too.  I do wonder if zone->refill_counter, as implemented, is a great idea.  Do
> we really need/want to remember to scan the active list if it has massively decreased in size
> because some app exited?  Maybe some sort of decay logic should be used...
> 

Well the refill counter thingy is just an optimisation: rather than calling refill_inacative()
lots of times to just grab two or three pages, we wait until it builds up to 32, and then
go deactivate 32 pages.

But ugh, it's a bit broken.  Yup, you're right.  Need to s/if/while/ in shrink_zone().

But we do need to slowly sift through the active list even when the inactive
list is enormously bigger.  Otherwise, completely dead pages will remain in-core
forever if there's a lot of pagecache activity going on.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
