Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D71498D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 19:16:50 -0500 (EST)
Date: Sat, 26 Feb 2011 01:16:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are
 disabled while isolating pages for migration
Message-ID: <20110226001611.GA19630@random.random>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
 <1298664299-10270-3-git-send-email-mel@csn.ul.ie>
 <20110225223204.GW25382@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110225223204.GW25382@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Feb 25, 2011 at 11:32:04PM +0100, Johannes Weiner wrote:
> I don't understand why this conditional is broken up like this.
> cond_resched() will have the right checks anyway.  Okay, you would
> save fatal_signal_pending() in the 'did one cluster' case.  Is it that
> expensive?  Couldn't this be simpler like
> 
> 		did_cluster = ((low_pfn + 1) % SWAP_CLUSTER_MAX) == 0
> 		lock_contended = spin_is_contended(&zone->lru_lock);
> 		if (did_cluster || lock_contended || need_resched()) {
> 			spin_unlock_irq(&zone->lru_lock);
> 			cond_resched();
> 			spin_lock_irq(&zone->lru_lock);
> 			if (fatal_signal_pending(current))
> 				break;
> 		}
> 
> instead?

If we don't release irqs first, how can need_resched get set in the
first place if the local apic irq can't run? I guess that's why
there's no cond_resched_lock_irq. BTW, I never liked too much clearing
interrupts for locks that can't ever be taken from irq (it's a
scalability boost to reduce contention but it makes things like above
confusing and it increases irq latency a bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
