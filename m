Date: Sat, 9 Jun 2001 00:15:15 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM tuning patch, take 2
In-Reply-To: <l03130318b74568171b40@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106090012230.10415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2001, Jonathan Morton wrote:

> - ageing is now done evenly, and independently of the number of
> mappings on a given page.  This is done by introducing a 4th LRU list
> (aside from active, inactive_clean and inactive_dirty) which holds
> pages attached to a process but not in the swapcache.

IMHO it would be better to add these to the active list so both
filesystem-backed and swap-backed pages will be aged the same.

> - try_to_swap_out() will now refuse to move a page into the swapcache
> which still has positive age.  This helps preserve the working set
> information, and may help to reduce swap bloat.  It may re-introduce
> the cause of cache collapse, but I haven't seen any evidence of this
> being disastrous, as yet.

This should only affect swap bloat and nothing else. The "cache
collapse" thing vmstat might show is just a "lack" of swap cache
pages being generated...

> - new pages are still given an age of PAGE_AGE_START, which is 2.
> PAGE_AGE_ADV has been increased to 4, and PAGE_AGE_MAX to 128.  Pages which
> are demand-paged in from swap are given an initial age of PAGE_AGE_MAX/2,
> or 64 - this should help to keep these (expensive) pages around for as long
> as possible.  Ageing down is now done using a decrement instead of a
> division by 2, preserving the age information for longer.

I think the PAGE_AGE_START should be the same for all pages.
About decrement vs. division by two, I think this is something
we may want to make tunable (I have the code for this floating
around somewhere, hold on).


regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
