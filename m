Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 312916B00A8
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 17:03:49 -0400 (EDT)
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <56111.84.105.60.153.1287521237.squirrel@gate.crashing.org>
References: <20101019181021.22456.qmail@kosh.dhis.org>
	 <56111.84.105.60.153.1287521237.squirrel@gate.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Oct 2010 08:02:48 +1100
Message-ID: <1287522168.2198.5.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Segher Boessenkool <segher@kernel.crashing.org>
Cc: pacman@kosh.dhis.org, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-10-19 at 22:47 +0200, Segher Boessenkool wrote:
> 
> It looks like it is the frame counter in an USB OHCI HCCA.
> 16-bit, 1kHz update, offset x'80 in a page.
> 
> So either the kernel forgot to call quiesce on it, or the firmware
> doesn't implement that, or the firmware messed up some other way.

I vote for the FW being on crack. Wouldn't be the first time with
Pegasos.

It's an OHCI or an UHCI in there ?

Can you try in prom_init.c changing the prom_close_stdin() function to
also close "stdout" ? 

         if (prom_getprop(_prom->chosen, "stdin", &val, sizeof(val)) > 0)
                 call_prom("close", 1, 0, val);
+        if (prom_getprop(_prom->chosen, "stdout", &val, sizeof(val)) > 0)
+               call_prom("close", 1, 0, val);

See if that makes a difference ?

Last option would be to manually turn the thing off with MMIO in yet-another
pegasos workaround in prom_init.c.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
