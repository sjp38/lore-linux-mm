Date: Mon, 15 Jul 2002 18:40:16 +0300
From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Message-ID: <20020715184016.W28720@mea-ext.zmailer.org>
References: <55160000.1026239746@baldur.austin.ibm.com> <E17TMiO-0003IR-00@starship> <10930000.1026741760@baldur.austin.ibm.com> <E17U7Gr-0003bX-00@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E17U7Gr-0003bX-00@starship>; from phillips@arcor.de on Mon, Jul 15, 2002 at 04:56:16PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2002 at 04:56:16PM +0200, Daniel Phillips wrote:
> On Monday 15 July 2002 16:02, Dave McCracken wrote:
> > --On Saturday, July 13, 2002 03:13:35 PM +0200 Daniel Phillips
> > <phillips@arcor.de> wrote:
> > > Why are we using up valuable real estate in page->flags when the low bit
> > > of page->pte_chain is available?
> > 
> > Right now my flag is bit number 18 in page->flags out of 32.  Mechanisms
> > already exist to manipulate this bit in a reasonable fashion.  I don't see
> > any good reason for complicating things by putting a flag bit into a
> > pointer, where we'd have to repeatedly check and clear it before we
> > dereference the pointer.
> 
> Hi Dave,
> 
> It's not more complicated.  You have to check which type of pointer you
> have anyway, and having to strip away the low bit on one of the two
> paths is insignificant in terms of generated code.  The current patch
> has to set and clear the flag bit separately.

  Better not try to play tricks with pointer bits.

  Take  ibm360 - pointers are 24 bit, 8 high-order bits are free for
                 application.  (ibm 370/XA and 390 redefine things.)
                 I don't remember what unaligned access did.
  Take  IBM POWER RISC - pointers are 32 (64) bit, and depending on
                         target object size, 0-3 low-order bits are
                         IGNORED (presumed zero) when accessing memory.
  Take SPARC - Unaligned access (those low-order bits being non-zero)
               causes SIGBUS.
  Take Alpha - Unaligned access (...) does unaligned-access-trap.
  Take i386 - Unaligned accesses are executed happily...

  So.. Some systems can give you 1-3 low-order bits, sometimes needing
  definite masking before usage.    In register-lacking i386 this
  masking is definite punishment..

> > When I discussed this with Rik he said putting it
> > in flags was reasonable.  We can always revisit it in the future if we run
> > out of bits.
> 
> I prefer doing things the most efficient way in core code.
> 
> -- 
> Daniel

/Matti Aarnio
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
