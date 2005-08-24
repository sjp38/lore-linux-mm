Date: 24 Aug 2005 10:27:49 -0400
Message-ID: <20050824142749.14667.qmail@science.horizon.com>
From: linux@horizon.com
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@engr.sgi.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Atomicity can be guaranteed to some degree by using the present bit. 
> For an update the present bit is first switched off. When a 
> new value is written, it is first written in the piece of the entry that 
> does not contain the pte bit which keeps the entry "not present". Last the 
> word with the present bit is written.

Er... no.  That would work if reads were atomic but writes weren't, but
consider the following:

Reader		Writer
Read first half
		Write not-present bit
		Write other half
		Write present bit
Read second half

Voila, mismatched halves.
Unless you can give a guarantee on relative rates of progress, this
can't be made to work.

The first obvious fix is to read the first half a second time and make
sure it matches, retrying if not.  The idea being that if the PTE changed
from AB to AC, you might not notice the change, but it wouldn't matter,
either.  But that can fail, too, in sufficiently contrived circumstances:

Reader		Writer
Read first half
		Write not-present bit
		Write other half
		Write present bit
Read second half
		Write not-present bit
		Write other half
		Write present bit
Read first half

If it changed from AB -> CD -> AE, you could read AD and not notice the
problem.


And remember that relative rates in SMP systems are *usually* matched,
but if you depend for correctness on a requirement that there be no
interrupts, no NMI, no SMM, no I-cache miss, no I-cache parity error that
triggered a re-fetch, no single-bit ECC error that triggered scrubbing,
etc., then you're really tightly constraining the rest of the system.

Modern processors do all kinds of strange low-probability exception
handling in order to speed up the common case.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
