Subject: Re: [PATCH]: Making high and batch sizes of per_cpu_pagelists
	configurable
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <20051208192032.6387f638.akpm@osdl.org>
References: <20051208192032.6387f638.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 09 Dec 2005 09:58:05 -0800
Message-Id: <1134151085.7131.66.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-12-08 at 19:20 -0800, Andrew Morton wrote:
> Rohit Seth <rohit.seth@intel.com> wrote:
> >
> > +     if ((high/4) > (PAGE_SHIFT * 8))
> >  +            pcp->batch = PAGE_SHIFT * 8;
> 
> hm.  What relationship is there between log2(PAGE_SIZE) and the batch
> quantity?  I'd have thought that if anything, we'd want to make the
> batch sizes smaller for larger PAGE_SIZE.  Or something.
> 
There is really no relationship between batch with either
log2(PAGE_SIZE) or PAGE_SIZE.  Larger page size machines typically go
with larger memory configs so it is okay to have bigger batch count for
those.  But this can be worked either way.  It is just a number of pages
that will get pulled (and in some cases pushed back) from buddy
allocator at any time.  My initial attempts to make this some function
of power of 2 and such have not gone anywhere.

> >  +    for_each_zone(zone) {
> >  +            for_each_online_cpu(cpu) {
> >  +                    unsigned long  high;
> >  +                    high = zone->present_pages /
> percpu_pagelist_fraction;
> >  +                    setup_pagelist_highmark(zone_pcp(zone, cpu),
> high);
> 
> What happens if a CPU comes online afterwards?
> 
> 

Good point.  Right now the new cpu will use the original boot settings
for the pagelist.  I will send you a smaller patch to correct that.
Basically check at the setup time if the percpu_pagelist_fraction is set
or not and build the pagelist accordingly.

Thanks,
-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
