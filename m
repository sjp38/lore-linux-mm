Subject: Re: mapped page in prep_new_page()..
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.58.0402262305000.2563@ppc970.osdl.org>
References: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org>
	 <20040226225809.669d275a.akpm@osdl.org>
	 <Pine.LNX.4.58.0402262305000.2563@ppc970.osdl.org>
Content-Type: text/plain
Message-Id: <1077878329.22925.321.camel@gaston>
Mime-Version: 1.0
Date: Fri, 27 Feb 2004 21:38:50 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, hch@infradead.org, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

> > > 	DAR: 0000005f00000008, DSISR: 0000000040000000
> 
> Heh. I've had this G5 thing for a couple of weeks, I'm not very good at 
> reading the oops dump either ;)

DAR is the access address for a 300 trap

> The ppc64 page fault oops thing seems to be braindead, and not even print 
> out the address. Stupid. Somebody is too used to debuggers, and as a 
> result users aren't helped to make good reports, hint hint..

Hehe :)

> Anyway, a little digging shows that the thing seems to be the instruction
> 
> 	.. r3 is "struct page *" ..
> 	ld      r10,64(r3)	/* r10 is "page->pte.direct" */
> 
> 	...
> 
> 	ld      r0,0(r3)	/* r0 is "page->flags */
> 	rldicl  r0,r0,48,63
> 	cmpwi   r0,0		/* PageDirect(page) ? */
> 
> 	... nope, direct bit not set ...
> 
> 	ld      r0,8(r10)
> 
> where r10 (as per above) is 0x0000005F00000000.  So the fault address
> would have been 0x0000005F00000008.
> 
> The value of r3 is interesting: C000000000FFFFC0. That's _just_ under the 
> 16MB mark, and the offset of the "page->pte.direct" access is 64 bytes. 
> Which means that the corrupted data was at _exactly_ the 16MB mark.
> 
> Now, I have no idea why, but it's an interesting - if slightly odd -
> detail.
> 
> Who would write the value quadword 0x0000005F00000000 to the physical
> address 1<<24? And is that a valid "struct page *" in the first place? 
> Probably. 
> 
> Bad pointer crapola? Or some subtle CPU bug with address arithmetic that
> crosses the 16MB border?  Anton, BenH, any ideas?

I don't beleive in a subtle CPU bug... we are chasing a +/- random
corruption bug that happens not just on G5s and we think it may be
related.

Did you have slab poisoning ? I wonder if it could be a use after
free ... That or a subtle ordering issue (missing barrier somewhere)
leading to crap.

The interesting bit is that 16Mb point... If that ever happen again
let me know.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
