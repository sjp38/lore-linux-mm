From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003202217.OAA94775@google.engr.sgi.com>
Subject: Re: More VM balancing issues..
Date: Mon, 20 Mar 2000 14:17:27 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10003201232410.4818-100000@penguin.transmeta.com> from "Linus Torvalds" at Mar 20, 2000 01:27:46 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christopher Zimmerman <zim@av.com>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

> 
> They happen to be inclusive on x86 (ie DMA <= direct-mapped <=
> everything), but I think it is a mistake to consider that a design. It's
> obviously not true on NUMA if you have per-CPU classes that fall back onto
> other CPU's zones. I would imagine, for example, that on NUMA the best
> arrangement would be something like
> 
>  - when making a NODE1 allocation, the "class" list is
> 
> 	NODE1, NODE2, NODE3, NODE4, NULL
> 
>  - when making a NODE2 allocation it would be
> 
> 	NODE2, NODE3, NODE4, NODE1, NULL
> 
>  etc...
> 
> (So each node would preferentially always allocate from its own zone, but
> would fall back on other nodes memory if the local zone fills up).

Okay, I think the crux of this discussion lies in this statement. I do
not believe this is what the numa code will do, but note that we are
not 100% certain at this stage. The numa code will be layered on top
of the generic code, (the primary goal being generic code should be 
impacted by numa minimally), so for example, the numa version of
alloc_pages() will invoke __alloc_pages() on different nodes. The
other thing to note is, the sequence of nodes to allocate is not
static, but dynamic (depending on other data structures that numa
code will track). This gives the most flexibility to numa code to
do the best thing performance wise for a wide variety of apps
under different situations. So apriori, you can not claim the class
list for NODE1 allocation will be "NODE1, NODE2, NODE3, NODE4, NULL".
I am ccing Hubertus Franke from IBM, we have been working on numa
issues together.

> 
> With something like the above, there is no longer any true inclusion. Each
> class covers an "equal" amount of zones, but has a different structure.
>
 
The only example I can think of is a hole architecture, as I mentioned
before, but even that can be handled with a "true inclusion" assumption.

Unless you can point to a processor/architecture to the contrary, for
the 2.4 timeframe, I would think we can assume true inclusion. (And that
will be true even if we come up with a ZONE_PCI32 for 64bit machines).

> > 2. The body of zone_balance_memory() should be replaced with the pre1
> > code, otherwise there are too many differences/problems to enumerate. 
> > Unless you are also proposing changes in this area.
> 
> The pre1 code was broken, and never checked pages_low. The changes were
> definitely pre-meditated - trying to think of the balancing as a "list of
> zones" issue.

Agreed, I pointed out the breakage when the balancing patch was sent out. 
I patched the pre1 code to get back to 2.3.50 behavior, and Christopher 
Zimmerman zim@av.com tested it out.

> 
> And I think it's fine that kswapd continues to run until we reach "high".
> Your patch makes kswapd stop when it reaches "low", but that makes kswapd
> go into this kind of "start/stop/start/stop" behaviour at around the "low"
> watermark.
> 
> Maybe you meant to clear the flags the other way around: keep kswapd
> running until it hits high, but remove the "low_on_mem" flag when we are
> above "low" (but we've gotten away from "min"). That might work, but I
> think clearing both flags at "high" is actually the right thing to do,
> because that way we will not get into a state where kswapd runs all the
> time because somebody is still allocating pages without helping to free
> anything up.
> 

Okay, that is a change on top of 2.3.50 behavior, this can be easily
implemented. As I mention in Documentation/vm/balance, low_on_memory
is a hysteric flag, zone_wake_kswapd/kswapd poking is not, we can 
change that. Do you want me to create a new patch against 2.3.99-pre2?

Kanoj

> The pre-3 behaviour is: if you ever hit "min", you set a flag that means
> "ok, kswapd can't do this on its own, and needs some help from the people
> that allocate memory all the time". If you think of it that way, I think
> you'll agree that it shouldn't be cleared until after kswapd says
> everything is ok again.
> 
> I don't know..
> 
> 		Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
