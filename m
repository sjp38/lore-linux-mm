Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C13E6B0089
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 08:52:11 -0500 (EST)
Date: Thu, 23 Dec 2010 13:51:20 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
Message-ID: <20101223135120.GL3636@n2100.arm.linux.org.uk>
References: <cover.1292443200.git.m.nazarewicz@samsung.com> <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com> <20101223100642.GD3636@n2100.arm.linux.org.uk> <87k4j0ehdl.fsf@erwin.mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k4j0ehdl.fsf@erwin.mina86.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Kyungmin Park <kmpark@infradead.org>, linux-arm-kernel@lists.infradead.org, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 02:41:26PM +0100, Michal Nazarewicz wrote:
> Russell King - ARM Linux <linux@arm.linux.org.uk> writes:
> > Has anyone addressed my issue with it that this is wide-open for
> > abuse by allocating large chunks of memory, and then remapping
> > them in some way with different attributes, thereby violating the
> > ARM architecture specification?
> >
> > In other words, do we _actually_ have a use for this which doesn't
> > involve doing something like allocating 32MB of memory from it,
> > remapping it so that it's DMA coherent, and then performing DMA
> > on the resulting buffer?
> 
> Huge pages.
> 
> Also, don't treat it as coherent memory and just flush/clear/invalidate
> cache before and after each DMA transaction.  I never understood what's
> wrong with that approach.

If you've ever used an ARM system with a VIVT cache, you'll know what's
wrong with this approach.

ARM systems with VIVT caches have extremely poor task switching
performance because they flush the entire data cache at every task switch
- to the extent that it makes system performance drop dramatically when
they become loaded.

Doing that for every DMA operation will kill the advantage we've gained
from having VIPT caches and ASIDs stone dead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
