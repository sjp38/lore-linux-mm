From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102150237.SAA99186@google.engr.sgi.com>
Subject: Re: x86 ptep_get_and_clear question
Date: Wed, 14 Feb 2001 18:37:39 -0800 (PST)
In-Reply-To: <Pine.LNX.4.30.0102142101290.15070-100000@today.toronto.redhat.com> from "Ben LaHaise" at Feb 14, 2001 09:13:11 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, mingo@redhat.com, alan@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> On Wed, 14 Feb 2001, Kanoj Sarcar wrote:
> 
> > I would like to understand how ptep_get_and_clear() works for x86 on
> > 2.4.1.
> >
> > I am assuming on x86, we do not implement software dirty bit, as is
> > implemented in the mips processors. Rather, the kernel relies on the
> > x86 hardware to update the dirty bit automatically (from looking at
> > the implementation of pte_mkwrite()).
> 
> However, we do set the dirty bit early.
> 

In some cases we do. But if the first access to a RW map_shared file 
page is for read, for example, we will not update dirty bit early. No?


> > The other possibility of course is that somehow processor 2 will interlock
> > out (via hardware), processor 1 will do the flush_tlb_range() out of
> > change_protection(), and then processor 1 will continue. If this is
> > the assumption, I would like to know if this is in some Intel x86 specs.
> >
> > Am I missing something?
> 
> If processor 2 attempts to access the pte while it is cleared, it will
> take a page fault.  This page fault will properly serialize by means of
> the page table spinlock.
> 

You edited out parts of my original email. In that, I mentioned the 
scenario that processor 2 already has the old pte contents (which gives
read/write permission, but does not have the pte dirty) in its own tlb.
Why would it take a page fault in this case?

> > I am assuming Ben Lahaise wrote this code. I remember having an earlier
> > conversation with Alan about this too (we did not know which scenario
> > could happen), who suggested I ask Ingo. I do not remember what happened
> > after that.
> 
> x86 hardware goes back to the page tables whenever there is an attempt to
> change the access it has to the pte.  Ie, if it originally accessed the
> page table for reading, it will go back to the page tables on write.  I
> believe most hardware that performs accessed/dirty bit updates in hardware
> behaves the same way.
>

Okay, what do you think x86 will do on processor 2 on a write if it goes
to the incore pte and sees that the dirty bit is cleared? Do you have any
specs to support your statement "x86 hardware goes back to the page tables
whenever there is an attempt to change the access it has to the pte"?

Kanoj
 
> 		-ben
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
