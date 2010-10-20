Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D45D76B00BB
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 23:23:48 -0400 (EDT)
Message-ID: <20101020032345.5240.qmail@kosh.dhis.org>
From: pacman@kosh.dhis.org
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Date: Tue, 19 Oct 2010 22:23:45 -0500 (GMT+5)
In-Reply-To: <1287522168.2198.5.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Segher Boessenkool <segher@kernel.crashing.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt writes:
> 
> On Tue, 2010-10-19 at 22:47 +0200, Segher Boessenkool wrote:
> > 
> > It looks like it is the frame counter in an USB OHCI HCCA.
> > 16-bit, 1kHz update, offset x'80 in a page.
> > 
> > So either the kernel forgot to call quiesce on it, or the firmware
> > doesn't implement that, or the firmware messed up some other way.
> 
> I vote for the FW being on crack. Wouldn't be the first time with
> Pegasos.
> 
> It's an OHCI or an UHCI in there ?

There's one of each... UHCI on the motherboard, OHCI on a card in a PCI
expansion slot. They shipped the ODW with the extra controller on an
expansion card since the on-board UHCI doesn't do USB2.0.

And that OHCI controller does appear to be the culprit. The 2 affected
addresses tick at 1000Hz until ohci-hcd is modprobe'd, then they stop.

I think the mm people can consider this closed. 6dda9d55 didn't do anything
but expose a problem which has been here all along. Will drop them from Cc
list in any further messages.

> 
> Can you try in prom_init.c changing the prom_close_stdin() function to
> also close "stdout" ? 
> 
>          if (prom_getprop(_prom->chosen, "stdin", &val, sizeof(val)) > 0)
>                  call_prom("close", 1, 0, val);
> +        if (prom_getprop(_prom->chosen, "stdout", &val, sizeof(val)) > 0)
> +               call_prom("close", 1, 0, val);
> 
> See if that makes a difference ?

Huge difference. With no stdout to print to, the kernel seems to freeze up.
Or at least it loses the console. The last message it prints is "Device tree
struct 0x00933000 -> 0x00957000" then there's just nothing. I waited a while
for the console to come on but it didn't.

The diff fragment above applied inside prom_close_stdin, but there are some
prom_printf calls after prom_close_stdin. Calling prom_printf after closing
stdout sounds like it could be bad. If I moved it down below all the
prom_printf's, it would be after the "quiesce" call. Would that be acceptable
(or even interesting as an experiment)? Does a close need a quiesce after it?

-- 
Alan Curry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
