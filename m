Message-ID: <391499C8.D4FDA2E6@norran.net>
Date: Sun, 07 May 2000 00:16:40 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: PG_referenced and lru_cache (cpu%)...
References: <Pine.LNX.4.21.0005061529280.4627-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Sat, 6 May 2000, Roger Larsson wrote:
> 
> > When _add_to_page_cache adds a page to the lru_cache
> > it forces it to be referenced.
> > In addition it will be added as youngest in list.
> 
> Which is IMHO a good thing, since the page *was* referenced
> and was referenced last.

Ok, I can buy that.

> 
> > When a page is needed it is very likely that a lot of
> > the youngest pages are marked as referenced.
> 
> > order=0 is the only that tries to search the full list.
> 
> No. Referenced pages are not counted, so if we encounter
> a lot of them we will happily age them all without decreasing
> the value of count.

But if it is first in the order==0 run that they are found...

Extreme example:
Suppose all DMA pages are referenced and last in list. No other zones
with pressure.
order = [6..1] will not find them.
order = 0 will, but since they are referenced they are put in young.
shrink_mmap will loop (256 times) without finding them...
And return 0.
order is 0
=> no more shrink_mmap will be called...
=> the pages were not found.

I would feel a lot safer if the young pages was inserted at top
of lru_cache instead of in another local list.
With them in lru_cache they will be searched if it needs to
loop that far...

/RogerL

PS.
  This feels a little like archaeology with a new algorithm
  soon to be released...
  But at leas I can learn a lot from it - Rik thanks for your replies!
DS

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
