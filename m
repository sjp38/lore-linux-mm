Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Date: Mon, 15 Jul 2002 19:50:59 +0200
References: <55160000.1026239746@baldur.austin.ibm.com> <E17U8kG-0003bx-00@starship> <20020715195527.X28720@mea-ext.zmailer.org>
In-Reply-To: <20020715195527.X28720@mea-ext.zmailer.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17U9zw-0003dQ-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 15 July 2002 18:55, Matti Aarnio wrote:
> On Mon, Jul 15, 2002 at 06:30:43PM +0200, Daniel Phillips wrote:
> > On Monday 15 July 2002 17:40, Matti Aarnio wrote:
> > > In register-lacking i386 this  masking is definite punishment..
> > 
> > Nonsense, the value needs to be loaded into a register anyway
> > before being used.
> 
>   Think in assembly, what is needed in i386 to mask the pointer ?

	and <reg>, -2

(apologies for thinking in Intel assembly, old habits die hard)

>   How the pointer is then used ?

Like any pointer.

>   How many register you need ?

One.

>   What registers can be used for masking arithmetics, and which
>   are usable in indexed memory reference address calculation ?

No extra register for masking arithmetic.

>   Linus seems to care about this kind of speed things, and
>   at least DaveM does look into gcc generated assembly to
>   verify, that used C idioms are compiled correctly and fast.

Yes, I guess I will generate the assembly code and have a look.
There is a lot more than just instructions/cycle counts to worry
about in code optimization.  Other big considerations are cache
line hits, address generation interlocks and suitability of the
code for multiple execution units.

Getting down to nano-efficiency here, masking the address before
using it will generate a one cycle stall in one of the execution
pipes on classic pentium.  That doesn't matter here - supposing
we use the low bit to indicate the non-direct case: the very
next thing we want to do after masking off the low bit is test
to see if the result is zero.  Hey, our masking operation just
set the condition codes, isn't that nice.  And the following jmp
instruction nicely fills the AGI slot.

Now I'm going to suggest an optimization that *is* really ugly:
note that in the current patch, the list always terminates with
null.  But suppose instead it terminates with a pointer to a pte, 
with the low bit set.  We save 8 bytes per pte chain, and that is 
not to be taken lightly.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
