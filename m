Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B6C7A6B0093
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 16:56:06 -0500 (EST)
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was:
 Re: [linux-pm] Memory allocations in .suspend became very unreliable)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <201001180000.23376.rjw@sisk.pl>
References: <1263549544.3112.10.camel@maxim-laptop>
	 <201001171427.27954.rjw@sisk.pl> <1263754684.724.444.camel@pasglop>
	 <201001180000.23376.rjw@sisk.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Jan 2010 08:55:57 +1100
Message-ID: <1263851757.724.500.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Oliver Neukum <oliver@neukum.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-01-18 at 00:00 +0100, Rafael J. Wysocki wrote:
> On Sunday 17 January 2010, Benjamin Herrenschmidt wrote:
> > On Sun, 2010-01-17 at 14:27 +0100, Rafael J. Wysocki wrote:
> ...
> > However, it's hard to deal with the case of allocations that have
> > already started waiting for IOs. It might be possible to have some VM
> > hook to make them wakeup, re-evaluate the situation and get out of that
> > code path but in any case it would be tricky.
> 
> In the second version of the patch I used an rwsem that made us wait for these
> allocations to complete before we changed gfp_allowed_mask.
> 
> [This is kinda buggy in the version I sent, but I'm going to send an update
> in a minute.]

And nobody screamed due to cache line ping pong caused by this in the
fast path ? :-)

We might want to look at something a bit smarter for that sort of
read-mostly-really-really-mostly construct, though in this case I don't
think RCU is the answer since we are happily scheduling.

I wonder if something per-cpu would do, it's thus the responsibility of
the "writer" to take them all in order for all CPUs.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
