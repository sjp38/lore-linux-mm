Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 5AED56B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 00:40:05 -0400 (EDT)
Date: Fri, 11 May 2012 00:39:51 -0400 (EDT)
Message-Id: <20120511.003951.1470088131186301605.davem@davemloft.net>
Subject: Re: [PATCH 05/17] mm: allow PF_MEMALLOC from softirq context
From: David Miller <davem@davemloft.net>
In-Reply-To: <1336657510-24378-6-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
	<1336657510-24378-6-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 10 May 2012 14:44:58 +0100

> This is needed to allow network softirq packet processing to make
> use of PF_MEMALLOC.
> 
> Currently softirq context cannot use PF_MEMALLOC due to it not being
> associated with a task, and therefore not having task flags to fiddle
> with - thus the gfp to alloc flag mapping ignores the task flags when
> in interrupts (hard or soft) context.
> 
> Allowing softirqs to make use of PF_MEMALLOC therefore requires some
> trickery.  We basically borrow the task flags from whatever process
> happens to be preempted by the softirq.
> 
> So we modify the gfp to alloc flags mapping to not exclude task flags
> in softirq context, and modify the softirq code to save, clear and
> restore the PF_MEMALLOC flag.
> 
> The save and clear, ensures the preempted task's PF_MEMALLOC flag
> doesn't leak into the softirq. The restore ensures a softirq's
> PF_MEMALLOC flag cannot leak back into the preempted process.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

We're now making changes to task->flags from both base and
softirq context, but with non-atomic operations and no other
kind of synchronization.

As far as I can tell, this has to be racy.

If this works via some magic combination of invariants, you
absolutely have to document this, verbosely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
