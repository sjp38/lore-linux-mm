Date: Mon, 11 Sep 2000 23:39:31 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [PATCH] workaround for lost dirty bits on x86 SMP
In-Reply-To: <200009120234.TAA39381@google.engr.sgi.com>
Message-ID: <Pine.LNX.3.96.1000911231400.11709A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Sep 2000, Kanoj Sarcar wrote:

> Not really, I thought I had it in a state where the bare minimum
> was being done. Of course, this was the non-PAE version ...

PAE already has to do the atomic updates, and could possibly withstand a
couple of tweaks: eg clear_pte should be okay if it is a locked clear of
the present bit and non-atomic clear of the high bits.

[...]
> With the above type of apps, you do not need too high a _memory_ pressure
> to trigger this, just compute pressure. Each time you come in to drop in
> the "dirty" bit, you would need to do establish_pte(), which does a 
> flush_tlb_page(), which gets costly when you have higher cpu counts. 

If the process is active, it will be updating the accessed bit on a
regular basis, so there will be no need to clear the dirty bit.  Also, we
mark mappings dirty early, so there is no extra fault on the typical case
of writing to data.  If the process was sharing the page read only (ie
zero page), it would still have had to do the tlb flush anyways.  As for
the tlb flushing in establish_pte, we should be avoiding the cross cpu tlb
flush since any other processor would take a write fault, at which it
would update its tlb.  establish_pte is only called from 3 places, two of
which are passing in the same page with either the accessed, dirty or
write bits enabled.

> This of course depends on how smart flush_tlb_page is, and the processor
> involved.

We're only talking about x86 SMP. =)  I think it and m68k SMP (which isn't
implemented afair) are the only vulnerable platforms to this problem
(since all others implement dirty bits in software).

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
