Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id BFEAC6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:02:35 -0400 (EDT)
Date: Mon, 14 May 2012 11:02:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 05/17] mm: allow PF_MEMALLOC from softirq context
Message-ID: <20120514100229.GA29102@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
 <1336657510-24378-6-git-send-email-mgorman@suse.de>
 <20120511.003951.1470088131186301605.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120511.003951.1470088131186301605.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

On Fri, May 11, 2012 at 12:39:51AM -0400, David Miller wrote:
> From: Mel Gorman <mgorman@suse.de>
> Date: Thu, 10 May 2012 14:44:58 +0100
> 
> > This is needed to allow network softirq packet processing to make
> > use of PF_MEMALLOC.
> > 
> > Currently softirq context cannot use PF_MEMALLOC due to it not being
> > associated with a task, and therefore not having task flags to fiddle
> > with - thus the gfp to alloc flag mapping ignores the task flags when
> > in interrupts (hard or soft) context.
> > 
> > Allowing softirqs to make use of PF_MEMALLOC therefore requires some
> > trickery.  We basically borrow the task flags from whatever process
> > happens to be preempted by the softirq.
> > 
> > So we modify the gfp to alloc flags mapping to not exclude task flags
> > in softirq context, and modify the softirq code to save, clear and
> > restore the PF_MEMALLOC flag.
> > 
> > The save and clear, ensures the preempted task's PF_MEMALLOC flag
> > doesn't leak into the softirq. The restore ensures a softirq's
> > PF_MEMALLOC flag cannot leak back into the preempted process.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> We're now making changes to task->flags from both base and
> softirq context, but with non-atomic operations and no other
> kind of synchronization.
> 
> As far as I can tell, this has to be racy.
> 

I'm not seeing the race you are thinking of.

Softirqs can run on multiple CPUs sure but the same task should not be
	executing the same softirq code. Interrupts are disabled and the
	executing process cannot sleep in softirq context so the task flags
	cannot "leak" nor can they be concurrently modified.

Softirqs are not execued from hard interrupt context so there are no
	races with hardirqs.

If the softirq is deferred to ksoftirq then its flags may be used
	instead of a normal tasks but as the softirq cannot be preempted,
	the PF_MEMALLOC flag does not leak to other code by accident.

When __do_softirq() is finished, care is taken to restore the
	PF_MEMALLOC flag to the value when __do_softirq() started. They
	should not be accidentally clearing the flag.

I'm not seeing how current->flags can be modified while the softirq handler
is running in such a way that information is lost or misused. There
would be a problem if softirqs used GFP_KERNEL because the presense of
the PF_MEMALLOC flag would prevent the use of direct reclaim but softirqs
cannot use direct reclaim anyway.

> If this works via some magic combination of invariants, you
> absolutely have to document this, verbosely.

Did I miss a race you are thinking of or should I just add the above
explanation to the changelog?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
