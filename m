From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001140117.RAA86279@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 17:17:32 -0800 (PST)
In-Reply-To: <Pine.LNX.4.10.10001140304570.7119-100000@chiara.csoma.elte.hu> from "Ingo Molnar" at Jan 14, 2000 03:13:48 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> 
> On Thu, 13 Jan 2000, Linus Torvalds wrote:
> 
> > HOWEVER, I don't think this is going to be a huge issue in most cases. And
> > if people don't need non-DMA memory, then the pages we "swapped" out are
> > going to stay in RAM anyway, so it's not going to hurt us.
> > 
> > Anyway, I obviously do agree that I may well be wrong, and that real life
> > is going to come back and bite us, and we'll end up having to not do it
> > this way. However, I'd prefer trying the "conceptually simple" path first,
> > and only if it turns out that yes, I was completely wrong, do we try to
> > fix it up with magic heuristics etc.
> 
> hm., i think we'll see this with ISA soundcards (still the majority) if
> used as modules. Right now kswapd just gives up too easy and says 'no such
> page', on a box with lots of RAM and all DMA allocated in process VM
> space.
> 
> Anyway, the patch and suggestion of passing in a single zone is i believe
> completely wrong, because it advances mm->swap_address, which unfairly
> selects a given range to be checked for only one zone. So i think it's
> either zone-bitmaps (or equivalent multi-zone logic) or what you
> suggested, to have no zone-awareness in swap_out() for now at all.
> 
> (i believe this is also going to bite us with the IA64 port - kswapd will
> have no information to free pages from the right node, we could solve this
> already with a zone bitmap, or by starting per-zone kswapds. The latter

If you are talking about the discontig memory support, yes, I have thought
about that and arrived at the conclusion that rather than overdesign
right now, we will have to see how things work out on a real machine. 

There's been some arguments against per-zone, or per-node kswapd's, 
so the other alternative is to pass the list of unbalanced zones to
kswapd, which can then scan only the unbalanced ones. This is the 
best solution when there are fairly large number of nodes.

Kanoj

> one looks like overkill to me, but it's conceptually cleaner than bitmaps
> and and does not have a limitation on the number of zones. Might not be a
> highprio issue though.)
> 
> -- mingo
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
