Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E2276B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 10:00:56 -0400 (EDT)
Date: Wed, 17 Jun 2009 09:00:53 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: + page_alloc-oops-when-setting-percpu_pagelist_fraction.patch
	added to -mm tree
Message-ID: <20090617140053.GB32637@sgi.com>
References: <200906161901.n5GJ1osY026940@imap1.linux-foundation.org> <20090617091040.99BB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617091040.99BB.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: cl@linux-foundation.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 09:21:27AM +0900, KOSAKI Motohiro wrote:
> (switch to lkml)
> 
> Sorry for late review.
> 
> >  mm/page_alloc.c |    6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff -puN mm/page_alloc.c~page_alloc-oops-when-setting-percpu_pagelist_fraction mm/page_alloc.c
> > --- a/mm/page_alloc.c~page_alloc-oops-when-setting-percpu_pagelist_fraction
> > +++ a/mm/page_alloc.c
> > @@ -2806,7 +2806,11 @@ static int __cpuinit process_zones(int c
> >  
> >  	node_set_state(node, N_CPU);	/* this node has a cpu */
> >  
> > -	for_each_populated_zone(zone) {
> > +	for_each_zone(zone) {
> > +		if (!populated_zone(zone)) {
> > +			zone_pcp(zone, cpu) = &boot_pageset[cpu];
> > +			continue;
> > +		}
> >  		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
> >  					 GFP_KERNEL, node);
> >  		if (!zone_pcp(zone, cpu))
> 
> I don't think this code works.
> pcp is only protected local_irq_save(), not spin lock. it assume
> each cpu have different own pcp. but this patch break this assumption.
> Now, we can share boot_pageset by multiple cpus.
> 

I'm not quite understanding what you mean.

Prior to the cpu going down, each unpopulated zone pointed to the boot_pageset (per_cpu_pageset) for it's cpu (it's array element), so things had been set up this way already.  I could be missing something, but am not sure why restoring this would be a risk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
