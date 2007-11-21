Date: Wed, 21 Nov 2007 22:54:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
Message-ID: <20071121225403.GD31674@csn.ul.ie>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com> <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie> <Pine.LNX.4.64.0711211421550.3809@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711211421550.3809@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On (21/11/07 14:28), Christoph Lameter didst pronounce:
> On Wed, 21 Nov 2007, Mel Gorman wrote:
> 
> > 1. In general, the split lists are faster than the combined list
> > 2. Disabling Per-CPU has comparable performance to having the lists
> 
> That is only true for the single threaded case (actually I am measuring a 
> slight performance benefit if I switch them off). If you have multiple 
> processes allocating from the same zone then you can get the zone locks 
> hot.

um, I thought I went through this but I didn't just test single-threaded
and you will see that the test C program forks children to do the
work. 1instances is single process doing the work. 4instance graphs are
4 processes simultaneously doing the work (1 per CPU) and they showed
comparable performance of split lists vs no-PCP lits. They are also bound
to one CPU in an effort to maximise the use of the PCPU lists.  There was
some evidence this was beginning to change when 12 instances (3 per CPU)
were running but I hadn't setup the test to run with more.

> That was the reason for the recent regression in SLUB. The networking
> layer went from an order 0 alloc to order 1. Zonelock contention then
> dropped performance by 50% on an 8p! The potential for lock contention is 
> higher the more processor per nodeare involved. So you are not going to 
> see this as high on a standard NUMA config with 2p per node.
> 

Ok. I've queued the test to re-run on a 16-way x86_64 machine non-NUMA
machine and an 8-way PPC64 2-node-NUMA machine. I haven't worked on this
machines before but hopefully they'll run to completion.

> The main point at this juncture of the pcp lists seems to be avoiding 
> zone lock contention!

I get that. I was suprised with the results too and leads me to wonder if
the lock is being avoided elsewhere (quicklists or slab per-cpu lists maybe)
or if there was a filesystem lock so big, it doesn't matter what the PCPU
allocator is doing. I don't have other profile data available.

> The overhead of extracting a page from the buddy 
> lists is not such a problem.
> 

Ok, the higher-CPU machines may show the zone-lock contention. It could also
be a case that file extend/truncate is not the right thing to be doing either
for these measurements. Read the code and see what you think.

> > single-pcplist-batch8: This is Christophs patch with pcp->high == 8*batch
> > 	as suggested by Martin Bligh (I agreed with him that keeping lists
> > 	the same size made sense)
> 
> Ack.
> 
> I have not had a look at the details of your performance measurements yet. 
> More later.
> 

Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
