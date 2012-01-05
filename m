Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 1245E6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 09:20:29 -0500 (EST)
Date: Thu, 5 Jan 2012 14:20:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120105142017.GA27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F033EC9.4050909@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Tue, Jan 03, 2012 at 12:45:45PM -0500, KOSAKI Motohiro wrote:
> >   void drain_all_pages(void)
> >   {
> > -	on_each_cpu(drain_local_pages, NULL, 1);
> > +	int cpu;
> > +	struct per_cpu_pageset *pcp;
> > +	struct zone *zone;
> > +
> 
> get_online_cpu() ?
> 

Just a separate note;

I'm looking at some mysterious CPU hotplug problems that only happen
under heavy load. My strongest suspicion at the moment that the problem
is related to on_each_cpu() being used without get_online_cpu() but you
cannot simply call get_online_cpu() in this path without causing
deadlock.

If/when I get a patch that can complete a CPU hotplug stress test
successfully, I'll post it. It'll collide with this series but it should
be manageable.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
