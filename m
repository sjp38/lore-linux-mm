Date: Fri, 17 Mar 2000 18:59:19 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: More VM balancing issues..
In-Reply-To: <200003172223.OAA37594@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10003171847170.831-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christopher Zimmerman <zim@av.com>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Kanoj,
 would you mind looking at the balancing idea in pre2-4? I put it out that
way, because it's the easiesy way for me to show what I was thinking
about, but it may be something I just punt on for a real pre-2.4 kernel..

Basically, I never liked the thing that was based on adding up the total
and free pages of different zones. It gave us the old 2.2 behaviour (or
close to it), but it's a global decision on something that really is a
local issue, I think. And it definitely doesn't make sense on a NUMA thing
at all.

So I have this feeling that balancing really should be purely a per-zone
thing, and purely based on the size and freeness of that particular zone.
That would allow us to make clear decisions like "we want to keep 2% of
the regular zones free, but for the DMA zone we want to keep that 10% free
because it more easily becomes a resource issue". 

So my approach would be:
 - each zone is completely independent
 - when allocating from a zone-list, the act of allocation is the only
   thing that should care about the "conglomerate" of zones.

So what I do in pre2-4 is basically:
 - __alloc_pages() walks all zones. If it finds one that has "enough"
   pages, it will just allocate from the first such zone it finds.
 - if none of the zones have "enough" pages, it does a zone-list balance. 
 - the zone-list balance will walk the list of zones again, and do the
   right thing for each of them. It will return successfully if it was
   able to free up some memory (or if it decides that it's not critical
   and we could just start kswapd without even trying to free anything
   ourselves)
 - if the zonelist balance succeeded, __alloc_pages() will walk the zones
   again and try to allocate memory, this time regardless of whether they
   have "enough" memory (because we freed some memory we can do that).

This avoids making any global decisions: it works naturally whatever the
zone-list looks like. It still tries to first allocate from the first
zone-lists, so it still has the advantage of leaving the DMA zone-list
pretty quiescent as it's the last zone on the lists - so the DMA zone list
will tend to have "enough" pages.

What my patch does NOT do is to change the zone_balance_ratio[] stuff etc,
but I think that with this approach it is now truly meaningful to do that,
and that we now really _can_ try to keep the DMA area at a certain
percentage etc..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
