From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102151738.JAA86611@google.engr.sgi.com>
Subject: Re: x86 ptep_get_and_clear question
Date: Thu, 15 Feb 2001 09:38:42 -0800 (PST)
In-Reply-To: <Pine.LNX.4.30.0102151225520.15843-100000@today.toronto.redhat.com> from "Ben LaHaise" at Feb 15, 2001 12:27:42 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, linux-mm@kvack.org, mingo@redhat.com, alan@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> On Thu, 15 Feb 2001, Kanoj Sarcar wrote:
> 
> > continue with my previous example, instead of pulling new examples.
> >
> > Look in mm/mprotect.c. Look at the call sequence change_protection() -> ...
> > change_pte_range(). Specifically at the sequence:
> >
> > 	entry = ptep_get_and_clear(pte);
> > 	set_pte(pte, pte_modify(entry, newprot));
> >
> > Go ahead and pull your x86 specs, and prove to me that between the
> > ptep_get_and_clear(), which zeroes out the pte (specifically, when the
> > dirty bit is not set), processor 2 can not come in and set the dirty
> > bit on the in-memory pte. Which immediately gets overwritten by the
> > set_pte(). For an example of how this can happen, look at my previous
> > postings.
> 
> Look at the specs.  The processor uses read-modify-write cycles to update
> the accessed and dirty bits.  If the in memory pte is either not present
> or writable, the processor will take a page fault.

What specs are you looking at? Please be specific with revision/volume/
section/page number if you are quoting from hardcopy. If you are looking 
at online manuals, please provide a pointer. I am specifically interested
in your claim "If the in memory pte is either not present or writable,
the processor will take a page fault".

This was what I asked for in the first place. We could have saved so much
email exchange if you would just have posted this information.

> 
> > Jamie's example misses the point in the sense that at the very beginning,
> > when he says "Processor 2 has recently done some writes", processor 2 has
> > made sure that the dirty bit is set in the in-memory pte. So, although
> > processor 1 clears the entire pte, the set_pte() will set the dirty bit,
> > and no information is lost. Even if processor 2 tries writing between
> > the ptep_get_and_clear() and set_pte(). Whether Jamie was trying to
> > illustrate a different problem, I am not sure. All I am trying to say
> > is that the "dirty bit lost on smp x86" still exists, ptep_get_and_clear
> > does not do anything to fix it.
> 
> Yes it does.  Write a test program like I did.  The processor does take a
> page fault.

Do you have the program saved (or can explain how it worked)? I would very 
much like to understand exactly how you were tickling the race condition 
by a user program (without hacking the kernel) deterministically.

Another thing: "The processor does take a page fault" might mean that 
current Intel processors do it, but future ones might not. Unless it is
part of the x86 specs. Thats why I am so interested in seeing it.

Kanoj

> 
> 		-ben
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
