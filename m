Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Date: Mon, 15 Jul 2002 18:10:25 +0200
References: <55160000.1026239746@baldur.austin.ibm.com> <E17U7Gr-0003bX-00@starship> <20020715184016.W28720@mea-ext.zmailer.org>
In-Reply-To: <20020715184016.W28720@mea-ext.zmailer.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17U8Qc-0003bk-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Cc: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 15 July 2002 17:40, Matti Aarnio wrote:
> On Mon, Jul 15, 2002 at 04:56:16PM +0200, Daniel Phillips wrote:
> > On Monday 15 July 2002 16:02, Dave McCracken wrote:
> > > --On Saturday, July 13, 2002 03:13:35 PM +0200 Daniel Phillips
> > > <phillips@arcor.de> wrote:
> > > > Why are we using up valuable real estate in page->flags when the low bit
> > > > of page->pte_chain is available?
> > > 
> > > Right now my flag is bit number 18 in page->flags out of 32.  Mechanisms
> > > already exist to manipulate this bit in a reasonable fashion.  I don't see
> > > any good reason for complicating things by putting a flag bit into a
> > > pointer, where we'd have to repeatedly check and clear it before we
> > > dereference the pointer.
> > 
> > Hi Dave,
> > 
> > It's not more complicated.  You have to check which type of pointer you
> > have anyway, and having to strip away the low bit on one of the two
> > paths is insignificant in terms of generated code.  The current patch
> > has to set and clear the flag bit separately.
> 
>   Better not try to play tricks with pointer bits.
> 
>   Take  ibm360 - pointers are 24 bit, 8 high-order bits are free for
>                  application.  (ibm 370/XA and 390 redefine things.)
>                  I don't remember what unaligned access did.
>   Take  IBM POWER RISC - pointers are 32 (64) bit, and depending on
>                          target object size, 0-3 low-order bits are
>                          IGNORED (presumed zero) when accessing memory.
>   Take SPARC - Unaligned access (those low-order bits being non-zero)
>                causes SIGBUS.
>   Take Alpha - Unaligned access (...) does unaligned-access-trap.
>   Take i386 - Unaligned accesses are executed happily...
> 
>   So.. Some systems can give you 1-3 low-order bits, sometimes needing
>   definite masking before usage.    In register-lacking i386 this
>   masking is definite punishment..

None of these cases apply, the low bit is always masked off before being
used as a pointer.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
