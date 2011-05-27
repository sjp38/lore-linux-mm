Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE8AA6B0022
	for <linux-mm@kvack.org>; Fri, 27 May 2011 14:21:01 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p4RIKMw1019166
	for <linux-mm@kvack.org>; Sat, 28 May 2011 04:20:22 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RIKmKS434180
	for <linux-mm@kvack.org>; Sat, 28 May 2011 04:20:50 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RIKl6R024593
	for <linux-mm@kvack.org>; Sat, 28 May 2011 04:20:47 +1000
Date: Fri, 27 May 2011 23:50:41 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/10] mm: Introduce the memory regions data structure
Message-ID: <20110527182041.GM5654@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <1306499498-14263-2-git-send-email-ankita@in.ibm.com>
 <1306510203.22505.69.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1306510203.22505.69.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, thomas.abraham@linaro.org

* Dave Hansen <dave@linux.vnet.ibm.com> [2011-05-27 08:30:03]:

> On Fri, 2011-05-27 at 18:01 +0530, Ankita Garg wrote:
> > +typedef struct mem_region_list_data {
> > +       struct zone zones[MAX_NR_ZONES];
> > +       int nr_zones;
> > +
> > +       int node;
> > +       int region;
> > +
> > +       unsigned long start_pfn;
> > +       unsigned long spanned_pages;
> > +} mem_region_t;
> > +
> > +#define MAX_NR_REGIONS    16 
> 
> Don't do the foo_t thing.  It's out of style and the pg_data_t is a
> dinosaur.
> 
> I'm a bit surprised how little discussion of this there is in the patch
> descriptions.  Why did you choose this structure?  What are the
> downsides of doing it this way?  This effectively breaks up the zone's
> LRU in to MAX_NR_REGIONS LRUs.  What effects does that have?

This data structure is one of the option, but definitely has
overheads.  One alternative was to use fake-numa nodes that has more
overhead and user visible quirks.

The overheads is based on the number of regions actually defined in
the platform. It may be 2-4 in smaller systems.  This split is what
makes the allocations and reclaims work withing these boundaries using
the zone's active, inactive lists on a per memory regions basis.

An external structure to just capture the boundaries would have less
overheads, but does not provide enough hooks to influence the zone
level allocators and reclaim operations.

> How big _is_ a 'struct zone' these days?  This patch will increase their
> effective size by 16x.

Yes, this is not good, we should to a runtime allocation for the exact
number of regions that we need.  This can be optimized later once we
design the data structure hierarchy with least overhead for the
purpose.

> Since one distro kernel basically gets run on *EVERYTHING*, what will
> MAX_NR_REGIONS be in practice?  How many regions are there on the
> largest systems that will need this?  We're going to be doing many
> linear searches and iterations over it, so it's pretty darn important to
> know.  What does this do to lmbench numbers sensitive to page
> allocations?

Yep, agreed, we are generally looking at 2-4 regions per-node for most
purposes.  Also regions need not be of equal size, they can be large
and small based on platform characteristics so that we need not
fragment the zones below the level required.

The overall idea is to have a VM data structure that can capture
various boundaries of memory, and enable the allocations and reclaim
logic to target certain areas based on the boundaries and properties
required.  NUMA node and pgdat is the example of capturing memory
distances.  The proposed memory regions should capture other
orthogonal properties and boundaries of memory addresses similar to
zone type.

Thanks for the quick feedback.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
