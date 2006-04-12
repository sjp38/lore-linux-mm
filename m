Date: Wed, 12 Apr 2006 09:43:46 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 2/6] Migrate-on-fault - check for
 misplaced page
Message-Id: <20060412094346.0a974f1c.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604111109370.878@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
	<1144441382.5198.40.camel@localhost.localdomain>
	<Pine.LNX.4.64.0604111109370.878@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee.Schermerhorn@hp.com, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Christoph, respnonding to Lee:
> > +			/*
> > +			 * allows binding to multiple nodes.
> > +			 * use current page if in zonelist,
> > +			 * else select first allowed node
> > +			 */
> > +			mems = &pol->cpuset_mems_allowed;
> > +			...
> 
> Hmm.... Checking for the current node in memory policy? How does this 
> interact with cpuset constraints?

The per-mempolicy 'cpuset_mems_allowed' does not specify the nodes to
which the task is bound, but rather the nodes to which the mempolicy is
relative.  No code except the mempolicy rebinding code should be using
the mempolicy->cpuset_mems_allowed field.

The proper way to check if a zone is allowed by cpusets appears
in several places in the files mm/page_alloc.c, mm/vmscan.c, and
mm/hugetlb.c.

$ grep cpuset_zone_allowed mm/*.c
mm/hugetlb.c:           if (cpuset_zone_allowed(*z, GFP_HIGHUSER) &&
mm/oom_kill.c:          if (cpuset_zone_allowed(*z, gfp_mask))
mm/page_alloc.c:         * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
mm/page_alloc.c:                                !cpuset_zone_allowed(*z, gfp_mask))
mm/page_alloc.c:         * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
mm/vmscan.c:            if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
mm/vmscan.c:            if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
mm/vmscan.c:            if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))
mm/vmscan.c:    if (!cpuset_zone_allowed(zone, __GFP_HARDWALL))

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
