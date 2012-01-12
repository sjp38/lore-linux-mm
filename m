Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id BC75B6B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 10:37:22 -0500 (EST)
Date: Thu, 12 Jan 2012 15:37:12 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: page allocator: Do not drain per-cpu lists via
 IPI from page allocator context
Message-ID: <20120112153712.GL4118@suse.de>
References: <1326276668-19932-1-git-send-email-mgorman@suse.de>
 <1326276668-19932-3-git-send-email-mgorman@suse.de>
 <1326381492.2442.188.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1326381492.2442.188.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Gilad Ben-Yossef <gilad@benyossef.com>, "Paul E.  McKenney" <paulmck@linux.vnet.ibm.com>, Miklos Szeredi <mszeredi@novell.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <gregkh@suse.de>, Gong Chen <gong.chen@intel.com>

On Thu, Jan 12, 2012 at 04:18:12PM +0100, Peter Zijlstra wrote:
> On Wed, 2012-01-11 at 10:11 +0000, Mel Gorman wrote:
> > At least one bug report has
> > been seen on ppc64 against a 3.0 era kernel that looked like a bug
> > receiving interrupts on a CPU being offlined. 
> 
> Got details on that Mel? The preempt_disable() in on_each_cpu() should
> serialize against the stop_machine() crap in unplug.

I might have added 2 and 2 together and got 5.

The stack trace clearly was while sending IPIs in on_each_cpu() and
always when under memory pressure and stuck in direct reclaim. This was
on !PREEMPT kernels where preempt_disable() is a no-op. That is why I
thought get_online_cpu() would be necessary.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
