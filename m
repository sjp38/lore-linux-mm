Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
References: <20070814153021.446917377@sgi.com>
	<20070814153501.766137366@sgi.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 14 Aug 2007 22:02:23 +0200
In-Reply-To: <20070814153501.766137366@sgi.com>
Message-ID: <p73vebhnauo.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> writes:

> Reclaim can be called with interrupts disabled in atomic reclaim.
> vmscan.c is currently using spinlock_irq(). Switch to spin_lock_irqsave().

I like the idea in principle. If this fully works out we could
potentially keep less memory free by default which would be a good
thing in general: free memory is bad memory.

But would be interesting to measure what the lock
changes do to interrupt latency. Probably nothing good.

A more benign alternative might be to just set a per CPU flag during
these critical sections and then only do atomic reclaim on a local
interrupt when the flag is not set.  That would make it a little less
reliable, but much less intrusive and with some luck still give many
of the benefits.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
