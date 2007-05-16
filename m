Date: Wed, 16 May 2007 20:18:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] optimise unlock_page
Message-ID: <20070516181847.GD5883@wotan.suse.de>
References: <20070508225012.GF20174@wotan.suse.de> <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com> <20070510033736.GA19196@wotan.suse.de> <Pine.LNX.4.64.0705101935590.18496@blonde.wat.veritas.com> <20070511085424.GA15352@wotan.suse.de> <Pine.LNX.4.64.0705111357120.3350@blonde.wat.veritas.com> <20070513033210.GA3667@wotan.suse.de> <Pine.LNX.4.64.0705130535410.3015@blonde.wat.veritas.com> <20070513065246.GA15071@wotan.suse.de> <Pine.LNX.4.64.0705161838080.16762@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705161838080.16762@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 16, 2007 at 06:54:15PM +0100, Hugh Dickins wrote:
> On Sun, 13 May 2007, Nick Piggin wrote:
> > On Sun, May 13, 2007 at 05:39:03AM +0100, Hugh Dickins wrote:
> > > On Sun, 13 May 2007, Nick Piggin wrote:
> > > > On Fri, May 11, 2007 at 02:15:03PM +0100, Hugh Dickins wrote:
> > > > 
> > > > > Hmm, well, I think that's fairly horrid, and would it even be
> > > > > guaranteed to work on all architectures?  Playing with one char
> > > > > of an unsigned long in one way, while playing with the whole of
> > > > > the unsigned long in another way (bitops) sounds very dodgy to me.
> > > > 
> > > > Of course not, but they can just use a regular atomic word sized
> > > > bitop. The problem with i386 is that its atomic ops also imply
> > > > memory barriers that you obviously don't need on unlock.
> > > 
> > > But is it even a valid procedure on i386?
> > 
> > Well I think so, but not completely sure.
> 
> That's not quite enough to convince me!

I did ask Linus, and he was very sure it works.


> I do retract my "fairly horrid" remark, that was a kneejerk reaction
> to cleverness; it's quite nice, if it can be guaranteed to work (and
> if lowering FLAGS_RESERVED from 9 to 7 doesn't upset whoever carefully
> chose 9).

Hmm, it is a _little_ bit horrid ;) Maybe slightly clever, but definitely
slightly horrid as well!

Not so much from a high level view (although it does put more constraints
on the flags layout), but from a CPU level... the way we intermix different
sized loads and stores can run into store forwarding issues[*] which might
be expensive as well. Not to mention that we can't do the non-atomic
unlock on all architectures.

OTOH, it did _seem_ to eliminate the pagefault regression on my P4 Xeon
here, in one round of tests.

The other option of moving the bit into ->mapping hopefully avoids all
the issues, and would probably be a little faster again on the P4, at the
expense of being a more intrusive (but it doesn't look too bad, at first
glance)...

[*] I did mention to Linus that we might be able to avoid the store
forwarding stall by loading just a single byte to test PG_waiters after
the byte store to clear PG_locked. At this point he puked. We decided
that using another field altogether might be better.


> Please seek out those guarantees.  Like you, I can't really see how
> it would go wrong (how could moving in the unlocked char mess with
> the flag bits in the rest of the long? how could atomically modifying
> the long have a chance of undoing that move?), but it feels like it
> might take us into errata territory.

I think we can just rely on the cache coherency protocol taking care of
it for us, on x86. movb would not affect other data other than the dest.
A non-atomic op _could_ of course undo the movb, but it could likewise
undo any other store to the word or byte. An atomic op on the flags does
not modify the movb byte so the movb before/after possibilities should
look exactly the same regardless of the atomic operations happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
