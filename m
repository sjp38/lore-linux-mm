Date: Sun, 15 Dec 2002 10:36:12 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: freemaps
In-Reply-To: <3DFC455E.1FD92CBC@digeo.com>
Message-ID: <Pine.LNX.4.44.0212151026210.3341-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Frederic Rossi (LMC)" <Frederic.Rossi@ericsson.ca>, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

On Sun, 15 Dec 2002, Andrew Morton wrote:

> Ingo Molnar wrote:
> > 
> > ...
> > another approach might be to maintain some sort of tree of holes.
> 
> This one, I'd suggest.  If we're going to fix this we may as
> well fix it right.  Otherwise there will always be whacky failure
> modes.
> 
> Trees are tricky, because we don't like to recur.
> 
> I expect this could be solved with two trees:
> 
> - For searching, a radix-tree indexed by hole size.  A list
>   of same-sized holes at each leaf.
> 
> - For insertion (where we must perform merging) an rbtree.

yes. I suspect this is close to what Andrea has/had in mind?

> But:
> 
> - Do we need to keep the lists of same-sized holes sorted by
>   virtual address, to avoid fragmentation?

the best anti-fragmentation technique is i guess what we have now: to use
the smallest matching hole at the lowest possible address. I think we
should give up strong anti-fragmentation techniques only once 32-bit
address spaces have become a distant memory, definitely not these days,
when the problems created by the limits of the 32-bit address space are
probably at their peak point in history.

but, before we go forward, i'd really suggest to run _real_ tests. The
free-area cache i added was to address one specific real-life workload.  
Frederic's test i dont know. One area i'd suspect we still suck somewhat
are the JITs and the memory protectorsm, but the loss due to the free-area
searching has to be quantified. Obviously, until trees are introduced
there will always be regressions.

> - Do all mm's incur all this stuff, or do we build it all when
>   some threshold is crossed?

we had some sort of threshold ages ago - i'd rather have a fast
constructor for this stuff instead of trying to hide the costs by cutting
off the small-size cases. I think basically everything but benchmarks will
have more than just a few mappings.

> - How does it play with non-linear mappings?

nonlinear mappings do not care about the structure of vmas (and the
structure of inverse vmas) - they are special types of vmas.

	Ingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
