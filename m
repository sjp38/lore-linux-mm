From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102151723.JAA43255@google.engr.sgi.com>
Subject: Re: x86 ptep_get_and_clear question
Date: Thu, 15 Feb 2001 09:23:42 -0800 (PST)
In-Reply-To: <20010215173547.A2079@pcep-jamie.cern.ch> from "Jamie Lokier" at Feb 15, 2001 05:35:47 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org, mingo@redhat.com, alan@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> Ben LaHaise wrote:
> > > Processor 2 has recently done some writes, so the dirty bit is set in
> > > processor 2's TLB.
> > >
> > > Processor 1 clears the dirty bit atomically.
> > >
> > > Processor 2 does some more writes, and does not check the page table
> > > because the page is already dirty in its TLB.
> > >
> > > Result: The later writes on processor 2 do not mark the page dirty.
> > 
> > Yeah, but the tlb is flushed in those cases (look for flush_tlb_page in
> > try_to_swap_out).
> 
> As long as processor 1 waits for the flush on processor 2 to complete
> before marking the struct page dirty, that looks fine to me.
> 
> -- Jamie
> 

Since this seems to be so hard to understand, lets keep things simple and
continue with my previous example, instead of pulling new examples.

Look in mm/mprotect.c. Look at the call sequence change_protection() -> ...
change_pte_range(). Specifically at the sequence:

	entry = ptep_get_and_clear(pte);
	set_pte(pte, pte_modify(entry, newprot));

Go ahead and pull your x86 specs, and prove to me that between the 
ptep_get_and_clear(), which zeroes out the pte (specifically, when the 
dirty bit is not set), processor 2 can not come in and set the dirty 
bit on the in-memory pte. Which immediately gets overwritten by the 
set_pte(). For an example of how this can happen, look at my previous 
postings.

Jamie's example misses the point in the sense that at the very beginning,
when he says "Processor 2 has recently done some writes", processor 2 has
made sure that the dirty bit is set in the in-memory pte. So, although 
processor 1 clears the entire pte, the set_pte() will set the dirty bit,
and no information is lost. Even if processor 2 tries writing between
the ptep_get_and_clear() and set_pte(). Whether Jamie was trying to 
illustrate a different problem, I am not sure. All I am trying to say
is that the "dirty bit lost on smp x86" still exists, ptep_get_and_clear
does not do anything to fix it.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
