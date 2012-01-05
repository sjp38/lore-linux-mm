Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 34BD66B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 09:41:17 -0500 (EST)
Date: Thu, 5 Jan 2012 14:40:11 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
	exist
Message-ID: <20120105144011.GU11810@n2100.arm.linux.org.uk>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com> <1325499859-2262-8-git-send-email-gilad@benyossef.com> <4F033EC9.4050909@gmail.com> <20120105142017.GA27881@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120105142017.GA27881@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, Jan 05, 2012 at 02:20:17PM +0000, Mel Gorman wrote:
> On Tue, Jan 03, 2012 at 12:45:45PM -0500, KOSAKI Motohiro wrote:
> > >   void drain_all_pages(void)
> > >   {
> > > -	on_each_cpu(drain_local_pages, NULL, 1);
> > > +	int cpu;
> > > +	struct per_cpu_pageset *pcp;
> > > +	struct zone *zone;
> > > +
> > 
> > get_online_cpu() ?
> > 
> 
> Just a separate note;
> 
> I'm looking at some mysterious CPU hotplug problems that only happen
> under heavy load. My strongest suspicion at the moment that the problem
> is related to on_each_cpu() being used without get_online_cpu() but you
> cannot simply call get_online_cpu() in this path without causing
> deadlock.

Mel,

That's a known hotplug problems.  PeterZ has a patch which (probably)
solves it, but there seems to be very little traction of any kind to
merge it.  I've been chasing that patch and getting no replies what so
ever from folk like Peter, Thomas and Ingo.

The problem affects all IPI-raising functions, which mask with
cpu_online_mask directly.

I'm not sure that smp_call_function() can use get_online_cpu() as it
looks like it's not permitted to sleep (it spins in csd_lock_wait if
it is to wait for the called function to complete on all CPUs,
rather than using a sleepable completion.)  get_online_cpu() solves
the online mask problem by sleeping until it's safe to access it.

So, I think this whole CPU bringup mess needs to be re-thought, and
the seemingly constant to pile more and more restrictions onto the
bringup path needs resolving.  It's got to the point where there's
soo many restrictions that actually it's impossible for arch code to
simultaneously satisfy them all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
