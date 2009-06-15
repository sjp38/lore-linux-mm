Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0662D6B005C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:26:46 -0400 (EDT)
Date: Mon, 15 Jun 2009 16:28:04 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615162804.4cb75b30@lxorguk.ukuu.org.uk>
In-Reply-To: <20090615152427.GF31969@one.firstfloor.org>
References: <20090615024520.786814520@intel.com>
	<4A35BD7A.9070208@linux.vnet.ibm.com>
	<20090615042753.GA20788@localhost>
	<Pine.LNX.4.64.0906151341160.25162@sister.anvils>
	<20090615140019.4e405d37@lxorguk.ukuu.org.uk>
	<20090615132934.GE31969@one.firstfloor.org>
	<20090615154832.73c89733@lxorguk.ukuu.org.uk>
	<20090615152427.GF31969@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> oops=panic already implies panic on all machine check exceptions, so they will
> be fine then (assuming this is the best strategy for availability 
> for them, which I personally find quite doubtful, but we can discuss this some 
> other time)

You can have the argument with all the people who deploy large systems.
Providing their boxes can be persuaded to panic they don't care about the
masses.

> That's because unpoisioning is quite hard -- you need some kind
> of synchronization point for all the error handling and that's
> the poisoned page and if it unposions itself then you need
> some very heavy weight synchronization to avoid handling errors
> multiple time. I looked at it, but it's quite messy.
> 
> Also it's of somewhat dubious value.

On a system running under a hypervisor or with hot swappable memory its
of rather higher value. In the hypervisor case the guest system can
acquire a new virtual page to replace the faulty one. In fact the
hypervisor case is even more complex as the guest may get migrated at
which point knowledge of "poisoned" memory is not at all connected to
information on hardware failings.

> > 
> > (You can unfail pages on x86 as well it appears by scrubbing them via DMA
> > - yes ?)
> 
> Not architectually. Also the other problem is not just unpoisoning them,
> but finding out if the page is permenantly bad or just temporarily.

Small detail you are overlooking: Hot swap mirrorable memory.

Second detail you are overlooking

	curse a lot
	suspend to disk
	remove dirt from fans, clean/replace RAM
	resume from disk

The very act of making the ECC error not take out the box creates the
environment whereby the underlying hardware error (if there was one) can
be cured.

In all these cases the fact you've got to shoot stuff because a page has
been lost becomes totally disconnected from the idea that the page is
somehow not recoverable and "contaminated" forever.

Which to me says your model is wrong.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
