Date: Mon, 20 Mar 2000 13:27:46 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: More VM balancing issues..
In-Reply-To: <200003202029.MAA75378@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10003201232410.4818-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christopher Zimmerman <zim@av.com>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Mar 2000, Kanoj Sarcar wrote:
> 
> 1. In a theoretical sense, there are _only_ memory classes. DMA class 
> memory, direct mapped class memory and the rest.

Definitely. I agree 100% that "classes" are really the fundamental factor
of allocation (and thus of balancing).  And I tried to preserve that,
exactly by having the zone_balance() thing become a "class" thing by
walking the list of zones that constitutes a class.

>					 Code will ask for a 
> dma, regular or other class memory (proactive balancing is needed for 
> intr context allocations or otherwise when page stealing is impossible
> or deadlock prone). Hence, theoretically, it makes sense to decide
> how many pages in each memory _class_ we want to keep free for such
> requests (based on application type, #cpu, memory, devices and fs
> activity). Decisions on when pages need to be stolen should really be
> _class_ based.

Yes. However, I think that in general is a quite difficult problem, given
that the zones that constitute classes are not at all necessarily
inclusive.

They happen to be inclusive on x86 (ie DMA <= direct-mapped <=
everything), but I think it is a mistake to consider that a design. It's
obviously not true on NUMA if you have per-CPU classes that fall back onto
other CPU's zones. I would imagine, for example, that on NUMA the best
arrangement would be something like

 - when making a NODE1 allocation, the "class" list is

	NODE1, NODE2, NODE3, NODE4, NULL

 - when making a NODE2 allocation it would be

	NODE2, NODE3, NODE4, NODE1, NULL

 etc...

(So each node would preferentially always allocate from its own zone, but
would fall back on other nodes memory if the local zone fills up).

With something like the above, there is no longer any true inclusion. Each
class covers an "equal" amount of zones, but has a different structure.

So I think the ordering is important (it implies preferences within a
class), but I don't the the total inclusion is.

> 2. Linux uses zones to implement memory classes. The DMA zone represents
> DMA class, the DMA+regular zone represents regular class, and the
> DMA+regular+himem zone represents other class. Theoretically, that is
> why decisions on page stealing need to be cumulative on the zones.
> (This explains why I did most of the code that way).

With strictly ordered classes, the cumulative aproach works. It does't
work for anything that is only partially ordered.

> 4. In 2.3.50 and pre1, zone_balance_ratio[] is the ratio of each _class_
> of memory that you want free, which is intuitive.

I disagree about the "intuitive" part. Yes, zone_balance_ratio is how each
class was to be balanced, but it's definitely not intuitive, with
different zones being in different classes, and the actual tests being
done per zone.

> Coming specifically to the 2.3.99-pre2 code, I see a couple of bugs:
> 1. __alloc_pages needs to return NULL instead of doing zone_balance_memory
> for the PF_MEMALLOC case.

Yup. I actually had this on my mental list, but it got dropped.

> 2. The body of zone_balance_memory() should be replaced with the pre1
> code, otherwise there are too many differences/problems to enumerate. 
> Unless you are also proposing changes in this area.

The pre1 code was broken, and never checked pages_low. The changes were
definitely pre-meditated - trying to think of the balancing as a "list of
zones" issue.

And I think it's fine that kswapd continues to run until we reach "high".
Your patch makes kswapd stop when it reaches "low", but that makes kswapd
go into this kind of "start/stop/start/stop" behaviour at around the "low"
watermark.

Maybe you meant to clear the flags the other way around: keep kswapd
running until it hits high, but remove the "low_on_mem" flag when we are
above "low" (but we've gotten away from "min"). That might work, but I
think clearing both flags at "high" is actually the right thing to do,
because that way we will not get into a state where kswapd runs all the
time because somebody is still allocating pages without helping to free
anything up.

The pre-3 behaviour is: if you ever hit "min", you set a flag that means
"ok, kswapd can't do this on its own, and needs some help from the people
that allocate memory all the time". If you think of it that way, I think
you'll agree that it shouldn't be cleared until after kswapd says
everything is ok again.

I don't know..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
