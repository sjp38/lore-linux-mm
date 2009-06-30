Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B017F6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 20:56:46 -0400 (EDT)
Date: Tue, 30 Jun 2009 08:58:28 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: + memory-hotplug-update-zone-pcp-at-memory-online.patch added
	to -mm tree
Message-ID: <20090630005828.GC21254@sli10-desk.sh.intel.com>
References: <200906291949.n5TJno8X028680@imap1.linux-foundation.org> <alpine.DEB.1.10.0906291814150.21956@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906291814150.21956@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Zhao, Yakui" <yakui.zhao@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 06:17:52AM +0800, Christoph Lameter wrote:
> On Mon, 29 Jun 2009, akpm@linux-foundation.org wrote:
> 
> > In my test, 128M memory is hot added, but zone's pcp batch is 0, which is
> > an obvious error.  When pages are onlined, zone pcp should be updated
> > accordingly.
> 
> Another side effect of the checks for unpopulated zones....?
Even for populated zones, the pcp should be updated as its value might not
be good as more memory is added.

> > diff -puN mm/page_alloc.c~memory-hotplug-update-zone-pcp-at-memory-online mm/page_alloc.c
> > --- a/mm/page_alloc.c~memory-hotplug-update-zone-pcp-at-memory-online
> > +++ a/mm/page_alloc.c
> > @@ -3135,6 +3135,31 @@ int zone_wait_table_init(struct zone *zo
> >  	return 0;
> >  }
> >
> > +static int __zone_pcp_update(void *data)
> > +{
> > +	struct zone *zone = data;
> > +	int cpu;
> > +	unsigned long batch = zone_batchsize(zone), flags;
> > +
> > +	for (cpu = 0; cpu < NR_CPUS; cpu++) {
> 
> foreach possible cpu?
Just follows zone_pcp_init(), do you think we should change that too?

> > +		struct per_cpu_pageset *pset;
> > +		struct per_cpu_pages *pcp;
> > +
> > +		pset = zone_pcp(zone, cpu);
> > +		pcp = &pset->pcp;
> > +
> > +		local_irq_save(flags);
> > +		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> 
> There are no pages in the pageset since the pcp batch is zero right?
It might not be zero for a populated zone, see above comments.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
